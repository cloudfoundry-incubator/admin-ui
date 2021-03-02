require 'date'
require_relative 'base_view_model'

module AdminUI
  class IdentityProvidersViewModel < AdminUI::BaseViewModel
    def do_items
      identity_providers = @cc.identity_providers

      # identity_providers have to exist. Other record types are optional
      return result unless identity_providers['connected']

      identity_zones = @cc.identity_zones

      identity_zone_hash = identity_zones['items'].map { |item| [item[:id], item] }.to_h

      items = []
      hash  = {}

      identity_providers['items'].each do |identity_provider|
        return result unless @running

        Thread.pass

        id            = identity_provider[:id]
        identity_zone = identity_zone_hash[identity_provider[:identity_zone_id]]

        row = []

        row.push(id)

        if identity_zone
          row.push(identity_zone[:name])
        else
          row.push(nil)
        end

        row.push(identity_provider[:name])
        row.push(id)
        row.push(identity_provider[:created].to_datetime.rfc3339)

        if identity_provider[:lastmodified]
          row.push(identity_provider[:lastmodified].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        row.push(identity_provider[:origin_key])
        row.push(identity_provider[:type])
        row.push(identity_provider[:active])
        row.push(identity_provider[:version])

        items.push(row)

        hash[id] =
          {
            'identity_provider' => identity_provider,
            'identity_zone'     => identity_zone
          }
      end

      result(true, items, hash, (1..9).to_a, (1..8).to_a)
    end
  end
end
