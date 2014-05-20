require 'date'
require_relative 'scheduled_thread_pool'
require_relative 'tabs/applications_tab'
require_relative 'tabs/cloud_controllers_tab'
require_relative 'tabs/components_tab'
require_relative 'tabs/deas_tab'
require_relative 'tabs/developers_tab'
require_relative 'tabs/gateways_tab'
require_relative 'tabs/health_managers_tab'
require_relative 'tabs/organizations_tab'
require_relative 'tabs/quotas_tab'
require_relative 'tabs/routers_tab'
require_relative 'tabs/routes_tab'
require_relative 'tabs/service_instances_tab'
require_relative 'tabs/service_plans_tab'
require_relative 'tabs/spaces_tab'

module AdminUI
  class Tabs
    def initialize(config, logger, cc, varz)
      @cc     = cc
      @config = config
      @logger = logger
      @varz   = varz
      # TODO: Need config for number of threads
      @pool   = AdminUI::ScheduledThreadPool.new(logger, 5)

      @caches = {}
      # These keys need to conform to their respective discover_x methods.
      # For instance applications conforms to discover_applications
      [:applications, :cloud_controllers, :components, :deas, :developers, :gateways, :health_managers, :organizations, :quotas, :routers, :routes, :service_instances, :service_plans, :spaces].each do |key|
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

      @logger.debug("[#{ @config.cloud_controller_discovery_interval } second interval] Starting Tabs #{ key_string } discovery...")

      result_cache = send("discover_#{ key_string }".to_sym)

      hash = @caches[key]
      hash[:semaphore].synchronize do
        @logger.debug("Caching Tabs #{ key_string } data...")
        hash[:result] = result_cache
        hash[:condition].broadcast
      end

      # Set up the next scheduled discovery for this key
      schedule(key, Time.now + @config.cloud_controller_discovery_interval)
    end

    def result_cache(key)
      hash = @caches[key]
      hash[:semaphore].synchronize do
        hash[:condition].wait(hash[:semaphore]) while hash[:result].nil?
        hash[:result]
      end
    end

    def discover_applications
      AdminUI::ApplicationsTab.new(@logger, @cc, @varz).items
    rescue => error
      @logger.debug("Error during discover_applications: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_cloud_controllers
      AdminUI::CloudControllersTab.new(@logger, @cc, @varz).items
    rescue => error
      @logger.debug("Error during discover_cloud_controllers: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_components
      AdminUI::ComponentsTab.new(@logger, @cc, @varz).items
    rescue => error
      @logger.debug("Error during discover_components: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_deas
      AdminUI::DEAsTab.new(@logger, @cc, @varz).items
    rescue => error
      @logger.debug("Error during discover_deas: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_developers
      AdminUI::DevelopersTab.new(@logger, @cc, @varz).items
    rescue => error
      @logger.debug("Error during discover_developers: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_gateways
      AdminUI::GatewaysTab.new(@logger, @cc, @varz).items
    rescue => error
      @logger.debug("Error during discover_gateways: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_health_managers
      AdminUI::HealthManagersTab.new(@logger, @cc, @varz).items
    rescue => error
      @logger.debug("Error during discover_health_managers: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_organizations
      AdminUI::OrganizationsTab.new(@logger, @cc, @varz).items
    rescue => error
      @logger.debug("Error during discover_organizations: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_quotas
      AdminUI::QuotasTab.new(@logger, @cc, @varz).items
    rescue => error
      @logger.debug("Error during discover_quotas: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_routers
      AdminUI::RoutersTab.new(@logger, @cc, @varz).items
    rescue => error
      @logger.debug("Error during discover_routers: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_routes
      AdminUI::RoutesTab.new(@logger, @cc, @varz).items
    rescue => error
      @logger.debug("Error during discover_routes: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_service_instances
      AdminUI::ServiceInstancesTab.new(@logger, @cc, @varz).items
    rescue => error
      @logger.debug("Error during discover_service_instances: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_service_plans
      AdminUI::ServicePlansTab.new(@logger, @cc, @varz).items
    rescue => error
      @logger.debug("Error during discover_service_plans: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_spaces
      AdminUI::SpacesTab.new(@logger, @cc, @varz).items
    rescue => error
      @logger.debug("Error during discover_spaces: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end
  end
end
