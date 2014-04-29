require 'json'

module AdminUI
  class CC
    def initialize(config, logger, client)
      @config = config
      @client = client
      @logger = logger

      @caches = {}
      # These keys need to conform to their respective discover_x methods.
      # For instance applications conforms to discover_applications
      [:applications, :organizations, :quota_definitions, :routes, :services, :service_bindings, :service_brokers, :service_instances, :service_plans, :spaces, :users_cc_deep, :users_uaa].each do |key|
        hash = { :semaphore => Mutex.new, :condition => ConditionVariable.new, :result => nil }
        @caches[key] = hash

        Thread.new do
          loop do
            schedule_discovery(key, hash)
          end
        end
      end
    end

    def applications
      result_cache(:applications)
    end

    def applications_count
      applications['items'].length
    end

    def applications_running_instances
      instances = 0
      applications['items'].each do |app|
        instances += app['instances'] if app['state'] == 'STARTED'
      end
      instances
    end

    def applications_total_instances
      instances = 0
      applications['items'].each do |app|
        instances += app['instances']
      end
      instances
    end

    def organizations
      result_cache(:organizations)
    end

    def organizations_count
      organizations['items'].length
    end

    def invalidate_applications
      hash = @caches[:applications]
      hash[:semaphore].synchronize do
        hash[:result] = nil
        hash[:condition].broadcast
      end
    end

    def invalidate_organizations
      invalidate_cache(:organizations)
    end

    def invalidate_service_plans
      invalidate_cache(:service_plans)
    end

    def invalidate_routes
      invalidate_cache(:routes)
    end

    def quota_definitions
      result_cache(:quota_definitions)
    end

    def routes
      result_cache(:routes)
    end

    def services
      result_cache(:services)
    end

    def service_bindings
      result_cache(:service_bindings)
    end

    def service_brokers
      result_cache(:service_brokers)
    end

    def service_instances
      result_cache(:service_instances)
    end

    def service_plans
      result_cache(:service_plans)
    end

    def spaces
      result_cache(:spaces)
    end

    def spaces_auditors
      users_cc_deep = result_cache(:users_cc_deep)
      if users_cc_deep['connected']
        discover_spaces_auditors(users_cc_deep)
      else
        result
      end
    end

    def spaces_count
      spaces['items'].length
    end

    def spaces_developers
      users_cc_deep = result_cache(:users_cc_deep)
      if users_cc_deep['connected']
        discover_spaces_developers(users_cc_deep)
      else
        result
      end
    end

    def spaces_managers
      users_cc_deep = result_cache(:users_cc_deep)
      if users_cc_deep['connected']
        discover_spaces_managers(users_cc_deep)
      else
        result
      end
    end

    def users
      result_cache(:users_uaa)
    end

    def users_count
      users['items'].length
    end

    private

    def invalidate_cache(key, *rediscover)
      key_string = key.to_s

      hash = @caches[key]
      hash[:semaphore].synchronize do
        if rediscover
          result_cache = send("discover_#{ key_string }".to_sym)
          @logger.debug("Caching CC #{ key_string } data...")
          hash[:result] = result_cache
        else
          hash[:result] = nil
        end
        hash[:condition].broadcast
      end
    end

    def schedule_discovery(key, hash)
      key_string = key.to_s

      @logger.debug("[#{ @config.cloud_controller_discovery_interval } second interval] Starting CC #{ key_string } discovery...")

      result_cache = send("discover_#{ key_string }".to_sym)

      hash[:semaphore].synchronize do
        @logger.debug("Caching CC #{ key_string } data...")
        hash[:result] = result_cache
        hash[:condition].broadcast
        hash[:condition].wait(hash[:semaphore], @config.cloud_controller_discovery_interval)
      end
    end

    def result_cache(key)
      hash = @caches[key]
      hash[:semaphore].synchronize do
        hash[:condition].wait(hash[:semaphore]) while hash[:result].nil?
        hash[:result]
      end
    end

    def result(items = nil)
      if items.nil?
        {
          'connected' => false,
          'items'     => []
        }
      else
        {
          'connected' => true,
          'items'     => items
        }
      end
    end

    def discover_applications
      items = []
      @client.get_cc('v2/apps').each do |app|
        items.push(app['entity'].merge(app['metadata']))
      end
      result(items)
    rescue => error
      @logger.debug("Error during discover_applications: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_organizations
      items = []
      @client.get_cc('v2/organizations').each do |app|
        items.push(app['entity'].merge(app['metadata']))
      end
      result(items)
    rescue => error
      @logger.debug("Error during discover_organizations: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_quota_definitions
      items = []
      @client.get_cc('v2/quota_definitions').each do |quota|
        items.push(quota['entity'].merge(quota['metadata']))
      end
      result(items)
    rescue => error
      @logger.debug("Error during discover_quota_definitions: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_routes
      items = []
      @client.get_cc('v2/routes?inline-relations-depth=1').each do |route|
        items.push(route['entity'].merge(route['metadata']))
      end
      result(items)
    rescue => error
      @logger.debug("Error during discover_routes: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_services
      items = []
      @client.get_cc('v2/services').each do |app|
        items.push(app['entity'].merge(app['metadata']))
      end
      result(items)
    rescue => error
      @logger.debug("Error during discover_services: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_service_bindings
      items = []
      @client.get_cc('v2/service_bindings').each do |app|
        items.push(app['entity'].merge(app['metadata']))
      end
      result(items)
    rescue => error
      @logger.debug("Error during discover_service_bindings: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_service_brokers
      items = []
      @client.get_cc('v2/service_brokers').each do |app|
        items.push(app['entity'].merge(app['metadata']))
      end
      result(items)
    rescue => error
      @logger.debug("Error during discover_service_brokers: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_service_instances
      items = []
      @client.get_cc('v2/service_instances').each do |app|
        items.push(app['entity'].merge(app['metadata']))
      end
      result(items)
    rescue => error
      @logger.debug("Error during discover_service_instances: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_service_plans
      items = []
      @client.get_cc('v2/service_plans').each do |app|
        items.push(app['entity'].merge(app['metadata']))
      end
      result(items)
    rescue => error
      @logger.debug("Error during discover_service_plans: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_spaces
      items = []
      @client.get_cc('v2/spaces').each do |app|
        items.push(app['entity'].merge(app['metadata']))
      end
      result(items)
    rescue => error
      @logger.debug("Error during discover_spaces: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_spaces_auditors(users_deep)
      items = []
      users_deep['items'].each do |user_deep|
        guid = user_deep['metadata']['guid']

        audited_spaces = user_deep['entity']['audited_spaces']
        unless audited_spaces.nil?
          audited_spaces.each do |space|
            items.push('user_guid'  => guid,
                       'space_guid' => space['metadata']['guid'])
          end
        end
      end
      result(items)
    rescue => error
      @logger.debug("Error during discover_spaces_auditors: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_spaces_developers(users_deep)
      items = []
      users_deep['items'].each do |user_deep|
        guid = user_deep['metadata']['guid']

        spaces = user_deep['entity']['spaces']
        unless spaces.nil?
          spaces.each do |space|
            items.push('user_guid'  => guid,
                       'space_guid' => space['metadata']['guid'])
          end
        end
      end
      result(items)
    rescue => error
      @logger.debug("Error during discover_spaces_developers: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_spaces_managers(users_deep)
      items = []
      users_deep['items'].each do |user_deep|
        guid = user_deep['metadata']['guid']

        managed_spaces = user_deep['entity']['managed_spaces']
        unless managed_spaces.nil?
          managed_spaces.each do |space|
            items.push('user_guid'  => guid,
                       'space_guid' => space['metadata']['guid'])
          end
        end
      end
      result(items)
    rescue => error
      @logger.debug("Error during discover_spaces_managers: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_users_cc_deep
      result(@client.get_cc('v2/users?inline-relations-depth=1'))
    rescue => error
      @logger.debug("Error during discover_users_cc_deep: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_users_uaa
      items = []
      @client.get_uaa('Users').each do |user|
        emails = user['emails']
        groups = user['groups']
        meta   = user['meta']
        name   = user['name']

        authorities = []
        groups.each do |group|
          authorities.push(group['display'])
        end

        attributes = { 'active'        => user['active'],
                       'authorities'   => authorities.sort.join(', '),
                       'created'       => meta['created'],
                       'id'            => user['id'],
                       'last_modified' => meta['lastModified'],
                       'version'       => meta['version'] }

        attributes['updated']    = meta['updated']    unless meta['updated'].nil?
        attributes['email']      = emails[0]['value'] unless emails.nil? || emails.length == 0
        attributes['familyname'] = name['familyName'] unless name['familyName'].nil?
        attributes['givenname']  = name['givenName'] unless name['givenName'].nil?
        attributes['username']   = user['userName'] unless user['userName'].nil?

        items.push(attributes)
      end
      result(items)
    rescue => error
      @logger.debug("Error during discover_users_uaa: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end
  end
end
