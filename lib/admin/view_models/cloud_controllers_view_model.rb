require_relative 'base'
require 'date'
require 'thread'

module AdminUI
  class CloudControllersViewModel < AdminUI::Base
    def initialize(logger, varz)
      super(logger)

      @varz = varz
    end

    def do_items
      cloud_controllers = @varz.cloud_controllers(false)

      # cloud_controllers have to exist.  Other record types are optional
      return result unless cloud_controllers['connected']

      items = []

      cloud_controllers['items'].each do |cloud_controller|
        Thread.pass
        row = []

        row.push(cloud_controller['name'])

        data = cloud_controller['data']

        if cloud_controller['connected']
          row.push(data['index'])
          row.push('RUNNING')
          row.push(DateTime.parse(data['start']).rfc3339)
          row.push(data['num_cores'])
          row.push(data['cpu'])

          # Conditional logic since mem becomes mem_bytes in 157
          if data['mem']
            row.push(data['mem'])
          elsif data['mem_bytes']
            row.push(data['mem_bytes'])
          else
            row.push(nil)
          end

          row.push(cloud_controller)
        else
          row.push(nil)
          row.push('OFFLINE')

          if data['start']
            row.push(DateTime.parse(data['start']).rfc3339)
          else
            row.push(nil)
          end

          row.push(nil, nil, nil, nil)

          row.push(cloud_controller['uri'])
        end

        items.push(row)
      end

      result(items, (0..6).to_a, [0, 2, 3])
    end
  end
end
