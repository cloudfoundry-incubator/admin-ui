require 'date'
require_relative 'base_view_model'

module AdminUI
  class EnvironmentGroupsViewModel < AdminUI::BaseViewModel
    def do_items
      env_groups = @cc.env_groups

      # env_groups have to exist. Other record types are optional
      return result unless env_groups['connected']

      items = []
      hash  = {}

      env_groups['items'].each do |env_group|
        return result unless @running

        Thread.pass

        name = env_group[:name]

        row = []

        row.push(name)
        row.push(env_group[:guid])
        row.push(env_group[:created_at].to_datetime.rfc3339)

        if env_group[:updated_at]
          row.push(env_group[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        items.push(row)

        hash[name] = env_group
      end

      result(true, items, hash, (0..3).to_a, (0..3).to_a)
    end
  end
end
