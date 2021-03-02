require 'date'
require_relative 'base_view_model'

module AdminUI
  class ServiceBindingsViewModel < AdminUI::BaseViewModel
    def do_items
      service_bindings = @cc.service_bindings

      # service_bindings have to exist. Other record types are optional
      return result unless service_bindings['connected']

      applications                = @cc.applications
      events                      = @cc.events
      organizations               = @cc.organizations
      service_binding_annotations = @cc.service_binding_annotations
      service_binding_labels      = @cc.service_binding_labels
      service_binding_operations  = @cc.service_binding_operations
      service_brokers             = @cc.service_brokers
      service_instances           = @cc.service_instances
      service_plans               = @cc.service_plans
      services                    = @cc.services
      spaces                      = @cc.spaces

      events_connected = events['connected']

      application_hash               = applications['items'].map { |item| [item[:guid], item] }.to_h
      organization_hash              = organizations['items'].map { |item| [item[:id], item] }.to_h
      service_binding_operation_hash = service_binding_operations['items'].map { |item| [item[:service_binding_id], item] }.to_h
      service_broker_hash            = service_brokers['items'].map { |item| [item[:id], item] }.to_h
      service_instance_hash          = service_instances['items'].map { |item| [item[:guid], item] }.to_h
      service_plan_hash              = service_plans['items'].map { |item| [item[:id], item] }.to_h
      service_hash                   = services['items'].map { |item| [item[:id], item] }.to_h
      space_hash                     = spaces['items'].map { |item| [item[:id], item] }.to_h

      service_binding_annotations_hash = {}
      service_binding_annotations['items'].each do |service_binding_annotation|
        return result unless @running

        Thread.pass

        service_binding_guid = service_binding_annotation[:resource_guid]
        service_binding_annotations_array = service_binding_annotations_hash[service_binding_guid]
        if service_binding_annotations_array.nil?
          service_binding_annotations_array = []
          service_binding_annotations_hash[service_binding_guid] = service_binding_annotations_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            annotation:         service_binding_annotation,
            created_at_rfc3339: service_binding_annotation[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: service_binding_annotation[:updated_at].nil? ? nil : service_binding_annotation[:updated_at].to_datetime.rfc3339
          }

        service_binding_annotations_array.push(wrapper)
      end

      service_binding_labels_hash = {}
      service_binding_labels['items'].each do |service_binding_label|
        return result unless @running

        Thread.pass

        service_binding_guid = service_binding_label[:resource_guid]
        service_binding_labels_array = service_binding_labels_hash[service_binding_guid]
        if service_binding_labels_array.nil?
          service_binding_labels_array = []
          service_binding_labels_hash[service_binding_guid] = service_binding_labels_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            label:              service_binding_label,
            created_at_rfc3339: service_binding_label[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: service_binding_label[:updated_at].nil? ? nil : service_binding_label[:updated_at].to_datetime.rfc3339
          }

        service_binding_labels_array.push(wrapper)
      end

      event_counters = {}
      events['items'].each do |event|
        return result unless @running

        Thread.pass

        next unless event[:actee_type] == 'service_binding'

        actee = event[:actee]
        event_counters[actee] = 0 if event_counters[actee].nil?
        event_counters[actee] += 1
      end

      items = []
      hash  = {}

      service_bindings['items'].each do |service_binding|
        return result unless @running

        Thread.pass

        guid                      = service_binding[:guid]
        id                        = service_binding[:id]
        application               = application_hash[service_binding[:app_guid]]
        service_binding_operation = service_binding_operation_hash[id]
        service_instance          = service_instance_hash[service_binding[:service_instance_guid]]
        service_plan_id           = service_instance.nil? ? nil : service_instance[:service_plan_id]
        service_plan              = service_plan_id.nil? ? nil : service_plan_hash[service_plan_id]
        service                   = service_plan.nil? ? nil : service_hash[service_plan[:service_id]]
        service_broker            = service.nil? || service[:service_broker_id].nil? ? nil : service_broker_hash[service[:service_broker_id]]
        space                     = service_instance.nil? ? nil : space_hash[service_instance[:space_id]]
        organization              = space.nil? ? nil : organization_hash[space[:organization_id]]

        event_counter                    = event_counters[guid]
        service_binding_annotation_array = service_binding_annotations_hash[guid] || []
        service_binding_label_array      = service_binding_labels_hash[guid] || []

        row = []

        row.push(guid)
        row.push(service_binding[:name])
        row.push(guid)
        row.push(service_binding[:created_at].to_datetime.rfc3339)

        if service_binding[:updated_at]
          row.push(service_binding[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        row.push(!service_binding[:syslog_drain_url].nil? && service_binding[:syslog_drain_url].length.positive?)

        if event_counter
          row.push(event_counter)
        elsif events_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_binding_operation
          row.push(service_binding_operation[:type])
          row.push(service_binding_operation[:state])
          row.push(service_binding_operation[:created_at].to_datetime.rfc3339)

          if service_binding_operation[:updated_at]
            row.push(service_binding_operation[:updated_at].to_datetime.rfc3339)
          else
            row.push(nil)
          end
        else
          row.push(nil, nil, nil, nil)
        end

        if application
          row.push(application[:name])
          row.push(application[:guid])
        else
          row.push(nil, nil)
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
            'annotations'               => service_binding_annotation_array,
            'application'               => application,
            'labels'                    => service_binding_label_array,
            'organization'              => organization,
            'service'                   => service,
            'service_binding'           => service_binding,
            'service_binding_operation' => service_binding_operation,
            'service_broker'            => service_broker,
            'service_instance'          => service_instance,
            'service_plan'              => service_plan,
            'space'                     => space
          }
      end

      result(true, items, hash, (1..35).to_a, (1..35).to_a - [6])
    end
  end
end
