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
        cc_started_apps['resources'][0]['metadata']['guid'],
        cc_started_apps['resources'][0]['entity']['name'],
        cc_started_apps['resources'][0]['entity']['state'],
        cc_started_apps['resources'][0]['entity']['package_state'],
        varz_dea['instance_registry']['application1']['application1_instance1']['state'],
        DateTime.parse(cc_started_apps['resources'][0]['metadata']['created_at']).rfc3339,
        DateTime.parse(cc_started_apps['resources'][0]['metadata']['updated_at']).rfc3339,
        DateTime.parse(Time.at(varz_dea['instance_registry']['application1']['application1_instance1']['state_running_timestamp']).to_s).rfc3339,
        varz_dea['instance_registry']['application1']['application1_instance1']['application_uris'],
        cc_started_apps['resources'][0]['entity']['detected_buildpack'],
        varz_dea['instance_registry']['application1']['application1_instance1']['instance_index'],
        varz_dea['instance_registry']['application1']['application1_instance1']['services'].length,
        AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry']['application1']['application1_instance1']['used_memory_in_bytes']),
        AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry']['application1']['application1_instance1']['used_disk_in_bytes']),
        varz_dea['instance_registry']['application1']['application1_instance1']['computed_pcpu'] * 100,
        cc_started_apps['resources'][0]['entity']['memory'],
        cc_started_apps['resources'][0]['entity']['disk_quota'],
        "#{ cc_organizations['resources'][0]['entity']['name'] }/#{ cc_spaces['resources'][0]['entity']['name'] }",
        nats_dea['host'],
        { 'application'  => cc_started_apps['resources'][0]['entity'].merge(cc_started_apps['resources'][0]['metadata']),
          'instance'     => varz_dea['instance_registry']['application1']['application1_instance1'],
          'organization' => cc_organizations['resources'][0]['entity'].merge(cc_organizations['resources'][0]['metadata']),
          'space'        => cc_spaces['resources'][0]['entity'].merge(cc_spaces['resources'][0]['metadata'])
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
        uaa_users['resources'][0]['emails'][0]['value'],
        cc_spaces['resources'][0]['entity']['name'],
        cc_organizations['resources'][0]['entity']['name'],
        "#{ cc_organizations['resources'][0]['entity']['name'] }/#{ cc_spaces['resources'][0]['entity']['name'] }",
        DateTime.parse(uaa_users['resources'][0]['meta']['created']).rfc3339,
        DateTime.parse(uaa_users['resources'][0]['meta']['lastModified']).rfc3339,
        { 'active'        => uaa_users['resources'][0]['active'],
          'authorities'   => uaa_users['resources'][0]['groups'].map { |group| group['display'] }.sort.join(', '),
          'created'       => uaa_users['resources'][0]['meta']['created'],
          'id'            => uaa_users['resources'][0]['id'],
          'last_modified' => uaa_users['resources'][0]['meta']['lastModified'],
          'version'       => uaa_users['resources'][0]['meta']['version'],
          'email'         => uaa_users['resources'][0]['emails'][0]['value'],
          'familyname'    => uaa_users['resources'][0]['name']['familyName'],
          'givenname'     => uaa_users['resources'][0]['name']['givenName'],
          'username'      => uaa_users['resources'][0]['userName']
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
        cc_organizations['resources'][0]['metadata']['guid'],
        cc_organizations['resources'][0]['entity']['name'],
        cc_organizations['resources'][0]['entity']['status'],
        DateTime.parse(cc_organizations['resources'][0]['metadata']['created_at']).rfc3339,
        DateTime.parse(cc_organizations['resources'][0]['metadata']['updated_at']).rfc3339,
        cc_spaces['resources'].length,
        cc_users_deep['resources'].length,
        cc_quota_definitions['resources'][0]['entity']['name'],
        cc_routes['resources'].length,
        cc_routes['resources'].length,
        0,
        cc_started_apps['resources'][0]['entity']['instances'],
        varz_dea['instance_registry']['application1']['application1_instance1']['services'].length,
        AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry']['application1']['application1_instance1']['used_memory_in_bytes']),
        AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry']['application1']['application1_instance1']['used_disk_in_bytes']),
        varz_dea['instance_registry']['application1']['application1_instance1']['computed_pcpu'] * 100,
        cc_started_apps['resources'][0]['entity']['memory'],
        cc_started_apps['resources'][0]['entity']['disk_quota'],
        cc_started_apps['resources'].length,
        cc_started_apps['resources'][0]['entity']['state'] == 'STARTED' ? 1 : 0,
        cc_started_apps['resources'][0]['entity']['state'] == 'STOPPED' ? 1 : 0,
        cc_started_apps['resources'][0]['entity']['package_state'] == 'PENDING' ? 1 : 0,
        cc_started_apps['resources'][0]['entity']['package_state'] == 'STAGED'  ? 1 : 0,
        cc_started_apps['resources'][0]['entity']['package_state'] == 'FAILED'  ? 1 : 0,
        cc_organizations['resources'][0]['entity'].merge(cc_organizations['resources'][0]['metadata'])
      ]
    ]
  end

  def view_models_quotas
    [
      [
        cc_quota_definitions['resources'][0]['entity']['name'],
        DateTime.parse(cc_quota_definitions['resources'][0]['metadata']['created_at']).rfc3339,
        DateTime.parse(cc_quota_definitions['resources'][0]['metadata']['updated_at']).rfc3339,
        cc_quota_definitions['resources'][0]['entity']['total_services'],
        cc_quota_definitions['resources'][0]['entity']['total_routes'],
        cc_quota_definitions['resources'][0]['entity']['memory_limit'],
        cc_quota_definitions['resources'][0]['entity']['non_basic_services_allowed'],
        cc_quota_definitions['resources'][0]['entity']['trial_db_allowed'],
        1,
        cc_quota_definitions['resources'][0]['entity'].merge(cc_quota_definitions['resources'][0]['metadata'])
      ],
      [
        cc_quota_definitions['resources'][1]['entity']['name'],
        DateTime.parse(cc_quota_definitions['resources'][1]['metadata']['created_at']).rfc3339,
        DateTime.parse(cc_quota_definitions['resources'][1]['metadata']['updated_at']).rfc3339,
        cc_quota_definitions['resources'][1]['entity']['total_services'],
        cc_quota_definitions['resources'][1]['entity']['total_routes'],
        cc_quota_definitions['resources'][1]['entity']['memory_limit'],
        cc_quota_definitions['resources'][1]['entity']['non_basic_services_allowed'],
        cc_quota_definitions['resources'][1]['entity']['trial_db_allowed'],
        0,
        cc_quota_definitions['resources'][1]['entity'].merge(cc_quota_definitions['resources'][1]['metadata'])
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
        cc_routes['resources'][0]['metadata']['guid'],
        cc_routes['resources'][0]['entity']['host'],
        cc_routes['resources'][0]['entity']['domain']['entity']['name'],
        DateTime.parse(cc_routes['resources'][0]['metadata']['created_at']).rfc3339,
        DateTime.parse(cc_routes['resources'][0]['metadata']['updated_at']).rfc3339,
        "#{ cc_organizations['resources'][0]['entity']['name'] }/#{ cc_spaces['resources'][0]['entity']['name'] }",
        cc_routes['resources'][0]['entity']['apps'].map { |app| app['entity']['name'] },
        { 'organization' => cc_organizations['resources'][0]['entity'].merge(cc_organizations['resources'][0]['metadata']),
          'route'        => cc_routes['resources'][0]['entity'].merge(cc_routes['resources'][0]['metadata']),
          'space'        => cc_spaces['resources'][0]['entity'].merge(cc_spaces['resources'][0]['metadata'])
        }
      ]
    ]
  end

  def view_models_service_instances
    [
      [
        cc_service_brokers['resources'][0]['entity']['name'],
        DateTime.parse(cc_service_brokers['resources'][0]['metadata']['created_at']).rfc3339,
        DateTime.parse(cc_service_brokers['resources'][0]['metadata']['updated_at']).rfc3339,
        cc_services['resources'][0]['entity']['provider'],
        cc_services['resources'][0]['entity']['label'],
        cc_services['resources'][0]['entity']['version'],
        DateTime.parse(cc_services['resources'][0]['metadata']['created_at']).rfc3339,
        DateTime.parse(cc_services['resources'][0]['metadata']['updated_at']).rfc3339,
        cc_service_plans['resources'][0]['entity']['name'],
        DateTime.parse(cc_service_plans['resources'][0]['metadata']['created_at']).rfc3339,
        DateTime.parse(cc_service_plans['resources'][0]['metadata']['updated_at']).rfc3339,
        cc_service_plans['resources'][0]['entity']['public'],
        "#{ cc_services['resources'][0]['entity']['provider'] }/#{ cc_services['resources'][0]['entity']['label'] }/#{ cc_service_plans['resources'][0]['entity']['name'] }",
        cc_service_instances['resources'][0]['entity']['name'],
        DateTime.parse(cc_service_instances['resources'][0]['metadata']['created_at']).rfc3339,
        DateTime.parse(cc_service_instances['resources'][0]['metadata']['updated_at']).rfc3339,
        cc_service_bindings['total_results'],
        "#{ cc_organizations['resources'][0]['entity']['name'] }/#{ cc_spaces['resources'][0]['entity']['name'] }",
        { 'bindingsAndApplications' =>
          [
            { 'application'    => cc_started_apps['resources'][0]['entity'].merge(cc_started_apps['resources'][0]['metadata']),
              'serviceBinding' => cc_service_bindings['resources'][0]['entity'].merge(cc_service_bindings['resources'][0]['metadata'])
            }
          ],
          'organization'    => cc_organizations['resources'][0]['entity'].merge(cc_organizations['resources'][0]['metadata']),
          'service'         => cc_services['resources'][0]['entity'].merge(cc_services['resources'][0]['metadata']),
          'serviceBroker'   => cc_service_brokers['resources'][0]['entity'].merge(cc_service_brokers['resources'][0]['metadata']),
          'serviceInstance' => cc_service_instances['resources'][0]['entity'].merge(cc_service_instances['resources'][0]['metadata']),
          'servicePlan'     => cc_service_plans['resources'][0]['entity'].merge(cc_service_plans['resources'][0]['metadata']),
          'space'           => cc_spaces['resources'][0]['entity'].merge(cc_spaces['resources'][0]['metadata'])
        }
      ]
    ]
  end

  def view_models_service_plans
    [
      [
        cc_service_plans['resources'][0]['entity'].merge(cc_service_plans['resources'][0]['metadata']),
        cc_service_plans['resources'][0]['entity']['name'],
        "#{ cc_services['resources'][0]['entity']['provider'] }/#{ cc_services['resources'][0]['entity']['label'] }/#{ cc_service_plans['resources'][0]['entity']['name'] }",
        DateTime.parse(cc_service_plans['resources'][0]['metadata']['created_at']).rfc3339,
        DateTime.parse(cc_service_plans['resources'][0]['metadata']['updated_at']).rfc3339,
        cc_service_plans['resources'][0]['entity']['public'],
        cc_service_instances['resources'].length,
        cc_services['resources'][0]['entity']['provider'],
        cc_services['resources'][0]['entity']['label'],
        cc_services['resources'][0]['entity']['version'],
        DateTime.parse(cc_services['resources'][0]['metadata']['created_at']).rfc3339,
        DateTime.parse(cc_services['resources'][0]['metadata']['updated_at']).rfc3339,
        cc_services['resources'][0]['entity']['active'],
        cc_services['resources'][0]['entity']['bindable'],
        cc_service_brokers['resources'][0]['entity']['name'],
        DateTime.parse(cc_service_brokers['resources'][0]['metadata']['created_at']).rfc3339,
        DateTime.parse(cc_service_brokers['resources'][0]['metadata']['updated_at']).rfc3339,
        { 'service'       => cc_services['resources'][0]['entity'].merge(cc_services['resources'][0]['metadata']),
          'serviceBroker' => cc_service_brokers['resources'][0]['entity'].merge(cc_service_brokers['resources'][0]['metadata']),
          'servicePlan'   => cc_service_plans['resources'][0]['entity'].merge(cc_service_plans['resources'][0]['metadata'])
        }
      ]
    ]
  end

  def view_models_spaces
    [
      [
        cc_spaces['resources'][0]['entity']['name'],
        "#{ cc_organizations['resources'][0]['entity']['name'] }/#{ cc_spaces['resources'][0]['entity']['name'] }",
        DateTime.parse(cc_spaces['resources'][0]['metadata']['created_at']).rfc3339,
        DateTime.parse(cc_spaces['resources'][0]['metadata']['updated_at']).rfc3339,
        cc_users_deep['resources'].length,
        cc_routes['resources'].length,
        cc_routes['resources'].length,
        0,
        cc_started_apps['resources'][0]['entity']['instances'],
        varz_dea['instance_registry']['application1']['application1_instance1']['services'].length,
        AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry']['application1']['application1_instance1']['used_memory_in_bytes']),
        AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry']['application1']['application1_instance1']['used_disk_in_bytes']),
        varz_dea['instance_registry']['application1']['application1_instance1']['computed_pcpu'] * 100,
        cc_started_apps['resources'][0]['entity']['memory'],
        cc_started_apps['resources'][0]['entity']['disk_quota'],
        cc_started_apps['resources'].length,
        cc_started_apps['resources'][0]['entity']['state'] == 'STARTED' ? 1 : 0,
        cc_started_apps['resources'][0]['entity']['state'] == 'STOPPED' ? 1 : 0,
        cc_started_apps['resources'][0]['entity']['package_state'] == 'PENDING' ? 1 : 0,
        cc_started_apps['resources'][0]['entity']['package_state'] == 'STAGED'  ? 1 : 0,
        cc_started_apps['resources'][0]['entity']['package_state'] == 'FAILED'  ? 1 : 0,
        { 'organization' => cc_organizations['resources'][0]['entity'].merge(cc_organizations['resources'][0]['metadata']),
          'space'        => cc_spaces['resources'][0]['entity'].merge(cc_spaces['resources'][0]['metadata'])
        }
      ]
    ]
  end

  def view_models_stats(timestamp)
    [
      [
        DateTime.parse(Time.at(timestamp / 1000.0).to_s).rfc3339,
        cc_organizations['resources'].length,
        cc_spaces['resources'].length,
        cc_users_deep['resources'].length,
        cc_started_apps['resources'].length,
        cc_started_apps['resources'][0]['entity']['instances'],
        cc_started_apps['resources'][0]['entity']['state'] == 'STARTED' ? 1 : 0,
        1,
        { :apps              => cc_started_apps['resources'].length,
          :deas              => 1,
          :organizations     => cc_organizations['resources'].length,
          :running_instances => cc_started_apps['resources'][0]['entity']['state'] == 'STARTED' ? 1 : 0,
          :spaces            => cc_spaces['resources'].length,
          :timestamp         => timestamp,
          :total_instances   => cc_started_apps['resources'][0]['entity']['instances'],
          :users             => cc_users_deep['resources'].length
        }
      ]
    ]
  end
end
