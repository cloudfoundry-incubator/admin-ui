require_relative 'base'
require 'date'
require 'thread'

module AdminUI
  class ServicesViewModel < AdminUI::Base
    def initialize(logger, cc)
      super(logger)

      @cc = cc
    end

    def do_items
      services = @cc.services

      # services have to exist.  Other record types are optional
      return result unless services['connected']

      service_brokers   = @cc.service_brokers
      service_instances = @cc.service_instances
      service_plans     = @cc.service_plans

      service_instances_connected = service_instances['connected']
      service_plans_connected     = service_plans['connected']

      service_broker_hash = Hash[service_brokers['items'].map { |item| [item[:id], item] }]
      service_plan_hash   = Hash[service_plans['items'].map { |item| [item[:id], item] }]

      service_plan_counters = {}
      service_plans['items'].each do |service_plan|
        Thread.pass
        service_id = service_plan[:service_id]
        service_plan_counters[service_id] = 0 if service_plan_counters[service_id].nil?
        service_plan_counters[service_id] += 1
      end

      service_instance_counters = {}
      service_instances['items'].each do |service_instance|
        Thread.pass
        service_plan_id = service_instance[:service_plan_id]
        next if service_plan_id.nil?
        service_plan = service_plan_hash[service_plan_id]
        next if service_plan.nil?
        service_id = service_plan[:service_id]
        service_instance_counters[service_id] = 0 if service_instance_counters[service_id].nil?
        service_instance_counters[service_id] += 1
      end

      items = []
      hash  = {}

      services['items'].each do |service|
        Thread.pass
        service_broker = service_broker_hash[service[:service_broker_id]]

        row = []

        row.push(service[:provider])
        row.push(service[:label])
        row.push(service[:guid])
        row.push(service[:version])
        row.push(service[:created_at].to_datetime.rfc3339)

        if service[:updated_at]
          row.push(service[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        row.push(service[:active])
        row.push(service[:bindable])

        if service_plan_counters[service[:id]]
          row.push(service_plan_counters[service[:id]])
        elsif service_plans_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_instance_counters[service[:id]]
          row.push(service_instance_counters[service[:id]])
        elsif service_instances_connected
          row.push(0)
        else
          row.push(nil)
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

        hash[service[:guid]] =
        {
          'service'       => service,
          'serviceBroker' => service_broker
        }
      end

      result(true, items, hash, (0..13).to_a, (0..13).to_a - [8, 9])
    end
  end
end
