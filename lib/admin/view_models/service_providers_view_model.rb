require 'date'
require_relative 'base_view_model'

module AdminUI
  class ServiceProvidersViewModel < AdminUI::BaseViewModel
    def do_items
      service_providers = @cc.service_providers

      # service_providers have to exist. Other record types are optional
      return result unless service_providers['connected']

      identity_zones = @cc.identity_zones

      identity_zone_hash = identity_zones['items'].map { |item| [item[:id], item] }.to_h

      items = []
      hash  = {}

      service_providers['items'].each do |service_provider|
        return result unless @running

        Thread.pass

        id            = service_provider[:id]
        identity_zone = identity_zone_hash[service_provider[:identity_zone_id]]

        row = []

        row.push(id)

        if identity_zone
          row.push(identity_zone[:name])
        else
          row.push(nil)
        end

        row.push(service_provider[:name])
        row.push(id)
        row.push(service_provider[:entity_id])
        row.push(service_provider[:created].to_datetime.rfc3339)

        if service_provider[:lastmodified]
          row.push(service_provider[:lastmodified].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        row.push(service_provider[:active])
        row.push(service_provider[:version])

        items.push(row)

        hash[id] =
          {
            'identity_zone'    => identity_zone,
            'service_provider' => service_provider
          }
      end

      result(true, items, hash, (1..8).to_a, (1..7).to_a)
    end
  end
end
