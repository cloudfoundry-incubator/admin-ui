require_relative 'base_view_model'
require 'date'
require 'thread'

module AdminUI
  class ApprovalsViewModel < AdminUI::BaseViewModel
    def do_items
      approvals = @cc.approvals
      users     = @cc.users_uaa

      # approvals and users have to exist.  Other record types are optional
      return result unless approvals['connected'] &&
                           users['connected']

      user_hash = Hash[users['items'].map { |item| [item[:id], item] }]

      items = []
      hash  = {}

      approvals['items'].each do |approval|
        return result unless @running
        Thread.pass

        user = user_hash[approval[:user_id]]

        next if user.nil?

        row = []

        row.push(user[:username])
        row.push(approval[:user_id])
        row.push(approval[:client_id])
        row.push(approval[:scope])
        row.push(approval[:status])
        row.push(approval[:lastmodifiedat].to_datetime.rfc3339)
        row.push(approval[:expiresat].to_datetime.rfc3339)

        items.push(row)

        hash["#{approval[:user_id]}/#{approval[:client_id]}/#{approval[:scope]}"] =
          {
            'approval' => approval,
            'user_uaa' => user
          }
      end

      result(true, items, hash, (0..6).to_a, (0..6).to_a)
    end
  end
end
