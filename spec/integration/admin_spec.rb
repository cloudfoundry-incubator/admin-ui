require_relative '../spec_helper'

describe AdminUI::Admin, :type => :integration do
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
      if line =~ /\[ admin \] : \[ /
        operations_msgs.each do | op_msg |
          op  = op_msg[0]
          msg = op_msg[1]
          esmsg = msg
          esmsg = Regexp.escape(msg) if escapes
          if line =~ /\[ admin \] : \[ #{ op } \] : #{ esmsg }/
            found_match += 1
            break
          end
        end
      end
    end
    expect(found_match).to be >= operations_msgs.length
  end

  def check_ok_response(response)
    expect(response.is_a?(Net::HTTPOK)).to be_true
  end

  def check_notfound_response(response)
    expect(response.is_a?(Net::HTTPNotFound)).to be_true
    expect(response.body).to eq('Page Not Found')
  end

  def get_json(path, escapes = false)
    response = get_response(path)

    body = response.body
    expect(body).to_not be_nil
    verify_sys_log_entries([['get', "#{ path }"]], escapes)
    JSON.parse(body)
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

  def put_request(path, body)
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
      # Make sure the original application status is STARTED
      expect(get_json('/applications_view_model')['items']['items'][0][2]).to eq('STARTED')
    end

    def stop_app
      response = put_request('/applications/application1', '{"state":"STOPPED"}')
      expect(response.is_a?(Net::HTTPNoContent)).to be_true
      verify_sys_log_entries([['put', '/applications/application1; body = {"state":"STOPPED"}']], true)
    end

    def start_app
      response = put_request('/applications/application1', '{"state":"STARTED"}')
      expect(response.is_a?(Net::HTTPNoContent)).to be_true
      verify_sys_log_entries([['put', '/applications/application1; body = {"state":"STARTED"}']], true)
    end

    def delete_app
      response = delete_request('/applications/application1')
      expect(response.is_a?(Net::HTTPNoContent)).to be_true
      verify_sys_log_entries([['delete', '/applications/application1']])
    end

    it 'has user name and applications in the log file' do
      verify_sys_log_entries([['authenticated', 'is admin? true'], ['get', '/applications']], true)
    end

    it 'stops a running application' do
      expect { stop_app }.to change { get_json('/applications_view_model')['items']['items'][0][2] }.from('STARTED').to('STOPPED')
    end

    it 'starts a stopped application' do
      stop_app
      expect { start_app }.to change { get_json('/applications_view_model')['items']['items'][0][2] }.from('STOPPED').to('STARTED')
    end

    it 'deletes an application' do
      expect { delete_app }.to change { get_json('/applications_view_model')['items']['items'][0][2] }.from('STARTED').to(nil)
    end
  end

  context 'manage organization' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      # Make sure there is an organization
      expect(get_json('/organizations_view_model')['items']['items'].length).to eq(1)
    end

    def create_org
      response = post_request('/organizations', "{\"name\":\"#{ cc_organization2[:name] }\"}")
      expect(response.is_a?(Net::HTTPNoContent)).to be_true
      verify_sys_log_entries([['post', "/organizations; body = {\"name\":\"#{ cc_organization2[:name] }\"}"]], true)
    end

    def delete_org
      response = delete_request('/organizations/organization1')
      expect(response.is_a?(Net::HTTPNoContent)).to be_true
      verify_sys_log_entries([['delete', '/organizations/organization1']], true)
    end

    def set_quota
      response = put_request('/organizations/organization1', '{"quota_definition_guid":"quota2"}')
      expect(response.is_a?(Net::HTTPNoContent)).to be_true
      verify_sys_log_entries([['put', '/organizations/organization1; body = {"quota_definition_guid":"quota2"}']], true)
    end

    it 'has user name and organizations request in the log file' do
      verify_sys_log_entries([['get', '/organizations']])
    end

    it 'creates an organization' do
      expect { create_org }.to change { get_json('/organizations_view_model')['items']['items'].length }.from(1).to(2)
      expect(get_json('/organizations_view_model', false)['items']['items'][1][1]).to eq(cc_organization2[:name])
    end

    def suspend_org
      response = put_request('/organizations/organization1', '{"status":"suspended"}')
      expect(response.is_a?(Net::HTTPNoContent)).to be_true
      verify_sys_log_entries([['put', '/organizations/organization1; body = {"status":"suspended"}']], true)
    end

    def activate_org
      response = put_request('/organizations/organization1', '{"status":"active"}')
      expect(response.is_a?(Net::HTTPNoContent)).to be_true
      verify_sys_log_entries([['put', '/organizations/organization1; body = {"status":"active"}']], true)
    end

    it 'deletes an organization' do
      expect { delete_org }.to change { get_json('/organizations_view_model')['items']['items'].length }.from(1).to(0)
    end

    context 'sets the specific quota for organization' do
      let(:insert_second_quota_definition) { true }
      it 'sets the specific quota for organization' do
        expect { set_quota }.to change { get_json('/organizations_view_model')['items']['items'][0][7] }.from('test_quota_1').to('test_quota_2')
      end
    end

    it 'activates the organization' do
      suspend_org
      expect { activate_org }.to change { get_json('/organizations_view_model')['items']['items'][0][2] }.from('suspended').to('active')
    end

    it 'suspends the organization' do
      expect { suspend_org }.to change { get_json('/organizations_view_model')['items']['items'][0][2] }.from('active').to('suspended')
    end
  end

  context 'manage route' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      # Make sure there is a route
      expect(get_json('/routes_view_model')['items']['items'].length).to eq(1)
    end

    def delete_route
      response = delete_request('/routes/route1')
      expect(response.is_a?(Net::HTTPNoContent)).to be_true
      verify_sys_log_entries([['delete', '/routes/route1']], true)
    end

    it 'has user name and routes request in the log file' do
      verify_sys_log_entries([['authenticated', 'is admin? true'], ['get', '/routes']], true)
    end

    it 'deletes the specific route' do
      expect { delete_route }.to change { get_json('/routes_view_model')['items']['items'].length }.from(1).to(0)
    end
  end

  context 'manage service plan' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    def make_service_plan_private
      response = put_request('/service_plans/service_plan1', '{"public": false }')
      expect(response.is_a?(Net::HTTPNoContent)).to be_true
      verify_sys_log_entries([['put', '/service_plans/service_plan1; body = {"public": false }']], true)
    end

    def make_service_plan_public
      response = put_request('/service_plans/service_plan1', '{"public": true }')
      expect(response.is_a?(Net::HTTPNoContent)).to be_true
      verify_sys_log_entries([['put', '/service_plans/service_plan1; body = {"public": true }']], true)
    end

    it 'make service plans private and back to public' do
      expect { make_service_plan_private }.to change { get_json('/service_plans_view_model')['items']['items'][0][5].to_s }.from('true').to('false')
      make_service_plan_public
      expect { get_json('/service_plans_view_model')['items']['items'][0][5] }.to be_true
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
          expect(JSON.parse(inner_items.to_json)).to include(JSON.parse(view_model.to_json))
        end
      end
    end

    context 'applications_view_model' do
      let(:path)              { '/applications_view_model' }
      let(:view_model_source) { view_models_applications }
      it_behaves_like('retrieves view_model')
    end

    context 'cloud_controllers_view_model' do
      let(:path)              { '/cloud_controllers_view_model' }
      let(:view_model_source) { view_models_cloud_controllers }
      it_behaves_like('retrieves view_model')
    end

    context 'components_view_model' do
      let(:path)              { '/components_view_model' }
      let(:view_model_source) { view_models_components }
      it_behaves_like('retrieves view_model')
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

    context 'developers_view_model' do
      let(:path)              { '/developers_view_model' }
      let(:view_model_source) { view_models_developers }
      it_behaves_like('retrieves view_model')
    end

    context 'download' do
      let(:response) { get_response("/download?path=#{ log_file_displayed }") }
      it 'retrieves' do
        body = response.body
        expect(body).to eq(log_file_displayed_contents)
      end
    end

    context 'gateways_view_model' do
      let(:path)              { '/gateways_view_model' }
      let(:view_model_source) { view_models_gateways }
      it_behaves_like('retrieves view_model')
    end

    context 'health_managers_view_model' do
      let(:path)              { '/health_managers_view_model' }
      let(:view_model_source) { view_models_health_managers }
      it_behaves_like('retrieves view_model')
    end

    context 'log' do
      let(:retrieved) { get_json("/log?path=#{ log_file_displayed }", true) }
      it 'retrieves' do
        expect(retrieved['data']).to eq(log_file_displayed_contents)
        expect(retrieved['file_size']).to eq(log_file_displayed_contents_length)
        expect(retrieved['page_size']).to eq(log_file_page_size)
        expect(retrieved['path']).to eq(log_file_displayed)
        expect(retrieved['read_size']).to eq(log_file_displayed_contents_length)
        expect(retrieved['start']).to eq(0)
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

    context 'quotas_view_model' do
      let(:path)              { '/quotas_view_model' }
      let(:view_model_source) { view_models_quotas }
      it_behaves_like('retrieves view_model')
    end

    context 'routers_view_model' do
      let(:path)              { '/routers_view_model' }
      let(:view_model_source) { view_models_routers }
      it_behaves_like('retrieves view_model')
    end

    context 'routes_view_model' do
      let(:path)              { '/routes_view_model' }
      let(:view_model_source) { view_models_routes }
      it_behaves_like('retrieves view_model')
    end

    context 'services_instances_view_model' do
      let(:path)              { '/service_instances_view_model' }
      let(:view_model_source) { view_models_service_instances }
      it_behaves_like('retrieves view_model')
    end

    context 'service_plans_view_model' do
      let(:path)              { '/service_plans_view_model' }
      let(:view_model_source) { view_models_service_plans }
      it_behaves_like('retrieves view_model')
    end

    context 'spaces_view_model' do
      let(:path)              { '/spaces_view_model' }
      let(:view_model_source) { view_models_spaces }
      it_behaves_like('retrieves view_model')
    end

    context 'stats_view_model' do
      let(:path)              { '/stats_view_model' }
      let(:timestamp)         { retrieved['items']['items'][0][8]['timestamp'] } # We have to copy the timestamp from the result since it is variable
      let(:view_model_source) { view_models_stats(timestamp) }
      it_behaves_like('retrieves view_model')
    end
  end

  context 'tasks' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    it 'creates DEA, retrieves all tasks and retrieves specific status' do
      request = Net::HTTP::Post.new('/deas')
      request['Cookie']         = cookie
      request['Content-Length'] = 0

      response = http.request(request)
      expect(response.is_a?(Net::HTTPOK)).to be_true

      body = response.body
      expect(body).to_not be_nil

      json = JSON.parse(body)

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
        if out['type'] == 'out'
          found_out = true
          expect(out['text'].start_with?('Creating new DEA')).to be_true
          expect(out['time']).to be > 0
          break
        end
      end
      expect(found_out).to be_true
    end
  end
end
