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

    @nats = IBM::AdminUI::NATS.new(logger,
                                   IBM::AdminUI::EMail.new(logger))
  end

  after do
    cleanup_files_pid = Process.spawn({}, "rm -fr #{ data_file } #{ log_file }")
    Process.wait(cleanup_files_pid)
  end

  context 'No backend connected' do
    it 'returns zero items as expected' do
      items = @nats.get

      items.should eq('connected' => false, 'items' => {}, 'notified' => {})
    end
  end
end
