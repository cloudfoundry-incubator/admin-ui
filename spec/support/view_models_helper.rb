require 'time'
require_relative '../spec_helper'
require_relative 'varz_helper'

module ViewModelsHelper
  include CCHelper
  include NATSHelper
  include VARZHelper

  def view_models_applications
    [
      [
        cc_app[:guid],
        cc_app[:name],
        cc_app[:state],
        cc_app[:package_state],
        varz_dea['instance_registry']['application1']['application1_instance1']['state'],
        cc_app[:created_at].to_datetime.rfc3339,
        cc_app[:updated_at].to_datetime.rfc3339,
        DateTime.parse(Time.at(varz_dea['instance_registry']['application1']['application1_instance1']['state_running_timestamp']).to_s).rfc3339,
        varz_dea['instance_registry']['application1']['application1_instance1']['application_uris'],
        cc_app[:detected_buildpack],
        varz_dea['instance_registry']['application1']['application1_instance1']['instance_index'],
        varz_dea['instance_registry']['application1']['application1_instance1']['services'].length,
        AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry']['application1']['application1_instance1']['used_memory_in_bytes']),
        AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry']['application1']['application1_instance1']['used_disk_in_bytes']),
        varz_dea['instance_registry']['application1']['application1_instance1']['computed_pcpu'] * 100,
        cc_app[:memory],
        cc_app[:disk_quota],
        "#{ cc_organization[:name] }/#{ cc_space[:name] }",
        nats_dea['host'],
        { 'application'  => cc_app,
          'instance'     => varz_dea['instance_registry']['application1']['application1_instance1'],
          'organization' => cc_organization,
          'space'        => cc_space
        }
      ]
    ]
  end

  def view_models_cloud_controllers
    [
      [
        nats_cloud_controller['host'],
        varz_cloud_controller['index'],
        'RUNNING',
        DateTime.parse(varz_cloud_controller['start']).rfc3339,
        varz_cloud_controller['num_cores'],
        varz_cloud_controller['cpu'],
        varz_cloud_controller['mem'],
        { 'connected' => true,
          'data'      => varz_cloud_controller,
          'name'      => nats_cloud_controller['host'],
          'uri'       => nats_cloud_controller_varz
        }
      ]
    ]
  end

  def view_models_components
    [
      [
        nats_cloud_controller['host'],
        nats_cloud_controller['type'],
        varz_cloud_controller['index'],
        'RUNNING',
        DateTime.parse(varz_cloud_controller['start']).rfc3339,
        { 'connected' => true,
          'data'      => varz_cloud_controller,
          'name'      => nats_cloud_controller['host'],
          'uri'       => nats_cloud_controller_varz
        },
        nats_cloud_controller_varz
      ],
      [
        nats_dea['host'],
        nats_dea['type'],
        varz_dea['index'],
        'RUNNING',
        DateTime.parse(varz_dea['start']).rfc3339,
        { 'connected' => true,
          'data'      => varz_dea,
          'name'      => nats_dea['host'],
          'uri'       => nats_dea_varz
        },
        nats_dea_varz
      ],
      [
        nats_health_manager['host'],
        nats_health_manager['type'],
        varz_health_manager['index'],
        'RUNNING',
        DateTime.parse(varz_health_manager['start']).rfc3339,
        { 'connected' => true,
          'data'      => varz_health_manager,
          'name'      => nats_health_manager['host'],
          'uri'       => nats_health_manager_varz
        },
        nats_health_manager_varz
      ],
      [
        nats_provisioner['host'],
        nats_provisioner['type'],
        varz_provisioner['index'],
        'RUNNING',
        DateTime.parse(varz_provisioner['start']).rfc3339,
        { 'connected' => true,
          'data'      => varz_provisioner,
          'name'      => nats_provisioner['host'],
          'uri'       => nats_provisioner_varz
        },
        nats_provisioner_varz
      ],
      [
        nats_router['host'],
        nats_router['type'],
        varz_router['index'],
        'RUNNING',
        DateTime.parse(varz_router['start']).rfc3339,
        { 'connected' => true,
          'data'      => varz_router,
          'name'      => nats_router['host'],
          'uri'       => nats_router_varz
        },
        nats_router_varz
      ]
    ]
  end

  def view_models_deas
    [
      [
        nats_dea['host'],
        varz_dea['index'],
        'RUNNING',
        DateTime.parse(varz_dea['start']).rfc3339,
        varz_dea['stacks'],
        varz_dea['cpu'],
        varz_dea['mem'],
        varz_dea['instance_registry'].length,
        varz_dea['instance_registry']['application1'].length,
        AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry']['application1']['application1_instance1']['used_memory_in_bytes']),
        AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry']['application1']['application1_instance1']['used_disk_in_bytes']),
        varz_dea['instance_registry']['application1']['application1_instance1']['computed_pcpu'] * 100,
        varz_dea['available_memory_ratio'] * 100,
        varz_dea['available_disk_ratio'] * 100,
        { 'connected' => true,
          'data'      => varz_dea,
          'name'      => nats_dea['host'],
          'uri'       => nats_dea_varz
        }
      ]
    ]
  end

  def view_models_developers
    [
      [
        uaa_user[:email],
        cc_space[:name],
        cc_organization[:name],
        "#{ cc_organization[:name] }/#{ cc_space[:name] }",
        uaa_user[:created].to_datetime.rfc3339,
        uaa_user[:lastmodified].to_datetime.rfc3339,
        {
          'authorities'     => uaa_group[:displayname],
          'organization'    => cc_organization,
          'space'           => cc_space,
          'space_developer' => cc_space_developer,
          'user_cc'         => cc_user,
          'user_uaa'        => uaa_user
        }
      ]
    ]
  end

  def view_models_gateways
    [
      [
        nats_provisioner['type'].sub('-Provisioner', ''),
        varz_provisioner['index'],
        'RUNNING',
        DateTime.parse(varz_provisioner['start']).rfc3339,
        varz_provisioner['config']['service']['description'],
        varz_provisioner['cpu'],
        varz_provisioner['mem'],
        varz_provisioner['nodes'].length,
        10,
        { 'connected' => true,
          'data'      => varz_provisioner,
          'name'      => nats_provisioner['type'].sub('-Provisioner', ''),
          'uri'       => nats_provisioner_varz
        }
      ]
    ]
  end

  def view_models_health_managers
    [
      [
        nats_health_manager['host'],
        varz_health_manager['index'],
        'RUNNING',
        DateTime.parse(varz_health_manager['start']).rfc3339,
        varz_health_manager['num_cores'],
        varz_health_manager['cpu'],
        varz_health_manager['mem'],
        varz_health_manager['total_users'],
        varz_health_manager['total_apps'],
        varz_health_manager['total_instances'],
        { 'connected' => true,
          'data'      => varz_health_manager,
          'name'      => nats_health_manager['host'],
          'uri'       => nats_health_manager_varz
        }
      ]
    ]
  end

  def view_models_logs(log_file_displayed, log_file_displayed_contents_length, log_file_displayed_modified_milliseconds)
    [
      [
        log_file_displayed,
        log_file_displayed_contents_length,
        DateTime.parse(Time.at(log_file_displayed_modified_milliseconds / 1000.0).to_s).rfc3339,
        { :path => log_file_displayed,
          :size => log_file_displayed_contents_length,
          :time => log_file_displayed_modified_milliseconds
        }
      ]
    ]
  end

  def view_models_organizations
    [
      [
        cc_organization[:guid],
        cc_organization[:name],
        cc_organization[:status],
        cc_organization[:created_at].to_datetime.rfc3339,
        cc_organization[:updated_at].to_datetime.rfc3339,
        1,
        1,
        cc_quota_definition[:name],
        1,
        1,
        0,
        cc_app[:instances],
        varz_dea['instance_registry']['application1']['application1_instance1']['services'].length,
        AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry']['application1']['application1_instance1']['used_memory_in_bytes']),
        AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry']['application1']['application1_instance1']['used_disk_in_bytes']),
        varz_dea['instance_registry']['application1']['application1_instance1']['computed_pcpu'] * 100,
        cc_app[:memory],
        cc_app[:disk_quota],
        1,
        cc_app[:state] == 'STARTED' ? 1 : 0,
        cc_app[:state] == 'STOPPED' ? 1 : 0,
        cc_app[:package_state] == 'PENDING' ? 1 : 0,
        cc_app[:package_state] == 'STAGED'  ? 1 : 0,
        cc_app[:package_state] == 'FAILED'  ? 1 : 0,
        cc_organization
      ]
    ]
  end

  def view_models_quotas
    [
      [
        cc_quota_definition[:name],
        cc_quota_definition[:created_at].to_datetime.rfc3339,
        cc_quota_definition[:updated_at].to_datetime.rfc3339,
        cc_quota_definition[:total_services],
        cc_quota_definition[:total_routes],
        cc_quota_definition[:memory_limit],
        cc_quota_definition[:non_basic_services_allowed],
        cc_quota_definition[:trial_db_allowed],
        1,
        cc_quota_definition
      ]
    ]
  end

  def view_models_routers
    [
      [
        nats_router['host'],
        varz_router['index'],
        'RUNNING',
        DateTime.parse(varz_router['start']).rfc3339,
        varz_router['num_cores'],
        varz_router['cpu'],
        varz_router['mem'],
        varz_router['droplets'],
        varz_router['requests'],
        varz_router['bad_requests'],
        { 'connected' => true,
          'data'      => varz_router,
          'name'      => nats_router['host'],
          'uri'       => nats_router_varz
        }
      ]
    ]
  end

  def view_models_routes
    [
      [
        cc_route[:guid],
        cc_route[:host],
        cc_domain[:name],
        cc_route[:created_at].to_datetime.rfc3339,
        cc_route[:updated_at].to_datetime.rfc3339,
        "#{ cc_organization[:name] }/#{ cc_space[:name] }",
        [cc_app[:name]],
        { 'domain'       => cc_domain,
          'organization' => cc_organization,
          'route'        => cc_route,
          'space'        => cc_space
        }
      ]
    ]
  end

  def view_models_service_instances
    [
      [
        cc_service_broker[:name],
        cc_service_broker[:created_at].to_datetime.rfc3339,
        cc_service_broker[:updated_at].to_datetime.rfc3339,
        cc_service[:provider],
        cc_service[:label],
        cc_service[:version],
        cc_service[:created_at].to_datetime.rfc3339,
        cc_service[:updated_at].to_datetime.rfc3339,
        cc_service_plan[:name],
        cc_service_plan[:created_at].to_datetime.rfc3339,
        cc_service_plan[:updated_at].to_datetime.rfc3339,
        cc_service_plan[:public],
        "#{ cc_service[:provider] }/#{ cc_service[:label] }/#{ cc_service_plan[:name] }",
        cc_service_instance[:name],
        cc_service_instance[:created_at].to_datetime.rfc3339,
        cc_service_instance[:updated_at].to_datetime.rfc3339,
        1,
        "#{ cc_organization[:name] }/#{ cc_space[:name] }",
        { 'bindingsAndApplications' =>
          [
            { 'application'    => cc_app,
              'serviceBinding' => cc_service_binding
            }
          ],
          'organization'    => cc_organization,
          'service'         => cc_service,
          'serviceBroker'   => cc_service_broker,
          'serviceInstance' => cc_service_instance,
          'servicePlan'     => cc_service_plan,
          'space'           => cc_space
        }
      ]
    ]
  end

  def view_models_service_plans
    [
      [
        cc_service_plan,
        cc_service_plan[:name],
        "#{ cc_service[:provider] }/#{ cc_service[:label] }/#{ cc_service_plan[:name] }",
        cc_service_plan[:created_at].to_datetime.rfc3339,
        cc_service_plan[:updated_at].to_datetime.rfc3339,
        cc_service_plan[:public],
        1,
        cc_service[:provider],
        cc_service[:label],
        cc_service[:version],
        cc_service[:created_at].to_datetime.rfc3339,
        cc_service[:updated_at].to_datetime.rfc3339,
        cc_service[:active],
        cc_service[:bindable],
        cc_service_broker[:name],
        cc_service_broker[:created_at].to_datetime.rfc3339,
        cc_service_broker[:updated_at].to_datetime.rfc3339,
        { 'service'       => cc_service,
          'serviceBroker' => cc_service_broker,
          'servicePlan'   => cc_service_plan
        }
      ]
    ]
  end

  def view_models_spaces
    [
      [
        cc_space[:name],
        "#{ cc_organization[:name] }/#{ cc_space[:name] }",
        cc_space[:created_at].to_datetime.rfc3339,
        cc_space[:updated_at].to_datetime.rfc3339,
        1,
        1,
        1,
        0,
        cc_app[:instances],
        varz_dea['instance_registry']['application1']['application1_instance1']['services'].length,
        AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry']['application1']['application1_instance1']['used_memory_in_bytes']),
        AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry']['application1']['application1_instance1']['used_disk_in_bytes']),
        varz_dea['instance_registry']['application1']['application1_instance1']['computed_pcpu'] * 100,
        cc_app[:memory],
        cc_app[:disk_quota],
        1,
        cc_app[:state] == 'STARTED' ? 1 : 0,
        cc_app[:state] == 'STOPPED' ? 1 : 0,
        cc_app[:package_state] == 'PENDING' ? 1 : 0,
        cc_app[:package_state] == 'STAGED'  ? 1 : 0,
        cc_app[:package_state] == 'FAILED'  ? 1 : 0,
        { 'organization' => cc_organization,
          'space'        => cc_space
        }
      ]
    ]
  end

  def view_models_stats(timestamp)
    [
      [
        DateTime.parse(Time.at(timestamp / 1000.0).to_s).rfc3339,
        1,
        1,
        1,
        1,
        cc_app[:instances],
        cc_app[:state] == 'STARTED' ? 1 : 0,
        1,
        { :apps              => 1,
          :deas              => 1,
          :organizations     => 1,
          :running_instances => cc_app[:state] == 'STARTED' ? 1 : 0,
          :spaces            => 1,
          :timestamp         => timestamp,
          :total_instances   => cc_app[:instances],
          :users             => 1
        }
      ]
    ]
  end
end
