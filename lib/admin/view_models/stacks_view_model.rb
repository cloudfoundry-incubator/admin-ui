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
      processes                = @cc.processes

      applications_connected             = applications['connected']
      buildpack_lifecycle_data_connected = buildpack_lifecycle_data['connected']
      processes_connected                = processes['connected']

      buildpack_lifecycle_data_hash = Hash[buildpack_lifecycle_data['items'].map { |item| [item[:app_guid], item] }]
      process_app_hash              = Hash[processes['items'].map { |item| [item[:app_guid], item] }]

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

        application_counter = application_counters[name]

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

        hash[guid] = stack
      end

      result(true, items, hash, (1..7).to_a, [1, 2, 3, 4, 7])
    end
  end
end
