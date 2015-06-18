require 'logger'
require_relative '../spec_helper'

describe AdminUI::NATS do
  include ConfigHelper

  let(:data_file) { '/tmp/admin_ui_data.json' }
  let(:db_file)   { '/tmp/admin_ui_store.db' }
  let(:db_uri)    { "sqlite://#{db_file}" }
  let(:log_file) { '/tmp/admin_ui.log' }
  let(:logger) { Logger.new(log_file) }
  let(:config) do
    AdminUI::Config.load(data_file:            data_file,
                         db_uri:               db_uri,
                         mbus:                 'nats://nats:c1oudc0w@localhost:14222',
                         monitored_components: [])
  end
  let(:email) { AdminUI::EMail.new(config, logger) }
  let(:nats) { AdminUI::NATS.new(config, logger, email) }

  before do
    config_stub
  end

  after do
    nats.shutdown
    nats.join

    Process.wait(Process.spawn({}, "rm -fr #{data_file} #{db_file} #{log_file}"))
  end

  context 'No backend connected' do
    it 'returns zero items as expected' do
      expect(nats.get).to eq('connected' => false, 'items' => {}, 'notified' => {})
    end
  end
end
