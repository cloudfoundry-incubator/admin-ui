require 'cgi'
require 'time'
require 'yajl'
require_relative '../spec_helper'
require_relative 'cc_helper'
require_relative 'nats_helper'
require_relative 'varz_helper'

module ViewModelsHelper
  include CCHelper
  include DopplerHelper
  include NATSHelper
  include VARZHelper

  BILLION = 1000 * 1000 * 1000

  def view_models_stub(application_instance_source, router_source)
    @application_instance_source = application_instance_source
    @router_source = router_source

    @used_memory_in_bytes = determine_used_memory(application_instance_source)
    @used_disk_in_bytes = determine_used_disk(application_instance_source)
    @computed_pcpu = determine_used_cpu(application_instance_source)

    @dea_identity = "#{dea_envelope.ip}:#{dea_envelope.index}" if application_instance_source == :doppler_dea
  end

  def determine_used_cpu(application_instance_source)
    if application_instance_source == :doppler_cell
      rep_container_metric_envelope.containerMetric.cpuPercentage
    else
      dea_container_metric_envelope.containerMetric.cpuPercentage
    end
  end

  def determine_used_disk(application_instance_source)
    if application_instance_source == :doppler_cell
      rep_container_metric_envelope.containerMetric.diskBytes
    else
      dea_container_metric_envelope.containerMetric.diskBytes
    end
  end

  def determine_used_memory(application_instance_source)
    if application_instance_source == :doppler_cell
      rep_container_metric_envelope.containerMetric.memoryBytes
    else
      dea_container_metric_envelope.containerMetric.memoryBytes
    end
  end

  def annotation_rfc3339(annotation)
    {
      annotation:         annotation,
      created_at_rfc3339: annotation[:created_at].to_datetime.rfc3339,
      updated_at_rfc3339: annotation[:updated_at].to_datetime.rfc3339
    }
  end

  def label_rfc3339(label)
    {
      label:              label,
      created_at_rfc3339: label[:created_at].to_datetime.rfc3339,
      updated_at_rfc3339: label[:updated_at].to_datetime.rfc3339
    }
  end

  def view_models_application_instances
    [
      [
        "#{cc_app[:guid]}/#{cc_app_instance_index}",
        cc_app[:name],
        cc_app[:guid],
        cc_app_instance_index,
        Time.at(rep_envelope.timestamp / BILLION).to_datetime.rfc3339,
        @application_instance_source == :doppler_cell,
        cc_stack[:name],
        AdminUI::Utils.convert_bytes_to_megabytes(@used_memory_in_bytes),
        AdminUI::Utils.convert_bytes_to_megabytes(@used_disk_in_bytes),
        @computed_pcpu,
        cc_process[:memory],
        cc_process[:disk_quota],
        "#{cc_organization[:name]}/#{cc_space[:name]}",
        @dea_identity,
        @application_instance_source == :doppler_cell ? "#{rep_envelope.ip}:#{rep_envelope.index}" : nil
      ]
    ]
  end

  def view_models_application_instances_detail
    container = nil
    case @application_instance_source
    when :doppler_cell
      container =
        {
          application_id:     rep_container_metric_envelope.containerMetric.applicationId,
          cpu_percentage:     rep_container_metric_envelope.containerMetric.cpuPercentage,
          disk_bytes:         rep_container_metric_envelope.containerMetric.diskBytes,
          disk_bytes_quota:   rep_container_metric_envelope.containerMetric.diskBytesQuota,
          index:              rep_envelope.index,
          instance_index:     rep_container_metric_envelope.containerMetric.instanceIndex,
          ip:                 rep_envelope.ip,
          memory_bytes:       rep_container_metric_envelope.containerMetric.memoryBytes,
          memory_bytes_quota: rep_container_metric_envelope.containerMetric.memoryBytesQuota,
          origin:             rep_envelope.origin,
          timestamp:          rep_envelope.timestamp
        }
    when :doppler_dea
      container =
        {
          application_id:     dea_container_metric_envelope.containerMetric.applicationId,
          cpu_percentage:     dea_container_metric_envelope.containerMetric.cpuPercentage,
          disk_bytes:         dea_container_metric_envelope.containerMetric.diskBytes,
          disk_bytes_quota:   dea_container_metric_envelope.containerMetric.diskBytesQuota,
          index:              dea_envelope.index,
          instance_index:     dea_container_metric_envelope.containerMetric.instanceIndex,
          ip:                 dea_envelope.ip,
          memory_bytes:       dea_container_metric_envelope.containerMetric.memoryBytes,
          memory_bytes_quota: dea_container_metric_envelope.containerMetric.memoryBytesQuota,
          origin:             dea_envelope.origin,
          timestamp:          dea_envelope.timestamp
        }
    end

    {
      'application'              => cc_app,
      'buildpack_lifecycle_data' => cc_buildpack_lifecycle_data,
      'container'                => container,
      'organization'             => cc_organization,
      'process'                  => cc_process,
      'space'                    => cc_space,
      'stack'                    => cc_stack
    }
  end

  def view_models_applications
    [
      [
        cc_app[:guid],
        cc_app[:name],
        cc_app[:guid],
        cc_app[:desired_state],
        cc_process[:state],
        cc_droplet[:state],
        cc_droplet[:error_id],
        cc_app[:created_at].to_datetime.rfc3339,
        cc_app[:updated_at].to_datetime.rfc3339,
        cc_process[:diego],
        cc_app[:enable_ssh],
        cc_app[:revisions_enabled],
        !cc_package[:docker_image].nil?,
        cc_stack[:name],
        cc_buildpack[:name],
        cc_buildpack[:guid],
        1,
        cc_process[:instances],
        1,
        1,
        1,
        AdminUI::Utils.convert_bytes_to_megabytes(@used_memory_in_bytes),
        AdminUI::Utils.convert_bytes_to_megabytes(@used_disk_in_bytes),
        @computed_pcpu,
        cc_process[:memory],
        cc_process[:disk_quota],
        "#{cc_organization[:name]}/#{cc_space[:name]}"
      ]
    ]
  end

  def view_models_applications_detail
    {
      'annotations'              => [annotation_rfc3339(cc_app_annotation)],
      'application'              => cc_app,
      'buildpack_lifecycle_data' => cc_buildpack_lifecycle_data,
      'current_droplet'          => cc_droplet,
      'current_package'          => cc_package,
      'environment_variables'    => cc_app_environment_variable,
      'labels'                   => [label_rfc3339(cc_app_label)],
      'latest_droplet'           => cc_droplet,
      'latest_package'           => cc_package,
      'organization'             => cc_organization,
      'process'                  => cc_process,
      'space'                    => cc_space,
      'stack'                    => cc_stack
    }
  end

  def view_models_approvals
    [
      [
        uaa_identity_zone[:name],
        uaa_user[:username],
        uaa_approval[:user_id],
        uaa_approval[:client_id],
        uaa_approval[:scope],
        uaa_approval[:status],
        uaa_approval[:lastmodifiedat].to_datetime.rfc3339,
        uaa_approval[:expiresat].to_datetime.rfc3339,
        CGI.escape(uaa_approval[:client_id])
      ]
    ]
  end

  def view_models_approvals_detail
    {
      'approval'      => uaa_approval,
      'identity_zone' => uaa_identity_zone,
      'user_uaa'      => uaa_user
    }
  end

  def view_models_buildpacks
    [
      [
        cc_buildpack[:guid],
        cc_stack[:name],
        cc_buildpack[:name],
        cc_buildpack[:guid],
        cc_buildpack[:created_at].to_datetime.rfc3339,
        cc_buildpack[:updated_at].to_datetime.rfc3339,
        cc_buildpack[:position],
        cc_buildpack[:enabled],
        cc_buildpack[:locked],
        1
      ]
    ]
  end

  def view_models_buildpacks_detail
    {
      'annotations' => [annotation_rfc3339(cc_buildpack_annotation)],
      'buildpack'   => cc_buildpack,
      'labels'      => [label_rfc3339(cc_buildpack_label)],
      'stack'       => cc_stack
    }
  end

  def view_models_cells
    [
      [
        "#{rep_envelope.ip}:#{rep_envelope.index}",
        rep_envelope.ip,
        rep_envelope.index,
        'doppler',
        Time.at(rep_envelope.timestamp / BILLION).to_datetime.rfc3339,
        'RUNNING',
        REP_VALUE_METRICS['numCPUS'],
        AdminUI::Utils.convert_bytes_to_megabytes(REP_VALUE_METRICS['memoryStats.numBytesAllocated']),
        AdminUI::Utils.convert_bytes_to_megabytes(REP_VALUE_METRICS['memoryStats.numBytesAllocatedHeap']),
        AdminUI::Utils.convert_bytes_to_megabytes(REP_VALUE_METRICS['memoryStats.numBytesAllocatedStack']),
        REP_VALUE_METRICS['CapacityTotalContainers'],
        REP_VALUE_METRICS['CapacityRemainingContainers'],
        REP_VALUE_METRICS['ContainerCount'],
        REP_VALUE_METRICS['CapacityTotalMemory'],
        REP_VALUE_METRICS['CapacityRemainingMemory'],
        REP_VALUE_METRICS['CapacityTotalDisk'],
        REP_VALUE_METRICS['CapacityRemainingDisk']
      ]
    ]
  end

  def view_models_cells_detail
    {
      'connected' => true,
      'index'     => rep_envelope.index,
      'ip'        => rep_envelope.ip,
      'origin'    => rep_envelope.origin,
      'timestamp' => rep_envelope.timestamp
    }.merge(REP_VALUE_METRICS)
  end

  def view_models_clients
    [
      [
        uaa_client[:client_id],
        uaa_identity_zone[:name],
        uaa_client[:client_id],
        uaa_client[:lastmodified].to_datetime.rfc3339,
        uaa_client[:scope].split(',').sort,
        uaa_client[:authorized_grant_types].split(',').sort,
        uaa_client[:web_server_redirect_uri].split(',').sort,
        uaa_client[:authorities].split(',').sort,
        [uaa_client_autoapprove.to_s],
        uaa_client[:required_user_groups].split(',').sort,
        uaa_client[:access_token_validity],
        uaa_client[:refresh_token_validity],
        1,
        1,
        1,
        cc_service_broker[:name]
      ]
    ]
  end

  def view_models_clients_detail
    {
      'client'         => uaa_client,
      'identity_zone'  => uaa_identity_zone,
      'service_broker' => cc_service_broker
    }
  end

  def view_models_cloud_controllers
    [
      [
        nats_cloud_controller['host'],
        nats_cloud_controller['index'],
        'varz',
        'RUNNING',
        DateTime.parse(varz_cloud_controller['start']).rfc3339,
        varz_cloud_controller['num_cores'],
        varz_cloud_controller['cpu'],
        AdminUI::Utils.convert_kilobytes_to_megabytes(varz_cloud_controller['mem_bytes'])
      ]
    ]
  end

  def view_models_cloud_controllers_detail
    {
      'connected' => true,
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
        nats_cloud_controller['index'].to_s,
        'varz',
        nil,
        'RUNNING',
        DateTime.parse(varz_cloud_controller['start']).rfc3339,
        nats_cloud_controller['host'],
        nats_cloud_controller_varz
      ],
      [
        nats_provisioner['host'],
        nats_provisioner['type'],
        nats_provisioner['index'].to_s,
        'varz',
        nil,
        'RUNNING',
        DateTime.parse(varz_provisioner['start']).rfc3339,
        nats_provisioner['host'],
        nats_provisioner_varz
      ],
      [
        nats_router['host'],
        nats_router['type'],
        nats_router['index'].to_s,
        'varz',
        nil,
        'RUNNING',
        DateTime.parse(varz_router['start']).rfc3339,
        nats_router['host'],
        nats_router_varz
      ],
      [
        "#{analyzer_envelope.ip}:#{analyzer_envelope.index}",
        analyzer_envelope.origin,
        analyzer_envelope.index,
        'doppler',
        Time.at(analyzer_envelope.timestamp / BILLION).to_datetime.rfc3339,
        'RUNNING',
        nil,
        "#{analyzer_envelope.origin}:#{analyzer_envelope.index}:#{analyzer_envelope.ip}",
        "#{analyzer_envelope.origin}:#{analyzer_envelope.index}:#{analyzer_envelope.ip}"
      ],
      [
        "#{dea_envelope.ip}:#{dea_envelope.index}",
        dea_envelope.origin,
        dea_envelope.index,
        'doppler',
        Time.at(dea_envelope.timestamp / BILLION).to_datetime.rfc3339,
        'RUNNING',
        nil,
        "#{dea_envelope.origin}:#{dea_envelope.index}:#{dea_envelope.ip}",
        "#{dea_envelope.origin}:#{dea_envelope.index}:#{dea_envelope.ip}"
      ]
    ]
  end

  def view_models_components_detail
    {
      'doppler_component' => nil,
      'varz_component'    => view_models_cloud_controllers_detail
    }
  end

  def view_models_deas
    [
      [
        "#{dea_envelope.ip}:#{dea_envelope.index}",
        dea_envelope.index,
        'doppler',
        @application_instance_source == :doppler_dea ? Time.at(dea_envelope.timestamp / BILLION).to_datetime.rfc3339 : nil,
        'RUNNING',
        DEA_VALUE_METRICS['instances'],
        cc_process[:instances],
        AdminUI::Utils.convert_bytes_to_megabytes(@used_memory_in_bytes),
        AdminUI::Utils.convert_bytes_to_megabytes(@used_disk_in_bytes),
        @computed_pcpu,
        DEA_VALUE_METRICS['available_memory_ratio'] * 100,
        DEA_VALUE_METRICS['available_disk_ratio'] * 100,
        DEA_VALUE_METRICS['remaining_memory'],
        DEA_VALUE_METRICS['remaining_disk']
      ]
    ]
  end

  def view_models_deas_detail
    {
      'connected' => true,
      'index'     => dea_envelope.index,
      'ip'        => dea_envelope.ip,
      'origin'    => dea_envelope.origin,
      'timestamp' => dea_envelope.timestamp
    }.merge(DEA_VALUE_METRICS)
  end

  def view_models_domains
    [
      [
        "#{cc_domain[:guid]}/false",
        cc_domain[:name],
        cc_domain[:guid],
        cc_domain[:created_at].to_datetime.rfc3339,
        cc_domain[:updated_at].to_datetime.rfc3339,
        cc_domain[:internal],
        false,
        cc_organization[:name],
        1,
        1
      ]
    ]
  end

  def view_models_domains_detail
    {
      'annotations'                  => [annotation_rfc3339(cc_domain_annotation)],
      'domain'                       => cc_domain,
      'labels'                       => [label_rfc3339(cc_domain_label)],
      'owning_organization'          => cc_organization,
      'private_shared_organizations' => [cc_organization]
    }
  end

  def view_models_environment_groups
    [
      [
        cc_env_group[:name],
        cc_env_group[:guid],
        cc_env_group[:created_at].to_datetime.rfc3339,
        cc_env_group[:updated_at].to_datetime.rfc3339
      ]
    ]
  end

  def view_models_environment_groups_detail
    cc_env_group.merge(variables: cc_env_group_variable)
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
        cc_event_space[:actor_username],
        cc_event_space[:actor_name],
        cc_event_space[:actor],
        "#{cc_organization[:name]}/#{cc_space[:name]}"
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

  def view_models_feature_flags
    [
      [
        cc_feature_flag[:name],
        cc_feature_flag[:name],
        cc_feature_flag[:guid],
        cc_feature_flag[:created_at].to_datetime.rfc3339,
        cc_feature_flag[:updated_at].to_datetime.rfc3339,
        cc_feature_flag[:enabled]
      ]
    ]
  end

  def view_models_feature_flags_detail
    cc_feature_flag
  end

  def view_models_gateways
    [
      [
        nats_provisioner['type'].sub('-Provisioner', ''),
        nats_provisioner['index'],
        'varz',
        'RUNNING',
        DateTime.parse(varz_provisioner['start']).rfc3339,
        varz_provisioner['config']['service']['description'],
        varz_provisioner['cpu'],
        AdminUI::Utils.convert_kilobytes_to_megabytes(varz_provisioner['mem']),
        varz_provisioner['nodes'].length,
        10
      ]
    ]
  end

  def view_models_gateways_detail
    {
      'connected' => true,
      'data'      => varz_provisioner,
      'index'     => nats_provisioner['index'],
      'name'      => nats_provisioner['type'].sub('-Provisioner', ''),
      'type'      => nats_provisioner['type'],
      'uri'       => nats_provisioner_varz
    }
  end

  def view_models_group_members
    [
      [
        "#{uaa_group[:id]}/#{uaa_user[:id]}",
        uaa_identity_zone[:name],
        uaa_group[:displayname],
        uaa_group[:id],
        uaa_user[:username],
        uaa_user[:id],
        uaa_group_membership[:added].to_datetime.rfc3339
      ]
    ]
  end

  def view_models_group_members_detail
    {
      'group'            => uaa_group,
      'group_membership' => uaa_group_membership,
      'identity_zone'    => uaa_identity_zone,
      'user_uaa'         => uaa_user
    }
  end

  def view_models_groups
    [
      [
        uaa_group[:id],
        uaa_identity_zone[:name],
        uaa_group[:displayname],
        uaa_group[:id],
        uaa_group[:created].to_datetime.rfc3339,
        uaa_group[:lastmodified].to_datetime.rfc3339,
        uaa_group[:version],
        1
      ]
    ]
  end

  def view_models_groups_detail
    {
      'group'         => uaa_group,
      'identity_zone' => uaa_identity_zone
    }
  end

  def view_models_health_managers
    [
      [
        "#{analyzer_envelope.ip}:#{analyzer_envelope.index}",
        analyzer_envelope.index,
        'doppler',
        Time.at(analyzer_envelope.timestamp / BILLION).to_datetime.rfc3339,
        'RUNNING',
        ANALYZER_VALUE_METRICS['numCPUS'],
        AdminUI::Utils.convert_bytes_to_megabytes(ANALYZER_VALUE_METRICS['memoryStats.numBytesAllocated'])
      ]
    ]
  end

  def view_models_health_managers_detail
    {
      'connected' => true,
      'index'     => analyzer_envelope.index,
      'ip'        => analyzer_envelope.ip,
      'origin'    => analyzer_envelope.origin,
      'timestamp' => analyzer_envelope.timestamp
    }.merge(ANALYZER_VALUE_METRICS)
  end

  def view_models_identity_providers
    [
      [
        uaa_identity_provider[:id],
        uaa_identity_zone[:name],
        uaa_identity_provider[:name],
        uaa_identity_provider[:id],
        uaa_identity_provider[:created].to_datetime.rfc3339,
        uaa_identity_provider[:lastmodified].to_datetime.rfc3339,
        uaa_identity_provider[:origin_key],
        uaa_identity_provider[:type],
        uaa_identity_provider[:active],
        uaa_identity_provider[:version]
      ]
    ]
  end

  def view_models_identity_providers_detail
    {
      'identity_provider' => uaa_identity_provider,
      'identity_zone'     => uaa_identity_zone
    }
  end

  def view_models_identity_zones
    [
      [
        uaa_identity_zone[:id],
        uaa_identity_zone[:name],
        uaa_identity_zone[:id],
        uaa_identity_zone[:created].to_datetime.rfc3339,
        uaa_identity_zone[:lastmodified].to_datetime.rfc3339,
        uaa_identity_zone[:subdomain],
        uaa_identity_zone[:active],
        uaa_identity_zone[:version],
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        uaa_identity_zone[:description]
      ]
    ]
  end

  def view_models_identity_zones_detail
    uaa_identity_zone
  end

  def view_models_isolation_segments
    [
      [
        cc_isolation_segment[:guid],
        cc_isolation_segment[:name],
        cc_isolation_segment[:guid],
        cc_isolation_segment[:created_at].to_datetime.rfc3339,
        cc_isolation_segment[:updated_at].to_datetime.rfc3339,
        1,
        1,
        1
      ]
    ]
  end

  def view_models_isolation_segments_detail
    {
      'annotations'       => [annotation_rfc3339(cc_isolation_segment_annotation)],
      'isolation_segment' => cc_isolation_segment,
      'labels'            => [label_rfc3339(cc_isolation_segment_label)]
    }
  end

  def view_models_logs(log_file_displayed, log_file_displayed_contents_length, log_file_displayed_modified_milliseconds)
    [
      [
        log_file_displayed,
        log_file_displayed_contents_length,
        Time.at(log_file_displayed_modified_milliseconds / 1000.0).to_datetime.rfc3339,
        {
          path: log_file_displayed,
          size: log_file_displayed_contents_length,
          time: log_file_displayed_modified_milliseconds
        }
      ]
    ]
  end

  def view_models_mfa_providers
    config = Yajl::Parser.parse(uaa_mfa_provider[:config])

    [
      [
        uaa_mfa_provider[:id],
        uaa_identity_zone[:name],
        uaa_mfa_provider[:type],
        uaa_mfa_provider[:name],
        uaa_mfa_provider[:id],
        uaa_mfa_provider[:created].to_datetime.rfc3339,
        uaa_mfa_provider[:lastmodified].to_datetime.rfc3339,
        config['issuer'],
        config['algorithm'],
        config['digits'],
        config['duration']
      ]
    ]
  end

  def view_models_mfa_providers_detail
    {
      'identity_zone' => uaa_identity_zone,
      'mfa_provider'  => uaa_mfa_provider
    }
  end

  def view_models_organization_roles
    [
      [
        "#{cc_organization[:guid]}/#{cc_organization_auditor[:role_guid]}/auditors/#{uaa_user[:id]}",
        'Auditor',
        cc_organization_auditor[:role_guid],
        cc_organization_auditor[:created_at].to_datetime.rfc3339,
        cc_organization_auditor[:updated_at].to_datetime.rfc3339,
        cc_organization[:name],
        cc_organization[:guid],
        uaa_user[:username],
        uaa_user[:id]
      ],
      [
        "#{cc_organization[:guid]}/#{cc_organization_billing_manager[:role_guid]}/billing_managers/#{uaa_user[:id]}",
        'Billing Manager',
        cc_organization_billing_manager[:role_guid],
        cc_organization_billing_manager[:created_at].to_datetime.rfc3339,
        cc_organization_billing_manager[:updated_at].to_datetime.rfc3339,
        cc_organization[:name],
        cc_organization[:guid],
        uaa_user[:username],
        uaa_user[:id]
      ],
      [
        "#{cc_organization[:guid]}/#{cc_organization_manager[:role_guid]}/managers/#{uaa_user[:id]}",
        'Manager',
        cc_organization_manager[:role_guid],
        cc_organization_manager[:created_at].to_datetime.rfc3339,
        cc_organization_manager[:updated_at].to_datetime.rfc3339,
        cc_organization[:name],
        cc_organization[:guid],
        uaa_user[:username],
        uaa_user[:id]
      ],
      [
        "#{cc_organization[:guid]}/#{cc_organization_user[:role_guid]}/users/#{uaa_user[:id]}",
        'User',
        cc_organization_user[:role_guid],
        cc_organization_user[:created_at].to_datetime.rfc3339,
        cc_organization_user[:updated_at].to_datetime.rfc3339,
        cc_organization[:name],
        cc_organization[:guid],
        uaa_user[:username],
        uaa_user[:id]
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
        1,
        1,
        4,
        3,
        1,
        cc_quota_definition[:name],
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        0,
        1,
        cc_process[:instances],
        1,
        1,
        AdminUI::Utils.convert_bytes_to_megabytes(@used_memory_in_bytes),
        AdminUI::Utils.convert_bytes_to_megabytes(@used_disk_in_bytes),
        @computed_pcpu,
        cc_process[:memory],
        cc_process[:disk_quota],
        cc_app[:desired_state] == 'STARTED' ? 1 : 0,
        cc_app[:desired_state] == 'STOPPED' ? 1 : 0,
        cc_process[:state] == 'STARTED' ? 1 : 0,
        cc_process[:state] == 'STOPPED' ? 1 : 0,
        cc_droplet[:state] == 'PENDING' ? 1 : 0,
        cc_droplet[:state] == 'STAGED' ? 1 : 0,
        cc_droplet[:state] == 'FAILED' ? 1 : 0,
        cc_isolation_segment[:name],
        cc_isolation_segment[:guid],
        1
      ]
    ]
  end

  def view_models_organizations_detail
    {
      'annotations'               => [annotation_rfc3339(cc_organization_annotation)],
      'default_isolation_segment' => cc_isolation_segment,
      'labels'                    => [label_rfc3339(cc_organization_label)],
      'organization'              => cc_organization,
      'quota_definition'          => cc_quota_definition
    }
  end

  def view_models_organizations_isolation_segments
    [
      [
        "#{cc_organization[:guid]}/#{cc_isolation_segment[:guid]}",
        cc_organization[:name],
        cc_organization[:guid],
        cc_isolation_segment[:name],
        cc_isolation_segment[:guid]
      ]
    ]
  end

  def view_models_organizations_isolation_segments_detail
    {
      'isolation_segment'              => cc_isolation_segment,
      'organization'                   => cc_organization,
      'organization_isolation_segment' => cc_organization_isolation_segment
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
        cc_quota_definition[:total_private_domains],
        cc_quota_definition[:total_services],
        cc_quota_definition[:total_service_keys],
        cc_quota_definition[:total_routes],
        cc_quota_definition[:total_reserved_route_ports],
        cc_quota_definition[:app_instance_limit],
        cc_quota_definition[:app_task_limit],
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

  def view_models_revocable_tokens
    [
      [
        uaa_revocable_token[:token_id],
        uaa_identity_zone[:name],
        uaa_revocable_token[:token_id],
        Time.at(uaa_revocable_token[:issued_at] / 1000.0).to_datetime.rfc3339,
        Time.at(uaa_revocable_token[:expires_at] / 1000.0).to_datetime.rfc3339,
        uaa_revocable_token[:format],
        uaa_revocable_token[:response_type],
        uaa_revocable_token[:scope][1...-1].split(', ').sort,
        uaa_client[:client_id],
        uaa_user[:username],
        uaa_user[:id]
      ]
    ]
  end

  def view_models_revocable_tokens_detail
    {
      'client'          => uaa_client,
      'identity_zone'   => uaa_identity_zone,
      'revocable_token' => uaa_revocable_token,
      'user_uaa'        => uaa_user
    }
  end

  def view_models_routers
    [
      [
        @router_source == :doppler_router ? "#{gorouter_envelope.ip}:#{gorouter_envelope.index}" : nats_router['host'],
        @router_source == :doppler_router ? gorouter_envelope.index : nats_router['index'].to_s,
        @router_source == :doppler_router ? 'doppler' : 'varz',
        @router_source == :doppler_router ? Time.at(gorouter_envelope.timestamp / BILLION).to_datetime.rfc3339 : nil,
        'RUNNING',
        @router_source == :doppler_router ? nil : DateTime.parse(varz_router['start']).rfc3339,
        @router_source == :doppler_router ? GOROUTER_VALUE_METRICS['numCPUS'] : varz_router['num_cores'],
        @router_source == :doppler_router ? nil : varz_router['cpu'],
        @router_source == :doppler_router ? AdminUI::Utils.convert_bytes_to_megabytes(GOROUTER_VALUE_METRICS['memoryStats.numBytesAllocated']) : AdminUI::Utils.convert_kilobytes_to_megabytes(varz_router['mem_bytes']),
        @router_source == :doppler_router ? nil : varz_router['droplets'],
        @router_source == :doppler_router ? nil : varz_router['requests'],
        @router_source == :doppler_router ? nil : varz_router['bad_requests']
      ]
    ]
  end

  def view_models_routers_detail
    doppler_gorouter_hash = nil
    varz_router_hash      = nil
    top10_apps_array      = nil

    if @router_source == :doppler_router
      doppler_gorouter_hash =
        {
          'connected' => true,
          'index'     => gorouter_envelope.index,
          'ip'        => gorouter_envelope.ip,
          'origin'    => gorouter_envelope.origin,
          'timestamp' => gorouter_envelope.timestamp
        }.merge(GOROUTER_VALUE_METRICS)
    else
      varz_router_hash =
        {
          'connected' => true,
          'data'      => varz_router,
          'index'     => nats_router['index'],
          'name'      => nats_router['host'],
          'type'      => nats_router['type'],
          'uri'       => nats_router_varz
        }

      top10_apps_array =
        [
          {
            'guid'   => cc_app[:guid],
            'name'   => cc_app[:name],
            'rpm'    => varz_router['top10_app_requests'][0]['rpm'],
            'rps'    => varz_router['top10_app_requests'][0]['rps'],
            'target' => "#{cc_organization[:name]}/#{cc_space[:name]}"
          }
        ]

    end

    {
      'doppler_gorouter' => doppler_gorouter_hash,
      'varz_router'      => varz_router_hash,
      'top_10_apps'      => top10_apps_array
    }
  end

  def view_models_route_bindings
    [
      [
        "#{cc_service_instance[:guid]}/#{cc_route[:guid]}/#{cc_service_instance[:is_gateway_service]}",
        cc_route_binding[:guid],
        cc_route_binding[:created_at].to_datetime.rfc3339,
        cc_route_binding[:updated_at].to_datetime.rfc3339,
        cc_route_binding_operation[:type],
        cc_route_binding_operation[:state],
        cc_route_binding_operation[:created_at].to_datetime.rfc3339,
        cc_route_binding_operation[:updated_at].to_datetime.rfc3339,
        "http://#{cc_route[:host]}.#{cc_domain[:name]}#{cc_route[:path]}",
        cc_route[:guid],
        cc_service_instance[:name],
        cc_service_instance[:guid],
        cc_service_instance[:created_at].to_datetime.rfc3339,
        cc_service_instance[:updated_at].to_datetime.rfc3339,
        cc_service_plan[:name],
        cc_service_plan[:guid],
        cc_service_plan[:unique_id],
        cc_service_plan[:created_at].to_datetime.rfc3339,
        cc_service_plan[:updated_at].to_datetime.rfc3339,
        cc_service_plan[:free],
        cc_service_plan[:active],
        cc_service_plan[:public],
        cc_service[:label],
        cc_service[:guid],
        cc_service[:unique_id],
        cc_service[:created_at].to_datetime.rfc3339,
        cc_service[:updated_at].to_datetime.rfc3339,
        cc_service[:active],
        cc_service_broker[:name],
        cc_service_broker[:guid],
        cc_service_broker[:created_at].to_datetime.rfc3339,
        cc_service_broker[:updated_at].to_datetime.rfc3339,
        "#{cc_organization[:name]}/#{cc_space[:name]}"
      ]
    ]
  end

  def view_models_route_bindings_detail
    {
      'annotations'             => [annotation_rfc3339(cc_route_binding_annotation)],
      'domain'                  => cc_domain,
      'labels'                  => [label_rfc3339(cc_route_binding_label)],
      'organization'            => cc_organization,
      'route'                   => cc_route,
      'route_binding'           => cc_route_binding,
      'route_binding_operation' => cc_route_binding_operation,
      'service'                 => cc_service,
      'service_broker'          => cc_service_broker,
      'service_instance'        => cc_service_instance,
      'service_plan'            => cc_service_plan,
      'space'                   => cc_space
    }
  end

  def view_models_route_mappings
    [
      [
        "#{cc_route_mapping[:guid]}/#{cc_route[:guid]}",
        cc_route_mapping[:guid],
        cc_route_mapping[:created_at].to_datetime.rfc3339,
        cc_route_mapping[:updated_at].to_datetime.rfc3339,
        cc_route_mapping[:weight],
        cc_app[:name],
        cc_app[:guid],
        "http://#{cc_route[:host]}.#{cc_domain[:name]}#{cc_route[:path]}",
        cc_route[:guid],
        "#{cc_organization[:name]}/#{cc_space[:name]}"
      ]
    ]
  end

  def view_models_route_mappings_detail
    {
      'application'   => cc_app,
      'domain'        => cc_domain,
      'organization'  => cc_organization,
      'route'         => cc_route,
      'route_mapping' => cc_route_mapping,
      'space'         => cc_space
    }
  end

  def view_models_routes
    [
      [
        cc_route[:guid],
        "http://#{cc_route[:host]}.#{cc_domain[:name]}#{cc_route[:path]}",
        cc_route[:host],
        cc_domain[:name],
        nil,
        cc_route[:path],
        cc_route[:vip_offset],
        cc_route[:guid],
        cc_route[:created_at].to_datetime.rfc3339,
        cc_route[:updated_at].to_datetime.rfc3339,
        1,
        1,
        1,
        "#{cc_organization[:name]}/#{cc_space[:name]}"
      ]
    ]
  end

  def view_models_routes_detail
    {
      'annotations'  => [annotation_rfc3339(cc_route_annotation)],
      'domain'       => cc_domain,
      'labels'       => [label_rfc3339(cc_route_label)],
      'organization' => cc_organization,
      'route'        => cc_route,
      'space'        => cc_space
    }
  end

  def view_models_security_groups
    [
      [
        cc_security_group[:guid],
        cc_security_group[:name],
        cc_security_group[:guid],
        cc_security_group[:created_at].to_datetime.rfc3339,
        cc_security_group[:updated_at].to_datetime.rfc3339,
        cc_security_group[:staging_default],
        cc_security_group[:running_default],
        1,
        1
      ]
    ]
  end

  def view_models_security_groups_detail
    cc_security_group
  end

  def view_models_security_groups_spaces
    [
      [
        "#{cc_security_group[:guid]}/#{cc_space[:guid]}",
        cc_security_group[:name],
        cc_security_group[:guid],
        cc_security_group[:created_at].to_datetime.rfc3339,
        cc_security_group[:updated_at].to_datetime.rfc3339,
        cc_space[:name],
        cc_space[:guid],
        cc_space[:created_at].to_datetime.rfc3339,
        cc_space[:updated_at].to_datetime.rfc3339,
        "#{cc_organization[:name]}/#{cc_space[:name]}"
      ]
    ]
  end

  def view_models_security_groups_spaces_detail
    {
      'organization'         => cc_organization,
      'security_group'       => cc_security_group,
      'security_group_space' => cc_security_group_space,
      'space'                => cc_space
    }
  end

  def view_models_service_bindings
    [
      [
        cc_service_binding[:guid],
        cc_service_binding[:name],
        cc_service_binding[:guid],
        cc_service_binding[:created_at].to_datetime.rfc3339,
        cc_service_binding[:updated_at].to_datetime.rfc3339,
        !cc_service_binding[:syslog_drain_url].nil? && cc_service_binding[:syslog_drain_url].length.positive?,
        1,
        cc_service_binding_operation[:type],
        cc_service_binding_operation[:state],
        cc_service_binding_operation[:created_at].to_datetime.rfc3339,
        cc_service_binding_operation[:updated_at].to_datetime.rfc3339,
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
        cc_service_plan[:free],
        cc_service_plan[:active],
        cc_service_plan[:public],
        cc_service[:label],
        cc_service[:guid],
        cc_service[:unique_id],
        cc_service[:created_at].to_datetime.rfc3339,
        cc_service[:updated_at].to_datetime.rfc3339,
        cc_service[:active],
        cc_service_broker[:name],
        cc_service_broker[:guid],
        cc_service_broker[:created_at].to_datetime.rfc3339,
        cc_service_broker[:updated_at].to_datetime.rfc3339,
        "#{cc_organization[:name]}/#{cc_space[:name]}"
      ]
    ]
  end

  def view_models_service_bindings_detail
    {
      'annotations'               => [annotation_rfc3339(cc_service_binding_annotation)],
      'application'               => cc_app,
      'credentials'               => cc_service_binding_credential,
      'labels'                    => [label_rfc3339(cc_service_binding_label)],
      'organization'              => cc_organization,
      'service'                   => cc_service,
      'service_binding'           => cc_service_binding,
      'service_binding_operation' => cc_service_binding_operation,
      'service_broker'            => cc_service_broker,
      'service_instance'          => cc_service_instance,
      'service_plan'              => cc_service_plan,
      'space'                     => cc_space,
      'volume_mounts'             => cc_service_binding_volume_mounts
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
        cc_service_broker[:state],
        1,
        uaa_client[:client_id],
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        "#{cc_organization[:name]}/#{cc_space[:name]}"
      ]
    ]
  end

  def view_models_service_brokers_detail
    {
      'annotations'    => [annotation_rfc3339(cc_service_broker_annotation)],
      'labels'         => [label_rfc3339(cc_service_broker_label)],
      'organization'   => cc_organization,
      'service_broker' => cc_service_broker,
      'space'          => cc_space
    }
  end

  def view_models_service_instances
    [
      [
        "#{cc_service_instance[:guid]}/#{cc_service_instance[:is_gateway_service]}",
        cc_service_instance[:name],
        cc_service_instance[:guid],
        cc_service_instance[:created_at].to_datetime.rfc3339,
        cc_service_instance[:updated_at].to_datetime.rfc3339,
        !cc_service_instance[:is_gateway_service],
        !cc_service_instance[:syslog_drain_url].nil? && cc_service_instance[:syslog_drain_url].length.positive?,
        1,
        1,
        1,
        1,
        1,
        cc_service_instance_operation[:type],
        cc_service_instance_operation[:state],
        cc_service_instance_operation[:created_at].to_datetime.rfc3339,
        cc_service_instance_operation[:updated_at].to_datetime.rfc3339,
        cc_service_plan[:name],
        cc_service_plan[:guid],
        cc_service_plan[:unique_id],
        cc_service_plan[:created_at].to_datetime.rfc3339,
        cc_service_plan[:updated_at].to_datetime.rfc3339,
        cc_service_plan[:bindable],
        cc_service_plan[:free],
        cc_service_plan[:active],
        cc_service_plan[:public],
        cc_service[:label],
        cc_service[:guid],
        cc_service[:unique_id],
        cc_service[:created_at].to_datetime.rfc3339,
        cc_service[:updated_at].to_datetime.rfc3339,
        cc_service[:bindable],
        cc_service[:active],
        cc_service_broker[:name],
        cc_service_broker[:guid],
        cc_service_broker[:created_at].to_datetime.rfc3339,
        cc_service_broker[:updated_at].to_datetime.rfc3339,
        "#{cc_organization[:name]}/#{cc_space[:name]}"
      ]
    ]
  end

  def view_models_service_instances_detail
    {
      'annotations'                => [annotation_rfc3339(cc_service_instance_annotation)],
      'credentials'                => cc_service_instance_credential,
      'labels'                     => [label_rfc3339(cc_service_instance_label)],
      'organization'               => cc_organization,
      'service'                    => cc_service,
      'service_broker'             => cc_service_broker,
      'service_instance'           => cc_service_instance,
      'service_instance_operation' => cc_service_instance_operation,
      'service_plan'               => cc_service_plan,
      'space'                      => cc_space
    }
  end

  def view_models_service_keys
    [
      [
        cc_service_key[:guid],
        cc_service_key[:name],
        cc_service_key[:guid],
        cc_service_key[:created_at].to_datetime.rfc3339,
        cc_service_key[:updated_at].to_datetime.rfc3339,
        1,
        cc_service_key_operation[:type],
        cc_service_key_operation[:state],
        cc_service_key_operation[:created_at].to_datetime.rfc3339,
        cc_service_key_operation[:updated_at].to_datetime.rfc3339,
        cc_service_instance[:name],
        cc_service_instance[:guid],
        cc_service_instance[:created_at].to_datetime.rfc3339,
        cc_service_instance[:updated_at].to_datetime.rfc3339,
        cc_service_plan[:name],
        cc_service_plan[:guid],
        cc_service_plan[:unique_id],
        cc_service_plan[:created_at].to_datetime.rfc3339,
        cc_service_plan[:updated_at].to_datetime.rfc3339,
        cc_service_plan[:free],
        cc_service_plan[:active],
        cc_service_plan[:public],
        cc_service[:label],
        cc_service[:guid],
        cc_service[:unique_id],
        cc_service[:created_at].to_datetime.rfc3339,
        cc_service[:updated_at].to_datetime.rfc3339,
        cc_service[:active],
        cc_service_broker[:name],
        cc_service_broker[:guid],
        cc_service_broker[:created_at].to_datetime.rfc3339,
        cc_service_broker[:updated_at].to_datetime.rfc3339,
        "#{cc_organization[:name]}/#{cc_space[:name]}"
      ]
    ]
  end

  def view_models_service_keys_detail
    {
      'annotations'           => [annotation_rfc3339(cc_service_key_annotation)],
      'credentials'           => cc_service_key_credential,
      'labels'                => [label_rfc3339(cc_service_key_label)],
      'organization'          => cc_organization,
      'service'               => cc_service,
      'service_broker'        => cc_service_broker,
      'service_instance'      => cc_service_instance,
      'service_key'           => cc_service_key,
      'service_key_operation' => cc_service_key_operation,
      'service_plan'          => cc_service_plan,
      'space'                 => cc_space
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
        cc_service_plan[:bindable],
        cc_service_plan[:plan_updateable],
        cc_service_plan[:free],
        cc_service_plan[:active],
        cc_service_plan[:public],
        cc_service_plan_display_name,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        cc_service[:label],
        cc_service[:guid],
        cc_service[:unique_id],
        cc_service[:created_at].to_datetime.rfc3339,
        cc_service[:updated_at].to_datetime.rfc3339,
        cc_service[:bindable],
        cc_service[:active],
        cc_service_broker[:name],
        cc_service_broker[:guid],
        cc_service_broker[:created_at].to_datetime.rfc3339,
        cc_service_broker[:updated_at].to_datetime.rfc3339
      ]
    ]
  end

  def view_models_service_plans_detail
    {
      'annotations'    => [annotation_rfc3339(cc_service_plan_annotation)],
      'labels'         => [label_rfc3339(cc_service_plan_label)],
      'service'        => cc_service,
      'service_broker' => cc_service_broker,
      'service_plan'   => cc_service_plan
    }
  end

  def view_models_service_plan_visibilities
    [
      [
        "#{cc_service_plan_visibility[:guid]}/#{cc_service_plan[:guid]}/#{cc_organization[:guid]}",
        cc_service_plan_visibility[:guid],
        cc_service_plan_visibility[:created_at].to_datetime.rfc3339,
        cc_service_plan_visibility[:updated_at].to_datetime.rfc3339,
        1,
        cc_service_plan[:name],
        cc_service_plan[:guid],
        cc_service_plan[:unique_id],
        cc_service_plan[:created_at].to_datetime.rfc3339,
        cc_service_plan[:updated_at].to_datetime.rfc3339,
        cc_service_plan[:bindable],
        cc_service_plan[:free],
        cc_service_plan[:active],
        cc_service_plan[:public],
        cc_service[:label],
        cc_service[:guid],
        cc_service[:unique_id],
        cc_service[:created_at].to_datetime.rfc3339,
        cc_service[:updated_at].to_datetime.rfc3339,
        cc_service[:bindable],
        cc_service[:active],
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
    {
      'organization'            => cc_organization,
      'service'                 => cc_service,
      'service_broker'          => cc_service_broker,
      'service_plan'            => cc_service_plan,
      'service_plan_visibility' => cc_service_plan_visibility
    }
  end

  def view_models_service_providers
    [
      [
        uaa_service_provider[:id],
        uaa_identity_zone[:name],
        uaa_service_provider[:name],
        uaa_service_provider[:id],
        uaa_service_provider[:entity_id],
        uaa_service_provider[:created].to_datetime.rfc3339,
        uaa_service_provider[:lastmodified].to_datetime.rfc3339,
        uaa_service_provider[:active],
        uaa_service_provider[:version]
      ]
    ]
  end

  def view_models_service_providers_detail
    {
      'identity_zone'    => uaa_identity_zone,
      'service_provider' => uaa_service_provider
    }
  end

  def view_models_services
    [
      [
        cc_service[:guid],
        cc_service[:label],
        cc_service[:guid],
        cc_service[:unique_id],
        cc_service[:created_at].to_datetime.rfc3339,
        cc_service[:updated_at].to_datetime.rfc3339,
        cc_service[:bindable],
        cc_service[:plan_updateable],
        cc_service[:instances_retrievable],
        cc_service[:bindings_retrievable],
        cc_service[:allow_context_updates],
        cc_service_shareable,
        cc_service[:active],
        cc_service_provider_display_name,
        cc_service_display_name,
        Yajl::Parser.parse(cc_service[:requires]).sort,
        1,
        1,
        1,
        1,
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
    {
      'annotations'    => [annotation_rfc3339(cc_service_offering_annotation)],
      'labels'         => [label_rfc3339(cc_service_offering_label)],
      'service'        => cc_service,
      'service_broker' => cc_service_broker
    }
  end

  def view_models_shared_service_instances
    [
      [
        "#{cc_service_instance[:guid]}/#{cc_space[:guid]}",
        cc_service_instance[:name],
        cc_service_instance[:guid],
        cc_service_instance[:created_at].to_datetime.rfc3339,
        cc_service_instance[:updated_at].to_datetime.rfc3339,
        cc_service_plan[:name],
        cc_service_plan[:guid],
        cc_service_plan[:unique_id],
        cc_service_plan[:created_at].to_datetime.rfc3339,
        cc_service_plan[:updated_at].to_datetime.rfc3339,
        cc_service_plan[:bindable],
        cc_service_plan[:free],
        cc_service_plan[:active],
        cc_service_plan[:public],
        cc_service[:label],
        cc_service[:guid],
        cc_service[:unique_id],
        cc_service[:created_at].to_datetime.rfc3339,
        cc_service[:updated_at].to_datetime.rfc3339,
        cc_service[:bindable],
        cc_service[:active],
        cc_service_broker[:name],
        cc_service_broker[:guid],
        cc_service_broker[:created_at].to_datetime.rfc3339,
        cc_service_broker[:updated_at].to_datetime.rfc3339,
        "#{cc_organization[:name]}/#{cc_space[:name]}",
        "#{cc_organization[:name]}/#{cc_space[:name]}"
      ]
    ]
  end

  def view_models_shared_service_instances_detail
    {
      'service'                => cc_service,
      'service_broker'         => cc_service_broker,
      'service_instance'       => cc_service_instance,
      'service_instance_share' => cc_service_instance_share,
      'service_plan'           => cc_service_plan,
      'source_organization'    => cc_organization,
      'source_space'           => cc_space,
      'target_organization'    => cc_organization,
      'target_space'           => cc_space
    }
  end

  def view_models_space_quotas
    [
      [
        cc_space_quota_definition[:guid],
        cc_space_quota_definition[:name],
        cc_space_quota_definition[:guid],
        cc_space_quota_definition[:created_at].to_datetime.rfc3339,
        cc_space_quota_definition[:updated_at].to_datetime.rfc3339,
        cc_space_quota_definition[:total_services],
        cc_space_quota_definition[:total_service_keys],
        cc_space_quota_definition[:total_routes],
        cc_space_quota_definition[:total_reserved_route_ports],
        cc_space_quota_definition[:app_instance_limit],
        cc_space_quota_definition[:app_task_limit],
        cc_space_quota_definition[:memory_limit],
        cc_space_quota_definition[:instance_memory_limit],
        cc_space_quota_definition[:non_basic_services_allowed],
        1,
        cc_organization[:name],
        cc_organization[:guid]
      ]
    ]
  end

  def view_models_space_quotas_detail
    {
      'organization'           => cc_organization,
      'space_quota_definition' => cc_space_quota_definition
    }
  end

  def view_models_space_roles
    [
      [
        "#{cc_space[:guid]}/#{cc_space_auditor[:role_guid]}/auditors/#{uaa_user[:id]}",
        'Auditor',
        cc_space_auditor[:role_guid],
        cc_space_auditor[:created_at].to_datetime.rfc3339,
        cc_space_auditor[:updated_at].to_datetime.rfc3339,
        cc_space[:name],
        cc_space[:guid],
        "#{cc_organization[:name]}/#{cc_space[:name]}",
        uaa_user[:username],
        uaa_user[:id]
      ],
      [
        "#{cc_space[:guid]}/#{cc_space_developer[:role_guid]}/developers/#{uaa_user[:id]}",
        'Developer',
        cc_space_developer[:role_guid],
        cc_space_developer[:created_at].to_datetime.rfc3339,
        cc_space_developer[:updated_at].to_datetime.rfc3339,
        cc_space[:name],
        cc_space[:guid],
        "#{cc_organization[:name]}/#{cc_space[:name]}",
        uaa_user[:username],
        uaa_user[:id]
      ],
      [
        "#{cc_space[:guid]}/#{cc_space_manager[:role_guid]}/managers/#{uaa_user[:id]}",
        'Manager',
        cc_space_manager[:role_guid],
        cc_space_manager[:created_at].to_datetime.rfc3339,
        cc_space_manager[:updated_at].to_datetime.rfc3339,
        cc_space[:name],
        cc_space[:guid],
        "#{cc_organization[:name]}/#{cc_space[:name]}",
        uaa_user[:username],
        uaa_user[:id]
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

  def view_models_spaces
    [
      [
        cc_space[:guid],
        cc_space[:name],
        cc_space[:guid],
        "#{cc_organization[:name]}/#{cc_space[:name]}",
        cc_space[:created_at].to_datetime.rfc3339,
        cc_space[:updated_at].to_datetime.rfc3339,
        cc_space[:allow_ssh],
        1,
        1,
        3,
        1,
        cc_space_quota_definition[:name],
        1,
        1,
        1,
        1,
        1,
        0,
        1,
        cc_process[:instances],
        1,
        1,
        AdminUI::Utils.convert_bytes_to_megabytes(@used_memory_in_bytes),
        AdminUI::Utils.convert_bytes_to_megabytes(@used_disk_in_bytes),
        @computed_pcpu,
        cc_process[:memory],
        cc_process[:disk_quota],
        cc_app[:desired_state] == 'STARTED' ? 1 : 0,
        cc_app[:desired_state] == 'STOPPED' ? 1 : 0,
        cc_process[:state] == 'STARTED' ? 1 : 0,
        cc_process[:state] == 'STOPPED' ? 1 : 0,
        cc_droplet[:state] == 'PENDING' ? 1 : 0,
        cc_droplet[:state] == 'STAGED' ? 1 : 0,
        cc_app[:package_state] == 'FAILED' ? 1 : 0,
        cc_isolation_segment[:name],
        cc_isolation_segment[:guid]
      ]
    ]
  end

  def view_models_spaces_detail
    {
      'annotations'            => [annotation_rfc3339(cc_space_annotation)],
      'isolation_segment'      => cc_isolation_segment,
      'labels'                 => [label_rfc3339(cc_space_label)],
      'organization'           => cc_organization,
      'space'                  => cc_space,
      'space_quota_definition' => cc_space_quota_definition
    }
  end

  def view_models_stacks
    [
      [
        cc_stack[:guid],
        cc_stack[:name],
        cc_stack[:guid],
        cc_stack[:created_at].to_datetime.rfc3339,
        cc_stack[:updated_at].to_datetime.rfc3339,
        1,
        1,
        cc_process[:instances],
        cc_stack[:description]
      ]
    ]
  end

  def view_models_stacks_detail
    {
      'annotations' => [annotation_rfc3339(cc_stack_annotation)],
      'labels'      => [label_rfc3339(cc_stack_label)],
      'stack'       => cc_stack
    }
  end

  def view_models_staging_security_groups_spaces
    [
      [
        "#{cc_security_group[:guid]}/#{cc_space[:guid]}",
        cc_security_group[:name],
        cc_security_group[:guid],
        cc_security_group[:created_at].to_datetime.rfc3339,
        cc_security_group[:updated_at].to_datetime.rfc3339,
        cc_space[:name],
        cc_space[:guid],
        cc_space[:created_at].to_datetime.rfc3339,
        cc_space[:updated_at].to_datetime.rfc3339,
        "#{cc_organization[:name]}/#{cc_space[:name]}"
      ]
    ]
  end

  def view_models_staging_security_groups_spaces_detail
    {
      'organization'                 => cc_organization,
      'security_group'               => cc_security_group,
      'space'                        => cc_space,
      'staging_security_group_space' => cc_staging_security_group_space
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
        cc_process[:instances],
        cc_process[:state] == 'STARTED' ? 1 : 0,
        @application_instance_source == :doppler_dea ? 1 : 0,
        @application_instance_source == :doppler_cell ? 1 : 0,
        {
          apps:              1,
          cells:             @application_instance_source == :doppler_cell ? 1 : 0,
          deas:              @application_instance_source == :doppler_dea ? 1 : 0,
          organizations:     1,
          running_instances: cc_process[:state] == 'STARTED' ? 1 : 0,
          spaces:            1,
          timestamp:         timestamp,
          total_instances:   cc_process[:instances],
          users:             1
        }
      ]
    ]
  end

  def view_models_tasks
    [
      [
        cc_task[:guid],
        cc_task[:name],
        cc_task[:guid],
        cc_task[:state],
        cc_task[:created_at].to_datetime.rfc3339,
        cc_task[:updated_at].to_datetime.rfc3339,
        cc_task[:memory_in_mb],
        cc_task[:disk_in_mb],
        cc_app[:name],
        cc_app[:guid],
        cc_task[:sequence_id],
        "#{cc_organization[:name]}/#{cc_space[:name]}"
      ]
    ]
  end

  def view_models_tasks_detail
    {
      'annotations'  => [annotation_rfc3339(cc_task_annotation)],
      'application'  => cc_app,
      'labels'       => [label_rfc3339(cc_task_label)],
      'organization' => cc_organization,
      'space'        => cc_space,
      'task'         => cc_task
    }
  end

  def view_models_users
    [
      [
        uaa_user[:id],
        uaa_identity_zone[:name],
        uaa_user[:username],
        uaa_user[:id],
        uaa_user[:created].to_datetime.rfc3339,
        uaa_user[:lastmodified].to_datetime.rfc3339,
        Time.at(uaa_user[:last_logon_success_time] / 1000.0).to_datetime.rfc3339,
        Time.at(uaa_user[:previous_logon_success_time] / 1000.0).to_datetime.rfc3339,
        uaa_user[:passwd_lastmodified].to_datetime.rfc3339,
        uaa_user[:passwd_change_required],
        uaa_user[:email],
        uaa_user[:familyname],
        uaa_user[:givenname],
        uaa_user[:phonenumber],
        uaa_user[:active],
        uaa_user[:verified],
        uaa_user[:version],
        1,
        1,
        1,
        1,
        cc_request_count[:count],
        cc_request_count[:valid_until].to_datetime.rfc3339,
        4,
        1,
        1,
        1,
        1,
        3,
        1,
        1,
        1,
        "#{cc_organization[:name]}/#{cc_space[:name]}"
      ]
    ]
  end

  def view_models_users_detail
    {
      'annotations'   => [annotation_rfc3339(cc_user_annotation)],
      'identity_zone' => uaa_identity_zone,
      'labels'        => [label_rfc3339(cc_user_label)],
      'organization'  => cc_organization,
      'request_count' => cc_request_count,
      'space'         => cc_space,
      'user_cc'       => cc_user,
      'user_uaa'      => uaa_user
    }
  end
end
