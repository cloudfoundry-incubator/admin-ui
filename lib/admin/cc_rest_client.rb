require 'json'
require 'uri'
require_relative 'utils'

module AdminUI
  class CCRestClient
    def initialize(config, logger)
      @config = config
      @logger = logger
    end

    def delete_cc(path)
      cf_request(get_cc_url(path), Utils::HTTP_DELETE)
    end

    def get_cc(path)
      uri = get_cc_url(path)
      resources = []
      loop do
        json = cf_request(uri, Utils::HTTP_GET)
        resources.concat(json['resources'])
        next_url = json['next_url']
        return resources if next_url.nil?
        uri = get_cc_url(next_url)
      end
      resources
    end

    def get_uaa(path)
      info

      uri = "#{ @token_endpoint }/#{ path }"

      resources = []
      loop do
        json = cf_request(uri, Utils::HTTP_GET)
        resources.concat(json['resources'])
        total_results = json['totalResults']
        start_index = resources.length + 1
        return resources unless total_results > start_index
        uri = "#{ @token_endpoint }/#{ path }?startIndex=#{ start_index }"
      end

      resources
    end

    def put_cc(path, body)
      cf_request(get_cc_url(path), Utils::HTTP_PUT, body)
    end

    def post_cc(path, body)
      cf_request(get_cc_url(path), Utils::HTTP_POST, body)
    end

    def sso_logout(redirect_uri)
      info
      "#{ @authorization_endpoint }/logout.do?redirect=#{ redirect_uri }"
    end

    def sso_login_redirect(redirect_uri)
      info
      "#{ @authorization_endpoint }/oauth/authorize?response_type=code&client_id=#{ @config.uaa_client_id }&redirect_uri=#{ redirect_uri }"
    end

    def sso_login_token_json(code, redirect_uri)
      info
      content = URI.encode_www_form('client_id'    => @config.uaa_client_id,
                                    'grant_type'   => 'authorization_code',
                                    'code'         => code,
                                    'redirect_uri' => redirect_uri)
      response = Utils.http_request(@config,
                                    "#{ @token_endpoint }/oauth/token",
                                    Utils::HTTP_POST,
                                    [@config.uaa_client_id, @config.uaa_client_secret],
                                    content)
      return JSON.parse(response.body) if response.is_a?(Net::HTTPOK) || response.is_a?(Net::HTTPCreated)
      @logger.debug("Unexpected response code from sso_login_token_json is #{ response.code }, message #{ response.message }, body #{ response.body }")
      nil
    end

    private

    def cf_request(url, method, body = nil)
      recent_login = false
      if @token.nil?
        login
        recent_login = true
      end

      loop do
        response = Utils.http_request(@config, url, method, nil, body, @token)

        if method == Utils::HTTP_GET && response.is_a?(Net::HTTPOK)
          return JSON.parse(response.body)
        elsif method == Utils::HTTP_PUT && (response.is_a?(Net::HTTPOK) || response.is_a?(Net::HTTPCreated))
          return JSON.parse(response.body)
        elsif method == Utils::HTTP_DELETE && (response.is_a?(Net::HTTPOK) || response.is_a?(Net::HTTPCreated) || response.is_a?(Net::HTTPNoContent))
          return
        elsif method == Utils::HTTP_POST && (response.is_a?(Net::HTTPOK) || response.is_a?(Net::HTTPCreated))
          return JSON.parse(response.body)
        end

        if !recent_login && response.is_a?(Net::HTTPUnauthorized)
          login
          recent_login = true
        else
          fail "Unexected response code from #{ method } is #{ response.code }, message #{ response.message }"
        end
      end
    end

    def get_cc_url(path)
      if path && path[0] == '/'
        return "#{ @config.cloud_controller_uri }#{ path }"
      else
        return "#{ @config.cloud_controller_uri }/#{ path }"
      end
    end

    def login
      info

      @token = nil

      response = Utils.http_request(@config,
                                    "#{ @token_endpoint }/oauth/token",
                                    Utils::HTTP_POST,
                                    [@config.uaa_client_id, @config.uaa_client_secret],
                                    'grant_type=client_credentials')

      if response.is_a?(Net::HTTPOK)
        body_json = JSON.parse(response.body)
        @token = "#{ body_json['token_type'] } #{ body_json['access_token'] }"
      else
        fail "Unexpected response code from login is #{ response.code }, message #{ response.message}"
      end
    end

    def info
      return unless @token_endpoint.nil?

      response = nil
      begin
        response = Utils.http_request(@config, get_cc_url('/info'), Utils::HTTP_GET)
      rescue => error
        @logger.debug("Error during /info: #{ error.inspect }")
        @logger.debug(error.backtrace.join("\n"))
        raise "Unable to fetch from #{ get_cc_url('/info') }"
      end

      if response.is_a?(Net::HTTPOK)
        body_json = JSON.parse(response.body)

        @authorization_endpoint = body_json['authorization_endpoint']
        if @authorization_endpoint.nil?
          fail "Information retrieved from #{ get_cc_url('/info') } does not include authorization_endpoint"
        end

        @token_endpoint = body_json['token_endpoint']
        if @token_endpoint.nil?
          fail "Information retrieved from #{ get_cc_url('/info') } does not include token_endpoint"
        end
      else
        fail "Unable to fetch from #{ get_cc_url('/info') }"
      end
    end
  end
end
