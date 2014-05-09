require_relative 'base'

module AdminUI
  class BaseTab < AdminUI::Base
    def initialize(logger, cc, varz)
      super(logger)

      @cc   = cc
      @varz = varz
    end
  end
end
