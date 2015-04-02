require_relative 'base'
require 'date'
require 'thread'

module AdminUI
  class ServiceInstancesViewModel < AdminUI::Base
    def initialize(logger, cc)
      super(logger)

      @cc = cc
    end

    def do_items
      service_instances = @cc.service_instances

      # service_instances have to exist.  Other record types are optional
      return result unless service_instances['connected']

      organizations    = @cc.organizations
      service_brokers  = @cc.service_brokers
      service_bindings = @cc.service_bindings
      service_plans    = @cc.service_plans
      services         = @cc.services
      spaces           = @cc.spaces

      service_bindings_connected = service_bindings['connected']

      organization_hash   = Hash[organizations['items'].map { |item| [item[:id], item] }]
      service_broker_hash = Hash[service_brokers['items'].map { |item| [item[:id], item] }]
      service_plan_hash   = Hash[service_plans['items'].map { |item| [item[:id], item] }]
      service_hash        = Hash[services['items'].map { |item| [item[:id], item] }]
      space_hash          = Hash[spaces['items'].map { |item| [item[:id], item] }]

      service_binding_counters = {}
      service_bindings['items'].each do |service_binding|
        Thread.pass
        service_instance_id = service_binding[:service_instance_id]
        next if service_instance_id.nil?
        service_binding_counters[service_instance_id] = 0 if service_binding_counters[service_instance_id].nil?
        service_binding_counters[service_instance_id] += 1
      end

      items = []
      hash  = {}

      service_instances['items'].each do |service_instance|
        Thread.pass
        service_plan_id = service_instance[:service_plan_id]
        service_plan    = service_plan_id.nil? ? nil : service_plan_hash[service_plan_id]
        service         = service_plan.nil? ? nil : service_hash[service_plan[:service_id]]
        service_broker  = service.nil? || service[:service_broker_id].nil? ? nil : service_broker_hash[service[:service_broker_id]]
        space           = space_hash[service_instance[:space_id]]
        organization    = space.nil? ? nil : organization_hash[space[:organization_id]]

        row = []

        row.push(service_instance[:guid])
        row.push(service_instance[:name])
        row.push(service_instance[:guid])
        row.push(service_instance[:created_at].to_datetime.rfc3339)

        if service_instance[:updated_at]
          row.push(service_instance[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        if service_binding_counters[service_instance[:id]]
          row.push(service_binding_counters[service_instance[:id]])
        elsif service_bindings_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_plan
          row.push(service_plan[:name])
          row.push(service_plan[:guid])
          row.push(service_plan[:unique_id])
          row.push(service_plan[:created_at].to_datetime.rfc3339)

          if service_plan[:updated_at]
            row.push(service_plan[:updated_at].to_datetime.rfc3339)
          else
            row.push(nil)
          end

          row.push(service_plan[:active])
          row.push(service_plan[:public])
          row.push(service_plan[:free])
        else
          row.push(nil, nil, nil, nil, nil, nil, nil, nil)
        end

        if service
          row.push(service[:provider])
          row.push(service[:label])
          row.push(service[:guid])
          row.push(service[:unique_id])
          row.push(service[:version])
          row.push(service[:created_at].to_datetime.rfc3339)

          if service[:updated_at]
            row.push(service[:updated_at].to_datetime.rfc3339)
          else
            row.push(nil)
          end

          row.push(service[:active])
          row.push(service[:bindable])
        else
          row.push(nil, nil, nil, nil, nil, nil, nil, nil, nil)
        end

        if service_broker
          row.push(service_broker[:name])
          row.push(service_broker[:guid])
          row.push(service_broker[:created_at].to_datetime.rfc3339)

          if service_broker[:updated_at]
            row.push(service_broker[:updated_at].to_datetime.rfc3339)
          else
            row.push(nil)
          end
        else
          row.push(nil, nil, nil, nil)
        end

        if organization && space
          row.push("#{ organization[:name] }/#{ space[:name] }")
        else
          row.push(nil)
        end

        items.push(row)

        hash[service_instance[:guid]] =
        {
          'organization'     => organization,
          'service'          => service,
          'service_broker'   => service_broker,
          'service_instance' => service_instance,
          'service_plan'     => service_plan,
          'space'            => space
        }
      end

      result(true, items, hash, (1..27).to_a, (1..27).to_a - [5])
    end
  end
end
