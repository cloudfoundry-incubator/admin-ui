require 'date'
require 'set'
require_relative 'base_view_model'

module AdminUI
  class FeatureFlagsViewModel < AdminUI::BaseViewModel
    # DEFAULT_FLAGS from https://github.com/cloudfoundry/cloud_controller_ng/blob/master/app/models/runtime/feature_flag.rb
    DEFAULT_FLAGS =
      {
        app_bits_upload:                             true,
        app_scaling:                                 true,
        diego_docker:                                false, # Added in cf_release 213
        env_var_visibility:                          true, # Added in cf-release 238
        hide_marketplace_from_unauthenticated_users: false, # Added in cf-deployment 5.1.0
        private_domain_creation:                     true,
        resource_matching:                           true, # Added in cf-deployment 12.2.0
        route_creation:                              true,
        service_instance_creation:                   true,
        service_instance_sharing:                    false, # Added in cf-release 280
        set_roles_by_username:                       true, # Added in cf_release 218
        space_developer_env_var_visibility:          true, # Added in cf_release 232
        space_scoped_private_broker_creation:        true, # Added in cf release 231
        # task_creation:                             false, # Added in cf_release 228 as false, but changed in cf_release 253 (API version 2.75.0) to true. Determined via code below
        unset_roles_by_username:                     true, # Added in cf_release 218
        user_org_creation:                           false
      }.freeze

    def do_items
      feature_flags = @cc.feature_flags

      # feature_flags have to exist. Other record types are optional
      return result unless feature_flags['connected']

      # Set of persisted feature_flag keys
      feature_flags_set = feature_flags['items'].to_set { |feature_flag| feature_flag[:name] }

      combined_feature_flags = feature_flags['items'].clone

      # Don't add the defaults if testing
      unless @testing
        DEFAULT_FLAGS.each_pair do |name, enabled|
          name_string = name.to_s
          combined_feature_flags.push(name: name_string, enabled: enabled) unless feature_flags_set.include?(name_string)
        end

        unless feature_flags_set.include?('task_creation')
          # As of cf-release v253 (API version 2.75.0), task_creation changed from default of false to true
          api_version = @cc_rest_client.api_version
          task_creation = Gem::Version.new(api_version) >= Gem::Version.new('2.75.0')
          combined_feature_flags.push(name: 'task_creation', enabled: task_creation)
        end
      end

      items = []
      hash  = {}

      combined_feature_flags.each do |feature_flag|
        return result unless @running

        Thread.pass

        name = feature_flag[:name]

        row = []

        row.push(name)
        row.push(name)
        row.push(feature_flag[:guid]) # default value will not have GUID

        # Default value will not have created_at
        if feature_flag[:created_at]
          row.push(feature_flag[:created_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        if feature_flag[:updated_at]
          row.push(feature_flag[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        row.push(feature_flag[:enabled])

        items.push(row)

        hash[name] = feature_flag
      end

      result(true, items, hash, (1..5).to_a, (1..5).to_a)
    end
  end
end
