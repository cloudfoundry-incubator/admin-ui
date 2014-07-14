require 'fileutils'
require 'uri'
require_relative '../spec_helper'

describe AdminUI::Admin do
  include LoginHelper
  include CCHelper

  let(:host) { 'localhost' }
  let(:port) { 8071 }

  let(:cloud_controller_uri) { 'http://api.localhost' }
  let(:data_file) { '/tmp/admin_ui_data.json' }
  let(:db_file) { '/tmp/admin_ui_store.db' }
  let(:log_file) { '/tmp/admin_ui.log' }
  let(:stats_file) { '/tmp/admin_ui_stats.json' }
  let(:tasks_refresh_interval) { 6000 }

  let(:config) do
    { :cloud_controller_uri   => cloud_controller_uri,
      :data_file              => data_file,
      :db_uri                 => "sqlite://#{ db_file }",
      :log_file               => log_file,
      :mbus                   => 'nats://nats:c1oudc0w@localhost:14222',
      :port                   => port,
      :stats_file             => stats_file,
      :tasks_refresh_interval => tasks_refresh_interval,
      :uaa_client             => { :id => 'id', :secret => 'secret' }
    }
  end

  before do
    File.delete(db_file) if File.exist?(db_file)

    ::WEBrick::Log.any_instance.stub(:log)

    Thread.new do
      AdminUI::Admin.new(config, true).start
    end

    sleep(1)
  end

  after do
    Rack::Handler::WEBrick.shutdown

    Thread.list.each do |thread|
      unless thread == Thread.main
        thread.kill
        thread.join
      end
    end

    Process.wait(Process.spawn({}, "rm -fr #{ data_file } #{ db_file } #{ log_file } #{ stats_file }"))
  end

  def create_http
    Net::HTTP.new(host, port)
  end

  def login_and_return_cookie(http)
    response = nil
    cookie = nil
    uri = URI.parse('/')
    loop do
      path  = uri.path
      path += "?#{ uri.query }" unless uri.query.nil?

      request = Net::HTTP::Get.new(path)
      request['Cookie'] = cookie

      response = http.request(request)
      cookie   = response['Set-Cookie'] unless response['Set-Cookie'].nil?

      break unless response['location']
      uri = URI.parse(response['location'])
    end

    expect(cookie).to_not be_nil

    cookie
  end

  def logout(http)
    request = Net::HTTP::Get.new('/logout')

    response = http.request(request)
    expect(response.is_a?(Net::HTTPOK)).to be_true

    body = response.body
    expect(body['redirect']).not_to be_nil

    cookie = response['Set-Cookie']
    expect(cookie).to_not be_nil

    cookie
  end

  context 'Destroys the session after logout' do
    before do
      login_stub_admin
    end
    it 'destroys the session after logout' do
      original_cookie = login_and_return_cookie(create_http)
      new_cookie      = logout(create_http)

      expect(new_cookie.inspect).not_to eq(original_cookie.inspect)
    end
  end

  context 'Login required, performed and failed' do
    before do
      login_stub_fail
    end
    let(:http) { create_http }

    it 'login fails as expected' do
      request = Net::HTTP::Get.new('/')

      response = http.request(request)
      expect(response.is_a?(Net::HTTPSeeOther)).to be_true

      location = response['location']
      expect(location).not_to be_nil
    end
  end

  context 'Login required, performed and succeeded' do
    before do
      login_stub_admin
    end

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

    def post(path, body)
      request = Net::HTTP::Post.new(path)
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

    context 'create organization' do
      it 'returns failure code due to disconnection' do
        response = post('/organizations', '{"name":"new_org"}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete application' do
      it 'returns failure code due to disconnection' do
        response = delete('/applications/application1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete organization' do
      it 'returns failure code due to disconnection' do
        response = delete('/organizations/organization1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
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

    context 'manage organization' do
      it 'returns failure code due to disconnection' do
        response = put('/organizations/organization1', '{"quota_definition_guid":"quota1"}')
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

    it '/quota_definitions succeeds' do
      verify_disconnected_items('/quota_definitions')
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
                         'cloud_controller_uri'   => cloud_controller_uri,
                         'tasks_refresh_interval' => tasks_refresh_interval)

    end

    it '/services succeeds' do
      verify_disconnected_items('/services')
    end

    it '/service_bindings succeeds' do
      verify_disconnected_items('/service_bindings')
    end

    it '/service_brokers succeeds' do
      verify_disconnected_items('/service_brokers')
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
    before do
      login_stub_fail
    end

    let(:http) { create_http }

    def get_redirects_as_expected(path)
      do_redirect_request(Net::HTTP::Get.new(path))
    end

    def post_redirects_as_expected(path, body)
      request = Net::HTTP::Post.new(path)
      request.body = body if body
      do_redirect_request(request)
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
      expect(location).not_to be_nil
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

    it '/quota_definitions redirects as expected' do
      get_redirects_as_expected('/quota_definitions')
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

    it '/service_brokers redirects as expected' do
      get_redirects_as_expected('/service_brokers')
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

    it 'deletes /applications/:app_guid redirects as expected' do
      delete_redirects_as_expected('/applications/application1')
    end

    it 'deletes /organizations/:org_guid redirects as expected' do
      delete_redirects_as_expected('/organizations/organization1')
    end

    it 'deletes /routes/:route_guid redirects as expected' do
      delete_redirects_as_expected('/routes/route1')
    end

    it 'posts /organizations redirects as expected' do
      post_redirects_as_expected('/organizations', '{"name":"new_org"}')
    end

    it 'puts /applications/:app_guid redirects as expected' do
      put_redirects_as_expected('/applications/application1', '{"state":"STARTED"}')
    end

    it 'puts /organizations/:org_guid redirects as expected' do
      put_redirects_as_expected('/organizations/organization1', '{"quota_definition_guid":"quota1"}')
    end

    it 'puts /service_plans/:service_plan_guid redirects as expected' do
      put_redirects_as_expected('/service_plans/application1', '{"public":true}')
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

      expect(json).to include('apps'              => nil,
                              'deas'              => nil,
                              'organizations'     => nil,
                              'running_instances' => nil,
                              'spaces'            => nil,
                              'total_instances'   => nil,
                              'users'             => nil)
    end

    context 'Login required for post' do
      before do
        login_stub_admin
      end
      let(:cookie) { login_and_return_cookie(http) }
      let(:timestamp) { Time.now }
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

        expect(json).to eq('label' => cloud_controller_uri,
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
