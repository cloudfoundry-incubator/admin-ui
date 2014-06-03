require 'date'
require_relative 'scheduled_thread_pool'
require_relative 'view_models/applications_view_model'
require_relative 'view_models/cloud_controllers_view_model'
require_relative 'view_models/components_view_model'
require_relative 'view_models/deas_view_model'
require_relative 'view_models/developers_view_model'
require_relative 'view_models/gateways_view_model'
require_relative 'view_models/health_managers_view_model'
require_relative 'view_models/logs_view_model'
require_relative 'view_models/organizations_view_model'
require_relative 'view_models/quotas_view_model'
require_relative 'view_models/routers_view_model'
require_relative 'view_models/routes_view_model'
require_relative 'view_models/service_instances_view_model'
require_relative 'view_models/service_plans_view_model'
require_relative 'view_models/spaces_view_model'
require_relative 'view_models/stats_view_model'
require_relative 'view_models/tasks_view_model'

module AdminUI
  class ViewModels
    def initialize(config, logger, cc, log_files, stats, tasks, varz)
      @cc        = cc
      @config    = config
      @log_files = log_files
      @logger    = logger
      @stats     = stats
      @tasks     = tasks
      @varz      = varz
      # TODO: Need config for number of threads
      @pool      = AdminUI::ScheduledThreadPool.new(logger, 2, -1)

      # Using an interval of half of the cloud_controller_interval.  The value of 1 is there for a test-time boundary
      @interval = [@config.cloud_controller_discovery_interval / 2, 1].max

      @caches = {}
      # These keys need to conform to their respective discover_x methods.
      # For instance applications conforms to discover_applications
      [:applications, :cloud_controllers, :components, :deas, :developers, :gateways, :health_managers, :logs, :organizations, :quotas, :routers, :routes, :service_instances, :service_plans, :spaces, :stats, :tasks].each do |key|
        hash = { :semaphore => Mutex.new, :condition => ConditionVariable.new, :result => nil }
        @caches[key] = hash
        schedule(key)
      end
    end

    def invalidate_applications
      invalidate_cache(:applications)
    end

    def invalidate_organizations
      invalidate_cache(:organizations)
    end

    def invalidate_routes
      invalidate_cache(:routes)
    end

    def invalidate_service_plans
      invalidate_cache(:service_plans)
    end

    def invalidate_stats
      invalidate_cache(:stats)
    end

    def invalidate_tasks
      invalidate_cache(:tasks)
    end

    def applications
      result_cache(:applications)
    end

    def cloud_controllers
      result_cache(:cloud_controllers)
    end

    def components
      result_cache(:components)
    end

    def deas
      result_cache(:deas)
    end

    def developers
      result_cache(:developers)
    end

    def gateways
      result_cache(:gateways)
    end

    def health_managers
      result_cache(:health_managers)
    end

    def logs
      result_cache(:logs)
    end

    def organizations
      result_cache(:organizations)
    end

    def quotas
      result_cache(:quotas)
    end

    def routers
      result_cache(:routers)
    end

    def routes
      result_cache(:routes)
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

    def stats
      result_cache(:stats)
    end

    def tasks
      result_cache(:tasks)
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

      @logger.debug("[#{ @interval } second interval] Starting view model #{ key_string } discovery...")

      start = Time.now

      result_cache = send("discover_#{ key_string }".to_sym)

      finish = Time.now

      hash = @caches[key]
      hash[:semaphore].synchronize do
        @logger.debug("Caching view model #{ key_string } data.  Compilation time: #{ finish - start } seconds")
        hash[:result] = result_cache
        hash[:condition].broadcast
      end

      # Set up the next scheduled discovery for this key
      schedule(key, Time.now + @interval)
    end

    def result_cache(key)
      hash = @caches[key]
      hash[:semaphore].synchronize do
        hash[:condition].wait(hash[:semaphore]) while hash[:result].nil?
        hash[:result]
      end
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

    def discover_developers
      AdminUI::DevelopersViewModel.new(@logger, @cc).items
    rescue => error
      @logger.debug("Error during discover_developers: #{ error.inspect }")
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

    def discover_quotas
      AdminUI::QuotasViewModel.new(@logger, @cc).items
    rescue => error
      @logger.debug("Error during discover_quotas: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_routers
      AdminUI::RoutersViewModel.new(@logger, @varz).items
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
  end
end
