require 'date'
require_relative 'base_view_model'

module AdminUI
  class RouteMappingsViewModel < AdminUI::BaseViewModel
    def do_items
      applications   = @cc.applications
      domains        = @cc.domains
      route_mappings = @cc.route_mappings
      routes         = @cc.routes

      # applications, domains, route_mappings and routes have to exist. Other record types are optional
      return result unless applications['connected'] &&
                           domains['connected'] &&
                           route_mappings['connected'] &&
                           routes['connected']

      organizations = @cc.organizations
      spaces        = @cc.spaces

      application_hash  = applications['items'].map { |item| [item[:guid], item] }.to_h
      domain_hash       = domains['items'].map { |item| [item[:id], item] }.to_h
      organization_hash = organizations['items'].map { |item| [item[:id], item] }.to_h
      route_hash        = routes['items'].map { |item| [item[:guid], item] }.to_h
      space_hash        = spaces['items'].map { |item| [item[:guid], item] }.to_h

      items = []
      hash  = {}

      route_mappings['items'].each do |route_mapping|
        return result unless @running

        Thread.pass

        guid        = route_mapping[:guid]
        app_guid    = route_mapping[:app_guid]
        route_guid  = route_mapping[:route_guid]
        application = application_hash[app_guid]
        route       = route_hash[route_guid]

        domain       = route.nil? ? nil : domain_hash[route[:domain_id]]
        space        = application.nil? ? nil : space_hash[application[:space_guid]]
        organization = space.nil? ? nil : organization_hash[space[:organization_id]]

        row = []

        key = "#{guid}/#{route_guid}"

        row.push(key)
        row.push(guid)

        row.push(route_mapping[:created_at].to_datetime.rfc3339)

        if route_mapping[:updated_at]
          row.push(route_mapping[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        row.push(route_mapping[:weight])

        if application
          row.push(application[:name])
          row.push(app_guid)
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
          row.push(route_guid)
        else
          row.push(nil, nil)
        end

        if organization && space
          row.push("#{organization[:name]}/#{space[:name]}")
        else
          row.push(nil)
        end

        items.push(row)

        hash[key] =
          {
            'application'   => application,
            'domain'        => domain,
            'organization'  => organization,
            'route'         => route,
            'route_mapping' => route_mapping,
            'space'         => space
          }
      end

      result(true, items, hash, (1..9).to_a, [1, 2, 3, 5, 6, 7, 8, 9])
    end
  end
end
