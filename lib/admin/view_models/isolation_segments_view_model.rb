require 'date'
require_relative 'base_view_model'

module AdminUI
  class IsolationSegmentsViewModel < AdminUI::BaseViewModel
    def do_items
      isolation_segments = @cc.isolation_segments

      # isolation_segments have to exist. Other record types are optional
      return result unless isolation_segments['connected']

      organizations                    = @cc.organizations
      organizations_isolation_segments = @cc.organizations_isolation_segments
      spaces                           = @cc.spaces

      organizations_connected                    = organizations['connected']
      organizations_isolation_segments_connected = organizations_isolation_segments['connected']
      spaces_connected                           = spaces['connected']

      organization_isolation_segment_counters = {}
      organization_counters                   = {}
      space_counters                          = {}

      organizations_isolation_segments['items'].each do |organization_isolation_segment|
        return result until @running
        Thread.pass

        isolation_segment_guid = organization_isolation_segment[:isolation_segment_guid]
        organization_isolation_segment_counters[isolation_segment_guid] = 0 if organization_isolation_segment_counters[isolation_segment_guid].nil?
        organization_isolation_segment_counters[isolation_segment_guid] += 1
      end

      organizations['items'].each do |organization|
        return result until @running
        Thread.pass

        default_isolation_segment_guid = organization[:default_isolation_segment_guid]
        next if default_isolation_segment_guid.nil?

        organization_counters[default_isolation_segment_guid] = 0 if organization_counters[default_isolation_segment_guid].nil?
        organization_counters[default_isolation_segment_guid] += 1
      end

      spaces['items'].each do |space|
        return result until @running
        Thread.pass

        isolation_segment_guid = space[:isolation_segment_guid]
        next if isolation_segment_guid.nil?

        space_counters[isolation_segment_guid] = 0 if space_counters[isolation_segment_guid].nil?
        space_counters[isolation_segment_guid] += 1
      end

      items = []
      hash  = {}

      isolation_segments['items'].each do |isolation_segment|
        return result unless @running
        Thread.pass

        guid = isolation_segment[:guid]

        organization_isolation_segment_counter = organization_isolation_segment_counters[guid]
        organization_counter                   = organization_counters[guid]
        space_counter                          = space_counters[guid]

        row = []

        row.push(guid)
        row.push(isolation_segment[:name])
        row.push(guid)
        row.push(isolation_segment[:created_at].to_datetime.rfc3339)

        if isolation_segment[:updated_at]
          row.push(isolation_segment[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        if organization_isolation_segment_counter
          row.push(organization_isolation_segment_counter)
        elsif organizations_isolation_segments_connected
          row.push(0)
        else
          row.push(nil)
        end

        if organization_counter
          row.push(organization_counter)
        elsif organizations_connected
          row.push(0)
        else
          row.push(nil)
        end

        if space_counter
          row.push(space_counter)
        elsif spaces_connected
          row.push(0)
        else
          row.push(nil)
        end

        items.push(row)

        hash[guid] = isolation_segment
      end

      result(true, items, hash, (1..7).to_a, (1..4).to_a)
    end
  end
end
