require 'date'
require_relative 'base_view_model'

module AdminUI
  class CloudControllersViewModel < AdminUI::BaseViewModel
    def do_items
      cloud_controllers = @varz.cloud_controllers

      # cloud_controllers have to exist. Other record types are optional
      return result unless cloud_controllers['connected']

      items = []
      hash  = {}

      cloud_controllers['items'].each do |cloud_controller|
        return result unless @running

        Thread.pass

        row = []

        row.push(cloud_controller['name'])
        row.push(cloud_controller['index'])
        row.push('varz')

        data = cloud_controller['data']

        if cloud_controller['connected']
          row.push('RUNNING')
          row.push(DateTime.parse(data['start']).rfc3339)
          row.push(data['num_cores'])
          row.push(data['cpu'])

          if data['mem_bytes']
            row.push(Utils.convert_bytes_to_megabytes(data['mem_bytes']))
          else
            row.push(nil)
          end

          hash[cloud_controller['name']] = cloud_controller
        else
          row.push('OFFLINE')

          if data['start']
            row.push(DateTime.parse(data['start']).rfc3339)
          else
            row.push(nil)
          end

          row.push(nil, nil, nil, nil)

          # This last non-visible column is used to enable deletion of OFFLINE components
          row.push(cloud_controller['uri'])
        end

        items.push(row)
      end

      result(true, items, hash, (0..7).to_a, [0, 2, 3, 4])
    end
  end
end
