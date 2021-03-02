require 'yajl'
require_relative 'base_view_model'

module AdminUI
  class MFAProvidersViewModel < AdminUI::BaseViewModel
    def do_items
      mfa_providers = @cc.mfa_providers

      # mfa_providers have to exist
      return result unless mfa_providers['connected']

      identity_zones = @cc.identity_zones

      identity_zone_hash = identity_zones['items'].map { |item| [item[:id], item] }.to_h

      items = []
      hash  = {}

      mfa_providers['items'].each do |mfa_provider|
        return result unless @running

        Thread.pass

        mfa_provider_id = mfa_provider[:id]

        identity_zone = identity_zone_hash[mfa_provider[:identity_zone_id]]

        row = []

        row.push(mfa_provider_id)

        if identity_zone
          row.push(identity_zone[:name])
        else
          row.push(nil)
        end

        row.push(mfa_provider[:type])
        row.push(mfa_provider[:name])
        row.push(mfa_provider_id)
        row.push(mfa_provider[:created].to_datetime.rfc3339)

        if mfa_provider[:lastmodified]
          row.push(mfa_provider[:lastmodified].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        config = mfa_provider[:config]
        if config
          begin
            json      = Yajl::Parser.parse(config)
            issuer    = json['issuer']
            algorithm = json['algorithm']
            digits    = json['digits']
            duration  = json['duration']

            row.push(issuer)
            row.push(algorithm)
            row.push(digits)
            row.push(duration)
          rescue
            row.push(nil, nil, nil, nil)
          end
        else
          row.push(nil, nil, nil, nil)
        end

        items.push(row)

        hash[mfa_provider_id] =
          {
            'identity_zone' => identity_zone,
            'mfa_provider'  => mfa_provider
          }
      end

      result(true, items, hash, (1..10).to_a, [1..8].to_a)
    end
  end
end
