require 'net/http'
require 'openssl'
require 'uri'

module AdminUI
  class Utils
    HTTP_DELETE = 'DELETE'.freeze
    HTTP_GET    = 'GET'.freeze
    HTTP_HEAD   = 'HEAD'.freeze
    HTTP_PATCH  = 'PATCH'.freeze
    HTTP_PUT    = 'PUT'.freeze
    HTTP_POST   = 'POST'.freeze

    HTTP_METHODS_MAP =
      {
        HTTP_DELETE => Net::HTTP::Delete,
        HTTP_GET    => Net::HTTP::Get,
        HTTP_HEAD   => Net::HTTP::Head,
        HTTP_PATCH  => Net::HTTP::Patch,
        HTTP_PUT    => Net::HTTP::Put,
        HTTP_POST   => Net::HTTP::Post
      }.freeze

    def self.time_in_milliseconds(time = Time.now)
      (time.to_f * 1000).to_i
    end

    def self.get_method_class(method_string)
      HTTP_METHODS_MAP[method_string.upcase]
    end

    def self.http_request(config, logger, uri_string, method = HTTP_GET, basic_auth_array = nil, body = nil, authorization_header = nil, content_type = nil, if_match = nil)
      uri = URI.parse(uri_string)

      path  = uri.path
      path += "?#{uri.query}" unless uri.query.nil?

      http             = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl     = uri.scheme.to_s.casecmp('https').zero?
      http.verify_mode = config.cloud_controller_ssl_verify_none ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
      request          = get_method_class(method).new(path)

      request.basic_auth(basic_auth_array[0], basic_auth_array[1]) unless basic_auth_array.nil? || basic_auth_array.length < 2
      request['Authorization'] = authorization_header unless authorization_header.nil?
      request['Accept']        = 'application/json'
      request['Content-Type']  = content_type unless content_type.nil?
      request['If-Match']      = if_match unless if_match.nil?

      request.body = body if body

      http.set_debug_output(logger) if config.http_debug

      retries_remaining = 2
      loop do
        return http.request(request)
      rescue EOFError, Timeout::Error
        raise if retries_remaining < 1

        retries_remaining -= 1
      end
    end

    def self.hours_in_a_day(num_minutes)
      minutes_in_a_day = num_minutes % (24 * 60)
      minutes_in_a_day / 60
    end

    def self.minutes_in_an_hour(num_minutes)
      num_minutes % 60
    end

    def self.symbolize_keys(object)
      case object
      when Array
        new_array = []
        object.each { |item| new_array.push(symbolize_keys(item)) }
        new_array
      when Hash
        new_hash = {}
        object.each { |key, value| new_hash[key.to_sym] = symbolize_keys(value) }
        new_hash
      else
        object
      end
    end

    def self.convert_bytes_to_megabytes(bytes)
      (bytes / 1_048_576.0).round
    end

    def self.convert_kilobytes_to_megabytes(kilobytes)
      (kilobytes / 1_024.0).round
    end
  end
end
