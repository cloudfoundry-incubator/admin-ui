require 'webrick'
require_relative '../spec_helper'

describe IBM::AdminUI::Admin, :type => :integration do
  include CCHelper
  include NATSHelper
  include VARZHelper

  let(:host) { 'localhost' }
  let(:port) { 8071 }

  let(:data_file) { '/tmp/admin_ui_data.json' }
  let(:log_file) { '/tmp/admin_ui.log' }
  let(:stats_file) { '/tmp/admin_ui_stats.json' }

  let(:admin_user) { 'admin' }
  let(:admin_password) { 'admin_passw0rd' }

  let(:user) { 'user' }
  let(:user_password) { 'user_passw0rd' }

  let(:cloud_controller_uri) { 'http://api.localhost' }
  let(:config) do
    {
      :cloud_controller_uri   => cloud_controller_uri,
      :data_file              => data_file,
      :log_file               => log_file,
      :log_files              => [],
      :mbus                   => 'nats://nats:c1oudc0w@localhost:14222',
      :monitored_components   => ['ALL'],
      :port                   => port,
      :receiver_emails        => [],
      :sender_email           => { :account => 'system@localhost', :server => 'localhost' },
      :stats_file             => stats_file,
      :uaa_admin_credentials  => { :password => 'c1oudc0w', :username => 'admin' },
      :ui_admin_credentials   => { :password => admin_password, :username => admin_user },
      :ui_credentials         => { :password => user_password, :username => user }
    }
  end

  before do
    cc_stub(IBM::AdminUI::Config.load(config))
    nats_stub
    varz_stub

    ::WEBrick::Log.any_instance.stub(:log)

    Thread.new do
      IBM::AdminUI::Admin.new(config).start
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
    Process.wait(Process.spawn({}, "rm -fr #{ data_file } #{ log_file } #{ stats_file }"))
  end

  context 'retrieves and validates' do
    def create_http
      Net::HTTP.new(host, port)
    end

    def login_and_return_cookie(http)
      request = Net::HTTP::Post.new("/login?username=#{ admin_user }&password=#{ admin_password }")
      request['Content-Length'] = 0

      response = http.request(request)
      fail_with('Unexpected http status code') unless response.is_a?(Net::HTTPSeeOther)

      location = response['location']
      expect(location).to eq("http://#{ host }:#{ port }/application.html?user=#{ admin_user }")

      cookie = response['Set-Cookie']
      expect(cookie).to_not be_nil

      cookie
    end

    def get_json(path)
      request = Net::HTTP::Get.new(path)
      request['Cookie'] = cookie

      response = http.request(request)
      fail_with('Unexpected http status code') unless response.is_a?(Net::HTTPOK)

      body = response.body
      expect(body).to_not be_nil

      JSON.parse(body)
    end

    let(:http)   { create_http }
    let(:cookie) { login_and_return_cookie(http) }

    shared_examples 'retrieves cc entity/metadata record' do
      let(:retrieved) { get_json(path) }
      it 'retrieves' do
        expect(retrieved['connected']).to eq(true)
        items = retrieved['items']

        resources = cc_source['resources']

        expect(items.length).to be(resources.length)

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

        expect(items.length).to be(count)
      end
    end

    shared_examples 'retrieves varz record' do
      let(:retrieved) { get_json(path) }
      it 'retrieves' do
        expect(retrieved['connected']).to eq(true)
        items = retrieved['items']

        expect(items.length).to be(1)

        expect(items).to include('connected' => true,
                                 'data'      => varz_data,
                                 'name'      => varz_name,
                                 'uri'       => varz_uri)
      end
    end

    it_behaves_like('retrieves cc entity/metadata record') do
      let(:path)      { '/applications' }
      let(:cc_source) { cc_apps }
    end

    it_behaves_like('retrieves varz record') do
      let(:varz_data) { varz_cloud_controller }
      let(:varz_name) { nats_cloud_controller['host'] }
      let(:path)      { '/cloud_controllers' }
      let(:varz_uri)  { nats_cloud_controller_varz }
    end

    context 'multiple varz components' do
      let(:retrieved) { get_json('/components') }
      it 'retrieves' do
        expect(retrieved['connected']).to eq(true)
        items = retrieved['items']

        expect(items.length).to be(5)

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

    context 'current_statistics' do
      let(:retrieved) { get_json('/current_statistics') }
      it 'retrieves' do
        expect(retrieved).to include('apps'              => cc_apps['resources'].length,
                                     'deas'              => 1,
                                     'organizations'     => cc_organizations['resources'].length,
                                     'running_instances' => cc_apps['resources'].length,
                                     'spaces'            => cc_spaces['resources'].length,
                                     'total_instances'   => cc_apps['resources'].length,
                                     'users'             => uaa_users['resources'].length)
      end
    end

    it_behaves_like('retrieves varz record') do
      let(:varz_data) { varz_dea }
      let(:varz_name) { nats_dea['host'] }
      let(:path)      { '/deas' }
      let(:varz_uri)  { nats_dea_varz }
    end

    it_behaves_like('retrieves varz record') do
      let(:varz_data) { varz_provisioner }
      let(:varz_name) { nats_provisioner['type'].sub('-Provisioner', '') }
      let(:path)      { '/gateways' }
      let(:varz_uri)  { nats_provisioner_varz }
    end

    it_behaves_like('retrieves varz record') do
      let(:varz_data) { varz_health_manager }
      let(:varz_name) { nats_health_manager['host'] }
      let(:path)      { '/health_managers' }
      let(:varz_uri)  { nats_health_manager_varz }
    end

    it_behaves_like('retrieves cc entity/metadata record') do
      let(:path)      { '/organizations' }
      let(:cc_source) { cc_organizations }
    end

    it_behaves_like('retrieves varz record') do
      let(:varz_data) { varz_router }
      let(:varz_name) { nats_router['host'] }
      let(:path)      { '/routers' }
      let(:varz_uri)  { nats_router_varz }
    end

    it_behaves_like('retrieves cc entity/metadata record') do
      let(:path)      { '/spaces' }
      let(:cc_source) { cc_spaces }
    end

    it_behaves_like('retrieves cc space/user record') do
      let(:path)       { '/spaces_auditors' }
      let(:type_space) { 'audited_spaces' }
    end

    it_behaves_like('retrieves cc space/user record') do
      let(:path)       { '/spaces_developers' }
      let(:type_space) { 'spaces' }
    end

    it_behaves_like('retrieves cc space/user record') do
      let(:path)       { '/spaces_managers' }
      let(:type_space) { 'managed_spaces' }
    end

    context 'users' do
      let(:retrieved) { get_json('/users') }
      it 'retrieves' do
        expect(retrieved['connected']).to eq(true)
        items = retrieved['items']

        resources = uaa_users['resources']

        expect(items.length).to be(resources.length)

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
end
