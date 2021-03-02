require 'date'
require_relative 'base_view_model'

module AdminUI
  class StagingSecurityGroupsSpacesViewModel < AdminUI::BaseViewModel
    def do_items
      security_groups                = @cc.security_groups
      spaces                         = @cc.spaces
      staging_security_groups_spaces = @cc.staging_security_groups_spaces

      # security_groups, spaces and staging_security_groups_spaces have to exist. Other record types are optional
      return result unless security_groups['connected'] &&
                           spaces['connected'] &&
                           staging_security_groups_spaces['connected']

      organizations = @cc.organizations

      organization_hash   = organizations['items'].map { |item| [item[:id], item] }.to_h
      security_group_hash = security_groups['items'].map { |item| [item[:id], item] }.to_h
      space_hash          = spaces['items'].map { |item| [item[:id], item] }.to_h

      items = []
      hash  = {}

      staging_security_groups_spaces['items'].each do |staging_security_group_space|
        return result unless @running

        Thread.pass

        row = []

        security_group = security_group_hash[staging_security_group_space[:staging_security_group_id]]
        next if security_group.nil?

        space = space_hash[staging_security_group_space[:staging_space_id]]
        next if space.nil?

        organization = organization_hash[space[:organization_id]]

        key = "#{security_group[:guid]}/#{space[:guid]}"

        row.push(key)
        row.push(security_group[:name])
        row.push(security_group[:guid])
        row.push(security_group[:created_at].to_datetime.rfc3339)

        if security_group[:updated_at]
          row.push(security_group[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        row.push(space[:name])
        row.push(space[:guid])
        row.push(space[:created_at].to_datetime.rfc3339)

        if space[:updated_at]
          row.push(space[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        if organization
          row.push("#{organization[:name]}/#{space[:name]}")
        else
          row.push(nil)
        end

        items.push(row)

        hash[key] =
          {
            'organization'                 => organization,
            'security_group'               => security_group,
            'space'                        => space,
            'staging_security_group_space' => staging_security_group_space
          }
      end

      result(true, items, hash, (1..9).to_a, (1..9).to_a)
    end
  end
end
