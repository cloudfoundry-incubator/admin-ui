require_relative '../spec_helper'

describe AdminUI::Admin do
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

  before(:all) do
    config =
    {
      :cloud_controller_uri   => CLOUD_CONTROLLER_URI,
      :data_file              => DATA_FILE,
      :log_file               => LOG_FILE,
      :mbus                   => 'nats://nats:c1oudc0w@localhost:14222',
      :port                   => PORT,
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

    Process.wait(Process.spawn({}, "rm -fr #{ CONFIG_FILE } #{ DATA_FILE } #{ LOG_FILE } #{ STATS_FILE }"))
  end

  def create_http
    Net::HTTP.new(HOST, PORT)
  end

  def login_and_return_cookie(http)
    request = Net::HTTP::Post.new("/login?username=#{ ADMIN_USER }&password=#{ ADMIN_PASSWORD }")
    request['Content-Length'] = 0

    response = http.request(request)
    expect(response.is_a?(Net::HTTPSeeOther)).to be_true

    location = response['location']
    expect(location).to eq("http://#{ HOST }:#{ PORT }/application.html?user=#{ ADMIN_USER }")

    cookie = response['Set-Cookie']
    expect(cookie).to_not be_nil

    cookie
  end

  context 'Login required, performed and failed' do
    let(:http) { create_http }

    it 'login fails as expected' do
      request = Net::HTTP::Post.new("/login?username=#{ ADMIN_USER }&password=#{ USER_PASSWORD }")
      request['Content-Length'] = 0

      response = http.request(request)
      expect(response.is_a?(Net::HTTPSeeOther)).to be_true

      location = response['location']
      expect(location).to eq("http://#{ HOST }:#{ PORT }/login.html?error=true")
    end
  end

  context 'Login required, performed and succeeded' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    def get_json(path)
      request = Net::HTTP::Get.new(path)
      request['Cookie'] = cookie

      response = http.request(request)
      expect(response.is_a?(Net::HTTPOK)).to be_true

      body = response.body
      expect(body).to_not be_nil

      JSON.parse(body)
    end

    def put(path, body)
      request = Net::HTTP::Put.new(path)
      request['Cookie'] = cookie
      request['Content-Length'] = 0
      request.body = body if body

      http.request(request)
    end

    def delete(path)
      request = Net::HTTP::Delete.new(path)
      request['Cookie'] = cookie

      http.request(request)
    end

    def verify_disconnected_items(path)
      json = get_json(path)

      expect(json).to include('connected' => false, 'items' => [])
    end

    def verify_empty_items(path)
      json = get_json(path)

      expect(json).to include('items' => [])
    end

    context 'delete route' do
      it 'returns failure code due to disconnection' do
        response = delete('/routes/route1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'manage application' do
      it 'returns failure code due to disconnection' do
        response = put('/applications/application1', '{"state":"STARTED"}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'manage service plan' do
      it 'returns failure code due to disconnection' do
        response = put('/service_plans/service_plan1', '{"public": true }')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
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

    it '/routes succeeds' do
      verify_disconnected_items('/routes')
    end

    it '/settings succeeds' do
      json = get_json('/settings')

      expect(json).to eq('admin'                  => true,
                         'cloud_controller_uri'   => CLOUD_CONTROLLER_URI,
                         'tasks_refresh_interval' => TASKS_REFRESH_INTERVAL)

    end

    it '/services succeeds' do
      verify_disconnected_items('/services')
    end

    it '/service_bindings succeeds' do
      verify_disconnected_items('/service_bindings')
    end

    it '/service_instances succeeds' do
      verify_disconnected_items('/service_instances')
    end

    it '/service_plans succeeds' do
      verify_disconnected_items('/service_plans')
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
    let(:http) { create_http }

    def get_redirects_as_expected(path)
      do_redirect_request(Net::HTTP::Get.new(path))
    end

    def put_redirects_as_expected(path, body)
      request = Net::HTTP::Put.new(path)
      request.body = body if body
      do_redirect_request(request)
    end

    def delete_redirects_as_expected(path)
      do_redirect_request(Net::HTTP::Delete.new(path))
    end

    def do_redirect_request(request)
      request['Content-Length'] = 0

      response = http.request(request)
      expect(response.is_a?(Net::HTTPSeeOther)).to be_true

      location = response['location']
      expect(location).to eq("http://#{ HOST }:#{ PORT }/login.html")
    end

    it '/applications redirects as expected' do
      get_redirects_as_expected('/applications')
    end

    it '/cloud_controllers redirects as expected' do
      get_redirects_as_expected('/cloud_controllers')
    end

    it '/components redirects as expected' do
      get_redirects_as_expected('/components')
    end

    it '/deas redirects as expected' do
      get_redirects_as_expected('/deas')
    end

    it '/download redirects as expected' do
      get_redirects_as_expected('/download')
    end

    it '/gateways redirects as expected' do
      get_redirects_as_expected('/gateways')
    end

    it '/health_managers redirects as expected' do
      get_redirects_as_expected('/health_managers')
    end

    it '/log redirects as expected' do
      get_redirects_as_expected('/log')
    end

    it '/logs redirects as expected' do
      get_redirects_as_expected('/logs')
    end

    it '/organizations redirects as expected' do
      get_redirects_as_expected('/organizations')
    end

    it '/routers redirects as expected' do
      get_redirects_as_expected('/routers')
    end

    it '/routes redirects as expected' do
      get_redirects_as_expected('/routes')
    end

    it '/settings redirects as expected' do
      get_redirects_as_expected('/settings')
    end

    it '/services redirects as expected' do
      get_redirects_as_expected('/services')
    end

    it '/service_bindings redirects as expected' do
      get_redirects_as_expected('/service_bindings')
    end

    it '/service_instances redirects as expected' do
      get_redirects_as_expected('/service_instances')
    end

    it '/service_plans redirects as expected' do
      get_redirects_as_expected('/service_plans')
    end

    it '/spaces redirects as expected' do
      get_redirects_as_expected('/spaces')
    end

    it '/spaces_auditors redirects as expected' do
      get_redirects_as_expected('/spaces_auditors')
    end

    it '/spaces_developers redirects as expected' do
      get_redirects_as_expected('/spaces_developers')
    end

    it '/spaces_managersd redirects as expected' do
      get_redirects_as_expected('/spaces_managers')
    end

    it '/tasks redirects as expected' do
      get_redirects_as_expected('/tasks')
    end

    it '/task_status redirects as expected' do
      get_redirects_as_expected('/task_status')
    end

    it '/users redirects as expected' do
      get_redirects_as_expected('/users')
    end

    it 'deletes /routes/:route_guid redirects as expected' do
      delete_redirects_as_expected('/routes/route1')
    end

    it 'puts /applications/:app_guid redirects as expected' do
      put_redirects_as_expected('/applications/application1', '{"state":"STARTED"}')
    end
  end

  context 'Login not required' do
    let(:http) { create_http }

    def get_response(path)
      request = Net::HTTP::Get.new(path)

      response = http.request(request)
      expect(response.is_a?(Net::HTTPOK)).to be_true

      response
    end

    def get_body(path)
      response = get_response(path)

      body = response.body
      expect(body).to_not be_nil

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
    let(:http) { create_http }

    it '/current_statistics succeeds' do
      request = Net::HTTP::Get.new('/current_statistics')

      response = http.request(request)
      expect(response.is_a?(Net::HTTPOK)).to be_true

      body = response.body
      expect(body).to_not be_nil

      json = JSON.parse(body)

      expect(json).to include('apps'              => 0,
                              'deas'              => 0,
                              'organizations'     => 0,
                              'running_instances' => 0,
                              'spaces'            => 0,
                              'total_instances'   => 0,
                              'users'             => 0)
    end

    context 'Login required for post' do
      let(:cookie) { login_and_return_cookie(http) }

      it '/statistics post succeeds' do
        request = Net::HTTP::Post.new('/statistics?apps=1&deas=2&organizations=3&running_instances=4&spaces=5&timestamp=6&total_instances=7&users=8')
        request['Cookie']         = cookie
        request['Content-Length'] = 0

        response = http.request(request)
        expect(response.is_a?(Net::HTTPOK)).to be_true

        body = response.body
        expect(body).to_not be_nil

        json = JSON.parse(body)
        expect(json).to eq('apps'              => 1,
                           'deas'              => 2,
                           'organizations'     => 3,
                           'running_instances' => 4,
                           'spaces'            => 5,
                           'timestamp'         => 6,
                           'total_instances'   => 7,
                           'users'             => 8)

        # Second half of the test does not require cookie for request

        request = Net::HTTP::Get.new('/statistics')

        response = http.request(request)
        expect(response.is_a?(Net::HTTPOK)).to be_true

        body = response.body
        expect(body).to_not be_nil

        json = JSON.parse(body)

        expect(json).to eq('label' => CLOUD_CONTROLLER_URI,
                           'items' => [{ 'apps'              => 1,
                                         'deas'              => 2,
                                         'organizations'     => 3,
                                         'running_instances' => 4,
                                         'spaces'            => 5,
                                         'timestamp'         => 6,
                                         'total_instances'   => 7,
                                         'users'             => 8 }])
      end
    end
  end
end
