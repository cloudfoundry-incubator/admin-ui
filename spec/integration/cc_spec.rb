require 'logger'
require_relative '../spec_helper'

describe AdminUI::CC, :type => :integration do
  include CCHelper

  let(:log_file) { '/tmp/admin_ui.log' }
  let(:logger) { Logger.new(log_file) }
  let(:config) do
    AdminUI::Config.load(:cloud_controller_discovery_interval => 1,
                         :cloud_controller_uri                => 'http://api.cloudfoundry',
                         :uaa_admin_credentials               => { :username => 'user', :password => 'password' })
  end
  let(:client) { AdminUI::CCRestClient.new(config, logger) }

  before do
    AdminUI::Config.any_instance.stub(:validate)
    cc_stub(config)
  end

  let(:cc) { AdminUI::CC.new(config, logger, client) }

  after do
    Thread.list.each do |thread|
      unless thread == Thread.main
        thread.kill
        thread.join
      end
    end
    Process.wait(Process.spawn({}, "rm -fr #{ log_file }"))
  end

  context 'Stubbed HTTP' do
    it 'clears the application cache' do
      cc_apps_start_to_stop_stub(config)
      expect { cc.invalidate_applications }.to change { cc.applications['items'][0]['state'] }.from('STARTED').to('STOPPED')
    end

    it 'clears the route cache' do
      cc_routes_delete_stub(config)
      expect { cc.invalidate_routes }.to change { cc.routes['items'].length }.from(1).to(0)
    end

    it 'clears the service plan cache' do
      cc_service_plans_public_to_private_stub(config)
      expect { cc.invalidate_service_plans }.to change { cc.service_plans['items'][0]['public'].to_s }.from('true').to('false')
    end

    it 'returns connected applications' do
      applications = cc.applications

      expect(applications['connected']).to eq(true)
      items = applications['items']

      resources = cc_started_apps['resources']

      expect(items.length).to be(resources.length)

      resources.each do |resource|
        expect(items).to include(resource['entity'].merge(resource['metadata']))
      end
    end

    it 'returns applications_count' do
      expect(cc.applications_count).to be(cc_started_apps['resources'].length)
    end

    it 'returns applications_running_instances' do
      expect(cc.applications_running_instances).to be(cc_started_apps['resources'].length)
    end

    it 'returns applications_total_instances' do
      expect(cc.applications_total_instances).to be(cc_started_apps['resources'].length)
    end

    it 'returns connected organizations' do
      organizations = cc.organizations

      expect(organizations['connected']).to eq(true)
      items = organizations['items']

      resources = cc_organizations['resources']

      expect(items.length).to be(resources.length)

      resources.each do |resource|
        expect(items).to include(resource['entity'].merge(resource['metadata']))
      end
    end

    it 'returns connected routes' do
      routes = cc.routes

      expect(routes['connected']).to eq(true)
      items = routes['items']

      resources = cc_routes['resources']

      expect(items.length).to be(resources.length)

      resources.each do |resource|
        expect(items).to include(resource['entity'].merge(resource['metadata']))
      end
    end

    it 'returns organizations_count' do
      expect(cc.organizations_count).to be(cc_organizations['resources'].length)
    end

    it 'returns connected services' do
      services = cc.services

      expect(services['connected']).to eq(true)
      items = services['items']

      resources = cc_services['resources']

      expect(items.length).to be(resources.length)

      resources.each do |resource|
        expect(items).to include(resource['entity'].merge(resource['metadata']))
      end
    end

    it 'returns connected service_bindings' do
      service_bindings = cc.service_bindings

      expect(service_bindings['connected']).to eq(true)
      items = service_bindings['items']

      resources = cc_service_bindings['resources']

      expect(items.length).to be(resources.length)

      resources.each do |resource|
        expect(items).to include(resource['entity'].merge(resource['metadata']))
      end
    end

    it 'returns connected service_instances' do
      service_instances = cc.service_instances

      expect(service_instances['connected']).to eq(true)
      items = service_instances['items']

      resources = cc_service_instances['resources']

      expect(items.length).to be(resources.length)

      resources.each do |resource|
        expect(items).to include(resource['entity'].merge(resource['metadata']))
      end
    end

    it 'returns connected service_plans' do
      service_plans = cc.service_plans

      expect(service_plans['connected']).to eq(true)
      items = service_plans['items']

      resources = cc_service_plans['resources']

      expect(items.length).to be(resources.length)

      resources.each do |resource|
        expect(items).to include(resource['entity'].merge(resource['metadata']))
      end
    end

    it 'returns connected spaces' do
      spaces = cc.spaces

      expect(spaces['connected']).to eq(true)
      items = spaces['items']

      resources = cc_spaces['resources']

      expect(items.length).to be(resources.length)

      resources.each do |resource|
        expect(items).to include(resource['entity'].merge(resource['metadata']))
      end
    end

    it 'returns connected spaces_auditors' do
      spaces_auditors = cc.spaces_auditors

      expect(spaces_auditors['connected']).to eq(true)
      items = spaces_auditors['items']

      resources = cc_users_deep['resources']

      count = 0
      resources.each do |resource|
        resource['entity']['audited_spaces'].each do |audited_space|
          count += 1
          expect(items).to include('user_guid' => resource['metadata']['guid'], 'space_guid' => audited_space['metadata']['guid'])
        end
      end

      expect(items.length).to be(count)
    end

    it 'returns spaces_count' do
      expect(cc.spaces_count).to be(cc_spaces['resources'].length)
    end

    it 'returns connected spaces_developers' do
      spaces_developers = cc.spaces_developers

      expect(spaces_developers['connected']).to eq(true)
      items = spaces_developers['items']

      resources = cc_users_deep['resources']

      count = 0
      resources.each do |resource|
        resource['entity']['spaces'].each do |space|
          count += 1
          expect(items).to include('user_guid' => resource['metadata']['guid'], 'space_guid' => space['metadata']['guid'])
        end
      end

      expect(items.length).to be(count)
    end

    it 'returns connected spaces_managers' do
      spaces_managers = cc.spaces_managers

      expect(spaces_managers['connected']).to eq(true)
      items = spaces_managers['items']

      resources = cc_users_deep['resources']

      count = 0
      resources.each do |resource|
        resource['entity']['managed_spaces'].each do |managed_space|
          count += 1
          expect(items).to include('user_guid' => resource['metadata']['guid'], 'space_guid' => managed_space['metadata']['guid'])
        end
      end

      expect(items.length).to be(count)

    end

    it 'returns connected users' do
      users = cc.users

      expect(users['connected']).to eq(true)
      items = users['items']

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

    it 'returns users_count' do
      expect(cc.users_count).to be(uaa_users['resources'].length)
    end
  end
end
