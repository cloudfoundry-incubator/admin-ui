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
      request['Accept']        = 'application/json'

      request.body = body if body

      retries_remaining = 2
      loop do
        begin
          return http.request(request)
        rescue EOFError, Timeout::Error
          raise if retries_remaining < 1
          retries_remaining -= 1
        end
      end
    end

    def self.hours_in_a_day(num_minutes)
      minutes_in_a_day = num_minutes % (24 * 60)
      minutes_in_a_day / 60
    end

    def self.minutes_in_an_hour(num_minutes)
      minutes_in_a_day = num_minutes % (24 * 60)
      minutes_in_a_day % 60
    end

    def self.symbolize_keys(hash)
      if hash.is_a? Hash
        new_hash = {}
        hash.each { |k, v| new_hash[k.to_sym] = symbolize_keys(v) }
        new_hash
      else
        hash
      end
    end

    def self.convert_bytes_to_megabytes(bytes)
      (bytes / 1_048_576.0).round
    end
  end
end
