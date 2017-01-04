require 'date'
require 'thread'
require_relative 'base_view_model'

module AdminUI
  class ServiceKeysViewModel < AdminUI::BaseViewModel
    def do_items
      service_keys = @cc.service_keys

      # service_keys have to exist.  Other record types are optional
      return result unless service_keys['connected']

      events            = @cc.events
      organizations     = @cc.organizations
      service_brokers   = @cc.service_brokers
      service_instances = @cc.service_instances
      service_plans     = @cc.service_plans
      services          = @cc.services
      spaces            = @cc.spaces

      events_connected = events['connected']

      organization_hash     = Hash[organizations['items'].map { |item| [item[:id], item] }]
      service_broker_hash   = Hash[service_brokers['items'].map { |item| [item[:id], item] }]
      service_instance_hash = Hash[service_instances['items'].map { |item| [item[:id], item] }]
      service_plan_hash     = Hash[service_plans['items'].map { |item| [item[:id], item] }]
      service_hash          = Hash[services['items'].map { |item| [item[:id], item] }]
      space_hash            = Hash[spaces['items'].map { |item| [item[:id], item] }]

      event_counters = {}
      events['items'].each do |event|
        return result unless @running
        Thread.pass

        next unless event[:actee_type] == 'service_key'
        actee = event[:actee]
        event_counters[actee] = 0 if event_counters[actee].nil?
        event_counters[actee] += 1
      end

      items = []
      hash  = {}

      service_keys['items'].each do |service_key|
        return result unless @running
        Thread.pass

        guid             = service_key[:guid]
        service_instance = service_instance_hash[service_key[:service_instance_id]]
        service_plan_id  = service_instance.nil? ? nil : service_instance[:service_plan_id]
        service_plan     = service_plan_id.nil? ? nil : service_plan_hash[service_plan_id]
        service          = service_plan.nil? ? nil : service_hash[service_plan[:service_id]]
        service_broker   = service.nil? || service[:service_broker_id].nil? ? nil : service_broker_hash[service[:service_broker_id]]
        space            = service_instance.nil? ? nil : space_hash[service_instance[:space_id]]
        organization     = space.nil? ? nil : organization_hash[space[:organization_id]]

        event_counter = event_counters[guid]

        row = []

        row.push(guid)
        row.push(service_key[:name])
        row.push(guid)
        row.push(service_key[:created_at].to_datetime.rfc3339)

        if service_key[:updated_at]
          row.push(service_key[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        if event_counter
          row.push(event_counter)
        elsif events_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_instance
          row.push(service_instance[:name])
          row.push(service_instance[:guid])
          row.push(service_instance[:created_at].to_datetime.rfc3339)

          if service_instance[:updated_at]
            row.push(service_instance[:updated_at].to_datetime.rfc3339)
          else
            row.push(nil)
          end
        else
          row.push(nil, nil, nil, nil)
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

          row.push(service_plan[:free])
          row.push(service_plan[:active])
          row.push(service_plan[:public])
        else
          row.push(nil, nil, nil, nil, nil, nil, nil, nil)
        end

        if service
          row.push(service[:label])
          row.push(service[:guid])
          row.push(service[:unique_id])
          row.push(service[:created_at].to_datetime.rfc3339)

          if service[:updated_at]
            row.push(service[:updated_at].to_datetime.rfc3339)
          else
            row.push(nil)
          end

          row.push(service[:active])
        else
          row.push(nil, nil, nil, nil, nil, nil)
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
          row.push("#{organization[:name]}/#{space[:name]}")
        else
          row.push(nil)
        end

        items.push(row)

        hash[guid] =
          {
            'organization'     => organization,
            'service'          => service,
            'service_broker'   => service_broker,
            'service_instance' => service_instance,
            'service_key'      => service_key,
            'service_plan'     => service_plan,
            'space'            => space
          }
      end

      result(true, items, hash, (1..28).to_a, (1..28).to_a - [5])
    end
  end
end
