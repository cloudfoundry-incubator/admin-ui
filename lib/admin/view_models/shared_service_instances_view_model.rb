require 'date'
require_relative 'base_view_model'

module AdminUI
  class SharedServiceInstancesViewModel < AdminUI::BaseViewModel
    def do_items
      service_instance_shares = @cc.service_instance_shares

      # service_instance_shares have to exist. Other record types are optional
      return result unless service_instance_shares['connected']

      organizations     = @cc.organizations
      service_brokers   = @cc.service_brokers
      service_instances = @cc.service_instances
      service_plans     = @cc.service_plans
      services          = @cc.services
      spaces            = @cc.spaces

      organization_hash     = organizations['items'].map { |item| [item[:id], item] }.to_h
      service_broker_hash   = service_brokers['items'].map { |item| [item[:id], item] }.to_h
      service_instance_hash = service_instances['items'].map { |item| [item[:guid], item] }.to_h
      service_plan_hash     = service_plans['items'].map { |item| [item[:id], item] }.to_h
      service_hash          = services['items'].map { |item| [item[:id], item] }.to_h
      space_guid_hash       = spaces['items'].map { |item| [item[:guid], item] }.to_h
      space_id_hash         = spaces['items'].map { |item| [item[:id], item] }.to_h

      items = []
      hash  = {}

      service_instance_shares['items'].each do |service_instance_share|
        return result unless @running

        Thread.pass

        service_instance_guid = service_instance_share[:service_instance_guid]
        target_space_guid     = service_instance_share[:target_space_guid]

        service_instance      = service_instance_hash[service_instance_guid]
        service_plan_id       = service_instance.nil? ? nil : service_instance[:service_plan_id]
        service_plan          = service_plan_id.nil? ? nil : service_plan_hash[service_plan_id]
        service               = service_plan.nil? ? nil : service_hash[service_plan[:service_id]]
        service_broker        = service.nil? || service[:service_broker_id].nil? ? nil : service_broker_hash[service[:service_broker_id]]
        source_space          = service_instance.nil? ? nil : space_id_hash[service_instance[:space_id]]
        source_organization   = source_space.nil? ? nil : organization_hash[source_space[:organization_id]]
        target_space          = space_guid_hash[target_space_guid]
        target_organization   = target_space.nil? ? nil : organization_hash[target_space[:organization_id]]

        key = "#{service_instance_guid}/#{target_space_guid}"

        row = []

        row.push(key)

        if service_instance
          row.push(service_instance[:name])
        else
          row.push(nil)
        end

        row.push(service_instance_guid)

        if service_instance
          row.push(service_instance[:created_at].to_datetime.rfc3339)

          if service_instance[:updated_at]
            row.push(service_instance[:updated_at].to_datetime.rfc3339)
          else
            row.push(nil)
          end
        else
          row.push(nil, nil)
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

          row.push(service_plan[:bindable])
          row.push(service_plan[:free])
          row.push(service_plan[:active])
          row.push(service_plan[:public])
        else
          row.push(nil, nil, nil, nil, nil, nil, nil, nil, nil)
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

        if source_organization && source_space
          row.push("#{source_organization[:name]}/#{source_space[:name]}")
        else
          row.push(nil)
        end

        if target_organization && target_space
          row.push("#{target_organization[:name]}/#{target_space[:name]}")
        else
          row.push(nil)
        end
        items.push(row)

        hash[key] =
          {
            'service'                => service,
            'service_broker'         => service_broker,
            'service_instance'       => service_instance,
            'service_instance_share' => service_instance_share,
            'service_plan'           => service_plan,
            'source_organization'    => source_organization,
            'source_space'           => source_space,
            'target_organization'    => target_organization,
            'target_space'           => target_space
          }
      end

      result(true, items, hash, (1..26).to_a, (1..26).to_a)
    end
  end
end
