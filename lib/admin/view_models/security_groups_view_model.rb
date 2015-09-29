require 'date'
require 'thread'
require_relative 'base_view_model'

module AdminUI
  class SecurityGroupsViewModel < AdminUI::BaseViewModel
    def do_items
      security_groups = @cc.security_groups

      # security_groups have to exist.  Other record types are optional
      return result unless security_groups['connected']

      items = []
      hash  = {}

      security_groups['items'].each do |security_group|
        return result unless @running
        Thread.pass

        guid = security_group[:guid]

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

        items.push(row)

        hash[guid] = security_group
      end

      result(true, items, hash, (1..6).to_a, [1, 2, 3, 4])
    end
  end
end
