require_relative 'base'
require 'date'
require 'thread'

module AdminUI
  class RoutersViewModel < AdminUI::Base
    def initialize(logger, cc, varz)
      super(logger)

      @cc   = cc
      @varz = varz
    end

    def do_items
      routers = @varz.routers

      # routers have to exist.  Other record types are optional
      return result unless routers['connected']

      applications  = @cc.applications
      organizations = @cc.organizations
      spaces        = @cc.spaces

      application_hash  = Hash[*applications['items'].map { |item| [item[:guid], item] }.flatten]
      organization_hash = Hash[*organizations['items'].map { |item| [item[:id], item] }.flatten]
      space_hash        = Hash[*spaces['items'].map { |item| [item[:id], item] }.flatten]

      items = []

      routers['items'].each do |router|
        Thread.pass
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

          top10_app_rows = []
          top10_app_requests = data['top10_app_requests']
          top10_app_requests.each do |top10_app|
            application = application_hash[top10_app['application_id']]
            next if application.nil?

            space        = space_hash[application[:space_id]]
            organization = space.nil? ? nil : organization_hash[space[:organization_id]]
            target       = organization.nil? ? nil : "#{ organization[:name] }/#{ space[:name]}"

            top10_app_rows.push('application'  => application[:name],
                                'rpm'          => top10_app['rpm'],
                                'rps'          => top10_app['rps'],
                                'target'       => target)
          end

          row.push('router'    => router,
                   'top10Apps' => top10_app_rows)
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
