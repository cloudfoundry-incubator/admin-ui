require 'logger'
require_relative '../spec_helper'

describe AdminUI::ViewModels do
  include ConfigHelper

  let(:ccdb_file)         { '/tmp/admin_ui_ccdb.db' }
  let(:ccdb_uri)          { "sqlite://#{ccdb_file}" }
  let(:data_file)         { '/tmp/admin_ui_data.json' }
  let(:db_file)           { '/tmp/admin_ui_store.db' }
  let(:db_uri)            { "sqlite://#{db_file}" }
  let(:doppler_data_file) { '/tmp/admin_ui_doppler_data.json' }
  let(:log_file)          { '/tmp/admin_ui.log' }
  let(:uaadb_file)        { '/tmp/admin_ui_uaadb.db' }
  let(:uaadb_uri)         { "sqlite://#{uaadb_file}" }

  let(:config) do
    AdminUI::Config.load(ccdb_uri:                ccdb_uri,
                         data_file:               data_file,
                         db_uri:                  db_uri,
                         doppler_data_file:       doppler_data_file,
                         doppler_rollup_interval: 1,
                         log_files:               [log_file],
                         mbus:                    'nats://nats:c1oudc0w@localhost:14222',
                         uaadb_uri:               uaadb_uri)
  end

  let(:cc)                 { AdminUI::CC.new(config, logger, true) }
  let(:client)             { AdminUI::CCRestClient.new(config, logger) }
  let(:doppler)            { AdminUI::Doppler.new(config, logger, client, email, true) }
  let(:email)              { AdminUI::EMail.new(config, logger) }
  let(:event_machine_loop) { AdminUI::EventMachineLoop.new(config, logger, true) }
  let(:logger)             { Logger.new(log_file) }
  let(:log_files)          { AdminUI::LogFiles.new(config, logger) }
  let(:nats)               { AdminUI::NATS.new(config, logger, email, true) }
  let(:stats)              { AdminUI::Stats.new(config, logger, cc, doppler, varz, true) }
  let(:varz)               { AdminUI::VARZ.new(config, logger, nats, true) }
  let(:view_models)        { AdminUI::ViewModels.new(config, logger, cc, client, doppler, log_files, stats, varz, true) }

  before do
    config_stub

    event_machine_loop
  end

  after do
    view_models.shutdown
    stats.shutdown
    varz.shutdown
    nats.shutdown
    doppler.shutdown
    cc.shutdown
    event_machine_loop.shutdown

    view_models.join
    stats.join
    varz.join
    nats.join
    doppler.join
    cc.join
    event_machine_loop.join

    Process.wait(Process.spawn({}, "rm -fr #{ccdb_file} #{data_file} #{db_file} #{doppler_data_file} #{log_file} #{uaadb_file}"))
  end

  context 'No backend connected' do
    def verify_disconnected_items(result)
      expect(result).to include(connected: false, items: [])
    end

    it 'returns nil application as expected' do
      expect(view_models.application('bogus', true)).to be_nil
    end

    it 'returns zero applications as expected' do
      verify_disconnected_items(view_models.applications)
    end

    it 'returns nil application_instance as expected' do
      expect(view_models.application_instance('bogus', 0)).to be_nil
    end

    it 'returns zero application_instances as expected' do
      verify_disconnected_items(view_models.application_instances)
    end

    it 'returns nil approval as expected' do
      expect(view_models.approval('bogus', 'bogus', 'bogus')).to be_nil
    end

    it 'returns zero approvals as expected' do
      verify_disconnected_items(view_models.approvals)
    end

    it 'returns nil buildpack as expected' do
      expect(view_models.buildpack('bogus')).to be_nil
    end

    it 'returns zero buildpacks as expected' do
      verify_disconnected_items(view_models.buildpacks)
    end

    it 'returns nil cell as expected' do
      expect(view_models.cell('bogus')).to be_nil
    end

    it 'returns zero cells as expected' do
      verify_disconnected_items(view_models.cells)
    end

    it 'returns nil client as expected' do
      expect(view_models.client('bogus')).to be_nil
    end

    it 'returns zero clients as expected' do
      verify_disconnected_items(view_models.clients)
    end

    it 'returns nil cloud_controller as expected' do
      expect(view_models.cloud_controller('bogus')).to be_nil
    end

    it 'returns zero cloud_controllers as expected' do
      verify_disconnected_items(view_models.cloud_controllers)
    end

    it 'returns nil component as expected' do
      expect(view_models.component('bogus')).to be_nil
    end

    it 'returns zero components as expected' do
      verify_disconnected_items(view_models.components)
    end

    it 'returns nil dea as expected' do
      expect(view_models.dea('bogus')).to be_nil
    end

    it 'returns zero deas as expected' do
      verify_disconnected_items(view_models.deas)
    end

    it 'returns nil domain as expected' do
      expect(view_models.domain('bogus')).to be_nil
    end

    it 'returns zero domains as expected' do
      verify_disconnected_items(view_models.domains)
    end

    it 'returns nil environment_group as expected' do
      expect(view_models.environment_group('bogus')).to be_nil
    end

    it 'returns zero environment_groups as expected' do
      verify_disconnected_items(view_models.environment_groups)
    end

    it 'returns nil event as expected' do
      expect(view_models.event('bogus')).to be_nil
    end

    it 'returns zero events as expected' do
      verify_disconnected_items(view_models.events)
    end

    it 'returns nil feature_flag as expected' do
      expect(view_models.feature_flag('bogus')).to be_nil
    end

    it 'returns zero feature_flags as expected' do
      verify_disconnected_items(view_models.feature_flags)
    end

    it 'returns nil gateway as expected' do
      expect(view_models.gateway('bogus')).to be_nil
    end

    it 'returns zero gateways as expected' do
      verify_disconnected_items(view_models.gateways)
    end

    it 'returns nil group_member as expected' do
      expect(view_models.group_member('bogus', 'bogus')).to be_nil
    end

    it 'returns zero group_members as expected' do
      verify_disconnected_items(view_models.group_members)
    end

    it 'returns nil group as expected' do
      expect(view_models.group('bogus')).to be_nil
    end

    it 'returns zero groups as expected' do
      verify_disconnected_items(view_models.groups)
    end

    it 'returns nil health_manager as expected' do
      expect(view_models.health_manager('bogus')).to be_nil
    end

    it 'returns zero health_managers as expected' do
      verify_disconnected_items(view_models.health_managers)
    end

    it 'returns nil identity_provider as expected' do
      expect(view_models.identity_provider('bogus')).to be_nil
    end

    it 'returns zero identity_providers as expected' do
      verify_disconnected_items(view_models.identity_providers)
    end

    it 'returns nil identity_zone as expected' do
      expect(view_models.identity_zone('bogus')).to be_nil
    end

    it 'returns zero identity_zones as expected' do
      verify_disconnected_items(view_models.identity_zones)
    end

    it 'returns nil isolation_segment as expected' do
      expect(view_models.isolation_segment('bogus')).to be_nil
    end

    it 'returns zero isolation_segments as expected' do
      verify_disconnected_items(view_models.isolation_segments)
    end

    it 'returns nil mfa_provider as expected' do
      expect(view_models.mfa_provider('bogus')).to be_nil
    end

    it 'returns zero mfa_providers as expected' do
      verify_disconnected_items(view_models.mfa_providers)
    end

    it 'returns nil organization as expected' do
      expect(view_models.organization('bogus')).to be_nil
    end

    it 'returns zero organizations as expected' do
      verify_disconnected_items(view_models.organizations)
    end

    it 'returns nil organization_isolation_segment as expected' do
      expect(view_models.organization_isolation_segment('bogus', 'bogus')).to be_nil
    end

    it 'returns zero organizations_isolation_segments as expected' do
      verify_disconnected_items(view_models.organizations_isolation_segments)
    end

    it 'returns nil organization_role expected' do
      expect(view_models.organization_role('bogus', 'bogus', 'bogus', 'bogus')).to be_nil
    end

    it 'returns zero organization_roles as expected' do
      verify_disconnected_items(view_models.organization_roles)
    end

    it 'returns nil quota as expected' do
      expect(view_models.quota('bogus')).to be_nil
    end

    it 'returns zero quotas as expected' do
      verify_disconnected_items(view_models.quotas)
    end

    it 'returns nil revocable_token as expected' do
      expect(view_models.revocable_token('bogus')).to be_nil
    end

    it 'returns zero revocable_tokens as expected' do
      verify_disconnected_items(view_models.revocable_tokens)
    end

    it 'returns nil router as expected' do
      expect(view_models.router('bogus')).to be_nil
    end

    it 'returns zero routers as expected' do
      verify_disconnected_items(view_models.routers)
    end

    it 'returns nil route as expected' do
      expect(view_models.route('bogus')).to be_nil
    end

    it 'returns zero routes as expected' do
      verify_disconnected_items(view_models.routes)
    end

    it 'returns nil route_binding as expected' do
      expect(view_models.route_binding('bogus')).to be_nil
    end

    it 'returns zero route_bindings as expected' do
      verify_disconnected_items(view_models.route_bindings)
    end

    it 'returns nil route_mapping as expected' do
      expect(view_models.route_mapping('bogus', 'bogus')).to be_nil
    end

    it 'returns zero route_mappings as expected' do
      verify_disconnected_items(view_models.route_mappings)
    end

    it 'returns nil security_group as expected' do
      expect(view_models.security_group('bogus')).to be_nil
    end

    it 'returns zero security_groups as expected' do
      verify_disconnected_items(view_models.security_groups)
    end

    it 'returns nil security_group_space as expected' do
      expect(view_models.security_group_space('bogus', 'bogus')).to be_nil
    end

    it 'returns zero security_groups_spaces as expected' do
      verify_disconnected_items(view_models.security_groups_spaces)
    end

    it 'returns nil service_binding as expected' do
      expect(view_models.service_binding('bogus', true)).to be_nil
    end

    it 'returns zero service_bindings as expected' do
      verify_disconnected_items(view_models.service_bindings)
    end

    it 'returns nil service_broker as expected' do
      expect(view_models.service_broker('bogus')).to be_nil
    end

    it 'returns zero service_brokers as expected' do
      verify_disconnected_items(view_models.service_brokers)
    end

    it 'returns nil service_instance as expected' do
      expect(view_models.service_instance('bogus', true, true)).to be_nil
    end

    it 'returns zero service_instances as expected' do
      verify_disconnected_items(view_models.service_instances)
    end

    it 'returns nil service_key as expected' do
      expect(view_models.service_key('bogus', true)).to be_nil
    end

    it 'returns zero service_keys as expected' do
      verify_disconnected_items(view_models.service_keys)
    end

    it 'returns nil service_plan as expected' do
      expect(view_models.service_plan('bogus')).to be_nil
    end

    it 'returns zero service_plans as expected' do
      verify_disconnected_items(view_models.service_plans)
    end

    it 'returns nil service_plan_visibility as expected' do
      expect(view_models.service_plan_visibility('bogus', 'bogus', 'bogus')).to be_nil
    end

    it 'returns zero service_plan_visibilities as expected' do
      verify_disconnected_items(view_models.service_plan_visibilities)
    end

    it 'returns nil service_provider as expected' do
      expect(view_models.service_provider('bogus')).to be_nil
    end

    it 'returns zero service_providers as expected' do
      verify_disconnected_items(view_models.service_providers)
    end

    it 'returns nil service as expected' do
      expect(view_models.service('bogus')).to be_nil
    end

    it 'returns zero services as expected' do
      verify_disconnected_items(view_models.services)
    end

    it 'returns nil shared_service_instance as expected' do
      expect(view_models.shared_service_instance('bogus', 'bogus')).to be_nil
    end

    it 'returns zero shared_service_instances as expected' do
      verify_disconnected_items(view_models.shared_service_instances)
    end

    it 'returns nil space as expected' do
      expect(view_models.space('bogus')).to be_nil
    end

    it 'returns nil space_quota as expected' do
      expect(view_models.space_quota('bogus')).to be_nil
    end

    it 'returns zero space_quotas as expected' do
      verify_disconnected_items(view_models.space_quotas)
    end

    it 'returns nil space_role as expected' do
      expect(view_models.space_role('bogus', 'bogus', 'bogus', 'bogus')).to be_nil
    end

    it 'returns zero space_roles as expected' do
      verify_disconnected_items(view_models.space_roles)
    end

    it 'returns zero spaces as expected' do
      verify_disconnected_items(view_models.spaces)
    end

    it 'returns nil stack as expected' do
      expect(view_models.stack('bogus')).to be_nil
    end

    it 'returns nil staging_security_group_space as expected' do
      expect(view_models.staging_security_group_space('bogus', 'bogus')).to be_nil
    end

    it 'returns zero staging_security_groups_spaces as expected' do
      verify_disconnected_items(view_models.staging_security_groups_spaces)
    end

    it 'returns zero stacks as expected' do
      verify_disconnected_items(view_models.stacks)
    end

    it 'returns nil task as expected' do
      expect(view_models.task('bogus')).to be_nil
    end

    it 'returns zero tasks as expected' do
      verify_disconnected_items(view_models.tasks)
    end

    it 'returns nil user as expected' do
      expect(view_models.user('bogus')).to be_nil
    end

    it 'returns zero users as expected' do
      verify_disconnected_items(view_models.users)
    end
  end

  context 'No backend required' do
    def verify_connected_one_item(result)
      expect(result).to include(connected: true)
      expect(result[:items].length).to be(1)
    end

    def verify_connected_zero_items(result)
      expect(result).to include(connected: true, items: [])
    end

    it 'returns zero logs as expected' do
      verify_connected_one_item(view_models.logs)
    end

    it 'returns zero stats as expected' do
      verify_connected_one_item(view_models.stats)
    end
  end
end
