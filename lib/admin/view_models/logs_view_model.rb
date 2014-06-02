require_relative 'base'
require 'date'

module AdminUI
  class LogsViewModel < AdminUI::Base
    def initialize(logger, log_files)
      super(logger)

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

      result(items, [0, 1, 2], [0, 2])
    end
  end
end
