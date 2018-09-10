require 'date'
require_relative 'base_view_model'
require_relative '../utils'

module AdminUI
  class StatsViewModel < AdminUI::BaseViewModel
    def do_items
      statistics        = @stats.stats
      current_statistic = @stats.current_stats

      items = []

      items.push(to_row(current_statistic)) if current_statistic

      statistics.each do |statistic|
        return result unless @running

        Thread.pass

        items.push(to_row(Utils.symbolize_keys(statistic)))
      end

      result(true, items, nil, (0..8).to_a, [0])
    end

    private

    def to_row(statistic)
      row = []

      row.push(Time.at(statistic[:timestamp] / 1000.0).to_datetime.rfc3339)
      row.push(statistic[:organizations])
      row.push(statistic[:spaces])
      row.push(statistic[:users])
      row.push(statistic[:apps])
      row.push(statistic[:total_instances])
      row.push(statistic[:running_instances])
      row.push(statistic[:deas])
      row.push(statistic[:cells])
      row.push(statistic)

      row
    end
  end
end
