require_relative 'base_action'

module AdminUI
  class SearchAction < AdminUI::BaseAction
    def do_items
      search = @params[:search]

      return @source if search.nil?
      return @source unless search.is_a?(Hash)

      search_value = search[:value]

      return @source if search_value.nil? || search_value == ''

      searchable_columns = @source[:searchable_columns]

      downcase_search_value = search_value.downcase

      searched = @source[:items].select do |row|
        included = false
        searchable_columns.each do |column|
          value = row[column]
          next if value.nil?
          next unless value.to_s.downcase.include?(downcase_search_value)

          included = true
          break
        end
        included
      end

      result(@source[:connected], searched, @source[:detail_hash], @source[:searchable_columns], @source[:case_insensitive_sort_columns])
    end
  end
end
