require 'date'
require_relative 'base_view_model'

module AdminUI
  class SecurityGroupsViewModel < AdminUI::BaseViewModel
    def do_items
      security_groups = @cc.security_groups

      # security_groups have to exist. Other record types are optional
      return result unless security_groups['connected']

      security_groups_spaces         = @cc.security_groups_spaces
      staging_security_groups_spaces = @cc.staging_security_groups_spaces

      security_groups_spaces_connected         = security_groups_spaces['connected']
      staging_security_groups_spaces_connected = staging_security_groups_spaces['connected']

      security_groups_spaces_counters         = {}
      staging_security_groups_spaces_counters = {}

      security_groups_spaces['items'].each do |security_group_space|
        return result unless @running

        Thread.pass

        security_group_id = security_group_space[:security_group_id]
        security_groups_spaces_counters[security_group_id] = 0 if security_groups_spaces_counters[security_group_id].nil?
        security_groups_spaces_counters[security_group_id] += 1
      end

      staging_security_groups_spaces['items'].each do |staging_security_group_space|
        return result unless @running

        Thread.pass

        staging_security_group_id = staging_security_group_space[:staging_security_group_id]
        staging_security_groups_spaces_counters[staging_security_group_id] = 0 if staging_security_groups_spaces_counters[staging_security_group_id].nil?
        staging_security_groups_spaces_counters[staging_security_group_id] += 1
      end

      items = []
      hash  = {}

      security_groups['items'].each do |security_group|
        return result unless @running

        Thread.pass

        guid = security_group[:guid]
        id   = security_group[:id]

        security_group_spaces_counter         = security_groups_spaces_counters[id]
        staging_security_group_spaces_counter = staging_security_groups_spaces_counters[id]

        row = []

        row.push(guid)
        row.push(security_group[:name])
        row.push(guid)

        row.push(security_group[:created_at].to_datetime.rfc3339)

        if security_group[:updated_at]
          row.push(security_group[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        row.push(security_group[:staging_default])
        row.push(security_group[:running_default])

        if security_group_spaces_counter
          row.push(security_group_spaces_counter)
        elsif security_groups_spaces_connected
          row.push(0)
        else
          row.push(nil)
        end

        if staging_security_group_spaces_counter
          row.push(staging_security_group_spaces_counter)
        elsif staging_security_groups_spaces_connected
          row.push(0)
        else
          row.push(nil)
        end

        items.push(row)

        hash[guid] = security_group
      end

      result(true, items, hash, (1..8).to_a, [1, 2, 3, 4])
    end
  end
end
