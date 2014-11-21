require_relative 'base'
require 'date'
require 'thread'

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
        Thread.pass
        row = []

        row.push(log[:path])
        row.push(log[:size])
        row.push(Time.at(log[:time] / 1000.0).to_datetime.rfc3339)

        row.push(log)

        items.push(row)
      end

      result(true, items, nil, [0, 1, 2], [0, 2])
    end
  end
end
