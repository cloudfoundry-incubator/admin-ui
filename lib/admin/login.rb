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
      json = @client.sso_login_token_payload_json(code, redirect_uri)
      user_name = json['user_name']
      scope = json['scope']

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
