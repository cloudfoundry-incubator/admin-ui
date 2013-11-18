require 'json'
require 'nats/client'

module AdminUI
  class NATS
    def initialize(config, logger, email)
      @config = config
      @logger = logger
      @email  = email

      FileUtils.mkpath File.dirname(@config.data_file)

      @semaphore = Mutex.new
      @condition = ConditionVariable.new

      @use_cache = true

      @cache = {}

      Thread.new do
        loop do
          schedule_discovery
        end
      end
    end

    def get
      @semaphore.synchronize do
        @condition.wait(@semaphore) while @cache['items'].nil?
        @cache.clone
      end
    end

    def remove(uris)
      @semaphore.synchronize do
        if File.exists?(@config.data_file)
          @cache = JSON.parse(IO.read(@config.data_file))

          uris.each do |uri|
            @cache['items'].delete(uri)
            @cache['notified'].delete(uri)
          end

          File.open(@config.data_file, 'w') do |file|
            file.write(JSON.pretty_generate(@cache))
          end
        end
      end
    end

    private

    def schedule_discovery
      nats_discovery_results = nats_discovery

      disconnected = []

      @semaphore.synchronize do
        save_data(nats_discovery_results, disconnected)

        send_email(disconnected)

        @use_cache = true
        @condition.broadcast
        @condition.wait(@semaphore, @config.nats_discovery_interval)
      end
    end

    def nats_discovery
      result = {}
      result['items'] = {}

      begin
        @logger.debug("[#{ @config.nats_discovery_interval } second interval] Starting NATS discovery...")

        @start_time = Time.now.to_f

        @last_discovery_time = 0

        Thread.new do
          while (@last_discovery_time == 0 && (Time.now.to_f - @start_time < @config.nats_discovery_interval)) || (Time.now.to_f - @last_discovery_time < @config.nats_discovery_timeout)
            sleep(@config.nats_discovery_timeout)
          end
          ::NATS.stop
        end

        ::NATS.start(:uri => @config.mbus) do
          # Set the connected to true to handle case where NATS is back up but no components are.
          # This gets rid of the disconnected error message on the UI without waiting for the nats_discovery_interval.
          @semaphore.synchronize do
            @cache['connected'] = true
          end

          ::NATS.request('vcap.component.discover') do |item|
            @last_discovery_time = Time.now.to_f
            item_json = JSON.parse(item)
            result['items'][item_uri(item_json)] = item_json
          end
        end

        result['connected'] = true
      rescue => error
        result['connected'] = false

        @logger.debug("Error during NATS discovery: #{ error.inspect }")
        @logger.debug(error.backtrace.join("\n"))
      end

      result
    end

    def save_data(nats_discovery_results, disconnected)
      @logger.debug('Saving NATS data...')

      @cache = {}

      @cache['items']    = {}
      @cache['notified'] = {}

      begin
        @cache = JSON.parse(IO.read(@config.data_file)) if @use_cache && File.exists?(@config.data_file)

        @cache['connected'] = nats_discovery_results['connected']
        @cache['items'].merge!(nats_discovery_results['items'])

        update_connection_status('NATS',
                                 @config.mbus.partition('@').last[0..-1],
                                 @cache['connected'],
                                 disconnected)

        @cache['items'].each do |url, item|
          update_connection_status(item['type'],
                                   url,
                                   !nats_discovery_results['items'][url].nil?,
                                   disconnected)
        end

        File.open(@config.data_file, 'w') do |file|
          file.write(JSON.pretty_generate(@cache))
        end
      rescue => error
        @logger.debug("Error during NATS save data: #{ error.inspect }")
        @logger.debug(error.backtrace.join("\n"))
      end
    end

    def send_email(disconnected)
      if @email.configured? && disconnected.length > 0
        Thread.new do
          begin
            @email.send_email(disconnected)
          rescue => error
            @logger.debug("Error during send email: #{ error.inspect }")
            @logger.debug(error.backtrace.join("\n"))
          end
        end
      end
    end

    def update_connection_status(type, uri, connected, disconnectedList)
      if monitored?(type)
        if connected
          @cache['notified'].delete(uri)
        else
          component_entry = component_entry(type, uri)
          if component_entry['count'] < @config.component_connection_retries
            @logger.debug("The #{ type } component #{ uri } is not responding, its status will be checked again next refresh")
          elsif component_entry['count'] == @config.component_connection_retries
            @logger.debug("The #{ type } component #{ uri } has been recognized as disconnected")
            disconnectedList.push(component_entry)
          else
            @logger.debug("The #{ type } component #{ uri } is still not responding")
          end
        end
      end
    end

    def monitored?(component)
      @config.monitored_components.each do |type|
        if !(component =~ /#{ type }/).nil? || type.casecmp('ALL') == 0
          return true
        end
      end
      false
    end

    def component_entry(type, uri)
      result = @cache['notified'][uri]
      result = { 'count' => 0, 'type' => type, 'uri' => uri } if result.nil?
      result['count'] += 1
      @cache['notified'][uri] = result

      result
    end

    def item_uri(item)
      "http://#{ item['host'] }/varz"
    end
  end
end
