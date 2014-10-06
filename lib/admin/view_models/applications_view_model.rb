require_relative 'base'
require 'date'
require 'thread'

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

      # applications and DEA's have to exist.  Other record types are optional
      return result unless applications['connected'] && deas['connected']

      organizations = @cc.organizations
      spaces        = @cc.spaces

      organization_hash = Hash[organizations['items'].map { |item| [item[:id], item] }]
      space_hash        = Hash[spaces['items'].map { |item| [item[:id], item] }]

      application_hash = {}

      items = []
      hash  = {}

      applications['items'].each do |application|
        Thread.pass
        space        = space_hash[application[:space_id]]
        organization = space.nil? ? nil : organization_hash[space[:organization_id]]

        row = []

        row.push(application[:guid])
        row.push(application[:name])
        row.push(application[:guid])
        row.push(application[:state])
        row.push(application[:package_state])

        # Instance State
        row.push(nil)

        row.push(application[:created_at].to_datetime.rfc3339)

        if application[:updated_at]
          row.push(application[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        # Started and URI
        row.push(nil, nil)

        if application[:buildpack]
          row.push(application[:buildpack])
        elsif application[:detected_buildpack]
          row.push(application[:detected_buildpack])
        else
          row.push(nil)
        end

        # Instance index, used services, memory, disk and CPU
        row.push(nil, nil, nil, nil, nil)

        row.push(application[:memory])
        row.push(application[:disk_quota])

        if organization && space
          row.push("#{ organization[:name] }/#{ space[:name] }")
        else
          row.push(nil)
        end

        # DEA
        row.push(nil)

        hash_entry =
        {
          'application'  => application,
          'organization' => organization,
          'space'        => space
        }

        application_hash[application[:guid]] =
        {
          'row'        => row,
          'hash_entry' => hash_entry
        }

        items.push(row)

        hash[application[:guid]] = hash_entry
      end

      dea_index = 0

      deas['items'].each do |dea|
        next unless dea['connected']
        data = dea['data']
        host = data['host']
        data['instance_registry'].each_value do |application|
          application.each_value do |instance|
            Thread.pass
            instance_index = instance['instance_index']

            prior = application_hash[instance['application_id']]

            # In some cases, we will not find an existing row.  Create the row as much as possible from the DEA data.
            if prior.nil?
              row = []

              row.push(instance['application_id'])
              row.push(instance['application_name'])
              row.push(instance['application_id'])

              # State and Package State not available.
              row.push(nil, nil)

              row.push(instance['state'])

              # Created and updated not available
              row.push(nil, nil)

              if instance['state_running_timestamp']
                row.push(Time.at(instance['state_running_timestamp']).to_datetime.rfc3339)
              else
                row.push(nil)
              end

              row.push(instance['application_uris'])

              # Buildpack not available.
              row.push(nil)

              row.push(instance_index)

              row.push(instance['services'].length)

              row.push(instance['used_memory_in_bytes'] ? Utils.convert_bytes_to_megabytes(instance['used_memory_in_bytes']) : nil)
              row.push(instance['used_disk_in_bytes'] ? Utils.convert_bytes_to_megabytes(instance['used_disk_in_bytes']) : nil)
              row.push(instance['computed_pcpu'] ? instance['computed_pcpu'] * 100 : nil)

              row.push(instance['limits']['mem'])
              row.push(instance['limits']['disk'])

              # Clear space and organization in case not found below
              space        = nil
              organization = nil

              if instance['tags'] && instance['tags']['space']
                space = space_hash[instance['tags']['space']]
                if space
                  organization = organization_hash[space[:organization_id]]
                end
              end

              if organization && space
                row.push("#{ organization['name'] }/#{ space['name'] }")
              else
                row.push(nil)
              end

              row.push(host)

              items.push(row)

              key = "#{ instance['application_id'] }/#{ instance_index }"
              # No application to push.  Push the instance instead so we can provide details.
              hash[key] =
              {
                'application'  => nil,
                'instance'     => instance,
                'organization' => organization,
                'space'        => space
              }
            else
              row        = prior['row']
              hash_entry = prior['hash_entry']

              # We will add instance info to the 0th row, but other instances have to be cloned so we can have instance specific information
              if instance_index > 0
                new_row = []
                row.each do |column|
                  new_row.push(column)
                end

                items.push(new_row)

                row = new_row
              end

              row[5] = instance['state']

              if instance['state_running_timestamp']
                row[8] = Time.at(instance['state_running_timestamp']).to_datetime.rfc3339
              end

              row[9]  = instance['application_uris']
              row[11] = instance_index
              row[12] = instance['services'].length
              row[13] = instance['used_memory_in_bytes'] ? Utils.convert_bytes_to_megabytes(instance['used_memory_in_bytes']) : nil
              row[14] = instance['used_disk_in_bytes'] ? Utils.convert_bytes_to_megabytes(instance['used_disk_in_bytes']) : nil
              row[15] = instance['computed_pcpu'] ? instance['computed_pcpu'] * 100 : nil
              row[19] = host

              key = "#{ instance['application_id'] }/#{ instance_index }"
              # Need the specific instance for this row
              hash[key] =
              {
                'application'  => hash_entry['application'],
                'instance'     => instance,
                'organization' => hash_entry['organization'],
                'space'        => hash_entry['space']
              }
            end
          end
        end

        dea_index += 1
      end

      result(true, items, hash, (1..19).to_a, (1..10).to_a << 18)
    end
  end
end
