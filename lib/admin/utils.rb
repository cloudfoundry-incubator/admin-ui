require 'net/http'
require 'uri'

module AdminUI
  class Utils
    HTTP_DELETE = 'DELETE'
    HTTP_GET    = 'GET'
    HTTP_HEAD   = 'HEAD'
    HTTP_PUT    = 'PUT'
    HTTP_POST   = 'POST'

    HTTP_METHODS_MAP = {
      HTTP_DELETE => Net::HTTP::Delete,
      HTTP_GET    => Net::HTTP::Get,
      HTTP_HEAD   => Net::HTTP::Head,
      HTTP_PUT    => Net::HTTP::Put,
      HTTP_POST   => Net::HTTP::Post
    }

    def self.time_in_milliseconds(time = Time.now)
      (time.to_f * 1000).to_i
    end

    def self.get_method_class(method_string)
      HTTP_METHODS_MAP[method_string.upcase]
    end

    def self.http_request(config, uri_string, method = HTTP_GET, basic_auth_array = nil, body = nil, authorization_header = nil)
      uri = URI.parse(uri_string)

      path  = uri.path
      path += "?#{ uri.query }" unless uri.query.nil?

      http             = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl     = uri.scheme.to_s.downcase == 'https'
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if config.cloud_controller_ssl_verify_none
      request          = get_method_class(method).new(path)

      request.basic_auth(basic_auth_array[0], basic_auth_array[1]) unless basic_auth_array.nil? || basic_auth_array.length < 2
      request['Authorization'] = authorization_header unless authorization_header.nil?

      request.body = body if body

      http.request(request)
    end
  end
end
