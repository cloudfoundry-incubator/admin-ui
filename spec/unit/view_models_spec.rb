require 'logger'
require_relative '../spec_helper'

describe AdminUI::CC do
  include ThreadHelper

  let(:ccdb_file)  { '/tmp/admin_ui_ccdb.db' }
  let(:ccdb_uri)   { "sqlite://#{ ccdb_file }" }
  let(:data_file)  { '/tmp/admin_ui.data' }
  let(:db_file)    { '/tmp/admin_ui_store.db' }
  let(:db_uri)     { "sqlite://#{ db_file }" }
  let(:log_file)   { '/tmp/admin_ui.log' }
  let(:logger)     { Logger.new(log_file) }
  let(:uaadb_file) { '/tmp/admin_ui_uaadb.db' }
  let(:uaadb_uri)  { "sqlite://#{ uaadb_file }" }
  let(:config) do
    AdminUI::Config.load(ccdb_uri:             ccdb_uri,
                         cloud_controller_uri: 'http://api.localhost',
                         data_file:            data_file,
                         db_uri:               db_uri,
                         log_files:            [log_file],
                         mbus:                 'nats://nats:c1oudc0w@localhost:14222',
                         uaadb_uri:            uaadb_uri,
                         uaa_client:           { id: 'id', secret: 'secret' })
  end

  let(:client) { AdminUI::CCRestClient.new(config, logger) }
  let(:cc) { AdminUI::CC.new(config, logger, client, true) }
  let(:email) { AdminUI::EMail.new(config, logger) }
  let(:log_files) { AdminUI::LogFiles.new(config, logger) }
  let(:nats) { AdminUI::NATS.new(config, logger, email) }
  let(:tasks) { AdminUI::Tasks.new(config, logger) }
  let(:varz) { AdminUI::VARZ.new(config, logger, nats) }
  let(:stats) { AdminUI::Stats.new(config, logger, cc, varz) }
  let(:view_models) { AdminUI::ViewModels.new(config, logger, cc, log_files, stats, tasks, varz) }

  before do
    AdminUI::Config.any_instance.stub(:validate)
  end

  after do
    kill_threads

    Process.wait(Process.spawn({}, "rm -fr #{ ccdb_file } #{ data_file } #{ db_file } #{ log_file } #{ uaadb_file }"))
  end

  context 'No backend connected' do
    def verify_disconnected_items(result)
      expect(result).to include(connected: false, items: [])
    end

    it 'returns nil application as expected' do
      expect(view_models.application('bogus')).to be_nil
    end

    it 'returns nil application instance as expected' do
      expect(view_models.application('bogus', 'bogus')).to be_nil
    end

    it 'returns zero applications as expected' do
      verify_disconnected_items(view_models.applications)
    end

    it 'returns nil client as expected' do
      expect(view_models.client('bogus')).to be_nil
    end

    it 'returns zero clients as expected' do
      verify_disconnected_items(view_models.clients)
    end

    it 'returns nil cloud_controller as expected' do
      expect(view_models.cloud_controller('bogus')).to be_nil
    end

    it 'returns zero cloud_controllers as expected' do
      verify_disconnected_items(view_models.cloud_controllers)
    end

    it 'returns nil component as expected' do
      expect(view_models.component('bogus')).to be_nil
    end

    it 'returns zero components as expected' do
      verify_disconnected_items(view_models.components)
    end

    it 'returns nil dea as expected' do
      expect(view_models.dea('bogus')).to be_nil
    end

    it 'returns zero deas as expected' do
      verify_disconnected_items(view_models.deas)
    end

    it 'returns nil domain as expected' do
      expect(view_models.domain('bogus')).to be_nil
    end

    it 'returns zero domains as expected' do
      verify_disconnected_items(view_models.domains)
    end

    it 'returns nil gateway as expected' do
      expect(view_models.gateway('bogus')).to be_nil
    end

    it 'returns zero gateways as expected' do
      verify_disconnected_items(view_models.gateways)
    end

    it 'returns nil health_manager as expected' do
      expect(view_models.health_manager('bogus')).to be_nil
    end

    it 'returns zero health_managers as expected' do
      verify_disconnected_items(view_models.health_managers)
    end

    it 'returns nil organization as expected' do
      expect(view_models.organization('bogus')).to be_nil
    end

    it 'returns zero organizations as expected' do
      verify_disconnected_items(view_models.organizations)
    end

    it 'returns nil organization_role expected' do
      expect(view_models.organization_role('bogus', 'bogus', 'bogus')).to be_nil
    end

    it 'returns zero organization_roles as expected' do
      verify_disconnected_items(view_models.organization_roles)
    end

    it 'returns nil quota as expected' do
      expect(view_models.quota('bogus')).to be_nil
    end

    it 'returns zero quotas as expected' do
      verify_disconnected_items(view_models.quotas)
    end

    it 'returns nil router as expected' do
      expect(view_models.router('bogus')).to be_nil
    end

    it 'returns zero routers as expected' do
      verify_disconnected_items(view_models.routers)
    end

    it 'returns nil route as expected' do
      expect(view_models.route('bogus')).to be_nil
    end

    it 'returns zero routes as expected' do
      verify_disconnected_items(view_models.routes)
    end

    it 'returns nil service_binding as expected' do
      expect(view_models.service_binding('bogus')).to be_nil
    end

    it 'returns zero service_bindings as expected' do
      verify_disconnected_items(view_models.service_bindings)
    end

    it 'returns nil service_broker as expected' do
      expect(view_models.service_broker('bogus')).to be_nil
    end

    it 'returns zero service_brokers as expected' do
      verify_disconnected_items(view_models.service_brokers)
    end

    it 'returns nil service_instance as expected' do
      expect(view_models.service_instance('bogus')).to be_nil
    end

    it 'returns zero service_instances as expected' do
      verify_disconnected_items(view_models.service_instances)
    end

    it 'returns nil service_plan as expected' do
      expect(view_models.service_plan('bogus')).to be_nil
    end

    it 'returns zero service_plans as expected' do
      verify_disconnected_items(view_models.service_plans)
    end

    it 'returns nil service_plan_visibility as expected' do
      expect(view_models.service_plan_visibility('bogus')).to be_nil
    end

    it 'returns zero service_plan_visibilities as expected' do
      verify_disconnected_items(view_models.service_plan_visibilities)
    end

    it 'returns nil service as expected' do
      expect(view_models.service('bogus')).to be_nil
    end

    it 'returns zero services as expected' do
      verify_disconnected_items(view_models.services)
    end

    it 'returns nil space as expected' do
      expect(view_models.space('bogus')).to be_nil
    end

    it 'returns zero spaces as expected' do
      verify_disconnected_items(view_models.spaces)
    end

    it 'returns nil space_role as expected' do
      expect(view_models.space_role('bogus', 'bogus', 'bogus')).to be_nil
    end

    it 'returns zero space_roles as expected' do
      verify_disconnected_items(view_models.space_roles)
    end

    it 'returns nil user as expected' do
      expect(view_models.user('bogus')).to be_nil
    end

    it 'returns zero users as expected' do
      verify_disconnected_items(view_models.users)
    end
  end

  context 'No backend required' do
    def verify_connected_one_item(result)
      expect(result).to include(connected: true)
      expect(result[:items].length).to be(1)
    end

    def verify_connected_zero_items(result)
      expect(result).to include(connected: true, items: [])
    end

    it 'returns zero logs as expected' do
      verify_connected_one_item(view_models.logs)
    end

    it 'returns zero stats as expected' do
      verify_connected_one_item(view_models.stats)
    end

    it 'returns zero tasks as expected' do
      verify_connected_zero_items(view_models.tasks)
    end
  end
end
