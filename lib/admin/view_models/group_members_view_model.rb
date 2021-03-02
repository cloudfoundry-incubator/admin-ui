require 'date'
require_relative 'base_view_model'

module AdminUI
  class GroupMembersViewModel < AdminUI::BaseViewModel
    def do_items
      groups           = @cc.groups
      group_membership = @cc.group_membership
      users            = @cc.users_uaa

      # groups, group_membership and users_uaa have to exist. Other record types are optional
      return result unless groups['connected'] &&
                           group_membership['connected'] &&
                           users['connected']

      identity_zones = @cc.identity_zones

      group_hash         = groups['items'].map { |item| [item[:id], item] }.to_h
      identity_zone_hash = identity_zones['items'].map { |item| [item[:id], item] }.to_h
      user_hash          = users['items'].map { |item| [item[:id], item] }.to_h

      items = []
      hash  = {}

      group_membership['items'].each do |group_member|
        return result unless @running

        Thread.pass

        group_id  = group_member[:group_id]
        member_id = group_member[:member_id]

        group = group_hash[group_id]
        user  = user_hash[member_id]

        next if group.nil? || user.nil?

        identity_zone = identity_zone_hash[group[:identity_zone_id]]

        row = []

        key = "#{group_id}/#{member_id}"

        row.push(key)

        if identity_zone
          row.push(identity_zone[:name])
        else
          row.push(nil)
        end

        row.push(group[:displayname])
        row.push(group_id)
        row.push(user[:username])
        row.push(member_id)
        row.push(group_member[:added].to_datetime.rfc3339)

        items.push(row)

        hash[key] =
          {
            'group'            => group,
            'group_membership' => group_member,
            'identity_zone'    => identity_zone,
            'user_uaa'         => user
          }
      end

      result(true, items, hash, (1..6).to_a, (1..6).to_a)
    end
  end
end
