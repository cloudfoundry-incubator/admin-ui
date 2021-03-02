require 'date'
require_relative 'has_applications_view_model'

module AdminUI
  class BuildpacksViewModel < AdminUI::HasApplicationsViewModel
    def do_items
      buildpacks = @cc.buildpacks

      # buildpacks have to exist. Other record types are optional
      return result unless buildpacks['connected']

      applications          = @cc.applications
      buildpack_annotations = @cc.buildpack_annotations
      buildpack_labels      = @cc.buildpack_labels
      droplets              = @cc.droplets
      stacks                = @cc.stacks

      applications_connected = applications['connected']
      droplets_connected     = droplets['connected']

      droplet_hash = droplets['items'].map { |item| [item[:guid], item] }.to_h
      stack_hash   = stacks['items'].map { |item| [item[:name], item] }.to_h

      latest_droplets = latest_app_guid_hash(droplets['items'])

      buildpack_annotations_hash = {}
      buildpack_annotations['items'].each do |buildpack_annotation|
        return result unless @running

        Thread.pass

        buildpack_guid = buildpack_annotation[:resource_guid]
        buildpack_annotations_array = buildpack_annotations_hash[buildpack_guid]
        if buildpack_annotations_array.nil?
          buildpack_annotations_array = []
          buildpack_annotations_hash[buildpack_guid] = buildpack_annotations_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            annotation:         buildpack_annotation,
            created_at_rfc3339: buildpack_annotation[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: buildpack_annotation[:updated_at].nil? ? nil : buildpack_annotation[:updated_at].to_datetime.rfc3339
          }

        buildpack_annotations_array.push(wrapper)
      end

      buildpack_labels_hash = {}
      buildpack_labels['items'].each do |buildpack_label|
        return result unless @running

        Thread.pass

        buildpack_guid = buildpack_label[:resource_guid]
        buildpack_labels_array = buildpack_labels_hash[buildpack_guid]
        if buildpack_labels_array.nil?
          buildpack_labels_array = []
          buildpack_labels_hash[buildpack_guid] = buildpack_labels_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            label:              buildpack_label,
            created_at_rfc3339: buildpack_label[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: buildpack_label[:updated_at].nil? ? nil : buildpack_label[:updated_at].to_datetime.rfc3339
          }

        buildpack_labels_array.push(wrapper)
      end

      application_counters = {}
      applications['items'].each do |application|
        droplet_guid = application[:droplet_guid]
        droplet      = droplet_guid.nil? ? nil : droplet_hash[droplet_guid]
        droplet      = latest_droplets[application[:guid]] if droplet.nil?
        next if droplet.nil?

        buildpack_receipt_buildpack_guid = droplet[:buildpack_receipt_buildpack_guid]
        next if buildpack_receipt_buildpack_guid.nil?

        application_counters[buildpack_receipt_buildpack_guid] = 0 if application_counters[buildpack_receipt_buildpack_guid].nil?
        application_counters[buildpack_receipt_buildpack_guid] += 1
      end

      items = []
      hash  = {}

      buildpacks['items'].each do |buildpack|
        return result unless @running

        Thread.pass

        guid       = buildpack[:guid]
        stack_name = buildpack[:stack]

        application_counter        = application_counters[guid]
        buildpack_annotation_array = buildpack_annotations_hash[guid] || []
        buildpack_label_array      = buildpack_labels_hash[guid] || []
        stack                      = stack_name.nil? ? nil : stack_hash[stack_name]

        row = []

        row.push(guid)
        row.push(stack_name)
        row.push(buildpack[:name])
        row.push(guid)

        row.push(buildpack[:created_at].to_datetime.rfc3339)

        if buildpack[:updated_at]
          row.push(buildpack[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        row.push(buildpack[:position])
        row.push(buildpack[:enabled])
        row.push(buildpack[:locked])

        if application_counter
          row.push(application_counter)
        elsif applications_connected && droplets_connected
          row.push(0)
        else
          row.push(nil)
        end

        items.push(row)

        hash[guid] =
          {
            'annotations' => buildpack_annotation_array,
            'buildpack'   => buildpack,
            'labels'      => buildpack_label_array,
            'stack'       => stack
          }
      end

      result(true, items, hash, (1..9).to_a, [1, 2, 3, 4, 5, 7, 8])
    end
  end
end
