require 'cgi'
require 'date'
require_relative 'base_view_model'

module AdminUI
  class ApprovalsViewModel < AdminUI::BaseViewModel
    def do_items
      approvals = @cc.approvals
      users     = @cc.users_uaa

      # approvals and users have to exist. Other record types are optional
      return result unless approvals['connected'] &&
                           users['connected']

      identity_zones = @cc.identity_zones

      identity_zone_hash = identity_zones['items'].map { |item| [item[:id], item] }.to_h
      user_hash          = users['items'].map { |item| [item[:id], item] }.to_h

      items = []
      hash  = {}

      approvals['items'].each do |approval|
        return result unless @running

        Thread.pass

        user = user_hash[approval[:user_id]]

        next if user.nil?

        identity_zone = identity_zone_hash[approval[:identity_zone_id]]

        row = []

        if identity_zone
          row.push(identity_zone[:name])
        else
          row.push(nil)
        end

        row.push(user[:username])
        row.push(approval[:user_id])
        row.push(approval[:client_id])
        row.push(approval[:scope])
        row.push(approval[:status])
        row.push(approval[:lastmodifiedat].to_datetime.rfc3339)
        row.push(approval[:expiresat].to_datetime.rfc3339)

        # We need an additional escaped client id for retrieval
        row.push(CGI.escape(approval[:client_id]))

        items.push(row)

        hash["#{approval[:user_id]}/#{approval[:client_id]}/#{approval[:scope]}"] =
          {
            'approval'      => approval,
            'identity_zone' => identity_zone,
            'user_uaa'      => user
          }
      end

      result(true, items, hash, (0..7).to_a, (0..7).to_a)
    end
  end
end
