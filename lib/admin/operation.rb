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
      @logger.debug("POST #{ url }, #{ control_message }")
      @client.post_cc(url, control_message)
      @cc.invalidate_organizations
      @view_models.invalidate_organizations
    end

    def delete_application(app_guid)
      url = "v2/apps/#{ app_guid }?recursive=true"
      @logger.debug("DELETE #{ url }")
      @client.delete_cc(url)
      @cc.invalidate_applications
      @varz.invalidate
      @view_models.invalidate_applications
    end

    def delete_domain(domain_guid)
      url = "v2/domains/#{ domain_guid }"
      @logger.debug("DELETE #{ url }")
      @client.delete_cc(url)
      @cc.invalidate_domains
      @view_models.invalidate_domains
    end

    def delete_organization(org_guid)
      url = "v2/organizations/#{ org_guid }?recursive=true"
      @logger.debug("DELETE #{ url }")
      @client.delete_cc(url)
      @cc.invalidate_organizations
      @view_models.invalidate_organizations
    end

    def delete_organization_role(org_guid, role, user_guid)
      url = "v2/organizations/#{ org_guid }/#{ role }/#{ user_guid }"
      @logger.debug("DELETE #{ url }")
      @client.delete_cc(url)
      @cc.invalidate_organizations_auditors if role == 'auditors'
      @cc.invalidate_organizations_billing_managers if role == 'billing_managers'
      @cc.invalidate_organizations_managers if role == 'managers'
      @cc.invalidate_organizations_users if role == 'users'
      @view_models.invalidate_organization_roles
    end

    def delete_quota_definition(quota_definition_guid)
      url = "v2/quota_definitions/#{ quota_definition_guid }"
      @logger.debug("DELETE #{ url }")
      @client.delete_cc(url)
      @cc.invalidate_quota_definitions
      @view_models.invalidate_quotas
    end

    def delete_route(route_guid)
      url = "v2/routes/#{ route_guid }"
      @logger.debug("DELETE #{ url }")
      @client.delete_cc(url)
      @cc.invalidate_routes
      @view_models.invalidate_routes
    end

    def delete_service_binding(service_binding_guid)
      url = "v2/service_bindings/#{ service_binding_guid }"
      @logger.debug("DELETE #{ url }")
      @client.delete_cc(url)
      @cc.invalidate_service_bindings
      @view_models.invalidate_service_bindings
    end

    def delete_service_instance(service_instance_guid)
      url = "v2/service_instances/#{ service_instance_guid }"
      @logger.debug("DELETE #{ url }")
      @client.delete_cc(url)
      @cc.invalidate_service_instances
      @cc.invalidate_service_bindings
      @view_models.invalidate_service_instances
      @view_models.invalidate_service_bindings
    end

    def delete_service_plan(service_plan_guid)
      url = "v2/service_plans/#{ service_plan_guid }"
      @logger.debug("DELETE #{ url }")
      @client.delete_cc(url)
      @cc.invalidate_service_plans
      @cc.invalidate_service_plan_visibilities
      @view_models.invalidate_service_plans
      @view_models.invalidate_service_plan_visibilities
    end

    def delete_service_plan_visibility(service_plan_visibility_guid)
      url = "v2/service_plan_visibilities/#{ service_plan_visibility_guid }"
      @logger.debug("DELETE #{ url }")
      @client.delete_cc(url)
      @cc.invalidate_service_plan_visibilities
      @view_models.invalidate_service_plan_visibilities
    end

    def delete_space(space_guid)
      url = "v2/spaces/#{ space_guid }?recursive=true"
      @logger.debug("DELETE #{ url }")
      @client.delete_cc(url)
      @cc.invalidate_spaces
      @view_models.invalidate_spaces
    end

    def delete_space_role(space_guid, role, user_guid)
      url = "v2/spaces/#{ space_guid }/#{ role }/#{ user_guid }"
      @logger.debug("DELETE #{ url }")
      @client.delete_cc(url)
      @cc.invalidate_spaces_auditors if role == 'auditors'
      @cc.invalidate_spaces_developers if role == 'developers'
      @cc.invalidate_spaces_managers if role == 'managers'
      @view_models.invalidate_space_roles
    end

    def manage_application(app_guid, control_message)
      url = "v2/apps/#{ app_guid }"
      @logger.debug("PUT #{ url }, #{ control_message }")
      @client.put_cc(url, control_message)
      @cc.invalidate_applications
      @varz.invalidate
      @view_models.invalidate_applications
    end

    def manage_service_plan(service_plan_guid, control_message)
      url = "/v2/service_plans/#{ service_plan_guid}"
      @logger.debug("PUT #{ url }, #{ control_message }")
      @client.put_cc(url, control_message)
      @cc.invalidate_service_plans
      @view_models.invalidate_service_plans
    end

    def manage_organization(org_guid, control_message)
      url = "v2/organizations/#{ org_guid }"
      @logger.debug("PUT #{ url }, #{ control_message }")
      @client.put_cc(url, control_message)
      @cc.invalidate_organizations
      @view_models.invalidate_organizations
    end

    def remove_component(uri)
      @logger.debug("REMOVE component #{ uri }")
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
