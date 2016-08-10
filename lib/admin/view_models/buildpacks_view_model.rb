require 'date'
require 'thread'
require_relative 'base_view_model'

module AdminUI
  class BuildpacksViewModel < AdminUI::BaseViewModel
    def do_items
      buildpacks = @cc.buildpacks

      # buildpacks have to exist.  Other record types are optional
      return result unless buildpacks['connected']

      applications = @cc.applications

      applications_connected = applications['connected']

      application_counters = {}
      applications['items'].each do |application|
        detected_buildpack_guid = application[:detected_buildpack_guid]
        next if detected_buildpack_guid.nil?

        application_counters[detected_buildpack_guid] = 0 if application_counters[detected_buildpack_guid].nil?
        application_counters[detected_buildpack_guid] += 1
      end

      items = []
      hash  = {}

      buildpacks['items'].each do |buildpack|
        return result unless @running
        Thread.pass

        guid = buildpack[:guid]

        application_counter = application_counters[guid]

        row = []

        row.push(guid)
        row.push(buildpack[:name])
        row.push(guid)

        row.push(buildpack[:created_at].to_datetime.rfc3339)

        if buildpack[:updated_at]
          row.push(buildpack[:updated_at].to_datetime.rfc3339)
        else
          row.push(nil)
        end

        # Buildpack priority renamed to position.  Handle both.
        if buildpack[:position]
          row.push(buildpack[:position])
        else
          row.push(buildpack[:priority])
        end

        row.push(buildpack[:enabled])
        row.push(buildpack[:locked])

        if application_counter
          row.push(application_counter)
        elsif applications_connected
          row.push(0)
        else
          row.push(nil)
        end

        items.push(row)

        hash[guid] = buildpack
      end

      result(true, items, hash, (1..8).to_a, [1, 2, 3, 4, 6, 7])
    end
  end
end
