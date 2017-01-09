require_relative 'base_view_model'
require 'date'
require 'thread'

module AdminUI
  class GroupMembersViewModel < AdminUI::BaseViewModel
    def do_items
      groups           = @cc.groups
      group_membership = @cc.group_membership
      users            = @cc.users_uaa

      # groups, group_membership and users_uaa have to exist.  Other record types are optional
      return result unless groups['connected'] &&
                           group_membership['connected'] &&
                           users['connected']

      group_hash = Hash[groups['items'].map { |item| [item[:id], item] }]
      user_hash  = Hash[users['items'].map { |item| [item[:id], item] }]

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

        row = []

        key = "#{group_id}/#{member_id}"

        row.push(key)
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
            'user_uaa'         => user
          }
      end

      result(true, items, hash, (1..5).to_a, (1..5).to_a)
    end
  end
end
