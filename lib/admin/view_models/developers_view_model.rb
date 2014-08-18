require_relative 'base'
require 'date'
require 'thread'

module AdminUI
  class DevelopersViewModel < AdminUI::Base
    def initialize(logger, cc)
      super(logger)

      @cc = cc
    end

    def do_items
      groups            = @cc.groups
      group_membership  = @cc.group_membership
      spaces_developers = @cc.spaces_developers
      users_cc          = @cc.users_cc
      users_uaa         = @cc.users_uaa

      # groups, group_membership, spaces_developers, users_cc and users_uaa have to exist.  Other record types are optional
      return result unless groups['connected'] && group_membership['connected'] && spaces_developers['connected'] && users_cc['connected'] && users_uaa['connected']

      organizations = @cc.organizations
      spaces        = @cc.spaces

      group_hash        = Hash[*groups['items'].map { |item| [item[:id], item] }.flatten]
      organization_hash = Hash[*organizations['items'].map { |item| [item[:id], item] }.flatten]
      space_hash        = Hash[*spaces['items'].map { |item| [item[:id], item] }.flatten]
      user_cc_hash      = Hash[*users_cc['items'].map { |item| [item[:id], item] }.flatten]
      user_uaa_hash     = Hash[*users_uaa['items'].map { |item| [item[:id], item] }.flatten]

      member_groups = {}

      group_membership['items'].each do |group_membership_entry|
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

      items = []

      spaces_developers['items'].each do |space_developer|
        Thread.pass
        user_cc = user_cc_hash[space_developer[:user_id]]

        next if user_cc.nil?

        guid     = user_cc[:guid]
        user_uaa = user_uaa_hash[guid]

        next if user_uaa.nil?

        objects = { 'space_developer' => space_developer,
                    'user_cc'         => user_cc,
                    'user_uaa'        => user_uaa }

        row = []

        row.push(user_uaa[:email])

        space = space_hash[space_developer[:space_id]]

        if space
          objects['space'] = space

          row.push(space[:name])

          organization = organization_hash[space[:organization_id]]

          if organization
            objects['organization'] = organization
            row.push(organization[:name])
            row.push("#{ organization[:name] }/#{ space[:name] }")
          else
            row.push(nil, nil)
          end
        else
          row.push(nil, nil, nil)
        end

        row.push(user_uaa[:created].to_datetime.rfc3339)

        if user_uaa[:lastmodified]
          row.push(user_uaa[:lastmodified].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        authorities  = []
        member_groups_entry = member_groups[guid]
        if member_groups_entry
          member_groups_entry.each do |group_id|
            group = group_hash[group_id]
            authorities.push(group[:displayname]) if group
          end
        end

        objects['authorities'] = authorities.sort.join(', ')

        row.push(objects)

        items.push(row)
      end

      result(items, (0..5).to_a, (0..5).to_a)
    end
  end
end
