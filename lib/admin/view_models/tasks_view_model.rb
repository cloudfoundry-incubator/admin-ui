require 'date'
require_relative 'base_view_model'

module AdminUI
  class TasksViewModel < AdminUI::BaseViewModel
    def do_items
      tasks = @cc.tasks

      # tasks have to exist. Other record types are optional
      return result unless tasks['connected']

      applications  = @cc.applications
      organizations = @cc.organizations
      spaces        = @cc.spaces
      task_annotations = @cc.task_annotations
      task_labels      = @cc.task_labels

      application_hash  = applications['items'].map { |item| [item[:guid], item] }.to_h
      organization_hash = organizations['items'].map { |item| [item[:id], item] }.to_h
      space_hash        = spaces['items'].map { |item| [item[:guid], item] }.to_h

      task_annotations_hash = {}
      task_annotations['items'].each do |task_annotation|
        return result unless @running

        Thread.pass

        task_guid = task_annotation[:resource_guid]
        task_annotations_array = task_annotations_hash[task_guid]
        if task_annotations_array.nil?
          task_annotations_array = []
          task_annotations_hash[task_guid] = task_annotations_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            annotation:         task_annotation,
            created_at_rfc3339: task_annotation[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: task_annotation[:updated_at].nil? ? nil : task_annotation[:updated_at].to_datetime.rfc3339
          }

        task_annotations_array.push(wrapper)
      end

      task_labels_hash = {}
      task_labels['items'].each do |task_label|
        return result unless @running

        Thread.pass

        task_guid = task_label[:resource_guid]
        task_labels_array = task_labels_hash[task_guid]
        if task_labels_array.nil?
          task_labels_array = []
          task_labels_hash[task_guid] = task_labels_array
        end

        # Need rfc3339 dates
        wrapper =
          {
            label:              task_label,
            created_at_rfc3339: task_label[:created_at].to_datetime.rfc3339,
            updated_at_rfc3339: task_label[:updated_at].nil? ? nil : task_label[:updated_at].to_datetime.rfc3339
          }

        task_labels_array.push(wrapper)
      end

      items = []
      hash  = {}

      tasks['items'].each do |task|
        return result unless @running

        Thread.pass

        guid             = task[:guid]
        application_guid = task[:app_guid]

        application           = application_hash[application_guid]
        space                 = application.nil? ? nil : space_hash[application[:space_guid]]
        organization          = space.nil? ? nil : organization_hash[space[:organization_id]]
        task_annotation_array = task_annotations_hash[guid] || []
        task_label_array      = task_labels_hash[guid] || []

        row = []

        row.push(guid)
        row.push(task[:name])
        row.push(guid)
        row.push(task[:state])
        row.push(task[:created_at].to_datetime.rfc3339)

        if task[:updated_at]
          row.push(task[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        row.push(task[:memory_in_mb])
        row.push(task[:disk_in_mb])

        if application
          row.push(application[:name])
        else
          row.push(nil)
        end

        row.push(application_guid)
        row.push(task[:sequence_id])

        if organization && space
          row.push("#{organization[:name]}/#{space[:name]}")
        else
          row.push(nil)
        end

        items.push(row)

        hash[guid] =
          {
            'annotations'  => task_annotation_array,
            'application'  => application,
            'labels'       => task_label_array,
            'organization' => organization,
            'space'        => space,
            'task'         => task
          }
      end

      result(true, items, hash, (1..11).to_a, [1, 2, 4, 5, 8, 9, 11])
    end
  end
end
