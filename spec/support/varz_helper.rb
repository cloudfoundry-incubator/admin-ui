require 'net/http'
require 'yajl'
require_relative '../spec_helper'
# These shouldn't be required, but they are in some environments...
require_relative 'cc_helper'
require_relative 'nats_helper'

module VARZHelper
  include CCHelper
  include NATSHelper

  # Workaround since I cannot instantiate Net::HTTPOK and have body() function successfully
  # Failing with NoMethodError: undefined method `closed?
  class OK < Net::HTTPOK
    attr_reader :body

    def initialize(hash)
      super(1.0, 200, 'OK')
      @body = Yajl::Encoder.encode(hash)
    end
  end

  def varz_stub
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, nats_cloud_controller_varz, AdminUI::Utils::HTTP_GET, anything) do
      OK.new(varz_cloud_controller)
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, nats_provisioner_varz, AdminUI::Utils::HTTP_GET, anything) do
      OK.new(varz_provisioner)
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, nats_router_varz, AdminUI::Utils::HTTP_GET, anything) do
      OK.new(varz_router)
    end
  end

  def varz_cloud_controller
    {
      'cpu'          => 0.1,
      'mem_bytes'    => 2,
      'num_cores'    => 3,
      'start'        => '2015-04-23T08:00:00-05:00',
      'type'         => nats_cloud_controller['type'],
      'uptime'       => '4d:5h:6m:7s',
      'vcap_sinatra' => { 'requests' => { 'completed'   => 8,
                                          'outstanding' => 9 } }
    }
  end

  def varz_provisioner
    {
      'cpu'       => 0.1,
      'mem'       => 2,
      'num_cores' => 3,
      'start'     => '2015-04-23T08:00:02-05:00',
      'type'      => nats_provisioner['type'],
      'uptime'    => '4d:5h:6m:7s',
      'config'    =>
      {
        'service' =>
        {
          'description'        => 'test provisioner description',
          'name'               => 'test',
          'supported_versions' => ['8.9']
        }
      },
      'nodes' =>
      {
        'test_node1' =>
        {
          'available_capacity' => 10,
          'id'                 => 'test_node1'
        }
      },
      'prov_svcs' =>
      {
        'service1' =>
        {
          'configuration' => {}
        }
      }
    }
  end

  def varz_router
    {
      'bad_requests'       => 1,
      'cpu'                => 0.2,
      'droplets'           => 3,
      'mem_bytes'          => 4,
      'num_cores'          => 5,
      'requests'           => 6,
      'responses_2xx'      => 7,
      'responses_3xx'      => 8,
      'responses_4xx'      => 9,
      'responses_5xx'      => 10,
      'responses_xxx'      => 11,
      'top10_app_requests' =>
      [
        {
          'application_id'   => cc_app[:guid],
          'rpm'              => 120,
          'rps'              => 2
        }
      ],
      'type'               => nats_router['type'],
      'start'              => '2015-04-23T08:00:03-05:00',
      'uptime'             => '12d:13h:14m:15s'
    }
  end
end
