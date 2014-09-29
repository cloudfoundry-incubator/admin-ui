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

      applications     = @cc.applications
      organizations    = @cc.organizations
      service_brokers  = @cc.service_brokers
      service_bindings = @cc.service_bindings
      service_plans    = @cc.service_plans
      services         = @cc.services
      spaces           = @cc.spaces

      applications_connected     = applications['connected']
      service_bindings_connected = service_bindings['connected']

      application_hash     = Hash[*applications['items'].map { |item| [item[:id], item] }.flatten]
      organization_hash    = Hash[*organizations['items'].map { |item| [item[:id], item] }.flatten]
      service_broker_hash  = Hash[*service_brokers['items'].map { |item| [item[:id], item] }.flatten]
      service_plan_hash    = Hash[*service_plans['items'].map { |item| [item[:id], item] }.flatten]
      service_hash         = Hash[*services['items'].map { |item| [item[:id], item] }.flatten]
      space_hash           = Hash[*spaces['items'].map { |item| [item[:id], item] }.flatten]

      service_binding_apps_hash = {}
      if service_bindings_connected && applications_connected
        service_bindings['items'].each do |service_binding|
          Thread.pass
          service_instance_id = service_binding[:service_instance_id]
          app_and_binding_array = service_binding_apps_hash[service_instance_id]
          if app_and_binding_array.nil?
            app_and_binding_array = []
            service_binding_apps_hash[service_instance_id] = app_and_binding_array
          end

          application = application_hash[service_binding[:app_id]]

          if application
            app_and_binding_array.push('application'    => application,
                                       'serviceBinding' => service_binding)
          end
        end
      end

      items = []

      service_instances['items'].each do |service_instance|
        Thread.pass
        service_plan   = service_plan_hash[service_instance[:service_plan_id]]
        service        = service_plan.nil? ? nil : service_hash[service_plan[:service_id]]
        service_broker = service.nil? || service[:service_broker_id].nil? ? nil : service_broker_hash[service[:service_broker_id]]
        space          = space_hash[service_instance[:space_id]]
        organization   = space.nil? ? nil : organization_hash[space[:organization_id]]

        row = []

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
        else
          row.push(nil, nil, nil, nil, nil)
        end

        if service_plan
          row.push(service_plan[:name])
          row.push(service_plan[:created_at].to_datetime.rfc3339)

          if service_plan[:updated_at]
            row.push(service_plan[:updated_at].to_datetime.rfc3339)
          else
            row.push(nil)
          end

          row.push(service_plan[:public])

          service_plan_target = ''
          if service
            service_plan_target = service[:provider] if service[:provider]
            service_plan_target += "/#{ service[:label] }/"
          end

          service_plan_target += service_plan[:name]

          row.push(service_plan_target)
        else
          row.push(nil, nil, nil, nil, nil)
        end

        row.push(service_instance[:name])
        row.push(service_instance[:created_at].to_datetime.rfc3339)

        if service_instance[:updated_at]
          row.push(service_instance[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        service_binding_apps = service_binding_apps_hash[service_instance[:id]]

        if service_binding_apps
          row.push(service_binding_apps.length)
        elsif service_bindings_connected && applications_connected
          row.push(0)
        else
          row.push(nil)
        end

        if organization && space
          row.push("#{ organization[:name] }/#{ space[:name] }")
        else
          row.push(nil)
        end

        row.push('bindingsAndApplications' => service_binding_apps,
                 'organization'            => organization,
                 'service'                 => service,
                 'serviceBroker'           => service_broker,
                 'serviceInstance'         => service_instance,
                 'servicePlan'             => service_plan,
                 'space'                   => space)

        items.push(row)
      end

      result(items, (0..17).to_a, (0..15).to_a << 17)
    end
  end
end
