require_relative 'base'
require 'thread'

module AdminUI
  class OrganizationRolesViewModel < AdminUI::Base
    def initialize(logger, cc)
      super(logger)

      @cc = cc
    end

    def do_items
      organizations                  = @cc.organizations
      organizations_auditors         = @cc.organizations_auditors
      organizations_billing_managers = @cc.organizations_billing_managers
      organizations_managers         = @cc.organizations_managers
      organizations_users            = @cc.organizations_users
      users_cc                       = @cc.users_cc
      users_uaa                      = @cc.users_uaa

      # organizations, organizations_auditors, organizations_billing_managers,
      # organizations_managers, organizations_users,
      # users_cc and users_uaa have to exist
      return result unless organizations['connected'] &&
                           organizations_auditors['connected'] &&
                           organizations_billing_managers['connected'] &&
                           organizations_managers['connected'] &&
                           organizations_users['connected'] &&
                           users_cc['connected'] &&
                           users_uaa['connected']

      organization_hash = Hash[organizations['items'].map { |item| [item[:id], item] }]
      user_cc_hash      = Hash[users_cc['items'].map { |item| [item[:id], item] }]
      user_uaa_hash     = Hash[users_uaa['items'].map { |item| [item[:id], item] }]

      items = []
      hash  = {}

      add_rows(organizations_auditors,         'auditors',         'Auditor', organization_hash, user_cc_hash, user_uaa_hash, items, hash)
      add_rows(organizations_billing_managers, 'billing_managers', 'Billing Manager', organization_hash, user_cc_hash, user_uaa_hash, items, hash)
      add_rows(organizations_managers,         'managers',         'Manager', organization_hash, user_cc_hash, user_uaa_hash, items, hash)
      add_rows(organizations_users,            'users',            'User', organization_hash, user_cc_hash, user_uaa_hash, items, hash)

      result(true, items, hash, (1..5).to_a, (1..5).to_a)
    end

    private

    def add_rows(organization_role_array, path_role, human_role, organization_hash, user_cc_hash, user_uaa_hash, items, hash)
      organization_role_array['items'].each do |organization_role|
        Thread.pass

        row = []

        organization = organization_hash[organization_role[:organization_id]]
        next if organization.nil?

        user_cc = user_cc_hash[organization_role[:user_id]]
        next if user_cc.nil?

        user_uaa = user_uaa_hash[user_cc[:guid]]
        next if user_uaa.nil?

        key = "#{ organization[:guid] }/#{ path_role }/#{ user_cc[:guid] }"

        row.push(key)
        row.push(organization[:name])
        row.push(organization[:guid])
        row.push(user_uaa[:username])
        row.push(user_uaa[:id])
        row.push(human_role)

        items.push(row)

        hash[key] =
        {
          'organization' => organization,
          'role'         => organization_role,
          'user_cc'      => user_cc,
          'user_uaa'     => user_uaa
        }
      end
    end
  end
end
