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

      { :sEcho                => @params[:sEcho].to_i, # Cast sEcho to an integer to avoid cross-site scripting
        :iTotalRecords        => @source[:items].length,
        :iTotalDisplayRecords => sorted[:items].length,
        :items                => result(displayed[:connected], displayed[:items])
      }
    end
  end
end
