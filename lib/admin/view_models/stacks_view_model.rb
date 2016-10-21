require 'date'
require 'thread'
require_relative 'has_applications_view_model'

module AdminUI
  class StacksViewModel < AdminUI::HasApplicationsViewModel
    def do_items
      stacks = @cc.stacks

      # stacks have to exist.  Other record types are optional
      return result unless stacks['connected']

      applications = @cc.applications
      droplets     = @cc.droplets
      processes    = @cc.processes

      applications_connected = applications['connected']
      droplets_connected     = droplets['connected']
      processes_connected    = processes['connected']

      droplet_hash     = Hash[droplets['items'].map { |item| [item[:guid], item] }]
      process_app_hash = Hash[processes['items'].map { |item| [item[:app_guid], item] }]

      latest_droplets = latest_app_guid_hash(droplets['items'])

      application_counters = {}

      applications['items'].each do |application|
        return result unless @running
        Thread.pass

        droplet_guid = application[:droplet_guid]
        droplet      = droplet_guid.nil? ? nil : droplet_hash[droplet_guid]
        droplet      = latest_droplets[application[:guid]] if droplet.nil?
        next if droplet.nil?

        stack_name = droplet[:buildpack_receipt_stack_name]
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

        process = process_app_hash[application[:guid]]
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

        application_counter = application_counters[name]

        row = []

        row.push(name)
        row.push(guid)

        row.push(stack[:created_at].to_datetime.rfc3339)

        if stack[:updated_at]
          row.push(stack[:updated_at].to_datetime.rfc3339)
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
        elsif applications_connected && droplets_connected
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

        hash[guid] = stack
      end

      result(true, items, hash, (0..6).to_a, [0, 1, 2, 3, 6])
    end
  end
end
