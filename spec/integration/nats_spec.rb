require 'logger'
require 'nats/client'
require_relative '../spec_helper'

describe AdminUI::NATS, type: :integration do
  include ConfigHelper
  include NATSHelper

  let(:data_file) { '/tmp/admin_ui_data.json' }
  let(:db_file)   { '/tmp/admin_ui_store.db' }
  let(:db_uri)    { "sqlite://#{db_file}" }
  let(:log_file)  { '/tmp/admin_ui.log' }

  let(:config) do
    AdminUI::Config.load(data_file:              data_file,
                         db_uri:                 db_uri,
                         monitored_components:   [],
                         nats_discovery_timeout: 1)
  end

  let(:email)              { AdminUI::EMail.new(config, logger) }
  let(:event_machine_loop) { AdminUI::EventMachineLoop.new(config, logger, true) }
  let(:logger)             { Logger.new(log_file) }
  let(:nats)               { AdminUI::NATS.new(config, logger, email, true) }

  before do
    config_stub
    nats_stub(:varz_router)

    event_machine_loop
  end

  after do
    nats.shutdown
    event_machine_loop.shutdown

    nats.join
    event_machine_loop.join

    Process.wait(Process.spawn({}, "rm -fr #{data_file} #{db_file} #{log_file}"))
  end

  context 'Stubbed NATS' do
    it 'returns items as expected' do
      get = nats.get

      expect(get['connected']).to eq(true)
      items = get['items']
      expect(items.length).to be(3)

      expect(items).to include(nats_cloud_controller_varz => nats_cloud_controller)
      expect(items).to include(nats_provisioner_varz => nats_provisioner)
      expect(items).to include(nats_router_varz => nats_router)
    end
  end
end
