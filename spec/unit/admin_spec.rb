require 'fileutils'
require 'net/https'
require 'openssl'
require 'thread'
require 'uri'
require_relative '../spec_helper'

describe AdminUI::Admin do
  include LoginHelper
  include ThreadHelper

  let(:ccdb_file) { '/tmp/admin_ui_ccdb.db' }
  let(:ccdb_uri) { "sqlite://#{ ccdb_file }" }
  let(:certificate_file_path)   { '/tmp/admin_ui_server.crt' }
  let(:certificate_request_file_path) { '/tmp/admin_ui_server.csr' }
  let(:cloud_controller_uri) { 'http://api.localhost' }
  let(:data_file) { '/tmp/admin_ui_data.json' }
  let(:db_file) { '/tmp/admin_ui_store.db' }
  let(:host) { 'localhost' }
  let(:log_file) { '/tmp/admin_ui.log' }
  let(:openssl_config) { 'spec/ssl/openssl.cnf' }
  let(:port) { 8071 }
  let(:private_key_file_path)   { '/tmp/admin_ui_server.key' }
  let(:private_key_pass_phrase) { 'private_key_pass_phrase'  }
  let(:secured_client_connection) { false }
  let(:stats_file) { '/tmp/admin_ui_stats.json' }
  let(:table_height) { '300px' }
  let(:table_page_size) { 10 }
  let(:tasks_refresh_interval) { 6000 }
  let(:uaadb_file) { '/tmp/admin_ui_uaadb.db' }
  let(:uaadb_uri)  { "sqlite://#{ uaadb_file }" }
  let(:config) do
    { ccdb_uri:                  ccdb_uri,
      cloud_controller_uri:      cloud_controller_uri,
      data_file:                 data_file,
      db_uri:                    "sqlite://#{ db_file }",
      log_file:                  log_file,
      mbus:                      'nats://nats:c1oudc0w@localhost:14222',
      port:                      port,
      secured_client_connection: secured_client_connection,
      ssl:                       { certificate_file_path:   certificate_file_path,
                                   max_session_idle_length: 1000,
                                   private_key_file_path:   private_key_file_path,
                                   private_key_pass_phrase: private_key_pass_phrase
                                 },
      stats_file:                stats_file,
      table_height:              table_height,
      table_page_size:           table_page_size,
      tasks_refresh_interval:    tasks_refresh_interval,
      uaadb_uri:                 uaadb_uri,
      uaa_client:                { id: 'id', secret: 'secret' }
    }
  end

  before do
    generate_certificate if secured_client_connection

    File.delete(db_file) if File.exist?(db_file)

    ::WEBrick::Log.any_instance.stub(:log)

    mutex                  = Mutex.new
    condition              = ConditionVariable.new
    start_callback_invoked = false
    start_callback         = proc do
      mutex.synchronize do
        start_callback_invoked = true
        condition.broadcast
      end
    end

    Thread.new do
      AdminUI::Admin.new(config, true, start_callback).start
    end

    mutex.synchronize do
      condition.wait(mutex) until start_callback_invoked
    end
  end

  after do
    if secured_client_connection
      FileUtils.rm_rf(certificate_file_path)
      FileUtils.rm_rf(certificate_request_file_path)
      FileUtils.rm_rf(private_key_file_path)
    end

    Rack::Handler::WEBrick.shutdown

    kill_threads

    Process.wait(Process.spawn({}, "rm -fr #{ ccdb_file } #{ data_file } #{ db_file } #{ log_file } #{ stats_file } #{ uaadb_file }"))
  end

  def generate_certificate
    system "openssl genrsa -des3 -out #{ private_key_file_path } -3 -passout pass:#{private_key_pass_phrase} 1024 > /dev/null 2>&1"
    system "openssl req -new -key #{ private_key_file_path } -out #{ certificate_request_file_path } -passin pass:#{ private_key_pass_phrase } -config #{ openssl_config } > /dev/null 2>&1"
    system "openssl x509 -req -days 365 -in #{ certificate_request_file_path } -signkey #{ private_key_file_path } -out #{ certificate_file_path } -passin pass:#{ private_key_pass_phrase } > /dev/null 2>&1"
  end

  def create_http
    http = Net::HTTP.new(host, port)
    if secured_client_connection
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    http
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
      if secured_client_connection
        cookie = { 'cookie' => response.to_hash['set-cookie'].map { |ea| ea[/^.*?;/] }.join }
      else
        cookie = response['Set-Cookie'] unless response['Set-Cookie'].nil?
      end

      break unless response['location']
      uri = URI.parse(response['location'])
    end

    expect(cookie).to_not be_nil

    cookie
  end

  def logout(http)
    request = Net::HTTP::Get.new('/logout')
    request['Cookie'] = cookie
    request['Content-Length'] = 0

    response = http.request(request)
    expect(response.is_a?(Net::HTTPOK)).to be_true

    body = response.body
    expect(body['redirect']).not_to be_nil

    cookie = response['Set-Cookie']
    expect(cookie).to_not be_nil

    cookie
  end

  shared_examples 'common_destroys the session after logout' do
    before do
      login_stub_admin
    end
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    it 'destroys the session after logout' do
      new_cookie = logout(http)
      expect(new_cookie.inspect).not_to eq(cookie.inspect)
    end
  end

  context 'Destroys the plain http session after logout' do
    it_behaves_like('common_destroys the session after logout')
  end

  context 'Destroys the https session after logout' do
    let(:secured_client_connection) { true }

    it_behaves_like('common_destroys the session after logout')
  end

  shared_examples 'common Login required, performed and failed' do
    let(:http) { create_http }
    it 'login fails as expected' do
      request = Net::HTTP::Get.new('/')

      response = http.request(request)
      expect(response.is_a?(Net::HTTPSeeOther)).to be_true

      location = response['location']
      expect(location).not_to be_nil
    end
  end

  context 'Login required, performed and failed via http' do
    before do
      login_stub_fail
    end

    it_behaves_like 'common Login required, performed and failed'
  end

  context 'Login required, performed and failed https' do
    before do
      login_stub_fail
    end
    let(:secured_client_connection) { true }

    it_behaves_like 'common Login required, performed and failed'
  end

  context 'Login required, performed and succeeded' do
    before do
      login_stub_admin
    end
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    def put(path, body = nil)
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

    shared_examples 'common create organization' do
      it 'returns failure code due to disconnection' do
        response = post('/organizations', '{"name":"new_org"}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'create organization via http' do
      it_behaves_like('common create organization')
    end

    context 'create organization via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common create organization')
    end

    shared_examples 'common create space quota definition space' do
      it 'returns failure code due to disconnection' do
        response = put('/space_quota_definitions/space_quota1/spaces/space1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'create space quota definition space via http' do
      it_behaves_like('common create space quota definition space')
    end

    context 'create space quota defintion space via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common create space quota definition space')
    end

    shared_examples 'common delete application' do
      it 'returns failure code due to disconnection' do
        response = delete('/applications/application1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete application via http' do
      it_behaves_like('common delete application')
    end

    context 'delete application via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete application')
    end

    shared_examples 'common delete application instance' do
      it 'returns failure code due to disconnection' do
        response = delete('/applications/application1/index0')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete application instance via http' do
      it_behaves_like('common delete application instance')
    end

    context 'delete application instance via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete application instance')
    end

    shared_examples 'common delete application recursive' do
      it 'returns failure code due to disconnection' do
        response = delete('/applications/application1?recursive=true')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete application recursive via http' do
      it_behaves_like('common delete application recursive')
    end

    context 'delete application recursive via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete application recursive')
    end

    shared_examples 'common delete domain' do
      it 'returns failure code due to disconnection' do
        response = delete('/domains/domain1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete domain via http' do
      it_behaves_like('common delete domain')
    end

    context 'delete domain via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete domain')
    end

    shared_examples 'common delete domain recursive' do
      it 'returns failure code due to disconnection' do
        response = delete('/domains/domain1?recursive=true')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete domain recursive via http' do
      it_behaves_like('common delete domain recursive')
    end

    context 'delete domain recursive via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete domain recursive')
    end

    shared_examples 'common delete organization' do
      it 'returns failure code due to disconnection' do
        response = delete('/organizations/organization1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete organization via http' do
      it_behaves_like('common delete organization')
    end

    context 'delete organization via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete organization')
    end

    shared_examples 'common delete organization recursive' do
      it 'returns failure code due to disconnection' do
        response = delete('/organizations/organization1?recursive=true')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete organization recursive via http' do
      it_behaves_like('common delete organization recursive')
    end

    context 'delete organization recursive via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete organization recursive')
    end

    shared_examples 'common delete organization role' do
      it 'returns failure code due to disconnection' do
        response = delete('/organizations/organization1/auditors/user1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete organization role via http' do
      it_behaves_like('common delete organization role')
    end

    context 'delete organization role via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete organization role')
    end

    shared_examples 'common delete quota definition' do
      it 'returns failure code due to disconnection' do
        response = delete('/quota_definitions/quota1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete quota definition via http' do
      it_behaves_like('common delete quota definition')
    end

    context 'delete quota definition via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete quota definition')
    end

    shared_examples 'common delete route' do
      it 'returns failure code due to disconnection' do
        response = delete('/routes/route1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete route via http' do
      it_behaves_like('common delete route')
    end

    context 'delete route via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete route')
    end

    shared_examples 'common delete service' do
      it 'returns failure code due to disconnection' do
        response = delete('/services/service1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete service via http' do
      it_behaves_like('common delete service')
    end

    context 'delete service via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service')
    end

    shared_examples 'common purge service' do
      it 'returns failure code due to disconnection' do
        response = delete('/services/service1?purge=true')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'purge service via http' do
      it_behaves_like('common purge service')
    end

    context 'purge service via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common purge service')
    end

    shared_examples 'common delete service binding' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_bindings/service_binding1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete service binding via http' do
      it_behaves_like('common delete service binding')
    end

    context 'delete service binding via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service binding')
    end

    shared_examples 'common delete service broker' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_brokers/service_broker1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete service broker via http' do
      it_behaves_like('common delete service broker')
    end

    context 'delete service broker via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service broker')
    end

    shared_examples 'common delete service instance' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_instances/service_instance1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete service instance via http' do
      it_behaves_like('common delete service instance')
    end

    context 'delete service instance via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service instance')
    end

    shared_examples 'common delete service instance recursive' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_instances/service_instance1?recursive=true')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete service instance recursive via http' do
      it_behaves_like('common delete service instance recursive')
    end

    context 'delete service instance recursive via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service instance recursive')
    end

    shared_examples 'common delete service key' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_keys/service_key1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete service key via http' do
      it_behaves_like('common delete service key')
    end

    context 'delete service key via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service key')
    end

    shared_examples 'common delete service plan' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_plans/service_plan1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete service plan via http' do
      it_behaves_like('common delete service plan')
    end

    context 'delete service plan via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service plan')
    end

    shared_examples 'common delete service plan visibility' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_plan_visibilities/service_plan_visibility1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete service plan visibility via http' do
      it_behaves_like('common delete service plan visibility')
    end

    context 'delete service plan visibility via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service plan visibility')
    end

    shared_examples 'common delete space' do
      it 'returns failure code due to disconnection' do
        response = delete('/spaces/space1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete space via http' do
      it_behaves_like('common delete space')
    end

    context 'delete space via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete space')
    end

    shared_examples 'common delete space recursive' do
      it 'returns failure code due to disconnection' do
        response = delete('/spaces/space1?recursive=true')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete space recursive via http' do
      it_behaves_like('common delete space recursive')
    end

    context 'delete space recursive via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete space recursive')
    end

    shared_examples 'common delete space quota definition' do
      it 'returns failure code due to disconnection' do
        response = delete('/space_quota_definitions/space_quota1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete space quota definition via http' do
      it_behaves_like('common delete space quota definition')
    end

    context 'delete space quota definition via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete space quota definition')
    end

    shared_examples 'common delete space quota definition space' do
      it 'returns failure code due to disconnection' do
        response = delete('/space_quota_definitions/space_quota1/spaces/space1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete space quota definition space role via http' do
      it_behaves_like('common delete space quota definition space')
    end

    context 'delete space quota definition space via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete space quota definition space')
    end

    shared_examples 'common delete space role' do
      it 'returns failure code due to disconnection' do
        response = delete('/spaces/space1/auditors/user1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'delete space role via http' do
      it_behaves_like('common delete space role')
    end

    context 'delete space role via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete space role')
    end

    shared_examples 'common manage application' do
      it 'returns failure code due to disconnection' do
        response = put('/applications/application1', '{"state":"STARTED"}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'manage application via http' do
      it_behaves_like('common manage application')
    end

    context 'manage application via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common manage application')
    end

    shared_examples 'common manage organization' do
      it 'returns failure code due to disconnection' do
        response = put('/organizations/organization1', '{"quota_definition_guid":"quota1"}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'manage organization via http' do
      it_behaves_like('common manage organization')
    end

    context 'manage organization via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common manage organization')
    end

    shared_examples 'common manage service plan' do
      it 'returns failure code due to disconnection' do
        response = put('/service_plans/service_plan1', '{"public": true }')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'manage service plan via http' do
      it_behaves_like('common manage organization')
    end

    context 'manage service plan via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common manage service plan')
    end

    shared_examples 'common restage application' do
      it 'returns failure code due to disconnection' do
        response = post('/applications/application1/restage', '{}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be_true
      end
    end

    context 'restage application via http' do
      it_behaves_like('common restage application')
    end

    context 'manage restage via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common restage application')
    end
  end

  context 'Login required; REST services performed and succeeded' do
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

    def verify_view_model_items(path, connected)
      json = get_json(path)

      expect(json).to include('iTotalDisplayRecords' => 0, 'iTotalRecords' => 0, 'sEcho' => 0)
      items = json['items']
      expect(items).not_to be(nil)
      expect(items).to include('connected' => connected, 'items' => [])
    end

    def verify_connected_view_model_empty_items(path)
      verify_view_model_items(path, true)
    end

    def verify_disconnected_view_model_items(path)
      verify_view_model_items(path, false)
    end

    def verify_disconnected_items(path)
      json = get_json(path)
      expect(json).to include('connected' => false, 'items' => [])
    end

    def verify_empty_items(path)
      json = get_json(path)

      expect(json).to include('items' => [])
    end

    def verify_not_found(path)
      request = Net::HTTP::Get.new(path)
      request['Cookie'] = cookie

      response = http.request(request)
      expect(response.is_a?(Net::HTTPNotFound)).to be_true
    end

    shared_examples 'common all tabs succeed' do
      before do
        login_stub_admin
      end

      it '/application_instances_view_model succeeds' do
        verify_disconnected_view_model_items('/application_instances_view_model')
      end

      it '/application_instances_view_model/:app_guid/:instance_id returns not found' do
        verify_not_found('/application_instances_view_model/application1/instance1')
      end

      it '/applications_view_model succeeds' do
        verify_disconnected_view_model_items('/applications_view_model')
      end

      it '/applications_view_model/:guid returns not found' do
        verify_not_found('/applications_view_model/application1')
      end

      it '/clients_view_model succeeds' do
        verify_disconnected_view_model_items('/clients_view_model')
      end

      it '/clients_view_model/:id returns not found' do
        verify_not_found('/clients_view_model/id')
      end

      it '/cloud_controllers_view_model succeeds' do
        verify_disconnected_view_model_items('/cloud_controllers_view_model')
      end

      it '/cloud_controllers_view_model/:name returns not found' do
        verify_not_found('/cloud_controllers_view_model/name')
      end

      it '/components_view_model succeeds' do
        verify_disconnected_view_model_items('/components_view_model')
      end

      it '/components_view_model/:name returns not found' do
        verify_not_found('/components_view_model/name')
      end

      it '/deas_view_model succeeds' do
        verify_disconnected_view_model_items('/deas_view_model')
      end

      it '/deas_view_model/:name returns not found' do
        verify_not_found('/deas_view_model/name')
      end

      it '/domains_view_model succeeds' do
        verify_disconnected_view_model_items('/domains_view_model')
      end

      it '/domains_view_model/:guid returns not found' do
        verify_not_found('/domains_view_model/domain1')
      end

      it '/events_view_model succeeds' do
        verify_disconnected_view_model_items('/events_view_model')
      end

      it '/events_view_model/:guid returns not found' do
        verify_not_found('/events_view_model/event1')
      end

      it '/gateways_view_model succeeds' do
        verify_disconnected_view_model_items('/gateways_view_model')
      end

      it '/gateways_view_model/:name returns not found' do
        verify_not_found('/gateways_view_model/name')
      end

      it '/health_managers_view_model succeeds' do
        verify_disconnected_view_model_items('/health_managers_view_model')
      end

      it '/health_managers_view_model/:name returns not found' do
        verify_not_found('/health_managers_view_model/name')
      end

      it '/logs_view_model succeeds' do
        verify_connected_view_model_empty_items('/logs_view_model')
      end

      it '/organizations_view_model succeeds' do
        verify_disconnected_view_model_items('/organizations_view_model')
      end

      it '/organizations_view_model/:guid returns not found' do
        verify_not_found('/organizations_view_model/organization1')
      end

      it '/organization_roles_view_model succeeds' do
        verify_disconnected_view_model_items('/organization_roles_view_model')
      end

      it '/organization_roles_view_model/:guid/:role/:guid returns not found' do
        verify_not_found('/organization_roles_view_model/organization1/auditors/user1')
      end

      it '/quotas_view_model succeeds' do
        verify_disconnected_view_model_items('/quotas_view_model')
      end

      it '/quotas_view_model/:guid returns not found' do
        verify_not_found('/quotas_view_model/quota1')
      end

      it '/routers_view_model succeeds' do
        verify_disconnected_view_model_items('/routers_view_model')
      end

      it '/routers_view_model/:name returns not found' do
        verify_not_found('/routers_view_model/name')
      end

      it '/routes_view_model succeeds' do
        verify_disconnected_view_model_items('/routes_view_model')
      end

      it '/routes_view_model/:guid returns not found' do
        verify_not_found('/routes_view_model/route1')
      end

      it '/settings succeeds' do
        json = get_json('/settings')

        expect(json).to eq('admin'                  => true,
                           'cloud_controller_uri'   => cloud_controller_uri,
                           'table_height'           => table_height,
                           'table_page_size'        => table_page_size,
                           'tasks_refresh_interval' => tasks_refresh_interval)
      end

      it '/service_bindings_view_model succeeds' do
        verify_disconnected_view_model_items('/service_bindings_view_model')
      end

      it '/service_bindings_view_model/:guid returns not found' do
        verify_not_found('/service_bindings_view_model/service_binding1')
      end

      it '/service_brokers_view_model succeeds' do
        verify_disconnected_view_model_items('/service_brokers_view_model')
      end

      it '/service_brokers_view_model/:guid returns not found' do
        verify_not_found('/service_brokers_view_model/service_broker1')
      end

      it '/service_instances_view_model succeeds' do
        verify_disconnected_view_model_items('/service_instances_view_model')
      end

      it '/service_instances_view_model/:guid returns not found' do
        verify_not_found('/service_instances_view_model/service_instance1')
      end

      it '/service_keys_view_model succeeds' do
        verify_disconnected_view_model_items('/service_keys_view_model')
      end

      it '/service_keys_view_model/:guid returns not found' do
        verify_not_found('/service_keys_view_model/service_key1')
      end

      it '/service_plans_view_model succeeds' do
        verify_disconnected_view_model_items('/service_plans_view_model')
      end

      it '/service_plans_view_model/:guid returns not found' do
        verify_not_found('/service_plans_view_model/service_plan1')
      end

      it '/service_plan_visibilities_view_model succeeds' do
        verify_disconnected_view_model_items('/service_plan_visibilities_view_model')
      end

      it '/service_plan_visibilities_view_model/:guid returns not found' do
        verify_not_found('/service_plan_visibilities_view_model/service_plan_visibility1')
      end

      it '/services_view_model succeeds' do
        verify_disconnected_view_model_items('/services_view_model')
      end

      it '/services_view_model/:guid returns not found' do
        verify_not_found('/services_view_model/service1')
      end

      it '/space_quotas_view_model succeeds' do
        verify_disconnected_view_model_items('/space_quotas_view_model')
      end

      it '/space_quotas_view_model/:guid returns not found' do
        verify_not_found('/space_quotas_view_model/space_quota1')
      end

      it '/space_roles_view_model succeeds' do
        verify_disconnected_view_model_items('/space_roles_view_model')
      end

      it '/space_roles_view_model/:guid/:role/:guid returns not found' do
        verify_not_found('/space_roles_view_model/space1/auditors/user1')
      end

      it '/spaces_view_model succeeds' do
        verify_disconnected_view_model_items('/spaces_view_model')
      end

      it '/spaces_view_model/:guid returns not found' do
        verify_not_found('/spaces_view_model/space1')
      end

      it '/stacks_view_model succeeds' do
        verify_disconnected_view_model_items('/stacks_view_model')
      end

      it '/stacks_view_model/:guid returns not found' do
        verify_not_found('/stacks_view_model/stack1')
      end

      it '/tasks_view_model succeeds' do
        verify_connected_view_model_empty_items('/tasks_view_model')
      end

      it '/users_view_model succeeds' do
        verify_disconnected_view_model_items('/users_view_model')
      end

      it '/users_view_model/:guid returns not found' do
        verify_not_found('/users_view_model/user1')
      end
    end

    context 'all tabs via http' do
      it_behaves_like('common all tabs succeed')
    end

    context 'all tabs via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common all tabs succeed')
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

    def post_redirects_as_expected(path, body = nil)
      request = Net::HTTP::Post.new(path)
      request.body = body if body
      do_redirect_request(request)
    end

    def put_redirects_as_expected(path, body = nil)
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

    shared_examples 'common all tabs redirect' do
      before do
        login_stub_fail
      end
      let(:http) { create_http }

      it '/application_instances_view_model redirects as expected' do
        get_redirects_as_expected('/application_instances_view_model')
      end

      it '/application_instances_view_model/:app_guid/:instance_id redirects as expected' do
        get_redirects_as_expected('/application_instances_view_model/application1/instance1')
      end

      it '/applications_view_model redirects as expected' do
        get_redirects_as_expected('/applications_view_model')
      end

      it '/applications_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/applications_view_model/application1')
      end

      it '/clients_view_model redirects as expected' do
        get_redirects_as_expected('/clients_view_model')
      end

      it '/clients_view_model/:id redirects as expected' do
        get_redirects_as_expected('/clients_view_model/id')
      end

      it '/cloud_controllers_view_model redirects as expected' do
        get_redirects_as_expected('/cloud_controllers_view_model')
      end

      it '/cloud_controllers_view_model/:name redirects as expected' do
        get_redirects_as_expected('/cloud_controllers_view_model/name')
      end

      it '/components_view_model redirects as expected' do
        get_redirects_as_expected('/components_view_model')
      end

      it '/components_view_model/:name redirects as expected' do
        get_redirects_as_expected('/components_view_model/name')
      end

      it '/deas_view_model redirects as expected' do
        get_redirects_as_expected('/deas_view_model')
      end

      it '/deas_view_model/:name redirects as expected' do
        get_redirects_as_expected('/deas_view_model/name')
      end

      it '/domains_view_model redirects as expected' do
        get_redirects_as_expected('/domains_view_model')
      end

      it '/domains_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/domains_view_model/domain1')
      end

      it '/download redirects as expected' do
        get_redirects_as_expected('/download')
      end

      it '/events_view_model redirects as expected' do
        get_redirects_as_expected('/events_view_model')
      end

      it '/events_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/events_view_model/domain1')
      end

      it '/gateways_view_model redirects as expected' do
        get_redirects_as_expected('/gateways_view_model')
      end

      it '/gateways_view_model/:name redirects as expected' do
        get_redirects_as_expected('/gateways_view_model/name')
      end

      it '/health_managers_view_model redirects as expected' do
        get_redirects_as_expected('/health_managers_view_model')
      end

      it '/health_managers_view_model/:name redirects as expected' do
        get_redirects_as_expected('/health_managers_view_model/name')
      end

      it '/log redirects as expected' do
        get_redirects_as_expected('/log')
      end

      it '/logs_view_model redirects as expected' do
        get_redirects_as_expected('/logs_view_model')
      end

      it '/organization_roles_view_model redirects as expected' do
        get_redirects_as_expected('/organization_roles_view_model')
      end

      it '/organization_roles_view_model/:guid/:role/:guid redirects as expected' do
        get_redirects_as_expected('/organization_roles_view_model/organization1/auditors/user1')
      end

      it '/organizations_view_model redirects as expected' do
        get_redirects_as_expected('/organizations_view_model')
      end

      it '/organizations_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/organizations_view_model/organization1')
      end

      it '/quotas_view_model redirects as expected' do
        get_redirects_as_expected('/quotas_view_model')
      end

      it '/quotas_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/quotas_view_model/quota1')
      end

      it '/routers_view_model redirects as expected' do
        get_redirects_as_expected('/routers_view_model')
      end

      it '/routers_view_model/:name redirects as expected' do
        get_redirects_as_expected('/routers_view_model/name')
      end

      it '/routes_view_model redirects as expected' do
        get_redirects_as_expected('/routes_view_model')
      end

      it '/routes_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/routes_view_model/route1')
      end

      it '/settings redirects as expected' do
        get_redirects_as_expected('/settings')
      end

      it '/service_bindings_view_model redirects as expected' do
        get_redirects_as_expected('/service_bindings_view_model')
      end

      it '/service_bindings_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/service_bindings_view_model/service_binding1')
      end

      it '/service_brokers_view_model redirects as expected' do
        get_redirects_as_expected('/service_brokers_view_model')
      end

      it '/service_brokers_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/service_brokers_view_model/service_broker1')
      end

      it '/service_instances_view_model redirects as expected' do
        get_redirects_as_expected('/service_instances_view_model')
      end

      it '/service_instances_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/service_instances_view_model/service_instance1')
      end

      it '/service_keys_view_model redirects as expected' do
        get_redirects_as_expected('/service_keys_view_model')
      end

      it '/service_keys_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/service_keys_view_model/service_key1')
      end

      it '/service_plans_view_model redirects as expected' do
        get_redirects_as_expected('/service_plans_view_model')
      end

      it '/service_plans_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/service_plans_view_model/service_plan1')
      end

      it '/service_plan_visibilities_view_model redirects as expected' do
        get_redirects_as_expected('/service_plan_visibilities_view_model')
      end

      it '/service_plan_visibilities_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/service_plans_view_model/service_plan_visibilities1')
      end

      it '/services_view_model redirects as expected' do
        get_redirects_as_expected('/services_view_model')
      end

      it '/services_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/services_view_model/service1')
      end

      it '/space_quotas_view_model redirects as expected' do
        get_redirects_as_expected('/space_quotas_view_model')
      end

      it '/space_quotas_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/space_quotas_view_model/space_quota1')
      end

      it '/space_roles_view_model redirects as expected' do
        get_redirects_as_expected('/space_roles_view_model')
      end

      it '/space_roles_view_model/:guid/:role/:guid redirects as expected' do
        get_redirects_as_expected('/space_roles_view_model/space1/auditors/user1')
      end

      it '/spaces_view_model redirects as expected' do
        get_redirects_as_expected('/spaces_view_model')
      end

      it '/spaces_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/spaces_view_model/space1')
      end

      it '/stacks_view_model redirects as expected' do
        get_redirects_as_expected('/stacks_view_model')
      end

      it '/stacks_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/stacks_view_model/stack1')
      end

      it '/tasks_view_model redirects as expected' do
        get_redirects_as_expected('/tasks_view_model')
      end

      it '/task_status redirects as expected' do
        get_redirects_as_expected('/task_status')
      end

      it '/users_view_model redirects as expected' do
        get_redirects_as_expected('/users_view_model')
      end

      it '/users_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/users_view_model/user1')
      end

      it 'deletes /applications/:guid redirects as expected' do
        delete_redirects_as_expected('/applications/application1')
      end

      it 'deletes /applications/:guid?recursive=true redirects as expected' do
        delete_redirects_as_expected('/applications/application1?recursive=true')
      end

      it 'deletes /applications/:app_guid/:index redirects as expected' do
        delete_redirects_as_expected('/applications/application1/index0')
      end

      it 'deletes /domains/:guid redirects as expected' do
        delete_redirects_as_expected('/domains/domain1')
      end

      it 'deletes /domains/:guid?recursive=true redirects as expected' do
        delete_redirects_as_expected('/domains/domain1?recursive=true')
      end

      it 'deletes /organizations/:guid redirects as expected' do
        delete_redirects_as_expected('/organizations/organization1')
      end

      it 'deletes /organizations/:guid?recursive=true redirects as expected' do
        delete_redirects_as_expected('/organizations/organization1?recursive=true')
      end

      it 'deletes /organizations/:guid/:role/:guid redirects as expected' do
        delete_redirects_as_expected('/organizations/organization1/auditors/user1')
      end

      it 'deletes /quota_definitions/:guid redirects as expected' do
        delete_redirects_as_expected('/quota_definitions/quota1')
      end

      it 'deletes /routes/:guid redirects as expected' do
        delete_redirects_as_expected('/routes/route1')
      end

      it 'deletes /service_bindings/:guid redirects as expected' do
        delete_redirects_as_expected('/service_bindings/service_binding1')
      end

      it 'deletes /service_brokers/:guid redirects as expected' do
        delete_redirects_as_expected('/service_brokers/service_broker1')
      end

      it 'deletes /service_instances/:guid redirects as expected' do
        delete_redirects_as_expected('/service_instances/service_instance1')
      end

      it 'deletes /service_instances/:guid?recursive=true redirects as expected' do
        delete_redirects_as_expected('/service_instances/service_instance1?recursive=true')
      end

      it 'deletes /service_keys/:guid redirects as expected' do
        delete_redirects_as_expected('/service_keys/service_key1')
      end

      it 'deletes /service_plans/:guid redirects as expected' do
        delete_redirects_as_expected('/service_plans/service_plan1')
      end

      it 'deletes /service_plan_visibilities/:guid redirects as expected' do
        delete_redirects_as_expected('/service_plan_visibilities/service_plan_visibility1')
      end

      it 'deletes /services/:guid redirects as expected' do
        delete_redirects_as_expected('/services/service1')
      end

      it 'deletes /services/:guid?purge=true redirects as expected' do
        delete_redirects_as_expected('/services/service1?purge=true')
      end

      it 'deletes /space_quota_definitions/:guid redirects as expected' do
        delete_redirects_as_expected('/space_quota_definitions/space_quota1')
      end

      it 'deletes /space_quota_definitions/:guid/spaces/:guid redirects as expected' do
        delete_redirects_as_expected('/space_quota_definitions/space_quota1/spaces/space1')
      end

      it 'deletes /spaces/:guid redirects as expected' do
        delete_redirects_as_expected('/spaces/space1')
      end

      it 'deletes /spaces/:guid?recursive=true redirects as expected' do
        delete_redirects_as_expected('/spaces/space1?recursive=true')
      end

      it 'deletes /spaces/:guid/:role/:guid redirects as expected' do
        delete_redirects_as_expected('/spaces/space1/auditors/user1')
      end

      it 'posts /application_instances_view_model redirects as expected' do
        post_redirects_as_expected('/application_instances_view_model')
      end

      it 'posts /applications/:guid/restage redirects as expected' do
        post_redirects_as_expected('/applications/application1/restage', '{}')
      end

      it 'posts /applications_view_model redirects as expected' do
        post_redirects_as_expected('/applications_view_model')
      end

      it 'posts /clients_view_model redirects as expected' do
        post_redirects_as_expected('/clients_view_model')
      end

      it 'posts /cloud_controllers_view_model redirects as expected' do
        post_redirects_as_expected('/cloud_controllers_view_model')
      end

      it 'posts /components_view_model redirects as expected' do
        post_redirects_as_expected('/components_view_model')
      end

      it 'posts /organizations redirects as expected' do
        post_redirects_as_expected('/organizations', '{"name":"new_org"}')
      end

      it 'posts /deas_view_model redirects as expected' do
        post_redirects_as_expected('/deas_view_model')
      end

      it 'posts /domains_view_model redirects as expected' do
        post_redirects_as_expected('/domains_view_model')
      end

      it 'posts /events_view_model redirects as expected' do
        post_redirects_as_expected('/events_view_model')
      end

      it 'posts /gateways_view_model redirects as expected' do
        post_redirects_as_expected('/gateways_view_model')
      end

      it 'posts /health_managers_view_model redirects as expected' do
        post_redirects_as_expected('/health_managers_view_model')
      end

      it 'posts /logs_view_model redirects as expected' do
        post_redirects_as_expected('/logs_view_model')
      end

      it 'posts /organizations_view_model redirects as expected' do
        post_redirects_as_expected('/organizations_view_model')
      end

      it 'posts /organization_roles_view_model redirects as expected' do
        post_redirects_as_expected('/organization_roles_view_model')
      end

      it 'posts /quotas_view_model redirects as expected' do
        post_redirects_as_expected('/quotas_view_model')
      end

      it 'posts /routers_view_model redirects as expected' do
        post_redirects_as_expected('/routers_view_model')
      end

      it 'posts /routes_view_model redirects as expected' do
        post_redirects_as_expected('/routes_view_model')
      end

      it 'posts /service_bindings_view_model redirects as expected' do
        post_redirects_as_expected('/service_bindings_view_model')
      end

      it 'posts /service_brokers_view_model redirects as expected' do
        post_redirects_as_expected('/service_brokers_view_model')
      end

      it 'posts /service_instances_view_model redirects as expected' do
        post_redirects_as_expected('/service_instances_view_model')
      end

      it 'posts /service_keys_view_model redirects as expected' do
        post_redirects_as_expected('/service_keys_view_model')
      end

      it 'posts /service_plans_view_model redirects as expected' do
        post_redirects_as_expected('/service_plans_view_model')
      end

      it 'posts /service_plan_visibilities_view_model redirects as expected' do
        post_redirects_as_expected('/service_plan_visibilities_view_model')
      end

      it 'posts /services_view_model redirects as expected' do
        post_redirects_as_expected('/services_view_model')
      end

      it 'posts /space_quotas_view_model redirects as expected' do
        post_redirects_as_expected('/space_quotas_view_model')
      end

      it 'posts /space_roles_view_model redirects as expected' do
        post_redirects_as_expected('/space_roles_view_model')
      end

      it 'posts /spaces_view_model redirects as expected' do
        post_redirects_as_expected('/spaces_view_model')
      end

      it 'posts /stacks_view_model redirects as expected' do
        post_redirects_as_expected('/stacks_view_model')
      end

      it 'posts /stats_view_model redirects as expected' do
        post_redirects_as_expected('/stats_view_model')
      end

      it 'posts /tasks_view_model redirects as expected' do
        post_redirects_as_expected('/tasks_view_model')
      end

      it 'posts /users_view_model redirects as expected' do
        post_redirects_as_expected('/users_view_model')
      end

      it 'puts /applications/:guid redirects as expected' do
        put_redirects_as_expected('/applications/application1', '{"state":"STARTED"}')
      end

      it 'puts /organizations/:guid redirects as expected' do
        put_redirects_as_expected('/organizations/organization1', '{"quota_definition_guid":"quota1"}')
      end

      it 'puts /service_plans/:guid redirects as expected' do
        put_redirects_as_expected('/service_plans/application1', '{"public":true}')
      end

      it 'puts /space_quota_definitions/:guid/spaces/:guid redirects as expected' do
        put_redirects_as_expected('/space_quota_definitions/space_quota1/spaces/space1')
      end
    end

    context 'all tabs via http' do
      it_behaves_like('common all tabs redirect')
    end

    context 'all tabs via https' do
      let(:secured_client_connection) { true }
      it_behaves_like('common all tabs redirect')
    end
  end

  context 'Login not required' do
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

    shared_examples 'common Login not required' do
      before do
        login_stub_fail
      end
      let(:http) { create_http }

      it '/favicon.ico succeeds' do
        get_response('/favicon.ico')
      end

      it '/stats succeeds' do
        get_body('/stats')
      end

      it '/stats_view_model succeeds' do
        get_body('/stats_view_model')
      end
    end

    context 'Login not required via http' do
      it_behaves_like('common Login not required')
    end

    context 'Login not required via https' do
      let(:secured_client_connection) { true }
      it_behaves_like('common Login not required')
    end
  end

  context 'Statistics' do
    shared_examples 'common Statistics' do
      before do
        login_stub_fail
      end
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
    end

    context 'Statistics via http' do
      it_behaves_like('common Statistics')
    end

    context 'Statistics via https' do
      let(:secured_client_connection) { true }
      it_behaves_like('common Statistics')
    end

    context 'Login required for post' do
      shared_examples 'common Login required for post' do
        before do
          login_stub_admin
        end
        let(:http) { create_http }
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

      context 'Login required for post via http' do
        it_behaves_like('common Login required for post')
      end

      context 'Login required for post via https' do
        let(:secured_client_connection) { true }
        it_behaves_like('common Login required for post')
      end
    end
  end
end
