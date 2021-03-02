require 'date'
require_relative 'base_view_model'

module AdminUI
  class EventsViewModel < AdminUI::BaseViewModel
    def do_items
      events = @cc.events

      # events have to exist
      return result unless events['connected']

      spaces        = @cc.spaces
      organizations = @cc.organizations

      organization_guid_hash = organizations['items'].map { |item| [item[:guid], item] }.to_h
      organization_id_hash   = organizations['items'].map { |item| [item[:id], item] }.to_h
      space_guid_hash        = spaces['items'].map { |item| [item[:guid], item] }.to_h
      space_id_hash          = spaces['items'].map { |item| [item[:id], item] }.to_h

      items = []
      hash  = {}

      events['items'].each do |event|
        return result unless @running

        Thread.pass

        space        = space_id_hash[event[:space_id]]
        space        = space_guid_hash[event[:space_guid]] if space.nil? && event[:space_guid] && event[:space_guid] != ''
        organization = space.nil? ? nil : organization_id_hash[space[:organization_id]]
        organization = organization_guid_hash[event[:organization_guid]] if organization.nil? && event[:organization_guid] && event[:organization_guid] != ''

        row = []

        row.push(event[:timestamp].to_datetime.rfc3339)
        row.push(event[:guid])
        row.push(event[:type])
        row.push(event[:actee_type])
        row.push(event[:actee_name])
        row.push(event[:actee])
        row.push(event[:actor_type])
        row.push(event[:actor_username])
        row.push(event[:actor_name])
        row.push(event[:actor])

        if organization
          if space
            row.push("#{organization[:name]}/#{space[:name]}")
          else
            row.push("#{organization[:name]}/")
          end
        else
          row.push(nil)
        end

        items.push(row)

        hash[event[:guid]] =
          {
            'event'        => event,
            'organization' => organization,
            'space'        => space
          }
      end

      result(true, items, hash, (0..10).to_a, (0..10).to_a)
    end
  end
end
