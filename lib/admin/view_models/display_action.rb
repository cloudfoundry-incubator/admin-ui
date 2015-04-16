require_relative 'base_action'

module AdminUI
  class DisplayAction < AdminUI::BaseAction
    def do_items
      # Add default values for start and length to return all records
      i_display_start  = @params[:iDisplayStart] ? @params[:iDisplayStart].to_i : 0
      i_display_length = @params[:iDisplayLength] ? @params[:iDisplayLength].to_i : -1

      source_items = @source[:items]
      first = i_display_start
      last  = first + i_display_length - 1
      last = source_items.length - 1 if last < 0 || last > source_items.length - 1

      displayed = source_items.values_at(first..last)

      result(@source[:connected], displayed, @source[:detail_hash], @source[:searchable_columns], @source[:case_insensitive_sort_columns])
    end
  end
end
