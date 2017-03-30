require 'date'
require 'thread'
require_relative 'base_view_model'

module AdminUI
  class ServiceBindingsViewModel < AdminUI::BaseViewModel
    def do_items
      service_bindings = @cc.service_bindings

      # service_bindings have to exist.  Other record types are optional
      return result unless service_bindings['connected']

      applications      = @cc.applications
      events            = @cc.events
      organizations     = @cc.organizations
      service_brokers   = @cc.service_brokers
      service_instances = @cc.service_instances
      service_plans     = @cc.service_plans
      services          = @cc.services
      spaces            = @cc.spaces

      events_connected = events['connected']

      application_hash      = Hash[applications['items'].map { |item| [item[:guid], item] }]
      organization_hash     = Hash[organizations['items'].map { |item| [item[:id], item] }]
      service_broker_hash   = Hash[service_brokers['items'].map { |item| [item[:id], item] }]
      service_instance_hash = Hash[service_instances['items'].map { |item| [item[:guid], item] }]
      service_plan_hash     = Hash[service_plans['items'].map { |item| [item[:id], item] }]
      service_hash          = Hash[services['items'].map { |item| [item[:id], item] }]
      space_hash            = Hash[spaces['items'].map { |item| [item[:id], item] }]

      event_counters = {}
      events['items'].each do |event|
        return result unless @running
        Thread.pass

        next unless event[:actee_type] == 'service_binding'
        actee = event[:actee]
        event_counters[actee] = 0 if event_counters[actee].nil?
        event_counters[actee] += 1
      end

      items = []
      hash  = {}

      service_bindings['items'].each do |service_binding|
        return result unless @running
        Thread.pass

        guid             = service_binding[:guid]
        application      = application_hash[service_binding[:app_guid]]
        service_instance = service_instance_hash[service_binding[:service_instance_guid]]
        service_plan_id  = service_instance.nil? ? nil : service_instance[:service_plan_id]
        service_plan     = service_plan_id.nil? ? nil : service_plan_hash[service_plan_id]
        service          = service_plan.nil? ? nil : service_hash[service_plan[:service_id]]
        service_broker   = service.nil? || service[:service_broker_id].nil? ? nil : service_broker_hash[service[:service_broker_id]]
        space            = service_instance.nil? ? nil : space_hash[service_instance[:space_id]]
        organization     = space.nil? ? nil : organization_hash[space[:organization_id]]

        event_counter = event_counters[guid]

        row = []

        row.push(guid)
        row.push(guid)
        row.push(service_binding[:created_at].to_datetime.rfc3339)

        if service_binding[:updated_at]
          row.push(service_binding[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        row.push(!service_binding[:syslog_drain_url].nil? && service_binding[:syslog_drain_url].length.positive?)
        row.push(!service_binding[:volume_mounts_salt].nil?)

        if event_counter
          row.push(event_counter)
        elsif events_connected
          row.push(0)
        else
          row.push(nil)
        end

        if application
          row.push(application[:name])
          row.push(application[:guid])
        else
          row.push(nil, nil)
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
            'application'      => application,
            'organization'     => organization,
            'service'          => service,
            'service_binding'  => service_binding.reject { |key, _| key == :volume_mounts_salt },
            'service_broker'   => service_broker,
            'service_instance' => service_instance,
            'service_plan'     => service_plan,
            'space'            => space
          }
      end

      result(true, items, hash, (1..31).to_a, (1..31).to_a - [6])
    end
  end
end
