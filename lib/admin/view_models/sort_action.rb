require 'set'
require_relative 'base_action'

module AdminUI
  class SortAction < AdminUI::BaseAction
    def do_items
      sort_columns = SortColumn.create_array_from_params(@source, @params)

      return @source if sort_columns.empty?

      sorted = @source[:items]
      sorted = sorted.sort do |a_row, b_row|
        # Start row compare at 0. Any difference among selected columns will terminate the inner loop
        compare = 0

        sort_columns.each do |sort_column|
          column   = sort_column.column
          a_column = a_row[column]
          b_column = b_row[column]

          compare = if a_column
                      if b_column
                        if sort_column.case_insensitive
                          a_column.to_s.casecmp(b_column.to_s)
                        else
                          a_column <=> b_column
                        end
                      else
                        1
                      end
                    elsif b_column
                      -1
                    else
                      0
                    end

          compare = -compare unless sort_column.ascending

          # Terminate looping if everything does not compare. Two nil columns considered as equal.
          break unless compare.zero?
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
      order                         = params[:order]

      result = []

      return result if order.nil?
      return result unless order.is_a?(Hash)

      sort_indices_used = Set.new

      order.each_value do |value|
        next unless value.is_a?(Hash)

        sort_index = value[:column].to_i
        sort_dir   = value[:dir]

        next if sort_indices_used.add?(sort_index).nil?
        next unless %w[asc desc].include?(sort_dir)

        case_insensitive_sort_column = case_insensitive_sort_columns.include?(sort_index)
        result.push(SortColumn.new(sort_index, sort_dir == 'asc', case_insensitive_sort_column))
      end

      result
    end
  end
end
