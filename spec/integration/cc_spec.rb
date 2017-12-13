require 'logger'
require_relative '../spec_helper'

describe AdminUI::CC, type: :integration do
  include CCHelper
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

  let(:logger) { Logger.new(log_file) }

  def cleanup_files
    Process.wait(Process.spawn({}, "rm -fr #{ccdb_file} #{db_file} #{log_file} #{uaadb_file}"))
  end

  before do
    cleanup_files

    config_stub
    cc_stub(config)
  end

  let(:cc) { AdminUI::CC.new(config, logger, true) }

  after do
    cc.shutdown
    cc.join

    cleanup_files
  end

  context 'Stubbed' do
    it 'clears the application cache' do
      expect(cc.applications['items'].length).to eq(1)
      cc_clear_apps_cache_stub(config)
      cc.invalidate_applications
      expect(cc.applications['items'].length).to eq(0)
    end

    it 'clears the approval cache' do
      expect(cc.approvals['items'].length).to eq(1)
      uaa_clear_approvals_cache_stub(config)
      cc.invalidate_approvals
      expect(cc.approvals['items'].length).to eq(0)
    end

    it 'clears the buildpack cache' do
      expect(cc.buildpacks['items'].length).to eq(1)
      cc_clear_buildpacks_cache_stub(config)
      cc.invalidate_buildpacks
      expect(cc.buildpacks['items'].length).to eq(0)
    end

    it 'clears the client cache' do
      expect(cc.clients['items'].length).to eq(1)
      uaa_clear_clients_cache_stub(config)
      cc.invalidate_clients
      expect(cc.clients['items'].length).to eq(0)
    end

    it 'clears the domain cache' do
      expect(cc.domains['items'].length).to eq(1)
      cc_clear_domains_cache_stub(config)
      cc.invalidate_domains
      expect(cc.domains['items'].length).to eq(0)
    end

    it 'clears the droplet cache' do
      expect(cc.droplets['items'].length).to eq(1)
      cc_clear_droplets_cache_stub(config)
      cc.invalidate_droplets
      expect(cc.droplets['items'].length).to eq(0)
    end

    it 'clears the feature flags cache' do
      expect(cc.feature_flags['items'].length).to eq(1)
      cc_clear_feature_flags_cache_stub(config)
      cc.invalidate_feature_flags
      expect(cc.feature_flags['items'].length).to eq(0)
    end

    it 'clears the group membership cache' do
      expect(cc.group_membership['items'].length).to eq(1)
      uaa_clear_group_membership_cache_stub(config)
      cc.invalidate_group_membership
      expect(cc.group_membership['items'].length).to eq(0)
    end

    it 'clears the groups cache' do
      expect(cc.groups['items'].length).to eq(1)
      uaa_clear_groups_cache_stub(config)
      cc.invalidate_groups
      expect(cc.groups['items'].length).to eq(0)
    end

    it 'clears the identity providers cache' do
      expect(cc.identity_providers['items'].length).to eq(1)
      uaa_clear_identity_providers_cache_stub(config)
      cc.invalidate_identity_providers
      expect(cc.identity_providers['items'].length).to eq(0)
    end

    it 'clears the identity zones cache' do
      expect(cc.identity_zones['items'].length).to eq(1)
      uaa_clear_identity_zones_cache_stub(config)
      cc.invalidate_identity_zones
      expect(cc.identity_zones['items'].length).to eq(0)
    end

    it 'clears the isolation segments cache' do
      expect(cc.isolation_segments['items'].length).to eq(1)
      cc_clear_isolation_segments_cache_stub(config)
      cc.invalidate_isolation_segments
      expect(cc.isolation_segments['items'].length).to eq(0)
    end

    it 'clears the mfa providers cache' do
      expect(cc.mfa_providers['items'].length).to eq(1)
      uaa_clear_mfa_providers_cache_stub(config)
      cc.invalidate_mfa_providers
      expect(cc.mfa_providers['items'].length).to eq(0)
    end

    it 'clears the organizations cache' do
      expect(cc.organizations['items'].length).to eq(1)
      cc_clear_organizations_cache_stub(config)
      cc.invalidate_organizations
      expect(cc.organizations['items'].length).to eq(0)
    end

    it 'clears the organizations auditors cache' do
      expect(cc.organizations_auditors['items'].length).to eq(1)
      cc_clear_organizations_cache_stub(config)
      cc.invalidate_organizations_auditors
      expect(cc.organizations_auditors['items'].length).to eq(0)
    end

    it 'clears the organizations billing managers cache' do
      expect(cc.organizations_billing_managers['items'].length).to eq(1)
      cc_clear_organizations_cache_stub(config)
      cc.invalidate_organizations_billing_managers
      expect(cc.organizations_billing_managers['items'].length).to eq(0)
    end

    it 'clears the organizations managers cache' do
      expect(cc.organizations_managers['items'].length).to eq(1)
      cc_clear_organizations_cache_stub(config)
      cc.invalidate_organizations_managers
      expect(cc.organizations_managers['items'].length).to eq(0)
    end

    it 'clears the organizations isolation segments users cache' do
      expect(cc.organizations_isolation_segments['items'].length).to eq(1)
      cc_clear_organizations_isolation_segments_cache_stub(config)
      cc.invalidate_organizations_isolation_segments
      expect(cc.organizations_isolation_segments['items'].length).to eq(0)
    end

    it 'clears the organizations private domains cache' do
      expect(cc.organizations_private_domains['items'].length).to eq(1)
      cc_clear_organizations_private_domains_cache_stub(config)
      cc.invalidate_organizations_private_domains
      expect(cc.organizations_private_domains['items'].length).to eq(0)
    end

    it 'clears the organizations users cache' do
      expect(cc.organizations_users['items'].length).to eq(1)
      cc_clear_organizations_cache_stub(config)
      cc.invalidate_organizations_users
      expect(cc.organizations_users['items'].length).to eq(0)
    end

    it 'clears the package cache' do
      expect(cc.packages['items'].length).to eq(1)
      cc_clear_packages_cache_stub(config)
      cc.invalidate_packages
      expect(cc.packages['items'].length).to eq(0)
    end

    it 'clears the process cache' do
      expect(cc.processes['items'].length).to eq(1)
      cc_clear_processes_cache_stub(config)
      cc.invalidate_processes
      expect(cc.processes['items'].length).to eq(0)
    end

    it 'clears the quota definition cache' do
      expect(cc.quota_definitions['items'].length).to eq(1)
      cc_clear_quota_definitions_cache_stub(config)
      cc.invalidate_quota_definitions
      expect(cc.quota_definitions['items'].length).to eq(0)
    end

    it 'clears the revocable tokens cache' do
      expect(cc.revocable_tokens['items'].length).to eq(1)
      uaa_clear_revocable_tokens_cache_stub(config)
      cc.invalidate_revocable_tokens
      expect(cc.revocable_tokens['items'].length).to eq(0)
    end

    it 'clears the route cache' do
      expect(cc.routes['items'].length).to eq(1)
      cc_clear_routes_cache_stub(config)
      cc.invalidate_routes
      expect(cc.routes['items'].length).to eq(0)
    end

    it 'clears the route bindings cache' do
      expect(cc.route_bindings['items'].length).to eq(1)
      cc_clear_route_bindings_cache_stub(config)
      cc.invalidate_route_bindings
      expect(cc.route_bindings['items'].length).to eq(0)
    end

    it 'clears the route mappings cache' do
      expect(cc.route_mappings['items'].length).to eq(1)
      cc_clear_route_mappings_cache_stub(config)
      cc.invalidate_route_mappings
      expect(cc.route_mappings['items'].length).to eq(0)
    end

    it 'clears the security group cache' do
      expect(cc.security_groups['items'].length).to eq(1)
      cc_clear_security_groups_cache_stub(config)
      cc.invalidate_security_groups
      expect(cc.security_groups['items'].length).to eq(0)
    end

    it 'clears the security group spaces cache' do
      expect(cc.security_groups_spaces['items'].length).to eq(1)
      cc_clear_security_groups_spaces_cache_stub(config)
      cc.invalidate_security_groups_spaces
      expect(cc.security_groups_spaces['items'].length).to eq(0)
    end

    it 'clears the service cache' do
      expect(cc.services['items'].length).to eq(1)
      cc_clear_services_cache_stub(config)
      cc.invalidate_services
      expect(cc.services['items'].length).to eq(0)
    end

    it 'clears the service binding cache' do
      expect(cc.service_bindings['items'].length).to eq(1)
      cc_clear_service_bindings_cache_stub(config)
      cc.invalidate_service_bindings
      expect(cc.service_bindings['items'].length).to eq(0)
    end

    it 'clears the service broker cache' do
      expect(cc.service_brokers['items'].length).to eq(1)
      cc_clear_service_brokers_cache_stub(config)
      cc.invalidate_service_brokers
      expect(cc.service_brokers['items'].length).to eq(0)
    end

    it 'clears the service instance cache' do
      expect(cc.service_instances['items'].length).to eq(1)
      cc_clear_service_instances_cache_stub(config)
      cc.invalidate_service_instances
      expect(cc.service_instances['items'].length).to eq(0)
    end

    it 'clears the service instance share cache' do
      expect(cc.service_instance_shares['items'].length).to eq(1)
      cc_clear_service_instance_shares_cache_stub(config)
      cc.invalidate_service_instance_shares
      expect(cc.service_instance_shares['items'].length).to eq(0)
    end

    it 'clears the service key cache' do
      expect(cc.service_keys['items'].length).to eq(1)
      cc_clear_service_keys_cache_stub(config)
      cc.invalidate_service_keys
      expect(cc.service_keys['items'].length).to eq(0)
    end

    it 'clears the service plan cache' do
      expect(cc.service_plans['items'].length).to eq(1)
      cc_clear_service_plans_cache_stub(config)
      cc.invalidate_service_plans
      expect(cc.service_plans['items'].length).to eq(0)
    end

    it 'clears the service plan visibility cache' do
      expect(cc.service_plan_visibilities['items'].length).to eq(1)
      cc_clear_service_plan_visibilities_cache_stub(config)
      cc.invalidate_service_plan_visibilities
      expect(cc.service_plan_visibilities['items'].length).to eq(0)
    end

    it 'clears the service provider cache' do
      expect(cc.service_providers['items'].length).to eq(1)
      uaa_clear_service_providers_cache_stub(config)
      cc.invalidate_service_providers
      expect(cc.service_providers['items'].length).to eq(0)
    end

    it 'clears the space quota definition cache' do
      expect(cc.space_quota_definitions['items'].length).to eq(1)
      cc_clear_space_quota_definitions_cache_stub(config)
      cc.invalidate_space_quota_definitions
      expect(cc.space_quota_definitions['items'].length).to eq(0)
    end

    it 'clears the spaces cache' do
      expect(cc.spaces['items'].length).to eq(1)
      cc_clear_spaces_cache_stub(config)
      cc.invalidate_spaces
      expect(cc.spaces['items'].length).to eq(0)
    end

    it 'clears the spaces auditors cache' do
      expect(cc.spaces_auditors['items'].length).to eq(1)
      cc_clear_spaces_cache_stub(config)
      cc.invalidate_spaces_auditors
      expect(cc.spaces_auditors['items'].length).to eq(0)
    end

    it 'clears the spaces developers cache' do
      expect(cc.spaces_developers['items'].length).to eq(1)
      cc_clear_spaces_cache_stub(config)
      cc.invalidate_spaces_developers
      expect(cc.spaces_developers['items'].length).to eq(0)
    end

    it 'clears the spaces managers cache' do
      expect(cc.spaces_managers['items'].length).to eq(1)
      cc_clear_spaces_cache_stub(config)
      cc.invalidate_spaces_managers
      expect(cc.spaces_managers['items'].length).to eq(0)
    end

    it 'clears the stacks cache' do
      expect(cc.stacks['items'].length).to eq(1)
      cc_clear_stacks_cache_stub(config)
      cc.invalidate_stacks
      expect(cc.stacks['items'].length).to eq(0)
    end

    it 'clears the staging security group spaces cache' do
      expect(cc.staging_security_groups_spaces['items'].length).to eq(1)
      cc_clear_staging_security_groups_spaces_cache_stub(config)
      cc.invalidate_staging_security_groups_spaces
      expect(cc.staging_security_groups_spaces['items'].length).to eq(0)
    end

    it 'clears the tasks cache' do
      expect(cc.tasks['items'].length).to eq(1)
      cc_clear_tasks_cache_stub(config)
      cc.invalidate_tasks
      expect(cc.tasks['items'].length).to eq(0)
    end

    it 'clears the users cc cache' do
      expect(cc.users_cc['items'].length).to eq(1)
      cc_clear_users_cache_stub(config)
      cc.invalidate_users_cc
      expect(cc.users_cc['items'].length).to eq(0)
    end

    it 'clears the users uaa cache' do
      expect(cc.users_uaa['items'].length).to eq(1)
      uaa_clear_users_cache_stub(config)
      cc.invalidate_users_uaa
      expect(cc.users_uaa['items'].length).to eq(0)
    end

    shared_examples 'common cc retrieval' do
      it 'verify cc retrieval' do
        expect(results['connected']).to eq(true)
        items = results['items']
        expect(items.length).to eq(1)
        expect(items[0]).to include(expected)
      end
    end

    context 'returns connected applications' do
      let(:results)  { cc.applications }
      let(:expected) { cc_app }

      it_behaves_like('common cc retrieval')
    end

    it 'returns applications count' do
      expect(cc.applications_count).to be(1)
    end

    context 'returns connected approvals' do
      let(:results)  { cc.approvals }
      let(:expected) { uaa_approval }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected buildpacks' do
      let(:results)  { cc.buildpacks }
      let(:expected) { cc_buildpack }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected buildpack_lifecycle_data' do
      let(:results)  { cc.buildpack_lifecycle_data }
      let(:expected) { cc_buildpack_lifecycle_data }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected clients' do
      let(:results)  { cc.clients }
      let(:expected) { uaa_client }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected domains' do
      let(:results)  { cc.domains }
      let(:expected) { cc_domain }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected droplets' do
      let(:results)  { cc.droplets }
      let(:expected) { cc_droplet }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected env_groups' do
      let(:results)  { cc.env_groups }
      let(:expected) { cc_env_group }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected events' do
      let(:results)  { cc.events }
      let(:expected) { cc_event_space }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected feature flags' do
      let(:results)  { cc.feature_flags }
      let(:expected) { cc_feature_flag }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected group membership' do
      let(:results)  { cc.group_membership }
      let(:expected) { uaa_group_membership }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected groups' do
      let(:results)  { cc.groups }
      let(:expected) { uaa_group }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected identity providers' do
      let(:results)  { cc.identity_providers }
      let(:expected) { uaa_identity_provider }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected identity zones' do
      let(:results)  { cc.identity_zones }
      let(:expected) { uaa_identity_zone }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected isolation segments' do
      let(:results)  { cc.isolation_segments }
      let(:expected) { cc_isolation_segment }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected mfa providers' do
      let(:results)  { cc.mfa_providers }
      let(:expected) { uaa_mfa_provider }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected organizations' do
      let(:results)  { cc.organizations }
      let(:expected) { cc_organization }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected organizations auditors' do
      let(:results)  { cc.organizations_auditors }
      let(:expected) { cc_organization_auditor }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected organizations billing managers' do
      let(:results)  { cc.organizations_billing_managers }
      let(:expected) { cc_organization_billing_manager }

      it_behaves_like('common cc retrieval')
    end

    it 'returns organizations count' do
      expect(cc.organizations_count).to be(1)
    end

    context 'returns connected organizations isolation segments' do
      let(:results)  { cc.organizations_isolation_segments }
      let(:expected) { cc_organization_isolation_segment }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected organizations managers' do
      let(:results)  { cc.organizations_managers }
      let(:expected) { cc_organization_manager }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected organizations private domains' do
      let(:results)  { cc.organizations_private_domains }
      let(:expected) { cc_organization_private_domain }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected organizations users' do
      let(:results)  { cc.organizations_users }
      let(:expected) { cc_organization_user }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected packages' do
      let(:results)  { cc.packages }
      let(:expected) { cc_package }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected processes' do
      let(:results)  { cc.processes }
      let(:expected) { cc_process }

      it_behaves_like('common cc retrieval')
    end

    it 'returns processes running instances' do
      expect(cc.processes_running_instances).to be(1)
    end

    it 'returns processes total instances' do
      expect(cc.processes_total_instances).to be(1)
    end

    context 'returns connected quota definitions' do
      let(:results)  { cc.quota_definitions }
      let(:expected) { cc_quota_definition }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected request counts' do
      let(:results)  { cc.request_counts }
      let(:expected) { cc_request_count }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected revocable tokens' do
      let(:results)  { cc.revocable_tokens }
      let(:expected) { uaa_revocable_token }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected routes' do
      let(:results)  { cc.routes }
      let(:expected) { cc_route }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected route bindings' do
      let(:results)  { cc.route_bindings }
      let(:expected) { cc_route_binding }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected route mappings' do
      let(:results)  { cc.route_mappings }
      let(:expected) { cc_route_mapping }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected security groups' do
      let(:results)  { cc.security_groups }
      let(:expected) { cc_security_group }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected security groups spaces' do
      let(:results)  { cc.security_groups_spaces }
      let(:expected) { cc_security_group_space }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected service bindings' do
      let(:results)  { cc.service_bindings }
      let(:expected) { cc_service_binding }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected service brokers' do
      let(:results)  { cc.service_brokers }
      let(:expected) { cc_service_broker }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected service dashboard clients' do
      let(:results)  { cc.service_dashboard_clients }
      let(:expected) { cc_service_dashboard_client }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected service instance operations' do
      let(:results)  { cc.service_instance_operations }
      let(:expected) { cc_service_instance_operation }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected service instance shares' do
      let(:results)  { cc.service_instance_shares }
      let(:expected) { cc_service_instance_share }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected service instances' do
      let(:results)  { cc.service_instances }
      let(:expected) { cc_service_instance }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected service keys' do
      let(:results)  { cc.service_keys }
      let(:expected) { cc_service_key }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected service plans' do
      let(:results)  { cc.service_plans }
      let(:expected) { cc_service_plan }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected service plan visibilities' do
      let(:results)  { cc.service_plan_visibilities }
      let(:expected) { cc_service_plan_visibility }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected service providers' do
      let(:results)  { cc.service_providers }
      let(:expected) { uaa_service_provider }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected services' do
      let(:results)  { cc.services }
      let(:expected) { cc_service }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected space quota definitions' do
      let(:results)  { cc.space_quota_definitions }
      let(:expected) { cc_space_quota_definition }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected spaces' do
      let(:results)  { cc.spaces }
      let(:expected) { cc_space }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected spaces auditors' do
      let(:results)  { cc.spaces_auditors }
      let(:expected) { cc_space_auditor }

      it_behaves_like('common cc retrieval')
    end

    it 'returns spaces count' do
      expect(cc.spaces_count).to be(1)
    end

    context 'returns connected spaces developers' do
      let(:results)  { cc.spaces_developers }
      let(:expected) { cc_space_developer }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected spaces managers' do
      let(:results)  { cc.spaces_managers }
      let(:expected) { cc_space_manager }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected stacks' do
      let(:results)  { cc.stacks }
      let(:expected) { cc_stack }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected staging security groups spaces' do
      let(:results)  { cc.staging_security_groups_spaces }
      let(:expected) { cc_staging_security_group_space }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected tasks' do
      let(:results)  { cc.tasks }
      let(:expected) { cc_task }

      it_behaves_like('common cc retrieval')
    end

    context 'returns connected users cc' do
      let(:results)  { cc.users_cc }
      let(:expected) { cc_user }

      it_behaves_like('common cc retrieval')
    end

    it 'returns users count' do
      expect(cc.users_count).to be(1)
    end

    context 'returns connected users uaa' do
      let(:results)  { cc.users_uaa }
      let(:expected) { uaa_user }

      it_behaves_like('common cc retrieval')
    end
  end
end
