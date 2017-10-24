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

      application_hash  = Hash[applications['items'].map { |item| [item[:guid], item] }]
      organization_hash = Hash[organizations['items'].map { |item| [item[:id], item] }]
      space_hash        = Hash[spaces['items'].map { |item| [item[:guid], item] }]

      items = []
      hash  = {}

      tasks['items'].each do |task|
        return result unless @running
        Thread.pass

        application_guid = task[:app_guid]
        application      = application_hash[application_guid]
        space            = application.nil? ? nil : space_hash[application[:space_guid]]
        organization     = space.nil? ? nil : organization_hash[space[:organization_id]]

        row = []

        row.push(task[:guid])
        row.push(task[:name])
        row.push(task[:guid])
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

        hash[task[:guid]] =
          {
            'application'  => application,
            'organization' => organization,
            'space'        => space,
            'task'         => task
          }
      end

      result(true, items, hash, (1..11).to_a, [1, 2, 4, 5, 8, 9, 11])
    end
  end
end
