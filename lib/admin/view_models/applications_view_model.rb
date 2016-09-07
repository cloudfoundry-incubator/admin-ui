require 'date'
require 'thread'
require_relative 'base_view_model'

module AdminUI
  class ApplicationsViewModel < AdminUI::BaseViewModel
    def do_items
      applications = @cc.applications

      # applications have to exist.  Other record types are optional
      return result unless applications['connected']

      apps_routes      = @cc.apps_routes
      buildpacks       = @cc.buildpacks
      containers       = @doppler.containers
      deas             = @varz.deas
      droplets         = @cc.droplets
      events           = @cc.events
      organizations    = @cc.organizations
      service_bindings = @cc.service_bindings
      spaces           = @cc.spaces
      stacks           = @cc.stacks

      apps_routes_connected      = apps_routes['connected']
      deas_connected             = deas['connected']
      events_connected           = events['connected']
      service_bindings_connected = service_bindings['connected']

      buildpack_hash    = Hash[buildpacks['items'].map { |item| [item[:guid], item] }]
      droplet_hash      = Hash[droplets['items'].map { |item| [item[:droplet_hash], item] }]
      organization_hash = Hash[organizations['items'].map { |item| [item[:id], item] }]
      space_hash        = Hash[spaces['items'].map { |item| [item[:id], item] }]
      stack_hash        = Hash[stacks['items'].map { |item| [item[:id], item] }]

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

      app_route_counters = {}
      apps_routes['items'].each do |app_route|
        return result unless @running
        Thread.pass

        app_id = app_route[:app_id]
        app_route_counters[app_id] = 0 if app_route_counters[app_id].nil?
        app_route_counters[app_id] += 1
      end

      service_binding_counters = {}
      service_bindings['items'].each do |service_binding|
        return result unless @running
        Thread.pass

        app_id = service_binding[:app_id]
        service_binding_counters[app_id] = 0 if service_binding_counters[app_id].nil?
        service_binding_counters[app_id] += 1
      end

      application_usage_counters_hash = {}
      deas['items'].each do |dea|
        next unless dea['connected']
        next unless dea['data']['instance_registry']
        dea['data']['instance_registry'].each_value do |application|
          application.each_value do |instance|
            return result unless @running
            Thread.pass

            application_id = instance['application_id']
            application_usage_counters = application_usage_counters_hash[application_id]
            if application_usage_counters.nil?
              application_usage_counters =
                {
                  'used_memory' => 0,
                  'used_disk'   => 0,
                  'used_cpu'    => 0
                }
              application_usage_counters_hash[application_id] = application_usage_counters
            end

            application_usage_counters['used_memory'] += instance['used_memory_in_bytes'] unless instance['used_memory_in_bytes'].nil?
            application_usage_counters['used_disk'] += instance['used_disk_in_bytes'] unless instance['used_disk_in_bytes'].nil?
            application_usage_counters['used_cpu'] += instance['computed_pcpu'] * 100 unless instance['computed_pcpu'].nil?
          end
        end
      end

      containers['items'].each_value do |container|
        return result unless @running
        Thread.pass

        application_id = container[:application_id]
        application_usage_counters = application_usage_counters_hash[application_id]
        if application_usage_counters.nil?
          application_usage_counters =
            {
              'used_memory' => 0,
              'used_disk'   => 0,
              'used_cpu'    => 0
            }
          application_usage_counters_hash[application_id] = application_usage_counters
        end

        application_usage_counters['used_memory'] += container[:memory_bytes]
        application_usage_counters['used_disk'] += container[:disk_bytes]
        application_usage_counters['used_cpu'] += container[:cpu_percentage]
      end

      items = []
      hash  = {}

      applications['items'].each do |application|
        return result unless @running
        Thread.pass

        guid             = application[:guid]
        id               = application[:id]
        app_droplet_hash = application[:droplet_hash]
        droplet          = app_droplet_hash.nil? ? nil : droplet_hash[app_droplet_hash]
        space            = space_hash[application[:space_id]]
        organization     = space.nil? ? nil : organization_hash[space[:organization_id]]
        stack            = stack_hash[application[:stack_id]]

        application_usage_counters = application_usage_counters_hash[guid]
        app_route_counter          = app_route_counters[id]
        event_counter              = event_counters[guid]
        service_binding_counter    = service_binding_counters[id]

        row = []

        row.push(guid)
        row.push(application[:name])
        row.push(guid)
        row.push(application[:state])
        row.push(application[:package_state])
        row.push(application[:staging_failed_reason])

        row.push(application[:created_at].to_datetime.rfc3339)

        if application[:updated_at]
          row.push(application[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        row.push(application[:diego])

        if application[:allow_ssh] || application[:enable_ssh] # Originally allow_ssh, changed later to enable_ssh
          row.push(true)
        else
          row.push(false)
        end

        if !application[:docker_image].nil?
          row.push(true)
        else
          row.push(false)
        end

        if stack
          row.push(stack[:name])
        else
          row.push(nil)
        end

        if application[:buildpack] # Removed in cf-release 241. Replaced with encrypted_buildpack
          row.push(application[:buildpack])
        elsif application[:detected_buildpack]
          row.push(application[:detected_buildpack])
        else
          row.push(nil)
        end

        # Verify buildpack really exists since deletion of buildpack does not clear app's detected_buildpack_guid
        detected_buildpack_guid = application[:detected_buildpack_guid]
        if detected_buildpack_guid
          detected_buildpack_guid = nil if buildpack_hash[detected_buildpack_guid].nil?
        end
        row.push(detected_buildpack_guid)

        if event_counter
          row.push(event_counter)
        elsif events_connected
          row.push(0)
        else
          row.push(nil)
        end

        row.push(application[:instances])

        if app_route_counter
          row.push(app_route_counter)
        elsif apps_routes_connected
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

        if application_usage_counters
          row.push(Utils.convert_bytes_to_megabytes(application_usage_counters['used_memory']))
          row.push(Utils.convert_bytes_to_megabytes(application_usage_counters['used_disk']))
          row.push(application_usage_counters['used_cpu'])
        elsif deas_connected
          row.push(0, 0, 0)
        else
          row.push(nil, nil, nil)
        end

        row.push(application[:memory])
        row.push(application[:disk_quota])

        if organization && space
          row.push("#{organization[:name]}/#{space[:name]}")
        else
          row.push(nil)
        end

        items.push(row)

        hash[guid] =
          {
            'application'  => application,
            'droplet'      => droplet,
            'organization' => organization,
            'space'        => space,
            'stack'        => stack
          }
      end

      result(true, items, hash, (1..23).to_a, (1..13).to_a << 23)
    end
  end
end
