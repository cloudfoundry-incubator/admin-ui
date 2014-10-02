require_relative 'base'
require 'date'
require 'thread'

module AdminUI
  class RoutesViewModel < AdminUI::Base
    def initialize(logger, cc)
      super(logger)

      @cc = cc
    end

    def do_items
      routes = @cc.routes

      # routes have to exist.  Other record types are optional
      return result unless routes['connected']

      applications  = @cc.applications
      apps_routes   = @cc.apps_routes
      domains       = @cc.domains
      organizations = @cc.organizations
      spaces        = @cc.spaces

      application_hash  = Hash[applications['items'].map { |item| [item[:id], item] }]
      domain_hash       = Hash[domains['items'].map { |item| [item[:id], item] }]
      organization_hash = Hash[organizations['items'].map { |item| [item[:id], item] }]
      space_hash        = Hash[spaces['items'].map { |item| [item[:id], item] }]

      route_apps = {}

      apps_routes['items'].each do |app_route|
        Thread.pass
        app_id   = app_route[:app_id]
        route_id = app_route[:route_id]
        route_apps_entry = route_apps[route_id]
        if route_apps_entry
          route_apps_entry.push(app_id)
        else
          route_apps[route_id] = [app_id]
        end
      end

      items = []

      routes['items'].each do |route|
        Thread.pass
        domain       = domain_hash[route[:domain_id]]
        space        = space_hash[route[:space_id]]
        organization = space.nil? ? nil : organization_hash[space[:organization_id]]

        row = []

        row.push(route[:guid])
        row.push(route[:host])
        row.push(route[:guid])

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

        if organization && space
          row.push("#{ organization[:name] }/#{ space[:name] }")
        else
          row.push(nil)
        end

        apps = []
        route_apps_entry = route_apps[route[:id]]
        if route_apps_entry
          route_apps_entry.each do |app_id|
            app = application_hash[app_id]
            apps.push(app[:name]) if app
          end
        end
        row.push(apps)

        row.push('domain'       => domain,
                 'organization' => organization,
                 'route'        => route,
                 'space'        => space)

        items.push(row)
      end

      result(items, (1..7).to_a, (1..7).to_a)
    end
  end
end
