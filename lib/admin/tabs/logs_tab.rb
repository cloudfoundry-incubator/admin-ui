require_relative 'base_tab'
require 'date'

module AdminUI
  class LogsTab < AdminUI::BaseTab
    def initialize(logger, cc, varz, log_files)
      super(logger, cc, varz)

      @log_files = log_files
    end

    def do_items
      logs = @log_files.infos

      # logs have to exist.  Other record types are optional
      return result unless logs

      items = []

      logs.each do |log|
        row = []

        row.push(log[:path])
        row.push(log[:size])
        row.push(DateTime.parse(Time.at(log[:time] / 1000.0).utc.to_s).rfc3339)

        row.push(log)

        items.push(row)
      end

      result(items, (0..2).to_a, (0..2).to_a)
    end
  end
end
