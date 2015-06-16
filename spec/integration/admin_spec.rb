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
      cookie   = response['Set-Cookie'] unless response['Set-Cookie'].nil?

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
      next unless line =~ /\[ admin \] : \[ /
      operations_msgs.each do |op_msg|
        op  = op_msg[0]
        msg = op_msg[1]
        esmsg = msg
        esmsg = Regexp.escape(msg) if escapes
        next unless line =~ /\[ admin \] : \[ #{op} \] : #{esmsg}/
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
    verify_sys_log_entries([['get', "#{path}"]], escapes)
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
    let(:cookie) {}
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
      expect(get_json('/applications_view_model')['items']['items'][0][3]).to eq('STARTED')
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

    it 'has user name and applications in the log file' do
      verify_sys_log_entries([['authenticated', 'is admin? true'], ['get', '/applications_view_model']], true)
    end

    it 'stops a running application' do
      expect { stop_app }.to change { get_json('/applications_view_model')['items']['items'][0][3] }.from('STARTED').to('STOPPED')
    end

    it 'starts a stopped application' do
      stop_app
      expect { start_app }.to change { get_json('/applications_view_model')['items']['items'][0][3] }.from('STOPPED').to('STARTED')
    end

    it 'restages stopped application' do
      restage_app
    end

    it 'deletes an application' do
      expect { delete_app }.to change { get_json('/applications_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes an application recursive' do
      expect { delete_app_recursive }.to change { get_json('/applications_view_model')['items']['items'].length }.from(1).to(0)
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
      verify_sys_log_entries([['authenticated', 'is admin? true'], ['get', '/application_instances_view_model']], true)
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

    it 'has user name and buildpack request in the log file' do
      verify_sys_log_entries([['authenticated', 'is admin? true'], ['get', '/buildpacks_view_model']], true)
    end

    it 'disables buildpack' do
      expect { make_buildpack_disabled }.to change { get_json('/buildpacks_view_model')['items']['items'][0][6].to_s }.from('true').to('false')
    end

    it 'enables buildpack' do
      make_buildpack_disabled
      expect { make_buildpack_enabled }.to change { get_json('/buildpacks_view_model')['items']['items'][0][6].to_s }.from('false').to('true')
    end

    it 'locks buildpack' do
      expect { make_buildpack_locked }.to change { get_json('/buildpacks_view_model')['items']['items'][0][7].to_s }.from('false').to('true')
    end

    it 'unlocks buildpack' do
      make_buildpack_locked
      expect { make_buildpack_unlocked }.to change { get_json('/buildpacks_view_model')['items']['items'][0][7].to_s }.from('true').to('false')
    end

    it 'deletes a buildpack' do
      expect { delete_buildpack }.to change { get_json('/buildpacks_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage domain' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/domains_view_model')['items']['items'].length).to eq(1)
    end

    def delete_domain
      response = delete_request("/domains/#{cc_domain[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/domains/#{cc_domain[:guid]}"]])
    end

    def delete_domain_recursive
      response = delete_request("/domains/#{cc_domain[:guid]}?recursive=true")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/domains/#{cc_domain[:guid]}?recursive=true"]], true)
    end

    it 'has user name and domains request in the log file' do
      verify_sys_log_entries([['authenticated', 'is admin? true'], ['get', '/domains_view_model']], true)
    end

    it 'deletes a domain' do
      expect { delete_domain }.to change { get_json('/domains_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes a domain recursive' do
      expect { delete_domain_recursive }.to change { get_json('/domains_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage organization' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/organizations_view_model')['items']['items'].length).to eq(1)
    end

    def create_org
      response = post_request('/organizations', "{\"name\":\"#{cc_organization2[:name]}\"}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['post', "/organizations; body = {\"name\":\"#{cc_organization2[:name]}\"}"]], true)
    end

    def set_quota
      response = put_request("/organizations/#{cc_organization[:guid]}", "{\"quota_definition_guid\":\"#{cc_quota_definition2[:guid]}\"}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/organizations/#{cc_organization[:guid]}; body = {\"quota_definition_guid\":\"#{cc_quota_definition2[:guid]}\"}"]], true)
    end

    def activate_org
      response = put_request("/organizations/#{cc_organization[:guid]}", '{"status":"active"}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/organizations/#{cc_organization[:guid]}; body = {\"status\":\"active\"}"]], true)
    end

    def suspend_org
      response = put_request("/organizations/#{cc_organization[:guid]}", '{"status":"suspended"}')
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['put', "/organizations/#{cc_organization[:guid]}; body = {\"status\":\"suspended\"}"]], true)
    end

    def delete_org
      response = delete_request("/organizations/#{cc_organization[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/organizations/#{cc_organization[:guid]}"]])
    end

    def delete_org_recursive
      response = delete_request("/organizations/#{cc_organization[:guid]}?recursive=true")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/organizations/#{cc_organization[:guid]}?recursive=true"]], true)
    end

    it 'has user name and organizations request in the log file' do
      verify_sys_log_entries([['get', '/organizations_view_model']])
    end

    it 'creates an organization' do
      expect { create_org }.to change { get_json('/organizations_view_model')['items']['items'].length }.from(1).to(2)
      expect(get_json('/organizations_view_model', false)['items']['items'][1][1]).to eq(cc_organization2[:name])
    end

    context 'sets the quota for organization' do
      let(:insert_second_quota_definition) { true }
      it 'sets the quota for organization' do
        expect { set_quota }.to change { get_json('/organizations_view_model')['items']['items'][0][10] }.from(cc_quota_definition[:name]).to(cc_quota_definition2[:name])
      end
    end

    it 'activates the organization' do
      suspend_org
      expect { activate_org }.to change { get_json('/organizations_view_model')['items']['items'][0][3] }.from('suspended').to('active')
    end

    it 'suspends the organization' do
      expect { suspend_org }.to change { get_json('/organizations_view_model')['items']['items'][0][3] }.from('active').to('suspended')
    end

    it 'deletes an organization' do
      expect { delete_org }.to change { get_json('/organizations_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes an organization recursive' do
      expect { delete_org_recursive }.to change { get_json('/organizations_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage organization role' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/organization_roles_view_model')['items']['items'].length).to eq(4)
    end

    def delete_organization_role
      response = delete_request("/organizations/#{cc_organization[:guid]}/auditors/#{cc_user[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/organizations/#{cc_organization[:guid]}/auditors/#{cc_user[:guid]}"]])
    end

    it 'has user name and organization roles request in the log file' do
      verify_sys_log_entries([['authenticated', 'is admin? true'], ['get', '/organization_roles_view_model']], true)
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

    def delete_quota
      response = delete_request("/quota_definitions/#{cc_quota_definition[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/quota_definitions/#{cc_quota_definition[:guid]}"]])
    end

    it 'has user name and quotas request in the log file' do
      verify_sys_log_entries([['authenticated', 'is admin? true'], ['get', '/quotas_view_model']], true)
    end

    it 'deletes a quota' do
      expect { delete_quota }.to change { get_json('/quotas_view_model')['items']['items'].length }.from(1).to(0)
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

    it 'has user name and routes request in the log file' do
      verify_sys_log_entries([['authenticated', 'is admin? true'], ['get', '/routes_view_model']], true)
    end

    it 'deletes a route' do
      expect { delete_route }.to change { get_json('/routes_view_model')['items']['items'].length }.from(1).to(0)
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

    it 'has user name and services request in the log file' do
      verify_sys_log_entries([['authenticated', 'is admin? true'], ['get', '/services_view_model']], true)
    end

    it 'deletes a service' do
      expect { delete_service }.to change { get_json('/services_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'purges a service' do
      expect { purge_service }.to change { get_json('/services_view_model')['items']['items'].length }.from(1).to(0)
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

    it 'has user name and service bindings request in the log file' do
      verify_sys_log_entries([['authenticated', 'is admin? true'], ['get', '/service_bindings_view_model']], true)
    end

    it 'deletes a service binding' do
      expect { delete_service_binding }.to change { get_json('/service_bindings_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage service broker' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/service_brokers_view_model')['items']['items'].length).to eq(1)
    end

    def delete_service_broker
      response = delete_request("/service_brokers/#{cc_service_broker[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/service_brokers/#{cc_service_broker[:guid]}"]])
    end

    it 'has user name and service brokers request in the log file' do
      verify_sys_log_entries([['authenticated', 'is admin? true'], ['get', '/service_brokers_view_model']], true)
    end

    it 'deletes a service broker' do
      expect { delete_service_broker }.to change { get_json('/service_brokers_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage service instance' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/service_instances_view_model')['items']['items'].length).to eq(1)
    end

    def delete_service_instance
      response = delete_request("/service_instances/#{cc_service_instance[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/service_instances/#{cc_service_instance[:guid]}"]])
    end

    def delete_service_instance_recursive
      response = delete_request("/service_instances/#{cc_service_instance[:guid]}?recursive=true")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/service_instances/#{cc_service_instance[:guid]}?recursive=true"]], true)
    end

    it 'has user name and service instances request in the log file' do
      verify_sys_log_entries([['authenticated', 'is admin? true'], ['get', '/service_instances_view_model']], true)
    end

    it 'deletes a service instance' do
      expect { delete_service_instance }.to change { get_json('/service_instances_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes a service instance recursive' do
      expect { delete_service_instance_recursive }.to change { get_json('/service_instances_view_model')['items']['items'].length }.from(1).to(0)
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

    it 'has user name and service keys request in the log file' do
      verify_sys_log_entries([['authenticated', 'is admin? true'], ['get', '/service_keys_view_model']], true)
    end

    it 'deletes a service key' do
      expect { delete_service_key }.to change { get_json('/service_keys_view_model')['items']['items'].length }.from(1).to(0)
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

    it 'has user name and service plan request in the log file' do
      verify_sys_log_entries([['authenticated', 'is admin? true'], ['get', '/service_plans_view_model']], true)
    end

    it 'makes service plan private' do
      expect { make_service_plan_private }.to change { get_json('/service_plans_view_model')['items']['items'][0][7].to_s }.from('true').to('false')
    end

    it 'makes service plan public' do
      make_service_plan_private
      expect { make_service_plan_public }.to change { get_json('/service_plans_view_model')['items']['items'][0][7].to_s }.from('false').to('true')
    end

    it 'deletes a service plan' do
      expect { delete_service_plan }.to change { get_json('/service_plans_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage service plan visibility' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/service_plan_visibilities_view_model')['items']['items'].length).to eq(1)
    end

    def delete_service_plan_visibility
      response = delete_request("/service_plan_visibilities/#{cc_service_plan_visibility[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/service_plan_visibilities/#{cc_service_plan_visibility[:guid]}"]])
    end

    it 'has user name and service plan visibility request in the log file' do
      verify_sys_log_entries([['authenticated', 'is admin? true'], ['get', '/service_plan_visibilities_view_model']], true)
    end

    it 'deletes a service plan visibility' do
      expect { delete_service_plan_visibility }.to change { get_json('/service_plan_visibilities_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage space' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/spaces_view_model')['items']['items'].length).to eq(1)
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

    it 'has user name and space request in the log file' do
      verify_sys_log_entries([['authenticated', 'is admin? true'], ['get', '/spaces_view_model']], true)
    end

    it 'deletes a space' do
      expect { delete_space }.to change { get_json('/spaces_view_model')['items']['items'].length }.from(1).to(0)
    end

    it 'deletes a space recursive' do
      expect { delete_space_recursive }.to change { get_json('/spaces_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage space quota' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      expect(get_json('/space_quotas_view_model')['items']['items'].length).to eq(1)
    end

    def delete_space_quota
      response = delete_request("/space_quota_definitions/#{cc_space_quota_definition[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/space_quota_definitions/#{cc_space_quota_definition[:guid]}"]])
    end

    it 'has user name and quotas request in the log file' do
      verify_sys_log_entries([['authenticated', 'is admin? true'], ['get', '/space_quotas_view_model']], true)
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
        expect { delete_space_quota_space }.to change { get_json('/spaces_view_model')['items']['items'][0][9] }.from(cc_space_quota_definition[:name]).to(nil)
      end
    end

    context 'sets a space quota for space' do
      let(:insert_second_quota_definition) { true }
      before do
        expect(get_json('/space_quotas_view_model')['items']['items'].length).to eq(2)
      end

      it 'sets a space quota for space' do
        expect { create_space_quota_space }.to change { get_json('/spaces_view_model')['items']['items'][0][9] }.from(cc_space_quota_definition[:name]).to(cc_space_quota_definition2[:name])
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
      response = delete_request("/spaces/#{cc_space[:guid]}/auditors/#{cc_user[:guid]}")
      expect(response.is_a?(Net::HTTPNoContent)).to be(true)
      verify_sys_log_entries([['delete', "/spaces/#{cc_space[:guid]}/auditors/#{cc_user[:guid]}"]])
    end

    it 'has user name and space roles request in the log file' do
      verify_sys_log_entries([['authenticated', 'is admin? true'], ['get', '/space_roles_view_model']], true)
    end

    it 'deletes a space role' do
      expect { delete_space_role }.to change { get_json('/space_roles_view_model')['items']['items'].length }.from(3).to(2)
    end
  end

  context 'retrieves and validates' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    shared_examples 'retrieves view_model' do
      let(:retrieved) { get_json(path) }
      it 'retrieves' do
        expect(retrieved).to_not be(nil)
        expect(retrieved['iTotalRecords']).to eq(view_model_source.length)
        expect(retrieved['iTotalDisplayRecords']).to eq(view_model_source.length)
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

    context 'application_instances_view_model' do
      let(:event_type)        { 'app' }
      let(:path)              { '/application_instances_view_model' }
      let(:view_model_source) { view_models_application_instances }
      it_behaves_like('retrieves view_model')
    end

    context 'application_instances_view_model detail' do
      let(:path)              { "/application_instances_view_model/#{cc_app[:guid]}/#{varz_dea_app_instance}" }
      let(:view_model_source) { view_models_application_instances_detail }
      it_behaves_like('retrieves view_model detail')
    end

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
      let(:view_model_source) { view_models_cloud_controllers_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'current_statistics' do
      let(:retrieved) { get_json('/current_statistics') }
      it 'retrieves' do
        expect(retrieved).to include('apps'              => 1,
                                     'deas'              => 1,
                                     'organizations'     => 1,
                                     'running_instances' => cc_app[:instances],
                                     'spaces'            => 1,
                                     'total_instances'   => cc_app[:instances],
                                     'users'             => 1)
      end
    end

    context 'deas_view_model' do
      let(:path)              { '/deas_view_model' }
      let(:view_model_source) { view_models_deas }
      it_behaves_like('retrieves view_model')
    end

    context 'deas_view_model detail' do
      let(:path)              { "/deas_view_model/#{nats_dea['host']}" }
      let(:view_model_source) { view_models_deas_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'domains_view_model' do
      let(:path)              { '/domains_view_model' }
      let(:view_model_source) { view_models_domains }
      it_behaves_like('retrieves view_model')
    end

    context 'domains_view_model detail' do
      let(:path)              { "/domains_view_model/#{cc_domain[:guid]}" }
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

    context 'health_managers_view_model' do
      let(:path)              { '/health_managers_view_model' }
      let(:view_model_source) { view_models_health_managers }
      it_behaves_like('retrieves view_model')
    end

    context 'health_managers_view_model detail' do
      let(:path)              { "/health_managers_view_model/#{nats_health_manager['host']}" }
      let(:view_model_source) { view_models_health_managers_detail }
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

    context 'organizations_view_model' do
      let(:path)              { '/organizations_view_model' }
      let(:view_model_source) { view_models_organizations }
      it_behaves_like('retrieves view_model')
    end

    context 'organizations_view_model detail' do
      let(:path)              { "/organizations_view_model/#{cc_organization[:guid]}" }
      let(:view_model_source) { view_models_organizations_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'organization_roles_view_model' do
      let(:path)              { '/organization_roles_view_model' }
      let(:view_model_source) { view_models_organization_roles }
      it_behaves_like('retrieves view_model')
    end

    context 'organization_roles_view_model detail' do
      let(:path)              { "/organization_roles_view_model/#{cc_organization[:guid]}/auditors/#{cc_user[:guid]}" }
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

    context 'routers_view_model' do
      let(:path)              { '/routers_view_model' }
      let(:view_model_source) { view_models_routers }
      it_behaves_like('retrieves view_model')
    end

    context 'routers_view_model detail' do
      let(:path)              { "/routers_view_model/#{nats_router['host']}" }
      let(:view_model_source) { view_models_routers_detail }
      it_behaves_like('retrieves view_model detail')
    end

    context 'routes_view_model' do
      let(:path)              { '/routes_view_model' }
      let(:view_model_source) { view_models_routes }
      it_behaves_like('retrieves view_model')
    end

    context 'routes_view_model detail' do
      let(:path)              { "/routes_view_model/#{cc_route[:guid]}" }
      let(:view_model_source) { view_models_routes_detail }
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
      let(:path)              { "/service_instances_view_model/#{cc_service_instance[:guid]}" }
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
      let(:path)              { "/service_plan_visibilities_view_model/#{cc_service_plan_visibility[:guid]}" }
      let(:view_model_source) { view_models_service_plan_visibilities_detail }
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
        expect(retrieved).to eq('admin'                  => true,
                                'build'                  => '2222',
                                'cloud_controller_uri'   => cloud_controller_uri,
                                'table_height'           => table_height,
                                'table_page_size'        => table_page_size,
                                'tasks_refresh_interval' => tasks_refresh_interval)
      end
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
      let(:path)              { "/space_roles_view_model/#{cc_space[:guid]}/auditors/#{cc_user[:guid]}" }
      let(:view_model_source) { view_models_space_roles_detail }
      it_behaves_like('retrieves view_model detail')
    end

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

    context 'stats_view_model' do
      let(:path)              { '/stats_view_model' }
      let(:timestamp)         { retrieved['items']['items'][0][8]['timestamp'] } # We have to copy the timestamp from the result since it is variable
      let(:view_model_source) { view_models_stats(timestamp) }
      it_behaves_like('retrieves view_model')
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

  context 'tasks' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    it 'creates DEA, retrieves all tasks and retrieves status' do
      request = Net::HTTP::Post.new('/deas')
      request['Cookie']         = cookie
      request['Content-Length'] = 0

      response = http.request(request)
      expect(response.is_a?(Net::HTTPOK)).to be(true)

      body = response.body
      expect(body).to_not be_nil

      json = Yajl::Parser.parse(body)

      expect(json).to include('task_id' => 0)

      tasks_view_model = get_json('/tasks_view_model')
      items = tasks_view_model['items']['items']
      expect(items.length).to eq(1)
      item = items[0]
      expect(item[0]).to_not be_nil
      expect(item[1]).to eq('RUNNING')
      expect(item[2]).to_not be_nil
      expect(item[3]).to eq(0)

      task_status = get_json('/task_status?task_id=0', true)
      expect(task_status['id']).to eq(0)
      expect(task_status['state']).to eq('RUNNING')
      expect(task_status['updated']).to be > 0
      output = task_status['output']
      found_out = false
      output.each do |out|
        next unless out['type'] == 'out'
        found_out = true
        expect(out['text'].start_with?('Creating new DEA')).to be(true)
        expect(out['time']).to be > 0
        break
      end
      expect(found_out).to be(true)
    end
  end
end
