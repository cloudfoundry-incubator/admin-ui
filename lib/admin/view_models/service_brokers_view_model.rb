require 'date'
require_relative 'base_view_model'

module AdminUI
  class ServiceBrokersViewModel < AdminUI::BaseViewModel
    def do_items
      service_brokers = @cc.service_brokers

      # service_brokers have to exist. Other record types are optional
      return result unless service_brokers['connected']

      events                     = @cc.events
      organizations              = @cc.organizations
      route_bindings             = @cc.route_bindings
      service_bindings           = @cc.service_bindings
      service_broker_annotations = @cc.service_broker_annotations
      service_broker_labels      = @cc.service_broker_labels
      service_dashboard_clients  = @cc.service_dashboard_clients
      service_instances          = @cc.service_instances
      service_instance_shares    = @cc.service_instance_shares
      service_keys               = @cc.service_keys
      service_plans              = @cc.service_plans
      service_plan_visibilities  = @cc.service_plan_visibilities
      services                   = @cc.services
      spaces                     = @cc.spaces

      events_connected                    = events['connected']
      route_bindings_connected            = route_bindings['connected']
      service_bindings_connected          = service_bindings['connected']
      service_instances_connected         = service_instances['connected']
      service_instance_shares_connected   = service_instance_shares['connected']
      service_keys_connected              = service_keys['connected']
      service_plans_connected             = service_plans['connected']
      service_plan_visibilities_connected = service_plan_visibilities['connected']
      services_connected                  = service_plans['connected']

      organization_hash             = organizations['items'].map { |item| [item[:id], item] }.to_h
      service_dashboard_client_hash = service_dashboard_clients['items'].map { |item| [item[:service_broker_id], item] }.to_h
      service_hash                  = services['items'].map { |item| [item[:id], item] }.to_h
      service_instance_guid_hash    = service_instances['items'].map { |item| [item[:guid], item] }.to_h
      service_instance_id_hash      = service_instances['items'].map { |item| [item[:id], item] }.to_h
      service_plan_hash             = service_plans['items'].map { |item| [item[:id], item] }.to_h
      space_hash                    = spaces['items'].map { |item| [item[:id], item] }.to_h

      service_broker_annotations_hash = {}
      service_broker_annotations['items'].each do |service_broker_annotation|
        return result unless @running

        Thread.pass

        service_broker_guid = service_broker_annotation[:resource_guid]
        service_broker_annotations_array = service_broker_annotations_hash[service_broker_guid]
        if service_broker_annotations_array.nil?
          service_broker_annotations_array = []
          service_broker_annotations_hash[service_broker_guid] = service_broker_annotations_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            annotation:         service_broker_annotation,
            created_at_rfc3339: service_broker_annotation[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: service_broker_annotation[:updated_at].nil? ? nil : service_broker_annotation[:updated_at].to_datetime.rfc3339
          }

        service_broker_annotations_array.push(wrapper)
      end

      service_broker_labels_hash = {}
      service_broker_labels['items'].each do |service_broker_label|
        return result unless @running

        Thread.pass

        service_broker_guid = service_broker_label[:resource_guid]
        service_broker_labels_array = service_broker_labels_hash[service_broker_guid]
        if service_broker_labels_array.nil?
          service_broker_labels_array = []
          service_broker_labels_hash[service_broker_guid] = service_broker_labels_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            label:              service_broker_label,
            created_at_rfc3339: service_broker_label[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: service_broker_label[:updated_at].nil? ? nil : service_broker_label[:updated_at].to_datetime.rfc3339
          }

        service_broker_labels_array.push(wrapper)
      end

      event_counters = {}
      events['items'].each do |event|
        return result unless @running

        Thread.pass

        if event[:actee_type] == 'service_broker'
          actee = event[:actee]
          event_counters[actee] = 0 if event_counters[actee].nil?
          event_counters[actee] += 1
        elsif event[:actor_type] == 'service_broker'
          actor = event[:actor]
          event_counters[actor] = 0 if event_counters[actor].nil?
          event_counters[actor] += 1
        end
      end

      service_counters = {}
      services['items'].each do |service|
        return result unless @running

        Thread.pass

        service_broker_id = service[:service_broker_id]
        next if service_broker_id.nil?

        service_counters[service_broker_id] = 0 if service_counters[service_broker_id].nil?
        service_counters[service_broker_id] += 1
      end

      service_plan_counters = {}
      service_plan_public_active_counters = {}
      service_plans['items'].each do |service_plan|
        return result unless @running

        Thread.pass

        service = service_hash[service_plan[:service_id]]
        next if service.nil?

        service_broker_id = service[:service_broker_id]
        next if service_broker_id.nil?

        service_plan_counters[service_broker_id] = 0 if service_plan_counters[service_broker_id].nil?
        service_plan_counters[service_broker_id] += 1

        next unless service_plan[:public] && service_plan[:active]

        service_plan_public_active_counters[service_broker_id] = 0 if service_plan_public_active_counters[service_broker_id].nil?
        service_plan_public_active_counters[service_broker_id] += 1
      end

      service_plan_visibility_counters = {}
      service_plan_visibilities['items'].each do |service_plan_visibility|
        return result unless @running

        Thread.pass

        service_plan_id = service_plan_visibility[:service_plan_id]
        next if service_plan_id.nil?

        service_plan = service_plan_hash[service_plan_id]
        next if service_plan.nil?

        service = service_hash[service_plan[:service_id]]
        next if service.nil?

        service_broker_id = service[:service_broker_id]
        next if service_broker_id.nil?

        service_plan_visibility_counters[service_broker_id] = 0 if service_plan_visibility_counters[service_broker_id].nil?
        service_plan_visibility_counters[service_broker_id] += 1
      end

      service_instance_counters = {}
      service_instances['items'].each do |service_instance|
        return result unless @running

        Thread.pass

        service_plan_id = service_instance[:service_plan_id]
        next if service_plan_id.nil?

        service_plan = service_plan_hash[service_plan_id]
        next if service_plan.nil?

        service = service_hash[service_plan[:service_id]]
        next if service.nil?

        service_broker_id = service[:service_broker_id]
        next if service_broker_id.nil?

        service_instance_counters[service_broker_id] = 0 if service_instance_counters[service_broker_id].nil?
        service_instance_counters[service_broker_id] += 1
      end

      service_instance_share_counters = {}
      service_instance_shares['items'].each do |service_instance_share|
        return result unless @running

        Thread.pass

        service_instance_guid = service_instance_share[:service_instance_guid]
        next if service_instance_guid.nil?

        service_instance = service_instance_guid_hash[service_instance_guid]
        next if service_instance.nil?

        service_plan_id = service_instance[:service_plan_id]
        next if service_plan_id.nil?

        service_plan = service_plan_hash[service_plan_id]
        next if service_plan.nil?

        service = service_hash[service_plan[:service_id]]
        next if service.nil?

        service_broker_id = service[:service_broker_id]
        next if service_broker_id.nil?

        service_instance_share_counters[service_broker_id] = 0 if service_instance_share_counters[service_broker_id].nil?
        service_instance_share_counters[service_broker_id] += 1
      end

      service_binding_counters = {}
      service_bindings['items'].each do |service_binding|
        return result unless @running

        Thread.pass

        service_instance_guid = service_binding[:service_instance_guid]
        next if service_instance_guid.nil?

        service_instance = service_instance_guid_hash[service_instance_guid]
        next if service_instance.nil?

        service_plan_id = service_instance[:service_plan_id]
        next if service_plan_id.nil?

        service_plan = service_plan_hash[service_plan_id]
        next if service_plan.nil?

        service = service_hash[service_plan[:service_id]]
        next if service.nil?

        service_broker_id = service[:service_broker_id]
        next if service_broker_id.nil?

        service_binding_counters[service_broker_id] = 0 if service_binding_counters[service_broker_id].nil?
        service_binding_counters[service_broker_id] += 1
      end

      service_key_counters = {}
      service_keys['items'].each do |service_key|
        return result unless @running

        Thread.pass

        service_instance_id = service_key[:service_instance_id]
        next if service_instance_id.nil?

        service_instance = service_instance_id_hash[service_instance_id]
        next if service_instance.nil?

        service_plan_id = service_instance[:service_plan_id]
        next if service_plan_id.nil?

        service_plan = service_plan_hash[service_plan_id]
        next if service_plan.nil?

        service = service_hash[service_plan[:service_id]]
        next if service.nil?

        service_broker_id = service[:service_broker_id]
        next if service_broker_id.nil?

        service_key_counters[service_broker_id] = 0 if service_key_counters[service_broker_id].nil?
        service_key_counters[service_broker_id] += 1
      end

      route_binding_counters = {}
      route_bindings['items'].each do |route_binding|
        return result unless @running

        Thread.pass

        service_instance_id = route_binding[:service_instance_id]
        next if service_instance_id.nil?

        service_instance = service_instance_id_hash[service_instance_id]
        next if service_instance.nil?

        service_plan_id = service_instance[:service_plan_id]
        next if service_plan_id.nil?

        service_plan = service_plan_hash[service_plan_id]
        next if service_plan.nil?

        service = service_hash[service_plan[:service_id]]
        next if service.nil?

        service_broker_id = service[:service_broker_id]
        next if service_broker_id.nil?

        route_binding_counters[service_broker_id] = 0 if route_binding_counters[service_broker_id].nil?
        route_binding_counters[service_broker_id] += 1
      end

      items = []
      hash  = {}

      service_brokers['items'].each do |service_broker|
        return result unless @running

        Thread.pass

        guid                     = service_broker[:guid]
        id                       = service_broker[:id]
        service_dashboard_client = service_dashboard_client_hash[id]
        space_id                 = service_broker[:space_id]
        space                    = space_id.nil? ? nil : space_hash[space_id]
        organization             = space.nil? ? nil : organization_hash[space[:organization_id]]

        event_counter                      = event_counters[guid]
        route_binding_counter              = route_binding_counters[id]
        service_binding_counter            = service_binding_counters[id]
        service_broker_annotation_array    = service_broker_annotations_hash[guid] || []
        service_broker_label_array         = service_broker_labels_hash[guid] || []
        service_counter                    = service_counters[id]
        service_instance_counter           = service_instance_counters[id]
        service_instance_share_counter     = service_instance_share_counters[id]
        service_key_counter                = service_key_counters[id]
        service_plan_counter               = service_plan_counters[id]
        service_plan_public_active_counter = service_plan_public_active_counters[id]
        service_plan_visibility_counter    = service_plan_visibility_counters[id]

        row = []

        row.push(guid)
        row.push(service_broker[:name])
        row.push(guid)
        row.push(service_broker[:created_at].to_datetime.rfc3339)

        if service_broker[:updated_at]
          row.push(service_broker[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        row.push(service_broker[:state])

        if event_counter
          row.push(event_counter)
        elsif events_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_dashboard_client
          row.push(service_dashboard_client[:uaa_id])
        else
          row.push(nil)
        end

        if service_counter
          row.push(service_counter)
        elsif services_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_plan_counter
          row.push(service_plan_counter)
        elsif service_plans_connected && services_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_plan_public_active_counter
          row.push(service_plan_public_active_counter)
        elsif service_plans_connected && services_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_plan_visibility_counter
          row.push(service_plan_visibility_counter)
        elsif service_plan_visibilities_connected && service_plans_connected && services_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_instance_counter
          row.push(service_instance_counter)
        elsif service_instances_connected && service_plans_connected && services_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_instance_share_counter
          row.push(service_instance_share_counter)
        elsif service_instance_shares_connected && service_instances_connected && service_plans_connected && services_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_binding_counter
          row.push(service_binding_counter)
        elsif service_bindings_connected && service_instances_connected && service_plans_connected && services_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_key_counter
          row.push(service_key_counter)
        elsif service_keys_connected && service_instances_connected && service_plans_connected && services_connected
          row.push(0)
        else
          row.push(nil)
        end

        if route_binding_counter
          row.push(route_binding_counter)
        elsif route_bindings_connected && service_instances_connected && service_plans_connected && services_connected
          row.push(0)
        else
          row.push(nil)
        end

        if organization && space
          row.push("#{organization[:name]}/#{space[:name]}")
        else
          row.push(nil)
        end

        items.push(row)

        hash[guid] =
          {
            'annotations'    => service_broker_annotation_array,
            'labels'         => service_broker_label_array,
            'organization'   => organization,
            'service_broker' => service_broker,
            'space'          => space
          }
      end

      result(true, items, hash, (1..17).to_a, [1, 2, 3, 4, 5, 7, 17])
    end
  end
end
