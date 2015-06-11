require 'net/http'
require 'uri'
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
    allow(AdminUI::Utils).to receive(:http_request).with(anything, nats_cloud_controller_varz, AdminUI::Utils::HTTP_GET, anything) do
      OK.new(varz_cloud_controller)
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, nats_dea_varz, AdminUI::Utils::HTTP_GET, anything) do
      OK.new(varz_dea)
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, nats_health_manager_varz, AdminUI::Utils::HTTP_GET, anything) do
      OK.new(varz_health_manager)
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, nats_provisioner_varz, AdminUI::Utils::HTTP_GET, anything) do
      OK.new(varz_provisioner)
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, nats_router_varz, AdminUI::Utils::HTTP_GET, anything) do
      OK.new(varz_router)
    end
  end

  def varz_cloud_controller
    {
      'cpu'          => 0.1,
      'mem'          => 2,
      'num_cores'    => 3,
      'start'        => '2015-04-23T08:00:00-05:00',
      'type'         => nats_cloud_controller['type'],
      'uptime'       => '4d:5h:6m:7s',
      'vcap_sinatra' => { 'requests' => { 'completed'   => 8,
                                          'outstanding' => 9 } }
    }
  end

  def varz_dea_app_instance
    "#{cc_app[:guid]}_instance0"
  end

  def varz_dea
    {
      'available_disk_ratio'   => 0.1,
      'available_memory_ratio' => 0.2,
      'cpu'                    => 0.3,
      'cpu_load_avg'           => 0.4,
      'mem'                    => 5,
      'num_cores'              => 6,
      'stacks'                 => ['lucid64'],
      'start'                  => '2015-04-23T08:00:01-05:00',
      'type'                   => nats_dea['type'],
      'uptime'                 => '7d:8h:9m:10s',
      'instance_registry'      => cc_apps_deleted ? {} : varz_dea_instance_registry
    }
  end

  def varz_dea_instance_registry
    {
      cc_app[:guid] =>
      {
        varz_dea_app_instance =>
        {
          'application_id'          => cc_app[:guid],
          'application_name'        => cc_app[:name],
          'application_uris'        => ["#{cc_route[:host]}.#{cc_domain[:name]}#{cc_route[:path]}"],
          'computed_pcpu'           => 0.12118232960961232,
          'droplet_sha1'            => cc_app[:droplet_hash],
          'limits'                  =>
          {
            'mem'  => cc_app[:memory],
            'disk' => cc_app[:disk_quota],
            'fds'  => 13
          },
          'instance_id'             => varz_dea_app_instance,
          'instance_index'          => cc_app_instance_index,
          'stack'                   => cc_stack[:name],
          'state'                   => 'RUNNING',
          'state_running_timestamp' => 1_382_448_059.0734425,
          'used_disk_in_bytes'      => 56_057_856,
          'used_memory_in_bytes'    => 19_292_160,
          'vcap_application'        =>
          {
            'space_id' => cc_space[:guid]
          }
        }
      }
    }
  end

  def varz_health_manager
    {
      'numCPUS' => 4,
      'memoryStats' =>
      {
        'numBytesAllocated' => 1_186_744
      },
      'contexts' =>
      [
        {
          'name' => 'HM9000',
          'metrics' =>
          [
            {
              'name'  => 'ActualStateListenerStoreUsagePercentage',
              'value' => 0.1
            },
            {
              'name'  => 'DesiredStateSyncTimeInMilliseconds',
              'value' => 2.3
            },
            {
              'name'  => 'NumberOfAppsWithAllInstancesReporting',
              'value' => 4
            },
            {
              'name'  => 'NumberOfAppsWithMissingInstances',
              'value' => 5
            },
            {
              'name'  => 'NumberOfCrashedIndices',
              'value' => 6
            },
            {
              'name'  => 'NumberOfCrashedInstances',
              'value' => 7
            },
            {
              'name'  => 'NumberOfDesiredApps',
              'value' => 8
            },
            {
              'name'  => 'NumberOfDesiredAppsPendingStaging',
              'value' => 9
            },
            {
              'name'  => 'NumberOfDesiredInstances',
              'value' => 10
            },
            {
              'name'  => 'NumberOfMissingIndices',
              'value' => 11
            },
            {
              'name'  => 'NumberOfRunningInstances',
              'value' => 12
            },
            {
              'name'  => 'NumberOfUndesiredRunningApps',
              'value' => 13
            },
            {
              'name'  => 'ReceivedHeartbeats',
              'value' => 14
            },
            {
              'name'  => 'SavedHeartbeats',
              'value' => 15
            },
            {
              'name'  => 'StartCrashed',
              'value' => 16
            },
            {
              'name'  => 'StartEvacuating',
              'value' => 17
            },
            {
              'name'  => 'StartMissing',
              'value' => 18
            },
            {
              'name'  => 'StopDuplicate',
              'value' => 19
            },
            {
              'name'  => 'StopExtra',
              'value' => 20
            },
            {
              'name'  => 'StopEvacuationComplete',
              'value' => 21
            }
          ]
        }
      ]
    }
  end

  def varz_health_manager_metric(name)
    varz_health_manager['contexts'][0]['metrics'].each do |metric|
      return metric['value'] if metric['name'] == name
    end
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
      'nodes'     =>
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
      'mem'                => 4,
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
