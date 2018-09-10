require 'date'
require_relative 'base_view_model'

module AdminUI
  class DEAsViewModel < AdminUI::BaseViewModel
    BILLION = 1000.0 * 1000.0 * 1000.0
    def do_items
      doppler_deas = @doppler.deas

      # doppler_deas has to exist. Other record types are optional
      return result unless doppler_deas['connected']

      items = []
      hash  = {}

      containers = @doppler.containers
      containers_connected = containers['connected']
      metrics_hash = {}
      if containers_connected
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

          hash[name] = dea
        else
          row.push('OFFLINE')

          row.push(nil, nil, nil, nil, nil, nil, nil, nil, nil)

          # This last non-visible column is used to enable deletion of OFFLINE components
          row.push(key)
        end

        items.push(row)
      end

      result(true, items, hash, (0..13).to_a, [0, 2, 3, 4])
    end
  end
end
