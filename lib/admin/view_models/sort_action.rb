require 'set'
require_relative 'base_action'

module AdminUI
  class SortAction < AdminUI::BaseAction
    def do_items
      sort_columns = SortColumn.create_array_from_params(@source, @params)

      return @source if sort_columns.length == 0

      sorted = @source[:items]
      sorted = sorted.sort do |a_row, b_row|
        # Start row compare at 0. Any difference among selected columns will terminate the inner loop
        compare = 0

        sort_columns.each do |sort_column|
          column   = sort_column.column
          a_column = a_row[column]
          b_column = b_row[column]

          if a_column
            if b_column
              if sort_column.case_insensitive
                compare = a_column.to_s.casecmp(b_column.to_s)
              else
                compare = a_column <=> b_column
              end
            else
              compare = 1
            end
          elsif b_column
            compare = -1
          end

          compare = -compare unless sort_column.ascending

          # Terminate looping if everything does not compare.  Two nil columns considered as equal.
          break unless compare == 0
        end

        next compare
      end

      result(@source[:connected], sorted, @source[:detail_hash], @source[:searchable_columns], @source[:case_insensitive_sort_columns])
    end
  end

  class SortColumn
    attr_reader :column, :ascending, :case_insensitive

    def initialize(column, ascending, case_insensitive)
      @column           = column
      @ascending        = ascending
      @case_insensitive = case_insensitive
    end

    def self.create_array_from_params(source, params)
      case_insensitive_sort_columns = source[:case_insensitive_sort_columns]
      i_sorting_cols                = params[:iSortingCols].to_i

      result = []

      sort_indices_used = Set.new

      index = 0
      while index < i_sorting_cols
        sort_col = params["iSortCol_#{index}"]
        unless sort_col.nil?
          i_sort_col = sort_col.to_i
          unless sort_indices_used.add?(i_sort_col).nil?
            s_sort_dir = params["sSortDir_#{index}"]
            if %w(asc desc).include?(s_sort_dir)
              case_insensitive_sort_column = case_insensitive_sort_columns.include?(i_sort_col)
              result.push(SortColumn.new(i_sort_col, s_sort_dir == 'asc', case_insensitive_sort_column))
            end
          end
        end

        index += 1
      end

      result
    end
  end
end
