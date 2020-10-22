require 'faye/websocket'
require 'uri'
require 'yajl'
require_relative 'utils'

module AdminUI
  class CCRestClient
    def initialize(config, logger)
      @config = config
      @logger = logger
    end

    def api_version
      info
      @api_version
    end

    def build
      info
      @build
    end

    def delete_cc(path, body = nil)
      cf_request(get_cc_url(path), Utils::HTTP_DELETE, body, body.nil? ? nil : 'application/json')
    end

    def delete_uaa(path)
      cf_request(get_uaa_token_endpoint_url(path), Utils::HTTP_DELETE)
    end

    def get_cc(path)
      cf_request(get_cc_url(path), Utils::HTTP_GET)
    end

    def get_firehose(subscription_id, force_login)
      begin
        info
      rescue => error
        @logger.error("Error during get_firehose info: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        return [nil, nil]
      end

      if @doppler_logging_endpoint.nil?
        @logger.warn('Warning during get_firehose doppler_logging_endpoint does not exist')
        return [nil, nil]
      end

      uri_base = "#{@doppler_logging_endpoint}/firehose"

      if @token.nil? || force_login
        begin
          login
        rescue => error
          @logger.error("Error during get_firehose login: #{error.inspect}")
          @logger.error(error.backtrace.join("\n"))
          return [uri_base, nil]
        end
      end

      begin
        websocket = Faye::WebSocket::Client.new("#{uri_base}/#{subscription_id}?filter-type=metrics",
                                                nil,
                                                headers: { 'Authorization' => @token },
                                                ping:    30,
                                                tls:     { verify_peer: !@config.doppler_ssl_verify_none })
        [uri_base, websocket]
      rescue => error
        @logger.error("Error during get_firehose websocket instantiation: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        [uri_base, nil]
      end
    end

    def get_uaa(path)
      cf_request(get_uaa_token_endpoint_url(path), Utils::HTTP_GET)
    end

    def name
      info
      @name
    end

    def osbapi_version
      info
      @osbapi_version
    end

    def patch_cc(path, body)
      cf_request(get_cc_url(path), Utils::HTTP_PATCH, body, 'application/json')
    end

    def patch_uaa(path, body)
      cf_request(get_uaa_token_endpoint_url(path), Utils::HTTP_PATCH, body, 'application/json', '*')
    end

    def put_cc(path, body)
      cf_request(get_cc_url(path), Utils::HTTP_PUT, body, 'application/json')
    end

    def post_cc(path, body)
      cf_request(get_cc_url(path), Utils::HTTP_POST, body, 'application/json')
    end

    def sso_logout(redirect_uri)
      info
      "#{@authorization_endpoint}/logout.do?redirect=#{redirect_uri}"
    end

    def sso_login_redirect(redirect_uri)
      info
      "#{@authorization_endpoint}/oauth/authorize?response_type=code&client_id=#{@config.uaa_client_id}&redirect_uri=#{redirect_uri}"
    end

    def sso_login_token_payload_json(code, redirect_uri)
      info
      json = sso_login_token_json(code, redirect_uri)
      user_access_token = json['access_token']

      # As of UAA 74.2.0, UAA /introspect supports client access_token
      use_introspect = Gem::Version.new(@uaa_version) >= Gem::Version.new('74.2.0')

      return sso_login_introspect_token(user_access_token) if use_introspect

      sso_login_check_token(user_access_token)
    end

    def uaa_version
      info
      @uaa_version
    end

    private

    def cf_request(url, method, body = nil, content_type = nil, if_match = nil)
      recent_login = false
      if @token.nil?
        login
        recent_login = true
      end

      loop do
        response = Utils.http_request(@config, @logger, url, method, nil, body, @token, content_type, if_match)

        return Yajl::Parser.parse(response.body) if method == Utils::HTTP_GET && response.is_a?(Net::HTTPOK)
        return Yajl::Parser.parse(response.body) if method == Utils::HTTP_PUT && (response.is_a?(Net::HTTPOK) || response.is_a?(Net::HTTPCreated))
        return if method == Utils::HTTP_DELETE && (response.is_a?(Net::HTTPOK) || response.is_a?(Net::HTTPCreated) || response.is_a?(Net::HTTPAccepted) || response.is_a?(Net::HTTPNoContent))
        return Yajl::Parser.parse(response.body) if method == Utils::HTTP_POST && (response.is_a?(Net::HTTPOK) || response.is_a?(Net::HTTPCreated) || response.is_a?(Net::HTTPAccepted))
        return Yajl::Parser.parse(response.body) if method == Utils::HTTP_PATCH && (response.is_a?(Net::HTTPOK) || response.is_a?(Net::HTTPCreated) || response.is_a?(Net::HTTPAccepted))

        raise AdminUI::CCRestClientResponseError, response unless !recent_login && response.is_a?(Net::HTTPUnauthorized)

        login
        recent_login = true
      end
    end

    def get_cc_url(path)
      return "#{@config.cloud_controller_uri}#{path}" if path && path[0] == '/'

      "#{@config.cloud_controller_uri}/#{path}"
    end

    def get_uaa_token_endpoint_url(path)
      info
      return "#{@token_endpoint}#{path}" if path && path[0] == '/'

      "#{@token_endpoint}/#{path}"
    end

    def info
      return unless @uaa_version.nil?

      cc_v2_info_url = get_cc_url('/v2/info')

      response = nil
      begin
        response = Utils.http_request(@config, @logger, cc_v2_info_url, Utils::HTTP_GET)
      rescue => error
        @logger.error("Error fetching #{cc_v2_info_url}: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        raise "Unable to fetch from #{cc_v2_info_url}"
      end

      raise "Unable to fetch from #{cc_v2_info_url}. Response code is #{response.code}." unless response.is_a?(Net::HTTPOK)

      body_json = Yajl::Parser.parse(response.body)

      @api_version = body_json['api_version']
      raise "Information retrieved from #{cc_v2_info_url} does not include api_version" if @api_version.nil?

      @build = body_json['build']
      raise "Information retrieved from #{cc_v2_info_url} does not include build" if @build.nil?

      @name = body_json['name']
      raise "Information retrieved from #{cc_v2_info_url} does not include name" if @name.nil?

      @osbapi_version = body_json['osbapi_version']
      if @osbapi_version.nil?
        @logger.warn("Information retrieved from #{cc_v2_info_url} does not include osbapi_version") if @osbapi_version.nil?
      end

      @authorization_endpoint = body_json['authorization_endpoint']
      raise "Information retrieved from #{cc_v2_info_url} does not include authorization_endpoint" if @authorization_endpoint.nil?

      if @config.doppler_logging_endpoint_override.nil?
        @doppler_logging_endpoint = body_json['doppler_logging_endpoint']
        @logger.warn("Information retrieved from #{cc_v2_info_url} does not include doppler_logging_endpoint") if @doppler_logging_endpoint.nil?
      else
        @doppler_logging_endpoint = @config.doppler_logging_endpoint_override
      end

      @token_endpoint = body_json['token_endpoint']
      raise "Information retrieved from #{cc_v2_info_url} does not include token_endpoint" if @token_endpoint.nil?

      uaa_info_url = "#{@token_endpoint}/info"

      begin
        response = Utils.http_request(@config, @logger, uaa_info_url, Utils::HTTP_GET)
      rescue => error
        @logger.error("Error fetching #{uaa_info_url}: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        raise "Unable to fetch from #{uaa_info_url}"
      end

      raise "Unable to fetch from #{uaa_info_url}. Response code is #{response.code}." unless response.is_a?(Net::HTTPOK)

      body_json = Yajl::Parser.parse(response.body)

      app = body_json['app']
      raise "Information retrieved from #{uaa_info_url} does not include app" if app.nil?

      @uaa_version = app['version']
      raise "Information retrieved from #{uaa_info_url} does not include app.version" if @uaa_version.nil?
    end

    def login
      info

      @token = nil

      response = Utils.http_request(@config,
                                    @logger,
                                    "#{@token_endpoint}/oauth/token",
                                    Utils::HTTP_POST,
                                    [@config.uaa_client_id, @config.uaa_client_secret],
                                    'grant_type=client_credentials',
                                    nil,
                                    'application/x-www-form-urlencoded')

      raise AdminUI::CCRestClientResponseError, response unless response.is_a?(Net::HTTPOK)

      body_json = Yajl::Parser.parse(response.body)
      @token = "#{body_json['token_type']} #{body_json['access_token']}"
    end

    def sso_login_check_token(user_access_token)
      url = "#{@token_endpoint}/check_token"
      content = URI.encode_www_form('token' => user_access_token)
      response = Utils.http_request(@config,
                                    @logger,
                                    url,
                                    Utils::HTTP_POST,
                                    [@config.uaa_client_id, @config.uaa_client_secret],
                                    content,
                                    nil,
                                    'application/x-www-form-urlencoded')
      return Yajl::Parser.parse(response.body) if response.is_a?(Net::HTTPOK)

      @logger.error("Unexpected response code from sso_login_check_token is #{response.code}, message #{response.message}, body #{response.body}")
      raise "Unable to post to #{url}. Response code is #{response.code}."
    end

    def sso_login_introspect_token(user_access_token)
      url = "#{@token_endpoint}/introspect"
      content = URI.encode_www_form('token' => user_access_token)
      payload_json = cf_request(url,
                                Utils::HTTP_POST,
                                content,
                                'application/x-www-form-urlencoded')
      return payload_json if payload_json['active'] == true

      @logger.error('Inactive user token from sso_login_introspect_token')
      raise 'Inactive user token.'
    end

    def sso_login_token_json(code, redirect_uri)
      url = "#{@token_endpoint}/oauth/token"
      content = URI.encode_www_form('client_id'    => @config.uaa_client_id,
                                    'grant_type'   => 'authorization_code',
                                    'code'         => code,
                                    'redirect_uri' => redirect_uri)
      response = Utils.http_request(@config,
                                    @logger,
                                    url,
                                    Utils::HTTP_POST,
                                    [@config.uaa_client_id, @config.uaa_client_secret],
                                    content,
                                    nil,
                                    'application/x-www-form-urlencoded')
      return Yajl::Parser.parse(response.body) if response.is_a?(Net::HTTPOK) || response.is_a?(Net::HTTPCreated)

      @logger.error("Unexpected response code from sso_login_token_json is #{response.code}, message #{response.message}, body #{response.body}")
      raise "Unable to post to #{url}. Response code is #{response.code}."
    end
  end
end
