require 'logger'
require_relative '../spec_helper'

describe AdminUI::VARZ do
  include ThreadHelper

  let(:data_file) { '/tmp/admin_ui_data.json' }
  let(:db_file)   { '/tmp/admin_ui_store.db' }
  let(:db_uri)    { "sqlite://#{db_file}" }
  let(:log_file) { '/tmp/admin_ui.log' }
  let(:logger) { Logger.new(log_file) }
  let(:config) do
    AdminUI::Config.load(component_connection_retries:        50,
                         cloud_controller_discovery_interval: 3,
                         db_uri:                              db_uri,
                         nats_discovery_interval:             3,
                         varz_discovery_interval:             3,
                         data_file:                           data_file,
                         mbus:                                'nats://nats:c1oudc0w@localhost:14222',
                         monitored_components:                [],
                         nats_discovery_timeout:              1)
  end
  let(:email) { AdminUI::EMail.new(config, logger) }
  let(:nats) { AdminUI::NATS.new(config, logger, email) }
  let(:varz) { AdminUI::VARZ.new(config, logger, nats, true) }

  before do
    AdminUI::Config.any_instance.stub(:validate)
  end

  after do
    kill_threads

    Process.wait(Process.spawn({}, "rm -fr #{data_file} #{db_file} #{log_file}"))
  end

  context 'No backend connected' do
    it 'returns zero components as expected' do
      expect(varz.components).to eq('connected' => false, 'items' => [])
    end

    it 'returns zero cloud_controllers as expected' do
      expect(varz.cloud_controllers).to eq('connected' => false, 'items' => [])
    end

    it 'returns zero deas as expected' do
      expect(varz.deas).to eq('connected' => false, 'items' => [])
    end

    it 'returns nil deas_count as expected' do
      expect(varz.deas_count).to be_nil
    end

    it 'returns zero health_managers as expected' do
      expect(varz.health_managers).to eq('connected' => false, 'items' => [])
    end

    it 'returns zero gateways as expected' do
      expect(varz.gateways).to eq('connected' => false, 'items' => [])
    end

    it 'returns zero routers as expected' do
      expect(varz.routers).to eq('connected' => false, 'items' => [])
    end
  end
end
