require_relative 'base'
require 'date'
require 'thread'

module AdminUI
  class DEAsViewModel < AdminUI::Base
    def initialize(logger, varz)
      super(logger)

      @varz = varz
    end

    def do_items
      deas = @varz.deas

      # deas have to exist.  Other record types are optional
      return result unless deas['connected']

      items = []

      deas['items'].each do |dea|
        Thread.pass
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

          instance_registry = data['instance_registry']
          if instance_registry
            instances_count = 0
            memory          = 0
            disk            = 0
            pcpu            = 0.0

            instance_registry.each_value do |instances|
              instances_count += instances.length
              instances.each_value do |instance|
                next unless instance['state'] == 'RUNNING'

                memory += instance['used_memory_in_bytes'] if instance['used_memory_in_bytes']
                disk   += instance['used_disk_in_bytes']   if instance['used_disk_in_bytes']
                pcpu   += instance['computed_pcpu']        if instance['computed_pcpu']
              end
            end

            row.push(instance_registry.length,
                     instances_count,
                     Utils.convert_bytes_to_megabytes(memory),
                     Utils.convert_bytes_to_megabytes(disk),
                     pcpu * 100)
          else
            row.push(nil, nil, nil, nil, nil)
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

          row.push(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)

          row.push(dea['uri'])
        end

        items.push(row)
      end

      result(items, (0..13).to_a, [0, 2, 3, 4])
    end
  end
end
