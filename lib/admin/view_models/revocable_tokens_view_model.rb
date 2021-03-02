require 'date'
require 'yajl'
require_relative 'base_view_model'

module AdminUI
  class RevocableTokensViewModel < AdminUI::BaseViewModel
    def do_items
      revocable_tokens = @cc.revocable_tokens

      # revocable_tokens have to exist
      return result unless revocable_tokens['connected']

      clients        = @cc.clients
      identity_zones = @cc.identity_zones
      users          = @cc.users_uaa

      client_hash        = clients['items'].map { |item| [item[:client_id], item] }.to_h
      identity_zone_hash = identity_zones['items'].map { |item| [item[:id], item] }.to_h
      user_hash          = users['items'].map { |item| [item[:id], item] }.to_h

      items = []
      hash  = {}

      revocable_tokens['items'].each do |revocable_token|
        return result unless @running

        Thread.pass

        token_id  = revocable_token[:token_id]
        client_id = revocable_token[:client_id]
        user_id   = revocable_token[:user_id]

        client        = client_hash[client_id]
        identity_zone = identity_zone_hash[revocable_token[:identity_zone_id]]
        user          = user_hash[user_id]

        row = []

        row.push(token_id)

        if identity_zone
          row.push(identity_zone[:name])
        else
          row.push(nil)
        end

        row.push(token_id)
        row.push(Time.at(revocable_token[:issued_at] / 1000.0).to_datetime.rfc3339)
        row.push(Time.at(revocable_token[:expires_at] / 1000.0).to_datetime.rfc3339)

        if revocable_token[:format]
          row.push(revocable_token[:format])
        else
          row.push(nil)
        end

        row.push(revocable_token[:response_type])

        if revocable_token[:scope]
          row.push(revocable_token[:scope][1...-1].split(', ').sort)
        else
          row.push(nil)
        end

        row.push(client_id)

        if user
          row.push(user[:username])
        else
          row.push(nil)
        end

        row.push(user_id)

        items.push(row)

        hash[token_id] =
          {
            'client'          => client,
            'identity_zone'   => identity_zone,
            'revocable_token' => revocable_token,
            'user_uaa'        => user
          }
      end

      result(true, items, hash, (1..10).to_a, (1..10).to_a)
    end
  end
end
