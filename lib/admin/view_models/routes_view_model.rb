require 'date'
require_relative 'base_view_model'

module AdminUI
  class RoutesViewModel < AdminUI::BaseViewModel
    def do_items
      routes = @cc.routes

      # routes have to exist. Other record types are optional
      return result unless routes['connected']

      domains           = @cc.domains
      events            = @cc.events
      organizations     = @cc.organizations
      route_annotations = @cc.route_annotations
      route_bindings    = @cc.route_bindings
      route_labels      = @cc.route_labels
      route_mappings    = @cc.route_mappings
      spaces            = @cc.spaces

      events_connected         = events['connected']
      route_bindings_connected = route_bindings['connected']
      route_mappings_connected = route_mappings['connected']

      domain_hash       = domains['items'].map { |item| [item[:id], item] }.to_h
      organization_hash = organizations['items'].map { |item| [item[:id], item] }.to_h
      space_hash        = spaces['items'].map { |item| [item[:id], item] }.to_h

      route_annotations_hash = {}
      route_annotations['items'].each do |route_annotation|
        return result unless @running

        Thread.pass

        route_guid = route_annotation[:resource_guid]
        route_annotations_array = route_annotations_hash[route_guid]
        if route_annotations_array.nil?
          route_annotations_array = []
          route_annotations_hash[route_guid] = route_annotations_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            annotation:         route_annotation,
            created_at_rfc3339: route_annotation[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: route_annotation[:updated_at].nil? ? nil : route_annotation[:updated_at].to_datetime.rfc3339
          }

        route_annotations_array.push(wrapper)
      end

      route_labels_hash = {}
      route_labels['items'].each do |route_label|
        return result unless @running

        Thread.pass

        route_guid = route_label[:resource_guid]
        route_labels_array = route_labels_hash[route_guid]
        if route_labels_array.nil?
          route_labels_array = []
          route_labels_hash[route_guid] = route_labels_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            label:              route_label,
            created_at_rfc3339: route_label[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: route_label[:updated_at].nil? ? nil : route_label[:updated_at].to_datetime.rfc3339
          }

        route_labels_array.push(wrapper)
      end

      event_counters = {}
      events['items'].each do |event|
        return result unless @running

        Thread.pass

        next unless event[:actee_type] == 'route'

        actee = event[:actee]
        event_counters[actee] = 0 if event_counters[actee].nil?
        event_counters[actee] += 1
      end

      app_counters = {}
      route_mappings['items'].each do |route_mapping|
        return result unless @running

        Thread.pass

        route_guid = route_mapping[:route_guid]
        app_counters[route_guid] = 0 if app_counters[route_guid].nil?
        app_counters[route_guid] += 1
      end

      binding_counters = {}
      route_bindings['items'].each do |route_binding|
        return result unless @running

        Thread.pass

        route_id = route_binding[:route_id]
        binding_counters[route_id] = 0 if binding_counters[route_id].nil?
        binding_counters[route_id] += 1
      end

      items = []
      hash  = {}

      routes['items'].each do |route|
        return result unless @running

        Thread.pass

        guid         = route[:guid]
        port         = route[:port]
        domain       = domain_hash[route[:domain_id]]
        space        = space_hash[route[:space_id]]
        organization = space.nil? ? nil : organization_hash[space[:organization_id]]

        app_counter            = app_counters[guid]
        binding_counter        = binding_counters[route[:id]]
        event_counter          = event_counters[guid]
        route_annotation_array = route_annotations_hash[guid] || []
        route_label_array      = route_labels_hash[guid] || []

        row = []

        row.push(guid)

        if domain
          fqdn = domain[:name]

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

        row.push(route[:host])

        if domain
          row.push(domain[:name])
        else
          row.push(nil)
        end

        if port&.positive?
          row.push(port)
        else
          row.push(nil)
        end

        row.push(route[:path])
        row.push(route[:vip_offset])
        row.push(guid)
        row.push(route[:created_at].to_datetime.rfc3339)

        if route[:updated_at]
          row.push(route[:updated_at].to_datetime.rfc3339)
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

        if app_counter
          row.push(app_counter)
        elsif route_mappings_connected
          row.push(0)
        else
          row.push(nil)
        end

        if binding_counter
          row.push(binding_counter)
        elsif route_bindings_connected
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
            'annotations'  => route_annotation_array,
            'domain'       => domain,
            'labels'       => route_label_array,
            'organization' => organization,
            'route'        => route,
            'space'        => space
          }
      end

      result(true, items, hash, (1..13).to_a, [1, 2, 3, 5, 7, 8, 9, 13])
    end
  end
end
