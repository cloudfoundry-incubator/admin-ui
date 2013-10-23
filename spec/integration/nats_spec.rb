require 'logger'
require 'nats/client'
require_relative '../spec_helper'

describe IBM::AdminUI::NATS, :type => :integration do
  include NATSHelper

  let(:data_file) { '/tmp/admin_ui_data.json' }
  let(:log_file) { '/tmp/admin_ui.log' }

  before do
    nats_stub

    logger = Logger.new(log_file)
    logger.level = Logger::DEBUG

    IBM::AdminUI::Config.load(:data_file            => data_file,
                              :monitored_components => [])

    @nats = IBM::AdminUI::NATS.new(logger,
                                   IBM::AdminUI::EMail.new(logger))
  end

  after do
    cleanup_files_pid = Process.spawn({}, "rm -fr #{ data_file } #{ log_file }")
    Process.wait(cleanup_files_pid)
  end

  context 'Stubbed NATS' do
    it 'returns items as expected' do
      get = @nats.get

      get['connected'].should eq(true)
      items = get['items']
      items.length.should be(5)

      items.should include(nats_cloud_controller_varz => nats_cloud_controller)
      items.should include(nats_dea_varz => nats_dea)
      items.should include(nats_health_manager_varz => nats_health_manager)
      items.should include(nats_provisioner_varz => nats_provisioner)
      items.should include(nats_router_varz => nats_router)
    end
  end
end
