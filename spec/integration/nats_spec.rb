require 'logger'
require 'nats/client'
require_relative '../spec_helper'

describe AdminUI::NATS, :type => :integration do
  include NATSHelper

  let(:data_file) { '/tmp/admin_ui_data.json' }
  let(:log_file) { '/tmp/admin_ui.log' }

  before do
    AdminUI::Config.any_instance.stub(:validate)
    nats_stub
  end

  let(:logger) { Logger.new(log_file) }
  let(:config) do
    AdminUI::Config.load(:data_file            => data_file,
                         :monitored_components => [])
  end

  let(:email) { AdminUI::EMail.new(config, logger) }
  let(:nats) { AdminUI::NATS.new(config, logger, email) }

  after do
    Process.wait(Process.spawn({}, "rm -fr #{ data_file } #{ log_file }"))
  end

  context 'Stubbed NATS' do
    it 'returns items as expected' do
      get = nats.get

      expect(get['connected']).to eq(true)
      items = get['items']
      expect(items.length).to be(5)

      expect(items).to include(nats_cloud_controller_varz => nats_cloud_controller)
      expect(items).to include(nats_dea_varz => nats_dea)
      expect(items).to include(nats_health_manager_varz => nats_health_manager)
      expect(items).to include(nats_provisioner_varz => nats_provisioner)
      expect(items).to include(nats_router_varz => nats_router)
    end
  end
end
