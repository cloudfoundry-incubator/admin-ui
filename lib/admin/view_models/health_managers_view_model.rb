require 'date'
require 'thread'
require_relative 'base_view_model'

module AdminUI
  class HealthManagersViewModel < AdminUI::BaseViewModel
    BILLION = 1000.0 * 1000.0 * 1000.0
    def do_items
      doppler_analyzers    = @doppler.analyzers
      varz_health_managers = @varz.health_managers

      # doppler_analyzers or varz_health_managers have to exist.  Other record types are optional
      return result unless doppler_analyzers['connected'] || varz_health_managers['connected']

      items = []
      hash  = {}

      if varz_health_managers['connected']
        varz_health_managers['items'].each do |health_manager|
          return result unless @running
          Thread.pass

          row = []

          row.push(health_manager['name'])
          row.push(health_manager['index'])
          row.push('varz')

          data = health_manager['data']

          if health_manager['connected']
            row.push('RUNNING')
            row.push(nil)
            row.push(data['numCPUS'])

            memory_stats = data['memoryStats']

            if memory_stats
              row.push(Utils.convert_bytes_to_megabytes(memory_stats['numBytesAllocated']))
            else
              row.push(nil)
            end

            hash[health_manager['name']] =
              {
                'doppler_analyzer'    => nil,
                'varz_health_manager' => health_manager
              }
          else
            row.push('OFFLINE')

            row.push(nil, nil, nil)

            row.push(health_manager['uri'])
          end

          items.push(row)
        end
      end

      if doppler_analyzers['connected']
        doppler_analyzers['items'].each_pair do |key, doppler_analyzer|
          return result unless @running
          Thread.pass

          name = "#{doppler_analyzer['ip']}:#{doppler_analyzer['index']}"

          row = []

          row.push(name)
          row.push(doppler_analyzer['index'])
          row.push('doppler')

          if doppler_analyzer['connected']
            row.push('RUNNING')
            row.push(Time.at(doppler_analyzer['timestamp'] / BILLION).to_datetime.rfc3339)
            row.push(doppler_analyzer['numCPUS'])

            if doppler_analyzer['memoryStats.numBytesAllocated']
              row.push(Utils.convert_bytes_to_megabytes(doppler_analyzer['memoryStats.numBytesAllocated']))
            else
              row.push(nil)
            end

            hash[name] =
              {
                'doppler_analyzer'    => doppler_analyzer,
                'varz_health_manager' => nil
              }
          else
            row.push('OFFLINE')

            row.push(nil, nil, nil)

            row.push(key)
          end

          items.push(row)
        end
      end

      result(true, items, hash, (0..6).to_a, [0, 2, 3, 4])
    end
  end
end
