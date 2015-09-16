require_relative 'base_action'
require_relative 'display_action'
require_relative 'search_action'
require_relative 'sort_action'

module AdminUI
  class AllActions < AdminUI::BaseAction
    def items
      searched  = SearchAction.new(@logger, @source, @params).items
      sorted    = SortAction.new(@logger, searched, @params).items
      displayed = DisplayAction.new(@logger, sorted, @params).items

      {
        draw:            @params[:draw].to_i, # Cast draw to an integer to avoid cross-site scripting
        items:           result(displayed[:connected], displayed[:items]),
        recordsFiltered: sorted[:items].length,
        recordsTotal:    @source[:items].length
      }
    end
  end
end
