require_relative 'base'

module AdminUI
  class BaseTab < AdminUI::Base
    def initialize(logger, cc, varz)
      super(logger)

      @cc   = cc
      @varz = varz
    end

    def convert_bytes_to_megabytes(bytes)
      (bytes / 1_048_576.0).round
    end
  end
end
