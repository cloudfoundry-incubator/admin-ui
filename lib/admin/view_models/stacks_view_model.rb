require 'date'
require_relative 'base_view_model'

module AdminUI
  class StacksViewModel < AdminUI::BaseViewModel
    def do_items
      stacks = @cc.stacks

      # stacks have to exist. Other record types are optional
      return result unless stacks['connected']

      applications             = @cc.applications
      buildpack_lifecycle_data = @cc.buildpack_lifecycle_data
      buildpacks               = @cc.buildpacks
      processes                = @cc.processes
      stack_annotations        = @cc.stack_annotations
      stack_labels             = @cc.stack_labels

      applications_connected             = applications['connected']
      buildpack_lifecycle_data_connected = buildpack_lifecycle_data['connected']
      buildpacks_connected               = buildpacks['connected']
      processes_connected                = processes['connected']

      buildpack_lifecycle_data_hash = buildpack_lifecycle_data['items'].map { |item| [item[:app_guid], item] }.to_h
      process_app_hash              = processes['items'].map { |item| [item[:app_guid], item] }.to_h

      stack_annotations_hash = {}
      stack_annotations['items'].each do |stack_annotation|
        return result unless @running

        Thread.pass

        stack_guid = stack_annotation[:resource_guid]
        stack_annotations_array = stack_annotations_hash[stack_guid]
        if stack_annotations_array.nil?
          stack_annotations_array = []
          stack_annotations_hash[stack_guid] = stack_annotations_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            annotation:         stack_annotation,
            created_at_rfc3339: stack_annotation[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: stack_annotation[:updated_at].nil? ? nil : stack_annotation[:updated_at].to_datetime.rfc3339
          }

        stack_annotations_array.push(wrapper)
      end

      stack_labels_hash = {}
      stack_labels['items'].each do |stack_label|
        return result unless @running

        Thread.pass

        stack_guid = stack_label[:resource_guid]
        stack_labels_array = stack_labels_hash[stack_guid]
        if stack_labels_array.nil?
          stack_labels_array = []
          stack_labels_hash[stack_guid] = stack_labels_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            label:              stack_label,
            created_at_rfc3339: stack_label[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: stack_label[:updated_at].nil? ? nil : stack_label[:updated_at].to_datetime.rfc3339
          }

        stack_labels_array.push(wrapper)
      end

      buildpack_counters = {}
      buildpacks['items'].each do |buildpack|
        return result unless @running

        Thread.pass

        stack_name = buildpack[:stack]
        next if stack_name.nil?

        buildpack_counters[stack_name] = 0 if buildpack_counters[stack_name].nil?
        buildpack_counters[stack_name] += 1
      end

      application_counters = {}
      applications['items'].each do |application|
        return result unless @running

        Thread.pass

        application_guid         = application[:guid]
        buildpack_lifecycle_data = buildpack_lifecycle_data_hash[application_guid]
        next if buildpack_lifecycle_data.nil?

        stack_name = buildpack_lifecycle_data[:stack]
        next if stack_name.nil?

        application_counter = application_counters[stack_name]
        if application_counter.nil?
          application_counter =
            {
              'applications' => 0,
              'instances'    => 0
            }
          application_counters[stack_name] = application_counter
        end

        application_counter['applications'] += 1

        process = process_app_hash[application_guid]
        next if process.nil?

        application_counter['instances'] += process[:instances] unless process[:instances].nil?
      end

      items = []
      hash  = {}

      stacks['items'].each do |stack|
        return result unless @running

        Thread.pass

        guid = stack[:guid]
        name = stack[:name]

        application_counter    = application_counters[name]
        buildpack_counter      = buildpack_counters[name]
        stack_annotation_array = stack_annotations_hash[guid] || []
        stack_label_array      = stack_labels_hash[guid] || []

        row = []

        row.push(guid)
        row.push(name)
        row.push(guid)

        row.push(stack[:created_at].to_datetime.rfc3339)

        if stack[:updated_at]
          row.push(stack[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        if buildpack_counter
          row.push(buildpack_counter)
        elsif buildpacks_connected
          row.push(0)
        else
          row.push(nil)
        end

        if application_counter
          row.push(application_counter['applications'])
          if processes_connected
            row.push(application_counter['instances'])
          else
            row.push(nil)
          end
        elsif applications_connected && buildpack_lifecycle_data_connected
          row.push(0)
          if processes_connected
            row.push(0)
          else
            row.push(nil)
          end
        else
          row.push(nil, nil)
        end

        row.push(stack[:description])

        items.push(row)

        hash[guid] =
          {
            'annotations' => stack_annotation_array,
            'labels'      => stack_label_array,
            'stack'       => stack
          }
      end

      result(true, items, hash, (1..8).to_a, [1, 2, 3, 4, 8])
    end
  end
end
