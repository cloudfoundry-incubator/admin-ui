module AdminUI
  class Operation
    def initialize(config, logger, cc, client, varz)
      @cc     = cc
      @client = client
      @config = config
      @logger = logger
      @varz   = varz
    end

    def manage_application(app_guid, control_message)
      url = "v2/apps/#{ app_guid }"

      @client.put_cc(url, control_message)

      @cc.invalidate_applications
      @varz.invalidate
    end

    def manage_route(method, route_guid)
      url = "v2/routes/#{ route_guid }"

      if method.upcase == 'DELETE'
        @client.delete_cc(url)
        @cc.invalidate_routes
      end
    end

    def manage_service_plan(service_plan_guid, control_message)
      url = "/v2/service_plans/#{ service_plan_guid}"
      @logger.debug("#{url}, #{control_message}")
      @client.put_cc(url, control_message)
      @cc.invalidate_service_plans
    end
  end
end
