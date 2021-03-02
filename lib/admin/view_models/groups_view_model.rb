require 'date'
require_relative 'base_view_model'

module AdminUI
  class GroupsViewModel < AdminUI::BaseViewModel
    def do_items
      groups = @cc.groups

      # groups has to exist. Other record types are optional
      return result unless groups['connected']

      group_membership = @cc.group_membership
      identity_zones   = @cc.identity_zones

      group_membership_connected = group_membership['connected']

      identity_zone_hash = identity_zones['items'].map { |item| [item[:id], item] }.to_h

      group_membership_counters = {}
      group_membership['items'].each do |group_membership_entry|
        return result unless @running

        Thread.pass

        group_id = group_membership_entry[:group_id]
        group_membership_counters[group_id] = 0 if group_membership_counters[group_id].nil?
        group_membership_counters[group_id] += 1
      end

      items = []
      hash  = {}

      groups['items'].each do |group|
        return result unless @running

        Thread.pass

        guid = group[:id]

        group_membership_counter = group_membership_counters[guid]
        identity_zone = identity_zone_hash[group[:identity_zone_id]]

        row = []

        row.push(guid)

        if identity_zone
          row.push(identity_zone[:name])
        else
          row.push(nil)
        end

        row.push(group[:displayname])
        row.push(guid)
        row.push(group[:created].to_datetime.rfc3339)

        if group[:lastmodified]
          row.push(group[:lastmodified].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        row.push(group[:version])

        if group_membership_counter
          row.push(group_membership_counter)
        elsif group_membership_connected
          row.push(0)
        else
          row.push(nil)
        end

        items.push(row)

        hash[guid] =
          {
            'group'         => group,
            'identity_zone' => identity_zone
          }
      end

      result(true, items, hash, (1..7).to_a, (1..5).to_a)
    end
  end
end
