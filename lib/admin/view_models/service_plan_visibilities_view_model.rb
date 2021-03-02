require 'date'
require_relative 'base_view_model'

module AdminUI
  class ServicePlanVisibilitiesViewModel < AdminUI::BaseViewModel
    def do_items
      organizations             = @cc.organizations
      service_plans             = @cc.service_plans
      service_plan_visibilities = @cc.service_plan_visibilities

      # organizations, service_plans and service_plan_visibilities have to exist. Other record types are optional
      return result unless organizations['connected'] &&
                           service_plans['connected'] &&
                           service_plan_visibilities['connected']

      events          = @cc.events
      service_brokers = @cc.service_brokers
      services        = @cc.services

      events_connected = events['connected']

      organization_hash   = organizations['items'].map { |item| [item[:id], item] }.to_h
      service_broker_hash = service_brokers['items'].map { |item| [item[:id], item] }.to_h
      service_plan_hash   = service_plans['items'].map { |item| [item[:id], item] }.to_h
      service_hash        = services['items'].map { |item| [item[:id], item] }.to_h

      items = []
      hash  = {}

      event_counters = {}
      events['items'].each do |event|
        return result unless @running

        Thread.pass

        next unless event[:actee_type] == 'service_plan_visibility'

        actee = event[:actee]
        event_counters[actee] = 0 if event_counters[actee].nil?
        event_counters[actee] += 1
      end

      service_plan_visibilities['items'].each do |service_plan_visibility|
        return result unless @running

        Thread.pass

        organization = organization_hash[service_plan_visibility[:organization_id]]
        next if organization.nil?

        service_plan = service_plan_hash[service_plan_visibility[:service_plan_id]]
        next if service_plan.nil?

        guid           = service_plan_visibility[:guid]
        service        = service_plan.nil? ? nil : service_hash[service_plan[:service_id]]
        service_broker = service.nil? || service[:service_broker_id].nil? ? nil : service_broker_hash[service[:service_broker_id]]
        event_counter  = event_counters[guid]

        row = []

        key = "#{guid}/#{service_plan[:guid]}/#{organization[:guid]}"

        row.push(key)
        row.push(guid)
        row.push(service_plan_visibility[:created_at].to_datetime.rfc3339)

        if service_plan_visibility[:updated_at]
          row.push(service_plan_visibility[:updated_at].to_datetime.rfc3339)
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

        row.push(service_plan[:name])
        row.push(service_plan[:guid])
        row.push(service_plan[:unique_id])
        row.push(service_plan[:created_at].to_datetime.rfc3339)

        if service_plan[:updated_at]
          row.push(service_plan[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        row.push(service_plan[:bindable])
        row.push(service_plan[:free])
        row.push(service_plan[:active])
        row.push(service_plan[:public])

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

          row.push(service[:bindable])
          row.push(service[:active])
        else
          row.push(nil, nil, nil, nil, nil, nil, nil)
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

        row.push(organization[:name])
        row.push(organization[:guid])

        row.push(organization[:created_at].to_datetime.rfc3339)

        if organization[:updated_at]
          row.push(organization[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        items.push(row)

        hash[key] =
          {
            'organization'            => organization,
            'service'                 => service,
            'service_broker'          => service_broker,
            'service_plan'            => service_plan,
            'service_plan_visibility' => service_plan_visibility
          }
      end

      result(true, items, hash, (1..28).to_a, (1..28).to_a - [4])
    end
  end
end
