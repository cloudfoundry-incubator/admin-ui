require 'date'
require_relative 'base_view_model'

module AdminUI
  class CellsViewModel < AdminUI::BaseViewModel
    BILLION = 1000.0 * 1000.0 * 1000.0
    def do_items
      reps = @doppler.reps

      # reps have to exist. Other record types are optional
      return result unless reps['connected']

      items = []
      hash  = {}

      reps['items'].each_pair do |key, rep|
        return result unless @running

        Thread.pass

        name = "#{rep['ip']}:#{rep['index']}"

        row = []

        row.push(name)
        row.push(rep['ip'])
        row.push(rep['index'])
        row.push('doppler')
        row.push(Time.at(rep['timestamp'] / BILLION).to_datetime.rfc3339)

        if rep['connected']
          row.push('RUNNING')
          row.push(rep['numCPUS'])

          if rep['memoryStats.numBytesAllocated']
            row.push(Utils.convert_bytes_to_megabytes(rep['memoryStats.numBytesAllocated']))
          else
            row.push(nil)
          end

          if rep['memoryStats.numBytesAllocatedHeap']
            row.push(Utils.convert_bytes_to_megabytes(rep['memoryStats.numBytesAllocatedHeap']))
          else
            row.push(nil)
          end

          if rep['memoryStats.numBytesAllocatedStack']
            row.push(Utils.convert_bytes_to_megabytes(rep['memoryStats.numBytesAllocatedStack']))
          else
            row.push(nil)
          end

          row.push(rep['CapacityTotalContainers'])
          row.push(rep['CapacityRemainingContainers'])
          row.push(rep['ContainerCount'])
          row.push(rep['CapacityTotalMemory'])
          row.push(rep['CapacityRemainingMemory'])
          row.push(rep['CapacityTotalDisk'])
          row.push(rep['CapacityRemainingDisk'])
        else
          row.push('OFFLINE')
          row.push(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)

          # This last non-visible column is used to enable deletion of OFFLINE components
          row.push(key)
        end

        hash[name] = rep
        items.push(row)
      end

      result(true, items, hash, (0..16).to_a, [3, 4, 5])
    end
  end
end
