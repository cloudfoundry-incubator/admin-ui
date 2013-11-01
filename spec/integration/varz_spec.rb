require 'logger'
require_relative '../spec_helper'

describe AdminUI::VARZ, :type => :integration do
  include NATSHelper
  include VARZHelper

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
  let(:varz) { AdminUI::VARZ.new(config, logger, nats) }

  after do
    Process.wait(Process.spawn({}, "rm -fr #{ data_file } #{ log_file }"))
  end

  context 'Stubbed NATS, but not HTTP' do
    it 'returns disconnected components as expected' do
      components = varz.components

      expect(components['connected']).to eq(true)
      items = components['items']
      expect(items.length).to be(5)

      expect(items).to include('connected' => false,
                               'data'      => nats_cloud_controller,
                               'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                               'name'      => nats_cloud_controller['host'],
                               'uri'       => nats_cloud_controller_varz)

      expect(items).to include('connected' => false,
                               'data'      => nats_dea,
                               'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                               'name'      => nats_dea['host'],
                               'uri'       => nats_dea_varz)

      expect(items).to include('connected' => false,
                               'data'      => nats_health_manager,
                               'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                               'name'      => nats_health_manager['host'],
                               'uri'       => nats_health_manager_varz)

      expect(items).to include('connected' => false,
                               'data'      => nats_router,
                               'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                               'name'      => nats_router['host'],
                               'uri'       => nats_router_varz)

      expect(items).to include('connected' => false,
                               'data'      => nats_provisioner,
                               'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                               'name'      => nats_provisioner['host'],
                               'uri'       => nats_provisioner_varz)
    end

    it 'returns disconnected cloud_controllers as expected' do
      cloud_controllers = varz.cloud_controllers

      expect(cloud_controllers['connected']).to eq(true)
      items = cloud_controllers['items']
      expect(items.length).to be(1)

      expect(items).to include('connected' => false,
                               'data'      => nats_cloud_controller,
                               'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                               'name'      => nats_cloud_controller['host'],
                               'uri'       => nats_cloud_controller_varz)
    end

    it 'returns disconnected deas as expected' do
      deas = varz.deas

      expect(deas['connected']).to eq(true)
      items = deas['items']
      expect(items.length).to be(1)

      expect(items).to include('connected' => false,
                               'data'      => nats_dea,
                               'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                               'name'      => nats_dea['host'],
                               'uri'       => nats_dea_varz)
    end

    it 'returns deas_count' do
      expect(varz.deas_count).to be(1)
    end

    it 'returns disconnected health_managers as expected' do
      health_managers = varz.health_managers

      expect(health_managers['connected']).to eq(true)
      items = health_managers['items']
      expect(items.length).to be(1)

      expect(items).to include('connected' => false,
                               'data'      => nats_health_manager,
                               'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                               'name'      => nats_health_manager['host'],
                               'uri'       => nats_health_manager_varz)
    end

    it 'returns disconnected gateways as expected' do
      gateways = varz.gateways

      expect(gateways['connected']).to eq(true)
      items = gateways['items']
      expect(items.length).to be(1)

      expect(items).to include('connected' => false,
                               'data'      => nats_provisioner,
                               'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                               'name'      => nats_provisioner['type'].sub('-Provisioner', ''),
                               'uri'       => nats_provisioner_varz)
    end

    it 'returns disconnected routers as expected' do
      routers = varz.routers

      expect(routers['connected']).to eq(true)
      items = routers['items']
      expect(items.length).to be(1)

      expect(items).to include('connected' => false,
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
      components = varz.components

      expect(components['connected']).to eq(true)
      items = components['items']

      expect(items.length).to be(5)

      expect(items).to include('connected' => true,
                               'data'      => varz_cloud_controller,
                               'name'      => nats_cloud_controller['host'],
                               'uri'       => nats_cloud_controller_varz)

      expect(items).to include('connected' => true,
                               'data'      => varz_dea,
                               'name'      => nats_dea['host'],
                               'uri'       => nats_dea_varz)

      expect(items).to include('connected' => true,
                               'data'      => varz_health_manager,
                               'name'      => nats_health_manager['host'],
                               'uri'       => nats_health_manager_varz)

      expect(items).to include('connected' => true,
                               'data'      => varz_router,
                               'name'      => nats_router['host'],
                               'uri'       => nats_router_varz)

      expect(items).to include('connected' => true,
                               'data'      => varz_provisioner,
                               'name'      => nats_provisioner['host'],
                               'uri'       => nats_provisioner_varz)
    end

    it 'returns connected cloud_controllers' do
      cloud_controllers = varz.cloud_controllers

      expect(cloud_controllers['connected']).to eq(true)
      items = cloud_controllers['items']

      expect(items.length).to be(1)

      expect(items).to include('connected' => true,
                               'data'      => varz_cloud_controller,
                               'name'      => nats_cloud_controller['host'],
                               'uri'       => nats_cloud_controller_varz)
    end

    it 'returns connected deas' do
      deas = varz.deas

      expect(deas['connected']).to eq(true)
      items = deas['items']

      expect(items.length).to be(1)

      expect(items).to include('connected' => true,
                               'data'      => varz_dea,
                               'name'      => nats_dea['host'],
                               'uri'       => nats_dea_varz)
    end

    it 'returns deas_count' do
      expect(varz.deas_count).to be(1)
    end

    it 'returns connected health_managers' do
      health_managers = varz.health_managers

      expect(health_managers['connected']).to eq(true)
      items = health_managers['items']

      expect(items.length).to be(1)

      expect(items).to include('connected' => true,
                               'data'      => varz_health_manager,
                               'name'      => nats_health_manager['host'],
                               'uri'       => nats_health_manager_varz)
    end

    it 'returns connected gateways' do
      gateways = varz.gateways

      expect(gateways['connected']).to eq(true)
      items = gateways['items']

      expect(items.length).to be(1)

      expect(items).to include('connected' => true,
                               'data'      => varz_provisioner,
                               'name'      => nats_provisioner['type'].sub('-Provisioner', ''),
                               'uri'       => nats_provisioner_varz)
    end

    it 'returns connected routers' do
      routers = varz.routers

      expect(routers['connected']).to eq(true)
      items = routers['items']

      expect(items.length).to be(1)

      expect(items).to include('connected' => true,
                               'data'      => varz_router,
                               'name'      => nats_router['host'],
                               'uri'       => nats_router_varz)
    end
  end
end
