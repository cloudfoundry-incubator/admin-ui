require 'json'

module AdminUI
  class CC
    def initialize(config, logger)
      @config = config
      @logger = logger

      @semaphore = Mutex.new
      @condition = ConditionVariable.new

      @cache = nil

      Thread.new do
        loop do
          schedule_discovery
        end
      end
    end

    def applications
      @semaphore.synchronize do
        @condition.wait(@semaphore) while @cache.nil?
        @cache[:applications]
      end
    end

    def applications_count
      @semaphore.synchronize do
        @condition.wait(@semaphore) while @cache.nil?
        @cache[:applications]['items'].length
      end
    end

    def applications_running_instances
      @semaphore.synchronize do
        @condition.wait(@semaphore) while @cache.nil?
        instances = 0
        @cache[:applications]['items'].each do |app|
          instances += app['instances'] if app['state'] == 'STARTED'
        end

        instances
      end
    end

    def applications_total_instances
      @semaphore.synchronize do
        @condition.wait(@semaphore) while @cache.nil?
        instances = 0
        @cache[:applications]['items'].each do |app|
          instances += app['instances']
        end

        instances
      end
    end

    def organizations
      @semaphore.synchronize do
        @condition.wait(@semaphore) while @cache.nil?
        @cache[:organizations]
      end
    end

    def organizations_count
      @semaphore.synchronize do
        @condition.wait(@semaphore) while @cache.nil?
        @cache[:organizations]['items'].length
      end
    end

    def spaces
      @semaphore.synchronize do
        @condition.wait(@semaphore) while @cache.nil?
        @cache[:spaces]
      end
    end

    def spaces_auditors
      @semaphore.synchronize do
        @condition.wait(@semaphore) while @cache.nil?
        @cache[:spaces_auditors]
      end
    end

    def spaces_count
      @semaphore.synchronize do
        @condition.wait(@semaphore) while @cache.nil?
        @cache[:spaces]['items'].length
      end
    end

    def spaces_developers
      @semaphore.synchronize do
        @condition.wait(@semaphore) while @cache.nil?
        @cache[:spaces_developers]
      end
    end

    def spaces_managers
      @semaphore.synchronize do
        @condition.wait(@semaphore) while @cache.nil?
        @cache[:spaces_managers]
      end
    end

    def users
      @semaphore.synchronize do
        @condition.wait(@semaphore) while @cache.nil?
        @cache[:users]
      end
    end

    def users_count
      @semaphore.synchronize do
        @condition.wait(@semaphore) while @cache.nil?
        @cache[:users]['items'].length
      end
    end

    def reload
      @semaphore.synchronize do
        @cache = nil
        @condition.broadcast
        @condition.wait(@semaphore) while @cache.nil?
      end
    end

    private

    def schedule_discovery
      @logger.debug("[#{ @config.cloud_controller_discovery_interval } second interval] Starting CC discovery...")

      organizations     = discover_organizations
      spaces            = discover_spaces
      applications      = discover_applications
      users_uaa         = discover_users_uaa
      users_cc_deep     = discover_users_cc_deep

      if users_cc_deep['connected']
        spaces_auditors   = discover_spaces_auditors(users_cc_deep)
        spaces_developers = discover_spaces_developers(users_cc_deep)
        spaces_managers   = discover_spaces_managers(users_cc_deep)
      else
        spaces_auditors   = result
        spaces_developers = result
        spaces_managers   = result
      end

      cache =
      {
        :applications      => applications,
        :organizations     => organizations,
        :spaces            => spaces,
        :spaces_auditors   => spaces_auditors,
        :spaces_developers => spaces_developers,
        :spaces_managers   => spaces_managers,
        :users             => users_uaa
      }

      @semaphore.synchronize do
        @logger.debug('Caching CC data...')
        @cache = cache
        @condition.broadcast
        @condition.wait(@semaphore, @config.cloud_controller_discovery_interval)
      end
    end

    def result(items = nil)
      if items.nil?
        {
          'connected' => false,
          'items'     => []
        }
      else
        {
          'connected' => true,
          'items'     => items
        }
      end
    end

    def discover_applications
      items = []
      get_cc('v2/apps').each do |app|
        items.push(app['entity'].merge(app['metadata']))
      end
      result(items)
    rescue => error
      @logger.debug("Error during discover_applications: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_organizations
      items = []
      get_cc('v2/organizations').each do |app|
        items.push(app['entity'].merge(app['metadata']))
      end
      result(items)
    rescue => error
      @logger.debug("Error during discover_organizations: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_spaces
      items = []
      get_cc('v2/spaces').each do |app|
        items.push(app['entity'].merge(app['metadata']))
      end
      result(items)
    rescue => error
      @logger.debug("Error during discover_spaces: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_spaces_auditors(users_deep)
      items = []
      users_deep['items'].each do |user_deep|
        guid = user_deep['metadata']['guid']

        user_deep['entity']['audited_spaces'].each do |space|
          items.push('user_guid'  => guid,
                     'space_guid' => space['metadata']['guid'])
        end
      end
      result(items)
    rescue => error
      @logger.debug("Error during discover_spaces_auditors: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_spaces_developers(users_deep)
      items = []
      users_deep['items'].each do |user_deep|
        guid = user_deep['metadata']['guid']

        user_deep['entity']['spaces'].each do |space|
          items.push('user_guid'  => guid,
                     'space_guid' => space['metadata']['guid'])
        end
      end
      result(items)
    rescue => error
      @logger.debug("Error during discover_spaces_developers: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_spaces_managers(users_deep)
      items = []
      users_deep['items'].each do |user_deep|
        guid = user_deep['metadata']['guid']

        user_deep['entity']['managed_spaces'].each do |space|
          items.push('user_guid'  => guid,
                     'space_guid' => space['metadata']['guid'])
        end
      end
      result(items)
    rescue => error
      @logger.debug("Error during discover_spaces_managers: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_users_cc_deep
      result(get_cc('v2/users?inline-relations-depth=1'))
    rescue => error
      @logger.debug("Error during discover_users_cc_deep: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def discover_users_uaa
      items = []
      get_uaa('Users').each do |user|
        emails = user['emails']
        groups = user['groups']
        meta   = user['meta']
        name   = user['name']

        authorities = []
        groups.each do |group|
          authorities.push(group['display'])
        end

        attributes = { 'active'        => user['active'],
                       'authorities'   => authorities.sort.join(', '),
                       'created'       => meta['created'],
                       'id'            => user['id'],
                       'last_modified' => meta['lastModified'],
                       'version'       => meta['version'] }

        attributes['email']      = emails[0]['value'] unless emails.nil? || emails.length == 0
        attributes['familyname'] = name['familyName'] unless name['familyName'].nil?
        attributes['givenname']  = name['givenName'] unless name['givenName'].nil?
        attributes['username']   = user['userName'] unless user['userName'].nil?

        items.push(attributes)
      end
      result(items)
    rescue => error
      @logger.debug("Error during discover_users_uaa: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    def get_cc(path)
      uri = "#{ @config.cloud_controller_uri }/#{ path }"

      resources = []
      loop do
        json = get(uri)
        resources.concat(json['resources'])
        next_url = json['next_url']
        return resources if next_url.nil?
        uri = "#{ @config.cloud_controller_uri }#{ next_url }"
      end

      resources
    end

    def get_uaa(path)
      info

      uri = "#{ @token_endpoint }/#{ path }"

      resources = []
      loop do
        json = get(uri)
        resources.concat(json['resources'])
        total_results = json['totalResults']
        start_index = resources.length + 1
        return resources unless total_results > start_index
        uri = "#{ @token_endpoint }/#{ path }?startIndex=#{ start_index }"
      end

      resources
    end

    def get(uri)
      recent_login = false
      if @token.nil?
        login
        recent_login = true
      end

      loop do
        response = Utils.http_get(uri, nil, @token)
        if response.is_a?(Net::HTTPOK)
          return JSON.parse(response.body)
        elsif !recent_login && response.is_a?(Net::HTTPUnauthorized)
          login
          recent_login = true
        else
          fail "Unexected response code from get is #{ response_code }, message #{ response.message }"
        end
      end
    end

    def login
      info

      @token = nil

      response = Utils.http_post("#{ @authorization_endpoint }/oauth/token",
                                 "grant_type=password&username=#{ @config.uaa_admin_credentials_username }&password=#{ @config.uaa_admin_credentials_password }",
                                 'Basic Y2Y6')

      if response.is_a?(Net::HTTPOK)
        body_json = JSON.parse(response.body)
        @token = "#{ body_json['token_type'] } #{ body_json['access_token'] }"
      else
        fail "Unexpected response code from login is #{ response.code }, message #{ response.message }"
      end
    end

    def info
      return unless @token_endpoint.nil?

      response = Utils.http_get("#{ @config.cloud_controller_uri }/info")

      if response.is_a?(Net::HTTPOK)
        body_json = JSON.parse(response.body)

        @authorization_endpoint = body_json['authorization_endpoint']
        if @authorization_endpoint.nil?
          fail "Information retrieved from #{ url } does not include authorization_endpoint"
        end

        @token_endpoint = body_json['token_endpoint']
        if @token_endpoint.nil?
          fail "Information retrieved from #{ url } does not include token_endpoint"
        end
      else
        fail "Unable to fetch info from #{ url }"
      end
    end
  end
end
