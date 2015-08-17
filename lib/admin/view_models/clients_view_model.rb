require 'thread'
require 'yajl'
require_relative 'base_view_model'

module AdminUI
  class ClientsViewModel < AdminUI::BaseViewModel
    def do_items
      clients = @cc.clients

      # clients have to exist
      return result unless clients['connected']

      events                             = @cc.events
      organizations                      = @cc.organizations
      service_brokers                    = @cc.service_brokers
      service_dashboard_clients          = @cc.service_dashboard_clients
      service_instances                  = @cc.service_instances
      service_instance_dashboard_clients = @cc.service_instance_dashboard_clients
      spaces                             = @cc.spaces

      events_connected = events['connected']

      organization_hash                      = Hash[organizations['items'].map { |item| [item[:id], item] }]
      service_broker_hash                    = Hash[service_brokers['items'].map { |item| [item[:id], item] }]
      service_dashboard_client_hash          = Hash[service_dashboard_clients['items'].map { |item| [item[:uaa_id], item] }]
      service_instance_hash                  = Hash[service_instances['items'].map { |item| [item[:id], item] }]
      service_instance_dashboard_client_hash = Hash[service_instance_dashboard_clients['items'].map { |item| [item[:uaa_id], item] }]
      space_hash                             = Hash[spaces['items'].map { |item| [item[:id], item] }]

      event_counters = {}
      events['items'].each do |event|
        return result unless @running
        Thread.pass

        if event[:actee_type] == 'service_dashboard_client'
          actee = event[:actee]
          event_counters[actee] = 0 if event_counters[actee].nil?
          event_counters[actee] += 1
        else
          next unless event[:actor_type] == 'user'
          # A user actor_type is used for a client.  But, the actor_name is nil in this case
          next unless event[:actor_name].nil?
          actor = event[:actor]
          event_counters[actor] = 0 if event_counters[actor].nil?
          event_counters[actor] += 1
        end
      end

      items = []
      hash  = {}

      clients['items'].each do |client|
        return result unless @running
        Thread.pass

        client_id = client[:client_id]

        service_dashboard_client          = service_dashboard_client_hash[client_id]
        service_broker                    = service_dashboard_client.nil? ? nil : service_broker_hash[service_dashboard_client[:service_broker_id]]
        service_instance_dashboard_client = service_instance_dashboard_client_hash[client_id]
        service_instance                  = service_instance_dashboard_client.nil? ? nil : service_instance_hash[service_instance_dashboard_client[:managed_service_instance_id]]
        space                             = service_instance.nil? ? nil : space_hash[service_instance[:space_id]]
        organization                      = space.nil? ? nil : organization_hash[space[:organization_id]]

        event_counter = event_counters[client_id]

        row = []

        row.push(client_id)

        if client[:scope]
          row.push(client[:scope].split(',').sort)
        else
          row.push(nil)
        end

        if client[:authorized_grant_types]
          row.push(client[:authorized_grant_types].split(',').sort)
        else
          row.push(nil)
        end

        if client[:web_server_redirect_uri]
          row.push(client[:web_server_redirect_uri].split(',').sort)
        else
          row.push(nil)
        end

        if client[:authorities]
          row.push(client[:authorities].split(',').sort)
        else
          row.push(nil)
        end

        if client[:additional_information]
          begin
            json = Yajl::Parser.parse(client[:additional_information])
            row.push(json['autoapprove'])
          rescue
            row.push(nil)
          end
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

        if service_broker
          row.push(service_broker[:name])
        else
          row.push(nil)
        end

        if service_instance
          row.push(service_instance[:name])
        else
          row.push(nil)
        end

        if organization && space
          row.push("#{organization[:name]}/#{space[:name]}")
        else
          row.push(nil)
        end

        items.push(row)

        hash[client_id] =
        {
          'client'           => client,
          'organization'     => organization,
          'service_broker'   => service_broker,
          'service_instance' => service_instance,
          'space'            => space
        }
      end

      result(true, items, hash, (0..9).to_a, (0..9).to_a - [6])
    end
  end
end
