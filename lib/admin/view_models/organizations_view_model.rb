require 'date'
require 'set'
require_relative 'has_application_instances_view_model'
require_relative '../utils'

module AdminUI
  class OrganizationsViewModel < AdminUI::HasApplicationInstancesViewModel
    def do_items
      organizations = @cc.organizations

      # organizations have to exist. Other record types are optional
      return result unless organizations['connected']

      applications                     = @cc.applications
      containers                       = @doppler.containers
      domains                          = @cc.domains
      droplets                         = @cc.droplets
      events                           = @cc.events
      isolation_segments               = @cc.isolation_segments
      organization_annotations         = @cc.organization_annotations
      organization_labels              = @cc.organization_labels
      organizations_auditors           = @cc.organizations_auditors
      organizations_billing_managers   = @cc.organizations_billing_managers
      organizations_isolation_segments = @cc.organizations_isolation_segments
      organizations_managers           = @cc.organizations_managers
      organizations_users              = @cc.organizations_users
      packages                         = @cc.packages
      processes                        = @cc.processes
      quotas                           = @cc.quota_definitions
      route_mappings                   = @cc.route_mappings
      routes                           = @cc.routes
      security_groups_spaces           = @cc.security_groups_spaces
      service_brokers                  = @cc.service_brokers
      service_instances                = @cc.service_instances
      service_plan_visibilities        = @cc.service_plan_visibilities
      space_quotas                     = @cc.space_quota_definitions
      spaces                           = @cc.spaces
      spaces_auditors                  = @cc.spaces_auditors
      spaces_developers                = @cc.spaces_developers
      spaces_managers                  = @cc.spaces_managers
      staging_security_groups_spaces   = @cc.staging_security_groups_spaces
      tasks                            = @cc.tasks
      users                            = @cc.users_cc

      applications_connected                     = applications['connected']
      containers_connected                       = containers['connected']
      domains_connected                          = domains['connected']
      droplets_connected                         = droplets['connected']
      events_connected                           = events['connected']
      organizations_roles_connected              = organizations_auditors['connected'] && organizations_billing_managers['connected'] && organizations_managers['connected'] && organizations_users['connected']
      organizations_isolation_segments_connected = organizations_isolation_segments['connected']
      packages_connected                         = packages['connected']
      processes_connected                        = processes['connected']
      route_mappings_connected                   = route_mappings['connected']
      routes_connected                           = routes['connected']
      security_groups_spaces_connected           = security_groups_spaces['connected']
      service_brokers_connected                  = service_brokers['connected']
      service_instances_connected                = service_instances['connected']
      service_plan_visibilities_connected        = service_plan_visibilities['connected']
      space_quotas_connected                     = space_quotas['connected']
      spaces_connected                           = spaces['connected']
      spaces_roles_connected                     = spaces_auditors['connected'] && spaces_developers['connected'] && spaces_managers['connected']
      staging_security_groups_spaces_connected   = staging_security_groups_spaces['connected']
      tasks_connected                            = tasks['connected']
      users_connected                            = users['connected']

      applications_hash       = applications['items'].map { |item| [item[:guid], item] }.to_h
      droplets_hash           = droplets['items'].map { |item| [item[:guid], item] }.to_h
      isolation_segments_hash = isolation_segments['items'].map { |item| [item[:guid], item] }.to_h
      quota_hash              = quotas['items'].map { |item| [item[:id], item] }.to_h
      routes_used_set         = route_mappings['items'].to_set { |route_mapping| route_mapping[:route_guid] }
      spaces_guid_hash        = spaces['items'].map { |item| [item[:guid], item] }.to_h
      spaces_id_hash          = spaces['items'].map { |item| [item[:id], item] }.to_h

      latest_droplets = latest_app_guid_hash(droplets['items'])
      latest_packages = latest_app_guid_hash(packages['items'])

      organization_annotations_hash                 = {}
      organization_labels_hash                      = {}
      event_counters                                = {}
      event_target_counters                         = {}
      organization_space_counters                   = {}
      organization_role_counters                    = {}
      organization_default_user_counters            = {}
      organization_domain_counters                  = {}
      organization_security_groups_counters         = {}
      organization_staging_security_groups_counters = {}
      organization_service_broker_counters          = {}
      organization_service_instance_counters        = {}
      organization_service_plan_visibility_counters = {}
      organization_route_counters_hash              = {}
      organization_app_counters_hash                = {}
      organization_process_counters_hash            = {}
      space_quota_counters                          = {}
      space_role_counters                           = {}
      organization_isolation_segment_counters       = {}
      organization_task_counters                    = {}

      organization_annotations['items'].each do |organization_annotation|
        return result unless @running

        Thread.pass

        organization_guid = organization_annotation[:resource_guid]
        organization_annotations_array = organization_annotations_hash[organization_guid]
        if organization_annotations_array.nil?
          organization_annotations_array = []
          organization_annotations_hash[organization_guid] = organization_annotations_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            annotation:         organization_annotation,
            created_at_rfc3339: organization_annotation[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: organization_annotation[:updated_at].nil? ? nil : organization_annotation[:updated_at].to_datetime.rfc3339
          }

        organization_annotations_array.push(wrapper)
      end

      organization_labels['items'].each do |organization_label|
        return result unless @running

        Thread.pass

        organization_guid = organization_label[:resource_guid]
        organization_labels_array = organization_labels_hash[organization_guid]
        if organization_labels_array.nil?
          organization_labels_array = []
          organization_labels_hash[organization_guid] = organization_labels_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            label:              organization_label,
            created_at_rfc3339: organization_label[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: organization_label[:updated_at].nil? ? nil : organization_label[:updated_at].to_datetime.rfc3339
          }

        organization_labels_array.push(wrapper)
      end

      events['items'].each do |event|
        return result unless @running

        Thread.pass

        if event[:actee_type] == 'organization'
          actee = event[:actee]
          event_counters[actee] = 0 if event_counters[actee].nil?
          event_counters[actee] += 1
        end

        organization_guid = event[:organization_guid]
        next if organization_guid.nil?

        event_target_counters[organization_guid] = 0 if event_target_counters[organization_guid].nil?
        event_target_counters[organization_guid] += 1
      end

      spaces_guid_hash.each_value do |space|
        return result unless @running

        Thread.pass

        organization_id = space[:organization_id]
        organization_space_counters[organization_id] = 0 if organization_space_counters[organization_id].nil?
        organization_space_counters[organization_id] += 1
      end

      count_organization_roles(organizations_auditors, organization_role_counters)
      count_organization_roles(organizations_billing_managers, organization_role_counters)
      count_organization_roles(organizations_managers, organization_role_counters)
      count_organization_roles(organizations_users, organization_role_counters)

      count_space_roles(spaces_id_hash, spaces_auditors, space_role_counters)
      count_space_roles(spaces_id_hash, spaces_developers, space_role_counters)
      count_space_roles(spaces_id_hash, spaces_managers, space_role_counters)

      users['items'].each do |user|
        return result unless @running

        Thread.pass

        default_space_id = user[:default_space_id]
        next if default_space_id.nil?

        space = spaces_id_hash[default_space_id]
        next if space.nil?

        organization_id = space[:organization_id]
        organization_default_user_counters[organization_id] = 0 if organization_default_user_counters[organization_id].nil?
        organization_default_user_counters[organization_id] += 1
      end

      service_brokers['items'].each do |service_broker|
        return result unless @running

        Thread.pass

        space_id = service_broker[:space_id]
        next if space_id.nil?

        space = spaces_id_hash[space_id]
        next if space.nil?

        organization_id = space[:organization_id]
        organization_service_broker_counters[organization_id] = 0 if organization_service_broker_counters[organization_id].nil?
        organization_service_broker_counters[organization_id] += 1
      end

      service_instances['items'].each do |service_instance|
        return result unless @running

        Thread.pass

        space = spaces_id_hash[service_instance[:space_id]]
        next if space.nil?

        organization_id = space[:organization_id]
        organization_service_instance_counters[organization_id] = 0 if organization_service_instance_counters[organization_id].nil?
        organization_service_instance_counters[organization_id] += 1
      end

      domains['items'].each do |domain|
        return result unless @running

        Thread.pass

        owning_organization_id = domain[:owning_organization_id]
        next if owning_organization_id.nil?

        organization_domain_counters[owning_organization_id] = 0 if organization_domain_counters[owning_organization_id].nil?
        organization_domain_counters[owning_organization_id] += 1
      end

      space_quotas['items'].each do |space_quota|
        return result unless @running

        Thread.pass

        organization_id = space_quota[:organization_id]
        next if organization_id.nil?

        space_quota_counters[organization_id] = 0 if space_quota_counters[organization_id].nil?
        space_quota_counters[organization_id] += 1
      end

      routes['items'].each do |route|
        return result unless @running

        Thread.pass

        space = spaces_id_hash[route[:space_id]]
        next if space.nil?

        organization_id = space[:organization_id]
        organization_route_counters = organization_route_counters_hash[organization_id]
        if organization_route_counters.nil?
          organization_route_counters =
            {
              'total_routes'  => 0,
              'unused_routes' => 0
            }
          organization_route_counters_hash[organization_id] = organization_route_counters
        end

        if route_mappings_connected
          organization_route_counters['unused_routes'] += 1 unless routes_used_set.include?(route[:guid])
        end
        organization_route_counters['total_routes'] += 1
      end

      service_plan_visibilities['items'].each do |service_plan_visibility|
        return result unless @running

        Thread.pass

        organization_id = service_plan_visibility[:organization_id]
        next if organization_id.nil?

        organization_service_plan_visibility_counters[organization_id] = 0 if organization_service_plan_visibility_counters[organization_id].nil?
        organization_service_plan_visibility_counters[organization_id] += 1
      end

      security_groups_spaces['items'].each do |security_group_space|
        return result unless @running

        Thread.pass

        space = spaces_id_hash[security_group_space[:space_id]]
        next if space.nil?

        organization_id = space[:organization_id]
        organization_security_groups_counters[organization_id] = 0 if organization_security_groups_counters[organization_id].nil?
        organization_security_groups_counters[organization_id] += 1
      end

      staging_security_groups_spaces['items'].each do |staging_security_group_space|
        return result unless @running

        Thread.pass

        space = spaces_id_hash[staging_security_group_space[:staging_space_id]]
        next if space.nil?

        organization_id = space[:organization_id]
        organization_staging_security_groups_counters[organization_id] = 0 if organization_staging_security_groups_counters[organization_id].nil?
        organization_staging_security_groups_counters[organization_id] += 1
      end

      containers_hash = create_instance_hash(containers)

      applications['items'].each do |application|
        return result unless @running

        Thread.pass

        space = spaces_guid_hash[application[:space_guid]]
        next if space.nil?

        organization_id = space[:organization_id]
        organization_app_counters = organization_app_counters_hash[organization_id]
        if organization_app_counters.nil?
          organization_app_counters =
            {
              'total'       => 0,
              'used_memory' => 0,
              'used_disk'   => 0,
              'used_cpu'    => 0
            }
          organization_app_counters_hash[organization_id] = organization_app_counters
        end

        add_instance_metrics(organization_app_counters, application, droplets_hash, latest_droplets, latest_packages, containers_hash)
      end

      processes['items'].each do |process|
        return result unless @running

        Thread.pass

        application_guid = process[:app_guid]
        application = applications_hash[application_guid]
        next if application.nil?

        space = spaces_guid_hash[application[:space_guid]]
        next if space.nil?

        organization_id = space[:organization_id]
        organization_process_counters = organization_process_counters_hash[organization_id]

        if organization_process_counters.nil?
          organization_process_counters =
            {
              'reserved_memory' => 0,
              'reserved_disk'   => 0,
              'instances'       => 0
            }
          organization_process_counters_hash[organization_id] = organization_process_counters
        end

        add_process_metrics(organization_process_counters, process)
      end

      tasks['items'].each do |task|
        return result unless @running

        Thread.pass

        application_guid = task[:app_guid]
        application = applications_hash[application_guid]
        next if application.nil?

        space = spaces_guid_hash[application[:space_guid]]
        next if space.nil?

        organization_id = space[:organization_id]
        organization_task_counters[organization_id] = 0 if organization_task_counters[organization_id].nil?
        organization_task_counters[organization_id] += 1
      end

      organizations_isolation_segments['items'].each do |organization_isolation_segment|
        return result unless @running

        Thread.pass

        organization_guid = organization_isolation_segment[:organization_guid]
        next if organization_guid.nil?

        organization_isolation_segment_counters[organization_guid] = 0 if organization_isolation_segment_counters[organization_guid].nil?
        organization_isolation_segment_counters[organization_guid] += 1
      end

      items = []
      hash  = {}

      organizations['items'].each do |organization|
        return result unless @running

        Thread.pass

        organization_id                = organization[:id]
        organization_guid              = organization[:guid]
        quota                          = quota_hash[organization[:quota_definition_id]]
        default_isolation_segment_guid = organization[:default_isolation_segment_guid]
        default_isolation_segment      = default_isolation_segment_guid.nil? ? nil : isolation_segments_hash[default_isolation_segment_guid]

        organization_annotation_array                = organization_annotations_hash[organization_guid] || []
        organization_label_array                     = organization_labels_hash[organization_guid] || []
        event_counter                                = event_counters[organization_guid]
        event_target_counter                         = event_target_counters[organization_guid]
        organization_default_user_counter            = organization_default_user_counters[organization_id]
        organization_role_counter                    = organization_role_counters[organization_id]
        organization_space_counter                   = organization_space_counters[organization_id]
        organization_service_broker_counter          = organization_service_broker_counters[organization_id]
        organization_service_instance_counter        = organization_service_instance_counters[organization_id]
        organization_service_plan_visibility_counter = organization_service_plan_visibility_counters[organization_id]
        organization_security_groups_counter         = organization_security_groups_counters[organization_id]
        organization_staging_security_groups_counter = organization_staging_security_groups_counters[organization_id]
        organization_app_counters                    = organization_app_counters_hash[organization_id]
        organization_domain_counter                  = organization_domain_counters[organization_id]
        organization_process_counters                = organization_process_counters_hash[organization_id]
        organization_route_counters                  = organization_route_counters_hash[organization_id]
        space_quota_counter                          = space_quota_counters[organization_id]
        space_role_counter                           = space_role_counters[organization_id]
        organization_task_counter                    = organization_task_counters[organization_id]
        organization_isolation_segment_counter       = organization_isolation_segment_counters[organization_guid]

        row = []

        row.push(organization_guid)
        row.push(organization[:name])
        row.push(organization_guid)
        row.push(organization[:status])
        row.push(organization[:created_at].to_datetime.rfc3339)

        if organization[:updated_at]
          row.push(organization[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        if event_counter
          row.push(event_counter)
        elsif events_connected
          row.push(0)
        else
          row.push(nil)
        end

        if event_target_counter
          row.push(event_target_counter)
        elsif events_connected
          row.push(0)
        else
          row.push(nil)
        end

        if organization_space_counter
          row.push(organization_space_counter)
        elsif spaces_connected
          row.push(0)
        else
          row.push(nil)
        end

        if organization_role_counter
          row.push(organization_role_counter)
        elsif organizations_roles_connected
          row.push(0)
        else
          row.push(nil)
        end

        if space_role_counter
          row.push(space_role_counter)
        elsif spaces_connected && spaces_roles_connected
          row.push(0)
        else
          row.push(nil)
        end

        if organization_default_user_counter
          row.push(organization_default_user_counter)
        elsif users_connected
          row.push(0)
        else
          row.push(nil)
        end

        if quota
          row.push(quota[:name])
        else
          row.push(nil)
        end

        if space_quota_counter
          row.push(space_quota_counter)
        elsif space_quotas_connected
          row.push(0)
        else
          row.push(nil)
        end

        if organization_domain_counter
          row.push(organization_domain_counter)
        elsif domains_connected
          row.push(0)
        else
          row.push(nil)
        end

        if organization_service_broker_counter
          row.push(organization_service_broker_counter)
        elsif spaces_connected && service_brokers_connected
          row.push(0)
        else
          row.push(nil)
        end

        if organization_service_plan_visibility_counter
          row.push(organization_service_plan_visibility_counter)
        elsif service_plan_visibilities_connected
          row.push(0)
        else
          row.push(nil)
        end

        if organization_security_groups_counter
          row.push(organization_security_groups_counter)
        elsif spaces_connected && security_groups_spaces_connected
          row.push(0)
        else
          row.push(nil)
        end

        if organization_staging_security_groups_counter
          row.push(organization_staging_security_groups_counter)
        elsif spaces_connected && staging_security_groups_spaces_connected
          row.push(0)
        else
          row.push(nil)
        end

        if organization_route_counters
          row.push(organization_route_counters['total_routes'])
          row.push(organization_route_counters['total_routes'] - organization_route_counters['unused_routes'])
          row.push(organization_route_counters['unused_routes'])
        elsif spaces_connected && routes_connected
          row.push(0, 0, 0)
        else
          row.push(nil, nil, nil)
        end

        if organization_app_counters
          row.push(organization_app_counters['total'])
        elsif spaces_connected && applications_connected
          row.push(0)
        else
          row.push(nil)
        end

        if organization_process_counters
          row.push(organization_process_counters['instances'])
        elsif spaces_connected && applications_connected && processes_connected
          row.push(0)
        else
          row.push(nil)
        end

        if organization_service_instance_counter
          row.push(organization_service_instance_counter)
        elsif spaces_connected && service_instances_connected
          row.push(0)
        else
          row.push(nil)
        end

        if organization_task_counter
          row.push(organization_task_counter)
        elsif spaces_connected && applications_connected && tasks_connected
          row.push(0)
        else
          row.push(nil)
        end

        if containers_connected
          if organization_app_counters
            row.push(Utils.convert_bytes_to_megabytes(organization_app_counters['used_memory']))
            row.push(Utils.convert_bytes_to_megabytes(organization_app_counters['used_disk']))
            row.push(organization_app_counters['used_cpu'])
          elsif spaces_connected && applications_connected
            row.push(0, 0, 0)
          else
            row.push(nil, nil, nil)
          end
        else
          row.push(nil, nil, nil)
        end

        if organization_process_counters
          row.push(organization_process_counters['reserved_memory'])
          row.push(organization_process_counters['reserved_disk'])
        elsif spaces_connected && applications_connected && processes_connected
          row.push(0, 0)
        else
          row.push(nil, nil)
        end

        if organization_app_counters
          row.push(organization_app_counters['STARTED'] || 0)
          row.push(organization_app_counters['STOPPED'] || 0)
        elsif spaces_connected && applications_connected
          row.push(0, 0)
        else
          row.push(nil, nil)
        end

        if organization_process_counters
          row.push(organization_process_counters['STARTED'] || 0)
          row.push(organization_process_counters['STOPPED'] || 0)
        elsif spaces_connected && applications_connected && processes_connected
          row.push(0, 0)
        else
          row.push(nil, nil)
        end

        if organization_app_counters && droplets_connected && packages_connected
          row.push(organization_app_counters['PENDING'] || 0)
          row.push(organization_app_counters['STAGED'] || 0)
          row.push(organization_app_counters['FAILED'] || 0)
        elsif spaces_connected && applications_connected && droplets_connected && packages_connected
          row.push(0, 0, 0)
        else
          row.push(nil, nil, nil)
        end

        if default_isolation_segment
          row.push(default_isolation_segment[:name])
        else
          row.push(nil)
        end

        row.push(default_isolation_segment_guid)

        if organization_isolation_segment_counter
          row.push(organization_isolation_segment_counter)
        elsif organizations_isolation_segments_connected
          row.push(0)
        else
          row.push(nil)
        end

        items.push(row)

        hash[organization_guid] =
          {
            'annotations'               => organization_annotation_array,
            'default_isolation_segment' => default_isolation_segment,
            'labels'                    => organization_label_array,
            'organization'              => organization,
            'quota_definition'          => quota
          }
      end

      result(true, items, hash, (1..40).to_a, [1, 2, 3, 4, 5, 12, 38, 39])
    end

    private

    def count_organization_roles(input_organization_role_array, output_organization_role_counter_hash)
      input_organization_role_array['items'].each do |input_organization_role_array_entry|
        Thread.pass
        organization_id = input_organization_role_array_entry[:organization_id]
        output_organization_role_counter_hash[organization_id] = 0 if output_organization_role_counter_hash[organization_id].nil?
        output_organization_role_counter_hash[organization_id] += 1
      end
    end

    def count_space_roles(spaces_id_hash, input_space_role_array, output_space_role_counter_hash)
      input_space_role_array['items'].each do |input_space_role_array_entry|
        Thread.pass
        space = spaces_id_hash[input_space_role_array_entry[:space_id]]
        next if space.nil?

        organization_id = space[:organization_id]
        output_space_role_counter_hash[organization_id] = 0 if output_space_role_counter_hash[organization_id].nil?
        output_space_role_counter_hash[organization_id] += 1
      end
    end
  end
end
