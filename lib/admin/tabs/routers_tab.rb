require_relative 'base'
require 'date'

module AdminUI
  class RoutersTab < AdminUI::Base
    def initialize(logger, varz)
      super(logger)

      @varz = varz
    end

    def do_items
      routers = @varz.routers

      # routers have to exist.  Other record types are optional
      return result unless routers['connected']

      items = []

      routers['items'].each do |router|
        row = []

        row.push(router['name'])

        data = router['data']

        if router['connected']
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

          row.push(data['droplets'])
          row.push(data['requests'])
          row.push(data['bad_requests'])

          row.push(router)
        else
          row.push(nil)
          row.push('OFFLINE')

          if data['start']
            row.push(DateTime.parse(data['start']).rfc3339)
          else
            row.push(nil)
          end

          row.push(nil, nil, nil, nil, nil, nil, nil)

          row.push(router['uri'])
        end

        items.push(row)
      end

      result(items, (0..9).to_a, [0, 2, 3])
    end
  end
end
