require 'date'
require 'thread'
require_relative 'base_view_model'

module AdminUI
  class BuildpacksViewModel < AdminUI::BaseViewModel
    def do_items
      buildpacks = @cc.buildpacks

      # buildpacks have to exist.  Other record types are optional
      return result unless buildpacks['connected']

      items = []
      hash  = {}

      buildpacks['items'].each do |buildpack|
        return result unless @running
        Thread.pass

        guid = buildpack[:guid]

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

        items.push(row)

        hash[guid] = buildpack
      end

      result(true, items, hash, (1..7).to_a, [1, 2, 3, 4, 6, 7])
    end
  end
end
