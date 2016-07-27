require_relative 'base_action'

module AdminUI
  class DisplayAction < AdminUI::BaseAction
    def do_items
      # Add default values for start and length to return all records
      start  = @params[:start] ? @params[:start].to_i : 0
      length = @params[:length] ? @params[:length].to_i : -1

      source_items = @source[:items]
      first = start
      last  = first + length - 1
      last = source_items.length - 1 if last.negative? || last > source_items.length - 1

      displayed = source_items.values_at(first..last)

      result(@source[:connected], displayed, @source[:detail_hash], @source[:searchable_columns], @source[:case_insensitive_sort_columns])
    end
  end
end
