require 'date'
require 'thread'
require_relative 'base_view_model'

module AdminUI
  class IdentityProvidersViewModel < AdminUI::BaseViewModel
    def do_items
      identity_providers = @cc.identity_providers

      # identity_providers have to exist.  Other record types are optional
      return result unless identity_providers['connected']

      clients                   = @cc.clients
      client_identity_providers = @cc.client_identity_providers
      identity_zones            = @cc.identity_zones

      clients_connected                   = clients['connected']
      client_identity_providers_connected = client_identity_providers['connected']

      client_hash        = Hash[clients['items'].map { |item| [item[:client_id], item] }]
      identity_zone_hash = Hash[identity_zones['items'].map { |item| [item[:id], item] }]

      client_counters = {}
      if clients_connected && client_identity_providers_connected
        client_identity_providers['items'].each do |client_identity_provider|
          # Check client exists
          client_id = client_identity_provider[:client_id]
          client    = client_hash[client_id]
          next if client.nil?

          identity_provider_id = client_identity_provider[:identity_provider_id]
          client_counters[identity_provider_id] = 0 if client_counters[identity_provider_id].nil?
          client_counters[identity_provider_id] += 1
        end
      end

      items = []
      hash  = {}

      identity_providers['items'].each do |identity_provider|
        return result unless @running
        Thread.pass

        id             = identity_provider[:id]
        client_counter = client_counters[id]
        identity_zone  = identity_zone_hash[identity_provider[:identity_zone_id]]

        row = []

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

        if client_counter
          row.push(client_counter)
        elsif clients_connected && client_identity_providers_connected
          row.push(0)
        else
          row.push(nil)
        end

        items.push(row)

        hash[id] =
          {
            'identity_provider' => identity_provider,
            'identity_zone'     => identity_zone
          }
      end

      result(true, items, hash, (0..9).to_a, (0..7).to_a)
    end
  end
end
