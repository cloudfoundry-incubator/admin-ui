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

  def check_ok_response(response)
    expect(response.is_a?(Net::HTTPOK)).to be_true
  end

  def check_notfound_response(response)
    expect(response.is_a?(Net::HTTPNotFound)).to be_true
    expect(response.body).to eq('Page Not Found')
  end

  def get_json(path)
    response = get_response(path)

    body = response.body
    expect(body).to_not be_nil

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
      expect(get_json('/applications')['items'][0]['state']).to eq('STARTED')
    end

    def stop_app
      response = put_request('/applications/application1', '{"state":"STOPPED"}')
      expect(response.is_a?(Net::HTTPNoContent)).to be_true
    end

    def start_app
      response = put_request('/applications/application1', '{"state":"STARTED"}')
      expect(response.is_a?(Net::HTTPNoContent)).to be_true
    end

    def delete_app
      response = delete_request('/applications/application1')
      expect(response.is_a?(Net::HTTPNoContent)).to be_true
    end

    it 'stops a running application' do
      # Stub the http request to return
      cc_stopped_apps_stub(AdminUI::Config.load(config))
      expect { stop_app }.to change { get_json('/applications')['items'][0]['state'] }.from('STARTED').to('STOPPED')
    end

    it 'starts a stopped application' do
      # Stub the http request to return
      cc_apps_stop_to_start_stub(AdminUI::Config.load(config))
      stop_app

      expect { start_app }.to change { get_json('/applications')['items'][0]['state'] }.from('STOPPED').to('STARTED')
    end

    it 'deletes an application' do
      cc_empty_applications_stub(AdminUI::Config.load(config))
      expect { delete_app }.to change { get_json('/applications')['items'].length }.from(1).to(0)
    end
  end

  context 'manage organization' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      # Make sure there is an organization
      expect(get_json('/organizations')['items'].length).to eq(1)
    end

    def create_org
      response = post_request('/organizations', '{"name":"new_org"}')
      expect(response.is_a?(Net::HTTPNoContent)).to be_true
    end

    def delete_org
      response = delete_request('/organizations/organization1')
      expect(response.is_a?(Net::HTTPNoContent)).to be_true
    end

    def set_quota
      response = put_request('/organizations/organization1', '{"quota_definition_guid":"quota2"}')
      expect(response.is_a?(Net::HTTPNoContent)).to be_true
    end

    it 'creates an organization' do
      cc_multiple_organizations_stub(AdminUI::Config.load(config))
      expect { create_org }.to change { get_json('/organizations')['items'].length }.from(1).to(2)
      expect(get_json('/organizations')['items'][1]['name']).to eq('new_org')
    end

    def suspend_org
      response = put_request('/organizations/organization1', '{"status":"suspended"}')
      expect(response.is_a?(Net::HTTPNoContent)).to be_true
    end

    def activate_org
      response = put_request('/organizations/organization1', '{"status":"active"}')
      expect(response.is_a?(Net::HTTPNoContent)).to be_true
    end

    it 'deletes an organization' do
      cc_empty_organizations_stub(AdminUI::Config.load(config))
      expect { delete_org }.to change { get_json('/organizations')['items'].length }.from(1).to(0)
    end

    it 'sets the specific quota for organization' do
      cc_organization_with_different_quota_stub(AdminUI::Config.load(config))
      expect { set_quota }.to change { get_json('/organizations')['items'][0]['quota_definition_guid'] }.from('quota1').to('quota2')
    end

    it 'activates the organization' do
      cc_organizations_suspend_active_stub(AdminUI::Config.load(config))
      suspend_org

      expect { activate_org }.to change { get_json('/organizations')['items'][0]['status'] }.from('suspended').to('active')
    end

    it 'suspends the organization' do
      cc_suspended_organizations_stub(AdminUI::Config.load(config))
      expect { suspend_org }.to change { get_json('/organizations')['items'][0]['status'] }.from('active').to('suspended')
    end
  end

  context 'manage route' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    before do
      # Make sure there is a route
      expect(get_json('/routes')['items'].length).to eq(1)
    end

    def delete_route
      response = delete_request('/routes/route1')
      expect(response.is_a?(Net::HTTPNoContent)).to be_true
    end

    it 'deletes the specific route' do
      cc_empty_routes_stub(AdminUI::Config.load(config))
      expect { delete_route }.to change { get_json('/routes')['items'].length }.from(1).to(0)
    end
  end

  context 'manage service plan' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    def make_service_plan_private
      response = put_request('/service_plans/service_plan1', '{"public": false }')
      expect(response.is_a?(Net::HTTPNoContent)).to be_true
    end

    def make_service_plan_public
      response = put_request('/service_plans/service_plan1', '{"public": true }')
      expect(response.is_a?(Net::HTTPNoContent)).to be_true
    end

    it 'make service plans private and back to public' do
      # Stub the http request to return
      cc_service_plans_private_to_public_stub(AdminUI::Config.load(config))
      expect { make_service_plan_private }.to change { get_json('/service_plans')['items'][0]['public'].to_s }.from('true').to('false')
      make_service_plan_public
      expect { get_json('/service_plans')['items'][0]['public'] }.to be_true
    end
  end

  context 'retrieves and validates' do
    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    shared_examples 'retrieves cc entity/metadata record' do
      let(:retrieved) { get_json(path) }
      it 'retrieves' do
        expect(retrieved['connected']).to eq(true)
        items = retrieved['items']

        resources = cc_source['resources']

        expect(items.length).to eq(resources.length)

        resources.each do |resource|
          expect(items).to include(resource['entity'].merge(resource['metadata']))
        end
      end
    end

    shared_examples 'retrieves cc space/user record' do
      let(:retrieved) { get_json(path) }
      it 'retrieves' do
        expect(retrieved['connected']).to eq(true)
        items = retrieved['items']

        resources = cc_users_deep['resources']

        count = 0
        resources.each do |resource|
          resource['entity'][type_space].each do |space|
            count += 1
            expect(items).to include('user_guid' => resource['metadata']['guid'], 'space_guid' => space['metadata']['guid'])
          end
        end

        expect(items.length).to eq(count)
      end
    end

    shared_examples 'retrieves varz record' do
      let(:retrieved) { get_json(path) }
      it 'retrieves' do
        expect(retrieved['connected']).to eq(true)
        items = retrieved['items']

        expect(items.length).to eq(1)

        expect(items).to include('connected' => true,
                                 'data'      => varz_data,
                                 'name'      => varz_name,
                                 'uri'       => varz_uri)
      end
    end

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
          expect(AdminUI::Utils.symbolize_keys(inner_items)).to include(AdminUI::Utils.symbolize_keys(view_model))
        end
      end
    end

    context 'applications' do
      let(:path)      { '/applications' }
      let(:cc_source) { cc_started_apps }
      it_behaves_like('retrieves cc entity/metadata record')
    end

    context 'applications_view_model' do
      let(:path)              { '/applications_view_model' }
      let(:view_model_source) { view_models_applications }
      it_behaves_like('retrieves view_model')
    end

    context 'cloud_controllers' do
      let(:varz_data) { varz_cloud_controller }
      let(:varz_name) { nats_cloud_controller['host'] }
      let(:path)      { '/cloud_controllers' }
      let(:varz_uri)  { nats_cloud_controller_varz }
      it_behaves_like('retrieves varz record')
    end

    context 'cloud_controllers_view_model' do
      let(:path)              { '/cloud_controllers_view_model' }
      let(:view_model_source) { view_models_cloud_controllers }
      it_behaves_like('retrieves view_model')
    end

    context 'components' do
      let(:retrieved) { get_json('/components') }
      it 'retrieves' do
        expect(retrieved['connected']).to eq(true)
        items = retrieved['items']

        expect(items.length).to eq(5)

        expect(items).to include('connected' => true,
                                 'data'      => varz_cloud_controller,
                                 'name'      => nats_cloud_controller['host'],
                                 'uri'       => nats_cloud_controller_varz)

        expect(items).to include('connected' => true,
                                 'data'      => varz_dea,
                                 'name'      => nats_dea['host'],
                                 'uri'       => nats_dea_varz)

        expect(items).to include('connected' => true,
                                 'data'      => varz_health_manager,
                                 'name'      => nats_health_manager['host'],
                                 'uri'       => nats_health_manager_varz)

        expect(items).to include('connected' => true,
                                 'data'      => varz_router,
                                 'name'      => nats_router['host'],
                                 'uri'       => nats_router_varz)

        expect(items).to include('connected' => true,
                                 'data'      => varz_provisioner,
                                 'name'      => nats_provisioner['host'],
                                 'uri'       => nats_provisioner_varz)
      end
    end

    context 'components_view_model' do
      let(:path)              { '/components_view_model' }
      let(:view_model_source) { view_models_components }
      it_behaves_like('retrieves view_model')
    end

    context 'current_statistics' do
      let(:retrieved) { get_json('/current_statistics') }
      it 'retrieves' do
        expect(retrieved).to include('apps'              => cc_started_apps['resources'].length,
                                     'deas'              => 1,
                                     'organizations'     => cc_organizations['resources'].length,
                                     'running_instances' => cc_started_apps['resources'].length,
                                     'spaces'            => cc_spaces['resources'].length,
                                     'total_instances'   => cc_started_apps['resources'].length,
                                     'users'             => uaa_users['resources'].length)
      end
    end

    context 'deas' do
      let(:varz_data) { varz_dea }
      let(:varz_name) { nats_dea['host'] }
      let(:path)      { '/deas' }
      let(:varz_uri)  { nats_dea_varz }
      it_behaves_like('retrieves varz record')
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

    context 'gateways' do
      let(:varz_data) { varz_provisioner }
      let(:varz_name) { nats_provisioner['type'].sub('-Provisioner', '') }
      let(:path)      { '/gateways' }
      let(:varz_uri)  { nats_provisioner_varz }
      it_behaves_like('retrieves varz record')
    end

    context 'gateways_view_model' do
      let(:path)              { '/gateways_view_model' }
      let(:view_model_source) { view_models_gateways }
      it_behaves_like('retrieves view_model')
    end

    context 'health_managers' do
      let(:varz_data) { varz_health_manager }
      let(:varz_name) { nats_health_manager['host'] }
      let(:path)      { '/health_managers' }
      let(:varz_uri)  { nats_health_manager_varz }
      it_behaves_like('retrieves varz record')
    end

    context 'health_managers_view_model' do
      let(:path)              { '/health_managers_view_model' }
      let(:view_model_source) { view_models_health_managers }
      it_behaves_like('retrieves view_model')
    end

    context 'log' do
      let(:retrieved) { get_json("/log?path=#{ log_file_displayed }") }
      it 'retrieves' do
        expect(retrieved['data']).to eq(log_file_displayed_contents)
        expect(retrieved['file_size']).to eq(log_file_displayed_contents_length)
        expect(retrieved['page_size']).to eq(log_file_page_size)
        expect(retrieved['path']).to eq(log_file_displayed)
        expect(retrieved['read_size']).to eq(log_file_displayed_contents_length)
        expect(retrieved['start']).to eq(0)
      end
    end

    context 'logs' do
      let(:retrieved) { get_json('/logs') }
      it 'retrieves' do
        items = retrieved['items']
        expect(items).to_not be_nil
        expect(items.length).to eq(1)
        item = items[0]
        expect(item).to include('path' => log_file_displayed,
                                'size' => log_file_displayed_contents_length,
                                'time' => log_file_displayed_modified_milliseconds)
      end
    end

    context 'logs_view_model' do
      let(:path)              { '/logs_view_model' }
      let(:view_model_source) { view_models_logs(log_file_displayed, log_file_displayed_contents_length, log_file_displayed_modified_milliseconds) }
      it_behaves_like('retrieves view_model')
    end

    context 'organizations' do
      let(:path)      { '/organizations' }
      let(:cc_source) { cc_organizations }
      it_behaves_like('retrieves cc entity/metadata record')
    end

    context 'organizations_view_model' do
      let(:path)              { '/organizations_view_model' }
      let(:view_model_source) { view_models_organizations }
      it_behaves_like('retrieves view_model')
    end

    context 'quota_definitions' do
      let(:path)      { '/quota_definitions' }
      let(:cc_source) { cc_quota_definitions }
      it_behaves_like('retrieves cc entity/metadata record')
    end

    context 'quotas_view_model' do
      let(:path)              { '/quotas_view_model' }
      let(:view_model_source) { view_models_quotas }
      it_behaves_like('retrieves view_model')
    end

    context 'routers' do
      let(:varz_data) { varz_router }
      let(:varz_name) { nats_router['host'] }
      let(:path)      { '/routers' }
      let(:varz_uri)  { nats_router_varz }
      it_behaves_like('retrieves varz record')
    end

    context 'routers_view_model' do
      let(:path)              { '/routers_view_model' }
      let(:view_model_source) { view_models_routers }
      it_behaves_like('retrieves view_model')
    end

    context 'routes' do
      let(:path)      { '/routes' }
      let(:cc_source) { cc_routes }
      it_behaves_like('retrieves cc entity/metadata record')
    end

    context 'routes_view_model' do
      let(:path)              { '/routes_view_model' }
      let(:view_model_source) { view_models_routes }
      it_behaves_like('retrieves view_model')
    end

    context 'services' do
      let(:path)      { '/services' }
      let(:cc_source) { cc_services }
      it_behaves_like('retrieves cc entity/metadata record')
    end

    context 'service_bindings' do
      let(:path)      { '/service_bindings' }
      let(:cc_source) { cc_service_bindings }
      it_behaves_like('retrieves cc entity/metadata record')
    end

    context 'service_brokers' do
      let(:path)      { '/service_brokers' }
      let(:cc_source) { cc_service_brokers }
      it_behaves_like('retrieves cc entity/metadata record')
    end

    context 'service_instances' do
      let(:path)      { '/service_instances' }
      let(:cc_source) { cc_service_instances }
      it_behaves_like('retrieves cc entity/metadata record')
    end

    context 'services_instances_view_model' do
      let(:path)              { '/service_instances_view_model' }
      let(:view_model_source) { view_models_service_instances }
      it_behaves_like('retrieves view_model')
    end

    context 'service_plans' do
      let(:path)      { '/service_plans' }
      let(:cc_source) { cc_service_plans }
      it_behaves_like('retrieves cc entity/metadata record')
    end

    context 'service_plans_view_model' do
      let(:path)              { '/service_plans_view_model' }
      let(:view_model_source) { view_models_service_plans }
      it_behaves_like('retrieves view_model')
    end

    context 'spaces' do
      let(:path)      { '/spaces' }
      let(:cc_source) { cc_spaces }
      it_behaves_like('retrieves cc entity/metadata record')
    end

    context 'spaces_auditors' do
      let(:path)       { '/spaces_auditors' }
      let(:type_space) { 'audited_spaces' }
      it_behaves_like('retrieves cc space/user record')
    end

    context 'spaces_developers' do
      let(:path)       { '/spaces_developers' }
      let(:type_space) { 'spaces' }
      it_behaves_like('retrieves cc space/user record')
    end

    context 'spaces_managers' do
      let(:path)       { '/spaces_managers' }
      let(:type_space) { 'managed_spaces' }
      it_behaves_like('retrieves cc space/user record')
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

    context 'users' do
      let(:retrieved) { get_json('/users') }
      it 'retrieves' do
        expect(retrieved['connected']).to eq(true)
        items = retrieved['items']

        resources = uaa_users['resources']

        expect(items.length).to eq(resources.length)

        resources.each do |resource|
          authorities = []
          resource['groups'].each do |group|
            authorities.push(group['display'])
          end

          hash = { 'active'        => resource['active'],
                   'authorities'   => authorities.sort.join(', '),
                   'created'       => resource['meta']['created'],
                   'id'            => resource['id'],
                   'last_modified' => resource['meta']['lastModified'],
                   'username'      => resource['userName'],
                   'version'       => resource['meta']['version'] }
          hash['email'] = resource['emails'][0]['value'] unless resource['emails'].empty?
          hash['familyname'] = resource['name']['familyName'] unless resource['name']['familyName'].nil?
          hash['givenname'] = resource['name']['givenName'] unless resource['name']['givenName'].nil?

          expect(items).to include(hash)
        end
      end
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

      tasks = get_json('/tasks')
      items = tasks['items']
      expect(items.length).to eq(1)
      item = items[0]
      expect(item['command']).to_not be_nil
      expect(item['id']).to eq(0)
      expect(item['started']).to be > 0
      expect(item['state']).to eq('RUNNING')

      task_status = get_json('/task_status?task_id=0')
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
