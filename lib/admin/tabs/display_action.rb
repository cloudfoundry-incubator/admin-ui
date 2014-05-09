require_relative 'base_action'

module AdminUI
  class DisplayAction < AdminUI::BaseAction
    def do_items
      i_display_start  = @params[:iDisplayStart].to_i
      i_display_length = @params[:iDisplayLength].to_i

      source_items = @source[:items]
      first = i_display_start
      last  = first + i_display_length - 1
      last = source_items.length - 1 if last < 0 || last > source_items.length - 1

      displayed = source_items.values_at(first..last)

      result(displayed, @source[:visible_columns], @source[:case_insensitive_sort_columns])
    end
  end
end
