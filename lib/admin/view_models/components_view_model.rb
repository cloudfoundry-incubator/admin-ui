require 'date'
require_relative 'base_view_model'

module AdminUI
  class ComponentsViewModel < AdminUI::BaseViewModel
    BILLION = 1000.0 * 1000.0 * 1000.0
    def do_items
      doppler_components = @doppler.components
      varz_components    = @varz.components

      # doppler_components or varz_components have to exist. Other record types are optional
      return result unless doppler_components['connected'] || varz_components['connected']

      items = []
      hash  = {}

      if varz_components['connected']
        varz_components['items'].each do |component|
          return result unless @running

          Thread.pass

          row = []

          row.push(component['name'])
          row.push(component['type'])
          row.push(component['index'].to_s)
          row.push('varz')
          row.push(nil) # Metrics date
          row.push(component['connected'] ? 'RUNNING' : 'OFFLINE')

          data = component['data']

          if data['start']
            row.push(DateTime.parse(data['start']).rfc3339)
          else
            row.push(nil)
          end

          # This non-visible column is used to provide a key for the component
          row.push(component['name'])

          # This last non-visible column is used to enable deletion of OFFLINE components
          row.push(component['uri'])

          items.push(row)

          hash[component['name']] =
            {
              'doppler_component' => nil,
              'varz_component'    => component
            }
        end
      end

      if doppler_components['connected']
        doppler_components['items'].each_pair do |key, component|
          return result unless @running

          Thread.pass

          name = "#{component['ip']}:#{component['index']}"

          row = []

          row.push(name)
          row.push(component['origin'])
          row.push(component['index'])
          row.push('doppler')
          row.push(Time.at(component['timestamp'] / BILLION).to_datetime.rfc3339)
          row.push(component['connected'] ? 'RUNNING' : 'OFFLINE')
          row.push(nil) # start

          # This non-visible column is used to provide a key for the component
          row.push(key)

          # This last non-visible column is used to enable deletion of OFFLINE components
          row.push(key)

          items.push(row)

          hash[key] =
            {
              'doppler_component' => component,
              'varz_component'    => nil
            }
        end
      end

      result(true, items, hash, (0..6).to_a, [0, 1, 3, 4, 5, 6])
    end
  end
end
