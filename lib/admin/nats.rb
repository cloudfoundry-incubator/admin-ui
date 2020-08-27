require 'nats/client'
require 'uri'
require 'yajl'

module AdminUI
  class NATS
    NATS_COMMON_KEYS = %w[credentials host index start type uuid uptime].freeze

    def initialize(config, logger, email, testing)
      @config  = config
      @logger  = logger
      @email   = email
      @testing = testing

      @running = true

      FileUtils.mkpath File.dirname(@config.data_file)

      @semaphore = Mutex.new
      @condition = ConditionVariable.new

      @cache = {}

      @thread = Thread.new do
        schedule_discovery while @running
      end

      @thread.priority = -2
    end

    def get
      @semaphore.synchronize do
        @condition.wait(@semaphore) while @testing && @running && @cache['items'].nil?
        return disconnected_result if @cache['items'].nil?

        @cache.clone
      end
    end

    def remove(uris)
      @semaphore.synchronize do
        @cache = read_or_initialize_cache

        removed = false
        uris.each do |uri|
          removed = true unless @cache['items'].delete(uri).nil?
          removed = true unless @cache['notified'].delete(uri).nil?
        end

        write_cache if removed
      ensure
        @condition.broadcast
      end
    end

    def shutdown
      return unless @running

      @running = false

      @semaphore.synchronize do
        @condition.broadcast
      end
    end

    def join
      @thread.join
    end

    private

    def disconnected_result
      {
        'connected' => false,
        'items'     => {},
        'notified'  => {}
      }
    end

    def schedule_discovery
      nats_discovery_results = nats_discovery

      disconnected = []

      @semaphore.synchronize do
        if @running
          save_data(nats_discovery_results, disconnected)
          send_email(disconnected)
        end
      ensure
        @condition.broadcast
        @condition.wait(@semaphore, @config.nats_discovery_interval) if @running
      end
    end

    def nats_discovery
      result         = { 'connected' => false, 'items' => {} }
      error_received = false

      begin
        @logger.debug("[#{@config.nats_discovery_interval} second interval] Starting NATS discovery...")

        @start_time = Time.now.to_f

        @last_discovery_time = 0

        EventMachine.next_tick do
          ::NATS.on_error do |error|
            result['connected'] = false
            @logger.error("Error during NATS discovery reported to NATS.on_error: #{error.inspect}")

            error_received = true

            @semaphore.synchronize do
              @condition.broadcast
            end
          rescue => error
            @logger.error("Error during NATS.on_error callback: #{error.inspect}")
            @logger.error(error.backtrace.join("\n"))
          end

          options =
            {
              uri:           @config.mbus,
              ping_interval: @config.nats_discovery_timeout
            }

          unless @config.nats_tls_cert_chain_file.nil? || @config.nats_tls_private_key_file.nil?
            tls =
              {
                cert_chain_file:  @config.nats_tls_cert_chain_file,
                private_key_file: @config.nats_tls_private_key_file
              }

            tls[:ca_file]     = @config.nats_tls_ca_file unless @config.nats_tls_ca_file.nil?
            tls[:verify_peer] = @config.nats_tls_verify_peer unless @config.nats_tls_verify_peer.nil?

            options[:tls] = tls
          end

          ::NATS.start(options) do
            result['connected'] = true

            ::NATS.request('vcap.component.discover') do |item|
              @last_discovery_time = Time.now.to_f
              item_json = Yajl::Parser.parse(item)
              result['items'][item_uri(item_json)] = item_json.keep_if { |key, _value| NATS_COMMON_KEYS.include?(key) }
            rescue => error
              @logger.error("Error during NATS.request callback: #{error.inspect}")
              @logger.error(error.backtrace.join("\n"))
            end
          rescue => error
            @logger.error("Error during NATS.start callback: #{error.inspect}")
            @logger.error(error.backtrace.join("\n"))
          end
        rescue => error
          @logger.error("Error within NATS next_tick for start: #{error.inspect}")
          @logger.error(error.backtrace.join("\n"))
        end

        # Wait for discovery to be complete since the NATS.start does not block since EventMachine loop already running
        @semaphore.synchronize do
          @condition.wait(@semaphore, @config.nats_discovery_timeout) while !error_received && @running && ((@last_discovery_time.zero? && (Time.now.to_f - @start_time < @config.nats_discovery_interval)) || (Time.now.to_f - @last_discovery_time < @config.nats_discovery_timeout))
        end

        EventMachine.next_tick do
          ::NATS.stop
        rescue => error
          @logger.error("Error during NATS next_tick for stop: #{error.inspect}")
          @logger.error(error.backtrace.join("\n"))
        end
      rescue => error
        result['connected'] = false
        @logger.error("Error during NATS discovery: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
      end

      result
    end

    # The call to this method must be in a synchronized block
    def read_or_initialize_cache
      if File.exist?(@config.data_file)
        begin
          read = IO.read(@config.data_file)
          begin
            parsed = Yajl::Parser.parse(read)
            if parsed.is_a?(Hash)
              if parsed.key?('connected')
                if parsed.key?('items')
                  return parsed if parsed.key?('notified')

                  @logger.error("Error during NATS parse data: 'notified' key not present")
                else
                  @logger.error("Error during NATS parse data: 'items' key not present")
                end
              else
                @logger.error("Error during NATS parse data: 'connected' key not present")
              end
            else
              @logger.error('Error during NATS parse data: parsed data not a hash')
            end
          rescue => error
            @logger.error("Error during NATS parse data: #{error.inspect}")
            @logger.error(error.backtrace.join("\n"))
          end
        rescue => error
          @logger.error("Error during NATS read data: #{error.inspect}")
          @logger.error(error.backtrace.join("\n"))
        end
      end
      disconnected_result
    end

    # The call to this method must be in a synchronized block
    def write_cache
      File.open(@config.data_file, 'w') do |file|
        file.write(Yajl::Encoder.encode(@cache, pretty: true))
      end
    rescue => error
      @logger.error("Error during NATS write data: #{error.inspect}")
      @logger.error(error.backtrace.join("\n"))
    end

    def save_data(nats_discovery_results, disconnected)
      @logger.debug('Saving NATS data...')

      begin
        @cache = read_or_initialize_cache

        # Special-casing code to handle same component restarting with different ephemeral port.
        # Remove all old references which also have new references prior to merge.
        new_item_keys = {}
        nats_discovery_results['items'].each_pair do |uri, item|
          new_item_keys[item_key(uri, item)] = nil
        end

        @cache['items'].each_pair do |uri, item|
          if new_item_keys.include?(item_key(uri, item))
            @cache['items'].delete(uri)
            @cache['notified'].delete(uri)
          end
        end

        @cache['connected'] = nats_discovery_results['connected']
        @cache['items'].merge!(nats_discovery_results['items'])

        update_connection_status('NATS',
                                 @config.mbus.partition('@').last[0..],
                                 @cache['connected'],
                                 disconnected)

        @cache['items'].each_pair do |uri, item|
          update_connection_status(item['type'],
                                   uri,
                                   nats_discovery_results['items'][uri],
                                   disconnected)
        end

        write_cache
      rescue => error
        @logger.error("Error during NATS save data: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
      end
    end

    def send_email(disconnected)
      return unless @email.configured? && !disconnected.empty?

      thread = Thread.new do
        @email.send_email(disconnected)
      rescue => error
        @logger.error("Error during send email: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
      end

      thread.priority = -2
    end

    def update_connection_status(type, uri, connected, disconnected_list)
      return unless monitored?(type)

      if connected
        @cache['notified'].delete(uri)
      else
        component_entry = component_entry(type, uri)
        if component_entry['count'] < @config.component_connection_retries
          @logger.warn("The #{type} component #{uri} is not responding, its status will be checked again next refresh")
        elsif component_entry['count'] == @config.component_connection_retries
          @logger.warn("The #{type} component #{uri} has been recognized as disconnected")
          disconnected_list.push(component_entry)
        else
          @logger.warn("The #{type} component #{uri} is still not responding")
        end
      end
    end

    def monitored?(component)
      @config.monitored_components.each do |type|
        return true if component =~ /#{type}/ || type.casecmp('ALL').zero?
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
      "http://#{item['host']}/varz"
    end

    # Determine key for comparison. Type and index are insufficient. Host must be included (without port) as well.
    def item_key(uri_string, item)
      uri = URI.parse(uri_string)
      "#{item['type']}:#{item['index']}:#{uri.host}"
    end
  end
end
