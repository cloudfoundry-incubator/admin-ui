require 'json'

module AdminUI
  class CCRestClientResponseError < StandardError
    attr_reader :cf_code, :cf_error_code, :http_code

    def initialize(response)
      @http_code = response.code

      begin
        hash = JSON.parse(response.body)
      rescue
        hash = nil
      end

      if hash.is_a?(Hash)
        message        = hash['description']
        @cf_code       = hash['code']
        @cf_error_code = hash['error_code']
      end

      message = response.message if message.nil?

      super(message)
    end

    def to_h
      {
        cf_code:       cf_code,
        cf_error_code: cf_error_code,
        http_code:     http_code,
        message:       message
      }
    end
  end
end
