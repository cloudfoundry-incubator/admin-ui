require_relative 'base'
require 'date'
require 'thread'

module AdminUI
  class HealthManagersViewModel < AdminUI::Base
    def initialize(logger, varz)
      super(logger)

      @varz = varz
    end

    def do_items
      health_managers = @varz.health_managers(false)

      # health_managers have to exist.  Other record types are optional
      return result unless health_managers['connected']

      items = []

      health_managers['items'].each do |health_manager|
        Thread.pass
        row = []

        row.push(health_manager['name'])

        data = health_manager['data']

        if health_manager['connected']
          row.push(data['index'])
          row.push('RUNNING')
          row.push(DateTime.parse(data['start']).rfc3339)
          row.push(data['num_cores'])
          row.push(data['cpu'])

          # Conditional logic since mem becomes mem_bytes in 157
          if data['mem']
            row.push(data['mem'])
          elsif data['mem_bytes']
            row.push(data['mem_bytes'])
          else
            row.push(nil)
          end

          row.push(data['total_users'])
          row.push(data['total_apps'])
          row.push(data['total_instances'])
          row.push(health_manager)
        else
          row.push(nil)
          row.push('OFFLINE')

          if data['start']
            row.push(DateTime.parse(data['start']).rfc3339)
          else
            row.push(nil)
          end

          row.push(nil, nil, nil, nil, nil, nil, nil)

          row.push(health_manager['uri'])
        end

        items.push(row)
      end

      result(items, (0..9).to_a, [0, 2, 3])
    end
  end
end
