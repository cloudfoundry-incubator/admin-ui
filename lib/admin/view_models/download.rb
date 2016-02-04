require 'csv'
require 'tempfile'
require 'uri'
require 'yajl'

module AdminUI
  class Download
    def self.download(body, view_model_type, view_model)
      file = Tempfile.new([view_model_type, '.csv'])

      decoded = URI.decode_www_form(body)

      heading_count = 9999

      CSV.open(file.path, 'wb') do |csv|
        if !decoded.empty? && (decoded[0].length == 2) && (decoded[0][0] == 'headings')
          headings = decoded[0][1]
          parsed = Yajl::Parser.parse(headings)
          heading_count = parsed.length
          csv << parsed
        end

        view_model[:items].each do |row|
          non_nil_row = []
          column_index = 0
          row.each do |column|
            non_nil_row.push(column.nil? ? '' : column)
            column_index += 1
            break if column_index >= heading_count
          end
          csv << non_nil_row
        end
      end

      file
    end
  end
end
