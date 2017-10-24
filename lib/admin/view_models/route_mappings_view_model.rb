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

      application_hash  = Hash[applications['items'].map { |item| [item[:guid], item] }]
      domain_hash       = Hash[domains['items'].map { |item| [item[:id], item] }]
      organization_hash = Hash[organizations['items'].map { |item| [item[:id], item] }]
      route_hash        = Hash[routes['items'].map { |item| [item[:guid], item] }]
      space_hash        = Hash[spaces['items'].map { |item| [item[:guid], item] }]

      items = []
      hash  = {}

      route_mappings['items'].each do |route_mapping|
        return result unless @running
        Thread.pass

        guid        = route_mapping[:guid]
        application = application_hash[route_mapping[:app_guid]]
        route       = route_hash[route_mapping[:route_guid]]

        domain       = route.nil? ? nil : domain_hash[route[:domain_id]]
        space        = application.nil? ? nil : space_hash[application[:space_guid]]
        organization = space.nil? ? nil : organization_hash[space[:organization_id]]

        row = []

        row.push(guid)
        row.push(guid)

        row.push(route_mapping[:created_at].to_datetime.rfc3339)

        if route_mapping[:updated_at]
          row.push(route_mapping[:updated_at].to_datetime.rfc3339)
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
            'application'   => application,
            'domain'        => domain,
            'organization'  => organization,
            'route'         => route,
            'route_mapping' => route_mapping,
            'space'         => space
          }
      end

      result(true, items, hash, (1..8).to_a, (1..8))
    end
  end
end
