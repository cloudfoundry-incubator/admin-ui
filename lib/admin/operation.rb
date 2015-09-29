module AdminUI
  class Operation
    def initialize(config, logger, cc, client, varz, view_models)
      @cc          = cc
      @client      = client
      @config      = config
      @logger      = logger
      @varz        = varz
      @view_models = view_models
    end

    def create_organization(control_message)
      url = 'v2/organizations'
      @logger.debug("POST #{url}, #{control_message}")
      @client.post_cc(url, control_message)
      @cc.invalidate_organizations
      @view_models.invalidate_organizations
    end

    def create_space_quota_definition_space(space_quota_definition_guid, space_guid)
      url = "v2/space_quota_definitions/#{space_quota_definition_guid}/spaces/#{space_guid}"
      @logger.debug("PUT #{url}")
      @client.put_cc(url, '{}')
      @cc.invalidate_spaces
      @view_models.invalidate_spaces
    end

    def delete_application(app_guid, recursive)
      url = "v2/apps/#{app_guid}"
      url += '?recursive=true' if recursive
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_applications
      @varz.invalidate
      @view_models.invalidate_applications
      @view_models.invalidate_application_instances
      return unless recursive
      @cc.invalidate_service_bindings
      @cc.invalidate_service_keys
      @view_models.invalidate_service_bindings
      @view_models.invalidate_service_keys
    end

    def delete_application_instance(app_guid, instance_index)
      url = "v2/apps/#{app_guid}/instances/#{instance_index}"
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @varz.invalidate
      @view_models.invalidate_application_instances
    end

    def delete_buildpack(buildpack_guid)
      url = "v2/buildpacks/#{buildpack_guid}"
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_buildpacks
      @view_models.invalidate_buildpacks
    end

    def delete_domain(domain_guid, recursive)
      url = "v2/domains/#{domain_guid}"
      url += '?recursive=true' if recursive
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_domains
      @view_models.invalidate_domains
      return unless recursive
      @cc.invalidate_routes
      @view_models.invalidate_routes
    end

    def delete_organization(organization_guid, recursive)
      url = "v2/organizations/#{organization_guid}"
      url += '?recursive=true' if recursive
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_organizations
      @cc.invalidate_organizations_auditors
      @cc.invalidate_organizations_billing_managers
      @cc.invalidate_organizations_managers
      @cc.invalidate_organizations_users
      @cc.invalidate_service_plan_visibilities
      @view_models.invalidate_organizations
      @view_models.invalidate_organization_roles
      @view_models.invalidate_service_plan_visibilities
      return unless recursive
      @cc.invalidate_space_quota_definitions
      @cc.invalidate_spaces
      @cc.invalidate_spaces_auditors
      @cc.invalidate_spaces_developers
      @cc.invalidate_spaces_managers
      @cc.invalidate_service_instances
      @cc.invalidate_service_bindings
      @cc.invalidate_service_keys
      @cc.invalidate_applications
      @cc.invalidate_routes
      @varz.invalidate
      @view_models.invalidate_space_quotas
      @view_models.invalidate_spaces
      @view_models.invalidate_space_roles
      @view_models.invalidate_service_instances
      @view_models.invalidate_service_bindings
      @view_models.invalidate_service_keys
      @view_models.invalidate_applications
      @view_models.invalidate_application_instances
      @view_models.invalidate_routes
    end

    def delete_organization_role(organization_guid, role, user_guid)
      url = "v2/organizations/#{organization_guid}/#{role}/#{user_guid}"
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_organizations_auditors if role == 'auditors'
      @cc.invalidate_organizations_billing_managers if role == 'billing_managers'
      @cc.invalidate_organizations_managers if role == 'managers'
      @cc.invalidate_organizations_users if role == 'users'
      @view_models.invalidate_organization_roles
    end

    def delete_quota_definition(quota_definition_guid)
      url = "v2/quota_definitions/#{quota_definition_guid}"
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_quota_definitions
      @view_models.invalidate_quotas
    end

    def delete_route(route_guid)
      url = "v2/routes/#{route_guid}"
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_routes
      @view_models.invalidate_routes
    end

    def delete_security_group(security_group_guid)
      url = "v2/security_groups/#{security_group_guid}"
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_security_groups
      @view_models.invalidate_security_groups
    end

    def delete_service(service_guid, purge)
      url = "v2/services/#{service_guid}"
      url += '?purge=true' if purge
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_services
      @cc.invalidate_service_plans
      @cc.invalidate_service_plan_visibilities
      @view_models.invalidate_services
      @view_models.invalidate_service_plans
      @view_models.invalidate_service_plan_visibilities
      return unless purge
      @cc.invalidate_service_instances
      @cc.invalidate_service_bindings
      @cc.invalidate_service_keys
      @view_models.invalidate_service_instances
      @view_models.invalidate_service_bindings
      @view_models.invalidate_service_keys
    end

    def delete_service_binding(service_binding_guid)
      url = "v2/service_bindings/#{service_binding_guid}"
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_service_bindings
      @view_models.invalidate_service_bindings
    end

    def delete_service_broker(service_broker_guid)
      url = "v2/service_brokers/#{service_broker_guid}"
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_clients
      @cc.invalidate_service_brokers
      @cc.invalidate_services
      @cc.invalidate_service_plans
      @cc.invalidate_service_plan_visibilities
      @view_models.invalidate_service_brokers
      @view_models.invalidate_services
      @view_models.invalidate_service_plans
      @view_models.invalidate_service_plan_visibilities
    end

    def delete_service_instance(service_instance_guid, is_gateway_service, recursive, purge)
      url = is_gateway_service ? "/v2/service_instances/#{service_instance_guid}" : "/v2/user_provided_service_instances/#{service_instance_guid}"
      if recursive
        url += '?recursive=true'
        url += '&purge=true' if purge
      end
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_service_instances
      @view_models.invalidate_service_instances
      return unless recursive
      @cc.invalidate_service_bindings
      @cc.invalidate_service_keys
      @view_models.invalidate_service_bindings
      @view_models.invalidate_service_keys
    end

    def delete_service_key(service_key_guid)
      url = "v2/service_keys/#{service_key_guid}"
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_service_keys
      @view_models.invalidate_service_keys
    end

    def delete_service_plan(service_plan_guid)
      url = "v2/service_plans/#{service_plan_guid}"
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_service_plans
      @cc.invalidate_service_plan_visibilities
      @view_models.invalidate_service_plans
      @view_models.invalidate_service_plan_visibilities
    end

    def delete_service_plan_visibility(service_plan_visibility_guid)
      url = "v2/service_plan_visibilities/#{service_plan_visibility_guid}"
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_service_plan_visibilities
      @view_models.invalidate_service_plan_visibilities
    end

    def delete_space(space_guid, recursive)
      url = "v2/spaces/#{space_guid}"
      url += '?recursive=true' if recursive
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_spaces
      @cc.invalidate_spaces_auditors
      @cc.invalidate_spaces_developers
      @cc.invalidate_spaces_managers
      @view_models.invalidate_spaces
      @view_models.invalidate_space_roles
      return unless recursive
      @cc.invalidate_service_instances
      @cc.invalidate_service_bindings
      @cc.invalidate_service_keys
      @cc.invalidate_applications
      @cc.invalidate_routes
      @varz.invalidate
      @view_models.invalidate_service_instances
      @view_models.invalidate_service_bindings
      @view_models.invalidate_service_keys
      @view_models.invalidate_applications
      @view_models.invalidate_application_instances
      @view_models.invalidate_routes
    end

    def delete_space_quota_definition(space_quota_definition_guid)
      url = "v2/space_quota_definitions/#{space_quota_definition_guid}"
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_space_quota_definitions
      @view_models.invalidate_space_quotas
    end

    def delete_space_quota_definition_space(space_quota_definition_guid, space_guid)
      url = "v2/space_quota_definitions/#{space_quota_definition_guid}/spaces/#{space_guid}"
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_spaces
      @view_models.invalidate_spaces
    end

    def delete_space_role(space_guid, role, user_guid)
      url = "v2/spaces/#{space_guid}/#{role}/#{user_guid}"
      @logger.debug("DELETE #{url}")
      @client.delete_cc(url)
      @cc.invalidate_spaces_auditors if role == 'auditors'
      @cc.invalidate_spaces_developers if role == 'developers'
      @cc.invalidate_spaces_managers if role == 'managers'
      @view_models.invalidate_space_roles
    end

    def manage_application(app_guid, control_message)
      url = "v2/apps/#{app_guid}"
      @logger.debug("PUT #{url}, #{control_message}")
      @client.put_cc(url, control_message)
      @cc.invalidate_applications
      @varz.invalidate
      @view_models.invalidate_applications
      @view_models.invalidate_application_instances
    end

    def manage_buildpack(buildpack_guid, control_message)
      url = "v2/buildpacks/#{buildpack_guid}"
      @logger.debug("PUT #{url}, #{control_message}")
      @client.put_cc(url, control_message)
      @cc.invalidate_buildpacks
      @view_models.invalidate_buildpacks
    end

    def manage_feature_flag(feature_flag_name, control_message)
      url = "v2/config/feature_flags/#{feature_flag_name}"
      @logger.debug("PUT #{url}, #{control_message}")
      @client.put_cc(url, control_message)
      @cc.invalidate_feature_flags
      @view_models.invalidate_feature_flags
    end

    def manage_organization(organization_guid, control_message)
      url = "v2/organizations/#{organization_guid}"
      @logger.debug("PUT #{url}, #{control_message}")
      @client.put_cc(url, control_message)
      @cc.invalidate_organizations
      @view_models.invalidate_organizations
    end

    def manage_quota_definition(quota_definition_guid, control_message)
      url = "v2/quota_definitions/#{quota_definition_guid}"
      @logger.debug("PUT #{url}, #{control_message}")
      @client.put_cc(url, control_message)
      @cc.invalidate_quota_definitions
      @view_models.invalidate_quotas
    end

    def manage_service_broker(service_broker_guid, control_message)
      url = "/v2/service_brokers/#{service_broker_guid}"
      @logger.debug("PUT #{url}, #{control_message}")
      @client.put_cc(url, control_message)
      @cc.invalidate_service_brokers
      @view_models.invalidate_service_brokers
    end

    def manage_service_instance(service_instance_guid, is_gateway_service, control_message)
      url = is_gateway_service ? "/v2/service_instances/#{service_instance_guid}" : "/v2/user_provided_service_instances/#{service_instance_guid}"
      @logger.debug("PUT #{url}, #{control_message}")
      @client.put_cc(url, control_message)
      @cc.invalidate_service_instances
      @view_models.invalidate_service_instances
    end

    def manage_service_plan(service_plan_guid, control_message)
      url = "/v2/service_plans/#{service_plan_guid}"
      @logger.debug("PUT #{url}, #{control_message}")
      @client.put_cc(url, control_message)
      @cc.invalidate_service_plans
      @view_models.invalidate_service_plans
    end

    def manage_space(space_guid, control_message)
      url = "v2/spaces/#{space_guid}"
      @logger.debug("PUT #{url}, #{control_message}")
      @client.put_cc(url, control_message)
      @cc.invalidate_spaces
      @view_models.invalidate_spaces
    end

    def manage_space_quota_definition(space_quota_definition_guid, control_message)
      url = "v2/space_quota_definitions/#{space_quota_definition_guid}"
      @logger.debug("PUT #{url}, #{control_message}")
      @client.put_cc(url, control_message)
      @cc.invalidate_space_quota_definitions
      @view_models.invalidate_space_quotas
    end

    def restage_application(app_guid)
      url = "v2/apps/#{app_guid}/restage"
      @logger.debug("POST #{url}")
      @client.post_cc(url, '{}')
      @cc.invalidate_applications
      @varz.invalidate
      @view_models.invalidate_applications
      @view_models.invalidate_application_instances
    end

    def remove_component(uri)
      @logger.debug("REMOVE component #{uri}")
      @varz.remove(uri)
      @view_models.invalidate_cloud_controllers
      @view_models.invalidate_components
      @view_models.invalidate_deas
      @view_models.invalidate_gateways
      @view_models.invalidate_health_managers
      @view_models.invalidate_routers
    end
  end
end
