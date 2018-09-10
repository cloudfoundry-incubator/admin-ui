require 'date'
require_relative 'base_view_model'

module AdminUI
  class LogsViewModel < AdminUI::BaseViewModel
    def do_items
      logs = @log_files.infos

      # logs have to exist. Other record types are optional
      return result unless logs

      items = []

      logs.each do |log|
        return result unless @running

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
