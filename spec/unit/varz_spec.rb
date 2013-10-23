require 'logger'
require_relative '../spec_helper'

describe IBM::AdminUI::NATS do
  let(:data_file) { '/tmp/admin_ui_data.json' }
  let(:log_file) { '/tmp/admin_ui.log' }

  before do
    logger = Logger.new(log_file)
    logger.level = Logger::DEBUG

    config =
    {
      :component_connection_retries => 50,
      :data_file                    => data_file,
      :mbus                         => 'nats://nats:c1oudc0w@localhost:14222',
      :monitored_components         => [],
      :nats_discovery_timeout       => 1,
    }

    IBM::AdminUI::Config.load(config)

    nats = IBM::AdminUI::NATS.new(logger, IBM::AdminUI::EMail.new(logger))

    @varz = IBM::AdminUI::VARZ.new(logger, nats)
  end

  after do
    cleanup_files_pid = Process.spawn({}, "rm -fr #{ data_file } #{ log_file }")
    Process.wait(cleanup_files_pid)
  end

  context 'No backend connected' do
    it 'returns zero components as expected' do
      components = @varz.components

      components.should eq('connected' => false, 'items' => [])
    end

    it 'returns zero cloud_controllers as expected' do
      cloud_controllers = @varz.cloud_controllers

      cloud_controllers.should eq('connected' => false, 'items' => [])
    end

    it 'returns zero deas as expected' do
      deas = @varz.deas

      deas.should eq('connected' => false, 'items' => [])
    end

    it 'returns zero deas_count as expected' do
      deas_count = @varz.deas_count

      deas_count.should eq(0)
    end

    it 'returns zero health_managers as expected' do
      health_managers = @varz.health_managers

      health_managers.should eq('connected' => false, 'items' => [])
    end

    it 'returns zero gateways as expected' do
      gateways = @varz.gateways

      gateways.should eq('connected' => false, 'items' => [])
    end

    it 'returns zero routers as expected' do
      routers = @varz.routers

      routers.should eq('connected' => false, 'items' => [])
    end
  end
end
