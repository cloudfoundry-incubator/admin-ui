require_relative 'base'
require 'thread'

module AdminUI
  class SpaceRolesViewModel < AdminUI::Base
    def initialize(logger, cc)
      super(logger)

      @cc = cc
    end

    def do_items
      spaces            = @cc.spaces
      spaces_auditors   = @cc.spaces_auditors
      spaces_managers   = @cc.spaces_managers
      spaces_developers = @cc.spaces_developers
      users_cc          = @cc.users_cc
      users_uaa         = @cc.users_uaa

      # spaces, spaces_auditors, spaces_developers,
      # spaces_managers, users_cc and users_uaa have to exist
      return result unless spaces['connected'] &&
                           spaces_auditors['connected'] &&
                           spaces_developers['connected'] &&
                           spaces_managers['connected'] &&
                           users_cc['connected'] &&
                           users_uaa['connected']

      organizations = @cc.organizations

      organization_hash = Hash[organizations['items'].map { |item| [item[:id], item] }]
      space_hash        = Hash[spaces['items'].map { |item| [item[:id], item] }]
      user_cc_hash      = Hash[users_cc['items'].map { |item| [item[:id], item] }]
      user_uaa_hash     = Hash[users_uaa['items'].map { |item| [item[:id], item] }]

      items = []
      hash  = {}

      add_rows(spaces_auditors,   'auditors',   'Auditor',   space_hash, organization_hash, user_cc_hash, user_uaa_hash, items, hash)
      add_rows(spaces_developers, 'developers', 'Developer', space_hash, organization_hash, user_cc_hash, user_uaa_hash, items, hash)
      add_rows(spaces_managers,   'managers',   'Manager',   space_hash, organization_hash, user_cc_hash, user_uaa_hash, items, hash)

      result(true, items, hash, (1..6).to_a, (1..6).to_a)
    end

    private

    def add_rows(space_role_array, path_role, human_role, space_hash, organization_hash, user_cc_hash, user_uaa_hash, items, hash)
      space_role_array['items'].each do |space_role|
        Thread.pass

        row = []

        space = space_hash[space_role[:space_id]]
        next if space.nil?

        user_cc = user_cc_hash[space_role[:user_id]]
        next if user_cc.nil?

        user_uaa = user_uaa_hash[user_cc[:guid]]
        next if user_uaa.nil?

        organization = organization_hash[space[:organization_id]]

        key = "#{ space[:guid] }/#{ path_role }/#{ user_cc[:guid] }"

        row.push(key)
        row.push(space[:name])
        row.push(space[:guid])

        if organization
          row.push("#{ organization[:name] }/#{ space[:name] }")
        else
          row.push(nil)
        end

        row.push(user_uaa[:username])
        row.push(user_uaa[:id])
        row.push(human_role)

        items.push(row)

        hash[key] =
        {
          'organization' => organization,
          'role'         => space_role,
          'space'        => space,
          'user_cc'      => user_cc,
          'user_uaa'     => user_uaa
        }
      end
    end
  end
end
