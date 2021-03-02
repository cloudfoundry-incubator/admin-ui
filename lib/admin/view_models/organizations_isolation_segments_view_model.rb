require 'date'
require_relative 'base_view_model'

module AdminUI
  class OrganizationsIsolationSegmentsViewModel < AdminUI::BaseViewModel
    def do_items
      isolation_segments               = @cc.isolation_segments
      organizations                    = @cc.organizations
      organizations_isolation_segments = @cc.organizations_isolation_segments

      # isolation_segments, organizations and organizations_isolation_segments have to exist. Other record types are optional
      return result unless isolation_segments['connected'] &&
                           organizations['connected'] &&
                           organizations_isolation_segments['connected']

      organization_hash       = organizations['items'].map { |item| [item[:guid], item] }.to_h
      isolation_segments_hash = isolation_segments['items'].map { |item| [item[:guid], item] }.to_h

      items = []
      hash  = {}

      organizations_isolation_segments['items'].each do |organization_isolation_segment|
        return result unless @running

        Thread.pass

        isolation_segment_guid = organization_isolation_segment[:isolation_segment_guid]
        organization_guid      = organization_isolation_segment[:organization_guid]

        isolation_segment = isolation_segments_hash[isolation_segment_guid]
        organization      = organization_hash[organization_guid]

        next if isolation_segment.nil? || organization.nil?

        key = "#{organization_guid}/#{isolation_segment_guid}"

        row = []

        row.push(key)

        row.push(organization[:name])
        row.push(organization_guid)
        row.push(isolation_segment[:name])
        row.push(isolation_segment_guid)

        items.push(row)

        hash[key] =
          {
            'isolation_segment'              => isolation_segment,
            'organization'                   => organization,
            'organization_isolation_segment' => organization_isolation_segment
          }
      end

      result(true, items, hash, (1..4).to_a, (1..4).to_a)
    end
  end
end
