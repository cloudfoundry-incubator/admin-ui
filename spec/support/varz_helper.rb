require 'json'
require 'net/http'
require 'uri'
require_relative '../spec_helper'
# This shouldn't be required, but is in some environments...
require_relative 'nats_helper'

module VARZHelper
  include NATSHelper

  # Workaround since I cannot instantiate Net::HTTPOK and have body() function successfully
  # Failing with NoMethodError: undefined method `closed?
  class OK < Net::HTTPOK
    attr_reader :body
    def initialize(hash)
      super(1.0, 200, 'OK')
      @body = hash.to_json
    end
  end

  def varz_stub
    AdminUI::Utils.stub(:http_get).with(anything, nats_cloud_controller_varz, anything) do
      OK.new(varz_cloud_controller)
    end

    AdminUI::Utils.stub(:http_get).with(anything, nats_dea_varz, anything) do
      OK.new(varz_dea)
    end

    AdminUI::Utils.stub(:http_get).with(anything, nats_health_manager_varz, anything) do
      OK.new(varz_health_manager)
    end

    AdminUI::Utils.stub(:http_get).with(anything, nats_provisioner_varz, anything) do
      OK.new(varz_provisioner)
    end

    AdminUI::Utils.stub(:http_get).with(anything, nats_router_varz, anything) do
      OK.new(varz_router)
    end
  end

  def varz_cloud_controller
    {
      'cpu'          => 0.1,
      'index'        => 0,
      'mem'          => 2,
      'num_cores'    => 3,
      'start'        => '2013-10-21T07:00:00-05:00',
      'type'         => nats_cloud_controller['type'],
      'uptime'       => '4d:5h:6m:7s',
      'vcap_sinatra' => { 'requests' => { 'completed'   => 8,
                                          'outstanding' => 9 } }
    }
  end

  def varz_dea
    {
      'available_disk_ratio'   => 0.1,
      'available_memory_ratio' => 0.2,
      'cpu'                    => 0.3,
      'cpu_load_avg'           => 0.4,
      'host'                   => nats_dea['host'],
      'index'                  => 0,
      'mem'                    => 5,
      'num_cores'              => 6,
      'stacks'                 => ['lucid64'],
      'start'                  => '2013-10-21T07:00:00-05:00',
      'type'                   => nats_dea['type'],
      'uptime'                 => '7d:8h:9m:10s',
      'instance_registry'      =>
      {
        'application1' =>
        {
          'application1_instance1' =>
          {
            'application_id'          => 'application1',
            'application_name'        => 'test',
            'application_uris'        => ['test.localhost.com'],
            'computed_pcpu'           => 0.12118232960961232,
            'droplet_sha1'            => 'droplet1',
            'limits'                  =>
            {
              'mem'  => 11,
              'disk' => 12,
              'fds'  => 13
            },
            'instance_index'          => 0,
            'services'                =>
            [
              {
                'name'     => 'TestService-random',
                'provider' => 'test',
                'vendor'   => 'TestService',
                'version'  => '1.0',
                'plan'     => 'TestServicePlan'
              }
            ],
            'state'                   => 'RUNNING',
            'state_running_timestamp' => 1382448059.0734425,
            'used_disk_in_bytes'      => 56_057_856,
            'used_memory_in_bytes'    => 19_292_160
          }
        }
      }
    }
  end

  def varz_health_manager
    {
      'cpu'               => 0.1,
      'crashed_instances' => 2,
      'index'             => 0,
      'mem'               => 3,
      'num_cores'         => 4,
      'running_instances' => 5,
      'start'             => '2013-10-21T07:00:00-05:00',
      'total_apps'        => 6,
      'total_instances'   => 7,
      'total_users'       => 8,
      'type'              => nats_health_manager['type'],
      'uptime'            => '9d:10h:11m:12s'
    }
  end

  def varz_provisioner
    {
      'cpu'       => 0.1,
      'host'      => nats_provisioner['host'],
      'index'     => 0,
      'mem'       => 2,
      'num_cores' => 3,
      'start'     => '2013-10-21T07:00:00-05:00',
      'type'      => nats_provisioner['type'],
      'uptime'    => '4d:5h:6m:7s',
      'config'    =>
      {
        'service' =>
        {
          'description'        => 'test provisioner description',
          'name'               => nats_provisioner['name'],
          'supported_versions' => ['8.9']
        }
      },
      'nodes'     =>
      {
        "#{ nats_provisioner['name'] }_node1" =>
        {
          'available_capacity' => 10,
          'id'                 => "#{ nats_provisioner['name'] }_node1"
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
      'bad_requests'  => 1,
      'cpu'           => 0.2,
      'droplets'      => 3,
      'index'         => 0,
      'mem'           => 4,
      'num_cores'     => 5,
      'requests'      => 6,
      'responses_2xx' => 7,
      'responses_3xx' => 8,
      'responses_4xx' => 9,
      'responses_5xx' => 10,
      'responses_xxx' => 11,
      'type'          => nats_router['type'],
      'start'         => '2013-10-21T07:00:00-05:00',
      'uptime'        => '12d:13h:14m:15s'
    }
  end
end
