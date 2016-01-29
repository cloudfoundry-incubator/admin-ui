require 'thread'
require 'yajl'
require_relative 'base_view_model'

module AdminUI
  class ClientsViewModel < AdminUI::BaseViewModel
    def do_items
      clients = @cc.clients

      # clients have to exist
      return result unless clients['connected']

      events                    = @cc.events
      identity_zones            = @cc.identity_zones
      service_brokers           = @cc.service_brokers
      service_dashboard_clients = @cc.service_dashboard_clients

      events_connected = events['connected']

      identity_zone_hash            = Hash[identity_zones['items'].map { |item| [item[:id], item] }]
      service_broker_hash           = Hash[service_brokers['items'].map { |item| [item[:id], item] }]
      service_dashboard_client_hash = Hash[service_dashboard_clients['items'].map { |item| [item[:uaa_id], item] }]

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

        identity_zone            = identity_zone_hash[client[:identity_zone_id]]
        service_dashboard_client = service_dashboard_client_hash[client_id]
        service_broker           = service_dashboard_client.nil? ? nil : service_broker_hash[service_dashboard_client[:service_broker_id]]

        event_counter = event_counters[client_id]

        row = []

        row.push(client_id)

        if identity_zone
          row.push(identity_zone[:name])
        else
          row.push(nil)
        end

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

        # Have to deal with both the old additional_information and the new autoapprove fields
        autoapprove = nil
        if client[:autoapprove] && client[:autoapprove].length > 0
          autoapprove = client[:autoapprove].split(',').sort
        elsif client[:additional_information]
          begin
            json = Yajl::Parser.parse(client[:additional_information])
            json_autoapprove = json['autoapprove']
            autoapprove = [json_autoapprove.to_s] unless json_autoapprove.nil?
          rescue
            autoapprove = nil
          end
        end
        row.push(autoapprove)

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

        items.push(row)

        hash[client_id] =
          {
            'client'         => client,
            'identity_zone'  => identity_zone,
            'service_broker' => service_broker
          }
      end

      result(true, items, hash, (1..9).to_a, (1..7).to_a << 9)
    end
  end
end
