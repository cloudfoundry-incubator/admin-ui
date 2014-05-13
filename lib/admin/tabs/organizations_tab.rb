require 'date'
require_relative 'has_instances_tab'

module AdminUI
  class OrganizationsTab < AdminUI::HasInstancesTab
    def do_items
      organizations = @cc.organizations

      # organizations have to exist.  Other record types are optional
      return result unless organizations['connected']

      applications      = @cc.applications
      deas              = @varz.deas
      quotas            = @cc.quota_definitions
      routes            = @cc.routes
      service_instances = @cc.service_instances
      spaces            = @cc.spaces
      spaces_developers = @cc.spaces_developers

      quota_hash = Hash[*quotas['items'].map { |item| [item['guid'], item] }.flatten]
      space_hash = Hash[*spaces['items'].map { |item| [item['guid'], item] }.flatten]

      organization_space_counters            = {}
      organization_developer_counters        = {}
      organization_service_instance_counters = {}
      organization_route_counters_hash       = {}
      organization_app_counters_hash         = {}

      space_hash.each_value do |space|
        organization_guid = space['organization_guid']
        organization_space_counters[organization_guid] = 0 if organization_space_counters[organization_guid].nil?
        organization_space_counters[organization_guid] += 1
      end

      spaces_developers['items'].each do |space_developer|
        space = space_hash[space_developer['space_guid']]
        unless space.nil?
          organization_guid = space['organization_guid']
          organization_developer_counters[organization_guid] = 0 if organization_developer_counters[organization_guid].nil?
          organization_developer_counters[organization_guid] += 1
        end
      end

      service_instances['items'].each do |service_instance|
        space = space_hash[service_instance['space_guid']]
        unless space.nil?
          organization_guid = space['organization_guid']
          organization_service_instance_counters[organization_guid] = 0 if organization_service_instance_counters[organization_guid].nil?
          organization_service_instance_counters[organization_guid] += 1
        end
      end

      routes['items'].each do |route|
        space = space_hash[route['space_guid']]
        unless space.nil?
          organization_guid = space['organization_guid']
          organization_route_counters = organization_route_counters_hash[organization_guid]
          if organization_route_counters.nil?
            organization_route_counters = { 'total_routes'  => 0,
                                            'unused_routes' => 0
                                          }
            organization_route_counters_hash[organization_guid] = organization_route_counters
          end

          organization_route_counters['unused_routes'] += 1 if route['apps'].length == 0
          organization_route_counters['total_routes'] += 1
        end
      end

      instance_hash = create_instance_hash(deas)

      applications['items'].each do |application|
        space = space_hash[application['space_guid']]
        unless space.nil?
          organization_guid = space['organization_guid']
          organization_app_counters = organization_app_counters_hash[organization_guid]
          if organization_app_counters.nil?
            organization_app_counters = { 'total'           => 0,
                                          'reserved_memory' => 0,
                                          'reserved_disk'   => 0,
                                          'used_memory'     => 0,
                                          'used_disk'       => 0,
                                          'used_cpu'        => 0,
                                          'instances'       => 0
                                        }
            organization_app_counters_hash[organization_guid] = organization_app_counters
          end

          organization_app_counters[application['state']] = 0 if organization_app_counters[application['state']].nil?
          organization_app_counters[application['package_state']] = 0 if organization_app_counters[application['package_state']].nil?

          add_instance_metrics(organization_app_counters, application, instance_hash)

          organization_app_counters['total'] += 1
          organization_app_counters[application['state']] += 1
          organization_app_counters[application['package_state']] += 1
        end
      end

      items = []

      organizations['items'].each do |organization|
        organization_guid = organization['guid']

        organization_developer_counter        = organization_developer_counters[organization_guid]
        organization_space_counter            = organization_space_counters[organization_guid]
        organization_service_instance_counter = organization_service_instance_counters[organization_guid]
        organization_app_counters             = organization_app_counters_hash[organization_guid]
        organization_route_counters           = organization_route_counters_hash[organization_guid]

        row = []

        row.push(organization_guid)

        row.push(organization['name'])
        row.push(organization['status'])
        row.push(DateTime.parse(organization['created_at']).rfc3339)

        if organization['updated_at']
          row.push(DateTime.parse(organization['updated_at']).rfc3339)
        else
          row.push(nil)
        end

        row.push(organization_space_counter || 0)
        row.push(organization_developer_counter || 0)

        quota = quota_hash[organization['quota_definition_guid']]

        if quota
          row.push(quota['name'])
        else
          row.push(nil)
        end

        if organization_route_counters
          row.push(organization_route_counters['total_routes'])
          row.push(organization_route_counters['total_routes'] - organization_route_counters['unused_routes'])
          row.push(organization_route_counters['unused_routes'])
        else
          row.push(0, 0, 0)
        end

        if organization_app_counters
          row.push(organization_app_counters['instances'])
        else
          row.push(0)
        end

        row.push(organization_service_instance_counter || 0)

        if organization_app_counters
          row.push(convert_bytes_to_megabytes(organization_app_counters['used_memory']))
          row.push(convert_bytes_to_megabytes(organization_app_counters['used_disk']))
          row.push(organization_app_counters['used_cpu'] * 100)
          row.push(organization_app_counters['reserved_memory'])
          row.push(organization_app_counters['reserved_disk'])
          row.push(organization_app_counters['total'])
          row.push(organization_app_counters['STARTED'] || 0)
          row.push(organization_app_counters['STOPPED'] || 0)
          row.push(organization_app_counters['PENDING'] || 0)
          row.push(organization_app_counters['STAGED']  || 0)
          row.push(organization_app_counters['FAILED']  || 0)
        else
          row.push(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        end

        row.push(organization)

        items.push(row)
      end

      result(items, (0..23).to_a, (1..4).to_a << 7)
    end
  end
end
