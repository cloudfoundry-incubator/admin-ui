require 'logger'
require_relative '../spec_helper'

describe IBM::AdminUI::VARZ, :type => :integration do
  include NATSHelper
  include VARZHelper

  let(:data_file) { '/tmp/admin_ui_data.json' }
  let(:log_file) { '/tmp/admin_ui.log' }

  before do
    nats_stub

    logger = Logger.new(log_file)
    logger.level = Logger::DEBUG

    IBM::AdminUI::Config.load(:data_file            => data_file,
                              :monitored_components => [])

    nats = IBM::AdminUI::NATS.new(logger,
                                  IBM::AdminUI::EMail.new(logger))

    @varz = IBM::AdminUI::VARZ.new(logger,
                                   nats)
  end

  after do
    cleanup_files_pid = Process.spawn({}, "rm -fr #{ data_file } #{ log_file }")
    Process.wait(cleanup_files_pid)
  end

  context 'Stubbed NATS, but not HTTP' do
    it 'returns disconnected components as expected' do
      components = @varz.components

      components['connected'].should eq(true)
      items = components['items']
      items.length.should be(5)

      items.should include('connected' => false,
                           'data'      => nats_cloud_controller,
                           'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                           'name'      => nats_cloud_controller['host'],
                           'uri'       => nats_cloud_controller_varz)

      items.should include('connected' => false,
                           'data'      => nats_dea,
                           'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                           'name'      => nats_dea['host'],
                           'uri'       => nats_dea_varz)

      items.should include('connected' => false,
                           'data'      => nats_health_manager,
                           'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                           'name'      => nats_health_manager['host'],
                           'uri'       => nats_health_manager_varz)

      items.should include('connected' => false,
                           'data'      => nats_router,
                           'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                           'name'      => nats_router['host'],
                           'uri'       => nats_router_varz)

      items.should include('connected' => false,
                           'data'      => nats_provisioner,
                           'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                           'name'      => nats_provisioner['host'],
                           'uri'       => nats_provisioner_varz)
    end

    it 'returns disconnected cloud_controllers as expected' do
      cloud_controllers = @varz.cloud_controllers

      cloud_controllers['connected'].should eq(true)
      items = cloud_controllers['items']
      items.length.should be(1)

      items.should include('connected' => false,
                           'data'      => nats_cloud_controller,
                           'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                           'name'      => nats_cloud_controller['host'],
                           'uri'       => nats_cloud_controller_varz)
    end

    it 'returns disconnected deas as expected' do
      deas = @varz.deas

      deas['connected'].should eq(true)
      items = deas['items']
      items.length.should be(1)

      items.should include('connected' => false,
                           'data'      => nats_dea,
                           'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                           'name'      => nats_dea['host'],
                           'uri'       => nats_dea_varz)
    end

    it 'returns deas_count' do
      deas_count = @varz.deas_count

      deas_count.should be(1)
    end

    it 'returns disconnected health_managers as expected' do
      health_managers = @varz.health_managers

      health_managers['connected'].should eq(true)
      items = health_managers['items']
      items.length.should be(1)

      items.should include('connected' => false,
                           'data'      => nats_health_manager,
                           'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                           'name'      => nats_health_manager['host'],
                           'uri'       => nats_health_manager_varz)
    end

    it 'returns disconnected gateways as expected' do
      gateways = @varz.gateways

      gateways['connected'].should eq(true)
      items = gateways['items']
      items.length.should be(1)

     items.should include('connected' => false,
                          'data'      => nats_provisioner,
                          'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                          'name'      => nats_provisioner['type'].sub('-Provisioner', ''),
                          'uri'       => nats_provisioner_varz)
    end

    it 'returns disconnected routers as expected' do
      routers = @varz.routers

      routers['connected'].should eq(true)
      items = routers['items']
      items.length.should be(1)

      items.should include('connected' => false,
                           'data'      => nats_router,
                           'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                           'name'      => nats_router['host'],
                           'uri'       => nats_router_varz)
    end
  end

  context 'Stubbed NATS and HTTP' do
    before do
      varz_stub
    end

    it 'returns connected components' do
      components = @varz.components

      components['connected'].should eq(true)
      items = components['items']

      items.length.should be(5)

      items.should include('connected' => true,
                           'data'      => varz_cloud_controller,
                           'name'      => nats_cloud_controller['host'],
                           'uri'       => nats_cloud_controller_varz)

      items.should include('connected' => true,
                           'data'      => varz_dea,
                           'name'      => nats_dea['host'],
                           'uri'       => nats_dea_varz)

      items.should include('connected' => true,
                           'data'      => varz_health_manager,
                           'name'      => nats_health_manager['host'],
                           'uri'       => nats_health_manager_varz)

      items.should include('connected' => true,
                           'data'      => varz_router,
                           'name'      => nats_router['host'],
                           'uri'       => nats_router_varz)

      items.should include('connected' => true,
                           'data'      => varz_provisioner,
                           'name'      => nats_provisioner['host'],
                           'uri'       => nats_provisioner_varz)
    end

    it 'returns connected cloud_controllers' do
      cloud_controllers = @varz.cloud_controllers

      cloud_controllers['connected'].should eq(true)
      items = cloud_controllers['items']

      items.length.should be(1)

      items.should include('connected' => true,
                           'data'      => varz_cloud_controller,
                           'name'      => nats_cloud_controller['host'],
                           'uri'       => nats_cloud_controller_varz)
    end

    it 'returns connected deas' do
      deas = @varz.deas

      deas['connected'].should eq(true)
      items = deas['items']

      items.length.should be(1)

      items.should include('connected' => true,
                           'data'      => varz_dea,
                           'name'      => nats_dea['host'],
                           'uri'       => nats_dea_varz)
    end

    it 'returns deas_count' do
      deas_count = @varz.deas_count

      deas_count.should be(1)
    end

    it 'returns connected health_managers' do
      health_managers = @varz.health_managers

      health_managers['connected'].should eq(true)
      items = health_managers['items']

      items.length.should be(1)

      items.should include('connected' => true,
                           'data'      => varz_health_manager,
                           'name'      => nats_health_manager['host'],
                           'uri'       => nats_health_manager_varz)
    end

    it 'returns connected gateways' do
      gateways = @varz.gateways

      gateways['connected'].should eq(true)
      items = gateways['items']

      items.length.should be(1)

      items.should include('connected' => true,
                           'data'      => varz_provisioner,
                           'name'      => nats_provisioner['type'].sub('-Provisioner', ''),
                           'uri'       => nats_provisioner_varz)
    end

    it 'returns connected routers' do
      routers = @varz.routers

      routers['connected'].should eq(true)
      items = routers['items']

      items.length.should be(1)

      items.should include('connected' => true,
                           'data'      => varz_router,
                           'name'      => nats_router['host'],
                           'uri'       => nats_router_varz)
    end
  end
end
