require 'json'
require 'net/http'
require 'uri'
require_relative '../spec_helper'

module OperationHelper
  class Created < Net::HTTPOK
    attr_reader :body

    def initialize(hash)
      super(1.0, 201, 'OK')
      @body = hash.to_json
    end
  end

  def operation_stub(config)
    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/apps/application1", AdminUI::Utils::HTTP_PUT, anything, '{"state":"STOPPED"}', anything) do
      Created.new(cc_stopped_app)
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/apps/application1", AdminUI::Utils::HTTP_PUT, anything, '{"state":"STARTED"}', anything) do
      Created.new(cc_started_app)
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/routes/route1", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      Net::HTTPNoContent.new(1.0, 204, 'OK')
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/service_plans/service_plan1", AdminUI::Utils::HTTP_PUT, anything, '{"public": true }', anything) do
      Created.new(cc_public_service_plans)
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/service_plans/service_plan1", AdminUI::Utils::HTTP_PUT, anything, '{"public": false }', anything) do
      Created.new(cc_private_service_plans)
    end
  end
end
