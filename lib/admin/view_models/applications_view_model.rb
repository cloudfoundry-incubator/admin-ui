require 'date'
require_relative 'has_applications_view_model'

module AdminUI
  class ApplicationsViewModel < AdminUI::HasApplicationsViewModel
    def do_items
      applications = @cc.applications
      droplets     = @cc.droplets
      packages     = @cc.packages

      # applications, droplets and packages have to exist. Other record types are optional
      return result unless applications['connected'] &&
                           droplets['connected'] &&
                           packages['connected']

      buildpack_lifecycle_data = @cc.buildpack_lifecycle_data
      containers               = @doppler.containers
      events                   = @cc.events
      organizations            = @cc.organizations
      processes                = @cc.processes
      route_mappings           = @cc.route_mappings
      service_bindings         = @cc.service_bindings
      spaces                   = @cc.spaces
      stacks                   = @cc.stacks
      tasks                    = @cc.tasks

      events_connected           = events['connected']
      processes_connected        = processes['connected']
      route_mappings_connected   = route_mappings['connected']
      service_bindings_connected = service_bindings['connected']
      tasks_connected            = tasks['connected']

      buildpack_lifecycle_data_hash = Hash[buildpack_lifecycle_data['items'].map { |item| [item[:app_guid], item] }]
      droplet_hash                  = Hash[droplets['items'].map { |item| [item[:guid], item] }]
      organization_hash             = Hash[organizations['items'].map { |item| [item[:id], item] }]
      package_hash                  = Hash[packages['items'].map { |item| [item[:guid], item] }]
      process_app_hash              = Hash[processes['items'].map { |item| [item[:app_guid], item] }]
      space_hash                    = Hash[spaces['items'].map { |item| [item[:guid], item] }]
      stack_hash                    = Hash[stacks['items'].map { |item| [item[:name], item] }]

      latest_droplets = latest_app_guid_hash(droplets['items'])
      latest_packages = latest_app_guid_hash(packages['items'])

      event_counters = {}
      events['items'].each do |event|
        return result unless @running
        Thread.pass

        if event[:actee_type] == 'app'
          actee = event[:actee]
          event_counters[actee] = 0 if event_counters[actee].nil?
          event_counters[actee] += 1
        elsif event[:actor_type] == 'app'
          actor = event[:actor]
          event_counters[actor] = 0 if event_counters[actor].nil?
          event_counters[actor] += 1
        end
      end

      route_mapping_counters = {}
      route_mappings['items'].each do |route_mapping|
        return result unless @running
        Thread.pass

        app_guid = route_mapping[:app_guid]
        route_mapping_counters[app_guid] = 0 if route_mapping_counters[app_guid].nil?
        route_mapping_counters[app_guid] += 1
      end

      service_binding_counters = {}
      service_bindings['items'].each do |service_binding|
        return result unless @running
        Thread.pass

        app_guid = service_binding[:app_guid]
        service_binding_counters[app_guid] = 0 if service_binding_counters[app_guid].nil?
        service_binding_counters[app_guid] += 1
      end

      application_usage_counters_hash = {}
      containers['items'].each_value do |container|
        return result unless @running
        Thread.pass

        application_guid = container[:application_id]
        application_usage_counters = application_usage_counters_hash[application_guid]
        if application_usage_counters.nil?
          application_usage_counters =
            {
              'used_memory' => 0,
              'used_disk'   => 0,
              'used_cpu'    => 0
            }
          application_usage_counters_hash[application_guid] = application_usage_counters
        end

        application_usage_counters['used_memory'] += container[:memory_bytes]
        application_usage_counters['used_disk'] += container[:disk_bytes]
        application_usage_counters['used_cpu'] += container[:cpu_percentage]
      end

      task_counters = {}
      tasks['items'].each do |task|
        return result unless @running
        Thread.pass

        app_guid = task[:app_guid]
        task_counters[app_guid] = 0 if task_counters[app_guid].nil?
        task_counters[app_guid] += 1
      end

      items = []
      hash  = {}

      applications['items'].each do |application|
        return result unless @running
        Thread.pass

        guid                     = application[:guid]
        process                  = process_app_hash[guid]
        current_droplet_guid     = application[:droplet_guid]
        current_droplet          = current_droplet_guid.nil? ? nil : droplet_hash[current_droplet_guid]
        current_package_guid     = current_droplet.nil? ? nil : current_droplet[:package_guid]
        current_package          = current_package_guid.nil? ? nil : package_hash[current_package_guid]
        latest_droplet           = latest_droplets[guid]
        latest_package           = latest_packages[guid]
        space                    = space_hash[application[:space_guid]]
        organization             = space.nil? ? nil : organization_hash[space[:organization_id]]
        buildpack_lifecycle_data = buildpack_lifecycle_data_hash[guid]
        stack_name               = buildpack_lifecycle_data.nil? ? nil : buildpack_lifecycle_data[:stack]
        stack                    = stack_name.nil? ? nil : stack_hash[stack_name]

        droplet = current_droplet
        droplet = latest_droplet if droplet.nil?

        package = current_package
        package = latest_package if package.nil?

        application_usage_counters = application_usage_counters_hash[guid]
        event_counter              = event_counters[guid]
        route_mapping_counter      = route_mapping_counters[guid]
        service_binding_counter    = service_binding_counters[guid]
        task_counter               = task_counters[guid]

        row = []

        row.push(guid)
        row.push(application[:name])
        row.push(guid)

        row.push(application[:desired_state])

        if process
          row.push(process[:state])
        else
          row.push(nil)
        end

        row.push(package_state(current_droplet, latest_droplet, latest_package))

        if droplet
          row.push(droplet[:error_id])
        else
          row.push(nil)
        end

        row.push(application[:created_at].to_datetime.rfc3339)

        if application[:updated_at]
          row.push(application[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        if process
          row.push(process[:diego])
        else
          row.push(nil)
        end

        # enable_ssh moved from process to application in cf-release 273
        if application[:enable_ssh].nil?
          if process
            row.push(process[:enable_ssh])
          else
            row.push(nil)
          end
        else
          row.push(application[:enable_ssh])
        end

        if package
          row.push(!package[:docker_image].nil?)
        else
          row.push(false)
        end

        row.push(stack_name)

        if droplet
          row.push(droplet[:buildpack_receipt_buildpack])
          row.push(droplet[:buildpack_receipt_buildpack_guid])
        else
          row.push(nil, nil)
        end

        if event_counter
          row.push(event_counter)
        elsif events_connected
          row.push(0)
        else
          row.push(nil)
        end

        if process
          row.push(process[:instances])
        elsif processes_connected
          row.push(0)
        else
          row.push(nil)
        end

        if route_mapping_counter
          row.push(route_mapping_counter)
        elsif route_mappings_connected
          row.push(0)
        else
          row.push(nil)
        end

        if service_binding_counter
          row.push(service_binding_counter)
        elsif service_bindings_connected
          row.push(0)
        else
          row.push(nil)
        end

        if task_counter
          row.push(task_counter)
        elsif tasks_connected
          row.push(0)
        else
          row.push(nil)
        end

        if application_usage_counters
          row.push(Utils.convert_bytes_to_megabytes(application_usage_counters['used_memory']))
          row.push(Utils.convert_bytes_to_megabytes(application_usage_counters['used_disk']))
          row.push(application_usage_counters['used_cpu'])
        else
          row.push(nil, nil, nil)
        end

        if process
          row.push(process[:memory])
          row.push(process[:disk_quota])
        else
          row.push(nil, nil)
        end

        if organization && space
          row.push("#{organization[:name]}/#{space[:name]}")
        else
          row.push(nil)
        end

        items.push(row)

        hash[guid] =
          {
            'application'              => application,
            'buildpack_lifecycle_data' => buildpack_lifecycle_data,
            'current_droplet'          => current_droplet,
            'current_package'          => current_package,
            'latest_droplet'           => latest_droplet,
            'latest_package'           => latest_package,
            'organization'             => organization,
            'process'                  => process,
            'space'                    => space,
            'stack'                    => stack
          }
      end

      result(true, items, hash, (1..25).to_a, (1..14).to_a << 25)
    end
  end
end
