require 'date'
require_relative 'scheduled_thread_pool'
require_relative 'view_models/application_instances_view_model'
require_relative 'view_models/applications_view_model'
require_relative 'view_models/approvals_view_model'
require_relative 'view_models/buildpacks_view_model'
require_relative 'view_models/cells_view_model'
require_relative 'view_models/clients_view_model'
require_relative 'view_models/cloud_controllers_view_model'
require_relative 'view_models/components_view_model'
require_relative 'view_models/deas_view_model'
require_relative 'view_models/domains_view_model'
require_relative 'view_models/environment_groups_view_model'
require_relative 'view_models/events_view_model'
require_relative 'view_models/feature_flags_view_model'
require_relative 'view_models/gateways_view_model'
require_relative 'view_models/group_members_view_model'
require_relative 'view_models/groups_view_model'
require_relative 'view_models/health_managers_view_model'
require_relative 'view_models/identity_providers_view_model'
require_relative 'view_models/identity_zones_view_model'
require_relative 'view_models/isolation_segments_view_model'
require_relative 'view_models/logs_view_model'
require_relative 'view_models/mfa_providers_view_model'
require_relative 'view_models/organization_roles_view_model'
require_relative 'view_models/organizations_isolation_segments_view_model'
require_relative 'view_models/organizations_view_model'
require_relative 'view_models/quotas_view_model'
require_relative 'view_models/revocable_tokens_view_model'
require_relative 'view_models/routers_view_model'
require_relative 'view_models/routes_view_model'
require_relative 'view_models/route_bindings_view_model'
require_relative 'view_models/route_mappings_view_model'
require_relative 'view_models/security_groups_spaces_view_model'
require_relative 'view_models/security_groups_view_model'
require_relative 'view_models/service_bindings_view_model'
require_relative 'view_models/service_brokers_view_model'
require_relative 'view_models/service_instances_view_model'
require_relative 'view_models/service_keys_view_model'
require_relative 'view_models/service_plans_view_model'
require_relative 'view_models/service_plan_visibilities_view_model'
require_relative 'view_models/service_providers_view_model'
require_relative 'view_models/services_view_model'
require_relative 'view_models/shared_service_instances_view_model'
require_relative 'view_models/space_quotas_view_model'
require_relative 'view_models/space_roles_view_model'
require_relative 'view_models/spaces_view_model'
require_relative 'view_models/stacks_view_model'
require_relative 'view_models/staging_security_groups_spaces_view_model'
require_relative 'view_models/stats_view_model'
require_relative 'view_models/tasks_view_model'
require_relative 'view_models/users_view_model'

