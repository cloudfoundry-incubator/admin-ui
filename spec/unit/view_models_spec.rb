require 'logger'
require_relative '../spec_helper'

describe AdminUI::CC do
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
    AdminUI::Config.load(:ccdb_uri               => ccdb_uri,
                         :cloud_controller_uri   => 'http://api.localhost',
                         :data_file              => data_file,
                         :db_uri                 => db_uri,
                         :log_files              => [log_file],
                         :mbus                   => 'nats://nats:c1oudc0w@localhost:14222',
                         :uaadb_uri              => uaadb_uri,
                         :uaa_client             => { :id => 'id', :secret => 'secret' })
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
    Process.wait(Process.spawn({}, "rm -fr #{ ccdb_file } #{ data_file } #{ db_file } #{ log_file } #{ uaadb_file }"))
  end

  context 'No backend connected' do

    def verify_disconnected_items(result)
      expect(result).to include(:connected => false, :items => [])
    end

    it 'returns zero applications as expected' do
      verify_disconnected_items(view_models.applications)
    end

    it 'returns zero cloud_controllers as expected' do
      verify_disconnected_items(view_models.cloud_controllers)
    end

    it 'returns zero components as expected' do
      verify_disconnected_items(view_models.components)
    end

    it 'returns zero deas as expected' do
      verify_disconnected_items(view_models.deas)
    end

    it 'returns zero developers as expected' do
      verify_disconnected_items(view_models.developers)
    end

    it 'returns zero domains as expected' do
      verify_disconnected_items(view_models.domains)
    end

    it 'returns zero gateways as expected' do
      verify_disconnected_items(view_models.gateways)
    end

    it 'returns zero health_managers as expected' do
      verify_disconnected_items(view_models.health_managers)
    end

    it 'returns zero organizations as expected' do
      verify_disconnected_items(view_models.organizations)
    end

    it 'returns zero quotas as expected' do
      verify_disconnected_items(view_models.quotas)
    end

    it 'returns zero routers as expected' do
      verify_disconnected_items(view_models.routers)
    end

    it 'returns zero routes as expected' do
      verify_disconnected_items(view_models.routes)
    end

    it 'returns zero service_instances as expected' do
      verify_disconnected_items(view_models.service_instances)
    end

    it 'returns zero service_plans as expected' do
      verify_disconnected_items(view_models.service_plans)
    end

    it 'returns zero spaces as expected' do
      verify_disconnected_items(view_models.spaces)
    end
  end

  context 'No backend required' do

    def verify_connected_one_item(result)
      expect(result).to include(:connected => true)
      expect(result[:items].length).to be(1)
    end

    def verify_connected_zero_items(result)
      expect(result).to include(:connected => true, :items => [])
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
