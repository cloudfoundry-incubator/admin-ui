require 'date'
require_relative 'base_view_model'

module AdminUI
  class RouteBindingsViewModel < AdminUI::BaseViewModel
    def do_items
      routes            = @cc.routes
      route_bindings    = @cc.route_bindings
      service_instances = @cc.service_instances

      # routes, route_bindings and service_instances have to exist. Other record types are optional
      return result unless routes['connected'] &&
                           route_bindings['connected'] &&
                           service_instances['connected']

      domains                   = @cc.domains
      organizations             = @cc.organizations
      route_binding_annotations = @cc.route_binding_annotations
      route_binding_labels      = @cc.route_binding_labels
      route_binding_operations  = @cc.route_binding_operations
      service_brokers           = @cc.service_brokers
      service_plans             = @cc.service_plans
      services                  = @cc.services
      spaces                    = @cc.spaces

      domain_hash                  = domains['items'].map { |item| [item[:id], item] }.to_h
      organization_hash            = organizations['items'].map { |item| [item[:id], item] }.to_h
      route_binding_operation_hash = route_binding_operations['items'].map { |item| [item[:route_binding_id], item] }.to_h
      route_hash                   = routes['items'].map { |item| [item[:id], item] }.to_h
      service_broker_hash          = service_brokers['items'].map { |item| [item[:id], item] }.to_h
      service_instance_hash        = service_instances['items'].map { |item| [item[:id], item] }.to_h
      service_plan_hash            = service_plans['items'].map { |item| [item[:id], item] }.to_h
      service_hash                 = services['items'].map { |item| [item[:id], item] }.to_h
      space_hash                   = spaces['items'].map { |item| [item[:id], item] }.to_h

      items = []
      hash  = {}

      route_binding_annotations_hash = {}
      route_binding_annotations['items'].each do |route_binding_annotation|
        return result unless @running

        Thread.pass

        route_binding_guid = route_binding_annotation[:resource_guid]
        route_binding_annotations_array = route_binding_annotations_hash[route_binding_guid]
        if route_binding_annotations_array.nil?
          route_binding_annotations_array = []
          route_binding_annotations_hash[route_binding_guid] = route_binding_annotations_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            annotation:         route_binding_annotation,
            created_at_rfc3339: route_binding_annotation[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: route_binding_annotation[:updated_at].nil? ? nil : route_binding_annotation[:updated_at].to_datetime.rfc3339
          }

        route_binding_annotations_array.push(wrapper)
      end

      route_binding_labels_hash = {}
      route_binding_labels['items'].each do |route_binding_label|
        return result unless @running

        Thread.pass

        route_binding_guid = route_binding_label[:resource_guid]
        route_binding_labels_array = route_binding_labels_hash[route_binding_guid]
        if route_binding_labels_array.nil?
          route_binding_labels_array = []
          route_binding_labels_hash[route_binding_guid] = route_binding_labels_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            label:              route_binding_label,
            created_at_rfc3339: route_binding_label[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: route_binding_label[:updated_at].nil? ? nil : route_binding_label[:updated_at].to_datetime.rfc3339
          }

        route_binding_labels_array.push(wrapper)
      end

      route_bindings['items'].each do |route_binding|
        return result unless @running

        Thread.pass

        route            = route_hash[route_binding[:route_id]]
        service_instance = service_instance_hash[route_binding[:service_instance_id]]

        next if route.nil? || service_instance.nil?

        guid                           = route_binding[:guid]
        id                             = route_binding[:id]
        domain                         = route.nil? ? nil : domain_hash[route[:domain_id]]
        route_binding_annotation_array = route_binding_annotations_hash[guid] || []
        route_binding_label_array      = route_binding_labels_hash[guid] || []
        route_binding_operation        = route_binding_operation_hash[id]
        service_plan_id                = service_instance.nil? ? nil : service_instance[:service_plan_id]
        service_plan                   = service_plan_id.nil? ? nil : service_plan_hash[service_plan_id]
        service                        = service_plan.nil? ? nil : service_hash[service_plan[:service_id]]
        service_broker                 = service.nil? || service[:service_broker_id].nil? ? nil : service_broker_hash[service[:service_broker_id]]
        space                          = service_instance.nil? ? nil : space_hash[service_instance[:space_id]]
        organization                   = space.nil? ? nil : organization_hash[space[:organization_id]]

        is_gateway_service = service_instance[:is_gateway_service].nil? ? true : service_instance[:is_gateway_service]

        row = []

        row.push("#{service_instance[:guid]}/#{route[:guid]}/#{is_gateway_service}")
        row.push(guid)
        row.push(route_binding[:created_at].to_datetime.rfc3339)

        if route_binding[:updated_at]
          row.push(route_binding[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        if route_binding_operation
          row.push(route_binding_operation[:type])
          row.push(route_binding_operation[:state])
          row.push(route_binding_operation[:created_at].to_datetime.rfc3339)

          if route_binding_operation[:updated_at]
            row.push(route_binding_operation[:updated_at].to_datetime.rfc3339)
          else
            row.push(nil)
          end
        else
          row.push(nil, nil, nil, nil)
        end

        if domain
          fqdn = domain[:name]
          port = route[:port]

          if port&.positive? # Older versions will have nil port
            fqdn = "tcp://#{fqdn}:#{port}"
          else
            host = route[:host]
            path = route[:path]

            fqdn = "#{host}.#{fqdn}" unless host.empty?
            fqdn = "#{fqdn}#{path}" if path # Add path check since older versions will have nil path
            fqdn = "http://#{fqdn}"
          end

          row.push(fqdn)
        else
          row.push(nil)
        end

        row.push(route[:guid])

        row.push(service_instance[:name])
        row.push(service_instance[:guid])
        row.push(service_instance[:created_at].to_datetime.rfc3339)

        if service_instance[:updated_at]
          row.push(service_instance[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
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
            'annotations'             => route_binding_annotation_array,
            'labels'                  => route_binding_label_array,
            'domain'                  => domain,
            'organization'            => organization,
            'route'                   => route,
            'route_binding'           => route_binding,
            'route_binding_operation' => route_binding_operation,
            'service'                 => service,
            'service_broker'          => service_broker,
            'service_instance'        => service_instance,
            'service_plan'            => service_plan,
            'space'                   => space
          }
      end

      result(true, items, hash, (1..32).to_a, (1..32).to_a)
    end
  end
end
