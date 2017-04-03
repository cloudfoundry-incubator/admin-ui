require 'eventmachine'
require 'nats/client'
require 'yajl'
require_relative '../spec_helper'

module NATSHelper
  def nats_stub(router_source)
    allow(::NATS).to receive(:start) do |_, &blk|
      EventMachine.next_tick { blk.call }
    end

    allow(::NATS).to receive(:stop)

    allow(::NATS).to receive(:request).with('vcap.component.discover') do |_, &blk|
      EventMachine.next_tick { blk.call(Yajl::Encoder.encode(nats_cloud_controller)) }
      EventMachine.next_tick { blk.call(Yajl::Encoder.encode(nats_provisioner)) }
      EventMachine.next_tick { blk.call(Yajl::Encoder.encode(nats_router)) } if router_source == :varz_router
    end
  end

  def nats_cloud_controller
    {
      'credentials' => %w[cc_user cc_password],
      'host'        => 'CloudControllerHost',
      'index'       => 0,
      'type'        => 'CloudController'
    }
  end

  def nats_provisioner
    {
      'credentials' => %w[provisioner_user provisioner_password],
      'host'        => 'Test-ProvisionerHost',
      'index'       => 0,
      'type'        => 'Test-Provisioner'
    }
  end

  def nats_router
    {
      'credentials' => %w[router_user router_password],
      'host'        => 'RouterHost',
      'index'       => 0,
      'type'        => 'Router'
    }
  end

  def nats_cloud_controller_varz
    "http://#{nats_cloud_controller['host']}/varz"
  end

  def nats_provisioner_varz
    "http://#{nats_provisioner['host']}/varz"
  end

  def nats_router_varz
    "http://#{nats_router['host']}/varz"
  end
end
