require 'logger'
require_relative '../spec_helper'

describe AdminUI::NATS do
  include ConfigHelper

  let(:data_file) { '/tmp/admin_ui_data.json' }
  let(:log_file)  { '/tmp/admin_ui.log' }

  let(:config) do
    AdminUI::Config.load(data_file:            data_file,
                         mbus:                 'nats://nats:c1oudc0w@localhost:14222',
                         monitored_components: [])
  end

  let(:email)              { AdminUI::EMail.new(config, logger) }
  let(:event_machine_loop) { AdminUI::EventMachineLoop.new(config, logger, true) }
  let(:logger)             { Logger.new(log_file) }
  let(:nats)               { AdminUI::NATS.new(config, logger, email, true) }

  before do
    config_stub

    event_machine_loop
  end

  after do
    nats.shutdown
    event_machine_loop.shutdown

    nats.join
    event_machine_loop.join

    Process.wait(Process.spawn({}, "rm -fr #{data_file} #{log_file}"))
  end

  context 'No backend connected' do
    it 'returns zero items as expected' do
      expect(nats.get).to eq('connected' => false, 'items' => {}, 'notified' => {})
    end
  end
end
