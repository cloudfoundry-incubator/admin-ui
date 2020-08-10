require 'date'
require_relative 'base_view_model'

module AdminUI
  class IsolationSegmentsViewModel < AdminUI::BaseViewModel
    def do_items
      isolation_segments = @cc.isolation_segments

      # isolation_segments have to exist. Other record types are optional
      return result unless isolation_segments['connected']

      isolation_segment_annotations    = @cc.isolation_segment_annotations
      isolation_segment_labels         = @cc.isolation_segment_labels
      organizations                    = @cc.organizations
      organizations_isolation_segments = @cc.organizations_isolation_segments
      spaces                           = @cc.spaces

      organizations_connected                    = organizations['connected']
      organizations_isolation_segments_connected = organizations_isolation_segments['connected']
      spaces_connected                           = spaces['connected']

      isolation_segment_annotations_hash      = {}
      isolation_segment_labels_hash           = {}
      organization_isolation_segment_counters = {}
      organization_counters                   = {}
      space_counters                          = {}

      isolation_segment_annotations['items'].each do |isolation_segment_annotation|
        return result unless @running

        Thread.pass

        isolation_segment_guid = isolation_segment_annotation[:resource_guid]
        isolation_segment_annotations_array = isolation_segment_annotations_hash[isolation_segment_guid]
        if isolation_segment_annotations_array.nil?
          isolation_segment_annotations_array = []
          isolation_segment_annotations_hash[isolation_segment_guid] = isolation_segment_annotations_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            annotation:         isolation_segment_annotation,
            created_at_rfc3339: isolation_segment_annotation[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: isolation_segment_annotation[:updated_at].nil? ? nil : isolation_segment_annotation[:updated_at].to_datetime.rfc3339
          }

        isolation_segment_annotations_array.push(wrapper)
      end

      isolation_segment_labels['items'].each do |isolation_segment_label|
        return result unless @running

        Thread.pass

        isolation_segment_guid = isolation_segment_label[:resource_guid]
        isolation_segment_labels_array = isolation_segment_labels_hash[isolation_segment_guid]
        if isolation_segment_labels_array.nil?
          isolation_segment_labels_array = []
          isolation_segment_labels_hash[isolation_segment_guid] = isolation_segment_labels_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            label:              isolation_segment_label,
            created_at_rfc3339: isolation_segment_label[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: isolation_segment_label[:updated_at].nil? ? nil : isolation_segment_label[:updated_at].to_datetime.rfc3339
          }

        isolation_segment_labels_array.push(wrapper)
      end

      organizations_isolation_segments['items'].each do |organization_isolation_segment|
        return result unless @running

        Thread.pass

        isolation_segment_guid = organization_isolation_segment[:isolation_segment_guid]
        organization_isolation_segment_counters[isolation_segment_guid] = 0 if organization_isolation_segment_counters[isolation_segment_guid].nil?
        organization_isolation_segment_counters[isolation_segment_guid] += 1
      end

      organizations['items'].each do |organization|
        return result unless @running

        Thread.pass

        default_isolation_segment_guid = organization[:default_isolation_segment_guid]
        next if default_isolation_segment_guid.nil?

        organization_counters[default_isolation_segment_guid] = 0 if organization_counters[default_isolation_segment_guid].nil?
        organization_counters[default_isolation_segment_guid] += 1
      end

      spaces['items'].each do |space|
        return result unless @running

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

        isolation_segment_annotation_array     = isolation_segment_annotations_hash[guid] || []
        isolation_segment_label_array          = isolation_segment_labels_hash[guid] || []
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

        hash[guid] =
          {
            'annotations'       => isolation_segment_annotation_array,
            'isolation_segment' => isolation_segment,
            'labels'            => isolation_segment_label_array
          }
      end

      result(true, items, hash, (1..7).to_a, (1..4).to_a)
    end
  end
end
