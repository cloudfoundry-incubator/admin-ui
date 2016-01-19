require 'date'
require 'thread'
require_relative 'base_view_model'

module AdminUI
  class ApplicationInstancesViewModel < AdminUI::BaseViewModel
    BILLION = 1000.0 * 1000.0 * 1000.0
    def do_items
      containers = @doppler.containers
      deas       = @varz.deas

      # containers or DEA's have to exist.  Other record types are optional
      return result unless containers['connected'] || deas['connected']

      applications  = @cc.applications
      organizations = @cc.organizations
      spaces        = @cc.spaces
      stacks        = @cc.stacks

      application_guid_hash = Hash[applications['items'].map { |item| [item[:guid], item] }]
      organization_hash     = Hash[organizations['items'].map { |item| [item[:id], item] }]
      space_guid_hash       = Hash[spaces['items'].map { |item| [item[:guid], item] }]
      space_hash            = Hash[spaces['items'].map { |item| [item[:id], item] }]
      stack_hash            = Hash[stacks['items'].map { |item| [item[:id], item] }]
      stack_name_hash       = Hash[stacks['items'].map { |item| [item[:name], item] }]

      items = []
      hash  = {}

      if deas['connected']
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

              # Metrics last gathered not provided in the DEA case
              row.push(nil)

              # This is not a Diego app
              row.push(false)

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
                space = space_guid_hash[application_instance['tags']['space']]
                organization = organization_hash[space[:organization_id]] if space
              elsif application_instance['vcap_application'] && application_instance['vcap_application']['space_id']
                space = space_guid_hash[application_instance['vcap_application']['space_id']]
                organization = organization_hash[space[:organization_id]] if space
              end

              if organization && space
                row.push("#{organization[:name]}/#{space[:name]}")
              else
                row.push(nil)
              end

              row.push(host)

              # Cell is always nil when dealing with DEA-based application instances
              row.push(nil)

              # We need another non-visible item to be the key when getting details since DEA-based and Cell-based application instances are different
              key = "#{id}/#{instance_index}/#{instance_id}"
              row.push(key)

              items.push(row)

              hash[key] =
                {
                  'application'          => nil,
                  'application_instance' => application_instance,
                  'container'            => nil,
                  'organization'         => organization,
                  'space'                => space,
                  'stack'                => stack
                }
            end
          end
        end
      end

      if containers['connected']
        containers['items'].each_value do |container|
          return result unless @running
          Thread.pass

          application_id = container[:application_id]
          instance_index = container[:instance_index]
          application    = application_guid_hash[application_id]
          space          = application.nil? ? nil : space_hash[application[:space_id]]
          organization   = space.nil? ? nil : organization_hash[space[:organization_id]]
          stack          = application.nil? ? nil : stack_hash[application[:stack_id]]

          row = []

          row.push("#{application_id}/#{instance_index}")

          if application
            row.push(application[:name])
          else
            row.push(nil)
          end

          row.push(application_id)
          row.push(container[:instance_index])

          # There is no application instance ID, state, running timestamp for a Cell-based application instance
          row.push(nil, nil, nil)

          row.push(Time.at(container[:timestamp] / BILLION).to_datetime.rfc3339)

          # This is a Diego app
          row.push(true)

          if stack
            row.push(stack[:name])
          else
            row.push(nil)
          end

          row.push(Utils.convert_bytes_to_megabytes(container[:memory_bytes]))
          row.push(Utils.convert_bytes_to_megabytes(container[:disk_bytes]))
          row.push(container[:cpu_percentage] * 100)

          if application
            row.push(application[:memory])
            row.push(application[:disk_quota])

            if organization && space
              row.push("#{organization[:name]}/#{space[:name]}")
            else
              row.push(nil)
            end
          else
            row.push(nil, nil, nil)
          end

          # DEA is always nil when dealing with Cell-based application instances
          row.push(nil)

          row.push("#{container[:ip]}:#{container[:index]}")

          # We need another item to be the key when getting details since DEA-based and Cell-based application instances are different
          key = "#{application_id}/#{instance_index}/0"
          row.push(key)

          items.push(row)

          hash[key] =
            {
              'application'          => application,
              'application_instance' => nil,
              'container'            => container,
              'organization'         => organization,
              'space'                => space,
              'stack'                => stack
            }
        end
      end

      result(true, items, hash, (1..17).to_a, [1, 2, 4, 5, 6, 7, 8, 9, 15, 16, 17])
    end
  end
end
