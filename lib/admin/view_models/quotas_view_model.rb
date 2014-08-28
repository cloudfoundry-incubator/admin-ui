require_relative 'base'
require 'date'
require 'thread'

module AdminUI
  class QuotasViewModel < AdminUI::Base
    def initialize(logger, cc)
      super(logger)

      @cc = cc
    end

    def do_items
      quota_definitions = @cc.quota_definitions

      # quota_definitions have to exist.  Other record types are optional
      return result unless quota_definitions['connected']

      organizations = @cc.organizations

      organizations_connected = organizations['connected']

      organization_counters = {}

      organizations['items'].each do |organization|
        Thread.pass
        quota_definition_id = organization[:quota_definition_id]
        organization_counters[quota_definition_id] = 0 if organization_counters[quota_definition_id].nil?
        organization_counters[quota_definition_id] += 1
      end

      items = []

      quota_definitions['items'].each do |quota_definition|
        Thread.pass
        row = []

        row.push(quota_definition[:name])
        row.push(quota_definition[:created_at].to_datetime.rfc3339)

        if quota_definition[:updated_at]
          row.push(quota_definition[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        row.push(quota_definition[:total_services])
        row.push(quota_definition[:total_routes])
        row.push(quota_definition[:memory_limit])
        row.push(quota_definition[:non_basic_services_allowed])

        if organization_counters[quota_definition[:id]]
          row.push(organization_counters[quota_definition[:id]])
        elsif organizations_connected
          row.push(0)
        else
          row.push(nil)
        end

        row.push(quota_definition)

        items.push(row)
      end

      result(items, (0..7).to_a, [0, 1, 2, 6])
    end
  end
end
