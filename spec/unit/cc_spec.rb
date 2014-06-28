require 'logger'
require_relative '../spec_helper'

describe AdminUI::CC do
  let(:log_file) { '/tmp/admin_ui.log' }
  let(:logger) { Logger.new(log_file) }
  let(:config) do
    AdminUI::Config.load(:cloud_controller_uri   => 'http://api.localhost',
                         :db_uri                       => 'sqlite:///tmp/store.db',
                         :uaa_admin_credentials  => { :password => 'c1oudc0w', :username => 'admin' })
  end
  let(:client) { AdminUI::CCRestClient.new(config, logger) }
  let(:cc) { AdminUI::CC.new(config, logger, client) }

  before do
    AdminUI::Config.any_instance.stub(:validate)
  end

  after do
    Process.wait(Process.spawn({}, "rm -fr #{ log_file }"))
  end

  context 'No backend connected' do

    def verify_disconnected_items(result)
      expect(result).to include('connected' => false, 'items' => [])
    end

    it 'returns zero applications as expected' do
      verify_disconnected_items(cc.applications)
    end

    it 'returns nil application count as expected' do
      expect(cc.applications_count).to be_nil
    end

    it 'returns nil application running instances as expected' do
      expect(cc.applications_running_instances).to be_nil
    end

    it 'returns nil application totals instances as expected' do
      expect(cc.applications_total_instances).to be_nil
    end

    it 'returns zero organizations as expected' do
      verify_disconnected_items(cc.organizations)
    end

    it 'returns zero quotas as expected' do
      verify_disconnected_items(cc.quota_definitions)
    end

    it 'returns zero routes as expected' do
      verify_disconnected_items(cc.routes)
    end

    it 'returns nil organizations count as expected' do
      expect(cc.organizations_count).to be_nil
    end

    it 'returns zero services as expected' do
      verify_disconnected_items(cc.services)
    end

    it 'returns zero service_bindings as expected' do
      verify_disconnected_items(cc.service_bindings)
    end

    it 'returns zero service_brokers as expected' do
      verify_disconnected_items(cc.service_brokers)
    end

    it 'returns zero service_instances as expected' do
      verify_disconnected_items(cc.service_instances)
    end

    it 'returns zero service_plans as expected' do
      verify_disconnected_items(cc.service_plans)
    end

    it 'returns zero spaces as expected' do
      verify_disconnected_items(cc.spaces)
    end

    it 'returns zero spaces_auditors as expected' do
      verify_disconnected_items(cc.spaces_auditors)
    end

    it 'returns nil spaces count as expected' do
      expect(cc.spaces_count).to be_nil
    end

    it 'returns zero spaces_developers as expected' do
      verify_disconnected_items(cc.spaces_developers)
    end

    it 'returns zero spaces_managers as expected' do
      verify_disconnected_items(cc.spaces_managers)
    end

    it 'returns zero users as expected' do
      verify_disconnected_items(cc.users)
    end

    it 'returns nil users count as expected' do
      expect(cc.users_count).to be_nil
    end
  end
end
