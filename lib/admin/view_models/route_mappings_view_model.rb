require 'date'
require 'thread'
require_relative 'base_view_model'

module AdminUI
  class RouteMappingsViewModel < AdminUI::BaseViewModel
    def do_items
      applications = @cc.applications
      apps_routes  = @cc.apps_routes
      domains      = @cc.domains
      routes       = @cc.routes

      # applications, apps_routes, domains and routes have to exist.  Other record types are optional
      return result unless applications['connected'] &&
                           apps_routes['connected'] &&
                           domains['connected'] &&
                           routes['connected']

      organizations = @cc.organizations
      spaces        = @cc.spaces

      application_hash  = Hash[applications['items'].map { |item| [item[:id], item] }]
      domain_hash       = Hash[domains['items'].map { |item| [item[:id], item] }]
      organization_hash = Hash[organizations['items'].map { |item| [item[:id], item] }]
      route_hash        = Hash[routes['items'].map { |item| [item[:id], item] }]
      space_hash        = Hash[spaces['items'].map { |item| [item[:id], item] }]

      items = []
      hash  = {}

      apps_routes['items'].each do |app_route|
        return result unless @running
        Thread.pass

        guid         = app_route[:guid]
        application  = application_hash[app_route[:app_id]]
        route        = route_hash[app_route[:route_id]]
        domain       = route.nil? ? nil : domain_hash[route[:domain_id]]
        space        = application.nil? ? nil : space_hash[application[:space_id]]
        organization = space.nil? ? nil : organization_hash[space[:organization_id]]

        row = []

        row.push(guid)
        row.push(guid)
        row.push(app_route[:created_at].to_datetime.rfc3339)

        if app_route[:updated_at]
          row.push(app_route[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        if application
          row.push(application[:name])
          row.push(application[:guid])
        else
          row.push(nil, nil)
        end

        if route && domain
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
          row.push(route[:guid])
        else
          row.push(nil, nil)
        end

        if organization && space
          row.push("#{organization[:name]}/#{space[:name]}")
        else
          row.push(nil)
        end

        items.push(row)

        hash[guid] =
          {
            'application'  => application,
            'app_route'    => app_route,
            'domain'       => domain,
            'organization' => organization,
            'route'        => route,
            'space'        => space
          }
      end

      result(true, items, hash, (1..8).to_a, (1..8))
    end
  end
end
