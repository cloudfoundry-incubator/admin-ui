require 'net/http'
require 'uri'

module AdminUI
  class Utils
    def self.time_in_milliseconds(time = Time.now)
      (time.to_f * 1000).to_i
    end

    def self.http_get(config, uri_string, basic_auth_array = nil, authorization_header = nil)
      uri = URI.parse(uri_string)

      path  = uri.path
      path += "?#{ uri.query }" unless uri.query.nil?

      http             = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl     = uri.scheme.to_s.downcase == 'https'
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if config.cloud_controller_ssl_verify_none
      request          = Net::HTTP::Get.new(path)

      request.basic_auth(basic_auth_array[0], basic_auth_array[1]) unless basic_auth_array.nil? || basic_auth_array.length < 2
      request['Authorization'] = authorization_header unless authorization_header.nil?

      http.request(request)
    end

    def self.http_post(config, uri_string, body, authorization_header)
      uri = URI.parse(uri_string)

      path  = uri.path
      path += "?#{ uri.query }" unless uri.query.nil?

      http             = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl     = uri.scheme.to_s.downcase == 'https'
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if config.cloud_controller_ssl_verify_none
      request          = Net::HTTP::Post.new(path)

      request.body = body
      request['Authorization'] = authorization_header

      http.request(request)
    end
  end
end
