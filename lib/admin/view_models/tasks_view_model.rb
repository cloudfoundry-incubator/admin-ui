require_relative 'base'
require 'date'

module AdminUI
  class TasksViewModel < AdminUI::Base
    def initialize(logger, tasks)
      super(logger)

      @tasks = tasks
    end

    def do_items
      tasks = @tasks.tasks

      # tasks have to exist.  Other record types are optional
      return result unless tasks

      items = []

      tasks.each do |task|
        row = []

        row.push(task[:command])
        row.push(task[:state])
        row.push(DateTime.parse(Time.at(task[:started] / 1000.0).to_s).rfc3339)
        row.push(task[:id])

        items.push(row)
      end

      result(items, [0, 1, 2], [0, 1, 2])
    end
  end
end
