require 'fileutils'
require 'net/https'
require 'openssl'
require 'uri'
require 'yajl'
require_relative '../spec_helper'

describe AdminUI::Admin do
  include LoginHelper

  let(:ccdb_file) { '/tmp/admin_ui_ccdb.db' }
  let(:ccdb_uri) { "sqlite://#{ccdb_file}" }
  let(:certificate_file_path) { '/tmp/admin_ui_server.crt' }
  let(:certificate_request_file_path) { '/tmp/admin_ui_server.csr' }
  let(:cloud_controller_uri) { 'http://api.localhost' }
  let(:data_file) { '/tmp/admin_ui_data.json' }
  let(:db_file) { '/tmp/admin_ui_store.db' }
  let(:doppler_data_file) { '/tmp/admin_ui_doppler_data.json' }
  let(:host) { 'localhost' }
  let(:log_file) { '/tmp/admin_ui.log' }
  let(:openssl_config) { 'spec/ssl/openssl.cnf' }
  let(:port) { 8071 }
  let(:private_key_file_path)   { '/tmp/admin_ui_server.key' }
  let(:private_key_pass_phrase) { 'private_key_pass_phrase'  }
  let(:secured_client_connection) { false }
  let(:stats_file) { '/tmp/admin_ui_stats.json' }
  let(:uaadb_file) { '/tmp/admin_ui_uaadb.db' }
  let(:uaadb_uri)  { "sqlite://#{uaadb_file}" }

  let(:config) do
    {
      ccdb_uri:                  ccdb_uri,
      cloud_controller_uri:      cloud_controller_uri,
      data_file:                 data_file,
      db_uri:                    "sqlite://#{db_file}",
      doppler_data_file:         doppler_data_file,
      doppler_rollup_interval:   1,
      log_file:                  log_file,
      mbus:                      'nats://nats:c1oudc0w@localhost:14222',
      port:                      port,
      secured_client_connection: secured_client_connection,
      ssl:                       {
                                   certificate_file_path:   certificate_file_path,
                                   max_session_idle_length: 1000,
                                   private_key_file_path:   private_key_file_path,
                                   private_key_pass_phrase: private_key_pass_phrase
                                 },
      stats_file:                stats_file,
      uaadb_uri:                 uaadb_uri,
      uaa_client:                {
                                   id:     'id',
                                   secret: 'secret'
                                 }
    }
  end

  before do
    generate_certificate if secured_client_connection

    File.delete(db_file) if File.exist?(db_file)

    allow_any_instance_of(::WEBrick::Log).to receive(:log)

    mutex                  = Mutex.new
    condition              = ConditionVariable.new
    start_callback_invoked = false
    start_callback         = proc do
      mutex.synchronize do
        start_callback_invoked = true
        condition.broadcast
      end
    end

    @admin = AdminUI::Admin.new(config, true, start_callback)

    Thread.new do
      @admin.start
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

    @admin.shutdown

    Process.wait(Process.spawn({}, "rm -fr #{ccdb_file} #{data_file} #{db_file} #{doppler_data_file} #{log_file} #{stats_file} #{uaadb_file}"))
  end

  def generate_certificate
    system "openssl genrsa -des3 -out #{private_key_file_path} -3 -passout pass:#{private_key_pass_phrase} 1024 > /dev/null 2>&1"
    system "openssl req -new -key #{private_key_file_path} -out #{certificate_request_file_path} -passin pass:#{private_key_pass_phrase} -config #{openssl_config} > /dev/null 2>&1"
    system "openssl x509 -req -days 365 -in #{certificate_request_file_path} -signkey #{private_key_file_path} -out #{certificate_file_path} -passin pass:#{private_key_pass_phrase} > /dev/null 2>&1"
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
      path += "?#{uri.query}" unless uri.query.nil?

      request = Net::HTTP::Get.new(path)
      request['Cookie'] = cookie

      response = http.request(request)

      all_cookies = response.get_fields('set-cookie')
      cookie = all_cookies.last.split('; ')[0] if all_cookies.present?

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
    expect(response.is_a?(Net::HTTPOK)).to be(true)

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
      expect(response.is_a?(Net::HTTPSeeOther)).to be(true)

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

    shared_examples 'common cancel task' do
      it 'returns failure code due to disconnection' do
        response = delete('/tasks/task1/cancel')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'cancel task via http' do
      it_behaves_like('common cancel task')
    end

    context 'cancel task via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common cancel task')
    end

    shared_examples 'common create isolation segment' do
      it 'returns failure code due to disconnection' do
        response = post('/isolation_segments', '{"name":"bogus"}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'create isolation segment via http' do
      it_behaves_like('common create isolation segment')
    end

    context 'create isolation segment via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common create isolation segment')
    end

    shared_examples 'common create organization' do
      it 'returns failure code due to disconnection' do
        response = post('/organizations', '{"name":"new_org"}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
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
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
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
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete application via http' do
      it_behaves_like('common delete application')
    end

    context 'delete application via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete application')
    end

    shared_examples 'common delete application recursive' do
      it 'returns failure code due to disconnection' do
        response = delete('/applications/application1?recursive=true')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete application recursive via http' do
      it_behaves_like('common delete application recursive')
    end

    context 'delete application recursive via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete application recursive')
    end

    shared_examples 'common delete application annotation' do
      it 'returns failure code due to disconnection' do
        response = delete('/applications/application1/metadata/annotations/annotation1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete application annotation via http' do
      it_behaves_like('common delete application annotation')
    end

    context 'delete application annotation via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete application annotation')
    end

    shared_examples 'common delete application environment variable' do
      it 'returns failure code due to disconnection' do
        response = delete('/applications/application1/environment_variables/environment_variable1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete application environment variable via http' do
      it_behaves_like('common delete application environment variable')
    end

    context 'delete application environment variable via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete application environment variable')
    end

    shared_examples 'common delete application instance' do
      it 'returns failure code due to disconnection' do
        response = delete('/applications/application1/index0')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete application instance via http' do
      it_behaves_like('common delete application instance')
    end

    context 'delete application instance via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete application instance')
    end

    shared_examples 'common delete application label' do
      it 'returns failure code due to disconnection' do
        response = delete('/applications/application1/metadata/labels/label1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete application label via http' do
      it_behaves_like('common delete application label')
    end

    context 'delete application label via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete application label')
    end

    shared_examples 'common delete application label with prefix' do
      it 'returns failure code due to disconnection' do
        response = delete('/applications/application1/metadata/labels/label1?prefix=bogus.com')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete application label with prefix via http' do
      it_behaves_like('common delete application label with prefix')
    end

    context 'delete application label with prefix via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete application label with prefix')
    end

    shared_examples 'common delete buildpack' do
      it 'returns failure code due to disconnection' do
        response = delete('/buildpacks/buildpack1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete buildpack via http' do
      it_behaves_like('common delete buildpack')
    end

    context 'delete buildpack via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete buildpack')
    end

    shared_examples 'common delete buildpack annotation' do
      it 'returns failure code due to disconnection' do
        response = delete('/buildpacks/buildpack1/metadata/annotations/annotation1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete buildpack annotation via http' do
      it_behaves_like('common delete buildpack annotation')
    end

    context 'delete buildpack annotation via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete buildpack annotation')
    end

    shared_examples 'common delete buildpack label' do
      it 'returns failure code due to disconnection' do
        response = delete('/buildpacks/buildpack1/metadata/labels/label1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete buildpack label via http' do
      it_behaves_like('common delete buildpack label')
    end

    context 'delete buildpack label via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete buildpack label')
    end

    shared_examples 'common delete buildpack label with prefix' do
      it 'returns failure code due to disconnection' do
        response = delete('/buildpacks/buildpack1/metadata/labels/label1?prefix=bogus.com')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete buildpack label with prefix via http' do
      it_behaves_like('common delete buildpack label with prefix')
    end

    context 'delete buildpack label with prefix via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete buildpack label with prefix')
    end

    shared_examples 'common delete client' do
      it 'returns failure code due to disconnection' do
        response = delete('/clients/client1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete client via http' do
      it_behaves_like('common delete client')
    end

    context 'delete client via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete client')
    end

    shared_examples 'common delete client tokens' do
      it 'returns failure code due to disconnection' do
        response = delete('/clients/client1/tokens')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete client tokens via http' do
      it_behaves_like('common delete client tokens')
    end

    context 'delete client tokens via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete client tokens')
    end
    shared_examples 'common delete domain' do
      it 'returns failure code due to disconnection' do
        response = delete('/domains/domain1/false')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
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
        response = delete('/domains/domain1/false?recursive=true')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete domain recursive via http' do
      it_behaves_like('common delete domain recursive')
    end

    context 'delete domain recursive via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete domain recursive')
    end

    shared_examples 'common delete domain annotation' do
      it 'returns failure code due to disconnection' do
        response = delete('/domains/domain1/metadata/annotations/annotation1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete domain annotation via http' do
      it_behaves_like('common delete domain annotation')
    end

    context 'delete domain annotation via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete domain annotation')
    end

    shared_examples 'common delete domain label' do
      it 'returns failure code due to disconnection' do
        response = delete('/domains/domain1/metadata/labels/label1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete domain label via http' do
      it_behaves_like('common delete domain label')
    end

    context 'delete domain label via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete domain label')
    end

    shared_examples 'common delete domain label with prefix' do
      it 'returns failure code due to disconnection' do
        response = delete('/domains/domain1/metadata/labels/label1?prefix=bogus.com')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete domain label with prefix via http' do
      it_behaves_like('common delete domain label with prefix')
    end

    context 'delete domain label with prefix via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete domain label with prefix')
    end

    shared_examples 'common delete domain organization' do
      it 'returns failure code due to disconnection' do
        response = delete('/domains/domain1/false/organization1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete domain organization via http' do
      it_behaves_like('common delete domain organization')
    end

    context 'delete domain organization via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete domain organization')
    end

    shared_examples 'common delete group' do
      it 'returns failure code due to disconnection' do
        response = delete('/groups/group1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete group via http' do
      it_behaves_like('common delete group')
    end

    context 'delete group via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete group')
    end

    shared_examples 'common delete group member' do
      it 'returns failure code due to disconnection' do
        response = delete('/groups/group1/member1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete group member via http' do
      it_behaves_like('common delete group member')
    end

    context 'delete group member via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete group member')
    end

    shared_examples 'common delete identity provider' do
      it 'returns failure code due to disconnection' do
        response = delete('/identity_providers/identity_provider1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete identity provider via http' do
      it_behaves_like('common delete identity provider')
    end

    context 'delete identity provider via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete identity provider')
    end

    shared_examples 'common delete identity zone' do
      it 'returns failure code due to disconnection' do
        response = delete('/identity_zones/identity_zone1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete identity zone via http' do
      it_behaves_like('common delete identity zone')
    end

    context 'delete identity zone via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete identity zone')
    end

    shared_examples 'common delete isolation segment' do
      it 'returns failure code due to disconnection' do
        response = delete('/isolation_segments/isolation_segment1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete isolation segment via http' do
      it_behaves_like('common delete isolation segment')
    end

    context 'delete isolation segment via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete isolation segment')
    end

    shared_examples 'common delete isolation segment annotation' do
      it 'returns failure code due to disconnection' do
        response = delete('/isolation_segments/isolation_segment1/metadata/annotations/annotation1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete isolation segment annotation via http' do
      it_behaves_like('common delete isolation segment annotation')
    end

    context 'delete isolation segment annotation via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete isolation segment annotation')
    end

    shared_examples 'common delete isolation segment label' do
      it 'returns failure code due to disconnection' do
        response = delete('/isolation_segments/isolation_segment1/metadata/labels/label1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete isolation segment label via http' do
      it_behaves_like('common delete isolation segment label')
    end

    context 'delete isolation segment label via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete isolation segment label')
    end

    shared_examples 'common delete isolation segment label with prefix' do
      it 'returns failure code due to disconnection' do
        response = delete('/isolation_segments/isolation_segment1/metadata/labels/label1?prefix=bogus.com')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete isolation segment label with prefix via http' do
      it_behaves_like('common delete isolation segment label with prefix')
    end

    context 'delete isolation segment label with prefix via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete isolation segment label with prefix')
    end

    shared_examples 'common delete MFA provider' do
      it 'returns failure code due to disconnection' do
        response = delete('/mfa_providers/mfa_provider1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete MFA provider via http' do
      it_behaves_like('common delete MFA provider')
    end

    context 'delete MFA provider via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete MFA provider')
    end

    shared_examples 'common delete organization' do
      it 'returns failure code due to disconnection' do
        response = delete('/organizations/organization1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
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
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete organization recursive via http' do
      it_behaves_like('common delete organization recursive')
    end

    context 'delete organization recursive via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete organization recursive')
    end

    shared_examples 'common delete organization annotation' do
      it 'returns failure code due to disconnection' do
        response = delete('/organizations/organization1/metadata/annotations/annotation1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete organization annotation via http' do
      it_behaves_like('common delete organization annotation')
    end

    context 'delete organization annotation via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete organization annotation')
    end

    shared_examples 'common delete organization default isolation segment' do
      it 'returns failure code due to disconnection' do
        response = delete('/organizations/organization1/default_isolation_segment')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete organization default isolation segment via http' do
      it_behaves_like('common delete organization default isolation segment')
    end

    context 'delete organization default isolation segment role via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete organization default isolation segment')
    end

    shared_examples 'common delete organization isolation segment' do
      it 'returns failure code due to disconnection' do
        response = delete('/organizations/organization1/isolation_segment1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete organization isolation segment via http' do
      it_behaves_like('common delete organization isolation segment')
    end

    context 'delete organization isolation segment role via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete organization isolation segment')
    end

    shared_examples 'common delete organization label' do
      it 'returns failure code due to disconnection' do
        response = delete('/organizations/organization1/metadata/labels/label1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete organization label via http' do
      it_behaves_like('common delete organization label')
    end

    context 'delete organization label via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete organization label')
    end

    shared_examples 'common delete organization label with prefix' do
      it 'returns failure code due to disconnection' do
        response = delete('/organizations/organization1/metadata/labels/label1?prefix=bogus.com')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete organization label with prefix via http' do
      it_behaves_like('common delete organization label with prefix')
    end

    context 'delete organization label with prefix via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete organization label with prefix')
    end

    shared_examples 'common delete organization role' do
      it 'returns failure code due to disconnection' do
        response = delete('/organizations/organization1/role1/auditors/user1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
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
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete quota definition via http' do
      it_behaves_like('common delete quota definition')
    end

    context 'delete quota definition via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete quota definition')
    end

    shared_examples 'common delete revocable token' do
      it 'returns failure code due to disconnection' do
        response = delete('/revocable_tokens/revocable_token1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete revocable token via http' do
      it_behaves_like('common delete revocable token')
    end

    context 'delete revocable token via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete revocable token')
    end

    shared_examples 'common delete route' do
      it 'returns failure code due to disconnection' do
        response = delete('/routes/route1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete route via http' do
      it_behaves_like('common delete route')
    end

    context 'delete route via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete route')
    end

    shared_examples 'common delete route recursive' do
      it 'returns failure code due to disconnection' do
        response = delete('/routes/route?recursive=true')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete route recursive via http' do
      it_behaves_like('common delete route recursive')
    end

    context 'delete route recursive via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete route recursive')
    end

    shared_examples 'common delete route annotation' do
      it 'returns failure code due to disconnection' do
        response = delete('/routes/route1/metadata/annotations/annotation1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete route annotation via http' do
      it_behaves_like('common delete route annotation')
    end

    context 'delete route annotation via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete route annotation')
    end

    shared_examples 'common delete route binding' do
      it 'returns failure code due to disconnection' do
        response = delete('/route_bindings/service_instance1/route1/true')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete route binding via http' do
      it_behaves_like('common delete route binding')
    end

    context 'delete route binding via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete route binding')
    end

    shared_examples 'common delete route label' do
      it 'returns failure code due to disconnection' do
        response = delete('/routes/route1/metadata/labels/label1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete route label via http' do
      it_behaves_like('common delete route label')
    end

    context 'delete route label via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete route label')
    end

    shared_examples 'common delete route label with prefix' do
      it 'returns failure code due to disconnection' do
        response = delete('/routes/route1/metadata/labels/label1?prefix=bogus.com')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete route label with prefix via http' do
      it_behaves_like('common delete route label with prefix')
    end

    context 'delete route label with prefix via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete route label with prefix')
    end

    shared_examples 'common delete route mapping' do
      it 'returns failure code due to disconnection' do
        response = delete('/route_mappings/route_mapping1/route1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete route mapping via http' do
      it_behaves_like('common delete route mapping')
    end

    context 'delete route mapping via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete route mapping')
    end

    shared_examples 'common delete security group' do
      it 'returns failure code due to disconnection' do
        response = delete('/security_groups/security_group1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete security group via http' do
      it_behaves_like('common delete security group')
    end

    context 'delete security group via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete security group')
    end

    shared_examples 'common delete security group space' do
      it 'returns failure code due to disconnection' do
        response = delete('/security_groups/security_group1/space1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete security group space via http' do
      it_behaves_like('common delete security group space')
    end

    context 'delete security group via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete security group space')
    end

    shared_examples 'common delete service' do
      it 'returns failure code due to disconnection' do
        response = delete('/services/service1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
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
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'purge service via http' do
      it_behaves_like('common purge service')
    end

    context 'purge service via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common purge service')
    end

    shared_examples 'common delete service annotation' do
      it 'returns failure code due to disconnection' do
        response = delete('/services/service1/metadata/annotations/annotation1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service annotation via http' do
      it_behaves_like('common delete service annotation')
    end

    context 'delete service annotation via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service annotation')
    end

    shared_examples 'common delete service label' do
      it 'returns failure code due to disconnection' do
        response = delete('/services/service1/metadata/labels/label1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service label via http' do
      it_behaves_like('common delete service label')
    end

    context 'delete service label via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service label')
    end

    shared_examples 'common delete service label with prefix' do
      it 'returns failure code due to disconnection' do
        response = delete('/services/service1/metadata/labels/label1?prefix=bogus.com')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service label with prefix via http' do
      it_behaves_like('common delete service label with prefix')
    end

    context 'delete service label with prefix via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service label with prefix')
    end

    shared_examples 'common delete service binding' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_bindings/service_binding1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service binding via http' do
      it_behaves_like('common delete service binding')
    end

    context 'delete service binding via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service binding')
    end

    shared_examples 'common delete service binding annotation' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_bindings/service_binding1/metadata/annotations/annotation1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service binding annotation via http' do
      it_behaves_like('common delete service binding annotation')
    end

    context 'delete service binding annotation via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service binding annotation')
    end

    shared_examples 'common delete service binding label' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_bindings/service_binding1/metadata/labels/label1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service binding label via http' do
      it_behaves_like('common delete service binding label')
    end

    context 'delete service binding label via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service binding label')
    end

    shared_examples 'common delete service binding label with prefix' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_bindings/service_binding1/metadata/labels/label1?prefix=bogus.com')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service binding label with prefix via http' do
      it_behaves_like('common delete service binding label with prefix')
    end

    context 'delete service binding label with prefix via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service binding label with prefix')
    end

    shared_examples 'common delete service broker' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_brokers/service_broker1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service broker via http' do
      it_behaves_like('common delete service broker')
    end

    context 'delete service broker via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service broker')
    end

    shared_examples 'common delete service broker annotation' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_brokers/service_broker1/metadata/annotations/annotation1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service broker annotation via http' do
      it_behaves_like('common delete service broker annotation')
    end

    context 'delete service broker annotation via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service broker annotation')
    end

    shared_examples 'common delete service broker label' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_brokers/service_broker1/metadata/labels/label1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service broker label via http' do
      it_behaves_like('common delete service broker label')
    end

    context 'delete service broker label via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service broker label')
    end

    shared_examples 'common delete service broker label with prefix' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_brokers/service_broker1/metadata/labels/label1?prefix=bogus.com')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service broker label with prefix via http' do
      it_behaves_like('common delete service broker label with prefix')
    end

    context 'delete service broker label with prefix via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service broker label with prefix')
    end

    shared_examples 'common delete service instance' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_instances/service_instance1/true')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
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
        response = delete('/service_instances/service_instance1/true?recursive=true')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service instance recursive via http' do
      it_behaves_like('common delete service instance recursive')
    end

    context 'delete service instance recursive via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service instance recursive')
    end

    shared_examples 'common delete service instance recursive purge' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_instances/service_instance1/true?recursive=true&purge=true')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service instance recursive purge via http' do
      it_behaves_like('common delete service instance recursive purge')
    end

    context 'delete service instance recursive purge via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service instance recursive purge')
    end

    shared_examples 'common delete service instance annotation' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_instances/service_instance1/metadata/annotations/annotation1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service instance annotation via http' do
      it_behaves_like('common delete service instance annotation')
    end

    context 'delete service instance annotation via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service instance annotation')
    end

    shared_examples 'common delete service instance label' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_instances/service_instance1/metadata/labels/label1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service instance label via http' do
      it_behaves_like('common delete service instance label')
    end

    context 'delete service instance label via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service instance label')
    end

    shared_examples 'common delete service instance label with prefix' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_instances/service_instance1/metadata/labels/label1?prefix=bogus.com')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service instance label with prefix via http' do
      it_behaves_like('common delete service instance label with prefix')
    end

    context 'delete service instance label with prefix via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service instance label with prefix')
    end

    shared_examples 'common delete service key' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_keys/service_key1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service key via http' do
      it_behaves_like('common delete service key')
    end

    context 'delete service key via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service key')
    end

    shared_examples 'common delete service key annotation' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_keys/service_key1/metadata/annotations/annotation1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service key annotation via http' do
      it_behaves_like('common delete service key annotation')
    end

    context 'delete service key annotation via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service key annotation')
    end

    shared_examples 'common delete service key label' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_keys/service_key1/metadata/labels/label1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service key label via http' do
      it_behaves_like('common delete service key label')
    end

    context 'delete service key label via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service key label')
    end

    shared_examples 'common delete service key label with prefix' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_keys/service_key1/metadata/labels/label1?prefix=bogus.com')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service key label with prefix via http' do
      it_behaves_like('common delete service key label with prefix')
    end

    context 'delete service key label with prefix via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service key label with prefix')
    end

    shared_examples 'common delete service plan' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_plans/service_plan1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service plan via http' do
      it_behaves_like('common delete service plan')
    end

    context 'delete service plan via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service plan')
    end

    shared_examples 'common delete service plan annotation' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_plans/service_plan1/metadata/annotations/annotation1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service plan annotation via http' do
      it_behaves_like('common delete service plan annotation')
    end

    context 'delete service plan annotation via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service plan annotation')
    end

    shared_examples 'common delete service plan label' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_plans/service_plan1/metadata/labels/label1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service plan label via http' do
      it_behaves_like('common delete service plan label')
    end

    context 'delete service plan label via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service plan label')
    end

    shared_examples 'common delete service plan label with prefix' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_plans/service_plan1/metadata/labels/label1?prefix=bogus.com')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service plan label with prefix via http' do
      it_behaves_like('common delete service plan label with prefix')
    end

    context 'delete service plan label with prefix via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service plan label with prefix')
    end

    shared_examples 'common delete service plan visibility' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_plan_visibilities/service_plan_visibility1/serviceplan1/organization1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service plan visibility via http' do
      it_behaves_like('common delete service plan visibility')
    end

    context 'delete service plan visibility via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service plan visibility')
    end

    shared_examples 'common delete service provider' do
      it 'returns failure code due to disconnection' do
        response = delete('/service_providers/service_provider1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete service provider via http' do
      it_behaves_like('common delete service provider')
    end

    context 'delete service provider via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete service provider')
    end

    shared_examples 'common delete shared service instance' do
      it 'returns failure code due to disconnection' do
        response = delete('/shared_service_instances/service_instance1/space1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete shared service instance via http' do
      it_behaves_like('common delete shared service instance')
    end

    context 'delete shared service instance via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete shared service instance')
    end

    shared_examples 'common delete space' do
      it 'returns failure code due to disconnection' do
        response = delete('/spaces/space1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
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
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete space recursive via http' do
      it_behaves_like('common delete space recursive')
    end

    context 'delete space recursive via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete space recursive')
    end

    shared_examples 'common delete space annotation' do
      it 'returns failure code due to disconnection' do
        response = delete('/spaces/space1/metadata/annotations/annotation1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete space annotation via http' do
      it_behaves_like('common delete space annotation')
    end

    context 'delete space annotation via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete space annotation')
    end

    shared_examples 'common delete space isolation segment' do
      it 'returns failure code due to disconnection' do
        response = delete('/spaces/space1/isolation_segment')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete space isolation segment via http' do
      it_behaves_like('common delete space isolation segment')
    end

    context 'delete space isolation segment via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete space isolation segment')
    end

    shared_examples 'common delete space label' do
      it 'returns failure code due to disconnection' do
        response = delete('/spaces/space1/metadata/labels/label1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete space label via http' do
      it_behaves_like('common delete space label')
    end

    context 'delete space label via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete space label')
    end

    shared_examples 'common delete space label with prefix' do
      it 'returns failure code due to disconnection' do
        response = delete('/spaces/space1/metadata/labels/label1?prefix=bogus.com')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete space label with prefix via http' do
      it_behaves_like('common delete space label with prefix')
    end

    context 'delete space label with prefix via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete space label with prefix')
    end

    shared_examples 'common delete space unmapped routes' do
      it 'returns failure code due to disconnection' do
        response = delete('/spaces/space1/unmapped_routes')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete space unmapped routes via http' do
      it_behaves_like('common delete space unmapped routes')
    end

    context 'delete space unmapped routes via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete space unmapped routes')
    end

    shared_examples 'common delete space quota definition' do
      it 'returns failure code due to disconnection' do
        response = delete('/space_quota_definitions/space_quota1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
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
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
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
        response = delete('/spaces/space1/role1/auditors/user1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete space role via http' do
      it_behaves_like('common delete space role')
    end

    context 'delete space role via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete space role')
    end

    shared_examples 'common delete stack' do
      it 'returns failure code due to disconnection' do
        response = delete('/stacks/stack1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete stack via http' do
      it_behaves_like('common delete stack')
    end

    context 'delete stack via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete stack')
    end

    shared_examples 'common delete stack annotation' do
      it 'returns failure code due to disconnection' do
        response = delete('/stacks/stack1/metadata/annotations/annotation1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete stack annotation via http' do
      it_behaves_like('common delete stack annotation')
    end

    context 'delete stack annotation via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete stack annotation')
    end

    shared_examples 'common delete stack label' do
      it 'returns failure code due to disconnection' do
        response = delete('/stacks/stack1/metadata/labels/label1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete stack label via http' do
      it_behaves_like('common delete stack label')
    end

    context 'delete stack label via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete stack label')
    end

    shared_examples 'common delete stack label with prefix' do
      it 'returns failure code due to disconnection' do
        response = delete('/stacks/stack1/metadata/labels/label1?prefix=bogus.com')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete stack label with prefix via http' do
      it_behaves_like('common delete stack label with prefix')
    end

    context 'delete stack label with prefix via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete stack label with prefix')
    end

    shared_examples 'common delete staging security group space' do
      it 'returns failure code due to disconnection' do
        response = delete('/staging_security_groups/security_group1/space1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete staging security group space via http' do
      it_behaves_like('common delete staging security group space')
    end

    context 'delete staging security group via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete staging security group space')
    end

    shared_examples 'common delete task annotation' do
      it 'returns failure code due to disconnection' do
        response = delete('/tasks/task1/metadata/annotations/annotation1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete task annotation via http' do
      it_behaves_like('common delete task annotation')
    end

    context 'delete task annotation via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete task annotation')
    end

    shared_examples 'common delete task label' do
      it 'returns failure code due to disconnection' do
        response = delete('/tasks/task1/metadata/labels/label1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete task label via http' do
      it_behaves_like('common delete task label')
    end

    context 'delete task label via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete task label')
    end

    shared_examples 'common delete task label with prefix' do
      it 'returns failure code due to disconnection' do
        response = delete('/tasks/task1/metadata/labels/label1?prefix=bogus.com')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete task label with prefix via http' do
      it_behaves_like('common delete task label with prefix')
    end

    context 'delete task label with prefix via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete task label with prefix')
    end

    shared_examples 'common delete user' do
      it 'returns failure code due to disconnection' do
        response = delete('/users/user1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete user via http' do
      it_behaves_like('common delete user')
    end

    context 'delete user via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete user')
    end

    shared_examples 'common delete user annotation' do
      it 'returns failure code due to disconnection' do
        response = delete('/users/user1/metadata/annotations/annotation1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete user annotation via http' do
      it_behaves_like('common delete user annotation')
    end

    context 'delete user annotation via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete user annotation')
    end

    shared_examples 'common delete user label' do
      it 'returns failure code due to disconnection' do
        response = delete('/users/user1/metadata/labels/label1')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete user label via http' do
      it_behaves_like('common delete user label')
    end

    context 'delete user label via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete user label')
    end

    shared_examples 'common delete user label with prefix' do
      it 'returns failure code due to disconnection' do
        response = delete('/users/user1/metadata/labels/label1?prefix=bogus.com')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete user label with prefix via http' do
      it_behaves_like('common delete user label with prefix')
    end

    context 'delete user label with prefix via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete user label with prefix')
    end

    shared_examples 'common delete user tokens' do
      it 'returns failure code due to disconnection' do
        response = delete('/users/user1/tokens')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'delete user tokens via http' do
      it_behaves_like('common delete user tokens')
    end

    context 'delete user tokens via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common delete user tokens')
    end

    shared_examples 'common manage application' do
      it 'returns failure code due to disconnection' do
        response = put('/applications/application1', '{"state":"STARTED"}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'manage application via http' do
      it_behaves_like('common manage application')
    end

    context 'manage application via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common manage application')
    end

    shared_examples 'common manage buildpack' do
      it 'returns failure code due to disconnection' do
        response = put('/buildpacks/buildpack1', '{"enabled":true}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'manage buildpack via http' do
      it_behaves_like('common manage buildpack')
    end

    context 'manage buildpack via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common manage buildpack')
    end

    shared_examples 'common manage feature flag' do
      it 'returns failure code due to disconnection' do
        response = put('/feature_flags/feature_flag1', '{"enabled":true}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'manage feature flag via http' do
      it_behaves_like('common manage feature flag')
    end

    context 'manage feature flag via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common manage feature flag')
    end

    shared_examples 'common manage identity provider status' do
      it 'returns failure code due to disconnection' do
        response = put('/identity_providers/identity_provider1/status', '{"requirePasswordChange":true}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'manage identity provider status via http' do
      it_behaves_like('common manage identity provider status')
    end

    context 'manage identity provider status via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common manage identity provider status')
    end

    shared_examples 'common manage isolation segment' do
      it 'returns failure code due to disconnection' do
        response = put('/isolation_segments/isolation_segment1', '{"name":"bogus"}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'manage isolation segment via http' do
      it_behaves_like('common manage isolation segment')
    end

    context 'manage isolation segment via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common manage isolation segment')
    end

    shared_examples 'common manage organization' do
      it 'returns failure code due to disconnection' do
        response = put('/organizations/organization1', '{"quota_definition_guid":"quota1"}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'manage organization via http' do
      it_behaves_like('common manage organization')
    end

    context 'manage organization via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common manage organization')
    end

    shared_examples 'common manage quota definition' do
      it 'returns failure code due to disconnection' do
        response = put('/quota_definitions/quota_definition1', '{"name":"bogus"}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'manage quota definition via http' do
      it_behaves_like('common manage quota definition')
    end

    context 'manage quota definition via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common manage quota definition')
    end

    shared_examples 'common manage security group' do
      it 'returns failure code due to disconnection' do
        response = put('/security_groups/security_group1', '{"name":"bogus"}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'manage security group via http' do
      it_behaves_like('common manage security group')
    end

    context 'manage security group via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common manage security group')
    end

    shared_examples 'common manage service broker' do
      it 'returns failure code due to disconnection' do
        response = put('/service_brokers/service_broker1', '{"name":"bogus"}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'manage service broker via http' do
      it_behaves_like('common manage service broker')
    end

    context 'manage service broker via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common manage service broker')
    end

    shared_examples 'common manage service instance' do
      it 'returns failure code due to disconnection' do
        response = put('/service_instances/service_instance1/true', '{"name":"bogus"}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'manage service instance via http' do
      it_behaves_like('common manage service instance')
    end

    context 'manage service instance via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common manage service instance')
    end

    shared_examples 'common manage service plan' do
      it 'returns failure code due to disconnection' do
        response = put('/service_plans/service_plan1', '{"public":true}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'manage service plan via http' do
      it_behaves_like('common manage organization')
    end

    context 'manage service plan via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common manage service plan')
    end

    shared_examples 'common manage space' do
      it 'returns failure code due to disconnection' do
        response = put('/spaces/space1', '{"name":"bogus"}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'manage space via http' do
      it_behaves_like('common manage space')
    end

    context 'manage space via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common manage space')
    end

    shared_examples 'common manage space quota definition' do
      it 'returns failure code due to disconnection' do
        response = put('/space_quota_definitions/space_quota_definition1', '{"name":"bogus"}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'manage space quota definition via http' do
      it_behaves_like('common manage space quota definition')
    end

    context 'manage space quota definition via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common manage space quota definition')
    end

    shared_examples 'common manage user' do
      it 'returns failure code due to disconnection' do
        response = put('/users/user1', '{"active":true}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'manage user via http' do
      it_behaves_like('common manage user')
    end

    context 'manage user via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common manage user')
    end

    shared_examples 'common manage user status' do
      it 'returns failure code due to disconnection' do
        response = put('/users/user1/status', '{"locked":false}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'manage user status via http' do
      it_behaves_like('common manage user status')
    end

    context 'manage user status via https' do
      let(:secured_client_connection) { true }

      it_behaves_like('common manage user status')
    end

    shared_examples 'common restage application' do
      it 'returns failure code due to disconnection' do
        response = post('/applications/application1/restage', '{}')
        expect(response.is_a?(Net::HTTPInternalServerError)).to be(true)
      end
    end

    context 'restage application via http' do
      it_behaves_like('common restage application')
    end

    context 'restage application via https' do
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
      expect(response.is_a?(Net::HTTPOK)).to be(true)

      body = response.body
      expect(body).to_not be_nil

      Yajl::Parser.parse(body)
    end

    def verify_view_model_items(path, connected)
      json = get_json(path)

      expect(json).to include('draw' => 0, 'recordsFiltered' => 0, 'recordsTotal' => 0)
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
      expect(response.is_a?(Net::HTTPNotFound)).to be(true)
    end

    shared_examples 'common all tabs succeed' do
      before do
        login_stub_admin
      end

      it '/application_instances_view_model succeeds' do
        verify_disconnected_view_model_items('/application_instances_view_model')
      end

      it '/application_instances_view_model/:guid/:instance_index returns not found' do
        verify_not_found('/application_instances_view_model/application1/0')
      end

      it '/applications_view_model succeeds' do
        verify_disconnected_view_model_items('/applications_view_model')
      end

      it '/applications_view_model/:guid returns not found' do
        verify_not_found('/applications_view_model/application1')
      end

      it '/approvals_view_model succeeds' do
        verify_disconnected_view_model_items('/approvals_view_model')
      end

      it '/approvals_view_model/:user_guid/:client_id/:scope returns not found' do
        verify_not_found('/approvals_view_model/user1/client1/scope1')
      end

      it '/buildpacks_view_model succeeds' do
        verify_disconnected_view_model_items('/buildpacks_view_model')
      end

      it '/buildpacks_view_model/:guid returns not found' do
        verify_not_found('/buildpacks_view_model/buildpack1')
      end

      it '/cells_view_model succeeds' do
        verify_disconnected_view_model_items('/cells_view_model')
      end

      it '/cells_view_model/:name returns not found' do
        verify_not_found('/cells_view_model/name')
      end

      it '/clients_view_model succeeds' do
        verify_disconnected_view_model_items('/clients_view_model')
      end

      it '/clients_view_model/:id returns not found' do
        verify_not_found('/clients_view_model/client1')
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

      it '/domains_view_model/:guid/:boolean returns not found' do
        verify_not_found('/domains_view_model/domain1/false')
      end

      it '/environment_groups_view_model succeeds' do
        verify_disconnected_view_model_items('/environment_groups_view_model')
      end

      it '/environment_groups_view_model/:name returns not found' do
        verify_not_found('/environment_groups_view_model/running')
      end

      it '/events_view_model succeeds' do
        verify_disconnected_view_model_items('/events_view_model')
      end

      it '/events_view_model/:guid returns not found' do
        verify_not_found('/events_view_model/event1')
      end

      it '/feature_flags_view_model succeeds' do
        verify_disconnected_view_model_items('/feature_flags_view_model')
      end

      it '/feature_flags_view_model/:name returns not found' do
        verify_not_found('/feature_flags_view_model/name')
      end

      it '/gateways_view_model succeeds' do
        verify_disconnected_view_model_items('/gateways_view_model')
      end

      it '/gateways_view_model/:name returns not found' do
        verify_not_found('/gateways_view_model/name')
      end

      it '/group_members_view_model succeeds' do
        verify_disconnected_view_model_items('/group_members_view_model')
      end

      it '/group_members_view_model/:guid/:guid returns not found' do
        verify_not_found('/group_members_view_model/group1/user1')
      end

      it '/groups_view_model succeeds' do
        verify_disconnected_view_model_items('/groups_view_model')
      end

      it '/groups_view_model/:guid returns not found' do
        verify_not_found('/groups_view_model/event1')
      end

      it '/health_managers_view_model succeeds' do
        verify_disconnected_view_model_items('/health_managers_view_model')
      end

      it '/health_managers_view_model/:name returns not found' do
        verify_not_found('/health_managers_view_model/name')
      end

      it '/identity_providers_view_model succeeds' do
        verify_disconnected_view_model_items('/identity_providers_view_model')
      end

      it '/identity_providers_view_model/:guid returns not found' do
        verify_not_found('/identity_providers_view_model/identity_provider1')
      end

      it '/identity_zones_view_model succeeds' do
        verify_disconnected_view_model_items('/identity_zones_view_model')
      end

      it '/identity_zones_view_model/:id returns not found' do
        verify_not_found('/identity_zones_view_model/identity_zone1')
      end

      it '/isolation_segments_view_model succeeds' do
        verify_disconnected_view_model_items('/isolation_segments_view_model')
      end

      it '/isolation_segments_view_model/:guid returns not found' do
        verify_not_found('/isolation_segments_view_model/isolation_segment1')
      end

      it '/logs_view_model succeeds' do
        verify_connected_view_model_empty_items('/logs_view_model')
      end

      it '/mfa_providers_view_model succeeds' do
        verify_disconnected_view_model_items('/mfa_providers_view_model')
      end

      it '/mfa_providers_view_model/:id returns not found' do
        verify_not_found('/mfa_providers_view_model/mfa_provider1')
      end

      it '/organizations_isolation_segments_view_model succeeds' do
        verify_disconnected_view_model_items('/organizations_isolation_segments_view_model')
      end

      it '/organizations_isolation_segments_view_model/:guid/:guid returns not found' do
        verify_not_found('/organizations_isolation_segments_view_model/organization1/isolation_segment1')
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

      it '/organization_roles_view_model/:guid/:guid/:role/:guid returns not found' do
        verify_not_found('/organization_roles_view_model/organization1/role1/auditors/user1')
      end

      it '/quotas_view_model succeeds' do
        verify_disconnected_view_model_items('/quotas_view_model')
      end

      it '/quotas_view_model/:guid returns not found' do
        verify_not_found('/quotas_view_model/quota1')
      end

      it '/revocable_tokens_view_model succeeds' do
        verify_disconnected_view_model_items('/revocable_tokens_view_model')
      end

      it '/revocable_tokens_view_model/:token_id returns not found' do
        verify_not_found('/revocable_tokens_view_model/revocable_token1')
      end

      it '/routers_view_model succeeds' do
        verify_disconnected_view_model_items('/routers_view_model')
      end

      it '/routers_view_model/:name returns not found' do
        verify_not_found('/routers_view_model/name')
      end

      it '/route_bindings_view_model succeeds' do
        verify_disconnected_view_model_items('/route_bindings_view_model')
      end

      it '/route_bindings_view_model/:guid returns not found' do
        verify_not_found('/route_bindings_view_model/route1')
      end

      it '/route_mappings_view_model succeeds' do
        verify_disconnected_view_model_items('/route_mappings_view_model')
      end

      it '/route_mappings_view_model/:guid/:guid returns not found' do
        verify_not_found('/route_mappings_view_model/route_mapping1/route1')
      end

      it '/routes_view_model succeeds' do
        verify_disconnected_view_model_items('/routes_view_model')
      end

      it '/routes_view_model/:guid returns not found' do
        verify_not_found('/routes_view_model/route1')
      end

      it '/security_groups_spaces_view_model succeeds' do
        verify_disconnected_view_model_items('/security_groups_spaces_view_model')
      end

      it '/security_groups_spaces_view_model/:guid/:guid returns not found' do
        verify_not_found('/security_groups_view_model/security_group1/space1')
      end

      it '/security_groups_view_model succeeds' do
        verify_disconnected_view_model_items('/security_groups_view_model')
      end

      it '/security_groups_view_model/:guid returns not found' do
        verify_not_found('/security_groups_view_model/security_group1')
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

      it '/service_instances_view_model/:guid/:boolean returns not found' do
        verify_not_found('/service_instances_view_model/service_instance1/true')
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

      it '/service_plan_visibilities_view_model/:guid/:guid/:guid returns not found' do
        verify_not_found('/service_plan_visibilities_view_model/service_plan_visibility1/service_plan1/organization1')
      end

      it '/service_providers_view_model succeeds' do
        verify_disconnected_view_model_items('/service_providers_view_model')
      end

      it '/service_providers_view_model/:id returns not found' do
        verify_not_found('/service_providers_view_model/service_provider1')
      end

      it '/services_view_model succeeds' do
        verify_disconnected_view_model_items('/services_view_model')
      end

      it '/services_view_model/:guid returns not found' do
        verify_not_found('/services_view_model/service1')
      end

      it '/shared_service_instances_view_model succeeds' do
        verify_disconnected_view_model_items('/shared_service_instances_view_model')
      end

      it '/shared_service_instances_view_model/:guid/:guid returns not found' do
        verify_not_found('/shared_service_instances_view_model/service_instance1/space1')
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

      it '/space_roles_view_model/:guid/:guid/:role/:guid returns not found' do
        verify_not_found('/space_roles_view_model/space1/role1/auditors/user1')
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

      it '/staging_security_groups_spaces_view_model succeeds' do
        verify_disconnected_view_model_items('/staging_security_groups_spaces_view_model')
      end

      it '/staging_security_groups_spaces_view_model/:guid/:guid returns not found' do
        verify_not_found('/staging_security_groups_view_model/security_group1/space1')
      end

      it '/tasks_view_model succeeds' do
        verify_disconnected_view_model_items('/tasks_view_model')
      end

      it '/tasks_view_model/:guid returns not found' do
        verify_not_found('/tasks_view_model/task1')
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
      expect(response.is_a?(Net::HTTPSeeOther)).to be(true)

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

      it '/application_instances_view_model/:guid/:instance_index redirects as expected' do
        get_redirects_as_expected('/application_instances_view_model/application1/0')
      end

      it '/applications_view_model redirects as expected' do
        get_redirects_as_expected('/applications_view_model')
      end

      it '/applications_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/applications_view_model/application1')
      end

      it '/approvals_view_model redirects as expected' do
        get_redirects_as_expected('/approvals_view_model')
      end

      it '/approvals_view_model/:user_guid/:client_id/:scope redirects as expected' do
        get_redirects_as_expected('/approvals_view_model/user1/client1/scope1')
      end

      it '/buildpacks_view_model redirects as expected' do
        get_redirects_as_expected('/buildpacks_view_model')
      end

      it '/buildpacks_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/buildpacks_view_model/buildpack1')
      end

      it '/cells_view_model redirects as expected' do
        get_redirects_as_expected('/cells_view_model')
      end

      it '/cells_view_model/:name redirects as expected' do
        get_redirects_as_expected('/cells_view_model/name')
      end

      it '/clients_view_model redirects as expected' do
        get_redirects_as_expected('/clients_view_model')
      end

      it '/clients_view_model/:id redirects as expected' do
        get_redirects_as_expected('/clients_view_model/client1')
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

      it '/domains_view_model/:guid/:boolean redirects as expected' do
        get_redirects_as_expected('/domains_view_model/domain1/false')
      end

      it '/download redirects as expected' do
        get_redirects_as_expected('/download')
      end

      it '/environment_groups_view_model redirects as expected' do
        get_redirects_as_expected('/environment_groups_view_model')
      end

      it '/environment_groups_view_model/:name redirects as expected' do
        get_redirects_as_expected('/environment_groups_view_model/running')
      end

      it '/events_view_model redirects as expected' do
        get_redirects_as_expected('/events_view_model')
      end

      it '/events_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/events_view_model/event1')
      end

      it '/feature_flags_view_model redirects as expected' do
        get_redirects_as_expected('/feature_flags_view_model')
      end

      it '/feature_flags_view_model/:name redirects as expected' do
        get_redirects_as_expected('/feature_flags_view_model/name')
      end

      it '/gateways_view_model redirects as expected' do
        get_redirects_as_expected('/gateways_view_model')
      end

      it '/gateways_view_model/:name redirects as expected' do
        get_redirects_as_expected('/gateways_view_model/name')
      end

      it '/group_members_view_model redirects as expected' do
        get_redirects_as_expected('/group_members_view_model')
      end

      it '/group_members_view_model/:guid/:guid redirects as expected' do
        get_redirects_as_expected('/group_members_view_model/group1/user1')
      end

      it '/groups_view_model redirects as expected' do
        get_redirects_as_expected('/groups_view_model')
      end

      it '/groups_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/groups_view_model/group1')
      end

      it '/health_managers_view_model redirects as expected' do
        get_redirects_as_expected('/health_managers_view_model')
      end

      it '/health_managers_view_model/:name redirects as expected' do
        get_redirects_as_expected('/health_managers_view_model/name')
      end

      it '/identity_providers_view_model redirects as expected' do
        get_redirects_as_expected('/identity_providers_view_model')
      end

      it '/identity_providers_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/identity_providers_view_model/identity_provider1')
      end

      it '/identity_zones_view_model redirects as expected' do
        get_redirects_as_expected('/identity_zones_view_model')
      end

      it '/identity_zones_view_model/:id redirects as expected' do
        get_redirects_as_expected('/identity_zones_view_model/identity_zone1')
      end

      it '/isolation_segments_view_model redirects as expected' do
        get_redirects_as_expected('/isolation_segments_view_model')
      end

      it '/isolation_segments_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/isolation_segments_view_model/isolation_segment1')
      end

      it '/log redirects as expected' do
        get_redirects_as_expected('/log')
      end

      it '/logs_view_model redirects as expected' do
        get_redirects_as_expected('/logs_view_model')
      end

      it '/mfa_providers_view_model redirects as expected' do
        get_redirects_as_expected('/mfa_providers_view_model')
      end

      it '/mfa_providers_view_model/:id redirects as expected' do
        get_redirects_as_expected('/mfa_providers_view_model/mfa_provider1')
      end

      it '/organization_roles_view_model redirects as expected' do
        get_redirects_as_expected('/organization_roles_view_model')
      end

      it '/organization_roles_view_model/:guid/:guid/:role/:guid redirects as expected' do
        get_redirects_as_expected('/organization_roles_view_model/organization1/role1/auditors/user1')
      end

      it '/organizations_isolation_segments_view_model redirects as expected' do
        get_redirects_as_expected('/organizations_isolation_segments_view_model')
      end

      it '/organizations_isolation_segments_view_model/:guid/:guid redirects as expected' do
        get_redirects_as_expected('/organizations_isolation_segments_view_model/organization1/isolation_segment1')
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

      it '/revocable_tokens_view_model redirects as expected' do
        get_redirects_as_expected('/revocable_tokens_view_model')
      end

      it '/revocable_tokens_view_model/:token_id redirects as expected' do
        get_redirects_as_expected('/revocable_tokens_view_model/revocable_token1')
      end

      it '/routers_view_model redirects as expected' do
        get_redirects_as_expected('/routers_view_model')
      end

      it '/routers_view_model/:name redirects as expected' do
        get_redirects_as_expected('/routers_view_model/name')
      end

      it '/route_bindings_view_model redirects as expected' do
        get_redirects_as_expected('/route_bindings_view_model')
      end

      it '/route_bindings_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/route_bindings_view_model/route_binding1')
      end

      it '/route_mappings_view_model redirects as expected' do
        get_redirects_as_expected('/route_mappings_view_model')
      end

      it '/route_mappings_view_model/:guid/:guid redirects as expected' do
        get_redirects_as_expected('/route_mappings_view_model/route_mapping1/route1')
      end

      it '/routes_view_model redirects as expected' do
        get_redirects_as_expected('/routes_view_model')
      end

      it '/routes_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/routes_view_model/route1')
      end

      it '/security_groups_spaces_view_model redirects as expected' do
        get_redirects_as_expected('/security_groups_spaces_view_model')
      end

      it '/security_groups_spaces_view_model/:guid/:guid redirects as expected' do
        get_redirects_as_expected('/security_groups_spaces_view_model/security_group1/space1')
      end

      it '/security_groups_view_model redirects as expected' do
        get_redirects_as_expected('/security_groups_view_model')
      end

      it '/security_groups_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/security_groups_view_model/security_group1')
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

      it '/service_instances_view_model/:guid/:boolean redirects as expected' do
        get_redirects_as_expected('/service_instances_view_model/service_instance1/true')
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

      it '/service_plan_visibilities_view_model/:guid/:guid/:guid redirects as expected' do
        get_redirects_as_expected('/service_plan_visibilities_view_model/service_plan_visibilities1/service_plan1/organization1')
      end

      it '/service_providers_view_model redirects as expected' do
        get_redirects_as_expected('/service_providers_view_model')
      end

      it '/service_providers_view_model/:id redirects as expected' do
        get_redirects_as_expected('/service_providers_view_model/service_provider1')
      end

      it '/services_view_model redirects as expected' do
        get_redirects_as_expected('/services_view_model')
      end

      it '/services_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/services_view_model/service1')
      end

      it '/shared_service_instances_view_model redirects as expected' do
        get_redirects_as_expected('/shared_service_instances_view_model')
      end

      it '/shared_service_instances_view_model/:guid/:guid redirects as expected' do
        get_redirects_as_expected('/shared_service_instances_view_model/service_instance1/space1')
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

      it '/space_roles_view_model/:guid/:guid/:role/:guid redirects as expected' do
        get_redirects_as_expected('/space_roles_view_model/space1/role1/auditors/user1')
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

      it '/staging_security_groups_spaces_view_model redirects as expected' do
        get_redirects_as_expected('/staging_security_groups_spaces_view_model')
      end

      it '/staging_security_groups_spaces_view_model/:guid/:guid redirects as expected' do
        get_redirects_as_expected('/staging_security_groups_spaces_view_model/security_group1/space1')
      end

      it '/tasks_view_model redirects as expected' do
        get_redirects_as_expected('/tasks_view_model')
      end

      it '/tasks_view_model/:guid redirects as expected' do
        get_redirects_as_expected('/tasks_view_model/stack1')
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

      it 'deletes /applications/:guid/metadata/annotations/:annotation redirects as expected' do
        delete_redirects_as_expected('/applications/application1/metadata/annotations/annotation1')
      end

      it 'deletes /applications/:guid/environment_variables/:environment_variable redirects as expected' do
        delete_redirects_as_expected('/applications/application1/environment_variables/environment_variable1')
      end

      it 'deletes /applications/:guid/:index redirects as expected' do
        delete_redirects_as_expected('/applications/application1/index0')
      end

      it 'deletes /applications/:guid/metadata/labels/:label redirects as expected' do
        delete_redirects_as_expected('/applications/application1/metadata/labels/label1')
      end

      it 'deletes /applications/:guid/metadata/labels/:label?prefix=:prefix redirects as expected' do
        delete_redirects_as_expected('/applications/application1/metadata/labels/label1?prefix=bogus.com')
      end

      it 'deletes /buildpacks/:guid redirects as expected' do
        delete_redirects_as_expected('/buildpacks/buildpack1')
      end

      it 'deletes /buildpacks/:guid/metadata/annotations/:annotation redirects as expected' do
        delete_redirects_as_expected('/buildpacks/buildpack1/metadata/annotations/annotation1')
      end

      it 'deletes /buildpacks/:guid/metadata/labels/:label redirects as expected' do
        delete_redirects_as_expected('/buildpacks/buildpack1/metadata/labels/label1')
      end

      it 'deletes /buildpacks/:guid/metadata/labels/:label?prefix=:prefix redirects as expected' do
        delete_redirects_as_expected('/buildpacks/buildpack1/metadata/labels/label1?prefix=bogus.com')
      end

      it 'deletes /clients/:id redirects as expected' do
        delete_redirects_as_expected('/clients/client1')
      end

      it 'deletes /clients/:id/tokens redirects as expected' do
        delete_redirects_as_expected('/clients/client1/tokens')
      end

      it 'deletes /components/?uri redirects as expected' do
        delete_redirects_as_expected('/components?uri=uri1')
      end

      it 'deletes /domains/:guid/:boolean redirects as expected' do
        delete_redirects_as_expected('/domains/domain1/false')
      end

      it 'deletes /domains/:guid/:boolean?recursive=true redirects as expected' do
        delete_redirects_as_expected('/domains/domain1/false?recursive=true')
      end

      it 'deletes /domains/:guid/metadata/annotations/:annotation redirects as expected' do
        delete_redirects_as_expected('/domains/domain1/metadata/annotations/annotation1')
      end

      it 'deletes /domains/:guid/metadata/labels/:label redirects as expected' do
        delete_redirects_as_expected('/domains/domain1/metadata/labels/label1')
      end

      it 'deletes /domains/:guid/metadata/labels/:label?prefix=:prefix redirects as expected' do
        delete_redirects_as_expected('/domains/domain1/metadata/labels/label1?prefix=bogus.com')
      end

      it 'deletes /domains/:guid/:boolean/:guid redirects as expected' do
        delete_redirects_as_expected('/domains/domain1/false/organization1')
      end

      it 'deletes /doppler_components/?uri redirects as expected' do
        delete_redirects_as_expected('/doppler_components?uri=uri1')
      end

      it 'deletes /groups/:guid redirects as expected' do
        delete_redirects_as_expected('/groups/group1')
      end

      it 'deletes /groups/:guid/:guid redirects as expected' do
        delete_redirects_as_expected('/groups/group1/member1')
      end

      it 'deletes /identity_providers/:guid redirects as expected' do
        delete_redirects_as_expected('/identity_providers/identity_provider1')
      end

      it 'deletes /identity_zones/:guid redirects as expected' do
        delete_redirects_as_expected('/identity_zones/identity_zone1')
      end

      it 'deletes /isolation_segments/:guid redirects as expected' do
        delete_redirects_as_expected('/isolation_segments/isolation_segment1')
      end

      it 'deletes /isolation_segments/:guid/metadata/annotations/:annotation redirects as expected' do
        delete_redirects_as_expected('/isolation_segments/isolation_segment1/metadata/annotations/annotation1')
      end

      it 'deletes /isolation_segments/:guid/metadata/labels/:label redirects as expected' do
        delete_redirects_as_expected('/isolation_segments/isolation_segment1/metadata/labels/label1')
      end

      it 'deletes /isolation_segments/:guid/metadata/labels/:label?prefix=:prefix redirects as expected' do
        delete_redirects_as_expected('/isolation_segments/isolation_segment1/metadata/labels/label1?prefix=bogus.com')
      end

      it 'deletes /mfa_providers/:guid redirects as expected' do
        delete_redirects_as_expected('/mfa_providers/mfa_provider1')
      end

      it 'deletes /organizations/:guid redirects as expected' do
        delete_redirects_as_expected('/organizations/organization1')
      end

      it 'deletes /organizations/:guid?recursive=true redirects as expected' do
        delete_redirects_as_expected('/organizations/organization1?recursive=true')
      end

      it 'deletes /organizations/:guid/metadata/annotations/:annotation redirects as expected' do
        delete_redirects_as_expected('/organizations/organization1/metadata/annotations/annotation1')
      end

      it 'deletes /organizations/:guid/default_isolation_segment redirects as expected' do
        delete_redirects_as_expected('/organizations/organization1/default_isolation_segment')
      end

      it 'deletes /organizations/:guid/metadata/labels/:label redirects as expected' do
        delete_redirects_as_expected('/organizations/organization1/metadata/labels/label1')
      end

      it 'deletes /organizations/:guid/metadata/labels/:label?prefix=:prefix redirects as expected' do
        delete_redirects_as_expected('/organizations/organization1/metadata/labels/label1?prefix=bogus.com')
      end

      it 'deletes /organizations/:guid/:guid redirects as expected' do
        delete_redirects_as_expected('/organizations/organization1/isolation_segment1')
      end

      it 'deletes /organizations/:guid/:guid/:role/:guid redirects as expected' do
        delete_redirects_as_expected('/organizations/organization1/role1/auditors/user1')
      end

      it 'deletes /quota_definitions/:guid redirects as expected' do
        delete_redirects_as_expected('/quota_definitions/quota1')
      end

      it 'deletes /revocable_tokens/:token_id redirects as expected' do
        delete_redirects_as_expected('/revocable_tokens/revocable_token1')
      end

      it 'deletes /route_bindings/:guid/:guid/:boolean redirects as expected' do
        delete_redirects_as_expected('/route_bindings/service_instance1/route1/true')
      end

      it 'deletes /route_mappings/:guid/:guid redirects as expected' do
        delete_redirects_as_expected('/route_mappings/route_mapping1/route1')
      end

      it 'deletes /routes/:guid redirects as expected' do
        delete_redirects_as_expected('/routes/route1')
      end

      it 'deletes /routes/:guid?recursive=true redirects as expected' do
        delete_redirects_as_expected('/routes/route1?recursive=true')
      end

      it 'deletes /routes/:guid/metadata/annotations/:annotation redirects as expected' do
        delete_redirects_as_expected('/routes/route1/metadata/annotations/annotation1')
      end

      it 'deletes /routes/:guid/metadata/labels/:label redirects as expected' do
        delete_redirects_as_expected('/routes/route1/metadata/labels/label1')
      end

      it 'deletes /routes/:guid/metadata/labels/:label?prefix=:prefix redirects as expected' do
        delete_redirects_as_expected('/routes/route1/metadata/labels/label1?prefix=bogus.com')
      end

      it 'deletes /security_groups/:guid redirects as expected' do
        delete_redirects_as_expected('/security_groups/security_group1')
      end

      it 'deletes /security_groups/:guid/:guid redirects as expected' do
        delete_redirects_as_expected('/security_groups/security_group1/space1')
      end

      it 'deletes /service_bindings/:guid redirects as expected' do
        delete_redirects_as_expected('/service_bindings/service_binding1')
      end

      it 'deletes /service_bindings/:guid/metadata/annotations/:annotation redirects as expected' do
        delete_redirects_as_expected('/service_bindings/service_binding1/metadata/annotations/annotation1')
      end

      it 'deletes /service_bindings/:guid/metadata/labels/:label redirects as expected' do
        delete_redirects_as_expected('/service_bindings/service_binding1/metadata/labels/label1')
      end

      it 'deletes /service_bindings/:guid/metadata/labels/:label?prefix=:prefix redirects as expected' do
        delete_redirects_as_expected('/service_bindings/service_binding1/metadata/labels/label1?prefix=bogus.com')
      end

      it 'deletes /service_brokers/:guid redirects as expected' do
        delete_redirects_as_expected('/service_brokers/service_broker1')
      end

      it 'deletes /service_brokers/:guid/metadata/annotations/:annotation redirects as expected' do
        delete_redirects_as_expected('/service_brokers/service_broker1/metadata/annotations/annotation1')
      end

      it 'deletes /service_brokers/:guid/metadata/labels/:label redirects as expected' do
        delete_redirects_as_expected('/service_brokers/service_broker1/metadata/labels/label1')
      end

      it 'deletes /service_brokers/:guid/metadata/labels/:label?prefix=:prefix redirects as expected' do
        delete_redirects_as_expected('/service_brokers/service_broker1/metadata/labels/label1?prefix=bogus.com')
      end

      it 'deletes /service_instances/:guid/:boolean redirects as expected' do
        delete_redirects_as_expected('/service_instances/service_instance1/true')
      end

      it 'deletes /service_instances/:guid/:boolean?recursive=true redirects as expected' do
        delete_redirects_as_expected('/service_instances/service_instance1/true?recursive=true')
      end

      it 'deletes /service_instances/:guid/:boolean?recursive=true&purge=true redirects as expected' do
        delete_redirects_as_expected('/service_instances/service_instance1/true?recursive=true&purge=true')
      end

      it 'deletes /service_instances/:guid/metadata/annotations/:annotation redirects as expected' do
        delete_redirects_as_expected('/service_instances/service_instance1/metadata/annotations/annotation1')
      end

      it 'deletes /service_instances/:guid/metadata/labels/:label redirects as expected' do
        delete_redirects_as_expected('/service_instances/service_instance1/metadata/labels/label1')
      end

      it 'deletes /service_instances/:guid/metadata/labels/:label?prefix=:prefix redirects as expected' do
        delete_redirects_as_expected('/service_instances/service_instance1/metadata/labels/label1?prefix=bogus.com')
      end

      it 'deletes /service_keys/:guid redirects as expected' do
        delete_redirects_as_expected('/service_keys/service_key1')
      end

      it 'deletes /service_keys/:guid/metadata/annotations/:annotation redirects as expected' do
        delete_redirects_as_expected('/service_keys/service_key1/metadata/annotations/annotation1')
      end

      it 'deletes /service_keys/:guid/metadata/labels/:label redirects as expected' do
        delete_redirects_as_expected('/service_keys/service_key1/metadata/labels/label1')
      end

      it 'deletes /service_keys/:guid/metadata/labels/:label?prefix=:prefix redirects as expected' do
        delete_redirects_as_expected('/service_keys/service_key1/metadata/labels/label1?prefix=bogus.com')
      end

      it 'deletes /service_plans/:guid redirects as expected' do
        delete_redirects_as_expected('/service_plans/service_plan1')
      end

      it 'deletes /service_plans/:guid/metadata/annotations/:annotation redirects as expected' do
        delete_redirects_as_expected('/service_plans/service_plan1/metadata/annotations/annotation1')
      end

      it 'deletes /service_plans/:guid/metadata/labels/:label redirects as expected' do
        delete_redirects_as_expected('/service_plans/service_plan1/metadata/labels/label1')
      end

      it 'deletes /service_plans/:guid/metadata/labels/:label?prefix=:prefix redirects as expected' do
        delete_redirects_as_expected('/service_plans/service_plan1/metadata/labels/label1?prefix=bogus.com')
      end

      it 'deletes /service_plan_visibilities/:guid/:guid/:guid redirects as expected' do
        delete_redirects_as_expected('/service_plan_visibilities/service_plan_visibility1/service_plan1/organization1')
      end

      it 'deletes /service_providers/:id redirects as expected' do
        delete_redirects_as_expected('/service_providers/service_provider1')
      end

      it 'deletes /services/:guid redirects as expected' do
        delete_redirects_as_expected('/services/service1')
      end

      it 'deletes /services/:guid?purge=true redirects as expected' do
        delete_redirects_as_expected('/services/service1?purge=true')
      end

      it 'deletes /services/:guid/metadata/annotations/:annotation redirects as expected' do
        delete_redirects_as_expected('/services/service1/metadata/annotations/annotation1')
      end

      it 'deletes /services/:guid/metadata/labels/:label redirects as expected' do
        delete_redirects_as_expected('/services/service1/metadata/labels/label1')
      end

      it 'deletes /services/:guid/metadata/labels/:label?prefix=:prefix redirects as expected' do
        delete_redirects_as_expected('/services/service1/metadata/labels/label1?prefix=bogus.com')
      end

      it 'deletes /shared_service_instances/:guid/:guid redirects as expected' do
        delete_redirects_as_expected('/shared_service_instances/service_instance1/space1')
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

      it 'deletes /spaces/:guid/metadata/annotations/:annotation redirects as expected' do
        delete_redirects_as_expected('/spaces/space1/metadata/annotations/annotation1')
      end

      it 'deletes /spaces/:guid/isolation_segment redirects as expected' do
        delete_redirects_as_expected('/spaces/space1/isolation_segment')
      end

      it 'deletes /spaces/:guid/metadata/labels/:label redirects as expected' do
        delete_redirects_as_expected('/spaces/space1/metadata/labels/label1')
      end

      it 'deletes /spaces/:guid/metadata/labels/:label?prefix=:prefix redirects as expected' do
        delete_redirects_as_expected('/spaces/space1/metadata/labels/label1?prefix=bogus.com')
      end

      it 'deletes /spaces/:guid/unmapped_routes redirects as expected' do
        delete_redirects_as_expected('/spaces/space1/unmapped_routes')
      end

      it 'deletes /spaces/:guid/:guid/:role/:guid redirects as expected' do
        delete_redirects_as_expected('/spaces/space1/role1/auditors/user1')
      end

      it 'deletes /stacks/:guid redirects as expected' do
        delete_redirects_as_expected('/stacks/stack1')
      end

      it 'deletes /stacks/:guid/metadata/annotations/:annotation redirects as expected' do
        delete_redirects_as_expected('/stacks/stack1/metadata/annotations/annotation1')
      end

      it 'deletes /stacks/:guid/metadata/labels/:label redirects as expected' do
        delete_redirects_as_expected('/stacks/stack1/metadata/labels/label1')
      end

      it 'deletes /stacks/:guid/metadata/labels/:label?prefix=:prefix redirects as expected' do
        delete_redirects_as_expected('/stacks/stack1/metadata/labels/label1?prefix=bogus.com')
      end

      it 'deletes /staging_security_groups/:guid/:guid redirects as expected' do
        delete_redirects_as_expected('/staging_security_groups/security_group1/space1')
      end

      it 'deletes /tasks/:guid/cancel redirects as expected' do
        delete_redirects_as_expected('/tasks/task1/cancel')
      end

      it 'deletes /tasks/:guid/metadata/annotations/:annotation redirects as expected' do
        delete_redirects_as_expected('/tasks/task1/metadata/annotations/annotation1')
      end

      it 'deletes /tasks/:guid/metadata/labels/:label redirects as expected' do
        delete_redirects_as_expected('/tasks/task1/metadata/labels/label1')
      end

      it 'deletes /tasks/:guid/metadata/labels/:label?prefix=:prefix redirects as expected' do
        delete_redirects_as_expected('/tasks/task1/metadata/labels/label1?prefix=bogus.com')
      end

      it 'deletes /users/:guid redirects as expected' do
        delete_redirects_as_expected('/users/user1')
      end

      it 'deletes /users/:guid/metadata/annotations/:annotation redirects as expected' do
        delete_redirects_as_expected('/users/user1/metadata/annotations/annotation1')
      end

      it 'deletes /users/:guid/metadata/labels/:label redirects as expected' do
        delete_redirects_as_expected('/users/user1/metadata/labels/label1')
      end

      it 'deletes /users/:guid/metadata/labels/:label?prefix=:prefix redirects as expected' do
        delete_redirects_as_expected('/users/user1/metadata/labels/label1?prefix=bogus.com')
      end

      it 'deletes /users/:guid/tokens redirects as expected' do
        delete_redirects_as_expected('/users/user1/tokens')
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

      it 'posts /approvals_view_model redirects as expected' do
        post_redirects_as_expected('/approvals_view_model')
      end

      it 'posts /buildpacks_view_model redirects as expected' do
        post_redirects_as_expected('/buildpacks_view_model')
      end

      it 'posts /cells_view_model redirects as expected' do
        post_redirects_as_expected('/cells_view_model')
      end

      it 'posts /cloud_controllers_view_model redirects as expected' do
        post_redirects_as_expected('/cloud_controllers_view_model')
      end

      it 'posts /components_view_model redirects as expected' do
        post_redirects_as_expected('/components_view_model')
      end

      it 'posts /deas_view_model redirects as expected' do
        post_redirects_as_expected('/deas_view_model')
      end

      it 'posts /domains_view_model redirects as expected' do
        post_redirects_as_expected('/domains_view_model')
      end

      it 'posts /environment_groups_view_model redirects as expected' do
        post_redirects_as_expected('/environment_groups_view_model')
      end

      it 'posts /events_view_model redirects as expected' do
        post_redirects_as_expected('/events_view_model')
      end

      it 'posts /feature_flags_view_model redirects as expected' do
        post_redirects_as_expected('/feature_flags_view_model')
      end

      it 'posts /gateways_view_model redirects as expected' do
        post_redirects_as_expected('/gateways_view_model')
      end

      it 'posts /group_members_view_model redirects as expected' do
        post_redirects_as_expected('/group_members_view_model')
      end

      it 'posts /groups_view_model redirects as expected' do
        post_redirects_as_expected('/groups_view_model')
      end

      it 'posts /health_managers_view_model redirects as expected' do
        post_redirects_as_expected('/health_managers_view_model')
      end

      it 'posts /identity_providers_view_model redirects as expected' do
        post_redirects_as_expected('/identity_providers_view_model')
      end

      it 'posts /identity_zones_view_model redirects as expected' do
        post_redirects_as_expected('/identity_zones_view_model')
      end

      it 'posts /isolation_segments redirects as expected' do
        post_redirects_as_expected('/isolation_segments', '{"name":"bogus"}')
      end

      it 'posts /isolation_segments_view_model redirects as expected' do
        post_redirects_as_expected('/isolation_segments_view_model')
      end

      it 'posts /logs_view_model redirects as expected' do
        post_redirects_as_expected('/logs_view_model')
      end

      it 'posts /mfa_providers_view_model redirects as expected' do
        post_redirects_as_expected('/mfa_providers_view_model')
      end

      it 'posts /organizations redirects as expected' do
        post_redirects_as_expected('/organizations', '{"name":"new_org"}')
      end

      it 'posts /organizations_isolation_segments_view_model redirects as expected' do
        post_redirects_as_expected('/organizations_isolation_segments_view_model')
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

      it 'posts /revocable_tokens_view_model redirects as expected' do
        post_redirects_as_expected('/revocable_tokens_view_model')
      end

      it 'posts /routers_view_model redirects as expected' do
        post_redirects_as_expected('/routers_view_model')
      end

      it 'posts /route_bindings_view_model redirects as expected' do
        post_redirects_as_expected('/route_bindings_view_model')
      end

      it 'posts /route_mappings_view_model redirects as expected' do
        post_redirects_as_expected('/route_mappings_view_model')
      end

      it 'posts /routes_view_model redirects as expected' do
        post_redirects_as_expected('/routes_view_model')
      end

      it 'posts /security_groups_spaces_view_model redirects as expected' do
        post_redirects_as_expected('/security_groups_spaces_view_model')
      end

      it 'posts /security_groups_view_model redirects as expected' do
        post_redirects_as_expected('/security_groups_view_model')
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

      it 'posts /service_providers_view_model redirects as expected' do
        post_redirects_as_expected('/service_providers_view_model')
      end

      it 'posts /services_view_model redirects as expected' do
        post_redirects_as_expected('/services_view_model')
      end

      it 'posts /shared_service_instances_view_model redirects as expected' do
        post_redirects_as_expected('/shared_service_instances_view_model')
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

      it 'posts /staging_security_groups_spaces_view_model redirects as expected' do
        post_redirects_as_expected('/staging_security_groups_spaces_view_model')
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

      it 'puts /buildpacks/:guid redirects as expected' do
        put_redirects_as_expected('/buildpacks/buildpack', '{"enabled":true}')
      end

      it 'puts /feature_flags/:name redirects as expected' do
        put_redirects_as_expected('/feature_flags/name', '{"enabled":true}')
      end

      it 'puts /identity_providers/:guid/status redirects as expected' do
        put_redirects_as_expected('/identity_providers/identity_provider1/status', '{"requirePasswordChange":true}')
      end

      it 'puts /isolation_segments/:guid redirects as expected' do
        put_redirects_as_expected('/isolation_segments/isolation_segment1', '{"name":"bogus"}')
      end

      it 'puts /organizations/:guid redirects as expected' do
        put_redirects_as_expected('/organizations/organization1', '{"quota_definition_guid":"quota1"}')
      end

      it 'puts /quota_definitions/:guid redirects as expected' do
        put_redirects_as_expected('/quota_definitions/quota_definition1', '{"name":"bogus"}')
      end

      it 'puts /security_groups/:guid redirects as expected' do
        put_redirects_as_expected('/security_groups/security_group1', '{"name":"bogus"}')
      end

      it 'puts /service_brokers/:guid redirects as expected' do
        put_redirects_as_expected('/service_brokers/service_broker1', '{"name":"bogus"}')
      end

      it 'puts /service_instances/:guid/:boolean redirects as expected' do
        put_redirects_as_expected('/service_instances/service_instance1/true', '{"name":"bogus"}')
      end

      it 'puts /service_plans/:guid redirects as expected' do
        put_redirects_as_expected('/service_plans/application1', '{"public":true}')
      end

      it 'puts /spaces/:guid redirects as expected' do
        put_redirects_as_expected('/spaces/space1', '{"name":"bogus"}')
      end

      it 'puts /space_quota_definitions/:guid redirects as expected' do
        put_redirects_as_expected('/space_quota_definitions/space_quota_definition1', '{"name":"bogus"}')
      end

      it 'puts /space_quota_definitions/:guid/spaces/:guid redirects as expected' do
        put_redirects_as_expected('/space_quota_definitions/space_quota1/spaces/space1')
      end

      it 'puts /users/:guid redirects as expected' do
        put_redirects_as_expected('/users/user1', '{"active":true}')
      end

      it 'puts /users/:guid/status redirects as expected' do
        put_redirects_as_expected('/users/user1/status', '{"locked":false}')
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
      expect(response.is_a?(Net::HTTPOK)).to be(true)

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
        expect(response.is_a?(Net::HTTPOK)).to be(true)

        body = response.body
        expect(body).to_not be_nil

        json = Yajl::Parser.parse(body)

        expect(json).to include('apps'              => nil,
                                'cells'             => nil,
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
          request = Net::HTTP::Post.new('/statistics?apps=1&cells=2&deas=3&organizations=4&running_instances=5&spaces=6&timestamp=7&total_instances=8&users=9')
          request['Cookie']         = cookie
          request['Content-Length'] = 0

          response = http.request(request)
          expect(response.is_a?(Net::HTTPOK)).to be(true)

          body = response.body
          expect(body).to_not be_nil

          json = Yajl::Parser.parse(body)
          expect(json).to eq('apps'              => 1,
                             'cells'             => 2,
                             'deas'              => 3,
                             'organizations'     => 4,
                             'running_instances' => 5,
                             'spaces'            => 6,
                             'timestamp'         => 7,
                             'total_instances'   => 8,
                             'users'             => 9)

          # Second half of the test does not require cookie for request

          request = Net::HTTP::Get.new('/statistics')

          response = http.request(request)
          expect(response.is_a?(Net::HTTPOK)).to be(true)

          body = response.body
          expect(body).to_not be_nil
          json = Yajl::Parser.parse(body)

          expect(json).to eq([{ 'apps'              => 1,
                                'cells'             => 2,
                                'deas'              => 3,
                                'organizations'     => 4,
                                'running_instances' => 5,
                                'spaces'            => 6,
                                'timestamp'         => 7,
                                'total_instances'   => 8,
                                'users'             => 9 }])
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

  context 'health' do
    shared_examples 'common health' do
      before do
        login_stub_fail
      end
      let(:http) { create_http }

      it '/health succeeds' do
        request = Net::HTTP::Get.new('/health')

        response = http.request(request)
        expect(response.is_a?(Net::HTTPOK)).to be(true)
      end
    end

    context 'health via http' do
      it_behaves_like('common health')
    end

    context 'health via https' do
      let(:secured_client_connection) { true }
      it_behaves_like('common health')
    end
  end
end
