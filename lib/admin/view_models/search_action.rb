require_relative 'base_action'

module AdminUI
  class SearchAction < AdminUI::BaseAction
    def do_items
      s_search = @params[:sSearch]

      return @source if s_search.nil? || s_search == ''

      searchable_columns = @source[:searchable_columns]

      downcase_s_search = s_search.downcase

      searched = @source[:items].select do |row|
        included = false
        searchable_columns.each do |column|
          value = row[column]
          next if value.nil?
          next unless value.to_s.downcase.include?(downcase_s_search)
          included = true
          break
        end
        included
      end

      result(@source[:connected], searched, @source[:detail_hash], @source[:searchable_columns], @source[:case_insensitive_sort_columns])
    end
  end
end
