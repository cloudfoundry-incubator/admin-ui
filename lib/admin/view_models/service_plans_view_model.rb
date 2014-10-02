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

      organizations             = @cc.organizations
      services                  = @cc.services
      service_brokers           = @cc.service_brokers
      service_instances         = @cc.service_instances
      service_plan_visibilities = @cc.service_plan_visibilities

      organizations_connected             = organizations['connected']
      service_instances_connected         = service_instances['connected']
      service_plan_visibilities_connected = service_plan_visibilities['connected']

      organization_hash   = Hash[organizations['items'].map { |item| [item[:id], item] }]
      service_broker_hash = Hash[service_brokers['items'].map { |item| [item[:id], item] }]
      service_hash        = Hash[services['items'].map { |item| [item[:id], item] }]

      service_plan_visibilities_organizations_hash = {}
      if service_plan_visibilities_connected && organizations_connected
        service_plan_visibilities['items'].each do |service_plan_visibility|
          Thread.pass
          service_plan_id = service_plan_visibility[:service_plan_id]
          service_plan_visibility_and_organization_array = service_plan_visibilities_organizations_hash[service_plan_id]
          if service_plan_visibility_and_organization_array.nil?
            service_plan_visibility_and_organization_array = []
            service_plan_visibilities_organizations_hash[service_plan_id] = service_plan_visibility_and_organization_array
          end

          organization = organization_hash[service_plan_visibility[:organization_id]]

          if organization
            service_plan_visibility_and_organization_array.push('organization'          => organization,
                                                                'servicePlanVisibility' => service_plan_visibility)
          end
        end
      end

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
        row.push(service_plan[:guid])

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

        service_plan_visibilities_organizations = service_plan_visibilities_organizations_hash[service_plan[:id]]

        if service_plan_visibilities_organizations
          row.push(service_plan_visibilities_organizations.length)
        elsif service_plan_visibilities_connected && organizations_connected
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

        if service
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
        else
          row.push(nil, nil, nil, nil, nil, nil, nil, nil)
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

        row.push('service'                                 => service,
                 'serviceBroker'                           => service_broker,
                 'servicePlan'                             => service_plan,
                 'servicePlanVisibilitiesAndOrganizations' => service_plan_visibilities_organizations)

        items.push(row)
      end

      result(items, (1..20).to_a, (1..20).to_a - [7, 8])
    end
  end
end
