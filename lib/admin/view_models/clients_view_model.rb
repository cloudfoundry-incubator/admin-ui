require_relative 'base'
require 'thread'

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

      events = @cc.events

      events_connected = events['connected']

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
            json = JSON.parse(client[:additional_information])
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

        items.push(row)

        hash[client_id] = client
      end

      result(true, items, hash, (0..6).to_a, (0..5).to_a)
    end
  end
end
