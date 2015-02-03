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

      items = []
      hash  = {}

      clients['items'].each do |client|
        Thread.pass
        row = []

        row.push(client[:client_id])

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

        items.push(row)

        hash[client[:client_id]] = client
      end

      result(true, items, hash, (0..5).to_a, (0..5).to_a)
    end
  end
end
