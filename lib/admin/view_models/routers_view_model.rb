require 'date'
require_relative 'base_view_model'

module AdminUI
  class RoutersViewModel < AdminUI::BaseViewModel
    BILLION = 1000.0 * 1000.0 * 1000.0
    def do_items
      doppler_gorouters = @doppler.gorouters
      varz_routers      = @varz.routers

      # doppler_gorouters or varz_routers have to exist. Other record types are optional
      return result unless doppler_gorouters['connected'] || varz_routers['connected']

      applications  = @cc.applications
      organizations = @cc.organizations
      spaces        = @cc.spaces

      application_hash  = applications['items'].map { |item| [item[:guid], item] }.to_h
      organization_hash = organizations['items'].map { |item| [item[:id], item] }.to_h
      space_hash        = spaces['items'].map { |item| [item[:guid], item] }.to_h

      items = []
      hash  = {}

      if varz_routers['connected']
        varz_routers['items'].each do |router|
          return result unless @running

          Thread.pass

          row = []

          row.push(router['name'])
          row.push(router['index'].to_s)
          row.push('varz')
          row.push(nil) # Metrics date

          data = router['data']

          if router['connected']
            row.push('RUNNING')
            row.push(DateTime.parse(data['start']).rfc3339)
            row.push(data['num_cores'])
            row.push(data['cpu'])

            if data['mem_bytes']
              row.push(Utils.convert_bytes_to_megabytes(data['mem_bytes']))
            else
              row.push(nil)
            end

            row.push(data['droplets'])
            row.push(data['requests'])
            row.push(data['bad_requests'])

            top10_app_rows = []
            top10_app_requests = data['top10_app_requests']
            top10_app_requests.each do |top10_app|
              application = application_hash[top10_app['application_id']]
              next if application.nil?

              space        = space_hash[application[:space_guid]]
              organization = space.nil? ? nil : organization_hash[space[:organization_id]]
              target       = organization.nil? ? nil : "#{organization[:name]}/#{space[:name]}"

              top10_app_rows.push('guid'   => application[:guid],
                                  'name'   => application[:name],
                                  'rpm'    => top10_app['rpm'],
                                  'rps'    => top10_app['rps'],
                                  'target' => target)
            end

            hash[router['name']] =
              {
                'doppler_gorouter' => nil,
                'top_10_apps'      => top10_app_rows,
                'varz_router'      => router
              }
          else
            row.push('OFFLINE')

            if data['start']
              row.push(DateTime.parse(data['start']).rfc3339)
            else
              row.push(nil)
            end

            row.push(nil, nil, nil, nil, nil, nil)

            # This last non-visible column is used to enable deletion of OFFLINE components
            row.push(router['uri'])
          end

          items.push(row)
        end
      end

      if doppler_gorouters['connected']
        doppler_gorouters['items'].each_pair do |key, router|
          return result unless @running

          Thread.pass

          name = "#{router['ip']}:#{router['index']}"

          row = []

          row.push(name)
          row.push(router['index'])
          row.push('doppler')
          row.push(Time.at(router['timestamp'] / BILLION).to_datetime.rfc3339)

          if router['connected']
            row.push('RUNNING')
            row.push(nil) # start
            row.push(router['numCPUS'])
            row.push(nil) # CPU

            if router['memoryStats.numBytesAllocated']
              row.push(Utils.convert_bytes_to_megabytes(router['memoryStats.numBytesAllocated']))
            else
              row.push(nil)
            end

            row.push(nil) # droplets
            row.push(nil) # requests
            row.push(nil) # bad_requests

            hash[name] =
              {
                'doppler_gorouter' => router,
                'top_10_apps'      => nil,
                'varz_router'      => nil
              }
          else
            row.push('OFFLINE')

            row.push(nil, nil, nil, nil, nil, nil, nil)

            # This last non-visible column is used to enable deletion of OFFLINE components
            row.push(key)
          end

          items.push(row)
        end
      end

      result(true, items, hash, (0..11).to_a, [0, 2, 3, 4, 5])
    end
  end
end
