require 'date'
require 'thread'
require_relative 'base_view_model'

module AdminUI
  class ComponentsViewModel < AdminUI::BaseViewModel
    def do_items
      components = @varz.components

      # components have to exist.  Other record types are optional
      return result unless components['connected']

      items = []
      hash  = {}

      components['items'].each do |component|
        return result unless @running
        Thread.pass

        row = []

        row.push(component['name'])

        row.push(component['type'])
        row.push(component['index'])
        row.push(component['connected'] ? 'RUNNING' : 'OFFLINE')

        data = component['data']

        if data['start']
          row.push(DateTime.parse(data['start']).rfc3339)
        else
          row.push(nil)
        end

        row.push(component['uri'])

        items.push(row)

        hash[component['name']] = component
      end

      result(true, items, hash, (0..4).to_a, [0, 1, 3, 4])
    end
  end
end
