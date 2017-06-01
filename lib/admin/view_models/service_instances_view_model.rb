require 'date'
require 'thread'
require_relative 'base_view_model'

module AdminUI
  class ServiceInstancesViewModel < AdminUI::BaseViewModel
    def do_items
      service_instances = @cc.service_instances

      # service_instances have to exist.  Other record types are optional
      return result unless service_instances['connected']

      events                      = @cc.events
      organizations               = @cc.organizations
      route_bindings              = @cc.route_bindings
      service_brokers             = @cc.service_brokers
      service_bindings            = @cc.service_bindings
      service_instance_operations = @cc.service_instance_operations
      service_keys                = @cc.service_keys
      service_plans               = @cc.service_plans
      services                    = @cc.services
      spaces                      = @cc.spaces

      events_connected           = events['connected']
      route_bindings_connected   = route_bindings['connected']
      service_bindings_connected = service_bindings['connected']
      service_keys_connected     = service_keys['connected']

      organization_hash               = Hash[organizations['items'].map { |item| [item[:id], item] }]
      service_broker_hash             = Hash[service_brokers['items'].map { |item| [item[:id], item] }]
      service_instance_operation_hash = Hash[service_instance_operations['items'].map { |item| [item[:service_instance_id], item] }]
      service_plan_hash               = Hash[service_plans['items'].map { |item| [item[:id], item] }]
      service_hash                    = Hash[services['items'].map { |item| [item[:id], item] }]
      space_hash                      = Hash[spaces['items'].map { |item| [item[:id], item] }]

      event_counters = {}
      events['items'].each do |event|
        return result unless @running
        Thread.pass

        actee_type = event[:actee_type]
        next unless %w[service_instance user_provided_service_instance].include?(actee_type)
        actee = event[:actee]
        event_counters[actee] = 0 if event_counters[actee].nil?
        event_counters[actee] += 1
      end

      service_binding_counters = {}
      service_bindings['items'].each do |service_binding|
        return result unless @running
        Thread.pass

        service_instance_guid = service_binding[:service_instance_guid]
        next if service_instance_guid.nil?
        service_binding_counters[service_instance_guid] = 0 if service_binding_counters[service_instance_guid].nil?
        service_binding_counters[service_instance_guid] += 1
      end

      service_key_counters = {}
      service_keys['items'].each do |service_key|
        return result unless @running
        Thread.pass

        service_instance_id = service_key[:service_instance_id]
        next if service_instance_id.nil?
        service_key_counters[service_instance_id] = 0 if service_key_counters[service_instance_id].nil?
        service_key_counters[service_instance_id] += 1
      end

      route_binding_counters = {}
      route_bindings['items'].each do |route_binding|
        return result unless @running
        Thread.pass

        service_instance_id = route_binding[:service_instance_id]
        next if service_instance_id.nil?
        route_binding_counters[service_instance_id] = 0 if route_binding_counters[service_instance_id].nil?
        route_binding_counters[service_instance_id] += 1
      end

      items = []
      hash  = {}

      service_instances['items'].each do |service_instance|
        return result unless @running
        Thread.pass

        guid                       = service_instance[:guid]
        id                         = service_instance[:id]
        is_gateway_service         = service_instance[:is_gateway_service].nil? ? true : service_instance[:is_gateway_service]
        service_instance_operation = service_instance_operation_hash[id]
        service_plan_id            = service_instance[:service_plan_id]
        service_plan               = service_plan_id.nil? ? nil : service_plan_hash[service_plan_id]
        service                    = service_plan.nil? ? nil : service_hash[service_plan[:service_id]]
        service_broker             = service.nil? || service[:service_broker_id].nil? ? nil : service_broker_hash[service[:service_broker_id]]
        space                      = space_hash[service_instance[:space_id]]
        organization               = space.nil? ? nil : organization_hash[space[:organization_id]]

        event_counter           = event_counters[guid]
        route_binding_counter   = route_binding_counters[id]
        service_binding_counter = service_binding_counters[guid]
        service_key_counter     = service_key_counters[id]

        row = []

        row.push("#{guid}/#{is_gateway_service}")
        row.push(service_instance[:name])
        row.push(guid)
        row.push(service_instance[:created_at].to_datetime.rfc3339)

        if service_instance[:updated_at]
          row.push(service_instance[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        row.push(!is_gateway_service)

        row.push(!service_instance[:syslog_drain_url].nil? && service_instance[:syslog_drain_url].length.positive?)

        if event_counter
          row.push(event_counter)
        elsif events_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_binding_counter
          row.push(service_binding_counter)
        elsif service_bindings_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_key_counter
          row.push(service_key_counter)
        elsif service_keys_connected
          row.push(0)
        else
          row.push(nil)
        end

        if route_binding_counter
          row.push(route_binding_counter)
        elsif route_bindings_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_instance_operation
          row.push(service_instance_operation[:type])
          row.push(service_instance_operation[:state])
          row.push(service_instance_operation[:created_at].to_datetime.rfc3339)

          if service_instance_operation[:updated_at]
            row.push(service_instance_operation[:updated_at].to_datetime.rfc3339)
          else
            row.push(nil)
          end
        else
          row.push(nil, nil, nil, nil)
        end

        if service_plan
          row.push(service_plan[:name])
          row.push(service_plan[:guid])
          row.push(service_plan[:unique_id])
          row.push(service_plan[:created_at].to_datetime.rfc3339)

          if service_plan[:updated_at]
            row.push(service_plan[:updated_at].to_datetime.rfc3339)
          else
            row.push(nil)
          end

          row.push(service_plan[:bindable])
          row.push(service_plan[:free])
          row.push(service_plan[:active])
          row.push(service_plan[:public])
        else
          row.push(nil, nil, nil, nil, nil, nil, nil, nil, nil)
        end

        if service
          row.push(service[:label])
          row.push(service[:guid])
          row.push(service[:unique_id])
          row.push(service[:created_at].to_datetime.rfc3339)

          if service[:updated_at]
            row.push(service[:updated_at].to_datetime.rfc3339)
          else
            row.push(nil)
          end

          row.push(service[:bindable])
          row.push(service[:active])
        else
          row.push(nil, nil, nil, nil, nil, nil, nil)
        end

        if service_broker
          row.push(service_broker[:name])
          row.push(service_broker[:guid])
          row.push(service_broker[:created_at].to_datetime.rfc3339)

          if service_broker[:updated_at]
            row.push(service_broker[:updated_at].to_datetime.rfc3339)
          else
            row.push(nil)
          end
        else
          row.push(nil, nil, nil, nil)
        end

        if organization && space
          row.push("#{organization[:name]}/#{space[:name]}")
        else
          row.push(nil)
        end

        items.push(row)

        hash[guid] =
          {
            'organization'               => organization,
            'service'                    => service,
            'service_broker'             => service_broker,
            'service_instance'           => service_instance,
            'service_instance_operation' => service_instance_operation,
            'service_plan'               => service_plan,
            'space'                      => space
          }
      end

      result(true, items, hash, (1..35).to_a, (1..35).to_a - [7, 8, 9, 10])
    end
  end
end
