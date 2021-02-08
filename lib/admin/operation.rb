require 'cgi'
require 'yajl'

module AdminUI
  class Operation
    def initialize(config, logger, cc, client, doppler, varz, view_models, testing)
      @cc          = cc
      @client      = client
      @config      = config
      @doppler     = doppler
      @logger      = logger
      @varz        = varz
      @view_models = view_models
      @testing     = testing
    end

    def cancel_task(task_guid)
      # As of cf-release 269 (API version 2.90.0), the protocol to cancel a task changed
      api_version = @client.api_version
      new_protocol = Gem::Version.new(api_version) >= Gem::Version.new('2.90.0')
      if new_protocol
        url = "/v3/tasks/#{task_guid}/actions/cancel"
        @logger.debug("POST #{url}")
        @client.post_cc(url, '{}')
      else
        url = "/v3/tasks/#{task_guid}/cancel"
        @logger.debug("PUT #{url}")
        @client.put_cc(url, '{}')
      end

      @cc.invalidate_tasks
      @view_models.invalidate_tasks
    end

    def create_isolation_segment(control_message)
      url = '/v3/isolation_segments'
      @logger.debug("POST #{url}, #{control_message}")
      @client.post_cc(url, control_message)
      @cc.invalidate_isolation_segments
      @view_models.invalidate_isolation_segments
    end

    def create_organization(control_message)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      url = if v3
              '/v3/organizations'
            else
              '/v2/organizations'
            end
      @logger.debug("POST #{url}, #{control_message}")
      @client.post_cc(url, control_message)
      @cc.invalidate_organizations
      @view_models.invalidate_organizations
    end

    def create_space_quota_definition_space(space_quota_definition_guid, space_guid)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      if v3
        url = "/v3/space_quotas/#{space_quota_definition_guid}/relationships/spaces"
        body = "{\"data\":[{\"guid\":\"#{space_guid}\"}]}"
        @logger.debug("POST #{url}, #{body}")
        @client.post_cc(url, body)
      else
        url = "/v2/space_quota_definitions/#{space_quota_definition_guid}/spaces/#{space_guid}"
        @logger.debug("PUT #{url}")
        @client.put_cc(url, '{}')
      end
      @cc.invalidate_spaces
      @view_models.invalidate_spaces
    end

    def delete_application(app_guid, recursive)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      if v3
        url = "/v3/apps/#{app_guid}"
      else
        url = "/v2/apps/#{app_guid}"
        url += '?recursive=true' if recursive
      end
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_applications
      @cc.invalidate_droplets
      @cc.invalidate_packages
      @cc.invalidate_processes
      @cc.invalidate_tasks
      @varz.invalidate
      if v3 || recursive
        @cc.invalidate_service_bindings
        @view_models.invalidate_service_bindings
      end
      @view_models.invalidate_applications
      @view_models.invalidate_application_instances
      @view_models.invalidate_tasks
    end

    def delete_application_annotation(application_guid, prefix, name)
      url = "/v3/apps/#{application_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"annotations\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_application_annotations
      @view_models.invalidate_applications
    end

    def delete_application_environment_variable(app_guid, environment_variable)
      api_version = @client.api_version
      new_protocol = Gem::Version.new(api_version) >= Gem::Version.new('2.92.0')
      url = "/v3/apps/#{app_guid}/environment_variables"
      body = "{\"#{environment_variable}\":null}"
      body = "{\"var\":#{body}" if new_protocol
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      # Since the application environment variables are fetched on a per-application-retrieval basis, no reason to invalidate.
    end

    def delete_application_instance(app_guid, instance_index)
      # TODO: v3 delete application instance
      url = "/v2/apps/#{app_guid}/instances/#{instance_index}"
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @doppler.testing_remove_container_metric(app_guid, instance_index) if @testing
      @varz.invalidate
      @view_models.invalidate_application_instances
    end

    def delete_application_label(application_guid, prefix, name)
      url = "/v3/apps/#{application_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"labels\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_application_labels
      @view_models.invalidate_applications
    end

    def delete_buildpack(buildpack_guid)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      url = if v3
              "/v3/buildpacks/#{buildpack_guid}"
            else
              "/v2/buildpacks/#{buildpack_guid}"
            end
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_buildpacks
      @view_models.invalidate_buildpacks
    end

    def delete_buildpack_annotation(buildpack_guid, prefix, name)
      url = "/v3/buildpacks/#{buildpack_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"annotations\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_buildpack_annotations
      @view_models.invalidate_buildpacks
    end

    def delete_buildpack_label(buildpack_guid, prefix, name)
      url = "/v3/buildpacks/#{buildpack_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"labels\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_buildpack_labels
      @view_models.invalidate_buildpacks
    end

    def delete_client(client_id)
      url = "/oauth/clients/#{CGI.escape(client_id)}"
      @logger.debug("DELETE #{url}")
      @client.delete_uaa(url)
      @cc.invalidate_approvals
      @cc.invalidate_clients
      @cc.invalidate_revocable_tokens
      @view_models.invalidate_clients
      @view_models.invalidate_revocable_tokens
    end

    def delete_client_tokens(client_id)
      url = "/oauth/token/revoke/client/#{CGI.escape(client_id)}"
      @logger.debug("GET #{url}")
      @client.get_uaa(url)
      @cc.invalidate_clients
      @cc.invalidate_revocable_tokens
      @view_models.invalidate_clients
      @view_models.invalidate_revocable_tokens
    end

    def delete_domain(domain_guid, is_shared, recursive)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      if v3
        url = "/v3/domains/#{domain_guid}"
      else
        url = is_shared ? "/v2/shared_domains/#{domain_guid}" : "/v2/private_domains/#{domain_guid}"
        url += '?recursive=true' if recursive
      end
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_domains
      if v3 || recursive
        @cc.invalidate_routes
        @cc.invalidate_route_mappings
        @view_models.invalidate_routes
        @view_models.invalidate_route_mappings
      end
      @view_models.invalidate_domains
    end

    def delete_domain_annotation(domain_guid, prefix, name)
      url = "/v3/domains/#{domain_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"annotations\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_domain_annotations
      @view_models.invalidate_domains
    end

    def delete_domain_label(domain_guid, prefix, name)
      url = "/v3/domains/#{domain_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"labels\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_domain_labels
      @view_models.invalidate_domains
    end

    def delete_group(group_guid)
      url = "/Groups/#{group_guid}"
      @logger.debug("DELETE #{url}")
      @client.delete_uaa(url)
      @cc.invalidate_approvals
      @cc.invalidate_groups
      @cc.invalidate_group_membership
      @view_models.invalidate_approvals
      @view_models.invalidate_groups
      @view_models.invalidate_group_members
    end

    def delete_group_member(group_guid, member_guid)
      url = "/Groups/#{group_guid}/members/#{member_guid}"
      @logger.debug("DELETE #{url}")
      @client.delete_uaa(url)
      @cc.invalidate_group_membership
      @view_models.invalidate_group_members
    end

    def delete_identity_provider(identity_provider_id)
      url = "/identity-providers/#{identity_provider_id}"
      @logger.debug("DELETE #{url}")
      @client.delete_uaa(url)
      @cc.invalidate_identity_providers
      @view_models.invalidate_identity_providers
    end

    def delete_identity_zone(identity_zone_id)
      url = "/identity-zones/#{CGI.escape(identity_zone_id)}"
      @logger.debug("DELETE #{url}")
      @client.delete_uaa(url)
      @cc.invalidate_approvals
      @cc.invalidate_clients
      @cc.invalidate_group_membership
      @cc.invalidate_groups
      @cc.invalidate_identity_providers
      @cc.invalidate_identity_zones
      @cc.invalidate_mfa_providers
      @cc.invalidate_revocable_tokens
      @cc.invalidate_service_providers
      @cc.invalidate_users_uaa
      @view_models.invalidate_approvals
      @view_models.invalidate_clients
      @view_models.invalidate_group_members
      @view_models.invalidate_groups
      @view_models.invalidate_identity_providers
      @view_models.invalidate_identity_zones
      @view_models.invalidate_mfa_providers
      @view_models.invalidate_revocable_tokens
      @view_models.invalidate_service_providers
      @view_models.invalidate_users
    end

    def delete_isolation_segment(isolation_segment_guid)
      url = "/v3/isolation_segments/#{isolation_segment_guid}"
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_isolation_segments
      @cc.invalidate_organizations_isolation_segments
      @view_models.invalidate_isolation_segments
      @view_models.invalidate_organizations_isolation_segments
    end

    def delete_isolation_segment_annotation(isolation_segment_guid, prefix, name)
      url = "/v3/isolation_segments/#{isolation_segment_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"annotations\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_isolation_segment_annotations
      @view_models.invalidate_isolation_segments
    end

    def delete_isolation_segment_label(isolation_segment_guid, prefix, name)
      url = "/v3/isolation_segments/#{isolation_segment_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"labels\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_isolation_segment_labels
      @view_models.invalidate_isolation_segments
    end

    def delete_mfa_provider(mfa_provider_id)
      url = "/mfa-providers/#{mfa_provider_id}"
      @logger.debug("DELETE #{url}")
      @client.delete_uaa(url)
      @cc.invalidate_mfa_providers
      @view_models.invalidate_mfa_providers
    end

    def delete_organization(organization_guid, recursive)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      if v3
        url = "/v3/organizations/#{organization_guid}"
      else
        url = "/v2/organizations/#{organization_guid}"
        url += '?recursive=true' if recursive
      end
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_organizations
      @cc.invalidate_organizations_auditors
      @cc.invalidate_organizations_billing_managers
      @cc.invalidate_organizations_managers
      @cc.invalidate_organizations_users
      @cc.invalidate_service_plan_visibilities
      if v3 || recursive
        @cc.invalidate_applications
        @cc.invalidate_droplets
        @cc.invalidate_packages
        @cc.invalidate_processes
        @cc.invalidate_routes
        @cc.invalidate_route_mappings
        @cc.invalidate_security_groups_spaces
        @cc.invalidate_service_instances
        @cc.invalidate_service_bindings
        @cc.invalidate_service_keys
        @cc.invalidate_service_brokers
        @cc.invalidate_space_quota_definitions
        @cc.invalidate_spaces
        @cc.invalidate_spaces_auditors
        @cc.invalidate_spaces_developers
        @cc.invalidate_spaces_managers
        @cc.invalidate_staging_security_groups_spaces
        @cc.invalidate_tasks
        @varz.invalidate
        @view_models.invalidate_applications
        @view_models.invalidate_application_instances
        @view_models.invalidate_routes
        @view_models.invalidate_route_mappings
        @view_models.invalidate_security_groups_spaces
        @view_models.invalidate_service_instances
        @view_models.invalidate_service_bindings
        @view_models.invalidate_service_keys
        @view_models.invalidate_service_brokers
        @view_models.invalidate_space_quotas
        @view_models.invalidate_spaces
        @view_models.invalidate_space_roles
        @view_models.invalidate_staging_security_groups_spaces
        @view_models.invalidate_tasks
      end
      @view_models.invalidate_organizations
      @view_models.invalidate_organization_roles
      @view_models.invalidate_service_plan_visibilities
    end

    def delete_organization_annotation(organization_guid, prefix, name)
      url = "/v3/organizations/#{organization_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"annotations\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_organization_annotations
      @view_models.invalidate_organizations
    end

    def delete_organization_isolation_segment(organization_guid, isolation_segment_guid)
      # As of cf-release 252 (API version 2.74.0), the protocol to delete an organization isolation segment changed
      api_version = @client.api_version
      new_protocol = Gem::Version.new(api_version) >= Gem::Version.new('2.74.0')
      if new_protocol
        url = "/v3/isolation_segments/#{isolation_segment_guid}/relationships/organizations/#{organization_guid}"
        @logger.debug("DELETE #{url}")
        @client.delete_cc(url)
      else
        url = "/v3/isolation_segments/#{isolation_segment_guid}/relationships/organizations"
        body = Yajl::Encoder.encode(data: [{ guid: organization_guid }])
        @logger.debug("DELETE #{url} #{body}")
        @client.delete_cc(url, body)
      end

      @cc.invalidate_organizations_isolation_segments
      @view_models.invalidate_organizations_isolation_segments
    end

    def delete_organization_label(organization_guid, prefix, name)
      url = "/v3/organizations/#{organization_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"labels\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_organization_labels
      @view_models.invalidate_organizations
    end

    def delete_organization_private_domain(organization_guid, domain_guid)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      url = if v3
              "/v3/domains/#{domain_guid}/relationships/shared_organizations/#{organization_guid}"
            else
              "/v2/organizations/#{organization_guid}/private_domains/#{domain_guid}"
            end
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_organizations_private_domains
      @view_models.invalidate_domains
    end

    def delete_organization_role(organization_guid, role_guid, role, user_guid)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      url = if v3
              "/v3/roles/#{role_guid}"
            else
              "/v2/organizations/#{organization_guid}/#{role}/#{user_guid}"
            end
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_organizations_auditors if role == 'auditors'
      @cc.invalidate_organizations_billing_managers if role == 'billing_managers'
      @cc.invalidate_organizations_managers if role == 'managers'
      @cc.invalidate_organizations_users if role == 'users'
      @view_models.invalidate_organization_roles
    end

    def delete_quota_definition(quota_definition_guid)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      url = if v3
              "/v3/organization_quotas/#{quota_definition_guid}"
            else
              "/v2/quota_definitions/#{quota_definition_guid}"
            end
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_quota_definitions
      @view_models.invalidate_quotas
    end

    def delete_revocable_token(token_id)
      url = "/oauth/token/revoke/#{token_id}"
      @logger.debug("DELETE #{url}")
      @client.delete_uaa(url)
      @cc.invalidate_revocable_tokens
      @view_models.invalidate_revocable_tokens
    end

    def delete_route(route_guid, recursive)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      if v3
        url = "/v3/routes/#{route_guid}"
      else
        url = "/v2/routes/#{route_guid}"
        url += '?recursive=true' if recursive
      end
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_routes
      if v3 || recursive
        @cc.invalidate_route_bindings
        @cc.invalidate_route_mappings
        @view_models.invalidate_route_bindings
        @view_models.invalidate_route_mappings
      end
      @view_models.invalidate_routes
    end

    def delete_route_annotation(route_guid, prefix, name)
      url = "/v3/routes/#{route_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"annotations\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_route_annotations
      @view_models.invalidate_routes
    end

    def delete_route_binding(service_instance_guid, route_guid, is_gateway_service)
      # TODO: v3 delete route binding
      url = is_gateway_service ? "/v2/service_instances/#{service_instance_guid}/routes/#{route_guid}" : "/v2/user_provided_service_instances/#{service_instance_guid}/routes/#{route_guid}"
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_route_bindings
      @view_models.invalidate_route_bindings
    end

    def delete_route_binding_annotation(service_instance_guid, prefix, name)
      url = "/v3/service_route_bindings/#{service_instance_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"annotations\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_route_binding_annotations
      @view_models.invalidate_route_bindings
    end

    def delete_route_binding_label(service_instance_guid, prefix, name)
      url = "/v3/service_route_bindings/#{service_instance_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"labels\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_route_binding_labels
      @view_models.invalidate_route_bindings
    end

    def delete_route_label(route_guid, prefix, name)
      url = "/v3/routes/#{route_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"labels\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_route_labels
      @view_models.invalidate_routes
    end

    def delete_route_mapping(route_mapping_guid, route_guid)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      url = if v3
              "/v3/routes/#{route_guid}/destinations/#{route_mapping_guid}"
            else
              "/v2/route_mappings/#{route_mapping_guid}"
            end
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_route_mappings
      @view_models.invalidate_route_mappings
    end

    def delete_security_group(security_group_guid)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      url = if v3
              "/v3/security_groups/#{security_group_guid}"
            else
              "/v2/security_groups/#{security_group_guid}"
            end
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_security_groups
      @cc.invalidate_security_groups_spaces
      @cc.invalidate_staging_security_groups_spaces
      @view_models.invalidate_security_groups
      @view_models.invalidate_security_groups_spaces
      @view_models.invalidate_staging_security_groups_spaces
    end

    def delete_security_group_space(security_group_guid, space_guid)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      url = if v3
              "/v3/security_groups/#{security_group_guid}/relationships/running_spaces/#{space_guid}"
            else
              "/v2/security_groups/#{security_group_guid}/spaces/#{space_guid}"
            end
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_security_groups_spaces
      @view_models.invalidate_security_groups_spaces
    end

    def delete_service(service_guid, purge)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      url = if v3
              "/v3/service_offerings/#{service_guid}"
            else
              "/v2/services/#{service_guid}"
            end
      url += '?purge=true' if purge
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_services
      @cc.invalidate_service_plans
      @cc.invalidate_service_plan_visibilities
      if purge
        @cc.invalidate_service_bindings
        @cc.invalidate_service_instances
        @cc.invalidate_service_keys
        @view_models.invalidate_service_bindings
        @view_models.invalidate_service_instances
        @view_models.invalidate_service_keys
      end
      @view_models.invalidate_services
      @view_models.invalidate_service_plans
      @view_models.invalidate_service_plan_visibilities
    end

    def delete_service_binding(service_binding_guid)
      # TODO: v3 delete service binding
      url = "/v2/service_bindings/#{service_binding_guid}?accepts_incomplete=true"
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_service_bindings
      @view_models.invalidate_service_bindings
    end

    def delete_service_binding_annotation(service_binding_guid, prefix, name)
      url = "/v3/service_credential_bindings/#{service_binding_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"annotations\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_service_binding_annotations
      @view_models.invalidate_service_bindings
    end

    def delete_service_binding_label(service_binding_guid, prefix, name)
      url = "/v3/service_credential_bindings/#{service_binding_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"labels\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_service_binding_labels
      @view_models.invalidate_service_bindings
    end

    def delete_service_broker(service_broker_guid)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      url = if v3
              "/v3/service_brokers/#{service_broker_guid}"
            else
              "/v2/service_brokers/#{service_broker_guid}"
            end
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_clients
      @cc.invalidate_services
      @cc.invalidate_service_brokers
      @cc.invalidate_service_plans
      @cc.invalidate_service_plan_visibilities
      @view_models.invalidate_services
      @view_models.invalidate_service_brokers
      @view_models.invalidate_service_plans
      @view_models.invalidate_service_plan_visibilities
    end

    def delete_service_broker_annotation(service_broker_guid, prefix, name)
      url = "/v3/service_brokers/#{service_broker_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"annotations\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_service_broker_annotations
      @view_models.invalidate_service_brokers
    end

    def delete_service_broker_label(service_broker_guid, prefix, name)
      url = "/v3/service_brokers/#{service_broker_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"labels\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_service_broker_labels
      @view_models.invalidate_service_brokers
    end

    def delete_service_instance(service_instance_guid, is_gateway_service, recursive, purge)
      # TODO: v3 delete service instance
      url = is_gateway_service ? "/v2/service_instances/#{service_instance_guid}?accepts_incomplete=true" : "/v2/user_provided_service_instances/#{service_instance_guid}"
      if recursive
        url += is_gateway_service ? '&' : '?'
        url += 'recursive=true'
        url += '&purge=true' if purge
      end
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_service_instances
      if recursive
        @cc.invalidate_service_bindings
        @cc.invalidate_service_keys
        @view_models.invalidate_service_bindings
        @view_models.invalidate_service_keys
      end
      @view_models.invalidate_service_instances
    end

    def delete_service_instance_annotation(service_instance_guid, prefix, name)
      url = "/v3/service_instances/#{service_instance_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"annotations\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_service_instance_annotations
      @view_models.invalidate_service_instances
    end

    def delete_service_instance_label(service_instance_guid, prefix, name)
      url = "/v3/service_instances/#{service_instance_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"labels\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_service_instance_labels
      @view_models.invalidate_service_instances
    end

    def delete_service_key(service_key_guid)
      # TODO: v3 delete service key
      url = "/v2/service_keys/#{service_key_guid}?accepts_incomplete=true"
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_service_keys
      @view_models.invalidate_service_keys
    end

    def delete_service_key_annotation(service_key_guid, prefix, name)
      url = "/v3/service_credential_bindings/#{service_key_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"annotations\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_service_key_annotations
      @view_models.invalidate_service_keys
    end

    def delete_service_key_label(service_key_guid, prefix, name)
      url = "/v3/service_credential_bindings/#{service_key_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"labels\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_service_key_labels
      @view_models.invalidate_service_keys
    end

    def delete_service_offering_annotation(service_offering_guid, prefix, name)
      url = "/v3/service_offerings/#{service_offering_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"annotations\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_service_offering_annotations
      @view_models.invalidate_services
    end

    def delete_service_offering_label(service_offering_guid, prefix, name)
      url = "/v3/service_offerings/#{service_offering_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"labels\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_service_offering_labels
      @view_models.invalidate_services
    end

    def delete_service_plan(service_plan_guid)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      url = if v3
              "/v3/service_plans/#{service_plan_guid}"
            else
              "/v2/service_plans/#{service_plan_guid}"
            end
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_service_plans
      @cc.invalidate_service_plan_visibilities
      @view_models.invalidate_service_plans
      @view_models.invalidate_service_plan_visibilities
    end

    def delete_service_plan_annotation(service_plan_guid, prefix, name)
      url = "/v3/service_plans/#{service_plan_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"annotations\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_service_plan_annotations
      @view_models.invalidate_service_plans
    end

    def delete_service_plan_label(service_plan_guid, prefix, name)
      url = "/v3/service_plans/#{service_plan_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"labels\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_service_plan_labels
      @view_models.invalidate_service_plans
    end

    def delete_service_plan_visibility(service_plan_visibility_guid, service_plan_guid, organization_guid)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      url = if v3
              "/v3/service_plans/#{service_plan_guid}/visibility/#{organization_guid}"
            else
              "/v2/service_plan_visibilities/#{service_plan_visibility_guid}"
            end
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_service_plan_visibilities
      @view_models.invalidate_service_plan_visibilities
    end

    def delete_service_provider(service_provider_id)
      url = "/saml/service-providers/#{service_provider_id}"
      @logger.debug("DELETE #{url}")
      @client.delete_uaa(url)
      @cc.invalidate_service_providers
      @view_models.invalidate_service_providers
    end

    def delete_shared_service_instance(service_instance_guid, target_space_guid)
      url = "/v3/service_instances/#{service_instance_guid}/relationships/shared_spaces/#{target_space_guid}"
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_service_instance_shares
      @view_models.invalidate_shared_service_instances
    end

    def delete_space(space_guid, recursive)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      if v3
        url = "/v3/spaces/#{space_guid}"
      else
        url = "/v2/spaces/#{space_guid}"
        url += '?recursive=true' if recursive
      end
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_security_groups_spaces
      @cc.invalidate_spaces
      @cc.invalidate_spaces_auditors
      @cc.invalidate_spaces_developers
      @cc.invalidate_spaces_managers
      @cc.invalidate_staging_security_groups_spaces
      if v3 || recursive
        @cc.invalidate_applications
        @cc.invalidate_droplets
        @cc.invalidate_packages
        @cc.invalidate_processes
        @cc.invalidate_routes
        @cc.invalidate_route_mappings
        @cc.invalidate_service_instances
        @cc.invalidate_service_bindings
        @cc.invalidate_service_keys
        @cc.invalidate_service_brokers
        @cc.invalidate_tasks
        @varz.invalidate
        @view_models.invalidate_applications
        @view_models.invalidate_application_instances
        @view_models.invalidate_routes
        @view_models.invalidate_route_mappings
        @view_models.invalidate_service_instances
        @view_models.invalidate_service_bindings
        @view_models.invalidate_service_keys
        @view_models.invalidate_service_brokers
        @view_models.invalidate_tasks
      end
      @view_models.invalidate_security_groups_spaces
      @view_models.invalidate_spaces
      @view_models.invalidate_space_roles
      @view_models.invalidate_staging_security_groups_spaces
    end

    def delete_space_annotation(space_guid, prefix, name)
      url = "/v3/spaces/#{space_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"annotations\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_space_annotations
      @view_models.invalidate_spaces
    end

    def delete_space_label(space_guid, prefix, name)
      url = "/v3/spaces/#{space_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"labels\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_space_labels
      @view_models.invalidate_spaces
    end

    def delete_space_quota_definition(space_quota_definition_guid)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      url = if v3
              "/v3/space_quotas/#{space_quota_definition_guid}"
            else
              "/v2/space_quota_definitions/#{space_quota_definition_guid}"
            end
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_space_quota_definitions
      @view_models.invalidate_space_quotas
    end

    def delete_space_quota_definition_space(space_quota_definition_guid, space_guid)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      url = if v3
              "/v3/space_quotas/#{space_quota_definition_guid}/relationships/spaces/#{space_guid}"
            else
              "/v2/space_quota_definitions/#{space_quota_definition_guid}/spaces/#{space_guid}"
            end
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_spaces
      @view_models.invalidate_spaces
    end

    def delete_space_role(space_guid, role_guid, role, user_guid)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      url = if v3
              "/v3/roles/#{role_guid}"
            else
              "/v2/spaces/#{space_guid}/#{role}/#{user_guid}"
            end
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_spaces_auditors if role == 'auditors'
      @cc.invalidate_spaces_developers if role == 'developers'
      @cc.invalidate_spaces_managers if role == 'managers'
      @view_models.invalidate_space_roles
    end

    def delete_space_unmapped_routes(space_guid)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      url = if v3
              "/v3/spaces/#{space_guid}/routes?unmapped=true"
            else
              "/v2/spaces/#{space_guid}/unmapped_routes"
            end
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_routes
      @cc.invalidate_spaces
      @view_models.invalidate_routes
      @view_models.invalidate_spaces
    end

    def delete_stack(stack_guid)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      url = if v3
              "/v3/stacks/#{stack_guid}"
            else
              "/v2/stacks/#{stack_guid}"
            end
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_stacks
      @view_models.invalidate_stacks
    end

    def delete_stack_annotation(stack_guid, prefix, name)
      url = "/v3/stacks/#{stack_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"annotations\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_stack_annotations
      @view_models.invalidate_stacks
    end

    def delete_stack_label(stack_guid, prefix, name)
      url = "/v3/stacks/#{stack_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"labels\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_stack_labels
      @view_models.invalidate_stacks
    end

    def delete_staging_security_group_space(staging_security_group_guid, staging_space_guid)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      url = if v3
              "/v3/security_groups/#{staging_security_group_guid}/relationships/staging_spaces/#{staging_space_guid}"
            else
              "/v2/security_groups/#{staging_security_group_guid}/staging_spaces/#{staging_space_guid}"
            end
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_staging_security_groups_spaces
      @view_models.invalidate_staging_security_groups_spaces
    end

    def delete_task_annotation(task_guid, prefix, name)
      url = "/v3/tasks/#{task_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"annotations\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_task_annotations
      @view_models.invalidate_tasks
    end

    def delete_task_label(task_guid, prefix, name)
      url = "/v3/tasks/#{task_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"labels\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_task_labels
      @view_models.invalidate_tasks
    end

    def delete_user(user_guid)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      url = if v3
              "/v3/users/#{user_guid}"
            else
              "/v2/users/#{user_guid}"
            end
      @logger.debug("DELETE #{url}")

      cc_error = nil
      begin
        @client.delete_cc(url)
        @cc.invalidate_users_cc
      rescue CCRestClientResponseError => error
        # If we receive a 404 since the user is not within the CC, it still might be in UAA
        raise unless error.http_code == '404'

        cc_error = error
      end

      url = "/Users/#{user_guid}"
      @logger.debug("DELETE #{url}")
      begin
        @client.delete_uaa(url)
        @cc.invalidate_approvals
        @cc.invalidate_group_membership
        @cc.invalidate_revocable_tokens
        @cc.invalidate_users_uaa
        @view_models.invalidate_group_members
        @view_models.invalidate_revocable_tokens
        @view_models.invalidate_users
      rescue CCRestClientResponseError => error
        raise cc_error if error.http_code == '404' && cc_error

        raise error
      end
    end

    def delete_user_annotation(user_guid, prefix, name)
      url = "/v3/users/#{user_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"annotations\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_user_annotations
      @view_models.invalidate_users
    end

    def delete_user_label(user_guid, prefix, name)
      url = "/v3/users/#{user_guid}"
      key = name
      key = "#{prefix}/#{name}" if prefix
      body = "{\"metadata\":{\"labels\":{\"#{key}\":null}}}"
      @logger.debug("PATCH #{url}, #{body}")
      @client.patch_cc(url, body)
      @cc.invalidate_user_labels
      @view_models.invalidate_users
    end

    def delete_user_tokens(user_guid)
      url = "/oauth/token/revoke/user/#{user_guid}"
      @logger.debug("GET #{url}")
      @client.get_uaa(url)
      @cc.invalidate_revocable_tokens
      @cc.invalidate_users_uaa
      @view_models.invalidate_revocable_tokens
      @view_models.invalidate_users
    end

    def manage_application(app_guid, control_message)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      json = Yajl::Parser.parse(control_message)
      diego = json['diego']
      revisions_enabled = json['revisions_enabled']
      if diego.nil? && (v3 || !revisions_enabled.nil?)
        enable_ssh = json['enable_ssh']
        name = json['name']
        state = json['state']
        if !enable_ssh.nil?
          url = "/v3/apps/#{app_guid}/features/ssh"
          body = "{\"enabled\":#{enable_ssh}}"
          @logger.debug("PATCH #{url}, #{body}")
          @client.patch_cc(url, body)
        elsif !name.nil?
          url = "/v3/apps/#{app_guid}"
          @logger.debug("PATCH #{url}, #{control_message}")
          @client.patch_cc(url, control_message)
        elsif !revisions_enabled.nil?
          url = "/v3/apps/#{app_guid}/features/revisions"
          body = "{\"enabled\":#{revisions_enabled}}"
          @logger.debug("PATCH #{url}, #{body}")
          @client.patch_cc(url, body)
        elsif !state.nil?
          url = if state == 'STARTED'
                  "/v3/apps/#{app_guid}/actions/start"
                else
                  "/v3/apps/#{app_guid}/actions/stop"
                end
          @logger.debug("POST #{url}")
          @client.post_cc(url, nil)
        end
      else
        url = "/v2/apps/#{app_guid}"
        @logger.debug("PUT #{url}, #{control_message}")
        @client.put_cc(url, control_message)
      end
      @cc.invalidate_applications
      @cc.invalidate_droplets
      @cc.invalidate_packages
      @cc.invalidate_processes
      @varz.invalidate
      @view_models.invalidate_applications
      @view_models.invalidate_application_instances
    end

    def manage_buildpack(buildpack_guid, control_message)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      if v3
        url = "/v3/buildpacks/#{buildpack_guid}"
        @logger.debug("PATCH #{url}, #{control_message}")
        @client.patch_cc(url, control_message)
      else
        url = "/v2/buildpacks/#{buildpack_guid}"
        @logger.debug("PUT #{url}, #{control_message}")
        @client.put_cc(url, control_message)
      end
      @cc.invalidate_buildpacks
      @view_models.invalidate_buildpacks
    end

    def manage_feature_flag(feature_flag_name, control_message)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      if v3
        url = "/v3/feature_flags/#{feature_flag_name}"
        @logger.debug("PATCH #{url}, #{control_message}")
        @client.patch_cc(url, control_message)
      else
        url = "/v2/config/feature_flags/#{feature_flag_name}"
        @logger.debug("PUT #{url}, #{control_message}")
        @client.put_cc(url, control_message)
      end
      @cc.invalidate_feature_flags
      @view_models.invalidate_feature_flags
    end

    def manage_identity_provider_status(identity_provider_id, control_message)
      url = "/identity-providers/#{identity_provider_id}/status"
      @logger.debug("PATCH #{url}, #{control_message}")
      @client.patch_uaa(url, control_message)
      @cc.invalidate_identity_providers
      @view_models.invalidate_identity_providers
    end

    def manage_isolation_segment(isolation_segment_guid, control_message)
      url = "/v3/isolation_segments/#{isolation_segment_guid}"

      # As of cf-release 253 (API version 2.75.0), the protocol to rename an isolation segment changed from PUT to PATCH
      api_version = @client.api_version
      new_protocol = Gem::Version.new(api_version) >= Gem::Version.new('2.75.0')
      if new_protocol
        @logger.debug("PATCH #{url}, #{control_message}")
        @client.patch_cc(url, control_message)
      else
        @logger.debug("PUT #{url}, #{control_message}")
        @client.put_cc(url, control_message)
      end

      @cc.invalidate_isolation_segments
      @view_models.invalidate_isolation_segments
    end

    def manage_organization(organization_guid, control_message)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      if v3
        json = Yajl::Parser.parse(control_message)
        quota_definition_guid = json['quota_definition_guid']
        if quota_definition_guid.nil?
          url = "/v3/organizations/#{organization_guid}"
          body = control_message
          status = json['status']
          unless status.nil?
            suspended = status == 'suspended'
            body = "{\"suspended\":#{suspended}}"
          end
          @logger.debug("PATCH #{url}, #{body}")
          @client.patch_cc(url, body)
        else
          url = "/v3/organization_quotas/#{quota_definition_guid}/relationships/organizations"
          body = "{\"data\":[{\"guid\":\"#{organization_guid}\"}]}"
          @logger.debug("POST #{url}, #{body}")
          @client.post_cc(url, body)
        end
      else
        url = "/v2/organizations/#{organization_guid}"
        @logger.debug("PUT #{url}, #{control_message}")
        @client.put_cc(url, control_message)
      end
      @cc.invalidate_organizations
      @view_models.invalidate_organizations
    end

    def manage_quota_definition(quota_definition_guid, control_message)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      if v3
        url = "/v3/organization_quotas/#{quota_definition_guid}"
        @logger.debug("PATCH #{url}, #{control_message}")
        @client.patch_cc(url, control_message)
      else
        url = "/v2/quota_definitions/#{quota_definition_guid}"
        @logger.debug("PUT #{url}, #{control_message}")
        @client.put_cc(url, control_message)
      end
      @cc.invalidate_quota_definitions
      @view_models.invalidate_quotas
    end

    def manage_security_group(security_group_guid, control_message)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      json = Yajl::Parser.parse(control_message)
      running_default = json['running_default']
      staging_default = json['staging_default']
      if v3
        url = "/v3/security_groups/#{security_group_guid}"
        body = if !running_default.nil?
                 "{\"globally_enabled\":{\"running\":#{running_default}}}"
               elsif !staging_default.nil?
                 "{\"globally_enabled\":{\"staging\":#{staging_default}}}"
               else
                 control_message
               end
        @logger.debug("PATCH #{url}, #{body}")
        @client.patch_cc(url, body)
      # Else we have to be in v2 case
      elsif !running_default.nil?
        url = "/v2/config/running_security_groups/#{security_group_guid}"
        if running_default
          @logger.debug("PUT #{url}")
          @client.put_cc(url, nil)
        else
          @logger.debug("DELETE #{url}")
          @client.delete_cc(url)
        end
      elsif !staging_default.nil?
        url = "/v2/config/staging_security_groups/#{security_group_guid}"
        if staging_default
          @logger.debug("PUT #{url}")
          @client.put_cc(url, nil)
        else
          @logger.debug("DELETE #{url}")
          @client.delete_cc(url)
        end
      else
        url = "/v2/security_groups/#{security_group_guid}"
        @logger.debug("PUT #{url}, #{control_message}")
        @client.put_cc(url, control_message)
      end
      @cc.invalidate_security_groups
      @view_models.invalidate_security_groups
    end

    def manage_service_broker(service_broker_guid, control_message)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      if v3
        url = "/v3/service_brokers/#{service_broker_guid}"
        @logger.debug("PATCH #{url}, #{control_message}")
        @client.patch_cc(url, control_message)
      else
        url = "/v2/service_brokers/#{service_broker_guid}"
        @logger.debug("PUT #{url}, #{control_message}")
        @client.put_cc(url, control_message)
      end
      @cc.invalidate_service_brokers
      @view_models.invalidate_service_brokers
    end

    def manage_service_instance(service_instance_guid, is_gateway_service, control_message)
      # TODO: v3 manage service instance
      url = is_gateway_service ? "/v2/service_instances/#{service_instance_guid}" : "/v2/user_provided_service_instances/#{service_instance_guid}"
      @logger.debug("PUT #{url}, #{control_message}")
      @client.put_cc(url, control_message)
      @cc.invalidate_service_instances
      @view_models.invalidate_service_instances
    end

    def manage_service_plan(service_plan_guid, control_message)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      if v3
        json = Yajl::Parser.parse(control_message)
        pub = json['public']
        unless pub.nil?
          url = "/v3/service_plans/#{service_plan_guid}/visibility"
          type = if pub
                   'public'
                 else
                   'admin'
                 end
          body = "{\"type\":\"#{type}\"}"
          @logger.debug("POST #{url}, #{body}")
          @client.post_cc(url, body)
        end
      else
        url = "/v2/service_plans/#{service_plan_guid}"
        @logger.debug("PUT #{url}, #{control_message}")
        @client.put_cc(url, control_message)
      end
      @cc.invalidate_service_plans
      @cc.invalidate_service_plan_visibilities
      @view_models.invalidate_service_plans
      @view_models.invalidate_service_plan_visibilities
    end

    def manage_space(space_guid, control_message)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      if v3
        json = Yajl::Parser.parse(control_message)
        allow_ssh = json['allow_ssh']
        if allow_ssh.nil?
          url = "/v3/spaces/#{space_guid}"
          @logger.debug("PATCH #{url}, #{control_message}")
          @client.patch_cc(url, control_message)
        else
          url = "/v3/spaces/#{space_guid}/features/ssh"
          body = "{\"enabled\":#{allow_ssh}}"
          @logger.debug("PATCH #{url}, #{body}")
          @client.patch_cc(url, body)
        end
      else
        url = "/v2/spaces/#{space_guid}"
        @logger.debug("PUT #{url}, #{control_message}")
        @client.put_cc(url, control_message)
      end
      @cc.invalidate_spaces
      @view_models.invalidate_spaces
    end

    def manage_space_quota_definition(space_quota_definition_guid, control_message)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      if v3
        url = "/v3/space_quotas/#{space_quota_definition_guid}"
        @logger.debug("PATCH #{url}, #{control_message}")
        @client.patch_cc(url, control_message)
      else
        url = "/v2/space_quota_definitions/#{space_quota_definition_guid}"
        @logger.debug("PUT #{url}, #{control_message}")
        @client.put_cc(url, control_message)
      end
      @cc.invalidate_space_quota_definitions
      @view_models.invalidate_space_quotas
    end

    def manage_user(user_guid, control_message)
      url = "/Users/#{user_guid}"
      @logger.debug("PATCH #{url}, #{control_message}")
      @client.patch_uaa(url, control_message)
      @cc.invalidate_users_uaa
      @view_models.invalidate_users
    end

    def manage_user_status(user_guid, control_message)
      url = "/Users/#{user_guid}/status"
      @logger.debug("PATCH #{url}, #{control_message}")
      @client.patch_uaa(url, control_message)
      @cc.invalidate_users_uaa
      @view_models.invalidate_users
    end

    def remove_component(uri)
      @logger.debug("REMOVE component #{uri}")
      @varz.remove(uri)
      @view_models.invalidate_cloud_controllers
      @view_models.invalidate_components
      @view_models.invalidate_gateways
      @view_models.invalidate_routers
    end

    def remove_doppler_component(key)
      @logger.debug("REMOVE doppler component #{key}")
      @doppler.remove_component(key)
      @view_models.invalidate_cells
      @view_models.invalidate_components
      @view_models.invalidate_deas
      @view_models.invalidate_health_managers
      @view_models.invalidate_routers
    end

    def remove_organization_default_isolation_segment(organization_guid)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      if v3
        url = "/v3/organizations/#{organization_guid}/relationships/default_isolation_segment"
        body = '{\"data\":null}'
        @logger.debug("PATCH #{url}, #{body}")
        @client.patch_cc(url, body)
      else
        url = "/v2/organizations/#{organization_guid}/default_isolation_segment"
        @logger.debug("DELETE #{url}")
        @client.delete_cc(url)
      end
      @cc.invalidate_organizations
      @view_models.invalidate_organizations
    end

    def remove_space_isolation_segment(space_guid)
      api_version = @client.api_version
      v3 = Gem::Version.new(api_version) >= Gem::Version.new('2.153.0')
      if v3
        url = "/v3/spaces/#{space_guid}/relationships/isolation_segment"
        body = '{\"data\":null}'
        @logger.debug("PATCH #{url}, #{body}")
        @client.patch_cc(url, body)
      else
        url = "/v2/spaces/#{space_guid}/isolation_segment"
        @logger.debug("DELETE #{url}")
        @client.delete_cc(url)
      end
      @cc.invalidate_spaces
      @view_models.invalidate_spaces
    end

    def restage_application(app_guid)
      # TODO: v3 restage application
      url = "/v2/apps/#{app_guid}/restage"
      @logger.debug("POST #{url}")
      @client.post_cc(url, '{}')
      @cc.invalidate_applications
      @cc.invalidate_droplets
      @cc.invalidate_packages
      @cc.invalidate_processes
      @varz.invalidate
      @view_models.invalidate_applications
      @view_models.invalidate_application_instances
    end
  end
end
