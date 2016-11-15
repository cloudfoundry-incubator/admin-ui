require 'yajl'

module AdminUI
  class CCRestClientResponseError < StandardError
    attr_reader :cf_code, :cf_error_code, :http_code

    def initialize(response)
      @http_code = response.code

      begin
        json = Yajl::Parser.parse(response.body)
      rescue
        json = nil
      end

      if json.is_a?(Hash)
        errors = json['errors']
        if errors.nil?
          # v2 response is { code: 'code', description: 'description', error_code: 'error_code' }
          message        = json['description']
          message        = json['message'] if message.nil? # This handles UAA cases
          @cf_code       = json['code']
          @cf_error_code = json['error_code']
        elsif errors.is_a?(Array)
          # v3 response is { error: [{ code: 'code', detail: 'detail', title: 'title' }] }
          if errors.length.positive?
            error = errors[0]
            if error.is_a?(Hash)
              message        = error['detail']
              @cf_code       = error['code']
              @cf_error_code = error['title']
            end
          end
        end
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
