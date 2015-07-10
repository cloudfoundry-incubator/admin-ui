require_relative 'base_view_model'
require 'date'
require 'thread'

module AdminUI
  class UsersViewModel < AdminUI::BaseViewModel
    def do_items
      groups                         = @cc.groups
      group_membership               = @cc.group_membership
      organizations_auditors         = @cc.organizations_auditors
      organizations_billing_managers = @cc.organizations_billing_managers
      organizations_managers         = @cc.organizations_managers
      organizations_users            = @cc.organizations_users
      spaces_auditors                = @cc.spaces_auditors
      spaces_managers                = @cc.spaces_developers
      spaces_developers              = @cc.spaces_managers
      users_cc                       = @cc.users_cc
      users_uaa                      = @cc.users_uaa

      # groups, group_membership,
      # organizations_auditors, organizations_billing_managers, organizations_managers, organizations_users,
      # spaces_auditors, spaces_developers, spaces_managers,
      # users_cc and users_uaa have to exist.  Other record types are optional
      return result unless groups['connected'] &&
                           group_membership['connected'] &&
                           organizations_auditors['connected'] &&
                           organizations_billing_managers['connected'] &&
                           organizations_managers['connected'] &&
                           organizations_users['connected'] &&
                           spaces_auditors['connected'] &&
                           spaces_developers['connected'] &&
                           spaces_managers['connected'] &&
                           users_cc['connected'] &&
                           users_uaa['connected']

      events = @cc.events

      events_connected = events['connected']

      group_hash   = Hash[groups['items'].map { |item| [item[:id], item] }]
      user_cc_hash = Hash[users_cc['items'].map { |item| [item[:guid], item] }]

      member_groups = {}
      group_membership['items'].each do |group_membership_entry|
        return result unless @running
        Thread.pass

        group_id = group_membership_entry[:group_id]
        member_id = group_membership_entry[:member_id]
        member_groups_entry = member_groups[member_id]
        if member_groups_entry
          member_groups_entry.push(group_id)
        else
          member_groups[member_id] = [group_id]
        end
      end

      event_counters = {}
      events['items'].each do |event|
        return result unless @running
        Thread.pass

        next unless event[:actor_type] == 'user'
        # A user actor_type is used for a client.  But, the actor_name is nil in this case
        next if event[:actor_name].nil?
        actor = event[:actor]
        event_counters[actor] = 0 if event_counters[actor].nil?
        event_counters[actor] += 1
      end

      users_organizations_auditors         = {}
      users_organizations_billing_managers = {}
      users_organizations_managers         = {}
      users_organizations_users            = {}
      users_spaces_auditors                = {}
      users_spaces_developers              = {}
      users_spaces_managers                = {}

      count_roles(organizations_auditors,         users_organizations_auditors)
      count_roles(organizations_billing_managers, users_organizations_billing_managers)
      count_roles(organizations_managers,         users_organizations_managers)
      count_roles(organizations_users,            users_organizations_users)
      count_roles(spaces_auditors,                users_spaces_auditors)
      count_roles(spaces_developers,              users_spaces_developers)
      count_roles(spaces_managers,                users_spaces_managers)

      items = []
      hash  = {}

      users_uaa['items'].each do |user_uaa|
        return result unless @running
        Thread.pass

        guid = user_uaa[:id]

        event_counter = event_counters[guid]

        row = []

        row.push(user_uaa[:username])
        row.push(guid)
        row.push(user_uaa[:created].to_datetime.rfc3339)

        if user_uaa[:lastmodified]
          row.push(user_uaa[:lastmodified].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        if user_uaa[:passwd_lastmodified]
          row.push(user_uaa[:passwd_lastmodified].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        row.push(user_uaa[:email])
        row.push(user_uaa[:familyname])
        row.push(user_uaa[:givenname])
        row.push(user_uaa[:active])
        row.push(user_uaa[:version])

        authorities  = []
        member_groups_entry = member_groups[guid]
        if member_groups_entry
          member_groups_entry.each do |group_id|
            group = group_hash[group_id]
            authorities.push(group[:displayname]) if group
          end
        end

        authorities = authorities.sort

        row.push(authorities)

        if event_counter
          row.push(event_counter)
        elsif events_connected
          row.push(0)
        else
          row.push(nil)
        end

        user_cc = user_cc_hash[guid]

        if user_cc
          id = user_cc[:id]

          organization_auditors         = users_organizations_auditors[id] || 0
          organization_billing_managers = users_organizations_billing_managers[id] || 0
          organization_managers         = users_organizations_managers[id] || 0
          organization_users            = users_organizations_users[id] || 0
          spc_auditors                  = users_spaces_auditors[id] || 0
          spc_developers                = users_spaces_developers[id] || 0
          spc_managers                  = users_spaces_managers[id] || 0

          row.push(organization_auditors + organization_billing_managers + organization_managers + organization_users)
          row.push(organization_auditors)
          row.push(organization_billing_managers)
          row.push(organization_managers)
          row.push(organization_users)

          row.push(spc_auditors + spc_developers + spc_managers)
          row.push(spc_auditors)
          row.push(spc_developers)
          row.push(spc_managers)
        else
          row.push(nil, nil, nil, nil, nil, nil, nil, nil, nil)
        end

        items.push(row)

        hash[guid] =
        {
          'groups'   => authorities,
          'user_cc'  => user_cc,
          'user_uaa' => user_uaa
        }
      end

      result(true, items, hash, (0..20).to_a, (0..10).to_a)
    end

    private

    def count_roles(input_user_array, output_user_hash)
      input_user_array['items'].each do |input_user_array_entry|
        Thread.pass
        user_id = input_user_array_entry[:user_id]
        output_user_hash[user_id] = 0 if output_user_hash[user_id].nil?
        output_user_hash[user_id] += 1
      end
    end
  end
end
