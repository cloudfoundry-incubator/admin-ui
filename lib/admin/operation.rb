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

    def delete_route(route_guid)
      url = "v2/routes/#{ route_guid }"
      @logger.debug("DELETE #{ url }")
      @client.delete_cc(url)
      @cc.invalidate_routes
      @view_models.invalidate_routes
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
  end
end
