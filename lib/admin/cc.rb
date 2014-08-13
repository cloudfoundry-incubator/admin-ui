require 'date'
require 'thread'
require_relative 'scheduled_thread_pool'

module AdminUI
  class CC
    def initialize(config, logger, client, testing = false)
      @config  = config
      @client  = client
      @logger  = logger
      @testing = testing

      # TODO: Need config for number of threads
      @pool   = AdminUI::ScheduledThreadPool.new(logger, 6, -2)

      @caches = {}

      # These keys need to conform to their respective discover_x methods.
      # For instance applications conforms to discover_applications
      [:applications, :organizations, :quota_definitions, :routes, :services, :service_bindings, :service_brokers, :service_instances, :service_plans, :spaces, :users_cc_deep, :users_uaa].each do |key|
        @caches[key] = { :semaphore => Mutex.new, :condition => ConditionVariable.new, :result => nil }
        schedule(key)
      end
    end

    def applications
      result_cache(:applications)
    end

    def applications_count
      hash = applications
      return nil unless hash['connected']
      hash['items'].length
    end

    def applications_running_instances
      hash = applications
      return nil unless hash['connected']
      instances = 0
      hash['items'].each do |app|
        Thread.pass
        instances += app['instances'] if app['state'] == 'STARTED'
      end
      instances
    end

    def applications_total_instances
      hash = applications
      return nil unless hash['connected']
      instances = 0
      hash['items'].each do |app|
        Thread.pass
        instances += app['instances']
      end
      instances
    end

    def invalidate_applications
      invalidate_cache(:applications)
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

    def organizations
      result_cache(:organizations)
    end

    def organizations_count
      hash = organizations
      return nil unless hash['connected']
      hash['items'].length
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
      hash = spaces
      return nil unless hash['connected']
      hash['items'].length
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
      hash = users
      return nil unless hash['connected']
      hash['items'].length
    end

    private

    def invalidate_cache(key)
      hash = @caches[key]
      hash[:semaphore].synchronize do
        hash[:result] = nil
      end
      schedule(key)
    end

    def schedule(key, time = Time.now)
      @pool.schedule(key, time) do
        discover(key)
      end
    end

    def discover(key)
      key_string = key.to_s

      @logger.debug("[#{ @config.cloud_controller_discovery_interval } second interval] Starting CC #{ key_string } discovery...")

      start = Time.now

      result_cache = send("discover_#{ key_string }".to_sym)

      finish = Time.now

      hash = @caches[key]
      hash[:semaphore].synchronize do
        @logger.debug("Caching CC #{ key_string } data.  Retrieval time: #{ finish - start } seconds")
        hash[:result] = result_cache
        hash[:condition].broadcast
      end

      # Set up the next scheduled discovery for this key
      schedule(key, Time.now + @config.cloud_controller_discovery_interval)
    end

    def result_cache(key)
      hash = @caches[key]
      hash[:semaphore].synchronize do
        if @testing
          hash[:condition].wait(hash[:semaphore]) while hash[:result].nil?
        else
          return result if hash[:result].nil?
        end
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
      @client.get_cc('v2/apps?results-per-page=100').each do |app|
        Thread.pass
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
      @client.get_cc('v2/organizations?results-per-page=100').each do |app|
        Thread.pass
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
      @client.get_cc('v2/quota_definitions?results-per-page=100').each do |quota|
        Thread.pass
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
      @client.get_cc('v2/routes?inline-relations-depth=1&results-per-page=100').each do |route|
        Thread.pass
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
      @client.get_cc('v2/services?results-per-page=100').each do |app|
        Thread.pass
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
      @client.get_cc('v2/service_bindings?results-per-page=100').each do |app|
        Thread.pass
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
      @client.get_cc('v2/service_brokers?results-per-page=100').each do |app|
        Thread.pass
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
      @client.get_cc('v2/service_instances?results-per-page=100').each do |app|
        Thread.pass
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
      @client.get_cc('v2/service_plans?results-per-page=100').each do |app|
        Thread.pass
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
      @client.get_cc('v2/spaces?results-per-page=100').each do |app|
        Thread.pass
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
        Thread.pass
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
        Thread.pass
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
        Thread.pass
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
      result(@client.get_cc('v2/users?inline-relations-depth=1&results-per-page=100'))
    rescue => error
      @logger.debug("Error during discover_users_cc_deep: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_users_uaa
      items = []
      @client.get_uaa('Users').each do |user|
        Thread.pass
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
