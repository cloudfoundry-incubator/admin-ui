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

    def nats_cloud_controller
      {
        'host'        => 'CloudControllerHost',
        'name'        => 'CloudControllerName',
        'type'        => 'CloudController',
        'credentials' => %w(cc_user cc_password)
      }
    end

    def nats_dea
      {
        'host'        => 'DEAHost',
        'name'        => 'DEAName',
        'type'        => 'DEA',
        'credentials' => %w(dea_user dea_password)
      }
    end

    def nats_health_manager
      {
        'host'        => 'HealthManagerHost',
        'name'        => 'HealthManagerName',
        'type'        => 'HealthManager',
        'credentials' => %w(hm_user hm_password)
      }
    end

    def nats_provisioner
      {
        'host'        => 'Test-ProvisionerHost',
        'name'        => 'Test-ProvisionerName',
        'type'        => 'Test-Provisioner',
        'credentials' => %w(provisioner_user provisioner_password)
      }
    end

    def nats_router
      {
        'host'        => 'RouterHost',
        'name'        => 'RouterName',
        'type'        => 'Router',
        'credentials' => %w(router_user router_password)
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
end
