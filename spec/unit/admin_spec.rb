require_relative '../spec_helper'

HOST = 'localhost'
PORT = 8071

CONFIG_FILE = '/tmp/admin_ui.yml'
DATA_FILE   = '/tmp/admin_ui_data.json'
LOG_FILE    = '/tmp/admin_ui.log'
STATS_FILE  = '/tmp/admin_ui_stats.json'

ADMIN_USER     = 'admin'
ADMIN_PASSWORD = 'admin_passw0rd'

USER          = 'user'
USER_PASSWORD = 'user_passw0rd'

CLOUD_CONTROLLER_URI = 'http://api.localhost'

TASKS_REFRESH_INTERVAL = 6000

describe IBM::AdminUI::Admin do
  before(:all) do
    config =
    {
      :cloud_controller_uri   => CLOUD_CONTROLLER_URI,
      :data_file              => DATA_FILE,
      :log_file               => LOG_FILE,
      :log_files              => [],
      :mbus                   => 'nats://nats:c1oudc0w@localhost:14222',
      :monitored_components   => ['ALL'],
      :port                   => PORT,
      :receiver_emails        => [],
      :sender_email           => { :account => 'system@localhost', :server => 'localhost' },
      :stats_file             => STATS_FILE,
      :tasks_refresh_interval => TASKS_REFRESH_INTERVAL,
      :uaa_admin_credentials  => { :password => 'c1oudc0w', :username => 'admin' },
      :ui_admin_credentials   => { :password => ADMIN_PASSWORD, :username => ADMIN_USER },
      :ui_credentials         => { :password => USER_PASSWORD, :username => USER }
    }

    File.open(CONFIG_FILE, 'w') do |file|
      file.write(JSON.pretty_generate(config))
    end

    project_path = File.join(File.dirname(__FILE__), '../..')
    spawn_opts = { :chdir => project_path,
                   :out   => '/dev/null',
                   :err   => '/dev/null' }

    @pid = Process.spawn({}, "ruby bin/admin -c #{ CONFIG_FILE }", spawn_opts)

    sleep(5)
  end

  after(:all) do
    Process.kill('TERM', @pid)
    Process.wait(@pid)

    cleanup_files_pid = Process.spawn({}, "rm -fr #{ CONFIG_FILE } #{ DATA_FILE } #{ LOG_FILE } #{ STATS_FILE }")
    Process.wait(cleanup_files_pid)
  end

  def create_http
    @http = Net::HTTP.new(HOST, PORT)
  end

  def clear_http
    @http = nil
  end

  def login
    create_http

    request = Net::HTTP::Post.new("/login?username=#{ ADMIN_USER }&password=#{ ADMIN_PASSWORD }")
    request['Content-Length'] = 0

    response = @http.request(request)
    fail_with('Unexpected http status code') unless response.is_a?(Net::HTTPSeeOther)

    location = response['location']
    location.should eq("http://#{ HOST }:#{ PORT }/application.html?user=#{ ADMIN_USER }")

    @cookie = response['Set-Cookie']
    @cookie.should_not be_nil
  end

  def logout
    clear_http

    @cookie = nil
  end

  context 'Login required, performed and failed' do
    it 'login fails as expected' do
      create_http
      request = Net::HTTP::Post.new("/login?username=#{ ADMIN_USER }&password=#{ USER_PASSWORD }")
      request['Content-Length'] = 0

      response = @http.request(request)
      fail_with('Unexpected http status code') unless response.is_a?(Net::HTTPSeeOther)

      location = response['location']
      location.should eq("http://#{ HOST }:#{ PORT }/login.html?error=true")
    end
  end

  context 'Login required, performed and succeeded' do
    before(:all) do
      login
    end

    after(:all) do
      logout
    end

    def get_json(path)
      request = Net::HTTP::Get.new(path)
      request['Cookie'] = @cookie

      response = @http.request(request)
      fail_with('Unexpected http status code') unless response.is_a?(Net::HTTPOK)

      body = response.body
      body.should_not be_nil

      JSON.parse(body)
    end

    def verify_disconnected_items(path)
      json = get_json(path)

      json.should include('connected' => false, 'items' => [])
    end

    def verify_empty_items(path)
      json = get_json(path)

      json.should include('items' => [])
    end

    it '/applications succeeds' do
      verify_disconnected_items('/applications')
    end

    it '/cloud_controllers succeeds' do
      verify_disconnected_items('/cloud_controllers')
    end

    it '/components succeeds' do
      verify_disconnected_items('/components')
    end

    it '/deas succeeds' do
      verify_disconnected_items('/deas')
    end

    it '/gateways succeeds' do
      verify_disconnected_items('/gateways')
    end

    it '/health_managers succeeds' do
      verify_disconnected_items('/health_managers')
    end

    it '/logs succeeds' do
      verify_empty_items('/logs')
    end

    it '/organizations succeeds' do
      verify_disconnected_items('/organizations')
    end

    it '/routers succeeds' do
      verify_disconnected_items('/routers')
    end

    it '/settings succeeds' do
      json = get_json('/settings')

      json.should eq('admin'                  => true,
                     'cloud_controller_uri'   => CLOUD_CONTROLLER_URI,
                     'tasks_refresh_interval' => TASKS_REFRESH_INTERVAL)

    end

    it '/spaces succeeds' do
      verify_disconnected_items('/spaces')
    end

    it '/spaces_auditors succeeds' do
      verify_disconnected_items('/spaces_auditors')
    end

    it '/spaces_developers succeeds' do
      verify_disconnected_items('/spaces_developers')
    end

    it '/spaces_managers succeeds' do
      verify_disconnected_items('/spaces_managers')
    end

    it '/tasks succeeds' do
      verify_empty_items('/tasks')
    end

    it '/users succeeds' do
      verify_disconnected_items('/users')
    end

  end

  context 'Login required, but not performed' do
    before(:all) do
      create_http
    end

    after(:all) do
      clear_http
    end

    def redirects_as_expected(path)
      request = Net::HTTP::Get.new(path)

      response = @http.request(request)
      fail_with('Unexpected http status code') unless response.is_a?(Net::HTTPSeeOther)

      location = response['location']
      location.should eq("http://#{ HOST }:#{ PORT }/login.html")
    end

    it '/applications redirects as expected' do
      redirects_as_expected('/applications')
    end

    it '/cloud_controllers redirects as expected' do
      redirects_as_expected('/cloud_controllers')
    end

    it '/components redirects as expected' do
      redirects_as_expected('/components')
    end

    it '/deas redirects as expected' do
      redirects_as_expected('/deas')
    end

    it '/download redirects as expected' do
      redirects_as_expected('/download')
    end

    it '/gateways redirects as expected' do
      redirects_as_expected('/gateways')
    end

    it '/health_managers redirects as expected' do
      redirects_as_expected('/health_managers')
    end

    it '/log redirects as expected' do
      redirects_as_expected('/log')
    end

    it '/logs redirects as expected' do
      redirects_as_expected('/logs')
    end

    it '/organizations redirects as expected' do
      redirects_as_expected('/organizations')
    end

    it '/routers redirects as expected' do
      redirects_as_expected('/routers')
    end

    it '/settings redirects as expected' do
      redirects_as_expected('/settings')
    end

    it '/spaces redirects as expected' do
      redirects_as_expected('/spaces')
    end

    it '/spaces_auditors redirects as expected' do
      redirects_as_expected('/spaces_auditors')
    end

    it '/spaces_developers redirects as expected' do
      redirects_as_expected('/spaces_developers')
    end

    it '/spaces_managersd redirects as expected' do
      redirects_as_expected('/spaces_managers')
    end

    it '/tasks redirects as expected' do
      redirects_as_expected('/tasks')
    end

    it '/task_status redirects as expected' do
      redirects_as_expected('/task_status')
    end

    it '/users redirects as expected' do
      redirects_as_expected('/users')
    end

  end

  context 'Login not required' do
    before(:all) do
      create_http
    end

    after(:all) do
      clear_http
    end

    def get_response(path)
      request = Net::HTTP::Get.new(path)

      response = @http.request(request)
      fail_with('Unexpected http status code') unless response.is_a?(Net::HTTPOK)

      response
    end

    def get_body(path)
      response = get_response(path)

      body = response.body
      body.should_not be_nil

      body
    end

    it '/ succeeds' do
      get_body('/')
    end

    it '/favicon.ico succeeds' do
      get_response('/favicon.ico')
    end

    it '/stats succeeds' do
      get_body('/stats')
    end

  end

  context 'Statistics' do
    it '/current_statistics succeeds' do
      create_http

      begin
        request = Net::HTTP::Get.new('/current_statistics')

        response = @http.request(request)
        fail_with('Unexpected http status code') unless response.is_a?(Net::HTTPOK)

        body = response.body
        body.should_not be_nil

        json = JSON.parse(body)

        json.should include('apps'              => 0,
                            'deas'              => 0,
                            'organizations'     => 0,
                            'running_instances' => 0,
                            'spaces'            => 0,
                            'total_instances'   => 0,
                            'users'             => 0)
      ensure
        clear_http
      end
    end

    it '/statistics post succeeds' do
      login

      begin
        request = Net::HTTP::Post.new('/statistics?apps=1&deas=2&organizations=3&running_instances=4&spaces=5&timestamp=6&total_instances=7&users=8')
        request['Cookie']         = @cookie
        request['Content-Length'] = 0

        response = @http.request(request)
        fail_with('Unexpected http status code') unless response.is_a?(Net::HTTPOK)

        body = response.body
        body.should_not be_nil

        json = JSON.parse(body)
        json.should eq('apps'              => 1,
                       'deas'              => 2,
                       'organizations'     => 3,
                       'running_instances' => 4,
                       'spaces'            => 5,
                       'timestamp'         => 6,
                       'total_instances'   => 7,
                       'users'             => 8)
      ensure
        logout
      end
    end

    it '/statistics succeeds' do
      create_http

      begin
        request = Net::HTTP::Get.new('/statistics')

        response = @http.request(request)
        fail_with('Unexpected http status code') unless response.is_a?(Net::HTTPOK)

        body = response.body
        body.should_not be_nil

        json = JSON.parse(body)

        json.should eq('label' => CLOUD_CONTROLLER_URI,
                       'items' => [{ 'apps'              => 1,
                                     'deas'              => 2,
                                     'organizations'     => 3,
                                     'running_instances' => 4,
                                     'spaces'            => 5,
                                     'timestamp'         => 6,
                                     'total_instances'   => 7,
                                     'users'             => 8 }])
      ensure
        clear_http
      end
    end
  end
end
