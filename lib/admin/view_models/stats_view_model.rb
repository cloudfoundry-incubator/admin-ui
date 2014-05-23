require_relative 'base'
require 'date'
require_relative '../utils'

module AdminUI
  class StatsViewModel < AdminUI::Base
    def initialize(logger, stats)
      super(logger)

      @stats = stats
    end

    def do_items
      statistics        = @stats.stats
      current_statistic = @stats.current_stats

      items = []

      items.push(to_row(current_statistic)) if current_statistic

      statistics['items'].each do |statistic|
        items.push(to_row(Utils.symbolize_keys(statistic)))
      end

      result(items, (0..7).to_a, (0..0).to_a)
    end

    private

    def to_row(statistic)
      row = []

      row.push(DateTime.parse(Time.at(statistic[:timestamp] / 1000.0).utc.to_s).rfc3339)
      row.push(statistic[:organizations]     || 0)
      row.push(statistic[:spaces]            || 0)
      row.push(statistic[:users]             || 0)
      row.push(statistic[:apps]              || 0)
      row.push(statistic[:total_instances]   || 0)
      row.push(statistic[:running_instances] || 0)
      row.push(statistic[:deas]              || 0)
      row.push(statistic)

      row
    end
  end
end
