require 'date'
require_relative 'base_view_model'

module AdminUI
  class HealthManagersViewModel < AdminUI::BaseViewModel
    BILLION = 1000.0 * 1000.0 * 1000.0
    def do_items
      doppler_analyzers = @doppler.analyzers

      # doppler_analyzers have to exist. Other record types are optional
      return result unless doppler_analyzers['connected']

      items = []
      hash  = {}

      doppler_analyzers['items'].each_pair do |key, doppler_analyzer|
        return result unless @running

        Thread.pass

        name = "#{doppler_analyzer['ip']}:#{doppler_analyzer['index']}"

        row = []

        row.push(name)
        row.push(doppler_analyzer['index'])
        row.push('doppler')
        row.push(Time.at(doppler_analyzer['timestamp'] / BILLION).to_datetime.rfc3339)

        if doppler_analyzer['connected']
          row.push('RUNNING')
          row.push(doppler_analyzer['numCPUS'])

          if doppler_analyzer['memoryStats.numBytesAllocated']
            row.push(Utils.convert_bytes_to_megabytes(doppler_analyzer['memoryStats.numBytesAllocated']))
          else
            row.push(nil)
          end

          hash[name] = doppler_analyzer
        else
          row.push('OFFLINE')

          row.push(nil, nil)

          # This last non-visible column is used to enable deletion of OFFLINE components
          row.push(key)
        end

        items.push(row)
      end

      result(true, items, hash, (0..6).to_a, [0, 2, 3, 4])
    end
  end
end
