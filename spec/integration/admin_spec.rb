require 'yajl'
require_relative '../spec_helper'

describe AdminUI::Admin, type: :integration do
  include_context :server_context

  def create_http
    Net::HTTP.new(host, port)
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

  def _get_request(path)
    request = Net::HTTP::Get.new(path)
    request['Cookie'] = cookie
    http.request(request)
  end

  def get_response(path)
    response = _get_request(path)
    check_ok_response(response)
    response
  end

  def get_response_for_invalid_path(path)
    response = _get_request(path)
    check_notfound_response(response)
    response
  end

  def verify_sys_log_entries(operations_msgs, escapes = false)
    found_match = 0
    File.readlines(log_file).each do |line|
      line.chomp!
      next unless line.include?('[ admin ] : [ ')

      operations_msgs.each do |op_msg|
        op  = op_msg[0]
        msg = op_msg[1]
        esmsg = msg
        esmsg = Regexp.escape(msg) if escapes
        next unless line.match?(/\[ admin \] : \[ #{op} \] : #{esmsg}/)

        found_match += 1
        break
      end
    end
    expect(found_match).to be >= operations_msgs.length
  end

  def check_ok_response(response)
    expect(response.is_a?(Net::HTTPOK)).to be(true)
  end

  def check_notfound_response(response)
    expect(response.is_a?(Net::HTTPNotFound)).to be(true)
    expect(response.body).to eq('Page Not Found')
  end

  def get_json(path, escapes = false)
    response = get_response(path)

    body = response.body
    expect(body).to_not be_nil
    verify_sys_log_entries([['get', path]], escapes)
    Yajl::Parser.parse(body)
  end

  def post_request(path, body)
    request = Net::HTTP::Post.new(path)
    request['Cookie'] = cookie
    request['Content-Length'] = 0
    request.body = body if body
    http.request(request)
  end

  def post_request_for_invalid_path(path, body)
    response = post_request(path, body)
    check_notfound_response(response)
    response
  end

  def put_request(path, body = nil)
    request = Net::HTTP::Put.new(path)
    request['Cookie'] = cookie
    request['Content-Length'] = 0
    request.body = body if body
    http.request(request)
  end

  def put_request_for_invalid_path(path, body)
    response = put_request(path, body)
    check_notfound_response(response)
    response
  end

  def delete_request(path)
    request = Net::HTTP::Delete.new(path)
    request['Cookie'] = cookie
    request['Content-Length'] = 0
    http.request(request)
  end

  def delete_request_for_invalid_path(path)
    response = delete_request(path)
    check_notfound_response(response)
    response
  end

  shared_examples 'common_check_request_path' do
    let(:http)   { create_http }
    let(:cookie) {} # intentionally empty
    it 'returns the 404 code if the get url is invalid' do
      get_response_for_invalid_path('/foo')
    end

    it 'returns the 404 code if the put url is invalid' do
      put_request_for_invalid_path('/foo', '{"state":"STOPPED"}')
    end

    it 'returns the 404 code if the post url is invalid' do
      post_request_for_invalid_path('/foo', '{"name":"new_org"}')
    end

    it 'returns the 404 code if the delete url is invalid' do
      delete_request_for_invalid_path('/foo')
    end
  end

  context 'returns the 404 code if the url is wrong without login' do
    it_behaves_like('common_check_request_path')
  end

  context 'returns the 404 code if the url is wrong with login' do
    let(:cookie) { login_and_return_cookie(http) }
    it_behaves_like('common_check_request_path')
  end

  context 'manage application' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/applications_view_model')['items']['items'].length).to eq(1)
    end

    def rename_app
      response = put_request("/applications/#{cc_app[:guid]}", "{\"name\":\"#{cc_app_rename}\"}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/applications/#{cc_app[:guid]}; body = {\"name\":\"#{cc_app_rename}\"}"]], true)
    end

    def stop_app
      response = put_request("/applications/#{cc_app[:guid]}", '{"state":"STOPPED"}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/applications/#{cc_app[:guid]}; body = {\"state\":\"STOPPED\"}"]], true)
    end

    def start_app
      response = put_request("/applications/#{cc_app[:guid]}", '{"state":"STARTED"}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/applications/#{cc_app[:guid]}; body = {\"state\":\"STARTED\"}"]], true)
    end

    def restage_app
      response = post_request("/applications/#{cc_app[:guid]}/restage", '{}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['post', "/applications/#{cc_app[:guid]}/restage"]], true)
    end

    def disable_app_diego
      response = put_request("/applications/#{cc_app[:guid]}", '{"diego":false}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/applications/#{cc_app[:guid]}; body = {\"diego\":false}"]], true)
    end

    def enable_app_diego
      response = put_request("/applications/#{cc_app[:guid]}", '{"diego":true}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/applications/#{cc_app[:guid]}; body = {\"diego\":true}"]], true)
    end

    def disable_app_ssh
      response = put_request("/applications/#{cc_app[:guid]}", '{"enable_ssh":false}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/applications/#{cc_app[:guid]}; body = {\"enable_ssh\":false}"]], true)
    end

    def enable_app_ssh
      response = put_request("/applications/#{cc_app[:guid]}", '{"enable_ssh":true}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/applications/#{cc_app[:guid]}; body = {\"enable_ssh\":true}"]], true)
    end

    def disable_app_revisions
      response = put_request("/applications/#{cc_app[:guid]}", '{"revisions_enabled":false}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/applications/#{cc_app[:guid]}; body = {\"revisions_enabled\":false}"]], true)
    end

    def enable_app_revisions
      response = put_request("/applications/#{cc_app[:guid]}", '{"revisions_enabled":true}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/applications/#{cc_app[:guid]}; body = {\"revisions_enabled\":true}"]], true)
    end

    def delete_app
      response = delete_request("/applications/#{cc_app[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/applications/#{cc_app[:guid]}"]])
    end

    def delete_app_recursive
      response = delete_request("/applications/#{cc_app[:guid]}?recursive=true")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/applications/#{cc_app[:guid]}?recursive=true"]], true)
    end

    def delete_app_annotation
      response = delete_request("/applications/#{cc_app[:guid]}/metadata/annotations/#{cc_app_annotation[:key]}?prefix=#{cc_app_annotation[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/applications/#{cc_app[:guid]}/metadata/annotations/#{cc_app_annotation[:key]}?prefix=#{cc_app_annotation[:key_prefix]}"]], true)
    end

    def delete_app_environment_variable
      response = delete_request("/applications/#{cc_app[:guid]}/environment_variables/#{cc_app_environment_variable_name}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/applications/#{cc_app[:guid]}/environment_variables/#{cc_app_environment_variable_name}"]])
    end

    def delete_app_label
      response = delete_request("/applications/#{cc_app[:guid]}/metadata/labels/#{cc_app_label[:key_name]}?prefix=#{cc_app_label[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/applications/#{cc_app[:guid]}/metadata/labels/#{cc_app_label[:key_name]}?prefix=#{cc_app_label[:key_prefix]}"]], true)
    end

    it 'has user name and applications in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/applications_view_model']], true)
    end

    it 'renames an application' do
      expect { rename_app }.to change { get_json('/applications_view_model')['items']['items'][0][1] }.from(cc_app[:name]).to(cc_app_rename)
    end

    it 'stops a running application' do
      start_app
      expect { stop_app }.to change { get_json('/applications_view_model')['items']['items'][0][4] }.from('STARTED').to('STOPPED')
    end

    it 'starts a stopped application' do
      stop_app
      expect { start_app }.to change { get_json('/applications_view_model')['items']['items'][0][4] }.from('STOPPED').to('STARTED')
    end

    it 'restages stopped application' do
      restage_app
    end

    it 'enables the application diego' do
      disable_app_diego
      expect { enable_app_diego }.to change { get_json('/applications_view_model')['items']['items'][0][9] }.from(false).to(true)
    end

    it 'disables the application diego' do
      enable_app_diego
      expect { disable_app_diego }.to change { get_json('/applications_view_model')['items']['items'][0][9] }.from(true).to(false)
    end

    it 'enables the application ssh' do
      disable_app_ssh
      expect { enable_app_ssh }.to change { get_json('/applications_view_model')['items']['items'][0][10] }.from(false).to(true)
    end

    it 'disables the application ssh' do
      enable_app_ssh
      expect { disable_app_ssh }.to change { get_json('/applications_view_model')['items']['items'][0][10] }.from(true).to(false)
    end

    it 'enables the application revisions' do
      disable_app_revisions
      expect { enable_app_revisions }.to change { get_json('/applications_view_model')['items']['items'][0][11] }.from(false).to(true)
    end

    it 'disables the application revisions' do
      enable_app_revisions
      expect { disable_app_revisions }.to change { get_json('/applications_view_model')['items']['items'][0][11] }.from(true).to(false)
    end

    it 'deletes an application' do
      expect { delete_app }.to change { get_json('/applications_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes an application recursive' do
      expect { delete_app_recursive }.to change { get_json('/applications_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes an application annotation' do
      expect { delete_app_annotation }.to change { get_json("/applications_view_model/#{cc_app[:guid]}")['annotations'].length }.from(1).to(0)
    end

    it 'deletes an application environment_variable' do
      expect { delete_app_environment_variable }.to change { get_json("/applications_view_model/#{cc_app[:guid]}")['environment_variables'].keys.length }.from(1).to(0)
    end

    it 'deletes an application label' do
      expect { delete_app_label }.to change { get_json("/applications_view_model/#{cc_app[:guid]}")['labels'].length }.from(1).to(0)
    end
  end

  context 'manage application instance' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/application_instances_view_model')['items']['items'].length).to eq(1)
    end

    def delete_app_instance
      response = delete_request("/applications/#{cc_app[:guid]}/#{cc_app_instance_index}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/applications/#{cc_app[:guid]}/#{cc_app_instance_index}"]])
    end

    it 'has user name and application instances request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/application_instances_view_model']], true)
    end

    it 'deletes an application instance' do
      expect { delete_app_instance }.to change { get_json('/application_instances_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage buildpack' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/buildpacks_view_model')['items']['items'].length).to eq(1)
    end

    def rename_buildpack
      response = put_request("/buildpacks/#{cc_buildpack[:guid]}", "{\"name\":\"#{cc_buildpack_rename}\"}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/buildpacks/#{cc_buildpack[:guid]}; body = {\"name\":\"#{cc_buildpack_rename}\"}"]], true)
    end

    def make_buildpack_disabled
      response = put_request("/buildpacks/#{cc_buildpack[:guid]}", '{"enabled":false}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/buildpacks/#{cc_buildpack[:guid]}; body = {\"enabled\":false}"]], true)
    end

    def make_buildpack_enabled
      response = put_request("/buildpacks/#{cc_buildpack[:guid]}", '{"enabled":true}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/buildpacks/#{cc_buildpack[:guid]}; body = {\"enabled\":true}"]], true)
    end

    def make_buildpack_locked
      response = put_request("/buildpacks/#{cc_buildpack[:guid]}", '{"locked":true}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/buildpacks/#{cc_buildpack[:guid]}; body = {\"locked\":true}"]], true)
    end

    def make_buildpack_unlocked
      response = put_request("/buildpacks/#{cc_buildpack[:guid]}", '{"locked":false}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/buildpacks/#{cc_buildpack[:guid]}; body = {\"locked\":false}"]], true)
    end

    def delete_buildpack
      response = delete_request("/buildpacks/#{cc_buildpack[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/buildpacks/#{cc_buildpack[:guid]}"]])
    end

    def delete_buildpack_annotation
      response = delete_request("/buildpacks/#{cc_buildpack[:guid]}/metadata/annotations/#{cc_buildpack_annotation[:key]}?prefix=#{cc_buildpack_annotation[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/buildpacks/#{cc_buildpack[:guid]}/metadata/annotations/#{cc_buildpack_annotation[:key]}?prefix=#{cc_buildpack_annotation[:key_prefix]}"]], true)
    end

    def delete_buildpack_label
      response = delete_request("/buildpacks/#{cc_buildpack[:guid]}/metadata/labels/#{cc_buildpack_label[:key_name]}?prefix=#{cc_buildpack_label[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/buildpacks/#{cc_buildpack[:guid]}/metadata/labels/#{cc_buildpack_label[:key_name]}?prefix=#{cc_buildpack_label[:key_prefix]}"]], true)
    end

    it 'has user name and buildpack request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/buildpacks_view_model']], true)
    end

    it 'renames a buildpack' do
      expect { rename_buildpack }.to change { get_json('/buildpacks_view_model')['items']['items'][0][2] }.from(cc_buildpack[:name]).to(cc_buildpack_rename)
    end

    it 'disables buildpack' do
      make_buildpack_enabled
      expect { make_buildpack_disabled }.to change { get_json('/buildpacks_view_model')['items']['items'][0][7] }.from(true).to(false)
    end

    it 'enables buildpack' do
      make_buildpack_disabled
      expect { make_buildpack_enabled }.to change { get_json('/buildpacks_view_model')['items']['items'][0][7] }.from(false).to(true)
    end

    it 'locks buildpack' do
      make_buildpack_unlocked
      expect { make_buildpack_locked }.to change { get_json('/buildpacks_view_model')['items']['items'][0][8] }.from(false).to(true)
    end

    it 'unlocks buildpack' do
      make_buildpack_locked
      expect { make_buildpack_unlocked }.to change { get_json('/buildpacks_view_model')['items']['items'][0][8] }.from(true).to(false)
    end

    it 'deletes a buildpack' do
      expect { delete_buildpack }.to change { get_json('/buildpacks_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes a buildpack annotation' do
      expect { delete_buildpack_annotation }.to change { get_json("/buildpacks_view_model/#{cc_buildpack[:guid]}")['annotations'].length }.from(1).to(0)
    end

    it 'deletes a buildpack label' do
      expect { delete_buildpack_label }.to change { get_json("/buildpacks_view_model/#{cc_buildpack[:guid]}")['labels'].length }.from(1).to(0)
    end
  end

  context 'manage cell' do
    let(:application_instance_source) { :doppler_cell }
    let(:http)                        { create_http }
    let(:cookie)                      { login_and_return_cookie(http) }

    before do
      expect(get_json('/cells_view_model')['items']['items'].length).to eq(1)
    end

    def delete_cell
      response = delete_request("/doppler_components?uri=#{rep_envelope.origin}:#{rep_envelope.index}:#{rep_envelope.ip}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/doppler_components?uri=#{rep_envelope.origin}:#{rep_envelope.index}:#{rep_envelope.ip}"]], true)
    end

    it 'has user name and cells request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/cells_view_model']], true)
    end

    it 'deletes a cell' do
      expect { delete_cell }.to change { get_json('/cells_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage client' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/clients_view_model')['items']['items'].length).to eq(1)
    end

    def revoke_tokens
      response = delete_request("/clients/#{uaa_client[:client_id]}/tokens")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/clients/#{uaa_client[:client_id]}/tokens"]])
    end

    def delete_client
      response = delete_request("/clients/#{uaa_client[:client_id]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/clients/#{uaa_client[:client_id]}"]])
    end

    it 'has user name and clients request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/clients_view_model']], true)
    end

    it 'revokes tokens' do
      expect { revoke_tokens }.to change { get_json('/revocable_tokens_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes a client' do
      expect { delete_client }.to change { get_json('/clients_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage cloud controller' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/cloud_controllers_view_model')['items']['items'].length).to eq(1)
    end

    def delete_cloud_controller
      response = delete_request("/components?uri=#{nats_cloud_controller_varz}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/components?uri=#{nats_cloud_controller_varz}"]], true)
    end

    it 'has user name and cloud controllers request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/cloud_controllers_view_model']], true)
    end

    it 'deletes a cloud controller' do
      expect { delete_cloud_controller }.to change { get_json('/cloud_controllers_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage dea' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/deas_view_model')['items']['items'].length).to eq(1)
    end

    def delete_dea(uri)
      response = delete_request(uri)
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', uri]], true)
    end

    it 'has user name and deas request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/deas_view_model']], true)
    end

    it 'deletes a dea' do
      expect { delete_dea("/doppler_components?uri=#{dea_envelope.origin}:#{dea_envelope.index}:#{dea_envelope.ip}") }.to change { get_json('/deas_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage domain' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/domains_view_model')['items']['items'].length).to eq(1)
    end

    def delete_domain
      response = delete_request("/domains/#{cc_domain[:guid]}/false")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/domains/#{cc_domain[:guid]}/false"]])
    end

    def delete_domain_recursive
      response = delete_request("/domains/#{cc_domain[:guid]}/false?recursive=true")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/domains/#{cc_domain[:guid]}/false?recursive=true"]], true)
    end

    def delete_domain_annotation
      response = delete_request("/domains/#{cc_domain[:guid]}/metadata/annotations/#{cc_domain_annotation[:key]}?prefix=#{cc_domain_annotation[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/domains/#{cc_domain[:guid]}/metadata/annotations/#{cc_domain_annotation[:key]}?prefix=#{cc_domain_annotation[:key_prefix]}"]], true)
    end

    def delete_domain_label
      response = delete_request("/domains/#{cc_domain[:guid]}/metadata/labels/#{cc_domain_label[:key_name]}?prefix=#{cc_domain_label[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/domains/#{cc_domain[:guid]}/metadata/labels/#{cc_domain_label[:key_name]}?prefix=#{cc_domain_label[:key_prefix]}"]], true)
    end

    def unshare_private_domain
      response = delete_request("/domains/#{cc_domain[:guid]}/false/#{cc_organization[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/domains/#{cc_domain[:guid]}/false/#{cc_organization[:guid]}"]], true)
    end

    it 'has user name and domains request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/domains_view_model']], true)
    end

    it 'deletes a domain' do
      expect { delete_domain }.to change { get_json('/domains_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes a domain recursive' do
      expect { delete_domain_recursive }.to change { get_json('/domains_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes a domain annotation' do
      expect { delete_domain_annotation }.to change { get_json("/domains_view_model/#{cc_domain[:guid]}/false")['annotations'].length }.from(1).to(0)
    end

    it 'deletes a domain label' do
      expect { delete_domain_label }.to change { get_json("/domains_view_model/#{cc_domain[:guid]}/false")['labels'].length }.from(1).to(0)
    end

    it 'unshares a private domain' do
      expect { unshare_private_domain }.to change { get_json('/domains_view_model')['items']['items'][0][8] }.from(1).to(0)
    end
  end

  context 'manage feature flag' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/feature_flags_view_model')['items']['items'].length).to eq(1)
    end

    def make_feature_flag_disabled
      response = put_request("/feature_flags/#{cc_feature_flag[:name]}", '{"enabled":false}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/feature_flags/#{cc_feature_flag[:name]}; body = {\"enabled\":false}"]], true)
    end

    def make_feature_flag_enabled
      response = put_request("/feature_flags/#{cc_feature_flag[:name]}", '{"enabled":true}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/feature_flags/#{cc_feature_flag[:name]}; body = {\"enabled\":true}"]], true)
    end

    it 'has user name and feature flag request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/feature_flags_view_model']], true)
    end

    it 'disables feature flag' do
      make_feature_flag_enabled
      expect { make_feature_flag_disabled }.to change { get_json('/feature_flags_view_model')['items']['items'][0][5] }.from(true).to(false)
    end

    it 'enables feature flag' do
      make_feature_flag_disabled
      expect { make_feature_flag_enabled }.to change { get_json('/feature_flags_view_model')['items']['items'][0][5] }.from(false).to(true)
    end
  end

  context 'manage gateway' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/gateways_view_model')['items']['items'].length).to eq(1)
    end

    def delete_gateway
      response = delete_request("/components?uri=#{nats_provisioner_varz}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/components?uri=#{nats_provisioner_varz}"]], true)
    end

    it 'has user name and gateways request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/gateways_view_model']], true)
    end

    it 'deletes a gateway' do
      expect { delete_gateway }.to change { get_json('/gateways_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage group' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/groups_view_model')['items']['items'].length).to eq(1)
    end

    def delete_group
      response = delete_request("/groups/#{uaa_group[:id]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/groups/#{uaa_group[:id]}"]])
    end

    it 'has user name and groups request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/groups_view_model']], true)
    end

    it 'deletes a group' do
      expect { delete_group }.to change { get_json('/groups_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage group members' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/group_members_view_model')['items']['items'].length).to eq(1)
    end

    def delete_group_member
      response = delete_request("/groups/#{uaa_group[:id]}/#{uaa_user[:id]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/groups/#{uaa_group[:id]}/#{uaa_user[:id]}"]])
    end

    it 'has user name and group members request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/group_members_view_model']], true)
    end

    it 'deletes a group member' do
      expect { delete_group_member }.to change { get_json('/group_members_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage health manager' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/health_managers_view_model')['items']['items'].length).to eq(1)
    end

    def delete_health_manager(uri)
      response = delete_request(uri)
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', uri]], true)
    end

    it 'has user name and health managers request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/health_managers_view_model']], true)
    end

    it 'deletes a health manager' do
      expect { delete_health_manager("/doppler_components?uri=#{analyzer_envelope.origin}:#{analyzer_envelope.index}:#{analyzer_envelope.ip}") }.to change { get_json('/health_managers_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage identity provider' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/identity_providers_view_model')['items']['items'].length).to eq(1)
    end

    def require_password_change_identity_provider
      response = put_request("/identity_providers/#{uaa_identity_provider[:id]}/status", '{"requirePasswordChange":true}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/identity_providers/#{uaa_identity_provider[:id]}/status; body = {\"requirePasswordChange\":true}"]], true)
    end

    def delete_identity_provider
      response = delete_request("/identity_providers/#{uaa_identity_provider[:id]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/identity_providers/#{uaa_identity_provider[:id]}"]])
    end

    it 'has user name and identity providers request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/identity_providers_view_model']], true)
    end

    it "requires password change for an identity provider's users" do
      require_password_change_identity_provider
    end

    it 'deletes an identity provider' do
      expect { delete_identity_provider }.to change { get_json('/identity_providers_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage identity zone' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/identity_zones_view_model')['items']['items'].length).to eq(1)
    end

    def delete_identity_zone
      response = delete_request("/identity_zones/#{uaa_identity_zone[:id]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/identity_zones/#{uaa_identity_zone[:id]}"]])
    end

    it 'has user name and identity zones request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/identity_zones_view_model']], true)
    end

    it 'deletes an identity zone' do
      expect { delete_identity_zone }.to change { get_json('/identity_zones_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage isolation segment' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/isolation_segments_view_model')['items']['items'].length).to eq(1)
    end

    def create_isolation_segment
      response = post_request('/isolation_segments', "{\"name\":\"#{cc_isolation_segment2[:name]}\"}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['post', "/isolation_segments; body = {\"name\":\"#{cc_isolation_segment2[:name]}\"}"]], true)
    end

    def rename_isolation_segment
      response = put_request("/isolation_segments/#{cc_isolation_segment[:guid]}", "{\"name\":\"#{cc_isolation_segment_rename}\"}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/isolation_segments/#{cc_isolation_segment[:guid]}; body = {\"name\":\"#{cc_isolation_segment_rename}\"}"]], true)
    end

    def delete_isolation_segment
      response = delete_request("/isolation_segments/#{cc_isolation_segment[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/isolation_segments/#{cc_isolation_segment[:guid]}"]])
    end

    def delete_isolation_segment_annotation
      response = delete_request("/isolation_segments/#{cc_isolation_segment[:guid]}/metadata/annotations/#{cc_isolation_segment_annotation[:key]}?prefix=#{cc_isolation_segment_annotation[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/isolation_segments/#{cc_isolation_segment[:guid]}/metadata/annotations/#{cc_isolation_segment_annotation[:key]}?prefix=#{cc_isolation_segment_annotation[:key_prefix]}"]], true)
    end

    def delete_isolation_segment_label
      response = delete_request("/isolation_segments/#{cc_isolation_segment[:guid]}/metadata/labels/#{cc_isolation_segment_label[:key_name]}?prefix=#{cc_isolation_segment_label[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/isolation_segments/#{cc_isolation_segment[:guid]}/metadata/labels/#{cc_isolation_segment_label[:key_name]}?prefix=#{cc_isolation_segment_label[:key_prefix]}"]], true)
    end

    it 'has user name and isolation segments request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/isolation_segments_view_model']], true)
    end

    it 'creates an isolation segment' do
      expect { create_isolation_segment }.to change { get_json('/isolation_segments_view_model')['items']['items'].length }.from(1).to(2)
      expect(get_json('/isolation_segments_view_model', false)['items']['items'][1][1]).to eq(cc_isolation_segment2[:name])
    end

    it 'renames an isolation segment' do
      expect { rename_isolation_segment }.to change { get_json('/isolation_segments_view_model')['items']['items'][0][1] }.from(cc_isolation_segment[:name]).to(cc_isolation_segment_rename)
    end

    it 'deletes an isolation segment' do
      expect { delete_isolation_segment }.to change { get_json('/isolation_segments_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes an isolation segment annotation' do
      expect { delete_isolation_segment_annotation }.to change { get_json("/isolation_segments_view_model/#{cc_isolation_segment[:guid]}")['annotations'].length }.from(1).to(0)
    end

    it 'deletes an isolation segment label' do
      expect { delete_isolation_segment_label }.to change { get_json("/isolation_segments_view_model/#{cc_isolation_segment[:guid]}")['labels'].length }.from(1).to(0)
    end
  end

  context 'manage MFA provider' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/mfa_providers_view_model')['items']['items'].length).to eq(1)
    end

    def delete_mfa_provider
      response = delete_request("/mfa_providers/#{uaa_mfa_provider[:id]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/mfa_providers/#{uaa_mfa_provider[:id]}"]])
    end

    it 'has user name and identity providers request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/mfa_providers_view_model']], true)
    end

    it 'deletes an MFA provider' do
      expect { delete_mfa_provider }.to change { get_json('/mfa_providers_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage organization' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/organizations_view_model')['items']['items'].length).to eq(1)
    end

    def create_organization
      response = post_request('/organizations', "{\"name\":\"#{cc_organization2[:name]}\"}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['post', "/organizations; body = {\"name\":\"#{cc_organization2[:name]}\"}"]], true)
    end

    def rename_organization
      response = put_request("/organizations/#{cc_organization[:guid]}", "{\"name\":\"#{cc_organization_rename}\"}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/organizations/#{cc_organization[:guid]}; body = {\"name\":\"#{cc_organization_rename}\"}"]], true)
    end

    def set_quota
      response = put_request("/organizations/#{cc_organization[:guid]}", "{\"quota_definition_guid\":\"#{cc_quota_definition2[:guid]}\"}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/organizations/#{cc_organization[:guid]}; body = {\"quota_definition_guid\":\"#{cc_quota_definition2[:guid]}\"}"]], true)
    end

    def activate_organization
      response = put_request("/organizations/#{cc_organization[:guid]}", '{"status":"active"}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/organizations/#{cc_organization[:guid]}; body = {\"status\":\"active\"}"]], true)
    end

    def suspend_organization
      response = put_request("/organizations/#{cc_organization[:guid]}", '{"status":"suspended"}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/organizations/#{cc_organization[:guid]}; body = {\"status\":\"suspended\"}"]], true)
    end

    def remove_organization_default_isolation_segment
      response = delete_request("/organizations/#{cc_organization[:guid]}/default_isolation_segment")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/organizations/#{cc_organization[:guid]}/default_isolation_segment"]], true)
    end

    def delete_organization
      response = delete_request("/organizations/#{cc_organization[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/organizations/#{cc_organization[:guid]}"]])
    end

    def delete_organization_recursive
      response = delete_request("/organizations/#{cc_organization[:guid]}?recursive=true")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/organizations/#{cc_organization[:guid]}?recursive=true"]], true)
    end

    def delete_organization_annotation
      response = delete_request("/organizations/#{cc_organization[:guid]}/metadata/annotations/#{cc_organization_annotation[:key]}?prefix=#{cc_organization_annotation[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/organizations/#{cc_organization[:guid]}/metadata/annotations/#{cc_organization_annotation[:key]}?prefix=#{cc_organization_annotation[:key_prefix]}"]], true)
    end

    def delete_organization_label
      response = delete_request("/organizations/#{cc_organization[:guid]}/metadata/labels/#{cc_organization_label[:key_name]}?prefix=#{cc_organization_label[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/organizations/#{cc_organization[:guid]}/metadata/labels/#{cc_organization_label[:key_name]}?prefix=#{cc_organization_label[:key_prefix]}"]], true)
    end

    it 'has user name and organizations request in the log file' do
      verify_sys_log_entries([['get', '/organizations_view_model']])
    end

    it 'creates an organization' do
      expect { create_organization }.to change { get_json('/organizations_view_model')['items']['items'].length }.from(1).to(2)
      expect(get_json('/organizations_view_model', false)['items']['items'][1][1]).to eq(cc_organization2[:name])
    end

    it 'renames an organization' do
      expect { rename_organization }.to change { get_json('/organizations_view_model')['items']['items'][0][1] }.from(cc_organization[:name]).to(cc_organization_rename)
    end

    context 'sets the quota for organization' do
      let(:insert_second_quota_definition) { true }
      it 'sets the quota for organization' do
        expect { set_quota }.to change { get_json('/organizations_view_model')['items']['items'][0][12] }.from(cc_quota_definition[:name]).to(cc_quota_definition2[:name])
      end
    end

    it 'activates an organization' do
      suspend_organization
      expect { activate_organization }.to change { get_json('/organizations_view_model')['items']['items'][0][3] }.from('suspended').to('active')
    end

    it 'suspends an organization' do
      activate_organization
      expect { suspend_organization }.to change { get_json('/organizations_view_model')['items']['items'][0][3] }.from('active').to('suspended')
    end

    it 'removes an organization default isolation segment' do
      expect(get_json('/organizations_view_model')['items']['items'][0][39]).to eq(cc_isolation_segment[:guid])
      expect { remove_organization_default_isolation_segment }.to change { get_json('/organizations_view_model')['items']['items'][0][38] }.from(cc_isolation_segment[:name]).to(nil)
      expect(get_json('/organizations_view_model')['items']['items'][0][39]).to eq(nil)
    end

    it 'deletes an organization' do
      expect { delete_organization }.to change { get_json('/organizations_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes an organization recursive' do
      expect { delete_organization_recursive }.to change { get_json('/organizations_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes an organization annotation' do
      expect { delete_organization_annotation }.to change { get_json("/organizations_view_model/#{cc_organization[:guid]}")['annotations'].length }.from(1).to(0)
    end

    it 'deletes an organization label' do
      expect { delete_organization_label }.to change { get_json("/organizations_view_model/#{cc_organization[:guid]}")['labels'].length }.from(1).to(0)
    end
  end

  context 'manage organization isolation segment' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/organizations_isolation_segments_view_model')['items']['items'].length).to eq(1)
    end

    def delete_organization_isolation_segment
      response = delete_request("/organizations/#{cc_organization[:guid]}/#{cc_isolation_segment[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/organizations/#{cc_organization[:guid]}/#{cc_isolation_segment[:guid]}"]])
    end

    it 'has user name and organizations isolation segments request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/organizations_isolation_segments_view_model']], true)
    end

    it 'deletes an organization isolation segment' do
      expect { delete_organization_isolation_segment }.to change { get_json('/organizations_isolation_segments_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage organization role' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/organization_roles_view_model')['items']['items'].length).to eq(4)
    end

    def delete_organization_role
      response = delete_request("/organizations/#{cc_organization[:guid]}/#{cc_organization_auditor[:role_guid]}/auditors/#{cc_user[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/organizations/#{cc_organization[:guid]}/#{cc_organization_auditor[:role_guid]}/auditors/#{cc_user[:guid]}"]])
    end

    it 'has user name and organization roles request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/organization_roles_view_model']], true)
    end

    it 'deletes an organization role' do
      expect { delete_organization_role }.to change { get_json('/organization_roles_view_model')['items']['items'].length }.from(4).to(3)
    end
  end

  context 'manage quota' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/quotas_view_model')['items']['items'].length).to eq(1)
    end

    def rename_quota
      response = put_request("/quota_definitions/#{cc_quota_definition[:guid]}", "{\"name\":\"#{cc_quota_definition_rename}\"}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/quota_definitions/#{cc_quota_definition[:guid]}; body = {\"name\":\"#{cc_quota_definition_rename}\"}"]], true)
    end

    def delete_quota
      response = delete_request("/quota_definitions/#{cc_quota_definition[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/quota_definitions/#{cc_quota_definition[:guid]}"]])
    end

    it 'has user name and quotas request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/quotas_view_model']], true)
    end

    it 'renames a quota' do
      expect { rename_quota }.to change { get_json('/quotas_view_model')['items']['items'][0][1] }.from(cc_quota_definition[:name]).to(cc_quota_definition_rename)
    end

    it 'deletes a quota' do
      expect { delete_quota }.to change { get_json('/quotas_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage revocable token' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/revocable_tokens_view_model')['items']['items'].length).to eq(1)
    end

    def delete_revocable_token
      response = delete_request("/revocable_tokens/#{uaa_revocable_token[:token_id]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/revocable_tokens/#{uaa_revocable_token[:token_id]}"]])
    end

    it 'has user name and clients request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/revocable_tokens_view_model']], true)
    end

    it 'deletes a revocable token' do
      expect { delete_revocable_token }.to change { get_json('/revocable_tokens_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage route' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/routes_view_model')['items']['items'].length).to eq(1)
    end

    def delete_route
      response = delete_request("/routes/#{cc_route[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/routes/#{cc_route[:guid]}"]])
    end

    def delete_route_recursive
      response = delete_request("/routes/#{cc_route[:guid]}?recursive=true")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/routes/#{cc_route[:guid]}?recursive=true"]], true)
    end

    def delete_route_annotation
      response = delete_request("/routes/#{cc_route[:guid]}/metadata/annotations/#{cc_route_annotation[:key]}?prefix=#{cc_route_annotation[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/routes/#{cc_route[:guid]}/metadata/annotations/#{cc_route_annotation[:key]}?prefix=#{cc_route_annotation[:key_prefix]}"]], true)
    end

    def delete_route_label
      response = delete_request("/routes/#{cc_route[:guid]}/metadata/labels/#{cc_route_label[:key_name]}?prefix=#{cc_route_label[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/routes/#{cc_route[:guid]}/metadata/labels/#{cc_route_label[:key_name]}?prefix=#{cc_route_label[:key_prefix]}"]], true)
    end

    it 'has user name and routes request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/routes_view_model']], true)
    end

    it 'deletes a route' do
      expect { delete_route }.to change { get_json('/routes_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes a route recursive' do
      expect { delete_route_recursive }.to change { get_json('/routes_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes a route annotation' do
      expect { delete_route_annotation }.to change { get_json("/routes_view_model/#{cc_route[:guid]}")['annotations'].length }.from(1).to(0)
    end

    it 'deletes a route label' do
      expect { delete_route_label }.to change { get_json("/routes_view_model/#{cc_route[:guid]}")['labels'].length }.from(1).to(0)
    end
  end

  context 'manage route binding' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/route_bindings_view_model')['items']['items'].length).to eq(1)
    end

    def delete_route_binding
      response = delete_request("/route_bindings/#{cc_service_instance[:guid]}/#{cc_route[:guid]}/#{cc_service_instance[:is_gateway_service]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/route_bindings/#{cc_service_instance[:guid]}/#{cc_route[:guid]}/#{cc_service_instance[:is_gateway_service]}"]])
    end

    def delete_route_binding_annotation
      response = delete_request("/route_bindings/#{cc_route_binding[:guid]}/metadata/annotations/#{cc_route_binding_annotation[:key]}?prefix=#{cc_route_binding_annotation[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/route_bindings/#{cc_route_binding[:guid]}/metadata/annotations/#{cc_route_binding_annotation[:key]}?prefix=#{cc_route_binding_annotation[:key_prefix]}"]], true)
    end

    def delete_route_binding_label
      response = delete_request("/route_bindings/#{cc_route_binding[:guid]}/metadata/labels/#{cc_route_binding_label[:key_name]}?prefix=#{cc_route_binding_label[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/route_bindings/#{cc_route_binding[:guid]}/metadata/labels/#{cc_route_binding_label[:key_name]}?prefix=#{cc_route_binding_label[:key_prefix]}"]], true)
    end

    it 'has user name and route bindings request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/route_bindings_view_model']], true)
    end

    it 'deletes a route binding' do
      expect { delete_route_binding }.to change { get_json('/route_bindings_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes a route binding annotation' do
      expect { delete_route_binding_annotation }.to change { get_json("/route_bindings_view_model/#{cc_route_binding[:guid]}")['annotations'].length }.from(1).to(0)
    end

    it 'deletes a route binding label' do
      expect { delete_route_binding_label }.to change { get_json("/route_bindings_view_model/#{cc_route_binding[:guid]}")['labels'].length }.from(1).to(0)
    end
  end

  context 'manage route mapping' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/route_mappings_view_model')['items']['items'].length).to eq(1)
    end

    def delete_route_mapping
      response = delete_request("/route_mappings/#{cc_route_mapping[:guid]}/#{cc_route[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/route_mappings/#{cc_route_mapping[:guid]}/#{cc_route[:guid]}"]])
    end

    it 'has user name and routes request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/route_mappings_view_model']], true)
    end

    it 'deletes a route mapping' do
      expect { delete_route_mapping }.to change { get_json('/route_mappings_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage router' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/routers_view_model')['items']['items'].length).to eq(1)
    end

    def delete_router(uri)
      response = delete_request(uri)
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', uri]], true)
    end

    it 'has user name and routers request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/routers_view_model']], true)
    end

    context 'varz router' do
      it 'deletes a router' do
        expect { delete_router("/components?uri=#{nats_router_varz}") }.to change { get_json('/routers_view_model')['items']['items'].length }.from(1).to(0)
      end
    end

    context 'doppler router' do
      let(:router_source) { :doppler_router }
      it 'deletes a router' do
        expect { delete_router("/doppler_components?uri=#{gorouter_envelope.origin}:#{gorouter_envelope.index}:#{gorouter_envelope.ip}") }.to change { get_json('/routers_view_model')['items']['items'].length }.from(1).to(0)
      end
    end
  end

  context 'manage security group' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/security_groups_view_model')['items']['items'].length).to eq(1)
    end

    def rename_security_group
      response = put_request("/security_groups/#{cc_security_group[:guid]}", "{\"name\":\"#{cc_security_group_rename}\"}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/security_groups/#{cc_security_group[:guid]}; body = {\"name\":\"#{cc_security_group_rename}\"}"]], true)
    end

    def disable_security_group_running_default
      response = put_request("/security_groups/#{cc_security_group[:guid]}", '{"running_default":false}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/security_groups/#{cc_security_group[:guid]}; body = {\"running_default\":false}"]], true)
    end

    def enable_security_group_running_default
      response = put_request("/security_groups/#{cc_security_group[:guid]}", '{"running_default":true}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/security_groups/#{cc_security_group[:guid]}; body = {\"running_default\":true}"]], true)
    end

    def disable_security_group_staging_default
      response = put_request("/security_groups/#{cc_security_group[:guid]}", '{"staging_default":false}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/security_groups/#{cc_security_group[:guid]}; body = {\"staging_default\":false}"]], true)
    end

    def enable_security_group_staging_default
      response = put_request("/security_groups/#{cc_security_group[:guid]}", '{"staging_default":true}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/security_groups/#{cc_security_group[:guid]}; body = {\"staging_default\":true}"]], true)
    end

    def delete_security_group
      response = delete_request("/security_groups/#{cc_security_group[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/security_groups/#{cc_security_group[:guid]}"]])
    end

    it 'has user name and security groups request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/security_groups_view_model']], true)
    end

    it 'renames a security_group' do
      expect { rename_security_group }.to change { get_json('/security_groups_view_model')['items']['items'][0][1] }.from(cc_security_group[:name]).to(cc_security_group_rename)
    end

    it 'disables a security_group as running default' do
      enable_security_group_running_default
      expect { disable_security_group_running_default }.to change { get_json('/security_groups_view_model')['items']['items'][0][6] }.from(true).to(false)
    end

    it 'enables a security_group as running default' do
      disable_security_group_running_default
      expect { enable_security_group_running_default }.to change { get_json('/security_groups_view_model')['items']['items'][0][6] }.from(false).to(true)
    end

    it 'disables a security_group as staging default' do
      enable_security_group_staging_default
      expect { disable_security_group_staging_default }.to change { get_json('/security_groups_view_model')['items']['items'][0][5] }.from(true).to(false)
    end

    it 'enables a security_group as staging default' do
      disable_security_group_staging_default
      expect { enable_security_group_staging_default }.to change { get_json('/security_groups_view_model')['items']['items'][0][5] }.from(false).to(true)
    end

    it 'deletes a security group' do
      expect { delete_security_group }.to change { get_json('/security_groups_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage security group space' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/security_groups_spaces_view_model')['items']['items'].length).to eq(1)
    end

    def delete_security_group_space
      response = delete_request("/security_groups/#{cc_security_group[:guid]}/#{cc_space[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/security_groups/#{cc_security_group[:guid]}/#{cc_space[:guid]}"]])
    end

    it 'has user name and security groups spaces request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/security_groups_spaces_view_model']], true)
    end

    it 'deletes a security group space' do
      expect { delete_security_group_space }.to change { get_json('/security_groups_spaces_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage service' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/services_view_model')['items']['items'].length).to eq(1)
    end

    def delete_service
      response = delete_request("/services/#{cc_service[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/services/#{cc_service[:guid]}"]])
    end

    def purge_service
      response = delete_request("/services/#{cc_service[:guid]}?purge=true")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/services/#{cc_service[:guid]}?purge=true"]], true)
    end

    def delete_service_annotation
      response = delete_request("/services/#{cc_service[:guid]}/metadata/annotations/#{cc_service_offering_annotation[:key]}?prefix=#{cc_service_offering_annotation[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/services/#{cc_service[:guid]}/metadata/annotations/#{cc_service_offering_annotation[:key]}?prefix=#{cc_service_offering_annotation[:key_prefix]}"]], true)
    end

    def delete_service_label
      response = delete_request("/services/#{cc_service[:guid]}/metadata/labels/#{cc_service_offering_label[:key_name]}?prefix=#{cc_service_offering_label[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/services/#{cc_service[:guid]}/metadata/labels/#{cc_service_offering_label[:key_name]}?prefix=#{cc_service_offering_label[:key_prefix]}"]], true)
    end

    it 'has user name and services request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/services_view_model']], true)
    end

    it 'deletes a service' do
      expect { delete_service }.to change { get_json('/services_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'purges a service' do
      expect { purge_service }.to change { get_json('/services_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes a service annotation' do
      expect { delete_service_annotation }.to change { get_json("/services_view_model/#{cc_service[:guid]}")['annotations'].length }.from(1).to(0)
    end

    it 'deletes a service label' do
      expect { delete_service_label }.to change { get_json("/services_view_model/#{cc_service[:guid]}")['labels'].length }.from(1).to(0)
    end
  end

  context 'manage service binding' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/service_bindings_view_model')['items']['items'].length).to eq(1)
    end

    def delete_service_binding
      response = delete_request("/service_bindings/#{cc_service_binding[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/service_bindings/#{cc_service_binding[:guid]}"]])
    end

    def delete_service_binding_annotation
      response = delete_request("/service_bindings/#{cc_service_binding[:guid]}/metadata/annotations/#{cc_service_binding_annotation[:key]}?prefix=#{cc_service_binding_annotation[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/service_bindings/#{cc_service_binding[:guid]}/metadata/annotations/#{cc_service_binding_annotation[:key]}?prefix=#{cc_service_binding_annotation[:key_prefix]}"]], true)
    end

    def delete_service_binding_label
      response = delete_request("/service_bindings/#{cc_service_binding[:guid]}/metadata/labels/#{cc_service_binding_label[:key_name]}?prefix=#{cc_service_binding_label[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/service_bindings/#{cc_service_binding[:guid]}/metadata/labels/#{cc_service_binding_label[:key_name]}?prefix=#{cc_service_binding_label[:key_prefix]}"]], true)
    end

    it 'has user name and service bindings request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/service_bindings_view_model']], true)
    end

    it 'deletes a service binding' do
      expect { delete_service_binding }.to change { get_json('/service_bindings_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes a service binding annotation' do
      expect { delete_service_binding_annotation }.to change { get_json("/service_bindings_view_model/#{cc_service_binding[:guid]}")['annotations'].length }.from(1).to(0)
    end

    it 'deletes a service binding label' do
      expect { delete_service_binding_label }.to change { get_json("/service_bindings_view_model/#{cc_service_binding[:guid]}")['labels'].length }.from(1).to(0)
    end
  end

  context 'manage service broker' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/service_brokers_view_model')['items']['items'].length).to eq(1)
    end

    def rename_service_broker
      response = put_request("/service_brokers/#{cc_service_broker[:guid]}", "{\"name\":\"#{cc_service_broker_rename}\"}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/service_brokers/#{cc_service_broker[:guid]}; body = {\"name\":\"#{cc_service_broker_rename}\"}"]], true)
    end

    def delete_service_broker
      response = delete_request("/service_brokers/#{cc_service_broker[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/service_brokers/#{cc_service_broker[:guid]}"]])
    end

    def delete_service_broker_annotation
      response = delete_request("/service_brokers/#{cc_service_broker[:guid]}/metadata/annotations/#{cc_service_broker_annotation[:key]}?prefix=#{cc_service_broker_annotation[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/service_brokers/#{cc_service_broker[:guid]}/metadata/annotations/#{cc_service_broker_annotation[:key]}?prefix=#{cc_service_broker_annotation[:key_prefix]}"]], true)
    end

    def delete_service_broker_label
      response = delete_request("/service_brokers/#{cc_service_broker[:guid]}/metadata/labels/#{cc_service_broker_label[:key_name]}?prefix=#{cc_service_broker_label[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/service_brokers/#{cc_service_broker[:guid]}/metadata/labels/#{cc_service_broker_label[:key_name]}?prefix=#{cc_service_broker_label[:key_prefix]}"]], true)
    end

    it 'has user name and service brokers request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/service_brokers_view_model']], true)
    end

    it 'renames a service broker' do
      expect { rename_service_broker }.to change { get_json('/service_brokers_view_model')['items']['items'][0][1] }.from(cc_service_broker[:name]).to(cc_service_broker_rename)
    end

    it 'deletes a service broker' do
      expect { delete_service_broker }.to change { get_json('/service_brokers_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes a service broker annotation' do
      expect { delete_service_broker_annotation }.to change { get_json("/service_brokers_view_model/#{cc_service_broker[:guid]}")['annotations'].length }.from(1).to(0)
    end

    it 'deletes a service broker label' do
      expect { delete_service_broker_label }.to change { get_json("/service_brokers_view_model/#{cc_service_broker[:guid]}")['labels'].length }.from(1).to(0)
    end
  end

  context 'manage service instance' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/service_instances_view_model')['items']['items'].length).to eq(1)
    end

    def rename_service_instance
      response = put_request("/service_instances/#{cc_service_instance[:guid]}/#{cc_service_instance[:is_gateway_service]}", "{\"name\":\"#{cc_service_instance_rename}\"}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/service_instances/#{cc_service_instance[:guid]}/#{cc_service_instance[:is_gateway_service]}; body = {\"name\":\"#{cc_service_instance_rename}\"}"]], true)
    end

    def delete_service_instance
      response = delete_request("/service_instances/#{cc_service_instance[:guid]}/#{cc_service_instance[:is_gateway_service]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/service_instances/#{cc_service_instance[:guid]}/#{cc_service_instance[:is_gateway_service]}"]])
    end

    def delete_service_instance_recursive
      response = delete_request("/service_instances/#{cc_service_instance[:guid]}/#{cc_service_instance[:is_gateway_service]}?recursive=true")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/service_instances/#{cc_service_instance[:guid]}/#{cc_service_instance[:is_gateway_service]}?recursive=true"]], true)
    end

    def delete_service_instance_recursive_purge
      response = delete_request("/service_instances/#{cc_service_instance[:guid]}/#{cc_service_instance[:is_gateway_service]}?recursive=true&purge=true")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/service_instances/#{cc_service_instance[:guid]}/#{cc_service_instance[:is_gateway_service]}?recursive=true&purge=true"]], true)
    end

    def delete_service_instance_annotation
      response = delete_request("/service_instances/#{cc_service_instance[:guid]}/metadata/annotations/#{cc_service_instance_annotation[:key]}?prefix=#{cc_service_instance_annotation[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/service_instances/#{cc_service_instance[:guid]}/metadata/annotations/#{cc_service_instance_annotation[:key]}?prefix=#{cc_service_instance_annotation[:key_prefix]}"]], true)
    end

    def delete_service_instance_label
      response = delete_request("/service_instances/#{cc_service_instance[:guid]}/metadata/labels/#{cc_service_instance_label[:key_name]}?prefix=#{cc_service_instance_label[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/service_instances/#{cc_service_instance[:guid]}/metadata/labels/#{cc_service_instance_label[:key_name]}?prefix=#{cc_service_instance_label[:key_prefix]}"]], true)
    end

    it 'has user name and service instances request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/service_instances_view_model']], true)
    end

    it 'renames a service instance' do
      expect { rename_service_instance }.to change { get_json('/service_instances_view_model')['items']['items'][0][1] }.from(cc_service_instance[:name]).to(cc_service_instance_rename)
    end

    it 'deletes a service instance' do
      expect { delete_service_instance }.to change { get_json('/service_instances_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes a service instance recursive' do
      expect { delete_service_instance_recursive }.to change { get_json('/service_instances_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes a service instance recursive purge' do
      expect { delete_service_instance_recursive_purge }.to change { get_json('/service_instances_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes a service instance annotation' do
      expect { delete_service_instance_annotation }.to change { get_json("/service_instances_view_model/#{cc_service_instance[:guid]}/true")['annotations'].length }.from(1).to(0)
    end

    it 'deletes a service instance label' do
      expect { delete_service_instance_label }.to change { get_json("/service_instances_view_model/#{cc_service_instance[:guid]}/true")['labels'].length }.from(1).to(0)
    end
  end

  context 'manage service key' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/service_keys_view_model')['items']['items'].length).to eq(1)
    end

    def delete_service_key
      response = delete_request("/service_keys/#{cc_service_key[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/service_keys/#{cc_service_key[:guid]}"]])
    end

    def delete_service_key_annotation
      response = delete_request("/service_keys/#{cc_service_key[:guid]}/metadata/annotations/#{cc_service_key_annotation[:key]}?prefix=#{cc_service_key_annotation[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/service_keys/#{cc_service_key[:guid]}/metadata/annotations/#{cc_service_key_annotation[:key]}?prefix=#{cc_service_key_annotation[:key_prefix]}"]], true)
    end

    def delete_service_key_label
      response = delete_request("/service_keys/#{cc_service_key[:guid]}/metadata/labels/#{cc_service_key_label[:key_name]}?prefix=#{cc_service_key_label[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/service_keys/#{cc_service_key[:guid]}/metadata/labels/#{cc_service_key_label[:key_name]}?prefix=#{cc_service_key_label[:key_prefix]}"]], true)
    end

    it 'has user name and service keys request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/service_keys_view_model']], true)
    end

    it 'deletes a service key' do
      expect { delete_service_key }.to change { get_json('/service_keys_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes a service key annotation' do
      expect { delete_service_key_annotation }.to change { get_json("/service_keys_view_model/#{cc_service_key[:guid]}")['annotations'].length }.from(1).to(0)
    end

    it 'deletes a service key label' do
      expect { delete_service_key_label }.to change { get_json("/service_keys_view_model/#{cc_service_key[:guid]}")['labels'].length }.from(1).to(0)
    end
  end

  context 'manage service plan' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/service_plans_view_model')['items']['items'].length).to eq(1)
    end

    def make_service_plan_private
      response = put_request("/service_plans/#{cc_service_plan[:guid]}", '{"public":false}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/service_plans/#{cc_service_plan[:guid]}; body = {\"public\":false}"]], true)
    end

    def make_service_plan_public
      response = put_request("/service_plans/#{cc_service_plan[:guid]}", '{"public":true}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/service_plans/#{cc_service_plan[:guid]}; body = {\"public\":true}"]], true)
    end

    def delete_service_plan
      response = delete_request("/service_plans/#{cc_service_plan[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/service_plans/#{cc_service_plan[:guid]}"]])
    end

    def delete_service_plan_annotation
      response = delete_request("/service_plans/#{cc_service_plan[:guid]}/metadata/annotations/#{cc_service_plan_annotation[:key]}?prefix=#{cc_service_plan_annotation[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/service_plans/#{cc_service_plan[:guid]}/metadata/annotations/#{cc_service_plan_annotation[:key]}?prefix=#{cc_service_plan_annotation[:key_prefix]}"]], true)
    end

    def delete_service_plan_label
      response = delete_request("/service_plans/#{cc_service_plan[:guid]}/metadata/labels/#{cc_service_plan_label[:key_name]}?prefix=#{cc_service_plan_label[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/service_plans/#{cc_service_plan[:guid]}/metadata/labels/#{cc_service_plan_label[:key_name]}?prefix=#{cc_service_plan_label[:key_prefix]}"]], true)
    end

    it 'has user name and service plan request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/service_plans_view_model']], true)
    end

    it 'makes service plan private' do
      make_service_plan_public
      expect { make_service_plan_private }.to change { get_json('/service_plans_view_model')['items']['items'][0][10] }.from(true).to(false)
    end

    it 'makes service plan public' do
      make_service_plan_private
      expect { make_service_plan_public }.to change { get_json('/service_plans_view_model')['items']['items'][0][10] }.from(false).to(true)
    end

    it 'deletes a service plan' do
      expect { delete_service_plan }.to change { get_json('/service_plans_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes a service plan annotation' do
      expect { delete_service_plan_annotation }.to change { get_json("/service_plans_view_model/#{cc_service_plan[:guid]}")['annotations'].length }.from(1).to(0)
    end

    it 'deletes a service plan label' do
      expect { delete_service_plan_label }.to change { get_json("/service_plans_view_model/#{cc_service_plan[:guid]}")['labels'].length }.from(1).to(0)
    end
  end

  context 'manage service plan visibility' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/service_plan_visibilities_view_model')['items']['items'].length).to eq(1)
    end

    def delete_service_plan_visibility
      response = delete_request("/service_plan_visibilities/#{cc_service_plan_visibility[:guid]}/#{cc_service_plan[:guid]}/#{cc_organization[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/service_plan_visibilities/#{cc_service_plan_visibility[:guid]}/#{cc_service_plan[:guid]}/#{cc_organization[:guid]}"]])
    end

    it 'has user name and service plan visibility request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/service_plan_visibilities_view_model']], true)
    end

    it 'deletes a service plan visibility' do
      expect { delete_service_plan_visibility }.to change { get_json('/service_plan_visibilities_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage service provider' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/service_providers_view_model')['items']['items'].length).to eq(1)
    end

    def delete_service_provider
      response = delete_request("/service_providers/#{uaa_service_provider[:id]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/service_providers/#{uaa_service_provider[:id]}"]])
    end

    it 'has user name and service providers request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/service_providers_view_model']], true)
    end

    it 'deletes a service provider' do
      expect { delete_service_provider }.to change { get_json('/service_providers_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage shared service instance' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/shared_service_instances_view_model')['items']['items'].length).to eq(1)
    end

    def delete_shared_service_instance
      response = delete_request("/shared_service_instances/#{cc_service_instance[:guid]}/#{cc_space[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/shared_service_instances/#{cc_service_instance[:guid]}/#{cc_space[:guid]}"]])
    end

    it 'has user name and shared service instances request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/shared_service_instances_view_model']], true)
    end

    it 'deletes a shared service instance' do
      expect { delete_shared_service_instance }.to change { get_json('/shared_service_instances_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage space' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/spaces_view_model')['items']['items'].length).to eq(1)
    end

    def rename_space
      response = put_request("/spaces/#{cc_space[:guid]}", "{\"name\":\"#{cc_space_rename}\"}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/spaces/#{cc_space[:guid]}; body = {\"name\":\"#{cc_space_rename}\"}"]], true)
    end

    def disallow_space_ssh
      response = put_request("/spaces/#{cc_space[:guid]}", '{"allow_ssh":false}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/spaces/#{cc_space[:guid]}; body = {\"allow_ssh\":false}"]], true)
    end

    def allow_space_ssh
      response = put_request("/spaces/#{cc_space[:guid]}", '{"allow_ssh":true}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/spaces/#{cc_space[:guid]}; body = {\"allow_ssh\":true}"]], true)
    end

    def remove_space_isolation_segment
      response = delete_request("/spaces/#{cc_space[:guid]}/isolation_segment")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/spaces/#{cc_space[:guid]}/isolation_segment"]], true)
    end

    def delete_space_unmapped_routes
      response = delete_request("/spaces/#{cc_space[:guid]}/unmapped_routes")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/spaces/#{cc_space[:guid]}/unmapped_routes"]], true)
    end

    def delete_space
      response = delete_request("/spaces/#{cc_space[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/spaces/#{cc_space[:guid]}"]])
    end

    def delete_space_recursive
      response = delete_request("/spaces/#{cc_space[:guid]}?recursive=true")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/spaces/#{cc_space[:guid]}?recursive=true"]], true)
    end

    def delete_space_annotation
      response = delete_request("/spaces/#{cc_space[:guid]}/metadata/annotations/#{cc_space_annotation[:key]}?prefix=#{cc_space_annotation[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/spaces/#{cc_space[:guid]}/metadata/annotations/#{cc_space_annotation[:key]}?prefix=#{cc_space_annotation[:key_prefix]}"]], true)
    end

    def delete_space_label
      response = delete_request("/spaces/#{cc_space[:guid]}/metadata/labels/#{cc_space_label[:key_name]}?prefix=#{cc_space_label[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/spaces/#{cc_space[:guid]}/metadata/labels/#{cc_space_label[:key_name]}?prefix=#{cc_space_label[:key_prefix]}"]], true)
    end

    it 'has user name and space request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/spaces_view_model']], true)
    end

    it 'renames a space' do
      expect { rename_space }.to change { get_json('/spaces_view_model')['items']['items'][0][1] }.from(cc_space[:name]).to(cc_space_rename)
    end

    it 'allows the space ssh' do
      disallow_space_ssh
      expect { allow_space_ssh }.to change { get_json('/spaces_view_model')['items']['items'][0][6] }.from(false).to(true)
    end

    it 'disallows the space ssh' do
      allow_space_ssh
      expect { disallow_space_ssh }.to change { get_json('/spaces_view_model')['items']['items'][0][6] }.from(true).to(false)
    end

    it 'removes the space isolation segment' do
      expect(get_json('/spaces_view_model')['items']['items'][0][35]).to eq(cc_isolation_segment[:guid])
      expect { remove_space_isolation_segment }.to change { get_json('/spaces_view_model')['items']['items'][0][34] }.from(cc_isolation_segment[:name]).to(nil)
      expect(get_json('/spaces_view_model')['items']['items'][0][35]).to eq(nil)
    end

    context 'delete the space unmapped routes' do
      let(:use_route) { false }

      it 'delete the space unmapped routes' do
        expect { delete_space_unmapped_routes }.to change { get_json('/spaces_view_model')['items']['items'][0][17] }.from(1).to(0)
      end
    end

    it 'deletes a space' do
      expect { delete_space }.to change { get_json('/spaces_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes a space recursive' do
      expect { delete_space_recursive }.to change { get_json('/spaces_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes a space annotation' do
      expect { delete_space_annotation }.to change { get_json("/spaces_view_model/#{cc_space[:guid]}")['annotations'].length }.from(1).to(0)
    end

    it 'deletes a space label' do
      expect { delete_space_label }.to change { get_json("/spaces_view_model/#{cc_space[:guid]}")['labels'].length }.from(1).to(0)
    end
  end

  context 'manage space quota' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/space_quotas_view_model')['items']['items'].length).to eq(1)
    end

    def rename_space_quota
      response = put_request("/space_quota_definitions/#{cc_space_quota_definition[:guid]}", "{\"name\":\"#{cc_space_quota_definition_rename}\"}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/space_quota_definitions/#{cc_space_quota_definition[:guid]}; body = {\"name\":\"#{cc_space_quota_definition_rename}\"}"]], true)
    end

    def delete_space_quota
      response = delete_request("/space_quota_definitions/#{cc_space_quota_definition[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/space_quota_definitions/#{cc_space_quota_definition[:guid]}"]])
    end

    it 'has user name and quotas request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/space_quotas_view_model']], true)
    end

    it 'renames a space quota' do
      expect { rename_space_quota }.to change { get_json('/space_quotas_view_model')['items']['items'][0][1] }.from(cc_space_quota_definition[:name]).to(cc_space_quota_definition_rename)
    end

    it 'deletes a space quota' do
      expect { delete_space_quota }.to change { get_json('/space_quotas_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage space quota space' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    def create_space_quota_space
      response = put_request("/space_quota_definitions/#{cc_space_quota_definition2[:guid]}/spaces/#{cc_space[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/space_quota_definitions/#{cc_space_quota_definition2[:guid]}/spaces/#{cc_space[:guid]}"]], true)
    end

    def delete_space_quota_space
      response = delete_request("/space_quota_definitions/#{cc_space_quota_definition[:guid]}/spaces/#{cc_space[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/space_quota_definitions/#{cc_space_quota_definition[:guid]}/spaces/#{cc_space[:guid]}"]])
    end

    context 'deletes a space quota space' do
      before do
        expect(get_json('/space_quotas_view_model')['items']['items'].length).to eq(1)
      end

      it 'deletes a space quota space' do
        expect { delete_space_quota_space }.to change { get_json('/spaces_view_model')['items']['items'][0][11] }.from(cc_space_quota_definition[:name]).to(nil)
      end
    end

    context 'sets a space quota for space' do
      let(:insert_second_quota_definition) { true }
      before do
        expect(get_json('/space_quotas_view_model')['items']['items'].length).to eq(2)
      end

      it 'sets a space quota for space' do
        expect { create_space_quota_space }.to change { get_json('/spaces_view_model')['items']['items'][0][11] }.from(cc_space_quota_definition[:name]).to(cc_space_quota_definition2[:name])
      end
    end
  end

  context 'manage space role' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/space_roles_view_model')['items']['items'].length).to eq(3)
    end

    def delete_space_role
      response = delete_request("/spaces/#{cc_space[:guid]}/#{cc_space_auditor[:role_guid]}/auditors/#{cc_user[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/spaces/#{cc_space[:guid]}/#{cc_space_auditor[:role_guid]}/auditors/#{cc_user[:guid]}"]])
    end

    it 'has user name and space roles request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/space_roles_view_model']], true)
    end

    it 'deletes a space role' do
      expect { delete_space_role }.to change { get_json('/space_roles_view_model')['items']['items'].length }.from(3).to(2)
    end
  end

  context 'manage stack' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/stacks_view_model')['items']['items'].length).to eq(1)
    end

    def delete_stack
      response = delete_request("/stacks/#{cc_stack[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/stacks/#{cc_stack[:guid]}"]])
    end

    def delete_stack_annotation
      response = delete_request("/stacks/#{cc_stack[:guid]}/metadata/annotations/#{cc_stack_annotation[:key]}?prefix=#{cc_stack_annotation[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/stacks/#{cc_stack[:guid]}/metadata/annotations/#{cc_stack_annotation[:key]}?prefix=#{cc_stack_annotation[:key_prefix]}"]], true)
    end

    def delete_stack_label
      response = delete_request("/stacks/#{cc_stack[:guid]}/metadata/labels/#{cc_stack_label[:key_name]}?prefix=#{cc_stack_label[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/stacks/#{cc_stack[:guid]}/metadata/labels/#{cc_stack_label[:key_name]}?prefix=#{cc_stack_label[:key_prefix]}"]], true)
    end

    it 'has user name and stacks request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/stacks_view_model']], true)
    end

    it 'deletes a stack' do
      expect { delete_stack }.to change { get_json('/stacks_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes a stack annotation' do
      expect { delete_stack_annotation }.to change { get_json("/stacks_view_model/#{cc_stack[:guid]}")['annotations'].length }.from(1).to(0)
    end

    it 'deletes a stack label' do
      expect { delete_stack_label }.to change { get_json("/stacks_view_model/#{cc_stack[:guid]}")['labels'].length }.from(1).to(0)
    end
  end

  context 'manage staging security group space' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/staging_security_groups_spaces_view_model')['items']['items'].length).to eq(1)
    end

    def delete_staging_security_group_space
      response = delete_request("/staging_security_groups/#{cc_security_group[:guid]}/#{cc_space[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/staging_security_groups/#{cc_security_group[:guid]}/#{cc_space[:guid]}"]])
    end

    it 'has user name and staging security groups spaces request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/staging_security_groups_spaces_view_model']], true)
    end

    it 'deletes a staging security group space' do
      expect { delete_staging_security_group_space }.to change { get_json('/staging_security_groups_spaces_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage task' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/tasks_view_model')['items']['items'].length).to eq(1)
    end

    def cancel_task
      response = delete_request("/tasks/#{cc_task[:guid]}/cancel")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/tasks/#{cc_task[:guid]}/cancel"]])
    end

    def delete_task_annotation
      response = delete_request("/tasks/#{cc_task[:guid]}/metadata/annotations/#{cc_task_annotation[:key]}?prefix=#{cc_task_annotation[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/tasks/#{cc_task[:guid]}/metadata/annotations/#{cc_task_annotation[:key]}?prefix=#{cc_task_annotation[:key_prefix]}"]], true)
    end

    def delete_task_label
      response = delete_request("/tasks/#{cc_task[:guid]}/metadata/labels/#{cc_task_label[:key_name]}?prefix=#{cc_task_label[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/tasks/#{cc_task[:guid]}/metadata/labels/#{cc_task_label[:key_name]}?prefix=#{cc_task_label[:key_prefix]}"]], true)
    end

    it 'has user name and tasks request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/tasks_view_model']], true)
    end

    it 'cancels a task' do
      expect { cancel_task }.to change { get_json('/tasks_view_model')['items']['items'][0][3] }.from(cc_task[:state]).to('FAILED')
    end

    it 'deletes a task annotation' do
      expect { delete_task_annotation }.to change { get_json("/tasks_view_model/#{cc_task[:guid]}")['annotations'].length }.from(1).to(0)
    end

    it 'deletes a task label' do
      expect { delete_task_label }.to change { get_json("/tasks_view_model/#{cc_task[:guid]}")['labels'].length }.from(1).to(0)
    end
  end

  context 'manage user' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/users_view_model')['items']['items'].length).to eq(1)
    end

    def activate_user
      response = put_request("/users/#{uaa_user[:id]}", '{"active":true}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/users/#{uaa_user[:id]}; body = {\"active\":true}"]], true)
    end

    def deactivate_user
      response = put_request("/users/#{uaa_user[:id]}", '{"active":false}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/users/#{uaa_user[:id]}; body = {\"active\":false}"]], true)
    end

    def verify_user
      response = put_request("/users/#{uaa_user[:id]}", '{"verified":true}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/users/#{uaa_user[:id]}; body = {\"verified\":true}"]], true)
    end

    def unverify_user
      response = put_request("/users/#{uaa_user[:id]}", '{"verified":false}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/users/#{uaa_user[:id]}; body = {\"verified\":false}"]], true)
    end

    def unlock_user
      response = put_request("/users/#{uaa_user[:id]}/status", '{"locked":false}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/users/#{uaa_user[:id]}/status; body = {\"locked\":false}"]], true)
    end

    def require_password_change_user
      response = put_request("/users/#{uaa_user[:id]}/status", '{"passwordChangeRequired":true}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/users/#{uaa_user[:id]}/status; body = {\"passwordChangeRequired\":true}"]], true)
    end

    def revoke_tokens
      response = delete_request("/users/#{uaa_user[:id]}/tokens")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/users/#{uaa_user[:id]}/tokens"]])
    end

    def delete_user
      response = delete_request("/users/#{uaa_user[:id]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/users/#{uaa_user[:id]}"]])
    end

    def delete_user_annotation
      response = delete_request("/users/#{cc_user[:guid]}/metadata/annotations/#{cc_user_annotation[:key]}?prefix=#{cc_user_annotation[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/users/#{cc_user[:guid]}/metadata/annotations/#{cc_user_annotation[:key]}?prefix=#{cc_user_annotation[:key_prefix]}"]], true)
    end

    def delete_user_label
      response = delete_request("/users/#{cc_user[:guid]}/metadata/labels/#{cc_user_label[:key_name]}?prefix=#{cc_user_label[:key_prefix]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/users/#{cc_user[:guid]}/metadata/labels/#{cc_user_label[:key_name]}?prefix=#{cc_user_label[:key_prefix]}"]], true)
    end

    it 'has user name and users request in the log file' do
      verify_sys_log_entries([['authenticated', 'role admin, authorized true'], ['get', '/users_view_model']], true)
    end

    it 'activates a user' do
      deactivate_user
      expect { activate_user }.to change { get_json('/users_view_model')['items']['items'][0][14] }.from(false).to(true)
    end

    it 'deactivates a user' do
      activate_user
      expect { deactivate_user }.to change { get_json('/users_view_model')['items']['items'][0][14] }.from(true).to(false)
    end

    it 'verifies a user' do
      unverify_user
      expect { verify_user }.to change { get_json('/users_view_model')['items']['items'][0][15] }.from(false).to(true)
    end

    it 'unverifies a user' do
      verify_user
      expect { unverify_user }.to change { get_json('/users_view_model')['items']['items'][0][15] }.from(true).to(false)
    end

    it 'unlocks a user' do
      # No database modification to verify the change actually worked
      unlock_user
    end

    it 'requires password change for a user' do
      expect { require_password_change_user }.to change { get_json('/users_view_model')['items']['items'][0][9] }.from(false).to(true)
    end

    it 'revokes tokens' do
      expect { revoke_tokens }.to change { get_json('/revocable_tokens_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes a user' do
      expect { delete_user }.to change { get_json('/users_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes a user annotation' do
      expect { delete_user_annotation }.to change { get_json("/users_view_model/#{cc_user[:guid]}")['annotations'].length }.from(1).to(0)
    end

    it 'deletes a user label' do
      expect { delete_user_label }.to change { get_json("/users_view_model/#{cc_user[:guid]}")['labels'].length }.from(1).to(0)
    end
  end

  context 'retrieves and validates' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    shared_examples 'retrieves view_model' do
      let(:retrieved) { get_json(path) }
      it 'retrieves' do
        expect(retrieved).to_not be(nil)
        expect(retrieved['recordsTotal']).to eq(view_model_source.length)
        expect(retrieved['recordsFiltered']).to eq(view_model_source.length)
        outer_items = retrieved['items']
        expect(outer_items).to_not be(nil)
        expect(outer_items['connected']).to eq(true)
        inner_items = outer_items['items']
        expect(inner_items).to_not be(nil)

        view_model_source.each do |view_model|
          expect(Yajl::Parser.parse(Yajl::Encoder.encode(inner_items))).to include(Yajl::Parser.parse(Yajl::Encoder.encode(view_model)))
        end
      end
    end

    shared_examples 'retrieves view_model detail' do
      let(:retrieved) { get_json(path) }
      it 'retrieves' do
        expect(Yajl::Parser.parse(Yajl::Encoder.encode(view_model_source))).to eq(Yajl::Parser.parse(Yajl::Encoder.encode(retrieved)))
      end
    end

    shared_examples 'application_instances' do
      context 'application_instances_view_model' do
        let(:event_type)        { 'app' }
        let(:path)              { '/application_instances_view_model' }
        let(:view_model_source) { view_models_application_instances }
        it_behaves_like('retrieves view_model')
      end

      context 'application_instances_view_model detail' do
        let(:path)              { "/application_instances_view_model/#{cc_app[:guid]}/#{cc_app_instance_index}" }
        let(:view_model_source) { view_models_application_instances_detail }
        it_behaves_like('retrieves view_model detail')
      end
    end

    context 'doppler cell' do
      let(:application_instance_source) { :doppler_cell }
      it_behaves_like('application_instances')
    end

    context 'doppler dea' do
      it_behaves_like('application_instances')
    end

    shared_examples 'applications' do
      context 'applications_view_model' do
        let(:event_type)        { 'app' }
        let(:path)              { '/applications_view_model' }
        let(:view_model_source) { view_models_applications }
        it_behaves_like('retrieves view_model')
      end

      context 'applications_view_model detail' do
        let(:path)              { "/applications_view_model/#{cc_app[:guid]}" }
        let(:view_model_source) { view_models_applications_detail }
        it_behaves_like('retrieves view_model detail')
      end
    end

    context 'doppler cell' do
      let(:application_instance_source) { :doppler_cell }
      it_behaves_like('applications')
    end

    context 'doppler dea' do
      it_behaves_like('applications')
    end

    context 'approvals_view_model' do
      let(:path)              { '/approvals_view_model' }
      let(:view_model_source) { view_models_approvals }
      it_behaves_like('retrieves view_model')
    end

    context 'approvals_view_model detail' do
      let(:path)              { "/approvals_view_model/#{uaa_approval[:user_id]}/#{uaa_approval[:client_id]}/#{uaa_approval[:scope]}" }
      let(:view_model_source) { view_models_approvals_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'buildpacks_view_model' do
      let(:path)              { '/buildpacks_view_model' }
      let(:view_model_source) { view_models_buildpacks }
      it_behaves_like('retrieves view_model')
    end

    context 'buildpacks_view_model detail' do
      let(:path)              { "/buildpacks_view_model/#{cc_buildpack[:guid]}" }
      let(:view_model_source) { view_models_buildpacks_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'cells_view_model' do
      let(:application_instance_source) { :doppler_cell }
      let(:path)                        { '/cells_view_model' }
      let(:view_model_source)           { view_models_cells }
      it_behaves_like('retrieves view_model')
    end

    context 'cells_view_model detail' do
      let(:application_instance_source) { :doppler_cell }
      let(:path)                        { "/cells_view_model/#{rep_envelope.ip}:#{rep_envelope.index}" }
      let(:view_model_source)           { view_models_cells_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'clients_view_model' do
      let(:event_type)        { 'service_dashboard_client' }
      let(:path)              { '/clients_view_model' }
      let(:view_model_source) { view_models_clients }
      it_behaves_like('retrieves view_model')
    end

    context 'clients_view_model detail' do
      let(:path)              { "/clients_view_model/#{uaa_client[:client_id]}" }
      let(:view_model_source) { view_models_clients_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'cloud_controllers_view_model' do
      let(:path)              { '/cloud_controllers_view_model' }
      let(:view_model_source) { view_models_cloud_controllers }
      it_behaves_like('retrieves view_model')
    end

    context 'cloud_controllers_view_model detail' do
      let(:path)              { "/cloud_controllers_view_model/#{nats_cloud_controller['host']}" }
      let(:view_model_source) { view_models_cloud_controllers_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'components_view_model' do
      let(:path)              { '/components_view_model' }
      let(:view_model_source) { view_models_components }
      it_behaves_like('retrieves view_model')
    end

    context 'components_view_model detail' do
      let(:path)              { "/components_view_model/#{nats_cloud_controller['host']}" }
      let(:view_model_source) { view_models_components_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'current_statistics' do
      let(:retrieved) { get_json('/current_statistics') }

      context 'doppler cell' do
        let(:application_instance_source) { :doppler_cell }
        it 'retrieves' do
          expect(retrieved).to include('apps'              => 1,
                                       'cells'             => 1,
                                       'deas'              => 0,
                                       'organizations'     => 1,
                                       'running_instances' => cc_process[:instances],
                                       'spaces'            => 1,
                                       'total_instances'   => cc_process[:instances],
                                       'users'             => 1)
        end
      end

      context 'doppler dea' do
        it 'retrieves' do
          expect(retrieved).to include('apps'              => 1,
                                       'cells'             => 0,
                                       'deas'              => 1,
                                       'organizations'     => 1,
                                       'running_instances' => cc_process[:instances],
                                       'spaces'            => 1,
                                       'total_instances'   => cc_process[:instances],
                                       'users'             => 1)
        end
      end
    end

    context 'deas_view_model' do
      let(:path)              { '/deas_view_model' }
      let(:view_model_source) { view_models_deas }
      it_behaves_like('retrieves view_model')
    end

    context 'deas_view_model_detail' do
      let(:path)              { "/deas_view_model/#{dea_envelope.ip}:#{dea_envelope.index}" }
      let(:view_model_source) { view_models_deas_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'domains_view_model' do
      let(:path)              { '/domains_view_model' }
      let(:view_model_source) { view_models_domains }
      it_behaves_like('retrieves view_model')
    end

    context 'domains_view_model detail' do
      let(:path)              { "/domains_view_model/#{cc_domain[:guid]}/false" }
      let(:view_model_source) { view_models_domains_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'download' do
      let(:response) { get_response("/download?path=#{log_file_displayed}") }
      it 'retrieves' do
        body = response.body
        expect(body).to eq(log_file_displayed_contents)
      end
    end

    context 'environment_groups_view_model' do
      let(:path)              { '/environment_groups_view_model' }
      let(:view_model_source) { view_models_environment_groups }
      it_behaves_like('retrieves view_model')
    end

    context 'environment_groups_view_model detail' do
      let(:path)              { "/environment_groups_view_model/#{cc_env_group[:name]}" }
      let(:view_model_source) { view_models_environment_groups_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'events_view_model' do
      let(:path)              { '/events_view_model' }
      let(:view_model_source) { view_models_events }
      it_behaves_like('retrieves view_model')
    end

    context 'events_view_model detail' do
      let(:path)              { "/events_view_model/#{cc_event_space[:guid]}" }
      let(:view_model_source) { view_models_events_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'feature_flags_view_model' do
      let(:path)              { '/feature_flags_view_model' }
      let(:view_model_source) { view_models_feature_flags }
      it_behaves_like('retrieves view_model')
    end

    context 'feature_flags_view_model detail' do
      let(:path)              { "/feature_flags_view_model/#{cc_feature_flag[:name]}" }
      let(:view_model_source) { view_models_feature_flags_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'gateways_view_model' do
      let(:path)              { '/gateways_view_model' }
      let(:view_model_source) { view_models_gateways }
      it_behaves_like('retrieves view_model')
    end

    context 'gateways_view_model detail' do
      let(:path)              { "/gateways_view_model/#{nats_provisioner['type'].sub('-Provisioner', '')}" }
      let(:view_model_source) { view_models_gateways_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'group_members_view_model' do
      let(:path)              { '/group_members_view_model' }
      let(:view_model_source) { view_models_group_members }
      it_behaves_like('retrieves view_model')
    end

    context 'group_members_view_model detail' do
      let(:path)              { "/group_members_view_model/#{uaa_group[:id]}/#{uaa_user[:id]}" }
      let(:view_model_source) { view_models_group_members_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'groups_view_model' do
      let(:path)              { '/groups_view_model' }
      let(:view_model_source) { view_models_groups }
      it_behaves_like('retrieves view_model')
    end

    context 'groups_view_model detail' do
      let(:path)              { "/groups_view_model/#{uaa_group[:id]}" }
      let(:view_model_source) { view_models_groups_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'health_managers_view_model' do
      let(:path)              { '/health_managers_view_model' }
      let(:view_model_source) { view_models_health_managers }
      it_behaves_like('retrieves view_model')
    end

    context 'health_managers_view_model detail' do
      let(:path) { "/health_managers_view_model/#{analyzer_envelope.ip}:#{analyzer_envelope.index}" }
      let(:view_model_source) { view_models_health_managers_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'identity_providers_view_model' do
      let(:path)              { '/identity_providers_view_model' }
      let(:view_model_source) { view_models_identity_providers }
      it_behaves_like('retrieves view_model')
    end

    context 'identity_providers_view_model detail' do
      let(:path)              { "/identity_providers_view_model/#{uaa_identity_provider[:id]}" }
      let(:view_model_source) { view_models_identity_providers_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'identity_zones_view_model' do
      let(:path)              { '/identity_zones_view_model' }
      let(:view_model_source) { view_models_identity_zones }
      it_behaves_like('retrieves view_model')
    end

    context 'identity_zones_view_model detail' do
      let(:path)              { "/identity_zones_view_model/#{uaa_identity_zone[:id]}" }
      let(:view_model_source) { view_models_identity_zones_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'isolation_segments_view_model' do
      let(:path)              { '/isolation_segments_view_model' }
      let(:view_model_source) { view_models_isolation_segments }
      it_behaves_like('retrieves view_model')
    end

    context 'isolation_segments_view_model detail' do
      let(:path)              { "/isolation_segments_view_model/#{cc_isolation_segment[:guid]}" }
      let(:view_model_source) { view_models_isolation_segments_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'log' do
      let(:retrieved) { get_json("/log?path=#{log_file_displayed}", true) }
      it 'retrieves' do
        expect(retrieved).to include('data'      => log_file_displayed_contents,
                                     'file_size' => log_file_displayed_contents_length,
                                     'page_size' => log_file_page_size,
                                     'path'      => log_file_displayed,
                                     'read_size' => log_file_displayed_contents_length,
                                     'start'     => 0)
      end
    end

    context 'logs_view_model' do
      let(:path)              { '/logs_view_model' }
      let(:view_model_source) { view_models_logs(log_file_displayed, log_file_displayed_contents_length, log_file_displayed_modified_milliseconds) }
      it_behaves_like('retrieves view_model')
    end

    context 'mfa_providers_view_model' do
      let(:path)              { '/mfa_providers_view_model' }
      let(:view_model_source) { view_models_mfa_providers }
      it_behaves_like('retrieves view_model')
    end

    context 'mfa_providers_view_model detail' do
      let(:path)              { "/mfa_providers_view_model/#{uaa_mfa_provider[:id]}" }
      let(:view_model_source) { view_models_mfa_providers_detail }
      it_behaves_like('retrieves view_model detail')
    end

    shared_examples 'organizations' do
      context 'organizations_view_model' do
        let(:event_type)        { 'organization' }
        let(:path)              { '/organizations_view_model' }
        let(:view_model_source) { view_models_organizations }
        it_behaves_like('retrieves view_model')
      end

      context 'organizations_view_model detail' do
        let(:path)              { "/organizations_view_model/#{cc_organization[:guid]}" }
        let(:view_model_source) { view_models_organizations_detail }
        it_behaves_like('retrieves view_model detail')
      end
    end

    context 'doppler cell' do
      let(:application_instance_source) { :doppler_cell }
      it_behaves_like('organizations')
    end

    context 'doppler dea' do
      it_behaves_like('organizations')
    end

    context 'organizations_isolation_segments_view_model' do
      let(:path)              { '/organizations_isolation_segments_view_model' }
      let(:view_model_source) { view_models_organizations_isolation_segments }
      it_behaves_like('retrieves view_model')
    end

    context 'organizations_isolation_segments_view_model detail' do
      let(:path)              { "/organizations_isolation_segments_view_model/#{cc_organization[:guid]}/#{cc_isolation_segment[:guid]}" }
      let(:view_model_source) { view_models_organizations_isolation_segments_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'organization_roles_view_model' do
      let(:path)              { '/organization_roles_view_model' }
      let(:view_model_source) { view_models_organization_roles }
      it_behaves_like('retrieves view_model')
    end

    context 'organization_roles_view_model detail' do
      let(:path)              { "/organization_roles_view_model/#{cc_organization[:guid]}/#{cc_organization_auditor[:role_guid]}/auditors/#{cc_user[:guid]}" }
      let(:view_model_source) { view_models_organization_roles_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'quotas_view_model' do
      let(:path)              { '/quotas_view_model' }
      let(:view_model_source) { view_models_quotas }
      it_behaves_like('retrieves view_model')
    end

    context 'quotas_view_model detail' do
      let(:path)              { "/quotas_view_model/#{cc_quota_definition[:guid]}" }
      let(:view_model_source) { view_models_quotas_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'revocable_tokens_view_model' do
      let(:path)              { '/revocable_tokens_view_model' }
      let(:view_model_source) { view_models_revocable_tokens }
      it_behaves_like('retrieves view_model')
    end

    context 'revocable_tokens_view_model detail' do
      let(:path)              { "/revocable_tokens_view_model/#{uaa_revocable_token[:token_id]}" }
      let(:view_model_source) { view_models_revocable_tokens_detail }
      it_behaves_like('retrieves view_model detail')
    end

    shared_examples 'routers_view_model' do
      let(:path)              { '/routers_view_model' }
      let(:view_model_source) { view_models_routers }
      it_behaves_like('retrieves view_model')
    end

    shared_examples 'routers_view_model detail' do
      let(:view_model_source) { view_models_routers_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'doppler routers_view_model' do
      let(:router_source) { :doppler_router }
      it_behaves_like('routers_view_model')
    end

    context 'doppler routers_view_model detail' do
      let(:router_source) { :doppler_router }
      let(:path)          { "/routers_view_model/#{gorouter_envelope.ip}:#{gorouter_envelope.index}" }
      it_behaves_like('routers_view_model detail')
    end

    context 'varz routers_view_model' do
      it_behaves_like('routers_view_model')
    end

    context 'varz routers_view_model detail' do
      let(:path) { "/routers_view_model/#{nats_router['host']}" }
      it_behaves_like('routers_view_model detail')
    end

    context 'route_bindings_view_model' do
      let(:path)              { '/route_bindings_view_model' }
      let(:view_model_source) { view_models_route_bindings }
      it_behaves_like('retrieves view_model')
    end

    context 'route_bindings_view_model detail' do
      let(:path)              { "/route_bindings_view_model/#{cc_route_binding[:guid]}" }
      let(:view_model_source) { view_models_route_bindings_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'route_mappings_view_model' do
      let(:path)              { '/route_mappings_view_model' }
      let(:view_model_source) { view_models_route_mappings }
      it_behaves_like('retrieves view_model')
    end

    context 'route_mappings_view_model detail' do
      let(:path)              { "/route_mappings_view_model/#{cc_route_mapping[:guid]}/#{cc_route[:guid]}" }
      let(:view_model_source) { view_models_route_mappings_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'routes_view_model' do
      let(:event_type)        { 'route' }
      let(:path)              { '/routes_view_model' }
      let(:view_model_source) { view_models_routes }
      it_behaves_like('retrieves view_model')
    end

    context 'routes_view_model detail' do
      let(:path)              { "/routes_view_model/#{cc_route[:guid]}" }
      let(:view_model_source) { view_models_routes_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'security_groups_spaces_view_model' do
      let(:path)              { '/security_groups_spaces_view_model' }
      let(:view_model_source) { view_models_security_groups_spaces }
      it_behaves_like('retrieves view_model')
    end

    context 'security_groups_spaces_view_model detail' do
      let(:path)              { "/security_groups_spaces_view_model/#{cc_security_group[:guid]}/#{cc_space[:guid]}" }
      let(:view_model_source) { view_models_security_groups_spaces_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'security_groups_view_model' do
      let(:path)              { '/security_groups_view_model' }
      let(:view_model_source) { view_models_security_groups }
      it_behaves_like('retrieves view_model')
    end

    context 'security_groups_view_model detail' do
      let(:path)              { "/security_groups_view_model/#{cc_security_group[:guid]}" }
      let(:view_model_source) { view_models_security_groups_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'service_bindings_view_model' do
      let(:event_type)        { 'service_binding' }
      let(:path)              { '/service_bindings_view_model' }
      let(:view_model_source) { view_models_service_bindings }
      it_behaves_like('retrieves view_model')
    end

    context 'service_bindings_view_model detail' do
      let(:path)              { "/service_bindings_view_model/#{cc_service_binding[:guid]}" }
      let(:view_model_source) { view_models_service_bindings_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'service_brokers_view_model' do
      let(:event_type)        { 'service_broker' }
      let(:path)              { '/service_brokers_view_model' }
      let(:view_model_source) { view_models_service_brokers }
      it_behaves_like('retrieves view_model')
    end

    context 'service_brokers_view_model detail' do
      let(:path)              { "/service_brokers_view_model/#{cc_service_broker[:guid]}" }
      let(:view_model_source) { view_models_service_brokers_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'service_instances_view_model' do
      let(:event_type)        { 'service_instance' }
      let(:path)              { '/service_instances_view_model' }
      let(:view_model_source) { view_models_service_instances }
      it_behaves_like('retrieves view_model')
    end

    context 'service_instances_view_model detail' do
      let(:path)              { "/service_instances_view_model/#{cc_service_instance[:guid]}/true" }
      let(:view_model_source) { view_models_service_instances_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'service_keys_view_model' do
      let(:event_type)        { 'service_key' }
      let(:path)              { '/service_keys_view_model' }
      let(:view_model_source) { view_models_service_keys }
      it_behaves_like('retrieves view_model')
    end

    context 'service_keys_view_model detail' do
      let(:path)              { "/service_keys_view_model/#{cc_service_key[:guid]}" }
      let(:view_model_source) { view_models_service_keys_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'service_plans_view_model' do
      let(:event_type)        { 'service_plan' }
      let(:path)              { '/service_plans_view_model' }
      let(:view_model_source) { view_models_service_plans }
      it_behaves_like('retrieves view_model')
    end

    context 'service_plans_view_model detail' do
      let(:path)              { "/service_plans_view_model/#{cc_service_plan[:guid]}" }
      let(:view_model_source) { view_models_service_plans_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'service_plan_visibilities_view_model' do
      let(:event_type)        { 'service_plan_visibility' }
      let(:path)              { '/service_plan_visibilities_view_model' }
      let(:view_model_source) { view_models_service_plan_visibilities }
      it_behaves_like('retrieves view_model')
    end

    context 'service_plan_visibilities_view_model detail' do
      let(:path)              { "/service_plan_visibilities_view_model/#{cc_service_plan_visibility[:guid]}/#{cc_service_plan[:guid]}/#{cc_organization[:guid]}" }
      let(:view_model_source) { view_models_service_plan_visibilities_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'service_providers_view_model' do
      let(:path)              { '/service_providers_view_model' }
      let(:view_model_source) { view_models_service_providers }
      it_behaves_like('retrieves view_model')
    end

    context 'service_providers_view_model detail' do
      let(:path)              { "/service_providers_view_model/#{uaa_service_provider[:id]}" }
      let(:view_model_source) { view_models_service_providers_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'services_view_model' do
      let(:event_type)        { 'service' }
      let(:path)              { '/services_view_model' }
      let(:view_model_source) { view_models_services }
      it_behaves_like('retrieves view_model')
    end

    context 'services_view_model detail' do
      let(:path)              { "/services_view_model/#{cc_service[:guid]}" }
      let(:view_model_source) { view_models_services_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'settings' do
      let(:retrieved) { get_json('/settings') }
      it 'retrieves' do
        expect(retrieved).to eq('admin'                => true,
                                'api_version'          => cc_info_api_version,
                                'build'                => cc_info_build,
                                'cloud_controller_uri' => cloud_controller_uri,
                                'name'                 => cc_info_name,
                                'osbapi_version'       => cc_info_osbapi_version,
                                'table_height'         => table_height,
                                'table_page_size'      => table_page_size,
                                'uaa_version'          => uaa_info_app_version,
                                'user'                 => LoginHelper::LOGIN_ADMIN)
      end
    end

    context 'shared_service_instances_view_model' do
      let(:path)              { '/shared_service_instances_view_model' }
      let(:view_model_source) { view_models_shared_service_instances }
      it_behaves_like('retrieves view_model')
    end

    context 'shared_service_instances_view_model detail' do
      let(:path)              { "/shared_service_instances_view_model/#{cc_service_instance[:guid]}/#{cc_space[:guid]}" }
      let(:view_model_source) { view_models_shared_service_instances_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'space_quotas_view_model' do
      let(:path)              { '/space_quotas_view_model' }
      let(:view_model_source) { view_models_space_quotas }
      it_behaves_like('retrieves view_model')
    end

    context 'space_quotas_view_model detail' do
      let(:path)              { "/space_quotas_view_model/#{cc_space_quota_definition[:guid]}" }
      let(:view_model_source) { view_models_space_quotas_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'space_roles_view_model' do
      let(:path)              { '/space_roles_view_model' }
      let(:view_model_source) { view_models_space_roles }
      it_behaves_like('retrieves view_model')
    end

    context 'space_roles_view_model detail' do
      let(:path)              { "/space_roles_view_model/#{cc_space[:guid]}/#{cc_space_auditor[:role_guid]}/auditors/#{cc_user[:guid]}" }
      let(:view_model_source) { view_models_space_roles_detail }
      it_behaves_like('retrieves view_model detail')
    end

    shared_examples 'spaces' do
      context 'spaces_view_model' do
        let(:path)              { '/spaces_view_model' }
        let(:view_model_source) { view_models_spaces }
        it_behaves_like('retrieves view_model')
      end

      context 'spaces_view_model detail' do
        let(:path)              { "/spaces_view_model/#{cc_space[:guid]}" }
        let(:view_model_source) { view_models_spaces_detail }
        it_behaves_like('retrieves view_model detail')
      end
    end

    context 'doppler cell' do
      let(:application_instance_source) { :doppler_cell }
      it_behaves_like('spaces')
    end

    context 'doppler dea' do
      it_behaves_like('spaces')
    end

    context 'stacks_view_model' do
      let(:path)              { '/stacks_view_model' }
      let(:view_model_source) { view_models_stacks }
      it_behaves_like('retrieves view_model')
    end

    context 'stacks_view_model detail' do
      let(:path)              { "/stacks_view_model/#{cc_stack[:guid]}" }
      let(:view_model_source) { view_models_stacks_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'staging_security_groups_spaces_view_model' do
      let(:path)              { '/staging_security_groups_spaces_view_model' }
      let(:view_model_source) { view_models_staging_security_groups_spaces }
      it_behaves_like('retrieves view_model')
    end

    context 'staging_security_groups_spaces_view_model detail' do
      let(:path)              { "/staging_security_groups_spaces_view_model/#{cc_security_group[:guid]}/#{cc_space[:guid]}" }
      let(:view_model_source) { view_models_staging_security_groups_spaces_detail }
      it_behaves_like('retrieves view_model detail')
    end

    shared_examples 'stats_view_model' do
      let(:path)                        { '/stats_view_model' }
      let(:timestamp)                   { retrieved['items']['items'][0][9]['timestamp'] } # We have to copy the timestamp from the result since it is variable
      let(:view_model_source)           { view_models_stats(timestamp) }
      it_behaves_like('retrieves view_model')
    end

    context 'doppler cell' do
      let(:application_instance_source) { :doppler_cell }
      it_behaves_like('stats_view_model')
    end

    context 'doppler dea' do
      it_behaves_like('stats_view_model')
    end

    context 'tasks_view_model' do
      let(:path)              { '/tasks_view_model' }
      let(:view_model_source) { view_models_tasks }
      it_behaves_like('retrieves view_model')
    end

    context 'tasks_view_model detail' do
      let(:path)              { "/tasks_view_model/#{cc_task[:guid]}" }
      let(:view_model_source) { view_models_tasks_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'users_view_model' do
      let(:path)              { '/users_view_model' }
      let(:view_model_source) { view_models_users }
      it_behaves_like('retrieves view_model')
    end

    context 'users_view_model detail' do
      let(:path)              { "/users_view_model/#{cc_user[:guid]}" }
      let(:view_model_source) { view_models_users_detail }
      it_behaves_like('retrieves view_model detail')
    end
  end
end
