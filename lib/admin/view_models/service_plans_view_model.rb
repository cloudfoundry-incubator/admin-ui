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
      service_plans = @cc.service_plans(false)

      # service_plans have to exist.  Other record types are optional
      return result unless service_plans['connected']

      services          = @cc.services(false)
      service_brokers   = @cc.service_brokers(false)
      service_instances = @cc.service_instances(false)

      service_instances_connected = service_instances['connected']

      service_broker_hash = Hash[*service_brokers['items'].map { |item| [item['guid'], item] }.flatten]
      service_hash        = Hash[*services['items'].map { |item| [item['guid'], item] }.flatten]

      service_instance_counters = {}

      service_instances['items'].each do |service_instance|
        Thread.pass
        service_plan_guid = service_instance['service_plan_guid']
        service_instance_counters[service_plan_guid] = 0 if service_instance_counters[service_plan_guid].nil?
        service_instance_counters[service_plan_guid] += 1
      end

      items = []

      service_plans['items'].each do |service_plan|
        Thread.pass
        service        = service_hash[service_plan['service_guid']]
        service_broker = service.nil? || service['service_broker_guid'].nil? ? nil : service_broker_hash[service['service_broker_guid']]

        row = []

        row.push(service_plan)
        row.push(service_plan['name'])

        service_plan_target = ''
        if service
          service_plan_target = service['provider'] if service['provider']
          service_plan_target = "#{ service_plan_target }/#{ service['label'] }/"
        end
        service_plan_target = "#{ service_plan_target }#{ service_plan['name'] }"
        row.push(service_plan_target)

        row.push(DateTime.parse(service_plan['created_at']).rfc3339)

        if service_plan['updated_at']
          row.push(DateTime.parse(service_plan['updated_at']).rfc3339)
        else
          row.push(nil)
        end

        row.push(service_plan['public'])

        if service_instance_counters[service_plan['guid']]
          row.push(service_instance_counters[service_plan['guid']])
        elsif service_instances_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service
          row.push(service['provider'])
          row.push(service['label'])
          row.push(service['version'])
          row.push(DateTime.parse(service['created_at']).rfc3339)

          if service['updated_at']
            row.push(DateTime.parse(service['updated_at']).rfc3339)
          else
            row.push(nil)
          end

          row.push(service['active'])
          row.push(service['bindable'])
        else
          row.push(nil, nil, nil, nil, nil, nil, nil)
        end

        if service_broker
          row.push(service_broker['name'])
          row.push(DateTime.parse(service_broker['created_at']).rfc3339)

          if service_broker['updated_at']
            row.push(DateTime.parse(service_broker['updated_at']).rfc3339)
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
