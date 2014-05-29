require 'date'
require_relative 'has_instances_view_model'
require_relative '../utils'

module AdminUI
  class SpacesViewModel < AdminUI::HasInstancesViewModel
    def do_items
      spaces = @cc.spaces(false)

      # spaces have to exist.  Other record types are optional
      return result unless spaces['connected']

      applications      = @cc.applications(false)
      deas              = @varz.deas(false)
      organizations     = @cc.organizations(false)
      routes            = @cc.routes(false)
      service_instances = @cc.service_instances(false)
      spaces_developers = @cc.spaces_developers(false)

      organization_hash = Hash[*organizations['items'].map { |item| [item['guid'], item] }.flatten]

      space_developer_counters        = {}
      space_service_instance_counters = {}
      space_route_counters_hash       = {}
      space_app_counters_hash         = {}

      spaces_developers['items'].each do |space_developer|
        space_guid = space_developer['space_guid']
        space_developer_counters[space_guid] = 0 if space_developer_counters[space_guid].nil?
        space_developer_counters[space_guid] += 1
      end

      service_instances['items'].each do |service_instance|
        space_guid = service_instance['space_guid']
        space_service_instance_counters[space_guid] = 0 if space_service_instance_counters[space_guid].nil?
        space_service_instance_counters[space_guid] += 1
      end

      routes['items'].each do |route|
        space_guid = route['space_guid']
        space_route_counters = space_route_counters_hash[space_guid]
        if space_route_counters.nil?
          space_route_counters = { 'total_routes'  => 0,
                                   'unused_routes' => 0
                                 }
          space_route_counters_hash[space_guid] = space_route_counters
        end

        space_route_counters['unused_routes'] += 1 if route['apps'].length == 0
        space_route_counters['total_routes'] += 1
      end

      instance_hash = create_instance_hash(deas)

      applications['items'].each do |application|
        space_guid = application['space_guid']
        space_app_counters = space_app_counters_hash[space_guid]
        if space_app_counters.nil?
          space_app_counters = { 'total'           => 0,
                                 'reserved_memory' => 0,
                                 'reserved_disk'   => 0,
                                 'used_memory'     => 0,
                                 'used_disk'       => 0,
                                 'used_cpu'        => 0,
                                 'instances'       => 0
                               }
          space_app_counters_hash[space_guid] = space_app_counters
        end

        space_app_counters[application['state']] = 0 if space_app_counters[application['state']].nil?
        space_app_counters[application['package_state']] = 0 if space_app_counters[application['package_state']].nil?

        add_instance_metrics(space_app_counters, application, instance_hash)

        space_app_counters['total'] += 1
        space_app_counters[application['state']] += 1
        space_app_counters[application['package_state']] += 1
      end

      items = []

      spaces['items'].each do |space|
        space_guid = space['guid']

        organization                   = organization_hash[space['organization_guid']]
        space_developer_counter        = space_developer_counters[space_guid]
        space_service_instance_counter = space_service_instance_counters[space_guid]
        space_app_counters             = space_app_counters_hash[space_guid]
        space_route_counters           = space_route_counters_hash[space_guid]

        row = []

        row.push(space['name'])

        if organization
          row.push("#{ organization['name'] }/#{ space['name'] }")
        else
          row.push(nil)
        end

        row.push(DateTime.parse(space['created_at']).rfc3339)

        if space['updated_at']
          row.push(DateTime.parse(space['updated_at']).rfc3339)
        else
          row.push(nil)
        end

        row.push(space_developer_counter || 0)

        if space_route_counters
          row.push(space_route_counters['total_routes'])
          row.push(space_route_counters['total_routes'] - space_route_counters['unused_routes'])
          row.push(space_route_counters['unused_routes'])
        else
          row.push(0, 0, 0)
        end

        if space_app_counters
          row.push(space_app_counters['instances'])
        else
          row.push(0)
        end

        row.push(space_service_instance_counter || 0)

        if space_app_counters
          row.push(Utils.convert_bytes_to_megabytes(space_app_counters['used_memory']))
          row.push(Utils.convert_bytes_to_megabytes(space_app_counters['used_disk']))
          row.push(space_app_counters['used_cpu'] * 100)
          row.push(space_app_counters['reserved_memory'])
          row.push(space_app_counters['reserved_disk'])
          row.push(space_app_counters['total'])
          row.push(space_app_counters['STARTED'] || 0)
          row.push(space_app_counters['STOPPED'] || 0)
          row.push(space_app_counters['PENDING'] || 0)
          row.push(space_app_counters['STAGED']  || 0)
          row.push(space_app_counters['FAILED']  || 0)
        else
          row.push(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        end

        row.push('organization' => organization,
                 'space'        => space)

        items.push(row)
      end

      result(items, (0..20).to_a, (0..3).to_a)
    end
  end
end
