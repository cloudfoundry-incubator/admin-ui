require_relative 'base'

module AdminUI
  class BaseAction < AdminUI::Base
    def initialize(logger, source, params)
      super(logger)

      @params = params
      @source = source
    end

    def items
      return @source unless @source[:connected]
      return @source if @source[:items].empty?

      super
    end
  end
end
