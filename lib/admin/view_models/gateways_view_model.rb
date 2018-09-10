require 'date'
require_relative 'base_view_model'

module AdminUI
  class GatewaysViewModel < AdminUI::BaseViewModel
    def do_items
      gateways = @varz.gateways

      # gateways have to exist. Other record types are optional
      return result unless gateways['connected']

      items = []
      hash  = {}

      gateways['items'].each do |gateway|
        return result unless @running

        Thread.pass

        row = []

        row.push(gateway['name'])
        row.push(gateway['index'])
        row.push('varz')

        data = gateway['data']

        if gateway['connected']
          row.push('RUNNING')
          row.push(DateTime.parse(data['start']).rfc3339)
          row.push(data['config']['service']['description'])
          row.push(data['cpu'])

          # Conditional logic since mem becomes mem_bytes in 157
          if data['mem']
            row.push(Utils.convert_kilobytes_to_megabytes(data['mem']))
          elsif data['mem_bytes']
            row.push(Utils.convert_bytes_to_megabytes(data['mem_bytes']))
          else
            row.push(nil)
          end

          # For some reason nodes is not an array.
          num_nodes = 0
          num_nodes = data['nodes'].length if data['nodes']
          row.push(num_nodes)

          capacity = 0
          data['nodes'].each_value do |node|
            capacity += node['available_capacity'] if node['available_capacity']&.positive?
          end

          row.push(capacity)

          hash[gateway['name']] = gateway
        else
          row.push('OFFLINE')

          if data['start']
            row.push(DateTime.parse(data['start']).rfc3339)
          else
            row.push(nil)
          end

          row.push(nil, nil, nil, nil, nil, nil)

          # This last non-visible column is used to enable deletion of OFFLINE components
          row.push(gateway['uri'])
        end

        items.push(row)
      end

      result(true, items, hash, (0..9).to_a, [0, 2, 3, 4, 5])
    end
  end
end
