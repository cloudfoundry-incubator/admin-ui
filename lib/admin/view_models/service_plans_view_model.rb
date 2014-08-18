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

      services          = @cc.services
      service_brokers   = @cc.service_brokers
      service_instances = @cc.service_instances

      service_instances_connected = service_instances['connected']

      service_broker_hash = Hash[*service_brokers['items'].map { |item| [item[:id], item] }.flatten]
      service_hash        = Hash[*services['items'].map { |item| [item[:id], item] }.flatten]

      service_instance_counters = {}

      service_instances['items'].each do |service_instance|
        Thread.pass
        service_plan_id = service_instance[:service_plan_id]
        service_instance_counters[service_plan_id] = 0 if service_instance_counters[service_plan_id].nil?
        service_instance_counters[service_plan_id] += 1
      end

      items = []

      service_plans['items'].each do |service_plan|
        Thread.pass
        service        = service_hash[service_plan[:service_id]]
        service_broker = service.nil? || service[:service_broker_id].nil? ? nil : service_broker_hash[service[:service_broker_id]]

        row = []

        row.push(service_plan)
        row.push(service_plan[:name])

        service_plan_target = ''
        if service
          service_plan_target = service[:provider] if service[:provider]
          service_plan_target = "#{ service_plan_target }/#{ service[:label] }/"
        end
        service_plan_target = "#{ service_plan_target }#{ service_plan[:name] }"
        row.push(service_plan_target)

        row.push(service_plan[:created_at].to_datetime.rfc3339)

        if service_plan[:updated_at]
          row.push(service_plan[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        row.push(service_plan[:public])

        if service_instance_counters[service_plan[:id]]
          row.push(service_instance_counters[service_plan[:id]])
        elsif service_instances_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service
          row.push(service[:provider])
          row.push(service[:label])
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
          row.push(nil, nil, nil, nil, nil, nil, nil)
        end

        if service_broker
          row.push(service_broker[:name])
          row.push(service_broker[:created_at].to_datetime.rfc3339)

          if service_broker[:updated_at]
            row.push(service_broker[:updated_at].to_datetime.rfc3339)
          else
            row.push(nil)
          end
        else
          row.push(nil, nil, nil)
        end

        row.push('service'       => service,
                 'serviceBroker' => service_broker,
                 'servicePlan'   => service_plan)

        items.push(row)
      end

      result(items, (1..16).to_a, (1..16).to_a - [6])
    end
  end
end
