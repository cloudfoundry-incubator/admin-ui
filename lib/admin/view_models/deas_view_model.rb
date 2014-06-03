require_relative 'base'
require 'date'

module AdminUI
  class DEAsViewModel < AdminUI::Base
    def initialize(logger, varz)
      super(logger)

      @varz = varz
    end

    def do_items
      deas = @varz.deas(false)

      # deas have to exist.  Other record types are optional
      return result unless deas['connected']

      items = []

      deas['items'].each do |dea|
        row = []

        row.push(dea['name'])

        data = dea['data']

        if dea['connected']
          row.push(data['index'])
          row.push('RUNNING')
          row.push(DateTime.parse(data['start']).rfc3339)
          row.push(data['stacks'])
          row.push(data['cpu'])

          # Conditional logic since mem becomes mem_bytes in 157
          if data['mem']
            row.push(data['mem'])
          elsif data['mem_bytes']
            row.push(data['mem_bytes'])
          else
            row.push(nil)
          end

          if data['instance_registry']
            row.push(data['instance_registry'].length)
          else
            row.push(0)
          end

          row.push(data['available_memory_ratio'] * 100)
          row.push(data['available_disk_ratio'] * 100)

          row.push(dea)
        else
          row.push(nil)
          row.push('OFFLINE')

          if data['start']
            row.push(DateTime.parse(data['start']).rfc3339)
          else
            row.push(nil)
          end

          row.push(nil, nil, nil, nil, nil, nil, nil)

          row.push(dea['uri'])
        end

        items.push(row)
      end

      result(items, (0..9).to_a, [0, 2, 3, 4])
    end
  end
end
