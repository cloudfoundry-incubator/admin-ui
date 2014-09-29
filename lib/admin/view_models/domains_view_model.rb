require_relative 'base'
require 'date'
require 'thread'

module AdminUI
  class DomainsViewModel < AdminUI::Base
    def initialize(logger, cc)
      super(logger)

      @cc = cc
    end

    def do_items
      domains = @cc.domains

      # domains have to exist.  Other record types are optional
      return result unless domains['connected']

      organizations = @cc.organizations
      routes        = @cc.routes

      routes_connected = routes['connected']

      organization_hash = Hash[organizations['items'].map { |item| [item[:id], item] }]

      domain_route_counters = {}

      routes['items'].each do |route|
        Thread.pass
        domain_id = route[:domain_id]
        domain_route_counters[domain_id] = 0 if domain_route_counters[domain_id].nil?
        domain_route_counters[domain_id] += 1
      end

      items = []

      domains['items'].each do |domain|
        Thread.pass
        owning_organization_id = domain[:owning_organization_id]
        organization           = owning_organization_id.nil? ? nil : organization_hash[owning_organization_id]
        domain_route_counter   = domain_route_counters[domain[:id]]

        row = []

        row.push(domain[:name])
        row.push(domain[:created_at].to_datetime.rfc3339)

        if domain[:updated_at]
          row.push(domain[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        if organization
          row.push(organization[:name])
        else
          row.push(nil)
        end

        if domain_route_counter
          row.push(domain_route_counter)
        elsif routes_connected
          row.push(0)
        else
          row.push(nil)
        end

        row.push('domain'       => domain,
                 'organization' => organization)

        items.push(row)
      end

      result(items, (0..4).to_a, (0..3).to_a)
    end
  end
end
