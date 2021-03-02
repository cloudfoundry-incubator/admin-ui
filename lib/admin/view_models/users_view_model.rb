require 'date'
require_relative 'base_view_model'

module AdminUI
  class UsersViewModel < AdminUI::BaseViewModel
    def do_items
      organizations                  = @cc.organizations
      organizations_auditors         = @cc.organizations_auditors
      organizations_billing_managers = @cc.organizations_billing_managers
      organizations_managers         = @cc.organizations_managers
      organizations_users            = @cc.organizations_users
      spaces                         = @cc.spaces
      spaces_auditors                = @cc.spaces_auditors
      spaces_managers                = @cc.spaces_developers
      spaces_developers              = @cc.spaces_managers
      users_cc                       = @cc.users_cc
      users_uaa                      = @cc.users_uaa

      # organizations, organizations_auditors, organizations_billing_managers, organizations_managers, organizations_users,
      # spaces, spaces_auditors, spaces_developers, spaces_managers,
      # users_cc and users_uaa have to exist. Other record types are optional
      return result unless organizations['connected'] &&
                           organizations_auditors['connected'] &&
                           organizations_billing_managers['connected'] &&
                           organizations_managers['connected'] &&
                           organizations_users['connected'] &&
                           spaces['connected'] &&
                           spaces_auditors['connected'] &&
                           spaces_developers['connected'] &&
                           spaces_managers['connected'] &&
                           users_cc['connected'] &&
                           users_uaa['connected']

      approvals        = @cc.approvals
      events           = @cc.events
      group_membership = @cc.group_membership
      identity_zones   = @cc.identity_zones
      request_counts   = @cc.request_counts
      revocable_tokens = @cc.revocable_tokens
      user_annotations = @cc.user_annotations
      user_labels      = @cc.user_labels

      approvals_connected        = approvals['connected']
      events_connected           = events['connected']
      group_membership_connected = group_membership['connected']
      request_counts_connected   = request_counts['connected']
      revocable_tokens_connected = revocable_tokens['connected']

      identity_zone_hash = identity_zones['items'].map { |item| [item[:id], item] }.to_h
      organization_hash  = organizations['items'].map { |item| [item[:id], item] }.to_h
      request_count_hash = request_counts['items'].map { |item| [item[:user_guid], item] }.to_h
      space_hash         = spaces['items'].map { |item| [item[:id], item] }.to_h
      user_cc_hash       = users_cc['items'].map { |item| [item[:guid], item] }.to_h

      user_annotations_hash = {}
      user_annotations['items'].each do |user_annotation|
        return result unless @running

        Thread.pass

        user_guid = user_annotation[:resource_guid]
        user_annotations_array = user_annotations_hash[user_guid]
        if user_annotations_array.nil?
          user_annotations_array = []
          user_annotations_hash[user_guid] = user_annotations_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            annotation:         user_annotation,
            created_at_rfc3339: user_annotation[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: user_annotation[:updated_at].nil? ? nil : user_annotation[:updated_at].to_datetime.rfc3339
          }

        user_annotations_array.push(wrapper)
      end

      user_labels_hash = {}
      user_labels['items'].each do |user_label|
        return result unless @running

        Thread.pass

        user_guid = user_label[:resource_guid]
        user_labels_array = user_labels_hash[user_guid]
        if user_labels_array.nil?
          user_labels_array = []
          user_labels_hash[user_guid] = user_labels_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            label:              user_label,
            created_at_rfc3339: user_label[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: user_label[:updated_at].nil? ? nil : user_label[:updated_at].to_datetime.rfc3339
          }

        user_labels_array.push(wrapper)
      end

      event_counters = {}
      events['items'].each do |event|
        return result unless @running

        Thread.pass

        next unless event[:actor_type] == 'user'
        # A user actor_type is used for a client. But, the actor_name is nil in this case
        next if event[:actor_name].nil?

        actor = event[:actor]
        event_counters[actor] = 0 if event_counters[actor].nil?
        event_counters[actor] += 1
      end

      group_membership_counters = {}
      group_membership['items'].each do |group_membership_entry|
        return result unless @running

        Thread.pass

        user_id = group_membership_entry[:member_id]
        group_membership_counters[user_id] = 0 if group_membership_counters[user_id].nil?
        group_membership_counters[user_id] += 1
      end

      approval_counters = {}
      approvals['items'].each do |approval|
        return result unless @running

        Thread.pass

        user_id = approval[:user_id]
        approval_counters[user_id] = 0 if approval_counters[user_id].nil?
        approval_counters[user_id] += 1
      end

      revocable_token_counters = {}
      revocable_tokens['items'].each do |revocable_token|
        return result unless @running

        Thread.pass

        user_id = revocable_token[:user_id]
        revocable_token_counters[user_id] = 0 if revocable_token_counters[user_id].nil?
        revocable_token_counters[user_id] += 1
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

        approval_counter         = approval_counters[guid]
        event_counter            = event_counters[guid]
        group_membership_counter = group_membership_counters[guid]
        identity_zone            = identity_zone_hash[user_uaa[:identity_zone_id]]
        request_count            = request_count_hash[guid]
        revocable_token_counter  = revocable_token_counters[guid]
        user_annotation_array    = user_annotations_hash[guid] || []
        user_label_array         = user_labels_hash[guid] || []

        row = []

        row.push(guid)

        if identity_zone
          row.push(identity_zone[:name])
        else
          row.push(nil)
        end

        row.push(user_uaa[:username])
        row.push(guid)
        row.push(user_uaa[:created].to_datetime.rfc3339)

        if user_uaa[:lastmodified]
          row.push(user_uaa[:lastmodified].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        if user_uaa[:last_logon_success_time]
          row.push(Time.at(user_uaa[:last_logon_success_time] / 1000.0).to_datetime.rfc3339)
        else
          row.push(nil)
        end

        if user_uaa[:previous_logon_success_time]
          row.push(Time.at(user_uaa[:previous_logon_success_time] / 1000.0).to_datetime.rfc3339)
        else
          row.push(nil)
        end

        if user_uaa[:passwd_lastmodified]
          row.push(user_uaa[:passwd_lastmodified].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        if user_uaa[:passwd_change_required].nil?
          row.push(nil)
        else
          row.push(user_uaa[:passwd_change_required])
        end

        row.push(user_uaa[:email])
        row.push(user_uaa[:familyname])
        row.push(user_uaa[:givenname])
        row.push(user_uaa[:phonenumber])
        row.push(user_uaa[:active])
        row.push(user_uaa[:verified])
        row.push(user_uaa[:version])

        if event_counter
          row.push(event_counter)
        elsif events_connected
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

        if revocable_token_counter
          row.push(revocable_token_counter)
        elsif revocable_tokens_connected
          row.push(0)
        else
          row.push(nil)
        end

        if request_count
          row.push(request_count[:count])
          if request_count[:valid_until]
            row.push(request_count[:valid_until].to_datetime.rfc3339)
          else
            row.push(nil)
          end
        elsif request_counts_connected
          row.push(0, nil)
        else
          row.push(nil, nil)
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

          default_space_id = user_cc[:default_space_id]
          space            = default_space_id.nil? ? nil : space_hash[default_space_id]
          organization     = space.nil? ? nil : organization_hash[space[:organization_id]]

          if organization && space
            row.push("#{organization[:name]}/#{space[:name]}")
          else
            row.push(nil)
          end
        else
          row.push(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
        end

        items.push(row)

        hash[guid] =
          {
            'annotations'   => user_annotation_array,
            'identity_zone' => identity_zone,
            'labels'        => user_label_array,
            'organization'  => organization,
            'request_count' => request_count,
            'space'         => space,
            'user_cc'       => user_cc,
            'user_uaa'      => user_uaa
          }
      end

      result(true, items, hash, (1..32).to_a, (1..15).to_a << 32)
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
