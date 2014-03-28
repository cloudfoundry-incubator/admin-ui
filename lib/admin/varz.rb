require 'json'
require 'net/http'

module AdminUI
  class VARZ
    def initialize(config, logger, nats)
      @config = config
      @logger = logger
      @nats   = nats

      @semaphore = Mutex.new
      @condition = ConditionVariable.new

      @cache = nil

      Thread.new do
        loop do
          schedule_discovery
        end
      end
    end

    def components
      filter(//)
    end

    def cloud_controllers
      filter(/CloudController/)
    end

    def deas
      filter(/DEA/)
    end

    def deas_count
      filter(/DEA/)['items'].length
    end

    def health_managers
      filter(/HealthManager/)
    end

    def gateways
      filter(/-Provisioner/)
    end

    def routers
      filter(/Router/)
    end

    def invalid
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
            @cache['items'].each do |uri, item|
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
        @condition.broadcast
      end
    end

    private

    def filter(typePattern)
      cache = {}
      @semaphore.synchronize do
        @condition.wait(@semaphore) while @cache.nil?
        cache = @cache.clone
      end

      result_item_array = []
      result = { 'connected' => cache['connected'], 'items' => result_item_array }

      cache['items'].each do |_, item|
        data = item['data']
        unless data.nil?
          type_pattern_index = data['type'] =~ typePattern
          unless type_pattern_index.nil?
            result_item = item.clone
            item_name = type_pattern_index == 0 ? data['host'] : data['type'].sub(typePattern, '')
            result_item['name'] = item_name unless item_name.nil?
            result_item_array.push(result_item)
          end
        end
      end

      result
    end

    def schedule_discovery
      item_hash = {}
      cache = { 'connected' => false, 'items' => item_hash }

      begin
        @logger.debug("[#{ @config.varz_discovery_interval } second interval] Starting VARZ discovery...")

        nats_result = @nats.get

        cache['connected'] = nats_result['connected']

        nats_result['items'].each do |uri, item|
          item_hash[uri] = item_result(uri, item)
        end
      rescue => error
        @logger.debug("Error during VARZ discovery: #{ error.inspect }")
        @logger.debug(error.backtrace.join("\n"))
      end

      @logger.debug('Caching VARZ data...')

      @semaphore.synchronize do
        @cache = cache
        @condition.broadcast
        @condition.wait(@semaphore, @config.varz_discovery_interval)
      end
    end

    def item_result(uri, item)
      result = { 'uri' => uri, 'name' => item['host'] }

      begin
        response = Utils.http_request(@config, uri, 'GET', (item.nil? ? nil : item['credentials']))

        if response.is_a?(Net::HTTPOK)
          result.merge!('connected' => true,
                        'data'      => JSON.parse(response.body))
        else
          result.merge!('connected' => false,
                        'data'      => (item.nil? ? {} : item),
                        'error'     => "#{ response.code }<br/><br/>#{ response.body }")
          @logger.debug("item_result(#{ uri }) : error [#{ response.code } - #{ response.body }]")
        end
      rescue => error
        result.merge!('connected' => false,
                      'data'      => (item.nil? ? {} : item),
                      'error'     => "#{ error.inspect }")
        @logger.debug("item_result(#{ uri }) : error [#{ error.inspect }]")
      end

      result
    end
  end
end
