require 'net/http'
require 'yajl'

module AdminUI
  class VARZ
    def initialize(config, logger, nats, testing)
      @config  = config
      @logger  = logger
      @nats    = nats
      @testing = testing

      @running = true

      @semaphore = Mutex.new
      @condition = ConditionVariable.new

      @cache = nil

      @thread = Thread.new do
        schedule_discovery while @running
      end

      @thread.priority = -2
    end

    def components
      filter(//)
    end

    def cloud_controllers
      filter(/CloudController/)
    end

    def gateways
      filter(/-Provisioner/)
    end

    def routers
      filter(/Router/)
    end

    def invalidate
      @semaphore.synchronize do
        @cache = nil
        @condition.broadcast
      end
    end

    def remove(uri_parameter)
      @semaphore.synchronize do
        unless @cache.nil?
          uris = []
          if uri_parameter.nil?
            @cache['items'].each_pair do |uri, item|
              uris.push(uri) unless item['connected']
            end
          else
            uris.push(uri_parameter)
          end

          @nats.remove(uris)

          uris.each do |uri|
            @cache['items'].delete(uri)
          end
        end
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

    def filter(type_pattern)
      cache = {}
      @semaphore.synchronize do
        @condition.wait(@semaphore) while @testing && @running && @cache.nil?
        return { 'connected' => false, 'items' => [] } if @cache.nil?

        cache = @cache.clone
      end

      result_item_array = []
      result = { 'connected' => cache['connected'], 'items' => result_item_array }

      cache['items'].each_value do |item|
        type_pattern_index = item['type'] =~ type_pattern
        next if type_pattern_index.nil?

        result_item = item.clone
        item_name = type_pattern_index.zero? ? item['host'] : item['type'].sub(type_pattern, '')
        result_item['name'] = item_name unless item_name.nil?
        result_item_array.push(result_item)
      end

      result
    end

    def schedule_discovery
      item_hash = {}
      cache = { 'connected' => false, 'items' => item_hash }

      begin
        @logger.debug("[#{@config.varz_discovery_interval} second interval] Starting VARZ discovery...")

        nats_result = @nats.get

        cache['connected'] = nats_result['connected']

        nats_result['items'].each_pair do |uri, item|
          break unless @running

          Thread.pass

          item_hash[uri] = item_result(uri, item)
        end
      rescue => error
        @logger.error("Error during VARZ discovery: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
      end

      @logger.debug('Caching VARZ data...')

      @semaphore.synchronize do
        @cache = cache
        @condition.broadcast
        @condition.wait(@semaphore, @config.varz_discovery_interval) if @running
      end
    end

    def item_result(uri, item)
      result = { 'uri' => uri, 'name' => item['host'], 'type' => item['type'], 'index' => item['index'] }

      begin
        response = Utils.http_request(@config, @logger, uri, 'GET', (item.nil? ? nil : item['credentials']))

        if response.is_a?(Net::HTTPOK)
          result['connected'] = true
          result['data']      = Yajl::Parser.parse(response.body)
        else
          result['connected'] = false
          result['data']      = item.nil? ? {} : item
          result['error']     = "#{response.code}<br/><br/>#{response.body}"

          @logger.warn("item_result(#{uri}): [#{response.code} - #{response.body}]")
        end
      rescue => error
        result['connected'] = false
        result['data']      = item.nil? ? {} : item
        result['error']     = error.inspect

        @logger.warn("item_result(#{uri}): [#{error.inspect}]")
      end

      result
    end
  end
end
