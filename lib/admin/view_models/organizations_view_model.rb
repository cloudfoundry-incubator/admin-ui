require 'date'
require 'set'
require 'thread'
require_relative 'has_instances_view_model'
require_relative '../utils'

module AdminUI
  class OrganizationsViewModel < AdminUI::HasInstancesViewModel
    def do_items
      organizations = @cc.organizations

      # organizations have to exist.  Other record types are optional
      return result unless organizations['connected']

      applications                   = @cc.applications
      apps_routes                    = @cc.apps_routes
      deas                           = @varz.deas
      domains                        = @cc.domains
      events                         = @cc.events
      organizations_auditors         = @cc.organizations_auditors
      organizations_billing_managers = @cc.organizations_billing_managers
      organizations_managers         = @cc.organizations_managers
      organizations_users            = @cc.organizations_users
      quotas                         = @cc.quota_definitions
      routes                         = @cc.routes
      security_groups_spaces         = @cc.security_groups_spaces
      service_brokers                = @cc.service_brokers
      service_instances              = @cc.service_instances
      service_plan_visibilities      = @cc.service_plan_visibilities
      space_quotas                   = @cc.space_quota_definitions
      spaces                         = @cc.spaces
      spaces_auditors                = @cc.spaces_auditors
      spaces_developers              = @cc.spaces_developers
      spaces_managers                = @cc.spaces_managers

      applications_connected              = applications['connected']
      apps_routes_connected               = apps_routes['connected']
      deas_connected                      = deas['connected']
      domains_connected                   = domains['connected']
      events_connected                    = events['connected']
      organizations_roles_connected       = organizations_auditors['connected'] && organizations_billing_managers['connected'] && organizations_managers['connected'] && organizations_users['connected']
      routes_connected                    = routes['connected']
      security_groups_spaces_connected    = security_groups_spaces['connected']
      service_brokers_connected           = service_brokers['connected']
      service_instances_connected         = service_instances['connected']
      service_plan_visibilities_connected = service_plan_visibilities['connected']
      space_quotas_connected              = space_quotas['connected']
      spaces_connected                    = spaces['connected']
      spaces_roles_connected              = spaces_auditors['connected'] && spaces_developers['connected'] && spaces_managers['connected']

      quota_hash      = Hash[quotas['items'].map { |item| [item[:id], item] }]
      routes_used_set = apps_routes['items'].to_set { |app_route| app_route[:route_id] }
      space_hash      = Hash[spaces['items'].map { |item| [item[:id], item] }]

      event_target_counters = {}
      organization_space_counters                   = {}
      organization_role_counters                    = {}
      organization_domain_counters                  = {}
      organization_security_groups_counters         = {}
      organization_service_broker_counters          = {}
      organization_service_instance_counters        = {}
      organization_service_plan_visibility_counters = {}
      organization_route_counters_hash              = {}
      organization_app_counters_hash                = {}
      space_quota_counters                          = {}
      space_role_counters                           = {}

      events['items'].each do |event|
        return result unless @running
        Thread.pass

        organization_guid = event[:organization_guid]
        next if organization_guid.nil?
        event_target_counters[organization_guid] = 0 if event_target_counters[organization_guid].nil?
        event_target_counters[organization_guid] += 1
      end

      space_hash.each_value do |space|
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

      count_space_roles(space_hash, spaces_auditors, space_role_counters)
      count_space_roles(space_hash, spaces_developers, space_role_counters)
      count_space_roles(space_hash, spaces_managers, space_role_counters)

      service_brokers['items'].each do |service_broker|
        return result unless @running
        Thread.pass

        space_id = service_broker[:space_id]
        next if space_id.nil?
        space = space_hash[space_id]
        next if space.nil?
        organization_id = space[:organization_id]
        organization_service_broker_counters[organization_id] = 0 if organization_service_broker_counters[organization_id].nil?
        organization_service_broker_counters[organization_id] += 1
      end

      service_instances['items'].each do |service_instance|
        return result unless @running
        Thread.pass

        space = space_hash[service_instance[:space_id]]
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

        space = space_hash[route[:space_id]]
        next if space.nil?
        organization_id = space[:organization_id]
        organization_route_counters = organization_route_counters_hash[organization_id]
        if organization_route_counters.nil?
          organization_route_counters = { 'total_routes'  => 0,
                                          'unused_routes' => 0
                                        }
          organization_route_counters_hash[organization_id] = organization_route_counters
        end

        if apps_routes_connected
          organization_route_counters['unused_routes'] += 1 unless routes_used_set.include?(route[:id])
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

        space = space_hash[security_group_space[:space_id]]
        next if space.nil?
        organization_id = space[:organization_id]
        organization_security_groups_counters[organization_id] = 0 if organization_security_groups_counters[organization_id].nil?
        organization_security_groups_counters[organization_id] += 1
      end

      instance_hash = create_instance_hash(deas)

      applications['items'].each do |application|
        return result unless @running
        Thread.pass

        space = space_hash[application[:space_id]]
        next if space.nil?
        organization_id = space[:organization_id]
        organization_app_counters = organization_app_counters_hash[organization_id]
        if organization_app_counters.nil?
          organization_app_counters = { 'total'           => 0,
                                        'reserved_memory' => 0,
                                        'reserved_disk'   => 0,
                                        'used_memory'     => 0,
                                        'used_disk'       => 0,
                                        'used_cpu'        => 0,
                                        'instances'       => 0
                                      }
          organization_app_counters_hash[organization_id] = organization_app_counters
        end

        organization_app_counters[application[:state]] = 0 if organization_app_counters[application[:state]].nil?
        organization_app_counters[application[:package_state]] = 0 if organization_app_counters[application[:package_state]].nil?

        add_instance_metrics(organization_app_counters, application, instance_hash)

        organization_app_counters['total'] += 1
        organization_app_counters[application[:state]] += 1
        organization_app_counters[application[:package_state]] += 1
        organization_app_counters['instances'] += application[:instances] unless application[:instances].nil?
      end

      items = []
      hash  = {}

      organizations['items'].each do |organization|
        return result unless @running
        Thread.pass

        organization_id   = organization[:id]
        organization_guid = organization[:guid]
        quota             = quota_hash[organization[:quota_definition_id]]

        event_target_counter                         = event_target_counters[organization_guid]
        organization_role_counter                    = organization_role_counters[organization_id]
        organization_space_counter                   = organization_space_counters[organization_id]
        organization_service_broker_counter          = organization_service_broker_counters[organization_id]
        organization_service_instance_counter        = organization_service_instance_counters[organization_id]
        organization_service_plan_visibility_counter = organization_service_plan_visibility_counters[organization_id]
        organization_security_groups_counter         = organization_security_groups_counters[organization_id]
        organization_app_counters                    = organization_app_counters_hash[organization_id]
        organization_domain_counter                  = organization_domain_counters[organization_id]
        organization_route_counters                  = organization_route_counters_hash[organization_id]
        space_quota_counter                          = space_quota_counters[organization_id]
        space_role_counter                           = space_role_counters[organization_id]

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

        if organization_route_counters
          row.push(organization_route_counters['total_routes'])
          row.push(organization_route_counters['total_routes'] - organization_route_counters['unused_routes'])
          row.push(organization_route_counters['unused_routes'])
        elsif spaces_connected && routes_connected
          row.push(0, 0, 0)
        else
          row.push(nil, nil, nil)
        end

        if deas_connected && organization_app_counters
          row.push(organization_app_counters['instances'])
        elsif deas_connected && spaces_connected && applications_connected
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

        if organization_app_counters
          if deas_connected
            row.push(Utils.convert_bytes_to_megabytes(organization_app_counters['used_memory']))
            row.push(Utils.convert_bytes_to_megabytes(organization_app_counters['used_disk']))
            row.push(organization_app_counters['used_cpu'] * 100)
          else
            row.push(nil, nil, nil)
          end
          row.push(organization_app_counters['reserved_memory'])
          row.push(organization_app_counters['reserved_disk'])
          row.push(organization_app_counters['total'])
          row.push(organization_app_counters['STARTED'] || 0)
          row.push(organization_app_counters['STOPPED'] || 0)
          row.push(organization_app_counters['PENDING'] || 0)
          row.push(organization_app_counters['STAGED'] || 0)
          row.push(organization_app_counters['FAILED'] || 0)
        elsif spaces_connected && applications_connected
          if deas_connected
            row.push(0, 0, 0)
          else
            row.push(nil, nil, nil)
          end
          row.push(0, 0, 0, 0, 0, 0, 0, 0)
        else
          row.push(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
        end

        items.push(row)

        hash[organization_guid] =
        {
          'organization'     => organization,
          'quota_definition' => quota
        }
      end

      result(true, items, hash, (1..31).to_a, (1..5).to_a << 10)
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

    def count_space_roles(space_hash, input_space_role_array, output_space_role_counter_hash)
      input_space_role_array['items'].each do |input_space_role_array_entry|
        Thread.pass
        space = space_hash[input_space_role_array_entry[:space_id]]
        next if space.nil?
        organization_id = space[:organization_id]
        output_space_role_counter_hash[organization_id] = 0 if output_space_role_counter_hash[organization_id].nil?
        output_space_role_counter_hash[organization_id] += 1
      end
    end
  end
end
