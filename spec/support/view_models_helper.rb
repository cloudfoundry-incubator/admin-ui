require 'time'
require_relative '../spec_helper'
require_relative 'cc_helper'
require_relative 'nats_helper'
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
        cc_app[:guid],
        cc_app[:state],
        cc_app[:package_state],
        varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['state'],
        cc_app[:created_at].to_datetime.rfc3339,
        cc_app[:updated_at].to_datetime.rfc3339,
        Time.at(varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['state_running_timestamp']).to_datetime.rfc3339,
        varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['application_uris'],
        cc_app[:detected_buildpack],
        varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['instance_index'],
        1,
        varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['services'].length,
        AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_memory_in_bytes']),
        AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_disk_in_bytes']),
        varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['computed_pcpu'] * 100,
        cc_app[:memory],
        cc_app[:disk_quota],
        "#{ cc_organization[:name] }/#{ cc_space[:name] }",
        nats_dea['host']
      ]
    ]
  end

  def view_models_applications_detail
    { 'application'  => cc_app,
      'instance'     => varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance],
      'organization' => cc_organization,
      'space'        => cc_space
    }
  end

  def view_models_clients
    [
      [
        uaa_client[:client_id],
        uaa_client[:scope].split(',').sort,
        uaa_client[:authorized_grant_types].split(',').sort,
        uaa_client[:web_server_redirect_uri].split(',').sort,
        uaa_client[:authorities].split(',').sort,
        uaa_client_autoapprove
      ]
    ]
  end

  def view_models_clients_detail
    uaa_client
  end

  def view_models_cloud_controllers
    [
      [
        nats_cloud_controller['host'],
        nats_cloud_controller['index'],
        'RUNNING',
        DateTime.parse(varz_cloud_controller['start']).rfc3339,
        varz_cloud_controller['num_cores'],
        varz_cloud_controller['cpu'],
        varz_cloud_controller['mem']
      ]
    ]
  end

  def view_models_cloud_controllers_detail
    { 'connected' => true,
      'data'      => varz_cloud_controller,
      'index'     => nats_cloud_controller['index'],
      'name'      => nats_cloud_controller['host'],
      'type'      => nats_cloud_controller['type'],
      'uri'       => nats_cloud_controller_varz
    }
  end

  def view_models_components
    [
      [
        nats_cloud_controller['host'],
        nats_cloud_controller['type'],
        nats_cloud_controller['index'],
        'RUNNING',
        DateTime.parse(varz_cloud_controller['start']).rfc3339,
        nats_cloud_controller_varz
      ],
      [
        nats_dea['host'],
        nats_dea['type'],
        nats_dea['index'],
        'RUNNING',
        DateTime.parse(varz_dea['start']).rfc3339,
        nats_dea_varz
      ],
      [
        nats_health_manager['host'],
        nats_health_manager['type'],
        nats_health_manager['index'],
        'RUNNING',
        nil,
        nats_health_manager_varz
      ],
      [
        nats_provisioner['host'],
        nats_provisioner['type'],
        nats_provisioner['index'],
        'RUNNING',
        DateTime.parse(varz_provisioner['start']).rfc3339,
        nats_provisioner_varz
      ],
      [
        nats_router['host'],
        nats_router['type'],
        nats_router['index'],
        'RUNNING',
        DateTime.parse(varz_router['start']).rfc3339,
        nats_router_varz
      ]
    ]
  end

  def view_models_deas
    [
      [
        nats_dea['host'],
        nats_dea['index'],
        'RUNNING',
        DateTime.parse(varz_dea['start']).rfc3339,
        varz_dea['stacks'],
        varz_dea['cpu'],
        varz_dea['mem'],
        varz_dea['instance_registry'].length,
        varz_dea['instance_registry'][cc_app[:guid]].length,
        AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_memory_in_bytes']),
        AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_disk_in_bytes']),
        varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['computed_pcpu'] * 100,
        varz_dea['available_memory_ratio'] * 100,
        varz_dea['available_disk_ratio'] * 100
      ]
    ]
  end

  def view_models_deas_detail
    { 'connected' => true,
      'data'      => varz_dea,
      'index'     => nats_dea['index'],
      'name'      => nats_dea['host'],
      'type'      => nats_dea['type'],
      'uri'       => nats_dea_varz
    }
  end

  def view_models_domains
    [
      [
        cc_domain[:guid],
        cc_domain[:name],
        cc_domain[:guid],
        cc_domain[:created_at].to_datetime.rfc3339,
        cc_domain[:updated_at].to_datetime.rfc3339,
        cc_organization[:name],
        1,
        1
      ]
    ]
  end

  def view_models_domains_detail
    {
      'domain'                       => cc_domain,
      'owning_organization'          => cc_organization,
      'private_shared_organizations' => [cc_organization]
    }
  end

  def view_models_events
    [
      [
        cc_event_space[:timestamp].to_datetime.rfc3339,
        cc_event_space[:guid],
        cc_event_space[:type],
        cc_event_space[:actee_type],
        cc_event_space[:actee_name],
        cc_event_space[:actee],
        cc_event_space[:actor_type],
        cc_event_space[:actor_name],
        cc_event_space[:actor],
        "#{ cc_organization[:name] }/#{ cc_space[:name] }"
      ]
    ]
  end

  def view_models_events_detail
    {
      'event'        => cc_event_space,
      'organization' => cc_organization,
      'space'        => cc_space
    }
  end

  def view_models_gateways
    [
      [
        nats_provisioner['type'].sub('-Provisioner', ''),
        nats_provisioner['index'],
        'RUNNING',
        DateTime.parse(varz_provisioner['start']).rfc3339,
        varz_provisioner['config']['service']['description'],
        varz_provisioner['cpu'],
        varz_provisioner['mem'],
        varz_provisioner['nodes'].length,
        10
      ]
    ]
  end

  def view_models_gateways_detail
    { 'connected' => true,
      'data'      => varz_provisioner,
      'index'     => nats_provisioner['index'],
      'name'      => nats_provisioner['type'].sub('-Provisioner', ''),
      'type'      => nats_provisioner['type'],
      'uri'       => nats_provisioner_varz
    }
  end

  def view_models_health_managers
    [
      [
        nats_health_manager['host'],
        nats_health_manager['index'],
        'RUNNING',
        varz_health_manager['numCPUS'],
        varz_health_manager['memoryStats']['numBytesAllocated']
      ]
    ]
  end

  def view_models_health_managers_detail
    { 'connected' => true,
      'data'      => varz_health_manager,
      'index'     => nats_health_manager['index'],
      'name'      => nats_health_manager['host'],
      'type'      => nats_health_manager['type'],
      'uri'       => nats_health_manager_varz
    }
  end

  def view_models_logs(log_file_displayed, log_file_displayed_contents_length, log_file_displayed_modified_milliseconds)
    [
      [
        log_file_displayed,
        log_file_displayed_contents_length,
        Time.at(log_file_displayed_modified_milliseconds / 1000.0).to_datetime.rfc3339,
        { path: log_file_displayed,
          size: log_file_displayed_contents_length,
          time: log_file_displayed_modified_milliseconds
        }
      ]
    ]
  end

  def view_models_organizations
    [
      [
        cc_organization[:guid],
        cc_organization[:name],
        cc_organization[:guid],
        cc_organization[:status],
        cc_organization[:created_at].to_datetime.rfc3339,
        cc_organization[:updated_at].to_datetime.rfc3339,
        1,
        4,
        3,
        cc_quota_definition[:name],
        1,
        1,
        1,
        1,
        0,
        cc_app[:instances],
        varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['services'].length,
        AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_memory_in_bytes']),
        AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_disk_in_bytes']),
        varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['computed_pcpu'] * 100,
        cc_app[:memory],
        cc_app[:disk_quota],
        1,
        cc_app[:state] == 'STARTED' ? 1 : 0,
        cc_app[:state] == 'STOPPED' ? 1 : 0,
        cc_app[:package_state] == 'PENDING' ? 1 : 0,
        cc_app[:package_state] == 'STAGED'  ? 1 : 0,
        cc_app[:package_state] == 'FAILED'  ? 1 : 0
      ]
    ]
  end

  def view_models_organizations_detail
    cc_organization
  end

  def view_models_organization_roles
    [
      [
        "#{ cc_organization[:guid] }/auditors/#{ uaa_user[:id] }",
        cc_organization[:name],
        cc_organization[:guid],
        uaa_user[:username],
        uaa_user[:id],
        'Auditor'
      ],
      [
        "#{ cc_organization[:guid] }/billing_managers/#{ uaa_user[:id] }",
        cc_organization[:name],
        cc_organization[:guid],
        uaa_user[:username],
        uaa_user[:id],
        'Billing Manager'
      ],
      [
        "#{ cc_organization[:guid] }/managers/#{ uaa_user[:id] }",
        cc_organization[:name],
        cc_organization[:guid],
        uaa_user[:username],
        uaa_user[:id],
        'Manager'
      ],
      [
        "#{ cc_organization[:guid] }/users/#{ uaa_user[:id] }",
        cc_organization[:name],
        cc_organization[:guid],
        uaa_user[:username],
        uaa_user[:id],
        'User'
      ]
    ]
  end

  def view_models_organization_roles_detail
    {
      'organization' => cc_organization,
      'role'         => cc_organization_auditor,
      'user_cc'      => cc_user,
      'user_uaa'     => uaa_user
    }
  end

  def view_models_quotas
    [
      [
        cc_quota_definition[:guid],
        cc_quota_definition[:name],
        cc_quota_definition[:guid],
        cc_quota_definition[:created_at].to_datetime.rfc3339,
        cc_quota_definition[:updated_at].to_datetime.rfc3339,
        cc_quota_definition[:total_services],
        cc_quota_definition[:total_routes],
        cc_quota_definition[:memory_limit],
        cc_quota_definition[:instance_memory_limit],
        cc_quota_definition[:non_basic_services_allowed],
        1
      ]
    ]
  end

  def view_models_quotas_detail
    cc_quota_definition
  end

  def view_models_routers
    [
      [
        nats_router['host'],
        nats_router['index'],
        'RUNNING',
        DateTime.parse(varz_router['start']).rfc3339,
        varz_router['num_cores'],
        varz_router['cpu'],
        varz_router['mem'],
        varz_router['droplets'],
        varz_router['requests'],
        varz_router['bad_requests']
      ]
    ]
  end

  def view_models_routers_detail
    { 'router' =>
      { 'connected' => true,
        'data'      => varz_router,
        'index'     => nats_router['index'],
        'name'      => nats_router['host'],
        'type'      => nats_router['type'],
        'uri'       => nats_router_varz
      },
      'top10Apps' =>
      [
        { 'guid'   => cc_app[:guid],
          'name'   => cc_app[:name],
          'rpm'    => varz_router['top10_app_requests'][0]['rpm'],
          'rps'    => varz_router['top10_app_requests'][0]['rps'],
          'target' => "#{ cc_organization[:name] }/#{ cc_space[:name] }"
        }
      ]
    }
  end

  def view_models_routes
    [
      [
        cc_route[:guid],
        cc_route[:host],
        cc_route[:guid],
        cc_domain[:name],
        cc_route[:created_at].to_datetime.rfc3339,
        cc_route[:updated_at].to_datetime.rfc3339,
        "#{ cc_organization[:name] }/#{ cc_space[:name] }",
        [cc_app[:name]]
      ]
    ]
  end

  def view_models_routes_detail
    { 'domain'       => cc_domain,
      'organization' => cc_organization,
      'route'        => cc_route,
      'space'        => cc_space
    }
  end

  def view_models_service_bindings
    [
      [
        cc_service_binding[:guid],
        cc_service_binding[:guid],
        cc_service_binding[:created_at].to_datetime.rfc3339,
        cc_service_binding[:updated_at].to_datetime.rfc3339,
        1,
        cc_app[:name],
        cc_app[:guid],
        cc_service_instance[:name],
        cc_service_instance[:guid],
        cc_service_instance[:created_at].to_datetime.rfc3339,
        cc_service_instance[:updated_at].to_datetime.rfc3339,
        cc_service_plan[:name],
        cc_service_plan[:guid],
        cc_service_plan[:unique_id],
        cc_service_plan[:created_at].to_datetime.rfc3339,
        cc_service_plan[:updated_at].to_datetime.rfc3339,
        cc_service_plan[:active],
        cc_service_plan[:public],
        cc_service_plan[:free],
        cc_service[:provider],
        cc_service[:label],
        cc_service[:guid],
        cc_service[:unique_id],
        cc_service[:version],
        cc_service[:created_at].to_datetime.rfc3339,
        cc_service[:updated_at].to_datetime.rfc3339,
        cc_service[:active],
        cc_service_broker[:name],
        cc_service_broker[:guid],
        cc_service_broker[:created_at].to_datetime.rfc3339,
        cc_service_broker[:updated_at].to_datetime.rfc3339,
        "#{ cc_organization[:name] }/#{ cc_space[:name] }"
      ]
    ]
  end

  def view_models_service_bindings_detail
    { 'application'      => cc_app,
      'organization'     => cc_organization,
      'service'          => cc_service,
      'service_binding'  => cc_service_binding,
      'service_broker'   => cc_service_broker,
      'service_instance' => cc_service_instance,
      'service_plan'     => cc_service_plan,
      'space'            => cc_space
    }
  end

  def view_models_service_brokers
    [
      [
        cc_service_broker[:guid],
        cc_service_broker[:name],
        cc_service_broker[:guid],
        cc_service_broker[:created_at].to_datetime.rfc3339,
        cc_service_broker[:updated_at].to_datetime.rfc3339,
        1,
        1,
        1,
        1,
        1,
        1
      ]
    ]
  end

  def view_models_service_brokers_detail
    cc_service_broker
  end

  def view_models_service_instances
    [
      [
        cc_service_instance[:guid],
        cc_service_instance[:name],
        cc_service_instance[:guid],
        cc_service_instance[:created_at].to_datetime.rfc3339,
        cc_service_instance[:updated_at].to_datetime.rfc3339,
        1,
        1,
        cc_service_plan[:name],
        cc_service_plan[:guid],
        cc_service_plan[:unique_id],
        cc_service_plan[:created_at].to_datetime.rfc3339,
        cc_service_plan[:updated_at].to_datetime.rfc3339,
        cc_service_plan[:active],
        cc_service_plan[:public],
        cc_service_plan[:free],
        cc_service[:provider],
        cc_service[:label],
        cc_service[:guid],
        cc_service[:unique_id],
        cc_service[:version],
        cc_service[:created_at].to_datetime.rfc3339,
        cc_service[:updated_at].to_datetime.rfc3339,
        cc_service[:active],
        cc_service[:bindable],
        cc_service_broker[:name],
        cc_service_broker[:guid],
        cc_service_broker[:created_at].to_datetime.rfc3339,
        cc_service_broker[:updated_at].to_datetime.rfc3339,
        "#{ cc_organization[:name] }/#{ cc_space[:name] }"
      ]
    ]
  end

  def view_models_service_instances_detail
    { 'organization'     => cc_organization,
      'service'          => cc_service,
      'service_broker'   => cc_service_broker,
      'service_instance' => cc_service_instance,
      'service_plan'     => cc_service_plan,
      'space'            => cc_space
    }
  end

  def view_models_service_plans
    [
      [
        cc_service_plan[:guid],
        cc_service_plan[:name],
        cc_service_plan[:guid],
        cc_service_plan[:unique_id],
        cc_service_plan[:created_at].to_datetime.rfc3339,
        cc_service_plan[:updated_at].to_datetime.rfc3339,
        cc_service_plan[:active],
        cc_service_plan[:public],
        cc_service_plan[:free],
        1,
        1,
        1,
        1,
        cc_service[:provider],
        cc_service[:label],
        cc_service[:guid],
        cc_service[:unique_id],
        cc_service[:version],
        cc_service[:created_at].to_datetime.rfc3339,
        cc_service[:updated_at].to_datetime.rfc3339,
        cc_service[:active],
        cc_service[:bindable],
        cc_service_broker[:name],
        cc_service_broker[:guid],
        cc_service_broker[:created_at].to_datetime.rfc3339,
        cc_service_broker[:updated_at].to_datetime.rfc3339
      ]
    ]
  end

  def view_models_service_plans_detail
    { 'service'        => cc_service,
      'service_broker' => cc_service_broker,
      'service_plan'   => cc_service_plan
    }
  end

  def view_models_service_plan_visibilities
    [
      [
        cc_service_plan_visibility[:guid],
        cc_service_plan_visibility[:guid],
        cc_service_plan_visibility[:created_at].to_datetime.rfc3339,
        cc_service_plan_visibility[:updated_at].to_datetime.rfc3339,
        1,
        cc_service_plan[:name],
        cc_service_plan[:guid],
        cc_service_plan[:unique_id],
        cc_service_plan[:created_at].to_datetime.rfc3339,
        cc_service_plan[:updated_at].to_datetime.rfc3339,
        cc_service_plan[:active],
        cc_service_plan[:public],
        cc_service_plan[:free],
        cc_service[:provider],
        cc_service[:label],
        cc_service[:guid],
        cc_service[:unique_id],
        cc_service[:version],
        cc_service[:created_at].to_datetime.rfc3339,
        cc_service[:updated_at].to_datetime.rfc3339,
        cc_service[:active],
        cc_service[:bindable],
        cc_service_broker[:name],
        cc_service_broker[:guid],
        cc_service_broker[:created_at].to_datetime.rfc3339,
        cc_service_broker[:updated_at].to_datetime.rfc3339,
        cc_organization[:name],
        cc_organization[:guid],
        cc_organization[:created_at].to_datetime.rfc3339,
        cc_organization[:updated_at].to_datetime.rfc3339
      ]
    ]
  end

  def view_models_service_plan_visibilities_detail
    { 'organization'            => cc_organization,
      'service'                 => cc_service,
      'service_broker'          => cc_service_broker,
      'service_plan'            => cc_service_plan,
      'service_plan_visibility' => cc_service_plan_visibility
    }
  end

  def view_models_services
    [
      [
        cc_service[:guid],
        cc_service[:provider],
        cc_service[:label],
        cc_service[:guid],
        cc_service[:unique_id],
        cc_service[:version],
        cc_service[:created_at].to_datetime.rfc3339,
        cc_service[:updated_at].to_datetime.rfc3339,
        cc_service[:active],
        cc_service[:bindable],
        cc_service[:plan_updateable],
        1,
        1,
        1,
        1,
        1,
        cc_service_broker[:name],
        cc_service_broker[:guid],
        cc_service_broker[:created_at].to_datetime.rfc3339,
        cc_service_broker[:updated_at].to_datetime.rfc3339
      ]
    ]
  end

  def view_models_services_detail
    { 'service'        => cc_service,
      'service_broker' => cc_service_broker
    }
  end

  def view_models_spaces
    [
      [
        cc_space[:guid],
        cc_space[:name],
        cc_space[:guid],
        "#{ cc_organization[:name] }/#{ cc_space[:name] }",
        cc_space[:created_at].to_datetime.rfc3339,
        cc_space[:updated_at].to_datetime.rfc3339,
        3,
        1,
        1,
        0,
        cc_app[:instances],
        varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['services'].length,
        AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_memory_in_bytes']),
        AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_disk_in_bytes']),
        varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['computed_pcpu'] * 100,
        cc_app[:memory],
        cc_app[:disk_quota],
        1,
        cc_app[:state] == 'STARTED' ? 1 : 0,
        cc_app[:state] == 'STOPPED' ? 1 : 0,
        cc_app[:package_state] == 'PENDING' ? 1 : 0,
        cc_app[:package_state] == 'STAGED'  ? 1 : 0,
        cc_app[:package_state] == 'FAILED'  ? 1 : 0
      ]
    ]
  end

  def view_models_spaces_detail
    { 'organization' => cc_organization,
      'space'        => cc_space
    }
  end

  def view_models_space_roles
    [
      [
        "#{ cc_space[:guid] }/auditors/#{ uaa_user[:id] }",
        cc_space[:name],
        cc_space[:guid],
        "#{ cc_organization[:name] }/#{ cc_space[:name] }",
        uaa_user[:username],
        uaa_user[:id],
        'Auditor'
      ],
      [
        "#{ cc_space[:guid] }/developers/#{ uaa_user[:id] }",
        cc_space[:name],
        cc_space[:guid],
        "#{ cc_organization[:name] }/#{ cc_space[:name] }",
        uaa_user[:username],
        uaa_user[:id],
        'Developer'
      ],
      [
        "#{ cc_space[:guid] }/managers/#{ uaa_user[:id] }",
        cc_space[:name],
        cc_space[:guid],
        "#{ cc_organization[:name] }/#{ cc_space[:name] }",
        uaa_user[:username],
        uaa_user[:id],
        'Manager'
      ]
    ]
  end

  def view_models_space_roles_detail
    {
      'organization' => cc_organization,
      'role'         => cc_space_auditor,
      'space'        => cc_space,
      'user_cc'      => cc_user,
      'user_uaa'     => uaa_user
    }
  end

  def view_models_stats(timestamp)
    [
      [
        Time.at(timestamp / 1000.0).to_datetime.rfc3339,
        1,
        1,
        1,
        1,
        cc_app[:instances],
        cc_app[:state] == 'STARTED' ? 1 : 0,
        1,
        { apps:              1,
          deas:              1,
          organizations:     1,
          running_instances: cc_app[:state] == 'STARTED' ? 1 : 0,
          spaces:            1,
          timestamp:         timestamp,
          total_instances:   cc_app[:instances],
          users:             1
        }
      ]
    ]
  end

  def view_models_users
    [
      [
        uaa_user[:username],
        uaa_user[:id],
        uaa_user[:created].to_datetime.rfc3339,
        uaa_user[:lastmodified].to_datetime.rfc3339,
        uaa_user[:email],
        uaa_user[:familyname],
        uaa_user[:givenname],
        uaa_user[:active],
        uaa_user[:version],
        [uaa_group[:displayname]],
        4,
        1,
        1,
        1,
        1,
        3,
        1,
        1,
        1
      ]
    ]
  end

  def view_models_users_detail
    {
      'groups'   => [uaa_group[:displayname]],
      'user_cc'  => cc_user,
      'user_uaa' => uaa_user
    }
  end
end
