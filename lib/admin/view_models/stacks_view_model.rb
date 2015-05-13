require 'date'
require 'thread'

module AdminUI
  class StacksViewModel < AdminUI::Base
    def initialize(logger, cc)
      super(logger)

      @cc = cc
    end

    def do_items
      stacks = @cc.stacks

      # stacks have to exist.  Other record types are optional
      return result unless stacks['connected']

      applications = @cc.applications

      applications_connected = applications['connected']

      application_counters = {}

      applications['items'].each do |application|
        Thread.pass
        stack_id = application[:stack_id]
        next if stack_id.nil?
        application_counter = application_counters[stack_id]
        if application_counter.nil?
          application_counter = { 'applications' => 0,
                                  'instances'    => 0
                                }
          application_counters[stack_id] = application_counter
        end
        application_counter['applications'] += 1
        application_counter['instances'] += application[:instances] unless application[:instances].nil?
      end

      items = []
      hash  = {}

      stacks['items'].each do |stack|
        Thread.pass

        guid = stack[:guid]

        application_counter = application_counters[stack[:id]]

        row = []

        row.push(stack[:name])
        row.push(guid)

        row.push(stack[:created_at].to_datetime.rfc3339)

        if stack[:updated_at]
          row.push(stack[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        if application_counter
          row.push(application_counter['applications'])
          row.push(application_counter['instances'])
        elsif applications_connected
          row.push(0, 0)
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
