require 'base64'
require 'yajl'

module AdminUI
  class Login
    LOGIN_ADMIN = 'ADMIN'.freeze
    LOGIN_USER  = 'USER'.freeze

    def initialize(config, logger, client)
      @client = client
      @config = config
      @logger = logger
    end

    def logout(redirect_uri)
      @client.sso_logout(redirect_uri)
    end

    def login_redirect_uri(redirect_uri)
      @client.sso_login_redirect(redirect_uri)
    end

    def login_user(code, redirect_uri)
      json = @client.sso_login_token_json(code, redirect_uri)
      return [nil, nil] if json.nil?

      access_token_segments = json['access_token'].split('.')
      access_token_payload = access_token_segments[1]
      pad = access_token_payload.length % 4
      access_token_payload += '=' * (4 - pad) if pad.positive?
      access_token_payload_decoded = Base64.respond_to?(:urlsafe_decode64) ? Base64.urlsafe_decode64(access_token_payload) : Base64.decode64(access_token_payload.tr('-_', '+/'))

      access_token_payload_json = Yajl::Parser.parse(access_token_payload_decoded)

      user_name = access_token_payload_json['user_name']
      scope = access_token_payload_json['scope']

      scopes = []
      scope.each do |scope_entry|
        scopes.push(scope_entry)
      end

      return [user_name, LOGIN_ADMIN] unless (scopes & @config.uaa_groups_admin).empty?
      return [user_name, LOGIN_USER] unless (scopes & @config.uaa_groups_user).empty?
      @logger.error("Login without proper group for user #{user_name}")
      [user_name, nil]
    end
  end
end
