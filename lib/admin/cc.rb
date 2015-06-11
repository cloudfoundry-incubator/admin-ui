require 'date'
require 'sequel'
require 'thread'
require_relative 'scheduled_thread_pool'

module AdminUI
  class CC
    def initialize(config, logger, client, testing)
      @config  = config
      @client  = client
      @logger  = logger
      @testing = testing

      # TODO: Need config for number of connections/threads
      # SQLite for testing does not appear to work well with multiple connections
      @max_connections = testing ? 1 : 4

      @pool = AdminUI::ScheduledThreadPool.new(logger, @max_connections, -2)

      ccdb_uri  = @config.ccdb_uri
      uaadb_uri = @config.uaadb_uri

      # These keys need to conform to their respective methods.
      # For instance applications conforms to applications
      @caches =
      {
        applications:
        {
          db_uri:  ccdb_uri,
          table:   :apps,
          columns: [:buildpack, :command, :created_at, :detected_buildpack, :diego, :disk_quota, :docker_image, :droplet_hash, :enable_ssh, :guid, :health_check_timeout, :health_check_type, :id, :instances, :memory, :metadata, :name, :package_pending_since, :package_state, :package_updated_at, :production, :space_id, :stack_id, :staging_task_id, :state, :type, :updated_at, :version]
        },
        apps_routes:
        {
          db_uri:  ccdb_uri,
          table:   :apps_routes,
          columns: [:app_id, :route_id]
        },
        clients:
        {
          db_uri:  uaadb_uri,
          table:   :oauth_client_details,
          columns: [:additional_information, :authorities, :authorized_grant_types, :client_id, :scope, :web_server_redirect_uri]
        },
        domains:
        {
          db_uri:  ccdb_uri,
          table:   :domains,
          columns: [:created_at, :guid, :id, :name, :owning_organization_id, :updated_at]
        },
        droplets:
        {
          db_uri:  ccdb_uri,
          table:   :droplets,
          columns: [:app_id, :created_at, :detected_start_command, :droplet_hash, :guid, :id, :updated_at]
        },
        events:
        {
          db_uri:  ccdb_uri,
          table:   :events,
          columns: [:actee, :actee_name, :actee_type, :actor, :actor_name, :actor_type, :created_at, :guid, :id, :metadata, :organization_guid, :space_guid, :space_id, :timestamp, :type, :updated_at],
          where:   "\"timestamp\" >= CURRENT_TIMESTAMP - INTERVAL '#{@config.event_days} DAYS'"
        },
        groups:
        {
          db_uri:  uaadb_uri,
          table:   :groups,
          columns: [:created, :displayname, :id, :lastmodified, :version]
        },
        group_membership:
        {
          db_uri:  uaadb_uri,
          table:   :group_membership,
          columns: [:group_id, :member_id]
        },
        organizations:
        {
          db_uri:  ccdb_uri,
          table:   :organizations,
          columns: [:billing_enabled, :created_at, :guid, :id, :name, :quota_definition_id, :status, :updated_at]
        },
        organizations_auditors:
        {
          db_uri:  ccdb_uri,
          table:   :organizations_auditors,
          columns: [:organization_id, :user_id]
        },
        organizations_billing_managers:
        {
          db_uri:  ccdb_uri,
          table:   :organizations_billing_managers,
          columns: [:organization_id, :user_id]
        },
        organizations_managers:
        {
          db_uri:  ccdb_uri,
          table:   :organizations_managers,
          columns: [:organization_id, :user_id]
        },
        organizations_private_domains:
        {
          db_uri:  ccdb_uri,
          table:   :organizations_private_domains,
          columns: [:organization_id, :private_domain_id]
        },
        organizations_users:
        {
          db_uri:  ccdb_uri,
          table:   :organizations_users,
          columns: [:organization_id, :user_id]
        },
        quota_definitions:
        {
          db_uri:  ccdb_uri,
          table:   :quota_definitions,
          columns: [:created_at, :guid, :id, :instance_memory_limit, :memory_limit, :name, :non_basic_services_allowed, :total_routes, :total_services, :updated_at]
        },
        routes:
        {
          db_uri:  ccdb_uri,
          table:   :routes,
          columns: [:created_at, :domain_id, :guid, :host, :id, :path, :space_id, :updated_at]
        },
        service_bindings:
        {
          db_uri:  ccdb_uri,
          table:   :service_bindings,
          columns: [:app_id, :binding_options, :created_at, :gateway_data, :gateway_name, :guid, :id, :service_instance_id, :syslog_drain_url, :updated_at]
        },
        service_brokers:
        {
          db_uri:  ccdb_uri,
          table:   :service_brokers,
          columns: [:auth_username, :broker_url, :created_at, :guid, :id, :name, :updated_at]
        },
        service_dashboard_clients:
        {
          db_uri:  ccdb_uri,
          table:   :service_dashboard_clients,
          columns: [:service_broker_id, :uaa_id]
        },
        service_instances:
        {
          db_uri:  ccdb_uri,
          table:   :service_instances,
          columns: [:created_at, :dashboard_url, :gateway_name, :gateway_data, :guid, :id, :name, :service_plan_id, :space_id, :updated_at]
        },
        service_instance_operations:
        {
          db_uri:  ccdb_uri,
          table:   :service_instance_operations,
          columns: [:created_at, :description, :guid, :id, :proposed_changes, :service_instance_id, :state, :type, :updated_at]
        },
        service_keys:
        {
          db_uri:  ccdb_uri,
          table:   :service_keys,
          columns: [:created_at, :guid, :id, :name, :service_instance_id, :updated_at]
        },
        service_plans:
        {
          db_uri:  ccdb_uri,
          table:   :service_plans,
          columns: [:active, :created_at, :description, :extra, :free, :guid, :id, :name, :public, :service_id, :unique_id, :updated_at]
        },
        service_plan_visibilities:
        {
          db_uri:  ccdb_uri,
          table:   :service_plan_visibilities,
          columns: [:created_at, :guid, :id, :organization_id, :service_plan_id, :updated_at]
        },
        services:
        {
          db_uri:  ccdb_uri,
          table:   :services,
          columns: [:active, :bindable, :created_at, :description, :documentation_url, :extra, :guid, :id, :info_url, :label, :long_description, :plan_updateable, :provider, :requires, :service_broker_id, :tags, :unique_id, :updated_at, :url, :version]
        },
        space_quota_definitions:
        {
          db_uri:  ccdb_uri,
          table:   :space_quota_definitions,
          columns: [:created_at, :guid, :id, :instance_memory_limit, :memory_limit, :name, :non_basic_services_allowed, :organization_id, :total_routes, :total_services, :updated_at]
        },
        spaces:
        {
          db_uri:  ccdb_uri,
          table:   :spaces,
          columns: [:allow_ssh, :created_at, :guid, :id, :name, :organization_id, :space_quota_definition_id, :updated_at]
        },
        spaces_auditors:
        {
          db_uri:  ccdb_uri,
          table:   :spaces_auditors,
          columns: [:space_id, :user_id]
        },
        spaces_developers:
        {
          db_uri:  ccdb_uri,
          table:   :spaces_developers,
          columns: [:space_id, :user_id]
        },
        spaces_managers:
        {
          db_uri:  ccdb_uri,
          table:   :spaces_managers,
          columns: [:space_id, :user_id]
        },
        stacks:
        {
          db_uri:  ccdb_uri,
          table:   :stacks,
          columns: [:created_at, :description, :guid, :id, :name, :updated_at]
        },
        users_cc:
        {
          db_uri:  ccdb_uri,
          table:   :users,
          columns: [:active, :admin, :created_at, :default_space_id, :guid, :id, :updated_at]
        },
        users_uaa:
        {
          db_uri:  uaadb_uri,
          table:   :users,
          columns: [:active, :created, :email, :familyname, :givenname, :id, :lastmodified, :username, :verified, :version]
        }
      }

      @caches.each_pair do |key, cache|
        cache.merge!(semaphore: Mutex.new, condition: ConditionVariable.new, exists: nil, result: nil, select: nil)
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
        instances += app[:instances] if app[:state] == 'STARTED'
      end
      instances
    end

    def applications_total_instances
      hash = applications
      return nil unless hash['connected']
      instances = 0
      hash['items'].each do |app|
        Thread.pass
        instances += app[:instances]
      end
      instances
    end

    def apps_routes
      result_cache(:apps_routes)
    end

    def clients
      result_cache(:clients)
    end

    def domains
      result_cache(:domains)
    end

    def droplets
      result_cache(:droplets)
    end

    def events
      result_cache(:events)
    end

    def group_membership
      result_cache(:group_membership)
    end

    def groups
      result_cache(:groups)
    end

    def invalidate_applications
      invalidate_cache(:applications)
    end

    def invalidate_clients
      invalidate_cache(:clients)
    end

    def invalidate_domains
      invalidate_cache(:domains)
    end

    def invalidate_organizations
      invalidate_cache(:organizations)
    end

    def invalidate_organizations_auditors
      invalidate_cache(:organizations_auditors)
    end

    def invalidate_organizations_billing_managers
      invalidate_cache(:organizations_billing_managers)
    end

    def invalidate_organizations_managers
      invalidate_cache(:organizations_managers)
    end

    def invalidate_organizations_users
      invalidate_cache(:organizations_users)
    end

    def invalidate_routes
      invalidate_cache(:routes)
    end

    def invalidate_quota_definitions
      invalidate_cache(:quota_definitions)
    end

    def invalidate_service_bindings
      invalidate_cache(:service_bindings)
    end

    def invalidate_service_brokers
      invalidate_cache(:service_brokers)
    end

    def invalidate_service_instances
      invalidate_cache(:service_instances)
    end

    def invalidate_service_keys
      invalidate_cache(:service_keys)
    end

    def invalidate_service_plans
      invalidate_cache(:service_plans)
    end

    def invalidate_services
      invalidate_cache(:services)
    end

    def invalidate_service_plan_visibilities
      invalidate_cache(:service_plan_visibilities)
    end

    def invalidate_space_quota_definitions
      invalidate_cache(:space_quota_definitions)
    end

    def invalidate_spaces
      invalidate_cache(:spaces)
    end

    def invalidate_spaces_auditors
      invalidate_cache(:spaces_auditors)
    end

    def invalidate_spaces_developers
      invalidate_cache(:spaces_developers)
    end

    def invalidate_spaces_managers
      invalidate_cache(:spaces_managers)
    end

    def organizations
      result_cache(:organizations)
    end

    def organizations_auditors
      result_cache(:organizations_auditors)
    end

    def organizations_billing_managers
      result_cache(:organizations_billing_managers)
    end

    def organizations_count
      hash = organizations
      return nil unless hash['connected']
      hash['items'].length
    end

    def organizations_managers
      result_cache(:organizations_managers)
    end

    def organizations_private_domains
      result_cache(:organizations_private_domains)
    end

    def organizations_users
      result_cache(:organizations_users)
    end

    def quota_definitions
      result_cache(:quota_definitions)
    end

    def routes
      result_cache(:routes)
    end

    def service_bindings
      result_cache(:service_bindings)
    end

    def service_brokers
      result_cache(:service_brokers)
    end

    def service_dashboard_clients
      result_cache(:service_dashboard_clients)
    end

    def service_instance_operations
      result_cache(:service_instance_operations)
    end

    def service_instances
      result_cache(:service_instances)
    end

    def service_keys
      result_cache(:service_keys)
    end

    def service_plans
      result_cache(:service_plans)
    end

    def service_plan_visibilities
      result_cache(:service_plan_visibilities)
    end

    def services
      result_cache(:services)
    end

    def space_quota_definitions
      result_cache(:space_quota_definitions)
    end

    def spaces
      result_cache(:spaces)
    end

    def spaces_count
      hash = spaces
      return nil unless hash['connected']
      hash['items'].length
    end

    def spaces_auditors
      result_cache(:spaces_auditors)
    end

    def spaces_developers
      result_cache(:spaces_developers)
    end

    def spaces_managers
      result_cache(:spaces_managers)
    end

    def stacks
      result_cache(:stacks)
    end

    def users_cc
      result_cache(:users_cc)
    end

    def users_count
      hash = users_uaa
      return nil unless hash['connected']
      hash['items'].length
    end

    def users_uaa
      result_cache(:users_uaa)
    end

    private

    def discover(key)
      @logger.debug("[#{@config.cloud_controller_discovery_interval} second interval] Starting CC #{key} discovery...")

      cache = @caches[key]

      start = Time.now

      result_cache = select(key, cache)

      finish = Time.now

      cache[:semaphore].synchronize do
        @logger.debug("Caching CC #{key} data.  Count: #{result_cache['items'].length}.  Retrieval time: #{finish - start} seconds")
        cache[:result] = result_cache
        cache[:condition].broadcast
      end

      # Set up the next scheduled discovery for this key
      schedule(key, Time.now + @config.cloud_controller_discovery_interval)
    end

    def invalidate_cache(key)
      cache = @caches[key]
      cache[:semaphore].synchronize do
        cache[:result] = nil
      end
      schedule(key)
    end

    def schedule(key, time = Time.now)
      @pool.schedule(key, time) do
        discover(key)
      end
    end

    def result_cache(key)
      cache = @caches[key]
      cache[:semaphore].synchronize do
        if @testing
          cache[:condition].wait(cache[:semaphore]) while cache[:result].nil?
        else
          return result if cache[:result].nil?
        end
        cache[:result]
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

    def select(key, cache)
      # If the table exists or we have not yet determined if the table exists
      exists = cache[:exists]
      if exists || exists.nil?
        Sequel.connect(cache[:db_uri], single_threaded: @testing, max_connections: @max_connections) do |connection|
          # If we have not yet determined if the table exists
          if exists.nil?
            table = cache[:table]
            # Determine if the table exists
            exists = connection.table_exists?(table)
            cache[:exists] = exists
            if exists
              # Determine the columns the current level of database supports
              columns        = cache[:columns]
              db_columns     = connection[table].columns
              # Downcase needed on column names to get around case sensitivity in MySQL
              db_columns     = db_columns.map(&:downcase)
              statement      = connection[table].select(columns & db_columns)
              statement      = statement.where(cache[:where]) if cache[:where] && !@testing
              cache[:select] = statement.sql

              # TODO: If the sql has parenthesis around the select clause, you get an array of values instead of a hash
              cache[:select] = cache[:select].sub('(', '').sub(')', '')

              @logger.debug("Select for key #{key}, table #{table}: #{cache[:select]}")
              @logger.debug("Columns removed for key #{key}, table #{table}: #{columns - db_columns}")
            else
              @logger.debug("Table #{table} does not exist")
            end
          end

          # If the table exists
          if exists
            items = []
            connection.fetch(cache[:select]) do |row|
              Thread.pass
              items.push(row)
            end
            return result(items)
          end
        end
      end

      result
    rescue => error
      @logger.debug("Error during discovery of #{key}: #{error.inspect}")
      @logger.debug(error.backtrace.join("\n"))
      result
    end
  end
end