module AdminUI
  class ViewModels
    def initialize(config, logger, cc, cc_rest_client, doppler, log_files, stats, varz, testing)
      @config          = config
      @logger          = logger
      @testing         = testing
      @cc_rest_client  = cc_rest_client

      @running = true

      @caches =
        {
          application_instances:            { clazz: AdminUI::ApplicationInstancesViewModel },
          applications:                     { clazz: AdminUI::ApplicationsViewModel },
          approvals:                        { clazz: AdminUI::ApprovalsViewModel },
          buildpacks:                       { clazz: AdminUI::BuildpacksViewModel },
          cells:                            { clazz: AdminUI::CellsViewModel },
          clients:                          { clazz: AdminUI::ClientsViewModel },
          cloud_controllers:                { clazz: AdminUI::CloudControllersViewModel },
          components:                       { clazz: AdminUI::ComponentsViewModel },
          deas:                             { clazz: AdminUI::DEAsViewModel },
          domains:                          { clazz: AdminUI::DomainsViewModel },
          environment_groups:               { clazz: AdminUI::EnvironmentGroupsViewModel },
          events:                           { clazz: AdminUI::EventsViewModel },
          feature_flags:                    { clazz: AdminUI::FeatureFlagsViewModel },
          gateways:                         { clazz: AdminUI::GatewaysViewModel },
          group_members:                    { clazz: AdminUI::GroupMembersViewModel },
          groups:                           { clazz: AdminUI::GroupsViewModel },
          health_managers:                  { clazz: AdminUI::HealthManagersViewModel },
          identity_providers:               { clazz: AdminUI::IdentityProvidersViewModel },
          identity_zones:                   { clazz: AdminUI::IdentityZonesViewModel },
          isolation_segments:               { clazz: AdminUI::IsolationSegmentsViewModel },
          logs:                             { clazz: AdminUI::LogsViewModel },
          mfa_providers:                    { clazz: AdminUI::MFAProvidersViewModel },
          organizations:                    { clazz: AdminUI::OrganizationsViewModel },
          organizations_isolation_segments: { clazz: AdminUI::OrganizationsIsolationSegmentsViewModel },
          organization_roles:               { clazz: AdminUI::OrganizationRolesViewModel },
          quotas:                           { clazz: AdminUI::QuotasViewModel },
          revocable_tokens:                 { clazz: AdminUI::RevocableTokensViewModel },
          routers:                          { clazz: AdminUI::RoutersViewModel },
          routes:                           { clazz: AdminUI::RoutesViewModel },
          route_bindings:                   { clazz: AdminUI::RouteBindingsViewModel },
          route_mappings:                   { clazz: AdminUI::RouteMappingsViewModel },
          services:                         { clazz: AdminUI::ServicesViewModel },
          security_groups:                  { clazz: AdminUI::SecurityGroupsViewModel },
          security_groups_spaces:           { clazz: AdminUI::SecurityGroupsSpacesViewModel },
          service_bindings:                 { clazz: AdminUI::ServiceBindingsViewModel },
          service_brokers:                  { clazz: AdminUI::ServiceBrokersViewModel },
          service_instances:                { clazz: AdminUI::ServiceInstancesViewModel },
          service_keys:                     { clazz: AdminUI::ServiceKeysViewModel },
          service_plans:                    { clazz: AdminUI::ServicePlansViewModel },
          service_plan_visibilities:        { clazz: AdminUI::ServicePlanVisibilitiesViewModel },
          service_providers:                { clazz: AdminUI::ServiceProvidersViewModel },
          shared_service_instances:         { clazz: AdminUI::SharedServiceInstancesViewModel },
          space_quotas:                     { clazz: AdminUI::SpaceQuotasViewModel },
          space_roles:                      { clazz: AdminUI::SpaceRolesViewModel },
          spaces:                           { clazz: AdminUI::SpacesViewModel },
          stacks:                           { clazz: AdminUI::StacksViewModel },
          staging_security_groups_spaces:   { clazz: AdminUI::StagingSecurityGroupsSpacesViewModel },
          stats:                            { clazz: AdminUI::StatsViewModel },
          tasks:                            { clazz: AdminUI::TasksViewModel },
          users:                            { clazz: AdminUI::UsersViewModel }
        }

      number_threads = testing ? @caches.length : 2

      # TODO: Need config for number of threads
      @pool = AdminUI::ScheduledThreadPool.new(logger, number_threads, -1)

      # Using an interval of half of the cloud_controller_interval. The value of 1 is there for a test-time boundary
      @interval = [config.cloud_controller_discovery_interval / 2, 1].max

      @caches.each_pair do |key, cache|
        cache[:condition]          = ConditionVariable.new
        cache[:result]             = nil
        cache[:semaphore]          = Mutex.new
        cache[:view_model_factory] = cache[:clazz].new(@logger, cc, cc_rest_client, doppler, log_files, stats, varz, @testing)

        schedule(key)
      end
    end

    def invalidate_application_instances
      invalidate_cache(:application_instances)
    end

    def invalidate_applications
      invalidate_cache(:applications)
    end

    def invalidate_approvals
      invalidate_cache(:approvals)
    end

    def invalidate_buildpacks
      invalidate_cache(:buildpacks)
    end

    def invalidate_cells
      invalidate_cache(:cells)
    end

    def invalidate_clients
      invalidate_cache(:clients)
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

    def invalidate_domains
      invalidate_cache(:domains)
    end

    def invalidate_feature_flags
      invalidate_cache(:feature_flags)
    end

    def invalidate_gateways
      invalidate_cache(:gateways)
    end

    def invalidate_group_members
      invalidate_cache(:group_members)
    end

    def invalidate_groups
      invalidate_cache(:groups)
    end

    def invalidate_health_managers
      invalidate_cache(:health_managers)
    end

    def invalidate_identity_providers
      invalidate_cache(:identity_providers)
    end

    def invalidate_identity_zones
      invalidate_cache(:identity_zones)
    end

    def invalidate_isolation_segments
      invalidate_cache(:isolation_segments)
    end

    def invalidate_mfa_providers
      invalidate_cache(:mfa_providers)
    end

    def invalidate_organizations
      invalidate_cache(:organizations)
    end

    def invalidate_organizations_isolation_segments
      invalidate_cache(:organizations_isolation_segments)
    end

    def invalidate_organization_roles
      invalidate_cache(:organization_roles)
    end

    def invalidate_quotas
      invalidate_cache(:quotas)
    end

    def invalidate_revocable_tokens
      invalidate_cache(:revocable_tokens)
    end

    def invalidate_routers
      invalidate_cache(:routers)
    end

    def invalidate_routes
      invalidate_cache(:routes)
    end

    def invalidate_route_bindings
      invalidate_cache(:route_bindings)
    end

    def invalidate_route_mappings
      invalidate_cache(:route_mappings)
    end

    def invalidate_security_groups
      invalidate_cache(:security_groups)
    end

    def invalidate_security_groups_spaces
      invalidate_cache(:security_groups_spaces)
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

    def invalidate_service_plan_visibilities
      invalidate_cache(:service_plan_visibilities)
    end

    def invalidate_service_plans
      invalidate_cache(:service_plans)
    end

    def invalidate_service_providers
      invalidate_cache(:service_providers)
    end

    def invalidate_services
      invalidate_cache(:services)
    end

    def invalidate_shared_service_instances
      invalidate_cache(:shared_service_instances)
    end

    def invalidate_space_quotas
      invalidate_cache(:space_quotas)
    end

    def invalidate_space_roles
      invalidate_cache(:space_roles)
    end

    def invalidate_spaces
      invalidate_cache(:spaces)
    end

    def invalidate_stacks
      invalidate_cache(:stacks)
    end

    def invalidate_staging_security_groups_spaces
      invalidate_cache(:staging_security_groups_spaces)
    end

    def invalidate_stats
      invalidate_cache(:stats)
    end

    def invalidate_tasks
      invalidate_cache(:tasks)
    end

    def invalidate_users
      invalidate_cache(:users)
    end

    def application_instance(app_guid, instance_index)
      details(:application_instances, "#{app_guid}/#{instance_index}")
    end

    def application_instances
      result_cache(:application_instances)
    end

    def application(guid, admin)
      result = details(:applications, guid)
      if @config.display_encrypted_values && admin && !result.nil?
        begin
          api_version = @cc_rest_client.api_version
          v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
          if v3
            json = @cc_rest_client.get_cc("/v3/apps/#{guid}/environment_variables")
            environment_variables = json['var']
          else
            json = @cc_rest_client.get_cc("/v2/apps/#{guid}")
            environment_variables = json['entity']['environment_json']
          end
          environment_variables = environment_variables.sort_by { |key, _| key.downcase }.to_h
          return result.merge('environment_variables' => environment_variables).sort_by { |key, _| key }.to_h
        rescue => error
          @logger.error("Error during application #{guid} retrieval: #{error.inspect}")
          @logger.error(error.backtrace.join("\n"))
        end
      end
      result
    end

    def applications
      result_cache(:applications)
    end

    def approval(user_id, client_id, scope)
      details(:approvals, "#{user_id}/#{client_id}/#{scope}")
    end

    def approvals
      result_cache(:approvals)
    end

    def buildpack(guid)
      details(:buildpacks, guid)
    end

    def buildpacks
      result_cache(:buildpacks)
    end

    def cell(key)
      details(:cells, key)
    end

    def cells
      result_cache(:cells)
    end

    def client(id)
      details(:clients, id)
    end

    def clients
      result_cache(:clients)
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

    def environment_group(name)
      result = details(:environment_groups, name)
      unless result.nil?
        begin
          api_version = @cc_rest_client.api_version
          v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
          if v3
            json = @cc_rest_client.get_cc("/v3/environment_variable_groups/#{name}")
            environment_variables = json['var']
          else
            environment_variables = @cc_rest_client.get_cc("/v2/config/environment_variable_groups/#{name}")
          end
          environment_variables = environment_variables.sort_by { |key, _| key.downcase }.to_h
          return result.merge(variables: environment_variables).sort_by { |key, _| key }.to_h
        rescue => error
          @logger.error("Error during environment_group #{name} retrieval: #{error.inspect}")
          @logger.error(error.backtrace.join("\n"))
        end
      end
      result
    end

    def environment_groups
      result_cache(:environment_groups)
    end

    def event(guid)
      details(:events, guid)
    end

    def events
      result_cache(:events)
    end

    def feature_flag(name)
      details(:feature_flags, name)
    end

    def feature_flags
      result_cache(:feature_flags)
    end

    def gateway(name)
      details(:gateways, name)
    end

    def gateways
      result_cache(:gateways)
    end

    def group(guid)
      details(:groups, guid)
    end

    def groups
      result_cache(:groups)
    end

    def group_member(group_id, member_id)
      details(:group_members, "#{group_id}/#{member_id}")
    end

    def group_members
      result_cache(:group_members)
    end

    def health_manager(name)
      details(:health_managers, name)
    end

    def health_managers
      result_cache(:health_managers)
    end

    def identity_provider(guid)
      details(:identity_providers, guid)
    end

    def identity_providers
      result_cache(:identity_providers)
    end

    def identity_zone(id)
      details(:identity_zones, id)
    end

    def identity_zones
      result_cache(:identity_zones)
    end

    def isolation_segment(guid)
      details(:isolation_segments, guid)
    end

    def isolation_segments
      result_cache(:isolation_segments)
    end

    def logs
      result_cache(:logs)
    end

    def mfa_provider(id)
      details(:mfa_providers, id)
    end

    def mfa_providers
      result_cache(:mfa_providers)
    end

    def organization(guid)
      details(:organizations, guid)
    end

    def organizations
      result_cache(:organizations)
    end

    def organization_isolation_segment(organization_guid, isolation_segment_guid)
      details(:organizations_isolation_segments, "#{organization_guid}/#{isolation_segment_guid}")
    end

    def organizations_isolation_segments
      result_cache(:organizations_isolation_segments)
    end

    def organization_role(organization_guid, role_guid, role, user_guid)
      details(:organization_roles, "#{organization_guid}/#{role_guid}/#{role}/#{user_guid}")
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

    def revocable_token(token_id)
      details(:revocable_tokens, token_id)
    end

    def revocable_tokens
      result_cache(:revocable_tokens)
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

    def route_binding(guid)
      details(:route_bindings, guid)
    end

    def route_bindings
      result_cache(:route_bindings)
    end

    def route_mapping(route_mapping_guid, route_guid)
      details(:route_mappings, "#{route_mapping_guid}/#{route_guid}")
    end

    def route_mappings
      result_cache(:route_mappings)
    end

    def security_group(guid)
      details(:security_groups, guid)
    end

    def security_group_space(security_group_guid, space_guid)
      details(:security_groups_spaces, "#{security_group_guid}/#{space_guid}")
    end

    def security_groups
      result_cache(:security_groups)
    end

    def security_groups_spaces
      result_cache(:security_groups_spaces)
    end

    def service(guid)
      details(:services, guid)
    end

    def service_binding(guid, admin)
      result = details(:service_bindings, guid)
      if @config.display_encrypted_values && admin && !result.nil?
        begin
          # TODO: v3 retrieve service binding
          json = @cc_rest_client.get_cc("/v2/service_bindings/#{guid}")
          credentials = json['entity']['credentials']
          credentials = credentials.sort_by { |key, _| key.downcase }.to_h
          volume_mounts = json['entity']['volume_mounts']
          return result.merge('credentials' => credentials, 'volume_mounts' => volume_mounts).sort_by { |key, _| key }.to_h
        rescue => error
          @logger.error("Error during service_binding #{guid} retrieval: #{error.inspect}")
          @logger.error(error.backtrace.join("\n"))
        end
      end
      result
    end

    def service_bindings
      result_cache(:service_bindings)
    end

    def service_broker(guid)
      details(:service_brokers, guid)
    end

    def service_brokers
      result_cache(:service_brokers)
    end

    def service_instance(guid, is_gateway_service, admin)
      result = details(:service_instances, guid)
      if @config.display_encrypted_values && admin && !result.nil?
        begin
          type = is_gateway_service ? 'service_instances' : 'user_provided_service_instances'
          # TODO: v3 retrieve service instance
          json = @cc_rest_client.get_cc("/v2/#{type}/#{guid}")
          credentials = json['entity']['credentials']
          credentials = credentials.sort_by { |key, _| key.downcase }.to_h
          return result.merge('credentials' => credentials).sort_by { |key, _| key }.to_h
        rescue => error
          @logger.error("Error during service_instance #{guid} retrieval: #{error.inspect}")
          @logger.error(error.backtrace.join("\n"))
        end
      end
      result
    end

    def service_instances
      result_cache(:service_instances)
    end

    def service_key(guid, admin)
      result = details(:service_keys, guid)
      if @config.display_encrypted_values && admin && !result.nil?
        begin
          # TODO: v3 retrieve service key
          json = @cc_rest_client.get_cc("/v2/service_keys/#{guid}")
          credentials = json['entity']['credentials']
          credentials = credentials.sort_by { |key, _| key.downcase }.to_h
          return result.merge('credentials' => credentials).sort_by { |key, _| key }.to_h
        rescue => error
          @logger.error("Error during service_key #{guid} retrieval: #{error.inspect}")
          @logger.error(error.backtrace.join("\n"))
        end
      end
      result
    end

    def service_keys
      result_cache(:service_keys)
    end

    def service_plan(guid)
      details(:service_plans, guid)
    end

    def service_plans
      result_cache(:service_plans)
    end

    def service_plan_visibility(service_plan_visibility_guid, service_plan_guid, organization_guid)
      details(:service_plan_visibilities, "#{service_plan_visibility_guid}/#{service_plan_guid}/#{organization_guid}")
    end

    def service_plan_visibilities
      result_cache(:service_plan_visibilities)
    end

    def service_provider(id)
      details(:service_providers, id)
    end

    def service_providers
      result_cache(:service_providers)
    end

    def services
      result_cache(:services)
    end

    def shared_service_instance(service_instance_guid, target_space_guid)
      details(:shared_service_instances, "#{service_instance_guid}/#{target_space_guid}")
    end

    def shared_service_instances
      result_cache(:shared_service_instances)
    end

    def shutdown
      return unless @running

      @running = false

      @caches.each_value do |cache|
        cache[:view_model_factory].shutdown
        cache[:semaphore].synchronize do
          cache[:condition].broadcast
        end
      end

      @pool.shutdown
    end

    def join
      @pool.join
    end

    def space(guid)
      details(:spaces, guid)
    end

    def space_quota(guid)
      details(:space_quotas, guid)
    end

    def space_quotas
      result_cache(:space_quotas)
    end

    def space_role(space_guid, role_guid, role, user_guid)
      details(:space_roles, "#{space_guid}/#{role_guid}/#{role}/#{user_guid}")
    end

    def space_roles
      result_cache(:space_roles)
    end

    def spaces
      result_cache(:spaces)
    end

    def stack(guid)
      details(:stacks, guid)
    end

    def stacks
      result_cache(:stacks)
    end

    def staging_security_group_space(staging_security_group_guid, staging_space_guid)
      details(:staging_security_groups_spaces, "#{staging_security_group_guid}/#{staging_space_guid}")
    end

    def staging_security_groups_spaces
      result_cache(:staging_security_groups_spaces)
    end

    def stats
      result_cache(:stats)
    end

    def task(guid)
      details(:tasks, guid)
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
        cache = @caches[key]
        cache[:semaphore].synchronize do
          cache[:result] = nil
          cache[:condition].broadcast
        end
      end

      schedule(key)
    end

    def schedule(key, time = Time.now)
      return unless @running

      @pool.schedule(key, time) do
        discover(key)
      end
    end

    def discover(key)
      cache = @caches[key]

      @logger.debug("[#{@interval} second interval] Starting view model #{key} discovery...")

      start = Time.now

      result_cache = cache[:view_model_factory].items

      finish = Time.now

      connected = result_cache[:connected]

      cache[:semaphore].synchronize do
        @logger.debug("Caching view model #{key} data. Compilation time: #{finish - start} seconds")

        # Only replace the cached result if the value is connected or this is the first time
        cache[:result] = result_cache if connected || cache[:result].nil?

        cache[:condition].broadcast
      end

      # If not a connected new value, reschedule the discovery soon
      interval = @interval
      interval = 10 if interval > 10 && connected == false

      # Set up the next scheduled discovery for this key
      schedule(key, Time.now + interval)
    end

    def disconnected_result
      {
        connected: false,
        items:     []
      }
    end

    def result_cache(key)
      cache = @caches[key]
      cache[:semaphore].synchronize do
        cache[:condition].wait(cache[:semaphore]) while @testing && @running && cache[:result].nil?
        return disconnected_result if cache[:result].nil?

        cache[:result]
      end
    end

    def details(key, hash_key)
      detail_hash = result_cache(key)[:detail_hash]
      return detail_hash[hash_key] if detail_hash
    end
  end
end
