require 'date'
require 'sequel'
require_relative 'scheduled_thread_pool'

module AdminUI
  class CC
    def initialize(config, logger, testing)
      @config  = config
      @logger  = logger
      @testing = testing

      @running = true

      # TODO: Need config for number of connections/threads
      # SQLite for testing does not appear to work well with multiple connections
      @max_connections = testing ? 1 : 4

      @pool = AdminUI::ScheduledThreadPool.new(logger, @max_connections, -2)

      ccdb_uri  = @config.ccdb_uri
      uaadb_uri = @config.uaadb_uri

      # rubocop:disable Layout/HashAlignment
      @caches =
        {
          application_annotations:
          {
            db_uri:  ccdb_uri,
            table:   :app_annotations,
            columns: %i[created_at guid id key key_prefix resource_guid updated_at value]
          },
          application_labels:
          {
            db_uri:  ccdb_uri,
            table:   :app_labels,
            columns: %i[created_at guid id key_name key_prefix resource_guid updated_at value]
          },
          applications:
          {
            db_uri:  ccdb_uri,
            table:   :apps,
            columns: %i[created_at desired_state droplet_guid enable_ssh guid id max_task_sequence_id name revisions_enabled space_guid updated_at]
          },
          approvals:
          {
            db_uri:  uaadb_uri,
            table:   :authz_approvals,
            columns: %i[client_id expiresat identity_zone_id lastmodifiedat scope status user_id]
          },
          buildpack_annotations:
          {
            db_uri:  ccdb_uri,
            table:   :buildpack_annotations,
            columns: %i[created_at guid id key key_prefix resource_guid updated_at value]
          },
          buildpack_labels:
          {
            db_uri:  ccdb_uri,
            table:   :buildpack_labels,
            columns: %i[created_at guid id key_name key_prefix resource_guid updated_at value]
          },
          buildpacks:
          {
            db_uri:  ccdb_uri,
            table:   :buildpacks,
            columns: %i[created_at enabled filename guid id key locked name position stack updated_at]
          },
          buildpack_lifecycle_data:
          {
            db_uri:  ccdb_uri,
            table:   :buildpack_lifecycle_data,
            columns: %i[app_guid created_at guid id stack]
          },
          clients:
          {
            db_uri:  uaadb_uri,
            table:   :oauth_client_details,
            columns: %i[access_token_validity additional_information app_launch_url authorities authorized_grant_types autoapprove client_id identity_zone_id lastmodified refresh_token_validity required_user_groups scope show_on_home_page web_server_redirect_uri]
          },
          domain_annotations:
          {
            db_uri:  ccdb_uri,
            table:   :domain_annotations,
            columns: %i[created_at guid id key key_prefix resource_guid updated_at value]
          },
          domain_labels:
          {
            db_uri:  ccdb_uri,
            table:   :domain_labels,
            columns: %i[created_at guid id key_name key_prefix resource_guid updated_at value]
          },
          domains:
          {
            db_uri:  ccdb_uri,
            table:   :domains,
            columns: %i[created_at guid id internal name owning_organization_id updated_at]
          },
          droplets:
          {
            db_uri:  ccdb_uri,
            table:   :droplets,
            columns: %i[app_guid buildpack_receipt_detect_output buildpack_receipt_buildpack buildpack_receipt_buildpack_guid created_at droplet_hash error_description error_id execution_metadata guid id package_guid process_types staging_disk_in_mb staging_memory_in_mb state updated_at]
          },
          env_groups:
          {
            db_uri:  ccdb_uri,
            table:   :env_groups,
            columns: %i[created_at guid id name updated_at]
          },
          events:
          {
            db_uri:  ccdb_uri,
            table:   :events,
            columns: %i[actee actee_name actee_type actor actor_name actor_type actor_username created_at guid id metadata organization_guid space_guid timestamp type updated_at],
            where:   "timestamp >= CURRENT_TIMESTAMP - INTERVAL '#{@config.event_days}' DAY"
          },
          feature_flags:
          {
            db_uri:  ccdb_uri,
            table:   :feature_flags,
            columns: %i[created_at enabled error_message guid id name updated_at]
          },
          groups:
          {
            db_uri:  uaadb_uri,
            table:   :groups,
            columns: %i[created description displayname id identity_zone_id lastmodified version]
          },
          group_membership:
          {
            db_uri:  uaadb_uri,
            table:   :group_membership,
            columns: %i[added group_id id identity_zone_id member_id]
          },
          identity_providers:
          {
            db_uri:  uaadb_uri,
            table:   :identity_provider,
            columns: %i[active config created id identity_zone_id lastmodified name origin_key type version]
          },
          identity_zones:
          {
            db_uri:  uaadb_uri,
            table:   :identity_zone,
            columns: %i[active config created description id lastmodified name subdomain version]
          },
          isolation_segment_annotations:
          {
            db_uri:  ccdb_uri,
            table:   :isolation_segment_annotations,
            columns: %i[created_at guid id key key_prefix resource_guid updated_at value]
          },
          isolation_segment_labels:
          {
            db_uri:  ccdb_uri,
            table:   :isolation_segment_labels,
            columns: %i[created_at guid id key_name key_prefix resource_guid updated_at value]
          },
          isolation_segments:
          {
            db_uri:  ccdb_uri,
            table:   :isolation_segments,
            columns: %i[created_at guid id name updated_at]
          },
          mfa_providers:
          {
            db_uri:  uaadb_uri,
            table:   :mfa_providers,
            columns: %i[config created id identity_zone_id lastmodified name type]
          },
          organization_annotations:
          {
            db_uri:  ccdb_uri,
            table:   :organization_annotations,
            columns: %i[created_at guid id key key_prefix resource_guid updated_at value]
          },
          organization_labels:
          {
            db_uri:  ccdb_uri,
            table:   :organization_labels,
            columns: %i[created_at guid id key_name key_prefix resource_guid updated_at value]
          },
          organizations:
          {
            db_uri:  ccdb_uri,
            table:   :organizations,
            columns: %i[billing_enabled created_at default_isolation_segment_guid guid id name quota_definition_id status updated_at]
          },
          organizations_auditors:
          {
            db_uri:  ccdb_uri,
            table:   :organizations_auditors,
            columns: %i[created_at organizations_auditors_pk organization_id role_guid updated_at user_id]
          },
          organizations_billing_managers:
          {
            db_uri:  ccdb_uri,
            table:   :organizations_billing_managers,
            columns: %i[created_at organizations_billing_managers_pk organization_id role_guid updated_at user_id]
          },
          organizations_isolation_segments:
          {
            db_uri:  ccdb_uri,
            table:   :organizations_isolation_segments,
            columns: %i[isolation_segment_guid organization_guid]
          },
          organizations_managers:
          {
            db_uri:  ccdb_uri,
            table:   :organizations_managers,
            columns: %i[created_at organizations_managers_pk organization_id role_guid updated_at user_id]
          },
          organizations_private_domains:
          {
            db_uri:  ccdb_uri,
            table:   :organizations_private_domains,
            columns: %i[organizations_private_domains_pk organization_id private_domain_id]
          },
          organizations_users:
          {
            db_uri:  ccdb_uri,
            table:   :organizations_users,
            columns: %i[created_at organizations_users_pk organization_id role_guid updated_at user_id]
          },
          packages:
          {
            db_uri:  ccdb_uri,
            table:   :packages,
            columns: %i[app_guid created_at docker_image error guid id package_hash state type updated_at]
          },
          processes:
          {
            db_uri:  ccdb_uri,
            table:   :processes,
            columns: %i[app_guid command created_at detected_buildpack diego disk_quota enable_ssh file_descriptors guid health_check_http_endpoint health_check_invocation_timeout health_check_timeout health_check_type id instances memory metadata package_updated_at ports production state type updated_at version]
          },
          quota_definitions:
          {
            db_uri:  ccdb_uri,
            table:   :quota_definitions,
            columns: %i[app_instance_limit app_task_limit created_at guid id instance_memory_limit memory_limit name non_basic_services_allowed total_private_domains total_reserved_route_ports total_routes total_services total_service_keys updated_at]
          },
          request_counts:
          {
            db_uri:  ccdb_uri,
            table:   :request_counts,
            columns: %i[count id user_guid valid_until]
          },
          revocable_tokens:
          {
            db_uri:  uaadb_uri,
            table:   :revocable_tokens,
            columns: %i[client_id expires_at format identity_zone_id issued_at response_type scope token_id user_id]
          },
          route_annotations:
          {
            db_uri:  ccdb_uri,
            table:   :route_annotations,
            columns: %i[created_at guid id key key_prefix resource_guid updated_at value]
          },
          route_bindings:
          {
            db_uri:  ccdb_uri,
            table:   :route_bindings,
            columns: %i[created_at guid id route_id route_service_url service_instance_id updated_at]
          },
          route_binding_annotations:
          {
            db_uri:  ccdb_uri,
            table:   :route_binding_annotations,
            columns: %i[created_at guid id key key_prefix resource_guid updated_at value]
          },
          route_binding_labels:
          {
            db_uri:  ccdb_uri,
            table:   :route_binding_labels,
            columns: %i[created_at guid id key_name key_prefix resource_guid updated_at value]
          },
          route_binding_operations:
          {
            db_uri:  ccdb_uri,
            table:   :route_binding_operations,
            columns: %i[broker_provided_operation created_at description id route_binding_id state type updated_at]
          },
          route_labels:
          {
            db_uri:  ccdb_uri,
            table:   :route_labels,
            columns: %i[created_at guid id key_name key_prefix resource_guid updated_at value]
          },
          route_mappings:
          {
            db_uri:  ccdb_uri,
            table:   :route_mappings,
            columns: %i[app_guid app_port created_at guid id process_type route_guid updated_at weight]
          },
          routes:
          {
            db_uri:  ccdb_uri,
            table:   :routes,
            columns: %i[created_at domain_id guid host id path port space_id updated_at vip_offset]
          },
          security_groups:
          {
            db_uri:  ccdb_uri,
            table:   :security_groups,
            columns: %i[created_at guid id name rules running_default staging_default updated_at]
          },
          security_groups_spaces:
          {
            db_uri:  ccdb_uri,
            table:   :security_groups_spaces,
            columns: %i[security_groups_spaces_pk security_group_id space_id]
          },
          service_bindings:
          {
            db_uri:  ccdb_uri,
            table:   :service_bindings,
            columns: %i[app_guid created_at guid id name service_instance_guid syslog_drain_url updated_at]
          },
          service_binding_annotations:
          {
            db_uri:  ccdb_uri,
            table:   :service_binding_annotations,
            columns: %i[created_at guid id key key_prefix resource_guid updated_at value]
          },
          service_binding_labels:
          {
            db_uri:  ccdb_uri,
            table:   :service_binding_labels,
            columns: %i[created_at guid id key_name key_prefix resource_guid updated_at value]
          },

          service_binding_operations:
          {
            db_uri:  ccdb_uri,
            table:   :service_binding_operations,
            columns: %i[broker_provided_operation created_at description id service_binding_id state type updated_at]
          },
          service_broker_annotations:
          {
            db_uri:  ccdb_uri,
            table:   :service_broker_annotations,
            columns: %i[created_at guid id key key_prefix resource_guid updated_at value]
          },
          service_broker_labels:
          {
            db_uri:  ccdb_uri,
            table:   :service_broker_labels,
            columns: %i[created_at guid id key_name key_prefix resource_guid updated_at value]
          },
          service_brokers:
          {
            db_uri:  ccdb_uri,
            table:   :service_brokers,
            columns: %i[auth_username broker_url created_at guid id name space_id state updated_at]
          },
          service_dashboard_clients:
          {
            db_uri:  ccdb_uri,
            table:   :service_dashboard_clients,
            columns: %i[service_broker_id uaa_id]
          },
          service_instances:
          {
            db_uri:  ccdb_uri,
            table:   :service_instances,
            columns: %i[created_at dashboard_url gateway_name gateway_data guid id is_gateway_service maintenance_info name route_service_url service_plan_id space_id syslog_drain_url tags updated_at]
          },
          service_instance_annotations:
          {
            db_uri:  ccdb_uri,
            table:   :service_instance_annotations,
            columns: %i[created_at guid id key key_prefix resource_guid updated_at value]
          },
          service_instance_labels:
          {
            db_uri:  ccdb_uri,
            table:   :service_instance_labels,
            columns: %i[created_at guid id key_name key_prefix resource_guid updated_at value]
          },
          service_instance_operations:
          {
            db_uri:  ccdb_uri,
            table:   :service_instance_operations,
            columns: %i[broker_provided_operation created_at description guid id proposed_changes service_instance_id state type updated_at]
          },
          service_instance_shares:
          {
            db_uri:  ccdb_uri,
            table:   :service_instance_shares,
            columns: %i[service_instance_guid target_space_guid]
          },
          service_keys:
          {
            db_uri:  ccdb_uri,
            table:   :service_keys,
            columns: %i[created_at guid id name service_instance_id updated_at]
          },
          service_key_annotations:
          {
            db_uri:  ccdb_uri,
            table:   :service_key_annotations,
            columns: %i[created_at guid id key key_prefix resource_guid updated_at value]
          },
          service_key_labels:
          {
            db_uri:  ccdb_uri,
            table:   :service_key_labels,
            columns: %i[created_at guid id key_name key_prefix resource_guid updated_at value]
          },

          service_key_operations:
          {
            db_uri:  ccdb_uri,
            table:   :service_key_operations,
            columns: %i[broker_provided_operation created_at description id service_key_id state type updated_at]
          },
          service_offering_annotations:
          {
            db_uri:  ccdb_uri,
            table:   :service_offering_annotations,
            columns: %i[created_at guid id key key_prefix resource_guid updated_at value]
          },
          service_offering_labels:
          {
            db_uri:  ccdb_uri,
            table:   :service_offering_labels,
            columns: %i[created_at guid id key_name key_prefix resource_guid updated_at value]
          },
          service_plans:
          {
            db_uri:  ccdb_uri,
            table:   :service_plans,
            columns: %i[active bindable created_at create_binding_schema create_instance_schema description extra free guid id maintenance_info maximum_polling_duration name plan_updateable public service_id unique_id updated_at update_instance_schema]
          },
          service_plan_annotations:
          {
            db_uri:  ccdb_uri,
            table:   :service_plan_annotations,
            columns: %i[created_at guid id key key_prefix resource_guid updated_at value]
          },
          service_plan_labels:
          {
            db_uri:  ccdb_uri,
            table:   :service_plan_labels,
            columns: %i[created_at guid id key_name key_prefix resource_guid updated_at value]
          },
          service_plan_visibilities:
          {
            db_uri:  ccdb_uri,
            table:   :service_plan_visibilities,
            columns: %i[created_at guid id organization_id service_plan_id updated_at]
          },
          service_providers:
          {
            db_uri:  uaadb_uri,
            table:   :service_provider,
            columns: %i[active created entity_id id identity_zone_id lastmodified name version]
          },
          services:
          {
            db_uri:  ccdb_uri,
            table:   :services,
            columns: %i[active allow_context_updates bindable bindings_retrievable created_at description extra guid id instances_retrievable label plan_updateable purging requires service_broker_id tags unique_id updated_at]
          },
          space_annotations:
          {
            db_uri:  ccdb_uri,
            table:   :space_annotations,
            columns: %i[created_at guid id key key_prefix resource_guid updated_at value]
          },
          space_labels:
          {
            db_uri:  ccdb_uri,
            table:   :space_labels,
            columns: %i[created_at guid id key_name key_prefix resource_guid updated_at value]
          },
          space_quota_definitions:
          {
            db_uri:  ccdb_uri,
            table:   :space_quota_definitions,
            columns: %i[app_instance_limit app_task_limit created_at guid id instance_memory_limit memory_limit name non_basic_services_allowed organization_id total_reserved_route_ports total_routes total_services total_service_keys updated_at]
          },
          spaces:
          {
            db_uri:  ccdb_uri,
            table:   :spaces,
            columns: %i[allow_ssh created_at guid id isolation_segment_guid name organization_id space_quota_definition_id updated_at]
          },
          spaces_auditors:
          {
            db_uri:  ccdb_uri,
            table:   :spaces_auditors,
            columns: %i[created_at role_guid spaces_auditors_pk space_id updated_at user_id]
          },
          spaces_developers:
          {
            db_uri:  ccdb_uri,
            table:   :spaces_developers,
            columns: %i[created_at role_guid spaces_developers_pk space_id updated_at user_id]
          },
          spaces_managers:
          {
            db_uri:  ccdb_uri,
            table:   :spaces_managers,
            columns: %i[created_at role_guid spaces_managers_pk space_id updated_at user_id]
          },
          stack_annotations:
          {
            db_uri:  ccdb_uri,
            table:   :stack_annotations,
            columns: %i[created_at guid id key key_prefix resource_guid updated_at value]
          },
          stack_labels:
          {
            db_uri:  ccdb_uri,
            table:   :stack_labels,
            columns: %i[created_at guid id key_name key_prefix resource_guid updated_at value]
          },
          stacks:
          {
            db_uri:  ccdb_uri,
            table:   :stacks,
            columns: %i[created_at description guid id name updated_at]
          },
          staging_security_groups_spaces:
          {
            db_uri:  ccdb_uri,
            table:   :staging_security_groups_spaces,
            columns: %i[staging_security_groups_spaces_pk staging_security_group_id staging_space_id]
          },
          task_annotations:
          {
            db_uri:  ccdb_uri,
            table:   :task_annotations,
            columns: %i[created_at guid id key key_prefix resource_guid updated_at value]
          },
          task_labels:
          {
            db_uri:  ccdb_uri,
            table:   :task_labels,
            columns: %i[created_at guid id key_name key_prefix resource_guid updated_at value]
          },
          tasks:
          {
            db_uri:  ccdb_uri,
            table:   :tasks,
            columns: %i[app_guid command created_at disk_in_mb droplet_guid failure_reason guid id memory_in_mb name sequence_id state updated_at]
          },
          user_annotations:
          {
            db_uri:  ccdb_uri,
            table:   :user_annotations,
            columns: %i[created_at guid id key key_prefix resource_guid updated_at value]
          },
          user_labels:
          {
            db_uri:  ccdb_uri,
            table:   :user_labels,
            columns: %i[created_at guid id key_name key_prefix resource_guid updated_at value]
          },
          users_cc:
          {
            db_uri:  ccdb_uri,
            table:   :users,
            columns: %i[active admin created_at default_space_id guid id updated_at]
          },
          users_uaa:
          {
            db_uri:  uaadb_uri,
            table:   :users,
            columns: %i[active created email familyname givenname id identity_zone_id lastmodified last_logon_success_time passwd_change_required passwd_lastmodified phonenumber previous_logon_success_time username verified version]
          }
        }
      # rubocop:enable Layout/HashAlignment

      @caches.each_pair do |key, cache|
        cache[:condition] = ConditionVariable.new
        cache[:exists]    = nil
        cache[:result]    = nil
        cache[:select]    = nil
        cache[:semaphore] = Mutex.new

        schedule(key)
      end
    end

    def application_annotations
      result_cache(:application_annotations)
    end

    def application_labels
      result_cache(:application_labels)
    end

    def applications
      result_cache(:applications)
    end

    def applications_count
      hash = applications
      return nil unless hash['connected']

      hash['items'].length
    end

    def approvals
      result_cache(:approvals)
    end

    def buildpack_annotations
      result_cache(:buildpack_annotations)
    end

    def buildpack_labels
      result_cache(:buildpack_labels)
    end

    def buildpacks
      result_cache(:buildpacks)
    end

    def buildpack_lifecycle_data
      result_cache(:buildpack_lifecycle_data)
    end

    def clients
      result_cache(:clients)
    end

    def domain_annotations
      result_cache(:domain_annotations)
    end

    def domain_labels
      result_cache(:domain_labels)
    end

    def domains
      result_cache(:domains)
    end

    def droplets
      result_cache(:droplets)
    end

    def env_groups
      result_cache(:env_groups)
    end

    def events
      result_cache(:events)
    end

    def feature_flags
      result_cache(:feature_flags)
    end

    def group_membership
      result_cache(:group_membership)
    end

    def groups
      result_cache(:groups)
    end

    def identity_providers
      result_cache(:identity_providers)
    end

    def identity_zones
      result_cache(:identity_zones)
    end

    def invalidate_application_annotations
      invalidate_cache(:application_annotations)
    end

    def invalidate_application_labels
      invalidate_cache(:application_labels)
    end

    def invalidate_applications
      invalidate_cache(:applications)
    end

    def invalidate_approvals
      invalidate_cache(:approvals)
    end

    def invalidate_buildpack_annotations
      invalidate_cache(:buildpack_annotations)
    end

    def invalidate_buildpack_labels
      invalidate_cache(:buildpack_labels)
    end

    def invalidate_buildpacks
      invalidate_cache(:buildpacks)
    end

    def invalidate_clients
      invalidate_cache(:clients)
    end

    def invalidate_domain_annotations
      invalidate_cache(:domain_annotations)
    end

    def invalidate_domain_labels
      invalidate_cache(:domain_labels)
    end

    def invalidate_domains
      invalidate_cache(:domains)
    end

    def invalidate_droplets
      invalidate_cache(:droplets)
    end

    def invalidate_feature_flags
      invalidate_cache(:feature_flags)
    end

    def invalidate_groups
      invalidate_cache(:groups)
    end

    def invalidate_group_membership
      invalidate_cache(:group_membership)
    end

    def invalidate_identity_providers
      invalidate_cache(:identity_providers)
    end

    def invalidate_identity_zones
      invalidate_cache(:identity_zones)
    end

    def invalidate_isolation_segment_annotations
      invalidate_cache(:isolation_segment_annotations)
    end

    def invalidate_isolation_segment_labels
      invalidate_cache(:isolation_segment_labels)
    end

    def invalidate_isolation_segments
      invalidate_cache(:isolation_segments)
    end

    def invalidate_mfa_providers
      invalidate_cache(:mfa_providers)
    end

    def invalidate_organization_annotations
      invalidate_cache(:organization_annotations)
    end

    def invalidate_organization_labels
      invalidate_cache(:organization_labels)
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

    def invalidate_organizations_isolation_segments
      invalidate_cache(:organizations_isolation_segments)
    end

    def invalidate_organizations_managers
      invalidate_cache(:organizations_managers)
    end

    def invalidate_organizations_private_domains
      invalidate_cache(:organizations_private_domains)
    end

    def invalidate_organizations_users
      invalidate_cache(:organizations_users)
    end

    def invalidate_packages
      invalidate_cache(:packages)
    end

    def invalidate_processes
      invalidate_cache(:processes)
    end

    def invalidate_revocable_tokens
      invalidate_cache(:revocable_tokens)
    end

    def invalidate_route_annotations
      invalidate_cache(:route_annotations)
    end

    def invalidate_route_binding_annotations
      invalidate_cache(:route_binding_annotations)
    end

    def invalidate_route_binding_labels
      invalidate_cache(:route_binding_labels)
    end

    def invalidate_route_bindings
      invalidate_cache(:route_bindings)
    end

    def invalidate_route_labels
      invalidate_cache(:route_labels)
    end

    def invalidate_route_mappings
      invalidate_cache(:route_mappings)
    end

    def invalidate_routes
      invalidate_cache(:routes)
    end

    def invalidate_quota_definitions
      invalidate_cache(:quota_definitions)
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

    def invalidate_service_binding_annotations
      invalidate_cache(:service_binding_annotations)
    end

    def invalidate_service_binding_labels
      invalidate_cache(:service_binding_labels)
    end

    def invalidate_service_broker_annotations
      invalidate_cache(:service_broker_annotations)
    end

    def invalidate_service_broker_labels
      invalidate_cache(:service_broker_labels)
    end

    def invalidate_service_brokers
      invalidate_cache(:service_brokers)
    end

    def invalidate_service_instances
      invalidate_cache(:service_instances)
    end

    def invalidate_service_instance_annotations
      invalidate_cache(:service_instance_annotations)
    end

    def invalidate_service_instance_labels
      invalidate_cache(:service_instance_labels)
    end

    def invalidate_service_instance_shares
      invalidate_cache(:service_instance_shares)
    end

    def invalidate_service_keys
      invalidate_cache(:service_keys)
    end

    def invalidate_service_key_annotations
      invalidate_cache(:service_key_annotations)
    end

    def invalidate_service_key_labels
      invalidate_cache(:service_key_labels)
    end

    def invalidate_service_offering_annotations
      invalidate_cache(:service_offering_annotations)
    end

    def invalidate_service_offering_labels
      invalidate_cache(:service_offering_labels)
    end

    def invalidate_service_plan_annotations
      invalidate_cache(:service_plan_annotations)
    end

    def invalidate_service_plan_labels
      invalidate_cache(:service_plan_labels)
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

    def invalidate_service_plan_visibilities
      invalidate_cache(:service_plan_visibilities)
    end

    def invalidate_space_annotations
      invalidate_cache(:space_annotations)
    end

    def invalidate_space_labels
      invalidate_cache(:space_labels)
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

    def invalidate_stack_annotations
      invalidate_cache(:stack_annotations)
    end

    def invalidate_stack_labels
      invalidate_cache(:stack_labels)
    end

    def invalidate_stacks
      invalidate_cache(:stacks)
    end

    def invalidate_staging_security_groups_spaces
      invalidate_cache(:staging_security_groups_spaces)
    end

    def invalidate_task_annotations
      invalidate_cache(:task_annotations)
    end

    def invalidate_task_labels
      invalidate_cache(:task_labels)
    end

    def invalidate_tasks
      invalidate_cache(:tasks)
    end

    def invalidate_user_annotations
      invalidate_cache(:user_annotations)
    end

    def invalidate_user_labels
      invalidate_cache(:user_labels)
    end

    def invalidate_users_cc
      invalidate_cache(:users_cc)
    end

    def invalidate_users_uaa
      invalidate_cache(:users_uaa)
    end

    def isolation_segment_annotations
      result_cache(:isolation_segment_annotations)
    end

    def isolation_segment_labels
      result_cache(:isolation_segment_labels)
    end

    def isolation_segments
      result_cache(:isolation_segments)
    end

    def mfa_providers
      result_cache(:mfa_providers)
    end

    def organization_annotations
      result_cache(:organization_annotations)
    end

    def organization_labels
      result_cache(:organization_labels)
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

    def organizations_isolation_segments
      result_cache(:organizations_isolation_segments)
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

    def packages
      result_cache(:packages)
    end

    def processes
      result_cache(:processes)
    end

    def processes_running_instances
      hash = processes
      return nil unless hash['connected']

      instances = 0
      hash['items'].each do |process|
        break unless @running

        Thread.pass

        instances += process[:instances] if process[:state] == 'STARTED'
      end
      instances
    end

    def processes_total_instances
      hash = processes
      return nil unless hash['connected']

      instances = 0
      hash['items'].each do |process|
        break unless @running

        Thread.pass

        instances += process[:instances]
      end
      instances
    end

    def quota_definitions
      result_cache(:quota_definitions)
    end

    def request_counts
      result_cache(:request_counts)
    end

    def revocable_tokens
      result_cache(:revocable_tokens)
    end

    def route_annotations
      result_cache(:route_annotations)
    end

    def route_binding_annotations
      result_cache(:route_binding_annotations)
    end

    def route_binding_labels
      result_cache(:route_binding_labels)
    end

    def route_binding_operations
      result_cache(:route_binding_operations)
    end

    def route_bindings
      result_cache(:route_bindings)
    end

    def route_labels
      result_cache(:route_labels)
    end

    def route_mappings
      result_cache(:route_mappings)
    end

    def routes
      result_cache(:routes)
    end

    def security_groups
      result_cache(:security_groups)
    end

    def security_groups_spaces
      result_cache(:security_groups_spaces)
    end

    def service_binding_annotations
      result_cache(:service_binding_annotations)
    end

    def service_binding_labels
      result_cache(:service_binding_labels)
    end

    def service_binding_operations
      result_cache(:service_binding_operations)
    end

    def service_bindings
      result_cache(:service_bindings)
    end

    def service_broker_annotations
      result_cache(:service_broker_annotations)
    end

    def service_broker_labels
      result_cache(:service_broker_labels)
    end

    def service_brokers
      result_cache(:service_brokers)
    end

    def service_dashboard_clients
      result_cache(:service_dashboard_clients)
    end

    def service_instance_annotations
      result_cache(:service_instance_annotations)
    end

    def service_instance_labels
      result_cache(:service_instance_labels)
    end

    def service_instance_operations
      result_cache(:service_instance_operations)
    end

    def service_instance_shares
      result_cache(:service_instance_shares)
    end

    def service_instances
      result_cache(:service_instances)
    end

    def service_key_annotations
      result_cache(:service_key_annotations)
    end

    def service_key_labels
      result_cache(:service_key_labels)
    end

    def service_key_operations
      result_cache(:service_key_operations)
    end

    def service_keys
      result_cache(:service_keys)
    end

    def service_offering_annotations
      result_cache(:service_offering_annotations)
    end

    def service_offering_labels
      result_cache(:service_offering_labels)
    end

    def service_plan_annotations
      result_cache(:service_plan_annotations)
    end

    def service_plan_labels
      result_cache(:service_plan_labels)
    end

    def service_plans
      result_cache(:service_plans)
    end

    def service_plan_visibilities
      result_cache(:service_plan_visibilities)
    end

    def service_providers
      result_cache(:service_providers)
    end

    def services
      result_cache(:services)
    end

    def shutdown
      return unless @running

      @running = false

      @caches.each_value do |cache|
        cache[:semaphore].synchronize do
          cache[:condition].broadcast
        end
      end

      @pool.shutdown
    end

    def join
      @pool.join
    end

    def space_annotations
      result_cache(:space_annotations)
    end

    def space_labels
      result_cache(:space_labels)
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

    def stack_annotations
      result_cache(:stack_annotations)
    end

    def stack_labels
      result_cache(:stack_labels)
    end

    def stacks
      result_cache(:stacks)
    end

    def staging_security_groups_spaces
      result_cache(:staging_security_groups_spaces)
    end

    def task_annotations
      result_cache(:task_annotations)
    end

    def task_labels
      result_cache(:task_labels)
    end

    def tasks
      result_cache(:tasks)
    end

    def user_annotations
      result_cache(:user_annotations)
    end

    def user_labels
      result_cache(:user_labels)
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
      cache = @caches[key]

      @logger.debug("[#{@config.cloud_controller_discovery_interval} second interval] Starting CC #{key} discovery...")

      start = Time.now

      result_cache = select(key, cache)

      finish = Time.now

      cache[:semaphore].synchronize do
        @logger.debug("Caching CC #{key} data. Count: #{result_cache['items'].length}. Retrieval time: #{finish - start} seconds")
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
        cache[:condition].broadcast
      end

      schedule(key)
    end

    def schedule(key, time = Time.now)
      return unless @running

      @pool.schedule(key, time) do
        discover(key)
      end
    end

    def result_cache(key)
      cache = @caches[key]

      cache[:semaphore].synchronize do
        cache[:condition].wait(cache[:semaphore]) while @testing && @running && cache[:result].nil?
        return result if cache[:result].nil?

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
              statement      = connection[table].select(*(columns & db_columns))
              statement      = statement.where(Sequel.lit(cache[:where])) if cache[:where] && !@testing
              cache[:select] = statement.sql

              @logger.debug("Select for key #{key}, table #{table}: #{cache[:select]}")
              @logger.debug("Columns removed for key #{key}, table #{table}: #{columns - db_columns}")
              @logger.debug("Columns available, but not consumed for key #{key}, table #{table}: #{db_columns - columns}")
            else
              begin
                # Test if the connection is valid
                connection.test_connection
                @logger.warn("Table #{table} does not exist")
              rescue
                # In this case we think the table does not exist because we cannot connect to the database.
                # We want to try again on the next iteration in case the database becomes available
                cache[:exists] = nil
                @logger.error("Table #{table} existence cannot be determined due to invalid database connection")
              end
            end
          end

          # If the table exists
          if exists
            items = []
            connection.fetch(cache[:select]) do |row|
              return result unless @running

              Thread.pass

              items.push(row)
            end
            return result(items)
          end
        end
      end

      result
    rescue => error
      @logger.error("Error during discovery of #{key}: #{error.inspect}")
      @logger.error(error.backtrace.join("\n"))
      result
    end
  end
end
