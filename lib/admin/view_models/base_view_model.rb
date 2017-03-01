require_relative 'base'

module AdminUI
  class BaseViewModel < AdminUI::Base
    def initialize(logger, cc, cc_rest_client, doppler, log_files, stats, varz, testing)
      super(logger)

      @cc             = cc
      @cc_rest_client = cc_rest_client
      @doppler        = doppler
      @log_files      = log_files
      @stats          = stats
      @varz           = varz
      @testing        = testing

      @running = true
    end

    def shutdown
      @running = false
    end
  end
end
