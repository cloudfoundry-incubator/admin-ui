require 'date'
require_relative 'base_view_model'

module AdminUI
  class QuotasViewModel < AdminUI::BaseViewModel
    def do_items
      quota_definitions = @cc.quota_definitions

      # quota_definitions have to exist. Other record types are optional
      return result unless quota_definitions['connected']

      organizations = @cc.organizations

      organizations_connected = organizations['connected']

      organization_counters = {}

      organizations['items'].each do |organization|
        return result unless @running

        Thread.pass

        quota_definition_id = organization[:quota_definition_id]
        organization_counters[quota_definition_id] = 0 if organization_counters[quota_definition_id].nil?
        organization_counters[quota_definition_id] += 1
      end

      items = []
      hash  = {}

      quota_definitions['items'].each do |quota_definition|
        return result unless @running

        Thread.pass

        row = []

        row.push(quota_definition[:guid])
        row.push(quota_definition[:name])
        row.push(quota_definition[:guid])
        row.push(quota_definition[:created_at].to_datetime.rfc3339)

        if quota_definition[:updated_at]
          row.push(quota_definition[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        row.push(quota_definition[:total_private_domains])
        row.push(quota_definition[:total_services])
        row.push(quota_definition[:total_service_keys])
        row.push(quota_definition[:total_routes])
        row.push(quota_definition[:total_reserved_route_ports])
        row.push(quota_definition[:app_instance_limit])
        row.push(quota_definition[:app_task_limit])
        row.push(quota_definition[:memory_limit])
        row.push(quota_definition[:instance_memory_limit])
        row.push(quota_definition[:non_basic_services_allowed])

        if organization_counters[quota_definition[:id]]
          row.push(organization_counters[quota_definition[:id]])
        elsif organizations_connected
          row.push(0)
        else
          row.push(nil)
        end

        items.push(row)

        hash[quota_definition[:guid]] = quota_definition
      end

      result(true, items, hash, (1..15).to_a, [1, 2, 3, 4, 14])
    end
  end
end
