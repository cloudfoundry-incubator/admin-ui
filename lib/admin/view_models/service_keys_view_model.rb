require 'date'
require_relative 'base_view_model'

module AdminUI
  class ServiceKeysViewModel < AdminUI::BaseViewModel
    def do_items
      service_keys = @cc.service_keys

      # service_keys have to exist. Other record types are optional
      return result unless service_keys['connected']

      events                 = @cc.events
      organizations          = @cc.organizations
      service_brokers        = @cc.service_brokers
      service_instances      = @cc.service_instances
      service_key_annotations = @cc.service_key_annotations
      service_key_labels      = @cc.service_key_labels
      service_key_operations = @cc.service_key_operations
      service_plans          = @cc.service_plans
      services               = @cc.services
      spaces                 = @cc.spaces

      events_connected = events['connected']

      organization_hash          = organizations['items'].map { |item| [item[:id], item] }.to_h
      service_broker_hash        = service_brokers['items'].map { |item| [item[:id], item] }.to_h
      service_instance_hash      = service_instances['items'].map { |item| [item[:id], item] }.to_h
      service_key_operation_hash = service_key_operations['items'].map { |item| [item[:service_key_id], item] }.to_h
      service_plan_hash          = service_plans['items'].map { |item| [item[:id], item] }.to_h
      service_hash               = services['items'].map { |item| [item[:id], item] }.to_h
      space_hash                 = spaces['items'].map { |item| [item[:id], item] }.to_h

      service_key_annotations_hash = {}
      service_key_annotations['items'].each do |service_key_annotation|
        return result unless @running

        Thread.pass

        service_key_guid = service_key_annotation[:resource_guid]
        service_key_annotations_array = service_key_annotations_hash[service_key_guid]
        if service_key_annotations_array.nil?
          service_key_annotations_array = []
          service_key_annotations_hash[service_key_guid] = service_key_annotations_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            annotation:         service_key_annotation,
            created_at_rfc3339: service_key_annotation[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: service_key_annotation[:updated_at].nil? ? nil : service_key_annotation[:updated_at].to_datetime.rfc3339
          }

        service_key_annotations_array.push(wrapper)
      end

      service_key_labels_hash = {}
      service_key_labels['items'].each do |service_key_label|
        return result unless @running

        Thread.pass

        service_key_guid = service_key_label[:resource_guid]
        service_key_labels_array = service_key_labels_hash[service_key_guid]
        if service_key_labels_array.nil?
          service_key_labels_array = []
          service_key_labels_hash[service_key_guid] = service_key_labels_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            label:              service_key_label,
            created_at_rfc3339: service_key_label[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: service_key_label[:updated_at].nil? ? nil : service_key_label[:updated_at].to_datetime.rfc3339
          }

        service_key_labels_array.push(wrapper)
      end

      event_counters = {}
      events['items'].each do |event|
        return result unless @running

        Thread.pass

        next unless event[:actee_type] == 'service_key'

        actee = event[:actee]
        event_counters[actee] = 0 if event_counters[actee].nil?
        event_counters[actee] += 1
      end

      items = []
      hash  = {}

      service_keys['items'].each do |service_key|
        return result unless @running

        Thread.pass

        guid                  = service_key[:guid]
        id                    = service_key[:id]
        service_instance      = service_instance_hash[service_key[:service_instance_id]]
        service_key_operation = service_key_operation_hash[id]
        service_plan_id       = service_instance.nil? ? nil : service_instance[:service_plan_id]
        service_plan          = service_plan_id.nil? ? nil : service_plan_hash[service_plan_id]
        service               = service_plan.nil? ? nil : service_hash[service_plan[:service_id]]
        service_broker        = service.nil? || service[:service_broker_id].nil? ? nil : service_broker_hash[service[:service_broker_id]]
        space                 = service_instance.nil? ? nil : space_hash[service_instance[:space_id]]
        organization          = space.nil? ? nil : organization_hash[space[:organization_id]]

        event_counter                = event_counters[guid]
        service_key_annotation_array = service_key_annotations_hash[guid] || []
        service_key_label_array      = service_key_labels_hash[guid] || []

        row = []

        row.push(guid)
        row.push(service_key[:name])
        row.push(guid)
        row.push(service_key[:created_at].to_datetime.rfc3339)

        if service_key[:updated_at]
          row.push(service_key[:updated_at].to_datetime.rfc3339)
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

        if service_key_operation
          row.push(service_key_operation[:type])
          row.push(service_key_operation[:state])
          row.push(service_key_operation[:created_at].to_datetime.rfc3339)

          if service_key_operation[:updated_at]
            row.push(service_key_operation[:updated_at].to_datetime.rfc3339)
          else
            row.push(nil)
          end
        else
          row.push(nil, nil, nil, nil)
        end

        if service_instance
          row.push(service_instance[:name])
          row.push(service_instance[:guid])
          row.push(service_instance[:created_at].to_datetime.rfc3339)

          if service_instance[:updated_at]
            row.push(service_instance[:updated_at].to_datetime.rfc3339)
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

          row.push(service_plan[:free])
          row.push(service_plan[:active])
          row.push(service_plan[:public])
        else
          row.push(nil, nil, nil, nil, nil, nil, nil, nil)
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

          row.push(service[:active])
        else
          row.push(nil, nil, nil, nil, nil, nil)
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
            'annotations'           => service_key_annotation_array,
            'labels'                => service_key_label_array,
            'organization'          => organization,
            'service'               => service,
            'service_broker'        => service_broker,
            'service_instance'      => service_instance,
            'service_key'           => service_key,
            'service_key_operation' => service_key_operation,
            'service_plan'          => service_plan,
            'space'                 => space
          }
      end

      result(true, items, hash, (1..32).to_a, (1..32).to_a - [5])
    end
  end
end
