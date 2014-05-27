require_relative 'base'
require 'date'

module AdminUI
  class ApplicationsViewModel < AdminUI::Base
    def initialize(logger, cc, varz)
      super(logger)

      @cc   = cc
      @varz = varz
    end

    def do_items
      applications = @cc.applications
      deas         = @varz.deas

      # applications or DEA's have to exist.  Other record types are optional
      return result unless applications['connected'] || deas['connected']

      organizations = @cc.organizations
      spaces        = @cc.spaces

      organization_hash = Hash[*organizations['items'].map { |item| [item['guid'], item] }.flatten]
      space_hash        = Hash[*spaces['items'].map { |item| [item['guid'], item] }.flatten]

      application_hash = {}

      items = []

      applications['items'].each do |application|
        space        = space_hash[application['space_guid']]
        organization = space.nil? ? nil : organization_hash[space['organization_guid']]

        row = []

        row.push(application['guid'])
        row.push(application['name'])
        row.push(application['state'])
        row.push(application['package_state'])

        # Instance State
        row.push(nil)

        row.push(DateTime.parse(application['created_at']).rfc3339)

        if application['updated_at']
          row.push(DateTime.parse(application['updated_at']).rfc3339)
        else
          row.push(nil)
        end

        # Started and URI
        row.push(nil, nil)

        if application['buildpack']
          row.push(application['buildpack'])
        elsif application['detected_buildpack']
          row.push(application['detected_buildpack'])
        else
          row.push(nil)
        end

        # Instance index, used services, memory, disk and CPU
        row.push(nil, nil, nil, nil, nil)

        row.push(application['memory'])
        row.push(application['disk_quota'])

        if organization && space
          row.push("#{ organization['name'] }/#{ space['name'] }")
        else
          row.push(nil)
        end

        # DEA
        row.push(nil)

        row.push('application'  => application,
                 'space'        => space,
                 'organization' => organization)

        application_hash[application['guid']] = row

        items.push(row)
      end

      dea_index = 0

      deas['items'].each do |dea|
        next unless dea['connected']
        data = dea['data']
        host = data['host']
        data['instance_registry'].each_value do |application|
          application.each_value do |instance|
            instance_index = instance['instance_index']

            row = application_hash[instance['application_id']]

            # In some cases, we will not find an existing row.  Create the row as much as possible from the DEA data.
            if row.nil?
              row = []

              row.push(instance['application_id'])
              row.push(instance['application_name'])

              # State and Package State not available.
              row.push(nil, nil)

              row.push(instance['state'])

              # Created and updated not available
              row.push(nil, nil)

              if instance['state_running_timestamp']
                row.push(DateTime.parse(Time.at(instance['state_running_timestamp']).utc.to_s).rfc3339)
              else
                row.push(nil)
              end

              row.push(instance['application_uris'])

              # Buildpack not available.
              row.push(nil)

              row.push(instance_index)

              row.push(instance['services'].length)

              row.push(instance['used_memory_in_bytes'] ? Utils.convert_bytes_to_megabytes(instance['used_memory_in_bytes']) : 0)
              row.push(instance['used_disk_in_bytes'] ? Utils.convert_bytes_to_megabytes(instance['used_disk_in_bytes']) : 0)
              row.push(instance['computed_pcpu'] ? instance['computed_pcpu'] * 100 : 0)

              row.push(instance['limits']['mem'])
              row.push(instance['limits']['disk'])

              # Clear space and organization in case not found below
              space        = nil
              organization = nil

              if instance['tags'] && instance['tags']['space']
                space = space_hash[instance['tags']['space']]
                if space
                  organization = organization_hash[space['organization_guid']]
                end
              end

              if organization && space
                row.push("#{ organization['name'] }/#{ space['name'] }")
              else
                row.push(nil)
              end

              row.push(host)

              # No application to push.  Push the instance instead so we can provide details.
              row.push('instance'     => instance,
                       'space'        => space,
                       'organization' => organization)

              items.push(row)
            else
              # We will add instance info to the 0th row, but other instances have to be cloned so we can have instance specific information
              if instance_index > 0
                new_row = []
                row.each do |column|
                  new_row.push(column)
                end

                items.push(new_row)

                row = new_row
              end

              row[4] = instance['state']

              if instance['state_running_timestamp']
                row[7] = DateTime.parse(Time.at(instance['state_running_timestamp']).utc.to_s).rfc3339
              end

              row[ 8] = instance['application_uris']
              row[10] = instance_index
              row[11] = instance['services'].length
              row[12] = instance['used_memory_in_bytes'] ? Utils.convert_bytes_to_megabytes(instance['used_memory_in_bytes']) : 0
              row[13] = instance['used_disk_in_bytes'] ? Utils.convert_bytes_to_megabytes(instance['used_disk_in_bytes']) : 0
              row[14] = instance['computed_pcpu'] ? instance['computed_pcpu'] * 100 : 0
              row[18] = host

              # Need the specific instance for this row
              row[19] = { 'application'  => row[19]['application'],
                          'instance'     => instance,
                          'space'        => row[19]['space'],
                          'organization' => row[19]['organization']
                        }
            end
          end
        end

        dea_index += 1
      end

      result(items, (1..18).to_a, (1..9).to_a << 17)
    end
  end
end
