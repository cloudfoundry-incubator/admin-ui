require_relative 'base_action'

module AdminUI
  class SortAction < AdminUI::BaseAction
    def do_items
      i_sorting_cols = @params[:iSortingCols].to_i

      # TODO: Currently limiting to a single column sort since that is all the UI side is currently supporting
      return @source unless i_sorting_cols == 1

      i_sort_col = @params['iSortCol_0'].to_i
      s_sort_dir = @params['sSortDir_0']

      sorted = @source[:items]
      if @source[:case_insensitive_sort_columns].include?(i_sort_col)
        if s_sort_dir == 'asc'
          sorted = sorted.sort do |a, b|
            a_col = a[i_sort_col]
            b_col = b[i_sort_col]
            next a_col.to_s.downcase <=> b_col.to_s.downcase if a_col && b_col
            next 1 if a_col
            next -1 if b_col
            next 0
          end
        else
          sorted = sorted.sort do |a, b|
            a_col = a[i_sort_col]
            b_col = b[i_sort_col]
            next b_col.to_s.downcase <=> a_col.to_s.downcase if a_col && b_col
            next 1 if b_col
            next -1 if a_col
            next 0
          end
        end
      else
        if s_sort_dir == 'asc'
          sorted = sorted.sort do |a, b|
            a_col = a[i_sort_col]
            b_col = b[i_sort_col]
            next a_col <=> b_col if a_col && b_col
            next 1 if a_col
            next -1 if b_col
            next 0
          end
        else
          sorted = sorted.sort do |a, b|
            a_col = a[i_sort_col]
            b_col = b[i_sort_col]
            next b_col <=> a_col if a_col && b_col
            next 1 if b_col
            next -1 if a_col
            next 0
          end
        end
      end

      result(sorted, @source[:visible_columns], @source[:case_insensitive_sort_columns])
    end
  end
end
