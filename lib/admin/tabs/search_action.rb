require_relative 'base_action'

module AdminUI
  class SearchAction < AdminUI::BaseAction
    def do_items
      s_search = @params[:sSearch]

      return @source if s_search.nil? || s_search == ''

      visible_columns = @source[:visible_columns]

      downcase_s_search = s_search.downcase

      searched = @source[:items].select do |row|
        included = false
        visible_columns.each do |column|
          value = row[column]
          unless value.nil?
            if value.to_s.downcase.include?(downcase_s_search)
              included = true
              break
            end
          end
        end
        included
      end

      result(searched, @source[:visible_columns], @source[:case_insensitive_sort_columns])
    end
  end
end
