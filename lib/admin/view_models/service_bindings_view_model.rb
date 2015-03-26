require_relative 'base'
require 'date'
require 'thread'

module AdminUI
  class ServiceBindingsViewModel < AdminUI::Base
    def initialize(logger, cc)
      super(logger)

      @cc = cc
    end

    def do_items
      service_bindings = @cc.service_bindings

      # service_bindings have to exist.  Other record types are optional
      return result unless service_bindings['connected']

      applications      = @cc.applications
      organizations     = @cc.organizations
      service_brokers   = @cc.service_brokers
      service_instances = @cc.service_instances
      service_plans     = @cc.service_plans
      services          = @cc.services
      spaces            = @cc.spaces

      application_hash      = Hash[applications['items'].map { |item| [item[:id], item] }]
      organization_hash     = Hash[organizations['items'].map { |item| [item[:id], item] }]
      service_broker_hash   = Hash[service_brokers['items'].map { |item| [item[:id], item] }]
      service_instance_hash = Hash[service_instances['items'].map { |item| [item[:id], item] }]
      service_plan_hash     = Hash[service_plans['items'].map { |item| [item[:id], item] }]
      service_hash          = Hash[services['items'].map { |item| [item[:id], item] }]
      space_hash            = Hash[spaces['items'].map { |item| [item[:id], item] }]

      items = []
      hash  = {}

      service_bindings['items'].each do |service_binding|
        Thread.pass
        application      = application_hash[service_binding[:app_id]]
        service_instance = service_instance_hash[service_binding[:service_instance_id]]
        service_plan_id  = service_instance.nil? ? nil : service_instance[:service_plan_id]
        service_plan     = service_plan_id.nil? ? nil : service_plan_hash[service_plan_id]
        service          = service_plan.nil? ? nil : service_hash[service_plan[:service_id]]
        service_broker   = service.nil? || service[:service_broker_id].nil? ? nil : service_broker_hash[service[:service_broker_id]]
        space            = service_instance.nil? ? nil : space_hash[service_instance[:space_id]]
        organization     = space.nil? ? nil : organization_hash[space[:organization_id]]

        row = []

        row.push(service_binding[:guid])
        row.push(service_binding[:created_at].to_datetime.rfc3339)

        if service_binding[:updated_at]
          row.push(service_binding[:updated_at].to_datetime.rfc3339)
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

          row.push(service_plan[:active])
          row.push(service_plan[:public])
          row.push(service_plan[:free])
        else
          row.push(nil, nil, nil, nil, nil, nil, nil, nil)
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

        if organization && space
          row.push("#{ organization[:name] }/#{ space[:name] }")
        else
          row.push(nil)
        end

        items.push(row)

        hash[service_binding[:guid]] =
        {
          'application'      => application,
          'organization'     => organization,
          'service'          => service,
          'service_binding'  => service_binding,
          'service_broker'   => service_broker,
          'service_instance' => service_instance,
          'service_plan'     => service_plan,
          'space'            => space
        }
      end

      result(true, items, hash, (0..29).to_a, (0..29).to_a)
    end
  end
end
