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

    def delete_route(route_guid)
      url = "v2/routes/#{ route_guid }"
      @logger.debug("DELETE #{ url }")
      @client.delete_cc(url)
      @cc.invalidate_routes
      @view_models.invalidate_routes
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
