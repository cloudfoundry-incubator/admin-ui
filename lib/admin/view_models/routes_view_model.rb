require 'date'
require 'thread'
require_relative 'base_view_model'

module AdminUI
  class RoutesViewModel < AdminUI::BaseViewModel
    def do_items
      routes = @cc.routes

      # routes have to exist.  Other record types are optional
      return result unless routes['connected']

      apps_routes   = @cc.apps_routes
      domains       = @cc.domains
      events        = @cc.events
      organizations = @cc.organizations
      spaces        = @cc.spaces

      apps_routes_connected = apps_routes['connected']
      events_connected      = events['connected']

      domain_hash       = Hash[domains['items'].map { |item| [item[:id], item] }]
      organization_hash = Hash[organizations['items'].map { |item| [item[:id], item] }]
      space_hash        = Hash[spaces['items'].map { |item| [item[:id], item] }]

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
      apps_routes['items'].each do |app_route|
        return result unless @running
        Thread.pass

        route_id = app_route[:route_id]
        app_counters[route_id] = 0 if app_counters[route_id].nil?
        app_counters[route_id] += 1
      end

      items = []
      hash  = {}

      routes['items'].each do |route|
        return result unless @running
        Thread.pass

        guid         = route[:guid]
        domain       = domain_hash[route[:domain_id]]
        space        = space_hash[route[:space_id]]
        organization = space.nil? ? nil : organization_hash[space[:organization_id]]

        app_counter   = app_counters[route[:id]]
        event_counter = event_counters[guid]

        row = []

        row.push(guid)
        row.push(route[:host])
        row.push(route[:path])
        row.push(guid)

        if domain
          row.push(domain[:name])
        else
          row.push(nil)
        end

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
        elsif apps_routes_connected
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
            'domain'       => domain,
            'organization' => organization,
            'route'        => route,
            'space'        => space
          }
      end

      result(true, items, hash, (1..9).to_a, (1..6).to_a << 9)
    end
  end
end
