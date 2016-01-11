require_relative 'base'

module AdminUI
  class BaseViewModel < AdminUI::Base
    def initialize(logger, cc, doppler, log_files, stats, varz, testing)
      super(logger)

      @cc        = cc
      @doppler   = doppler
      @log_files = log_files
      @stats     = stats
      @varz      = varz
      @testing   = testing

      @running = true
    end

    def shutdown
      @running = false
    end
  end
end
