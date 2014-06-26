require_relative 'base'
require 'date'
require 'thread'
require_relative '../utils'

module AdminUI
  class StatsViewModel < AdminUI::Base
    def initialize(logger, stats)
      super(logger)

      @stats = stats
    end

    def do_items
      statistics        = @stats.stats
      current_statistic = @stats.current_stats(false)

      items = []

      items.push(to_row(current_statistic)) if current_statistic

      statistics['items'].each do |statistic|
        Thread.pass
        items.push(to_row(Utils.symbolize_keys(statistic)))
      end

      result(items, (0..7).to_a, [0])
    end

    private

    def to_row(statistic)
      row = []

      row.push(DateTime.parse(Time.at(statistic[:timestamp] / 1000.0).to_s).rfc3339)
      row.push(statistic[:organizations])
      row.push(statistic[:spaces])
      row.push(statistic[:users])
      row.push(statistic[:apps])
      row.push(statistic[:total_instances])
      row.push(statistic[:running_instances])
      row.push(statistic[:deas])
      row.push(statistic)

      row
    end
  end
end
