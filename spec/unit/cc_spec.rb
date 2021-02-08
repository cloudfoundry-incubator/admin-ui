require 'logger'
require_relative '../spec_helper'

describe AdminUI::CC do
  include ConfigHelper

  let(:ccdb_file)  { '/tmp/admin_ui_ccdb.db' }
  let(:ccdb_uri)   { "sqlite://#{ccdb_file}" }
  let(:db_file)    { '/tmp/admin_ui_store.db' }
  let(:db_uri)     { "sqlite://#{db_file}" }
  let(:log_file)   { '/tmp/admin_ui.log' }
  let(:uaadb_file) { '/tmp/admin_ui_uaadb.db' }
  let(:uaadb_uri)  { "sqlite://#{uaadb_file}" }

  let(:config) do
    AdminUI::Config.load(ccdb_uri:  ccdb_uri,
                         db_uri:    db_uri,
                         uaadb_uri: uaadb_uri)
  end

  let(:cc)     { AdminUI::CC.new(config, logger, true) }
  let(:logger) { Logger.new(log_file) }

  before do
    config_stub
  end

  after do
    cc.shutdown
    cc.join

    Process.wait(Process.spawn({}, "rm -fr #{ccdb_file} #{db_file} #{log_file} #{uaadb_file}"))
  end

  context 'No backend connected' do
    def verify_disconnected_items(result)
      expect(result).to include('connected' => false, 'items' => [])
    end

    it 'returns zero applications as expected' do
      verify_disconnected_items(cc.applications)
    end

    it 'returns zero application annotations as expected' do
      verify_disconnected_items(cc.application_annotations)
    end

    it 'returns nil application count as expected' do
      expect(cc.applications_count).to be_nil
    end

    it 'returns zero application labels as expected' do
      verify_disconnected_items(cc.application_labels)
    end

    it 'returns zero approvals as expected' do
      verify_disconnected_items(cc.approvals)
    end

    it 'returns zero buildpacks as expected' do
      verify_disconnected_items(cc.buildpacks)
    end

    it 'returns zero buildpack annotations as expected' do
      verify_disconnected_items(cc.buildpack_annotations)
    end

    it 'returns zero buildpack labels as expected' do
      verify_disconnected_items(cc.buildpack_labels)
    end

    it 'returns zero buildpack_lifecycle_data as expected' do
      verify_disconnected_items(cc.buildpack_lifecycle_data)
    end

    it 'returns zero clients as expected' do
      verify_disconnected_items(cc.clients)
    end

    it 'returns zero domains as expected' do
      verify_disconnected_items(cc.domains)
    end

    it 'returns zero domain annotations as expected' do
      verify_disconnected_items(cc.domain_annotations)
    end

    it 'returns zero domain labels as expected' do
      verify_disconnected_items(cc.domain_labels)
    end

    it 'returns zero droplets as expected' do
      verify_disconnected_items(cc.droplets)
    end

    it 'returns zero env-groups as expected' do
      verify_disconnected_items(cc.env_groups)
    end

    it 'returns zero events as expected' do
      verify_disconnected_items(cc.events)
    end

    it 'returns zero feature_flags as expected' do
      verify_disconnected_items(cc.feature_flags)
    end

    it 'returns zero group_membership expected' do
      verify_disconnected_items(cc.group_membership)
    end

    it 'returns zero groups as expected' do
      verify_disconnected_items(cc.groups)
    end

    it 'returns zero identity_providers as expected' do
      verify_disconnected_items(cc.identity_providers)
    end

    it 'returns zero identity_zones as expected' do
      verify_disconnected_items(cc.identity_zones)
    end

    it 'returns zero isolation_segments as expected' do
      verify_disconnected_items(cc.isolation_segments)
    end

    it 'returns zero isolation segment annotations as expected' do
      verify_disconnected_items(cc.isolation_segment_annotations)
    end

    it 'returns zero isolation segment labels as expected' do
      verify_disconnected_items(cc.isolation_segment_labels)
    end

    it 'returns zero mfa_providers as expected' do
      verify_disconnected_items(cc.mfa_providers)
    end

    it 'returns zero organizations as expected' do
      verify_disconnected_items(cc.organizations)
    end

    it 'returns zero organizations_auditors as expected' do
      verify_disconnected_items(cc.organizations_auditors)
    end

    it 'returns nil organizations count as expected' do
      expect(cc.organizations_count).to be_nil
    end

    it 'returns zero organizations_billing_managers as expected' do
      verify_disconnected_items(cc.organizations_billing_managers)
    end

    it 'returns zero organizations_isolation_segments expected' do
      verify_disconnected_items(cc.organizations_isolation_segments)
    end

    it 'returns zero organizations_managers as expected' do
      verify_disconnected_items(cc.organizations_managers)
    end

    it 'returns zero organizations_private_domains as expected' do
      verify_disconnected_items(cc.organizations_private_domains)
    end

    it 'returns zero organizations_users as expected' do
      verify_disconnected_items(cc.organizations_users)
    end

    it 'returns zero organization annotations as expected' do
      verify_disconnected_items(cc.organization_annotations)
    end

    it 'returns zero organization_labels as expected' do
      verify_disconnected_items(cc.organization_labels)
    end

    it 'returns zero packages as expected' do
      verify_disconnected_items(cc.packages)
    end

    it 'returns zero processes as expected' do
      verify_disconnected_items(cc.processes)
    end

    it 'returns nil processes running instances as expected' do
      expect(cc.processes_running_instances).to be_nil
    end

    it 'returns nil processes totals instances as expected' do
      expect(cc.processes_total_instances).to be_nil
    end

    it 'returns zero quota_definitions as expected' do
      verify_disconnected_items(cc.quota_definitions)
    end

    it 'returns zero revocable_tokens as expected' do
      verify_disconnected_items(cc.revocable_tokens)
    end

    it 'returns zero request_counts as expected' do
      verify_disconnected_items(cc.request_counts)
    end

    it 'returns zero routes as expected' do
      verify_disconnected_items(cc.routes)
    end

    it 'returns zero route annotations as expected' do
      verify_disconnected_items(cc.route_annotations)
    end

    it 'returns zero route_bindings as expected' do
      verify_disconnected_items(cc.route_bindings)
    end

    it 'returns zero route_binding_annotations as expected' do
      verify_disconnected_items(cc.route_binding_annotations)
    end

    it 'returns zero route_binding_labels as expected' do
      verify_disconnected_items(cc.route_binding_labels)
    end

    it 'returns zero route_binding_operations as expected' do
      verify_disconnected_items(cc.route_binding_operations)
    end

    it 'returns zero route labels as expected' do
      verify_disconnected_items(cc.route_labels)
    end

    it 'returns zero route_mappings as expected' do
      verify_disconnected_items(cc.route_mappings)
    end

    it 'returns zero security_groups as expected' do
      verify_disconnected_items(cc.security_groups)
    end

    it 'returns zero security_groups_spaces as expected' do
      verify_disconnected_items(cc.security_groups_spaces)
    end

    it 'returns zero service_bindings as expected' do
      verify_disconnected_items(cc.service_bindings)
    end

    it 'returns zero service_binding_annotations as expected' do
      verify_disconnected_items(cc.service_binding_annotations)
    end

    it 'returns zero service_binding_labels as expected' do
      verify_disconnected_items(cc.service_binding_labels)
    end

    it 'returns zero service_binding_operations as expected' do
      verify_disconnected_items(cc.service_binding_operations)
    end

    it 'returns zero service_brokers as expected' do
      verify_disconnected_items(cc.service_brokers)
    end

    it 'returns zero service_broker_annotations as expected' do
      verify_disconnected_items(cc.service_broker_annotations)
    end

    it 'returns zero service_broker_labels as expected' do
      verify_disconnected_items(cc.service_broker_labels)
    end

    it 'returns zero service_dashboard_clients as expected' do
      verify_disconnected_items(cc.service_dashboard_clients)
    end

    it 'returns zero service_instances as expected' do
      verify_disconnected_items(cc.service_instances)
    end

    it 'returns zero service_instance_annotations as expected' do
      verify_disconnected_items(cc.service_instance_annotations)
    end

    it 'returns zero service_instance_labels as expected' do
      verify_disconnected_items(cc.service_instance_labels)
    end

    it 'returns zero service_instance_operations as expected' do
      verify_disconnected_items(cc.service_instance_operations)
    end

    it 'returns zero service_instance_shares as expected' do
      verify_disconnected_items(cc.service_instance_shares)
    end

    it 'returns zero service_keys as expected' do
      verify_disconnected_items(cc.service_keys)
    end

    it 'returns zero service_key_annotations as expected' do
      verify_disconnected_items(cc.service_key_annotations)
    end

    it 'returns zero service_key_labels as expected' do
      verify_disconnected_items(cc.service_key_labels)
    end

    it 'returns zero service_key_operations as expected' do
      verify_disconnected_items(cc.service_key_operations)
    end

    it 'returns zero service_offering_annotations as expected' do
      verify_disconnected_items(cc.service_offering_annotations)
    end

    it 'returns zero service_offering_labels as expected' do
      verify_disconnected_items(cc.service_offering_labels)
    end

    it 'returns zero service_plans as expected' do
      verify_disconnected_items(cc.service_plans)
    end

    it 'returns zero service_plan_annotations as expected' do
      verify_disconnected_items(cc.service_plan_annotations)
    end

    it 'returns zero service_plan_labels as expected' do
      verify_disconnected_items(cc.service_plan_labels)
    end

    it 'returns zero service_plan_visibilities as expected' do
      verify_disconnected_items(cc.service_plan_visibilities)
    end

    it 'returns zero service_providers as expected' do
      verify_disconnected_items(cc.service_providers)
    end

    it 'returns zero services as expected' do
      verify_disconnected_items(cc.services)
    end

    it 'returns zero space quota_definitions as expected' do
      verify_disconnected_items(cc.space_quota_definitions)
    end

    it 'returns zero spaces as expected' do
      verify_disconnected_items(cc.spaces)
    end

    it 'returns zero spaces_auditors as expected' do
      verify_disconnected_items(cc.spaces_auditors)
    end

    it 'returns nil spaces count as expected' do
      expect(cc.spaces_count).to be_nil
    end

    it 'returns zero spaces_developers as expected' do
      verify_disconnected_items(cc.spaces_developers)
    end

    it 'returns zero spaces_managers as expected' do
      verify_disconnected_items(cc.spaces_managers)
    end

    it 'returns zero space annotations as expected' do
      verify_disconnected_items(cc.space_annotations)
    end

    it 'returns zero space_labels as expected' do
      verify_disconnected_items(cc.space_labels)
    end

    it 'returns zero stacks as expected' do
      verify_disconnected_items(cc.stacks)
    end

    it 'returns zero stack annotations as expected' do
      verify_disconnected_items(cc.stack_annotations)
    end

    it 'returns zero stack labels as expected' do
      verify_disconnected_items(cc.stack_labels)
    end

    it 'returns zero staging_security_groups_spaces as expected' do
      verify_disconnected_items(cc.staging_security_groups_spaces)
    end

    it 'returns zero tasks as expected' do
      verify_disconnected_items(cc.tasks)
    end

    it 'returns zero task annotations as expected' do
      verify_disconnected_items(cc.task_annotations)
    end

    it 'returns zero task labels as expected' do
      verify_disconnected_items(cc.task_labels)
    end

    it 'returns zero user annotations as expected' do
      verify_disconnected_items(cc.user_annotations)
    end

    it 'returns zero user labels as expected' do
      verify_disconnected_items(cc.user_labels)
    end

    it 'returns zero users_cc as expected' do
      verify_disconnected_items(cc.users_cc)
    end

    it 'returns nil users count as expected' do
      expect(cc.users_count).to be_nil
    end

    it 'returns zero users_uaa as expected' do
      verify_disconnected_items(cc.users_uaa)
    end
  end
end
