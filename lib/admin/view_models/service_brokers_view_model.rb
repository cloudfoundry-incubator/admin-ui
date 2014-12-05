require_relative 'base'
require 'date'
require 'thread'

module AdminUI
  class ServiceBrokersViewModel < AdminUI::Base
    def initialize(logger, cc)
      super(logger)

      @cc = cc
    end

    def do_items
      service_brokers   = @cc.service_brokers

      # service_brokers have to exist.  Other record types are optional
      return result unless service_brokers['connected']

      service_instances = @cc.service_instances
      service_plans     = @cc.service_plans
      services          = @cc.services

      service_instances_connected = service_instances['connected']
      service_plans_connected     = service_plans['connected']
      services_connected          = service_plans['connected']

      service_hash      = Hash[services['items'].map { |item| [item[:id], item] }]
      service_plan_hash = Hash[service_plans['items'].map { |item| [item[:id], item] }]

      service_counters = {}
      services['items'].each do |service|
        Thread.pass
        service_broker_id = service[:service_broker_id]
        next if service_broker_id.nil?
        service_counters[service_broker_id] = 0 if service_counters[service_broker_id].nil?
        service_counters[service_broker_id] += 1
      end

      service_plan_counters = {}
      service_plans['items'].each do |service_plan|
        Thread.pass
        service = service_hash[service_plan[:service_id]]
        next if service.nil?
        service_broker_id = service[:service_broker_id]
        next if service_broker_id.nil?
        service_plan_counters[service_broker_id] = 0 if service_plan_counters[service_broker_id].nil?
        service_plan_counters[service_broker_id] += 1
      end

      service_instance_counters = {}
      service_instances['items'].each do |service_instance|
        Thread.pass
        service_plan_id = service_instance[:service_plan_id]
        next if service_plan_id.nil?
        service_plan = service_plan_hash[service_plan_id]
        next if service_plan.nil?
        service = service_hash[service_plan[:service_id]]
        next if service.nil?
        service_broker_id = service[:service_broker_id]
        next if service_broker_id.nil?
        service_instance_counters[service_broker_id] = 0 if service_instance_counters[service_broker_id].nil?
        service_instance_counters[service_broker_id] += 1
      end

      items = []
      hash  = {}

      service_brokers['items'].each do |service_broker|
        Thread.pass

        row = []

        row.push(service_broker[:name])
        row.push(service_broker[:guid])
        row.push(service_broker[:created_at].to_datetime.rfc3339)

        if service_broker[:updated_at]
          row.push(service_broker[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        if service_counters[service_broker[:id]]
          row.push(service_counters[service_broker[:id]])
        elsif services_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_plan_counters[service_broker[:id]]
          row.push(service_plan_counters[service_broker[:id]])
        elsif service_plans_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_instance_counters[service_broker[:id]]
          row.push(service_instance_counters[service_broker[:id]])
        elsif service_instances_connected
          row.push(0)
        else
          row.push(nil)
        end

        items.push(row)

        hash[service_broker[:guid]] = service_broker
      end

      result(true, items, hash, (0..6).to_a, (0..3).to_a)
    end
  end
end
