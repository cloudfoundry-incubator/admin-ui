require 'date'
require 'yajl'
require_relative 'base_view_model'

module AdminUI
  class ServicePlansViewModel < AdminUI::BaseViewModel
    def do_items
      service_plans = @cc.service_plans

      # service_plans have to exist. Other record types are optional
      return result unless service_plans['connected']

      events                    = @cc.events
      route_bindings            = @cc.route_bindings
      services                  = @cc.services
      service_bindings          = @cc.service_bindings
      service_brokers           = @cc.service_brokers
      service_instances         = @cc.service_instances
      service_instance_shares   = @cc.service_instance_shares
      service_keys              = @cc.service_keys
      service_plan_annotations  = @cc.service_plan_annotations
      service_plan_labels       = @cc.service_plan_labels
      service_plan_visibilities = @cc.service_plan_visibilities

      events_connected                    = events['connected']
      route_bindings_connected            = route_bindings['connected']
      service_bindings_connected          = service_bindings['connected']
      service_instances_connected         = service_instances['connected']
      service_instance_shares_connected   = service_instance_shares['connected']
      service_keys_connected              = service_keys['connected']
      service_plan_visibilities_connected = service_plan_visibilities['connected']

      service_broker_hash        = service_brokers['items'].map { |item| [item[:id], item] }.to_h
      service_hash               = services['items'].map { |item| [item[:id], item] }.to_h
      service_instance_guid_hash = service_instances['items'].map { |item| [item[:guid], item] }.to_h
      service_instance_id_hash   = service_instances['items'].map { |item| [item[:id], item] }.to_h

      service_plan_annotations_hash = {}
      service_plan_annotations['items'].each do |service_plan_annotation|
        return result unless @running

        Thread.pass

        service_plan_guid = service_plan_annotation[:resource_guid]
        service_plan_annotations_array = service_plan_annotations_hash[service_plan_guid]
        if service_plan_annotations_array.nil?
          service_plan_annotations_array = []
          service_plan_annotations_hash[service_plan_guid] = service_plan_annotations_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            annotation:         service_plan_annotation,
            created_at_rfc3339: service_plan_annotation[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: service_plan_annotation[:updated_at].nil? ? nil : service_plan_annotation[:updated_at].to_datetime.rfc3339
          }

        service_plan_annotations_array.push(wrapper)
      end

      service_plan_labels_hash = {}
      service_plan_labels['items'].each do |service_plan_label|
        return result unless @running

        Thread.pass

        service_plan_guid = service_plan_label[:resource_guid]
        service_plan_labels_array = service_plan_labels_hash[service_plan_guid]
        if service_plan_labels_array.nil?
          service_plan_labels_array = []
          service_plan_labels_hash[service_plan_guid] = service_plan_labels_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            label:              service_plan_label,
            created_at_rfc3339: service_plan_label[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: service_plan_label[:updated_at].nil? ? nil : service_plan_label[:updated_at].to_datetime.rfc3339
          }

        service_plan_labels_array.push(wrapper)
      end

      event_counters = {}
      events['items'].each do |event|
        return result unless @running

        Thread.pass

        next unless event[:actee_type] == 'service_plan'

        actee = event[:actee]
        event_counters[actee] = 0 if event_counters[actee].nil?
        event_counters[actee] += 1
      end

      service_plan_visibility_counters = {}
      service_plan_visibilities['items'].each do |service_plan_visibility|
        return result unless @running

        Thread.pass

        service_plan_id = service_plan_visibility[:service_plan_id]
        next if service_plan_id.nil?

        service_plan_visibility_counters[service_plan_id] = 0 if service_plan_visibility_counters[service_plan_id].nil?
        service_plan_visibility_counters[service_plan_id] += 1
      end

      service_instance_counters = {}
      service_instances['items'].each do |service_instance|
        return result unless @running

        Thread.pass

        service_plan_id = service_instance[:service_plan_id]
        next if service_plan_id.nil?

        service_instance_counters[service_plan_id] = 0 if service_instance_counters[service_plan_id].nil?
        service_instance_counters[service_plan_id] += 1
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

        service_instance_share_counters[service_plan_id] = 0 if service_instance_share_counters[service_plan_id].nil?
        service_instance_share_counters[service_plan_id] += 1
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

        service_binding_counters[service_plan_id] = 0 if service_binding_counters[service_plan_id].nil?
        service_binding_counters[service_plan_id] += 1
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

        service_key_counters[service_plan_id] = 0 if service_key_counters[service_plan_id].nil?
        service_key_counters[service_plan_id] += 1
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

        route_binding_counters[service_plan_id] = 0 if route_binding_counters[service_plan_id].nil?
        route_binding_counters[service_plan_id] += 1
      end

      items = []
      hash  = {}

      service_plans['items'].each do |service_plan|
        return result unless @running

        Thread.pass

        guid           = service_plan[:guid]
        id             = service_plan[:id]
        service        = service_hash[service_plan[:service_id]]
        service_broker = service.nil? || service[:service_broker_id].nil? ? nil : service_broker_hash[service[:service_broker_id]]

        event_counter                   = event_counters[guid]
        route_binding_counter           = route_binding_counters[id]
        service_binding_counter         = service_binding_counters[id]
        service_instance_counter        = service_instance_counters[id]
        service_instance_share_counter  = service_instance_share_counters[id]
        service_key_counter             = service_key_counters[id]
        service_plan_annotation_array   = service_plan_annotations_hash[guid] || []
        service_plan_label_array        = service_plan_labels_hash[guid] || []
        service_plan_visibility_counter = service_plan_visibility_counters[id]

        row = []

        row.push(guid)
        row.push(service_plan[:name])
        row.push(guid)
        row.push(service_plan[:unique_id])
        row.push(service_plan[:created_at].to_datetime.rfc3339)

        if service_plan[:updated_at]
          row.push(service_plan[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        row.push(service_plan[:bindable])
        row.push(service_plan[:plan_updateable])
        row.push(service_plan[:free])
        row.push(service_plan[:active])
        row.push(service_plan[:public])

        display_name = nil
        if service_plan[:extra]
          begin
            json = Yajl::Parser.parse(service_plan[:extra])

            display_name = json['displayName']
          rescue
            display_name = nil
          end
        end
        row.push(display_name)

        if event_counter
          row.push(event_counter)
        elsif events_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_plan_visibility_counter
          row.push(service_plan_visibility_counter)
        elsif service_plan_visibilities_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_instance_counter
          row.push(service_instance_counter)
        elsif service_instances_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_instance_share_counter
          row.push(service_instance_share_counter)
        elsif service_instance_shares_connected && service_instances_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_binding_counter
          row.push(service_binding_counter)
        elsif service_bindings_connected && service_instances_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_key_counter
          row.push(service_key_counter)
        elsif service_keys_connected && service_instances_connected
          row.push(0)
        else
          row.push(nil)
        end

        if route_binding_counter
          row.push(route_binding_counter)
        elsif route_bindings_connected && service_instances_connected
          row.push(0)
        else
          row.push(nil)
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

        items.push(row)

        hash[guid] =
          {
            'annotations'    => service_plan_annotation_array,
            'labels'         => service_plan_label_array,
            'service'        => service,
            'service_broker' => service_broker,
            'service_plan'   => service_plan
          }
      end

      result(true, items, hash, (1..29).to_a, (1..29).to_a - [12, 13, 14, 15, 16, 17, 18])
    end
  end
end
