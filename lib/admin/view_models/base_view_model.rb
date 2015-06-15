require_relative 'base'

module AdminUI
  class BaseViewModel < AdminUI::Base
    def initialize(logger, cc, log_files, nats, stats, tasks, varz)
      super(logger)

      @cc        = cc
      @log_files = log_files
      @nats      = nats
      @stats     = stats
      @tasks     = tasks
      @varz      = varz

      @running = true
    end

    def shutdown
      @running = false
    end
  end
end
