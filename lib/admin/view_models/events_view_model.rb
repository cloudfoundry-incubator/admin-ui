require_relative 'base'
require 'thread'

module AdminUI
  class EventsViewModel < AdminUI::Base
    def initialize(logger, cc)
      super(logger)

      @cc = cc
    end

    def do_items
      events = @cc.events

      # events have to exist
      return result unless events['connected']

      spaces        = @cc.spaces
      organizations = @cc.organizations

      organization_hash = Hash[organizations['items'].map { |item| [item[:id], item] }]
      space_hash        = Hash[spaces['items'].map { |item| [item[:id], item] }]

      items = []
      hash  = {}

      events['items'].each do |event|
        Thread.pass
        space        = space_hash[event[:space_id]]
        organization = space.nil? ? nil : organization_hash[space[:organization_id]]

        row = []

        row.push(event[:timestamp].to_datetime.rfc3339)
        row.push(event[:guid])
        row.push(event[:type])
        row.push(event[:actee_type])
        row.push(event[:actee_name])
        row.push(event[:actee])
        row.push(event[:actor_type])
        row.push(event[:actor_name])
        row.push(event[:actor])

        if organization && space
          row.push("#{ organization[:name] }/#{ space[:name] }")
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

      result(true, items, hash, (0..9).to_a, (0..9).to_a)
    end
  end
end
