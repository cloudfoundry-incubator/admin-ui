require 'date'
require 'thread'
require_relative 'base_view_model'

module AdminUI
  class ApplicationInstancesViewModel < AdminUI::BaseViewModel
    def do_items
      deas = @varz.deas

      # DEA's have to exist.  Other record types are optional
      return result unless deas['connected']

      organizations = @cc.organizations
      spaces        = @cc.spaces
      stacks        = @cc.stacks

      organization_hash = Hash[organizations['items'].map { |item| [item[:id], item] }]
      space_hash        = Hash[spaces['items'].map { |item| [item[:guid], item] }]
      stack_name_hash   = Hash[stacks['items'].map { |item| [item[:name], item] }]

      items = []
      hash  = {}

      deas['items'].each do |dea|
        next unless dea['connected']
        data = dea['data']
        host = dea['name']
        next unless data['instance_registry']
        data['instance_registry'].each_value do |application|
          application.each_value do |application_instance|
            return result unless @running
            Thread.pass

            id             = application_instance['application_id']
            instance_id    = application_instance['instance_id']
            instance_index = application_instance['instance_index']

            stack_name    = application_instance['stack']
            stack         = stack_name.nil? ? nil : stack_name_hash[stack_name]

            row = []

            row.push("#{id}/#{instance_index}")
            row.push(application_instance['application_name'])
            row.push(id)
            row.push(instance_index)
            row.push(instance_id)
            row.push(application_instance['state'])

            if application_instance['state_running_timestamp']
              row.push(Time.at(application_instance['state_running_timestamp']).to_datetime.rfc3339)
            else
              row.push(nil)
            end

            row.push(application_instance['application_uris'])
            row.push(stack_name)
            row.push(application_instance['used_memory_in_bytes'] ? Utils.convert_bytes_to_megabytes(application_instance['used_memory_in_bytes']) : nil)
            row.push(application_instance['used_disk_in_bytes'] ? Utils.convert_bytes_to_megabytes(application_instance['used_disk_in_bytes']) : nil)
            row.push(application_instance['computed_pcpu'] ? application_instance['computed_pcpu'] * 100 : nil)
            row.push(application_instance['limits']['mem'])
            row.push(application_instance['limits']['disk'])

            # Clear space and organization in case not found below
            space        = nil
            organization = nil

            # Old using tags and new using vcap_application
            if application_instance['tags'] && application_instance['tags']['space']
              space = space_hash[application_instance['tags']['space']]
              organization = organization_hash[space[:organization_id]] if space
            elsif application_instance['vcap_application'] && application_instance['vcap_application']['space_id']
              space = space_hash[application_instance['vcap_application']['space_id']]
              organization = organization_hash[space[:organization_id]] if space
            end

            if organization && space
              row.push("#{organization[:name]}/#{space[:name]}")
            else
              row.push(nil)
            end

            row.push(host)

            items.push(row)

            hash["#{id}/#{instance_id}"] =
            {
              'application_instance' => application_instance,
              'organization'         => organization,
              'space'                => space,
              'stack'                => stack
            }
          end
        end
      end

      result(true, items, hash, (1..15).to_a, [1, 2, 4, 5, 6, 7, 8, 14])
    end
  end
end
