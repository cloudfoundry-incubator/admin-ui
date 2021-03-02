require 'cgi'
require 'yajl'
require_relative 'base_view_model'

module AdminUI
  class ClientsViewModel < AdminUI::BaseViewModel
    def do_items
      clients = @cc.clients

      # clients have to exist
      return result unless clients['connected']

      approvals                 = @cc.approvals
      events                    = @cc.events
      identity_zones            = @cc.identity_zones
      revocable_tokens          = @cc.revocable_tokens
      service_brokers           = @cc.service_brokers
      service_dashboard_clients = @cc.service_dashboard_clients

      approvals_connected        = approvals['connected']
      events_connected           = events['connected']
      revocable_tokens_connected = revocable_tokens['connected']

      identity_zone_hash            = identity_zones['items'].map { |item| [item[:id], item] }.to_h
      service_broker_hash           = service_brokers['items'].map { |item| [item[:id], item] }.to_h
      service_dashboard_client_hash = service_dashboard_clients['items'].map { |item| [item[:uaa_id], item] }.to_h

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
          # A user actor_type is used for a client. But, the actor_name is nil in this case
          next unless event[:actor_name].nil?

          actor = event[:actor]
          event_counters[actor] = 0 if event_counters[actor].nil?
          event_counters[actor] += 1
        end
      end

      approval_counters = {}
      approvals['items'].each do |approval|
        return result unless @running

        Thread.pass

        client_id = approval[:client_id]
        approval_counters[client_id] = 0 if approval_counters[client_id].nil?
        approval_counters[client_id] += 1
      end

      revocable_token_counters = {}
      revocable_tokens['items'].each do |revocable_token|
        return result unless @running

        Thread.pass

        client_id = revocable_token[:client_id]
        revocable_token_counters[client_id] = 0 if revocable_token_counters[client_id].nil?
        revocable_token_counters[client_id] += 1
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

        approval_counter        = approval_counters[client_id]
        event_counter           = event_counters[client_id]
        revocable_token_counter = revocable_token_counters[client_id]

        row = []

        row.push(CGI.escape(client_id))

        if identity_zone
          row.push(identity_zone[:name])
        else
          row.push(nil)
        end

        row.push(client_id)

        if client[:lastmodified]
          row.push(client[:lastmodified].to_datetime.rfc3339)
        else
          row.push(nil)
        end

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
        if client[:autoapprove].present?
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

        if client[:required_user_groups]
          row.push(client[:required_user_groups].split(',').sort)
        else
          row.push(nil)
        end

        row.push(client[:access_token_validity])
        row.push(client[:refresh_token_validity])

        if event_counter
          row.push(event_counter)
        elsif events_connected
          row.push(0)
        else
          row.push(nil)
        end

        if approval_counter
          row.push(approval_counter)
        elsif approvals_connected
          row.push(0)
        else
          row.push(nil)
        end

        if revocable_token_counter
          row.push(revocable_token_counter)
        elsif revocable_tokens_connected
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

      result(true, items, hash, (1..15).to_a, [1, 2, 3, 4, 5, 6, 7, 8, 9, 15])
    end
  end
end
