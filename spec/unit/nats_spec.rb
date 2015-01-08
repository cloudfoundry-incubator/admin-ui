require 'logger'
require_relative '../spec_helper'

describe AdminUI::NATS do
  include ThreadHelper

  let(:data_file) { '/tmp/admin_ui_data.json' }
  let(:db_file)   { '/tmp/admin_ui_store.db' }
  let(:db_uri)    { "sqlite://#{ db_file }" }
  let(:log_file) { '/tmp/admin_ui.log' }
  let(:logger) { Logger.new(log_file) }
  let(:config) do
    AdminUI::Config.load(component_connection_retries: 50,
                         data_file:                    data_file,
                         db_uri:                       db_uri,
                         mbus:                         'nats://nats:c1oudc0w@localhost:14222',
                         monitored_components:         [],
                         nats_discovery_timeout:       1)
  end
  let(:email) { AdminUI::EMail.new(config, logger) }
  let(:nats) { AdminUI::NATS.new(config, logger, email) }

  before do
    AdminUI::Config.any_instance.stub(:validate)
  end

  after do
    kill_threads

    Process.wait(Process.spawn({}, "rm -fr #{ data_file } #{ db_file } #{ log_file }"))
  end

  context 'No backend connected' do
    it 'returns zero items as expected' do
      expect(nats.get).to eq('connected' => false, 'items' => {}, 'notified' => {})
    end
  end
end
