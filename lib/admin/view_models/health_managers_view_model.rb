require 'date'
require 'thread'
require_relative 'base_view_model'

module AdminUI
  class HealthManagersViewModel < AdminUI::BaseViewModel
    def do_items
      health_managers = @varz.health_managers

      # health_managers have to exist.  Other record types are optional
      return result unless health_managers['connected']

      items = []
      hash  = {}

      health_managers['items'].each do |health_manager|
        return result unless @running
        Thread.pass

        row = []

        row.push(health_manager['name'])
        row.push(health_manager['index'])

        data = health_manager['data']

        if health_manager['connected']
          row.push('RUNNING')
          row.push(data['numCPUS'])

          memory_stats = data['memoryStats']

          if memory_stats
            row.push(memory_stats['numBytesAllocated'])
          else
            row.push(nil)
          end

          hash[health_manager['name']] = health_manager
        else
          row.push('OFFLINE')

          row.push(nil, nil, nil)

          row.push(health_manager['uri'])
        end

        items.push(row)
      end

      result(true, items, hash, (0..4).to_a, [0, 2])
    end
  end
end
