require 'date'
require 'thread'
require_relative 'base_view_model'

module AdminUI
  class DEAsViewModel < AdminUI::BaseViewModel
    BILLION = 1000.0 * 1000.0 * 1000.0
    def do_items
      doppler_deas = @doppler.deas
      varz_deas    = @varz.deas

      # Either doppler_deas or varz_deas have to exist.  Other record types are optional
      return result unless doppler_deas['connected'] || varz_deas['connected']

      items = []
      hash  = {}

      if varz_deas['connected']
        varz_deas['items'].each do |dea|
          return result unless @running
          Thread.pass

          row = []

          row.push(dea['name'])
          row.push(dea['index'])
          row.push('varz')
          row.push(nil) # Metrics date

          data = dea['data']

          if dea['connected']
            row.push('RUNNING')
            row.push(DateTime.parse(data['start']).rfc3339)
            row.push(data['stacks'])
            row.push(data['cpu'])

            # Conditional logic since mem becomes mem_bytes in 157
            if data['mem']
              row.push(Utils.convert_kilobytes_to_megabytes(data['mem']))
            elsif data['mem_bytes']
              row.push(Utils.convert_bytes_to_megabytes(data['mem_bytes']))
            else
              row.push(nil)
            end

            instance_registry = data['instance_registry']
            if instance_registry
              instances_count = 0
              running_count   = 0
              memory          = 0
              disk            = 0
              pcpu            = 0.0

              instance_registry.each_value do |instances|
                instances_count += instances.length
                instances.each_value do |instance|
                  next unless instance['state'] == 'RUNNING'

                  running_count += 1
                  memory += instance['used_memory_in_bytes'] if instance['used_memory_in_bytes']
                  disk += instance['used_disk_in_bytes'] if instance['used_disk_in_bytes']
                  pcpu += instance['computed_pcpu'] if instance['computed_pcpu']
                end
              end

              row.push(instances_count,
                       running_count,
                       Utils.convert_bytes_to_megabytes(memory),
                       Utils.convert_bytes_to_megabytes(disk),
                       pcpu * 100)
            else
              row.push(nil, nil, nil, nil, nil)
            end

            if data['available_memory_ratio']
              row.push(data['available_memory_ratio'] * 100)
            else
              row.push(nil)
            end

            if data['available_disk_ratio']
              row.push(data['available_disk_ratio'] * 100)
            else
              row.push(nil)
            end

            row.push(nil, nil) # remaining_memory and remaining_disk

            hash[dea['name']] =
              {
                'doppler_dea' => nil,
                'varz_dea'    => dea
              }
          else
            row.push('OFFLINE')

            if data['start']
              row.push(DateTime.parse(data['start']).rfc3339)
            else
              row.push(nil)
            end

            row.push(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)

            # This last non-visible column is used to enable deletion of OFFLINE components
            row.push(dea['uri'])
          end

          items.push(row)
        end
      end

      if doppler_deas['connected']
        containers = @doppler.containers
        containers_connected = containers['connected']
        metrics_hash = {}
        if containers['connected']
          containers['items'].each_value do |container|
            return result unless @running
            Thread.pass

            origin = container[:origin]

            next unless origin == 'DEA'

            cpu          = container[:cpu_percentage]
            disk_bytes   = container[:disk_bytes]
            memory_bytes = container[:memory_bytes]

            key = "#{container[:ip]}:#{container[:index]}"

            metrics = metrics_hash[key]
            if metrics.nil?
              metrics =
                {
                  instances:    1,
                  cpu:          cpu,
                  disk_bytes:   disk_bytes,
                  memory_bytes: memory_bytes
                }
              metrics_hash[key] = metrics
            else
              metrics[:instances]    += 1
              metrics[:cpu]          += cpu
              metrics[:disk_bytes]   += disk_bytes
              metrics[:memory_bytes] += memory_bytes
            end
          end
        end

        doppler_deas['items'].each_pair do |key, dea|
          return result unless @running
          Thread.pass

          name = "#{dea['ip']}:#{dea['index']}"

          row = []

          row.push(name)
          row.push(dea['index'])
          row.push('doppler')
          row.push(Time.at(dea['timestamp'] / BILLION).to_datetime.rfc3339)

          if dea['connected']
            row.push('RUNNING')
            row.push(nil) # start
            row.push(nil) # stacks
            row.push(nil) # cpu
            row.push(nil) # mem

            row.push(dea['instances'])

            metrics = metrics_hash[name]
            if metrics
              row.push(metrics[:instances],
                       Utils.convert_bytes_to_megabytes(metrics[:memory_bytes]),
                       Utils.convert_bytes_to_megabytes(metrics[:disk_bytes]),
                       metrics[:cpu])
            elsif containers_connected
              row.push(0, 0.0, 0.0, 0.0)
            else
              row.push(nil, nil, nil, nil)
            end

            if dea['available_memory_ratio'] # Added in 235
              row.push(dea['available_memory_ratio'] * 100)
            else
              row.push(nil)
            end

            if dea['available_disk_ratio'] # Added in 235
              row.push(dea['available_disk_ratio'] * 100)
            else
              row.push(nil)
            end

            row.push(dea['remaining_memory'])
            row.push(dea['remaining_disk'])

            hash[name] =
              {
                'doppler_dea' => dea,
                'varz_dea'    => nil
              }
          else
            row.push('OFFLINE')

            row.push(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)

            # This last non-visible column is used to enable deletion of OFFLINE components
            row.push(key)
          end

          items.push(row)
        end
      end

      result(true, items, hash, (0..17).to_a, [0, 2, 3, 4, 5, 6])
    end
  end
end
