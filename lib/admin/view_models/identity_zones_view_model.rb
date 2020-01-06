require 'cgi'
require 'date'
require_relative 'base_view_model'

module AdminUI
  class IdentityZonesViewModel < AdminUI::BaseViewModel
    def do_items
      identity_zones = @cc.identity_zones

      # identity_zones have to exist. Other record types are optional
      return result unless identity_zones['connected']

      approvals          = @cc.approvals
      clients            = @cc.clients
      group_membership   = @cc.group_membership
      groups             = @cc.groups
      identity_providers = @cc.identity_providers
      mfa_providers      = @cc.mfa_providers
      service_providers  = @cc.service_providers
      users              = @cc.users_uaa

      approvals_connected          = approvals['connected']
      clients_connected            = clients['connected']
      group_membership_connected   = group_membership['connected']
      groups_connected             = groups['connected']
      identity_providers_connected = identity_providers['connected']
      mfa_providers_connected      = mfa_providers['connected']
      service_providers_connected  = service_providers['connected']
      users_connected              = users['connected']

      approval_counters = {}
      approvals['items'].each do |approval|
        return result unless @running

        Thread.pass

        identity_zone_id = approval[:identity_zone_id]
        next if identity_zone_id.nil?

        approval_counters[identity_zone_id] = 0 if approval_counters[identity_zone_id].nil?
        approval_counters[identity_zone_id] += 1
      end

      client_counters = {}
      clients['items'].each do |client|
        return result unless @running

        Thread.pass

        identity_zone_id = client[:identity_zone_id]
        next if identity_zone_id.nil?

        client_counters[identity_zone_id] = 0 if client_counters[identity_zone_id].nil?
        client_counters[identity_zone_id] += 1
      end

      group_counters = {}
      groups['items'].each do |group|
        return result unless @running

        Thread.pass

        identity_zone_id = group[:identity_zone_id]
        next if identity_zone_id.nil?

        group_counters[identity_zone_id] = 0 if group_counters[identity_zone_id].nil?
        group_counters[identity_zone_id] += 1
      end

      group_membership_counters = {}
      group_membership['items'].each do |group_membership_entry|
        return result unless @running

        Thread.pass

        identity_zone_id = group_membership_entry[:identity_zone_id]
        next if identity_zone_id.nil?

        group_membership_counters[identity_zone_id] = 0 if group_membership_counters[identity_zone_id].nil?
        group_membership_counters[identity_zone_id] += 1
      end

      identity_provider_counters = {}
      identity_providers['items'].each do |identity_provider|
        return result unless @running

        Thread.pass

        identity_zone_id = identity_provider[:identity_zone_id]
        next if identity_zone_id.nil?

        identity_provider_counters[identity_zone_id] = 0 if identity_provider_counters[identity_zone_id].nil?
        identity_provider_counters[identity_zone_id] += 1
      end

      mfa_provider_counters = {}
      mfa_providers['items'].each do |mfa_provider|
        return result unless @running

        Thread.pass

        identity_zone_id = mfa_provider[:identity_zone_id]
        next if identity_zone_id.nil?

        mfa_provider_counters[identity_zone_id] = 0 if mfa_provider_counters[identity_zone_id].nil?
        mfa_provider_counters[identity_zone_id] += 1
      end

      service_provider_counters = {}
      service_providers['items'].each do |service_provider|
        return result unless @running

        Thread.pass

        identity_zone_id = service_provider[:identity_zone_id]
        next if identity_zone_id.nil?

        service_provider_counters[identity_zone_id] = 0 if service_provider_counters[identity_zone_id].nil?
        service_provider_counters[identity_zone_id] += 1
      end

      user_counters = {}
      users['items'].each do |user|
        return result unless @running

        Thread.pass

        identity_zone_id = user[:identity_zone_id]
        next if identity_zone_id.nil?

        user_counters[identity_zone_id] = 0 if user_counters[identity_zone_id].nil?
        user_counters[identity_zone_id] += 1
      end

      items = []
      hash  = {}

      identity_zones['items'].each do |identity_zone|
        return result unless @running

        Thread.pass

        id = identity_zone[:id]

        approval_counter          = approval_counters[id]
        client_counter            = client_counters[id]
        group_counter             = group_counters[id]
        group_membership_counter  = group_membership_counters[id]
        identity_provider_counter = identity_provider_counters[id]
        mfa_provider_counter      = mfa_provider_counters[id]
        service_provider_counter  = service_provider_counters[id]
        user_counter              = user_counters[id]

        row = []

        row.push(CGI.escape(id))
        row.push(identity_zone[:name])
        row.push(id)
        row.push(identity_zone[:created].to_datetime.rfc3339)

        if identity_zone[:lastmodified]
          row.push(identity_zone[:lastmodified].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        row.push(identity_zone[:subdomain])
        row.push(identity_zone[:active])
        row.push(identity_zone[:version])

        if identity_provider_counter
          row.push(identity_provider_counter)
        elsif identity_providers_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_provider_counter
          row.push(service_provider_counter)
        elsif service_providers_connected
          row.push(0)
        else
          row.push(nil)
        end

        if mfa_provider_counter
          row.push(mfa_provider_counter)
        elsif mfa_providers_connected
          row.push(0)
        else
          row.push(nil)
        end

        if client_counter
          row.push(client_counter)
        elsif clients_connected
          row.push(0)
        else
          row.push(nil)
        end

        if user_counter
          row.push(user_counter)
        elsif users_connected
          row.push(0)
        else
          row.push(nil)
        end

        if group_counter
          row.push(group_counter)
        elsif groups_connected
          row.push(0)
        else
          row.push(nil)
        end

        if group_membership_counter
          row.push(group_membership_counter)
        elsif group_membership_connected
          row.push(0)
        else
          row.push(nil)
        end

        if approval_counter
          row.push(approval_counter)
        elsif approvals_connected
          row.push(0)
        else
          row.push(nil)
        end

        row.push(identity_zone[:description])

        items.push(row)

        hash[id] = identity_zone
      end

      result(true, items, hash, (1..16).to_a, (1..6).to_a << 16)
    end
  end
end
