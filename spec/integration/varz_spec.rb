require 'logger'
require_relative '../spec_helper'

describe AdminUI::VARZ, type: :integration do
  include CCHelper
  include ConfigHelper
  include NATSHelper
  include VARZHelper

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
  let(:varz)               { AdminUI::VARZ.new(config, logger, nats, true) }

  before do
    config_stub
    cc_stub(config, false)
    nats_stub(:varz_router)

    event_machine_loop
  end

  after do
    varz.shutdown
    nats.shutdown
    event_machine_loop.shutdown

    varz.join
    nats.join
    event_machine_loop.join

    Process.wait(Process.spawn({}, "rm -fr #{data_file} #{db_file} #{log_file}"))
  end

  context 'Stubbed NATS, but not HTTP' do
    it 'returns disconnected components as expected' do
      components = varz.components

      expect(components['connected']).to eq(true)
      items = components['items']
      items.each { |i| i.delete('error') }
      expect(items.length).to be(3)

      expect(items).to include('connected' => false,
                               'data'      => nats_cloud_controller,
                               # 'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                               'index'     => nats_cloud_controller['index'],
                               'name'      => nats_cloud_controller['host'],
                               'type'      => nats_cloud_controller['type'],
                               'uri'       => nats_cloud_controller_varz)

      expect(items).to include('connected' => false,
                               'data'      => nats_router,
                               # 'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                               'index'     => nats_router['index'],
                               'name'      => nats_router['host'],
                               'type'      => nats_router['type'],
                               'uri'       => nats_router_varz)

      expect(items).to include('connected' => false,
                               'data'      => nats_provisioner,
                               # 'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                               'index'     => nats_provisioner['index'],
                               'name'      => nats_provisioner['host'],
                               'type'      => nats_provisioner['type'],
                               'uri'       => nats_provisioner_varz)
    end

    it 'returns disconnected cloud_controllers as expected' do
      cloud_controllers = varz.cloud_controllers

      expect(cloud_controllers['connected']).to eq(true)
      items = cloud_controllers['items']
      items.each { |i| i.delete('error') }
      expect(items.length).to be(1)

      expect(items).to include('connected' => false,
                               'data'      => nats_cloud_controller,
                               # 'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                               'index'     => nats_cloud_controller['index'],
                               'name'      => nats_cloud_controller['host'],
                               'type'      => nats_cloud_controller['type'],
                               'uri'       => nats_cloud_controller_varz)
    end

    it 'returns disconnected gateways as expected' do
      gateways = varz.gateways

      expect(gateways['connected']).to eq(true)
      items = gateways['items']
      items.each { |i| i.delete('error') }
      expect(items.length).to be(1)

      expect(items).to include('connected' => false,
                               'data'      => nats_provisioner,
                               # 'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                               'index'     => nats_provisioner['index'],
                               'name'      => nats_provisioner['type'].sub('-Provisioner', ''),
                               'type'      => nats_provisioner['type'],
                               'uri'       => nats_provisioner_varz)
    end

    it 'returns disconnected routers as expected' do
      routers = varz.routers

      expect(routers['connected']).to eq(true)
      items = routers['items']
      items.each { |i| i.delete('error') }
      expect(items.length).to be(1)

      expect(items).to include('connected' => false,
                               'data'      => nats_router,
                               # 'error'     => '#<SocketError: getaddrinfo: Name or service not known>',
                               'index'     => nats_router['index'],
                               'name'      => nats_router['host'],
                               'type'      => nats_router['type'],
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

      expect(items.length).to be(3)

      expect(items).to include('connected' => true,
                               'data'      => varz_cloud_controller,
                               'index'     => nats_cloud_controller['index'],
                               'name'      => nats_cloud_controller['host'],
                               'type'      => nats_cloud_controller['type'],
                               'uri'       => nats_cloud_controller_varz)

      expect(items).to include('connected' => true,
                               'data'      => varz_router,
                               'index'     => nats_router['index'],
                               'name'      => nats_router['host'],
                               'type'      => nats_router['type'],
                               'uri'       => nats_router_varz)

      expect(items).to include('connected' => true,
                               'data'      => varz_provisioner,
                               'index'     => nats_provisioner['index'],
                               'name'      => nats_provisioner['host'],
                               'type'      => nats_provisioner['type'],
                               'uri'       => nats_provisioner_varz)
    end

    it 'returns connected cloud_controllers' do
      cloud_controllers = varz.cloud_controllers

      expect(cloud_controllers['connected']).to eq(true)
      items = cloud_controllers['items']

      expect(items.length).to be(1)

      expect(items).to include('connected' => true,
                               'data'      => varz_cloud_controller,
                               'index'     => nats_cloud_controller['index'],
                               'name'      => nats_cloud_controller['host'],
                               'type'      => nats_cloud_controller['type'],
                               'uri'       => nats_cloud_controller_varz)
    end

    it 'returns connected gateways' do
      gateways = varz.gateways

      expect(gateways['connected']).to eq(true)
      items = gateways['items']

      expect(items.length).to be(1)

      expect(items).to include('connected' => true,
                               'data'      => varz_provisioner,
                               'index'     => nats_provisioner['index'],
                               'name'      => nats_provisioner['type'].sub('-Provisioner', ''),
                               'type'      => nats_provisioner['type'],
                               'uri'       => nats_provisioner_varz)
    end

    it 'returns connected routers' do
      routers = varz.routers

      expect(routers['connected']).to eq(true)
      items = routers['items']

      expect(items.length).to be(1)

      expect(items).to include('connected' => true,
                               'data'      => varz_router,
                               'index'     => nats_router['index'],
                               'name'      => nats_router['host'],
                               'type'      => nats_router['type'],
                               'uri'       => nats_router_varz)
    end
  end
end
