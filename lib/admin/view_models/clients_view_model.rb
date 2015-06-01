require 'thread'
require 'yajl'
require_relative 'base'

module AdminUI
  class ClientsViewModel < AdminUI::Base
    def initialize(logger, cc)
      super(logger)

      @cc = cc
    end

    def do_items
      clients = @cc.clients

      # clients have to exist
      return result unless clients['connected']

      events                    = @cc.events
      service_brokers           = @cc.service_brokers
      service_dashboard_clients = @cc.service_dashboard_clients

      events_connected = events['connected']

      service_broker_hash           = Hash[service_brokers['items'].map { |item| [item[:id], item] }]
      service_dashboard_client_hash = Hash[service_dashboard_clients['items'].map { |item| [item[:uaa_id], item] }]

      event_counters = {}
      events['items'].each do |event|
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
        Thread.pass

        client_id = client[:client_id]

        service_dashboard_client = service_dashboard_client_hash[client_id]
        service_broker           = service_dashboard_client.nil? ? nil : service_broker_hash[service_dashboard_client[:service_broker_id]]

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

        items.push(row)

        hash[client_id] =
        {
          'client'         => client,
          'service_broker' => service_broker
        }
      end

      result(true, items, hash, (0..7).to_a, (0..5).to_a << 7)
    end
  end
end
