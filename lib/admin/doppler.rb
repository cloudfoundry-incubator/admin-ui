require 'eventmachine'
require 'yajl'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'dropsonde_protocol')
require 'envelope.pb.rb'

module AdminUI
  class Doppler
    BILLION              = 1000.0 * 1000.0 * 1000.0
    DOPPLER_PERSIST_KEYS = %w[connected index ip origin timestamp].freeze

    def initialize(config, logger, client, email, testing)
      @config  = config
      @logger  = logger
      @client  = client
      @email   = email
      @testing = testing

      @running = true
      FileUtils.mkpath File.dirname(@config.doppler_data_file)

      @subscription_id = Time.now.to_i

      @components           = {}
      @components_condition = ConditionVariable.new
      @components_semaphore = Mutex.new

      @containers           = {}
      @containers_condition = ConditionVariable.new
      @containers_semaphore = Mutex.new

      @container_metrics           = {}
      @container_metrics_semaphore = Mutex.new

      @value_metrics           = {}
      @value_metrics_semaphore = Mutex.new

      # We can reuse the envelope if we clear it and retrieve fields from it
      @envelope = Events::Envelope.new

      # This will use the main EventMachine loop
      @thread = Thread.new do
        discover
      end
    end

    def components
      @components_semaphore.synchronize do
        @components_condition.wait(@components_semaphore) while @testing && @running && @components['items'].nil?
        return { 'connected' => false, 'items' => {} } if @components['items'].nil?

        { 'connected' => @components['connected'], 'items' => @components['items'].clone }
      end
    end

    def containers
      @containers_semaphore.synchronize do
        @containers_condition.wait(@containers_semaphore) while @testing && @running && @containers['items'].nil?
        return { 'connected' => false, 'items' => {} } if @containers['items'].nil?

        { 'connected' => @containers['connected'], 'items' => @containers['items'].clone }
      end
    end

    def analyzers
      filter_components('analyzer')
    end

    def deas
      filter_components('DEA')
    end

    def deas_count
      hash = filter_components('DEA')
      return nil unless hash['connected']

      hash['items'].length
    end

    def gorouters
      filter_components('gorouter')
    end

    def reps
      filter_components('rep')
    end

    def reps_count
      hash = filter_components('rep')
      return nil unless hash['connected']

      hash['items'].length
    end

    def remove_component(key_parameter)
      @components_semaphore.synchronize do
        local_components = @components['items'].nil? ? read_or_initialize_components : @components
        keys = []
        if key_parameter.nil?
          local_components['items'].each_pair do |key, value|
            keys.push(key) unless value['connected']
          end
        else
          keys.push(key_parameter)
        end

        removed = false
        keys.each do |key|
          removed = true unless local_components['items'].delete(key).nil?
          removed = true unless local_components['notified'].delete(key).nil?
        end

        write_components(local_components) if removed
      ensure
        @components_condition.broadcast
      end
    end

    # In order to test deletion of an application instance, need mechanism to force immediate removal
    def testing_remove_container_metric(application_guid, instance_index)
      return unless @testing

      key = "#{application_guid}:#{instance_index}"
      @container_metrics_semaphore.synchronize do
        @container_metrics.delete(key)
      end

      handle_rollup
    end

    def shutdown
      return unless @running

      @running = false

      eventmachine_close

      @components_semaphore.synchronize do
        @components_condition.broadcast
      end

      @containers_semaphore.synchronize do
        @containers_condition.broadcast
      end
    end

    def join
      @thread.join
    end

    private

    def filter_components(origin)
      all_components = components

      {
        'connected' => all_components['connected'],
        'items'     => all_components['items'].select { |_key, value| value['origin'] == origin }
      }
    end

    def discover
      @rollup_interval_timer = EventMachine.add_periodic_timer(@config.doppler_rollup_interval) do
        handle_rollup
      end

      EventMachine.next_tick do
        eventmachine_setup(false)
      end
    end

    def eventmachine_setup(force_login)
      return unless @running

      first_message = true

      @logger.debug('Doppler attempting websocket connection to firehose')
      @doppler_uri, @doppler_websocket = @client.get_firehose(@subscription_id, force_login)

      if @doppler_websocket.nil?
        @logger.error('Doppler failure attempting websocket connection to firehose')
        doppler_future_connect(false, false)
      else
        @doppler_websocket.on :open do |event|
          doppler_open(event)
        end

        @doppler_websocket.on :message do |event|
          if first_message
            first_message = false
            @logger.debug('Doppler first message received')
          end

          doppler_message(event)
        end

        @doppler_websocket.on :error do |event|
          doppler_error(event)
        end

        @doppler_websocket.on :close do |event|
          doppler_close(event, force_login, !first_message)
        end
      end
    rescue => error
      @logger.error("Error during doppler eventmachine_setup callback: #{error.inspect}")
      @logger.error(error.backtrace.join("\n"))
    end

    def eventmachine_close
      cancel_connect_timer
      cancel_rollup_interval_timer

      @doppler_websocket&.close
    end

    def cancel_connect_timer
      return unless @connect_timer

      EventMachine.cancel_timer(@connect_timer)
      @connect_timer = nil
    end

    def cancel_rollup_interval_timer
      return unless @rollup_interval_timer

      EventMachine.cancel_timer(@rollup_interval_timer)
      @rollup_interval_timer = nil
    end

    def doppler_future_connect(immediate, force_login)
      cancel_connect_timer

      return unless @running

      if immediate
        @logger.debug("Doppler will attempt reconnect on next tick with forced login=#{force_login}")
        EventMachine.next_tick do
          eventmachine_setup(force_login)
        end
      else
        @logger.debug("Doppler will attempt reconnect in #{@config.doppler_reconnect_delay} seconds with forced login=#{force_login}")
        @connect_timer = EventMachine.add_timer(@config.doppler_reconnect_delay) do
          eventmachine_setup(force_login)
        end
      end
    end

    def doppler_open(event)
      @logger.debug("Doppler open: #{event.inspect}")
    rescue => error
      @logger.error("Error during doppler open callback: #{error.inspect}")
      @logger.error(error.backtrace.join("\n"))
    end

    def doppler_error(event)
      @logger.error("Doppler error: #{event.inspect}")
    rescue => error
      @logger.error("Error during doppler error callback: #{error.inspect}")
      @logger.error(error.backtrace.join("\n"))
    end

    def doppler_message(event)
      return unless @running

      buffer = ''
      event.data.each do |character|
        buffer += character.chr
      end

      @envelope.clear!

      parsed_envelope = @envelope.parse_from_string(buffer)
      event_type = parsed_envelope.eventType

      if event_type == Events::Envelope::EventType::ContainerMetric
        doppler_message_container_metric(parsed_envelope)
      elsif event_type == Events::Envelope::EventType::ValueMetric
        doppler_message_value_metric(parsed_envelope)
      end
    rescue => error
      @logger.error("Error during doppler message callback: #{error.inspect}")
      @logger.error(error.backtrace.join("\n"))
    end

    def doppler_message_container_metric(parsed_envelope)
      container_metric = parsed_envelope.containerMetric
      key = "#{container_metric.applicationId}:#{container_metric.instanceIndex}"
      value =
        {
          application_id:     container_metric.applicationId,
          cpu_percentage:     container_metric.cpuPercentage,
          disk_bytes:         container_metric.diskBytes,
          disk_bytes_quota:   container_metric.diskBytesQuota,
          index:              parsed_envelope.index,
          instance_index:     container_metric.instanceIndex,
          ip:                 parsed_envelope.ip,
          memory_bytes:       container_metric.memoryBytes,
          memory_bytes_quota: container_metric.memoryBytesQuota,
          origin:             parsed_envelope.origin,
          timestamp:          parsed_envelope.timestamp
        }

      @container_metrics_semaphore.synchronize do
        @container_metrics[key] = value
      end
    end

    def doppler_message_value_metric(parsed_envelope)
      value_metric = parsed_envelope.valueMetric
      key = "#{parsed_envelope.origin}:#{parsed_envelope.index}:#{parsed_envelope.ip}"

      @value_metrics_semaphore.synchronize do
        hash = @value_metrics[key]
        if hash.nil?
          hash =
            {
              'connected' => true,
              'index'     => parsed_envelope.index,
              'ip'        => parsed_envelope.ip,
              'origin'    => parsed_envelope.origin,
              'timestamp' => parsed_envelope.timestamp
            }
          @value_metrics[key] = hash
        else
          hash['timestamp'] = parsed_envelope.timestamp
        end

        hash[value_metric.name] = value_metric.value
      end
    end

    def doppler_close(event, force_login, messages_received)
      @logger.debug("Doppler close status: #{@doppler_websocket.status}") unless @doppler_websocket.nil?
      @logger.debug("Doppler close event: #{event.inspect}")

      if @running
        force_login = !force_login && (@doppler_websocket.status == 401)
        immediate = force_login || messages_received || (event.code == 1008)
        force_login ||= !immediate
        doppler_future_connect(immediate, force_login)
      end
      @doppler_websocket = nil
    rescue => error
      @logger.error("Error during doppler close callback: #{error.inspect}")
      @logger.error(error.backtrace.join("\n"))
    end

    def handle_rollup
      return unless @running

      @logger.debug("[#{@config.doppler_rollup_interval} second interval] Caching doppler component and container data...")

      old_time = Time.now - (@config.doppler_rollup_interval * 4)
      old_ns = old_time.to_i * BILLION

      handle_components_rollup(old_ns)
      handle_container_metrics_rollup(old_ns)
    rescue => error
      @logger.error("Error during doppler handle_rollup: #{error.inspect}")
      @logger.error(error.backtrace.join("\n"))
    end

    def handle_components_rollup(old_ns)
      local_value_metrics = nil
      @value_metrics_semaphore.synchronize do
        @value_metrics.delete_if { |_key, metrics| metrics['timestamp'] < old_ns } unless @testing
        local_value_metrics = @value_metrics.clone
      end

      disconnected = []
      save_data(local_value_metrics, disconnected)

      send_email(disconnected)
    rescue => error
      @logger.error("Error during doppler handle_components_rollup: #{error.inspect}")
      @logger.error(error.backtrace.join("\n"))
    end

    def handle_container_metrics_rollup(old_ns)
      local_container_metrics = nil
      @container_metrics_semaphore.synchronize do
        @container_metrics.delete_if { |_key, metrics| metrics[:timestamp] < old_ns } unless @testing
        local_container_metrics = @container_metrics.clone
      end

      @containers_semaphore.synchronize do
        @containers = { 'connected' => !local_container_metrics.empty?, 'items' => local_container_metrics }
        @containers_condition.broadcast
      end
    rescue => error
      @logger.error("Error during doppler handle_container_metrics_rollup: #{error.inspect}")
      @logger.error(error.backtrace.join("\n"))
    end

    def save_data(local_value_metrics, disconnected)
      @logger.debug('Saving doppler component data...')

      # Sort the local value metrics. Nice for the UI when displaying JSON block.
      sorted_local_value_metrics = {}
      local_value_metrics.each_pair do |key, value|
        sorted_local_value_metrics[key] = value.sort_by { |k, _v| k.downcase }.to_h
      end

      @components_semaphore.synchronize do
        @components = read_or_initialize_components

        # Remove all old references which also have new references prior to merge.
        @components['items'].each_key do |key|
          if sorted_local_value_metrics.key?(key)
            @components['items'].delete(key)
            @components['notified'].delete(key)
          else
            @components['items'][key]['connected'] = false
          end
        end

        @components['connected'] = !sorted_local_value_metrics.empty?
        @components['items'].merge!(sorted_local_value_metrics)

        update_connection_status('doppler_logging_endpoint',
                                 'doppler_logging_endpoint',
                                 @doppler_uri || 'unknown',
                                 @components['connected'],
                                 disconnected)

        @components['items'].each_pair do |key, item|
          update_connection_status(key,
                                   item['origin'],
                                   item['ip'],
                                   item['connected'],
                                   disconnected)
        end

        write_components(@components)
      ensure
        @components_condition.broadcast
      end
    rescue => error
      @logger.error("Error during doppler save data: #{error.inspect}")
      @logger.error(error.backtrace.join("\n"))
    end

    def send_email(disconnected)
      return unless @email.configured? && !disconnected.empty?

      thread = Thread.new do
        @email.send_email(disconnected)
      rescue => error
        @logger.error("Error during doppler send_email: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
      end

      thread.priority = -2
    end

    # The call to this method must be in a synchronized block
    def read_or_initialize_components
      if File.exist?(@config.doppler_data_file)
        begin
          read = IO.read(@config.doppler_data_file)
          begin
            parsed = Yajl::Parser.parse(read)
            if parsed.is_a?(Hash)
              if parsed.key?('connected')
                if parsed.key?('items')
                  return parsed if parsed.key?('notified')

                  @logger.error("Error during doppler parse data: 'notified' key not present")
                else
                  @logger.error("Error during doppler parse data: 'items' key not present")
                end
              else
                @logger.error("Error during doppler parse data: 'connected' key not present")
              end
            else
              @logger.error('Error during doppler parse data: parsed data not a hash')
            end
          rescue => error
            @logger.error("Error during doppler parse data: #{error.inspect}")
            @logger.error(error.backtrace.join("\n"))
          end
        rescue => error
          @logger.error("Error during doppler read data: #{error.inspect}")
          @logger.error(error.backtrace.join("\n"))
        end
      end

      {
        'connected' => false,
        'items'     => {},
        'notified'  => {}
      }
    end

    # The call to this method must be in a synchronized block
    def write_components(param_components)
      # Prune the keys being persisted for the components. No need to persist all of their metrics
      items = {}
      param_components['items'].each_pair do |key, value|
        items[key] = value.select { |value_key, _| DOPPLER_PERSIST_KEYS.include?(value_key) }
      end

      local_components =
        {
          'connected' => param_components['connected'],
          'items'     => items,
          'notified'  => param_components['notified']
        }

      File.open(@config.doppler_data_file, 'w') do |file|
        file.write(Yajl::Encoder.encode(local_components, pretty: true))
      end
    rescue => error
      @logger.error("Error during doppler write_components: #{error.inspect}")
      @logger.error(error.backtrace.join("\n"))
    end

    # The call to this method must be in a synchronized block
    def update_connection_status(key, origin, uri, connected, disconnected_list)
      return unless monitored?(origin)

      if connected
        @components['notified'].delete(key)
      else
        component_entry = component_entry(key, origin, uri)
        if component_entry['count'] < @config.component_connection_retries
          @logger.warn("The #{origin} component #{key} is not responding, its status will be checked again next refresh")
        elsif component_entry['count'] == @config.component_connection_retries
          @logger.warn("The #{origin} component #{key} has been recognized as disconnected")
          disconnected_list.push(component_entry)
        else
          @logger.warn("The #{origin} component #{key} is still not responding")
        end
      end
    end

    def monitored?(component)
      @config.monitored_components.each do |type|
        return true if component =~ /#{type}/ || type.casecmp('ALL').zero?
      end
      false
    end

    # The call to this method must be in a synchronized block
    def component_entry(key, origin, uri)
      result = @components['notified'][key]
      result = { 'count' => 0, 'type' => origin, 'uri' => uri } if result.nil?
      result['count'] += 1
      @components['notified'][key] = result

      result
    end
  end
end
