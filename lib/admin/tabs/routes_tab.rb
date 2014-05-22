require_relative 'base'
require 'date'

module AdminUI
  class RoutesTab < AdminUI::Base
    def initialize(logger, cc)
      super(logger)

      @cc = cc
    end

    def do_items
      routes = @cc.routes

      # routes have to exist.  Other record types are optional
      return result unless routes['connected']

      organizations = @cc.organizations
      spaces        = @cc.spaces

      organization_hash = Hash[*organizations['items'].map { |item| [item['guid'], item] }.flatten]
      space_hash        = Hash[*spaces['items'].map { |item| [item['guid'], item] }.flatten]

      items = []

      routes['items'].each do |route|
        space        = space_hash[route['space_guid']]
        organization = space.nil? ? nil : organization_hash[space['organization_guid']]

        row = []

        row.push(route['guid'])
        row.push(route['host'])
        row.push(route['domain']['entity']['name'])
        row.push(DateTime.parse(route['created_at']).rfc3339)

        if route['updated_at']
          row.push(DateTime.parse(route['updated_at']).rfc3339)
        else
          row.push(nil)
        end

        if organization && space
          row.push("#{ organization['name'] }/#{ space['name'] }")
        else
          row.push(nil)
        end

        apps = []
        route['apps'].each do |app|
          apps.push(app['entity']['name'])
        end
        row.push(apps)

        row.push('organization' => organization,
                 'route'        => route,
                 'space'        => space)

        items.push(row)
      end

      result(items, (1..6).to_a, (1..6).to_a)
    end
  end
end
