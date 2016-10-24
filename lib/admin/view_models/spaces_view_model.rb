require 'date'
require 'set'
require 'thread'
require_relative 'has_application_instances_view_model'
require_relative '../utils'

module AdminUI
  class SpacesViewModel < AdminUI::HasApplicationInstancesViewModel
    def do_items
      spaces = @cc.spaces

      # spaces have to exist.  Other record types are optional
      return result unless spaces['connected']

      applications           = @cc.applications
      containers             = @doppler.containers
      droplets               = @cc.droplets
      events                 = @cc.events
      organizations          = @cc.organizations
      packages               = @cc.packages
      processes              = @cc.processes
      route_mappings         = @cc.route_mappings
      routes                 = @cc.routes
      security_groups_spaces = @cc.security_groups_spaces
      service_brokers        = @cc.service_brokers
      service_instances      = @cc.service_instances
      space_quotas           = @cc.space_quota_definitions
      spaces_auditors        = @cc.spaces_auditors
      spaces_developers      = @cc.spaces_developers
      spaces_managers        = @cc.spaces_managers
      users                  = @cc.users_cc

      applications_connected           = applications['connected']
      containers_connected             = containers['connected']
      droplets_connected               = droplets['connected']
      events_connected                 = events['connected']
      packages_connected               = packages['connected']
      processes_connected              = processes['connected']
      route_mappings_connected         = route_mappings['connected']
      routes_connected                 = routes['connected']
      security_groups_spaces_connected = security_groups_spaces['connected']
      service_brokers_connected        = service_brokers['connected']
      service_instances_connected      = service_instances['connected']
      spaces_roles_connected           = spaces_auditors['connected'] && spaces_developers['connected'] && spaces_managers['connected']
      users_connected                  = users['connected']

      applications_hash = Hash[applications['items'].map { |item| [item[:guid], item] }]
      droplets_hash     = Hash[droplets['items'].map { |item| [item[:guid], item] }]
      organization_hash = Hash[organizations['items'].map { |item| [item[:id], item] }]
      routes_used_set   = route_mappings['items'].to_set { |route_mapping| route_mapping[:route_guid] }
      space_quota_hash  = Hash[space_quotas['items'].map { |item| [item[:id], item] }]

      latest_droplets = latest_app_guid_hash(droplets['items'])
      latest_packages = latest_app_guid_hash(packages['items'])

      event_counters        = {}
      event_target_counters = {}
      events['items'].each do |event|
        return result unless @running
        Thread.pass

        if event[:actee_type] == 'space'
          actee = event[:actee]
          event_counters[actee] = 0 if event_counters[actee].nil?
          event_counters[actee] += 1
        end

        space_guid = event[:space_guid]
        next if space_guid.nil?
        event_target_counters[space_guid] = 0 if event_target_counters[space_guid].nil?
        event_target_counters[space_guid] += 1
      end

      space_role_counters             = {}
      space_default_user_counters     = {}
      space_security_groups_counters  = {}
      space_service_broker_counters   = {}
      space_service_instance_counters = {}
      space_route_counters_hash       = {}
      space_app_counters_hash         = {}
      space_process_counters_hash     = {}

      count_space_roles(spaces_auditors, space_role_counters)
      count_space_roles(spaces_developers, space_role_counters)
      count_space_roles(spaces_managers, space_role_counters)

      users['items'].each do |user|
        return result unless @running
        Thread.pass

        default_space_id = user[:default_space_id]
        next if default_space_id.nil?
        space_default_user_counters[default_space_id] = 0 if space_default_user_counters[default_space_id].nil?
        space_default_user_counters[default_space_id] += 1
      end

      service_brokers['items'].each do |service_broker|
        return result unless @running
        Thread.pass

        space_id = service_broker[:space_id]
        next if space_id.nil?
        space_service_broker_counters[space_id] = 0 if space_service_broker_counters[space_id].nil?
        space_service_broker_counters[space_id] += 1
      end

      service_instances['items'].each do |service_instance|
        return result unless @running
        Thread.pass

        space_id = service_instance[:space_id]
        space_service_instance_counters[space_id] = 0 if space_service_instance_counters[space_id].nil?
        space_service_instance_counters[space_id] += 1
      end

      security_groups_spaces['items'].each do |security_group_space|
        return result unless @running
        Thread.pass

        space_id = security_group_space[:space_id]
        space_security_groups_counters[space_id] = 0 if space_security_groups_counters[space_id].nil?
        space_security_groups_counters[space_id] += 1
      end

      routes['items'].each do |route|
        return result unless @running
        Thread.pass

        space_id = route[:space_id]
        space_route_counters = space_route_counters_hash[space_id]
        if space_route_counters.nil?
          space_route_counters =
            {
              'total_routes'  => 0,
              'unused_routes' => 0
            }
          space_route_counters_hash[space_id] = space_route_counters
        end

        if route_mappings_connected
          space_route_counters['unused_routes'] += 1 unless routes_used_set.include?(route[:guid])
        end
        space_route_counters['total_routes'] += 1
      end

      containers_hash = create_instance_hash(containers)

      applications['items'].each do |application|
        return result unless @running
        Thread.pass

        space_guid = application[:space_guid]
        space_app_counters = space_app_counters_hash[space_guid]
        if space_app_counters.nil?
          space_app_counters =
            {
              'total'       => 0,
              'used_memory' => 0,
              'used_disk'   => 0,
              'used_cpu'    => 0
            }
          space_app_counters_hash[space_guid] = space_app_counters
        end

        add_instance_metrics(space_app_counters, application, droplets_hash, latest_droplets, latest_packages, containers_hash)
      end

      processes['items'].each do |process|
        return result unless @running
        Thread.pass

        application_guid = process[:app_guid]
        application = applications_hash[application_guid]
        next if application.nil?
        space_guid = application[:space_guid]
        space_process_counters = space_process_counters_hash[space_guid]

        if space_process_counters.nil?
          space_process_counters =
            {
              'reserved_memory' => 0,
              'reserved_disk'   => 0,
              'instances'       => 0
            }
          space_process_counters_hash[space_guid] = space_process_counters
        end

        add_process_metrics(space_process_counters, process)
      end

      items = []
      hash  = {}

      spaces['items'].each do |space|
        return result unless @running
        Thread.pass

        space_id   = space[:id]
        space_guid = space[:guid]

        organization                   = organization_hash[space[:organization_id]]
        event_counter                  = event_counters[space_guid]
        event_target_counter           = event_target_counters[space_guid]
        space_quota                    = space_quota_hash[space[:space_quota_definition_id]]
        space_role_counter             = space_role_counters[space_id]
        space_security_groups_counter  = space_security_groups_counters[space_id]
        space_service_broker_counter   = space_service_broker_counters[space_id]
        space_service_instance_counter = space_service_instance_counters[space_id]
        space_app_counters             = space_app_counters_hash[space_guid]
        space_default_user_counter     = space_default_user_counters[space_id]
        space_process_counters         = space_process_counters_hash[space_guid]
        space_route_counters           = space_route_counters_hash[space_id]

        row = []

        row.push(space_guid)
        row.push(space[:name])
        row.push(space_guid)

        if organization
          row.push("#{organization[:name]}/#{space[:name]}")
        else
          row.push(nil)
        end

        row.push(space[:created_at].to_datetime.rfc3339)

        if space[:updated_at]
          row.push(space[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        if space[:allow_ssh]
          row.push(true)
        else
          row.push(false)
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

        if space_role_counter
          row.push(space_role_counter)
        elsif spaces_roles_connected
          row.push(0)
        else
          row.push(nil)
        end

        if space_default_user_counter
          row.push(space_default_user_counter)
        elsif users_connected
          row.push(0)
        else
          row.push(nil)
        end

        if space_quota
          row.push(space_quota[:name])
        else
          row.push(nil)
        end

        if space_service_broker_counter
          row.push(space_service_broker_counter)
        elsif service_brokers_connected
          row.push(0)
        else
          row.push(nil)
        end

        if space_security_groups_counter
          row.push(space_security_groups_counter)
        elsif security_groups_spaces_connected
          row.push(0)
        else
          row.push(nil)
        end

        if space_route_counters
          row.push(space_route_counters['total_routes'])
          row.push(space_route_counters['total_routes'] - space_route_counters['unused_routes'])
          row.push(space_route_counters['unused_routes'])
        elsif routes_connected
          row.push(0, 0, 0)
        else
          row.push(nil, nil, nil)
        end

        if space_app_counters
          row.push(space_app_counters['total'])
        elsif applications_connected
          row.push(0)
        else
          row.push(nil)
        end

        if space_process_counters
          row.push(space_process_counters['instances'])
        elsif applications_connected && processes_connected
          row.push(0)
        else
          row.push(nil)
        end

        if space_service_instance_counter
          row.push(space_service_instance_counter)
        elsif service_instances_connected
          row.push(0)
        else
          row.push(nil)
        end

        if containers_connected
          if space_app_counters
            row.push(Utils.convert_bytes_to_megabytes(space_app_counters['used_memory']))
            row.push(Utils.convert_bytes_to_megabytes(space_app_counters['used_disk']))
            row.push(space_app_counters['used_cpu'])
          elsif applications_connected
            row.push(0, 0, 0)
          else
            row.push(nil, nil, nil)
          end
        else
          row.push(nil, nil, nil)
        end

        if space_process_counters
          row.push(space_process_counters['reserved_memory'])
          row.push(space_process_counters['reserved_disk'])
        elsif applications_connected && processes_connected
          row.push(0, 0)
        else
          row.push(nil, nil)
        end

        if space_app_counters
          row.push(space_app_counters['STARTED'] || 0)
          row.push(space_app_counters['STOPPED'] || 0)
        elsif applications_connected
          row.push(0, 0)
        else
          row.push(nil, nil)
        end

        if space_process_counters
          row.push(space_process_counters['STARTED'] || 0)
          row.push(space_process_counters['STOPPED'] || 0)
        elsif applications_connected && processes_connected
          row.push(0, 0)
        else
          row.push(nil, nil)
        end

        if space_app_counters && droplets_connected && packages_connected
          row.push(space_app_counters['PENDING'] || 0)
          row.push(space_app_counters['STAGED'] || 0)
          row.push(space_app_counters['FAILED'] || 0)
        elsif applications_connected && droplets_connected && packages_connected
          row.push(0, 0, 0)
        else
          row.push(nil, nil, nil)
        end

        items.push(row)

        hash[space_guid] =
          {
            'organization'           => organization,
            'space'                  => space,
            'space_quota_definition' => space_quota
          }
      end

      result(true, items, hash, (1..31).to_a, (1..6).to_a << 11)
    end

    private

    def count_space_roles(input_space_role_array, output_space_role_counter_hash)
      input_space_role_array['items'].each do |input_space_role_array_entry|
        Thread.pass
        space_id = input_space_role_array_entry[:space_id]
        output_space_role_counter_hash[space_id] = 0 if output_space_role_counter_hash[space_id].nil?
        output_space_role_counter_hash[space_id] += 1
      end
    end
  end
end
