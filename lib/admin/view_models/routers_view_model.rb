require 'date'
require 'thread'
require_relative 'base_view_model'

module AdminUI
  class RoutersViewModel < AdminUI::BaseViewModel
    def do_items
      routers = @varz.routers

      # routers have to exist.  Other record types are optional
      return result unless routers['connected']

      applications  = @cc.applications
      organizations = @cc.organizations
      spaces        = @cc.spaces

      application_hash  = Hash[applications['items'].map { |item| [item[:guid], item] }]
      organization_hash = Hash[organizations['items'].map { |item| [item[:id], item] }]
      space_hash        = Hash[spaces['items'].map { |item| [item[:id], item] }]

      items = []
      hash  = {}

      routers['items'].each do |router|
        return result unless @running
        Thread.pass

        row = []

        row.push(router['name'])
        row.push(router['index'])
        row.push('varz')

        data = router['data']

        if router['connected']
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

          top10_app_rows = []
          top10_app_requests = data['top10_app_requests']
          top10_app_requests.each do |top10_app|
            application = application_hash[top10_app['application_id']]
            next if application.nil?

            space        = space_hash[application[:space_id]]
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
              'router'    => router,
              'top10Apps' => top10_app_rows
            }
        else
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

      result(true, items, hash, (0..10).to_a, [0, 2, 3, 4])
    end
  end
end
