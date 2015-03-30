require_relative 'base'
require 'date'
require 'thread'

module AdminUI
  class ServicePlansViewModel < AdminUI::Base
    def initialize(logger, cc)
      super(logger)

      @cc = cc
    end

    def do_items
      service_plans = @cc.service_plans

      # service_plans have to exist.  Other record types are optional
      return result unless service_plans['connected']

      services                  = @cc.services
      service_bindings          = @cc.service_bindings
      service_brokers           = @cc.service_brokers
      service_instances         = @cc.service_instances
      service_plan_visibilities = @cc.service_plan_visibilities

      service_bindings_connected          = service_bindings['connected']
      service_instances_connected         = service_instances['connected']
      service_plan_visibilities_connected = service_plan_visibilities['connected']

      service_broker_hash   = Hash[service_brokers['items'].map { |item| [item[:id], item] }]
      service_hash          = Hash[services['items'].map { |item| [item[:id], item] }]
      service_instance_hash = Hash[service_instances['items'].map { |item| [item[:id], item] }]

      service_plan_visibility_counters = {}
      service_plan_visibilities['items'].each do |service_plan_visibility|
        Thread.pass
        service_plan_id = service_plan_visibility[:service_plan_id]
        next if service_plan_id.nil?
        service_plan_visibility_counters[service_plan_id] = 0 if service_plan_visibility_counters[service_plan_id].nil?
        service_plan_visibility_counters[service_plan_id] += 1
      end

      service_instance_counters = {}
      service_instances['items'].each do |service_instance|
        Thread.pass
        service_plan_id = service_instance[:service_plan_id]
        next if service_plan_id.nil?
        service_instance_counters[service_plan_id] = 0 if service_instance_counters[service_plan_id].nil?
        service_instance_counters[service_plan_id] += 1
      end

      service_binding_counters = {}
      service_bindings['items'].each do |service_binding|
        Thread.pass
        service_instance_id = service_binding[:service_instance_id]
        next if service_instance_id.nil?
        service_instance = service_instance_hash[service_instance_id]
        next if service_instance.nil?
        service_plan_id = service_instance[:service_plan_id]
        next if service_plan_id.nil?
        service_binding_counters[service_plan_id] = 0 if service_binding_counters[service_plan_id].nil?
        service_binding_counters[service_plan_id] += 1
      end

      items = []
      hash  = {}

      service_plans['items'].each do |service_plan|
        Thread.pass
        service        = service_hash[service_plan[:service_id]]
        service_broker = service.nil? || service[:service_broker_id].nil? ? nil : service_broker_hash[service[:service_broker_id]]

        row = []

        row.push(service_plan[:guid])
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

        if service_plan_visibility_counters[service_plan[:id]]
          row.push(service_plan_visibility_counters[service_plan[:id]])
        elsif service_plan_visibilities_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_instance_counters[service_plan[:id]]
          row.push(service_instance_counters[service_plan[:id]])
        elsif service_instances_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_binding_counters[service_plan[:id]]
          row.push(service_binding_counters[service_plan[:id]])
        elsif service_bindings_connected && service_instances_connected
          row.push(0)
        else
          row.push(nil)
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

        items.push(row)

        hash[service_plan[:guid]] =
        {
          'service'        => service,
          'service_broker' => service_broker,
          'service_plan'   => service_plan
        }
      end

      result(true, items, hash, (1..24).to_a, (1..24).to_a - [9, 10, 11])
    end
  end
end
