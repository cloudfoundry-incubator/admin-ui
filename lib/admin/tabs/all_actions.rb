require_relative 'base_action'
require_relative 'display_action'
require_relative 'search_action'
require_relative 'sort_action'

module AdminUI
  class AllActions
    def initialize(logger, source, params)
      @logger = logger
      @params = params
      @source = source
    end

    def items
      searched  = SearchAction.new(@logger, @source, @params).items
      sorted    = SortAction.new(@logger, searched, @params).items
      displayed = DisplayAction.new(@logger, sorted, @params).items

      { :sEcho                => @params[:sEcho],
        :iTotalRecords        => @source[:items].length,
        :iTotalDisplayRecords => sorted[:items].length,
        :items                => displayed
      }
    end
  end
end
