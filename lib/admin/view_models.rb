require 'date'
require_relative 'scheduled_thread_pool'
require_relative 'view_models/applications_view_model'
require_relative 'view_models/cloud_controllers_view_model'
require_relative 'view_models/components_view_model'
require_relative 'view_models/deas_view_model'
require_relative 'view_models/domains_view_model'
require_relative 'view_models/gateways_view_model'
require_relative 'view_models/health_managers_view_model'
require_relative 'view_models/logs_view_model'
require_relative 'view_models/organization_roles_view_model'
require_relative 'view_models/organizations_view_model'
require_relative 'view_models/quotas_view_model'
require_relative 'view_models/routers_view_model'
require_relative 'view_models/routes_view_model'
require_relative 'view_models/service_instances_view_model'
require_relative 'view_models/service_plans_view_model'
require_relative 'view_models/space_roles_view_model'
require_relative 'view_models/spaces_view_model'
require_relative 'view_models/stats_view_model'
require_relative 'view_models/tasks_view_model'
require_relative 'view_models/users_view_model'

module AdminUI
  class ViewModels
    def initialize(config, logger, cc, log_files, stats, tasks, varz, testing = false)
      @cc        = cc
      @config    = config
      @log_files = log_files
      @logger    = logger
      @stats     = stats
      @tasks     = tasks
      @varz      = varz
      @testing   = testing

      # TODO: Need config for number of threads
      @pool      = AdminUI::ScheduledThreadPool.new(logger, 2, -1)

      # Using an interval of half of the cloud_controller_interval.  The value of 1 is there for a test-time boundary
      @interval = [@config.cloud_controller_discovery_interval / 2, 1].max

      @caches = {}
      # These keys need to conform to their respective discover_x methods.
      # For instance applications conforms to discover_applications
      [:applications, :cloud_controllers, :components, :deas, :domains, :gateways, :health_managers, :logs, :organizations, :organization_roles, :quotas, :routers, :routes, :service_instances, :service_plans, :spaces, :space_roles, :stats, :tasks, :users].each do |key|
        hash = { :semaphore => Mutex.new, :condition => ConditionVariable.new, :result => nil }
        @caches[key] = hash
        schedule(key)
      end
    end

    def invalidate_applications
      invalidate_cache(:applications)
    end

    def invalidate_cloud_controllers
      invalidate_cache(:cloud_controllers)
    end

    def invalidate_components
      invalidate_cache(:components)
    end

    def invalidate_deas
      invalidate_cache(:deas)
    end

    def invalidate_gateways
      invalidate_cache(:gateways)
    end

    def invalidate_health_managers
      invalidate_cache(:health_managers)
    end

    def invalidate_organizations
      invalidate_cache(:organizations)
    end

    def invalidate_organization_roles
      invalidate_cache(:organization_roles)
    end

    def invalidate_routers
      invalidate_cache(:routers)
    end

    def invalidate_routes
      invalidate_cache(:routes)
    end

    def invalidate_service_plans
      invalidate_cache(:service_plans)
    end

    def invalidate_space_roles
      invalidate_cache(:space_roles)
    end

    def invalidate_stats
      invalidate_cache(:stats)
    end

    def invalidate_tasks
      invalidate_cache(:tasks)
    end

    def application(guid, instance = nil)
      key = guid
      key += "/#{ instance }" if instance
      details(:applications, key)
    end

    def applications
      result_cache(:applications)
    end

    def cloud_controller(name)
      details(:cloud_controllers, name)
    end

    def cloud_controllers
      result_cache(:cloud_controllers)
    end

    def component(name)
      details(:components, name)
    end

    def components
      result_cache(:components)
    end

    def dea(name)
      details(:deas, name)
    end

    def deas
      result_cache(:deas)
    end

    def domain(guid)
      details(:domains, guid)
    end

    def domains
      result_cache(:domains)
    end

    def gateway(name)
      details(:gateways, name)
    end

    def gateways
      result_cache(:gateways)
    end

    def health_manager(name)
      details(:health_managers, name)
    end

    def health_managers
      result_cache(:health_managers)
    end

    def logs
      result_cache(:logs)
    end

    def organization(guid)
      details(:organizations, guid)
    end

    def organizations
      result_cache(:organizations)
    end

    def organization_role(organization_guid, role, user_guid)
      details(:organization_roles, "#{ organization_guid }/#{ role }/#{ user_guid }")
    end

    def organization_roles
      result_cache(:organization_roles)
    end

    def quota(guid)
      details(:quotas, guid)
    end

    def quotas
      result_cache(:quotas)
    end

    def router(name)
      details(:routers, name)
    end

    def routers
      result_cache(:routers)
    end

    def route(guid)
      details(:routes, guid)
    end

    def routes
      result_cache(:routes)
    end

    def service_instance(guid)
      details(:service_instances, guid)
    end

    def service_instances
      result_cache(:service_instances)
    end

    def service_plan(guid)
      details(:service_plans, guid)
    end

    def service_plans
      result_cache(:service_plans)
    end

    def space(guid)
      details(:spaces, guid)
    end

    def spaces
      result_cache(:spaces)
    end

    def space_role(space_guid, role, user_guid)
      details(:space_roles, "#{ space_guid }/#{ role }/#{ user_guid }")
    end

    def space_roles
      result_cache(:space_roles)
    end

    def stats
      result_cache(:stats)
    end

    def tasks
      result_cache(:tasks)
    end

    def user(guid)
      details(:users, guid)
    end

    def users
      result_cache(:users)
    end

    private

    def invalidate_cache(key)
      if @testing
        hash = @caches[key]
        hash[:semaphore].synchronize do
          hash[:result] = nil
        end
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

      @logger.debug("[#{ @interval } second interval] Starting view model #{ key_string } discovery...")

      start = Time.now

      result_cache = send("discover_#{ key_string }".to_sym)

      finish = Time.now

      connected = result_cache[:connected]

      hash = @caches[key]
      hash[:semaphore].synchronize do
        @logger.debug("Caching view model #{ key_string } data.  Compilation time: #{ finish - start } seconds")

        # Only replace the cached result if the value is connected or this is the first time
        hash[:result] = result_cache if connected || hash[:result].nil?

        hash[:condition].broadcast
      end

      # If not a connected new value, reschedule the discovery soon
      interval = @interval
      interval = 5 if interval > 5 && connected == false

      # Set up the next scheduled discovery for this key
      schedule(key, Time.now + interval)
    end

    def result_cache(key)
      hash = @caches[key]
      hash[:semaphore].synchronize do
        hash[:condition].wait(hash[:semaphore]) while hash[:result].nil?
        hash[:result]
      end
    end

    def details(key, hash_key)
      detail_hash = result_cache(key)[:detail_hash]
      return detail_hash[hash_key] if detail_hash
    end

    def discover_applications
      AdminUI::ApplicationsViewModel.new(@logger, @cc, @varz).items
    rescue => error
      @logger.debug("Error during discover_applications: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_cloud_controllers
      AdminUI::CloudControllersViewModel.new(@logger, @varz).items
    rescue => error
      @logger.debug("Error during discover_cloud_controllers: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_components
      AdminUI::ComponentsViewModel.new(@logger, @varz).items
    rescue => error
      @logger.debug("Error during discover_components: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_deas
      AdminUI::DEAsViewModel.new(@logger, @varz).items
    rescue => error
      @logger.debug("Error during discover_deas: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_domains
      AdminUI::DomainsViewModel.new(@logger, @cc).items
    rescue => error
      @logger.debug("Error during discover_domains: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_gateways
      AdminUI::GatewaysViewModel.new(@logger, @varz).items
    rescue => error
      @logger.debug("Error during discover_gateways: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_health_managers
      AdminUI::HealthManagersViewModel.new(@logger, @varz).items
    rescue => error
      @logger.debug("Error during discover_health_managers: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_logs
      AdminUI::LogsViewModel.new(@logger, @log_files).items
    rescue => error
      @logger.debug("Error during discover_logs: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_organizations
      AdminUI::OrganizationsViewModel.new(@logger, @cc, @varz).items
    rescue => error
      @logger.debug("Error during discover_organizations: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_organization_roles
      AdminUI::OrganizationRolesViewModel.new(@logger, @cc).items
    rescue => error
      @logger.debug("Error during discover_organization_roles: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_quotas
      AdminUI::QuotasViewModel.new(@logger, @cc).items
    rescue => error
      @logger.debug("Error during discover_quotas: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_routers
      AdminUI::RoutersViewModel.new(@logger, @cc, @varz).items
    rescue => error
      @logger.debug("Error during discover_routers: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_routes
      AdminUI::RoutesViewModel.new(@logger, @cc).items
    rescue => error
      @logger.debug("Error during discover_routes: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_service_instances
      AdminUI::ServiceInstancesViewModel.new(@logger, @cc).items
    rescue => error
      @logger.debug("Error during discover_service_instances: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_service_plans
      AdminUI::ServicePlansViewModel.new(@logger, @cc).items
    rescue => error
      @logger.debug("Error during discover_service_plans: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_spaces
      AdminUI::SpacesViewModel.new(@logger, @cc, @varz).items
    rescue => error
      @logger.debug("Error during discover_spaces: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_space_roles
      AdminUI::SpaceRolesViewModel.new(@logger, @cc).items
    rescue => error
      @logger.debug("Error during discover_space_roles: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_stats
      AdminUI::StatsViewModel.new(@logger, @stats).items
    rescue => error
      @logger.debug("Error during discover_stats: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_tasks
      AdminUI::TasksViewModel.new(@logger, @tasks).items
    rescue => error
      @logger.debug("Error during discover_tasks: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_users
      AdminUI::UsersViewModel.new(@logger, @cc).items
    rescue => error
      @logger.debug("Error during discover_users: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end
  end
end
