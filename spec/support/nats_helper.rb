require 'nats/client'
require_relative '../spec_helper'

module NATSHelper
  def nats_stub
    ::NATS.stub(:start) do |_, &blk|
      return if blk.nil?
      blk.call
    end

    ::NATS.stub(:stop)

    ::NATS.stub(:request).with('vcap.component.discover') do |_, &blk|
      return if blk.nil?
      blk.call(nats_cloud_controller.to_json)
      blk.call(nats_dea.to_json)
      blk.call(nats_health_manager.to_json)
      blk.call(nats_provisioner.to_json)
      blk.call(nats_router.to_json)
    end
  end

  def nats_cloud_controller
    {
      'credentials' => %w(cc_user cc_password),
      'host'        => 'CloudControllerHost',
      'index'       => 0,
      'type'        => 'CloudController'
    }
  end

  def nats_dea
    {
      'credentials' => %w(dea_user dea_password),
      'host'        => 'DEAHost',
      'index'       => 0,
      'type'        => 'DEA'
    }
  end

  def nats_health_manager
    {
      'credentials' => %w(hm_user hm_password),
      'host'        => 'HealthManagerHost',
      'index'       => 0,
      'type'        => 'HM9000'
    }
  end

  def nats_provisioner
    {
      'credentials' => %w(provisioner_user provisioner_password),
      'host'        => 'Test-ProvisionerHost',
      'index'       => 0,
      'type'        => 'Test-Provisioner'
    }
  end

  def nats_router
    {
      'credentials' => %w(router_user router_password),
      'host'        => 'RouterHost',
      'index'       => 0,
      'type'        => 'Router'
    }
  end

  def nats_cloud_controller_varz
    "http://#{ nats_cloud_controller['host'] }/varz"
  end

  def nats_dea_varz
    "http://#{ nats_dea['host'] }/varz"
  end

  def nats_health_manager_varz
    "http://#{ nats_health_manager['host'] }/varz"
  end

  def nats_provisioner_varz
    "http://#{ nats_provisioner['host'] }/varz"
  end

  def nats_router_varz
    "http://#{ nats_router['host'] }/varz"
  end
end
