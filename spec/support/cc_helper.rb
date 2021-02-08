require 'net/http'
require 'time'
require 'yajl'
require_relative '../spec_helper'

module CCHelper
  # Workaround since I cannot instantiate Net::HTTPOK and have body() function successfully
  # Failing with NoMethodError: undefined method `closed?
  class OK < Net::HTTPOK
    attr_reader :body

    def initialize(hash)
      super(1.0, 200, 'OK')
      @body = Yajl::Encoder.encode(hash)
    end
  end

  # Workaround since I cannot instantiate Net::HTTPCreated and have body() function successfully
  # Failing with NoMethodError: undefined method `closed?
  class Created < Net::HTTPOK
    attr_reader :body

    def initialize
      super(1.0, 201, 'Created')
      @body = Yajl::Encoder.encode({})
    end
  end

  # Workaround since I cannot instantiate Net::HTTPBadRequest and have body() function successfully
  # Failing with NoMethodError: undefined method `closed?
  class Accepted < Net::HTTPAccepted
    attr_reader :body

    def initialize(hash)
      super(1.0, 202, 'Accepted')
      @body = Yajl::Encoder.encode(hash)
    end
  end

  # Workaround since I cannot instantiate Net::HTTPBadRequest and have body() function successfully
  # Failing with NoMethodError: undefined method `closed?
  class BadRequest < Net::HTTPBadRequest
    attr_reader :body

    def initialize(hash)
      super(1.0, 400, 'BadRequest')
      @body = Yajl::Encoder.encode(hash)
    end
  end

  # Workaround since I cannot instantiate Net::HTTPNotFound and have body() function successfully
  # Failing with NoMethodError: undefined method `closed?
  class NotFound < Net::HTTPNotFound
    attr_reader :body

    def initialize(hash)
      super(1.0, 404, 'NotFound')
      @body = Yajl::Encoder.encode(hash)
    end
  end

  # Workaround since I cannot instantiate Net::HTTPUnprocessableEntity and have body() function successfully
  # Failing with NoMethodError: undefined method `closed?
  class UnprocessableEntity < Net::HTTPUnprocessableEntity
    attr_reader :body

    def initialize(hash)
      super(1.0, 422, 'UnprocessableEntity')
      @body = Yajl::Encoder.encode(hash)
    end
  end

  def cc_stub(config, populate_and_stub = true, insert_second_quota_definition = false, event_type = 'space', use_route = true)
    @last_unique_id   = 0
    @unique_ids       = {}

    @last_unique_time = Time.parse('2015-04-23 08:00:00 -0500')
    @unique_times     = {}

    return unless populate_and_stub

    @cc_apps_deleted                             = false
    @cc_apps_environment_variables_deleted       = false
    @cc_buildpacks_deleted                       = false
    @cc_buildpack_lifecycle_data_deleted         = false
    @cc_domains_deleted                          = false
    @cc_feature_flags_deleted                    = false
    @cc_isolation_segments_deleted               = false
    @cc_organizations_deleted                    = false
    @cc_organizations_isolation_segments_deleted = false
    @cc_quota_definitions_deleted                = false
    @cc_routes_deleted                           = false
    @cc_route_bindings_deleted                   = false
    @cc_route_mappings_deleted                   = false
    @cc_security_groups_deleted                  = false
    @cc_security_groups_spaces_deleted           = false
    @cc_services_deleted                         = false
    @cc_service_bindings_deleted                 = false
    @cc_service_brokers_deleted                  = false
    @cc_service_instances_deleted                = false
    @cc_service_instance_shares_deleted          = false
    @cc_service_keys_deleted                     = false
    @cc_service_plans_deleted                    = false
    @cc_service_plan_visibilities_deleted        = false
    @cc_space_quota_definitions_deleted          = false
    @cc_spaces_deleted                           = false
    @cc_stacks_deleted                           = false
    @cc_staging_security_groups_spaces_deleted   = false
    @cc_tasks_deleted                            = false
    @cc_users_deleted                            = false
    @uaa_groups_deleted                          = false
    @uaa_group_membership_deleted                = false
    @uaa_identity_providers_deleted              = false
    @uaa_identity_zones_deleted                  = false
    @uaa_mfa_providers_deleted                   = false
    @uaa_revocable_tokens_deleted                = false
    @uaa_service_providers_deleted               = false
    @uaa_users_deleted                           = false
    @uaa_clients_deleted                         = false

    @cc_isolation_segment_created = false
    @cc_organization_created      = false

    populate_db(config.ccdb_uri,  File.join(File.dirname(__FILE__), './ccdb'), ccdb_inserts(insert_second_quota_definition, event_type, use_route))
    populate_db(config.uaadb_uri, File.join(File.dirname(__FILE__), './uaadb'), uaadb_inserts)

    # In order to set the organization's default_isolation_segment_guid, there has to first be an
    # organizations_isolation_segment record. As a result, we have to have both isolation_segment and
    # organization created prior to being able to set the organization's default_isolation_segment_guid
    sql(config.ccdb_uri, "UPDATE organizations SET default_isolation_segment_guid = '#{cc_isolation_segment[:guid]}'")

    cc_login_stubs(config)
    cc_app_stubs(config)
    cc_buildpack_stubs(config)
    cc_domain_stubs(config)
    cc_env_group_stubs(config)
    cc_feature_flag_stubs(config)
    cc_isolation_segment_stubs(config)
    cc_organization_stubs(config)
    cc_quota_definition_stubs(config)
    cc_route_stubs(config)
    cc_route_binding_stubs(config)
    cc_route_mapping_stubs(config)
    cc_security_group_stubs(config)
    cc_security_group_space_stubs(config)
    cc_service_stubs(config)
    cc_service_binding_stubs(config)
    cc_service_broker_stubs(config)
    cc_service_instance_stubs(config)
    cc_service_instance_share_stubs(config)
    cc_service_key_stubs(config)
    cc_service_plan_stubs(config)
    cc_service_plan_visibility_stubs(config)
    cc_space_stubs(config)
    cc_space_quota_definition_stubs(config)
    cc_stack_stubs(config)
    cc_staging_security_group_space_stubs(config)
    cc_task_stubs(config)
    cc_user_stubs(config)

    uaa_client_stubs(config)
    uaa_group_stubs(config)
    uaa_group_membership_stubs(config)
    uaa_identity_provider_stubs(config)
    uaa_identity_zone_stubs(config)
    uaa_mfa_provider_stubs(config)
    uaa_revocable_token_stubs(config)
    uaa_service_provider_stubs(config)
    uaa_user_stubs(config)
  end

  def cc_clear_apps_cache_stub(config)
    cc_clear_service_bindings_cache_stub(config)
    cc_clear_route_mappings_cache_stub(config)
    cc_clear_tasks_cache_stub(config)
    cc_clear_buildpack_lifecycle_data_cache_stub(config)
    cc_clear_droplets_cache_stub(config)
    cc_clear_packages_cache_stub(config)
    cc_clear_processes_cache_stub(config)

    sql(config.ccdb_uri, 'DELETE FROM app_annotations')
    sql(config.ccdb_uri, 'DELETE FROM app_labels')
    sql(config.ccdb_uri, 'DELETE FROM apps')

    @cc_apps_deleted = true
  end

  def cc_clear_buildpacks_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM buildpack_annotations')
    sql(config.ccdb_uri, 'DELETE FROM buildpack_labels')
    sql(config.ccdb_uri, 'DELETE FROM buildpacks')

    @cc_buildpacks_deleted = true
  end

  def cc_clear_buildpack_lifecycle_data_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM buildpack_lifecycle_data')

    @cc_buildpack_lifecycle_data_deleted = true
  end

  def cc_clear_domains_cache_stub(config)
    cc_clear_organizations_private_domains_cache_stub(config)
    cc_clear_routes_cache_stub(config)

    sql(config.ccdb_uri, 'DELETE FROM domain_annotations')
    sql(config.ccdb_uri, 'DELETE FROM domain_labels')
    sql(config.ccdb_uri, 'DELETE FROM domains')

    @cc_domains_deleted = true
  end

  def cc_clear_droplets_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM droplets')
  end

  def cc_clear_feature_flags_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM feature_flags')

    @cc_feature_flags_deleted = true
  end

  def cc_clear_isolation_segments_cache_stub(config)
    cc_clear_organizations_isolation_segments_cache_stub(config)

    sql(config.ccdb_uri, 'DELETE FROM isolation_segment_annotations')
    sql(config.ccdb_uri, 'DELETE FROM isolation_segment_labels')
    sql(config.ccdb_uri, 'DELETE from isolation_segments')

    @cc_isolation_segments_deleted = true
  end

  def cc_clear_organizations_cache_stub(config)
    cc_clear_domains_cache_stub(config)
    cc_clear_service_plan_visibilities_cache_stub(config)
    cc_clear_space_quota_definitions_cache_stub(config)
    cc_clear_spaces_cache_stub(config)
    cc_clear_organizations_isolation_segments_cache_stub(config)
    cc_clear_organizations_private_domains_cache_stub(config)

    sql(config.ccdb_uri, 'DELETE FROM organization_annotations')
    sql(config.ccdb_uri, 'DELETE FROM organization_labels')
    sql(config.ccdb_uri, 'DELETE FROM organizations_auditors')
    sql(config.ccdb_uri, 'DELETE FROM organizations_billing_managers')
    sql(config.ccdb_uri, 'DELETE FROM organizations_managers')
    sql(config.ccdb_uri, 'DELETE FROM organizations_users')
    sql(config.ccdb_uri, 'DELETE FROM organizations')

    @cc_organizations_deleted = true
    @cc_organization_created  = false
  end

  def cc_clear_organizations_isolation_segments_cache_stub(config)
    sql(config.ccdb_uri, 'UPDATE spaces SET isolation_segment_guid = NULL')
    sql(config.ccdb_uri, 'UPDATE organizations SET default_isolation_segment_guid = NULL')
    sql(config.ccdb_uri, 'DELETE from organizations_isolation_segments')

    @cc_organizations_isolation_segments_deleted = true
  end

  def cc_clear_organizations_private_domains_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM organizations_private_domains')
  end

  def cc_clear_packages_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM packages')
  end

  def cc_clear_processes_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM processes')
  end

  def cc_clear_quota_definitions_cache_stub(config)
    cc_clear_organizations_cache_stub(config)

    sql(config.ccdb_uri, 'DELETE FROM quota_definitions')

    @cc_quota_definitions_deleted = true
  end

  def cc_clear_routes_cache_stub(config)
    cc_clear_route_annotations_cache_stub(config)
    cc_clear_route_bindings_cache_stub(config)
    cc_clear_route_labels_cache_stub(config)
    cc_clear_route_mappings_cache_stub(config)

    sql(config.ccdb_uri, 'DELETE FROM routes')

    @cc_routes_deleted = true
  end

  def cc_clear_route_annotations_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM route_annotations')
  end

  def cc_clear_route_bindings_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM route_binding_annotations')
    sql(config.ccdb_uri, 'DELETE FROM route_binding_labels')
    sql(config.ccdb_uri, 'DELETE FROM route_binding_operations')
    sql(config.ccdb_uri, 'DELETE FROM route_bindings')

    @cc_route_bindings_deleted = true
  end

  def cc_clear_route_labels_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM route_labels')
  end

  def cc_clear_route_mappings_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM route_mappings')

    @cc_route_mappings_deleted = true
  end

  def cc_clear_security_groups_cache_stub(config)
    cc_clear_security_groups_spaces_cache_stub(config)
    cc_clear_staging_security_groups_spaces_cache_stub(config)

    sql(config.ccdb_uri, 'DELETE FROM security_groups')

    @cc_security_groups_deleted = true
  end

  def cc_clear_security_groups_spaces_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM security_groups_spaces')

    @cc_security_groups_spaces_deleted = true
  end

  def cc_clear_service_bindings_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM service_binding_annotations')
    sql(config.ccdb_uri, 'DELETE FROM service_binding_labels')
    sql(config.ccdb_uri, 'DELETE FROM service_binding_operations')
    sql(config.ccdb_uri, 'DELETE FROM service_bindings')

    @cc_service_bindings_deleted = true
  end

  def cc_clear_service_brokers_cache_stub(config)
    cc_clear_services_cache_stub(config)

    sql(config.ccdb_uri, 'DELETE FROM service_broker_annotations')
    sql(config.ccdb_uri, 'DELETE FROM service_broker_labels')
    sql(config.ccdb_uri, 'DELETE FROM service_dashboard_clients')
    sql(config.ccdb_uri, 'DELETE FROM service_brokers')

    @cc_service_brokers_deleted = true
  end

  def cc_clear_service_instances_cache_stub(config)
    cc_clear_route_bindings_cache_stub(config)
    cc_clear_service_bindings_cache_stub(config)
    cc_clear_service_instance_shares_cache_stub(config)
    cc_clear_service_keys_cache_stub(config)

    sql(config.ccdb_uri, 'DELETE FROM service_instance_annotations')
    sql(config.ccdb_uri, 'DELETE FROM service_instance_labels')
    sql(config.ccdb_uri, 'DELETE FROM service_instance_operations')
    sql(config.ccdb_uri, 'DELETE FROM service_instances')

    @cc_service_instances_deleted = true
  end

  def cc_clear_service_instance_shares_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM service_instance_shares')

    @cc_service_instance_shares_deleted = true
  end

  def cc_clear_service_keys_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM service_key_annotations')
    sql(config.ccdb_uri, 'DELETE FROM service_key_labels')
    sql(config.ccdb_uri, 'DELETE FROM service_key_operations')
    sql(config.ccdb_uri, 'DELETE FROM service_keys')

    @cc_service_keys_deleted = true
  end

  def cc_clear_service_plans_cache_stub(config)
    cc_clear_service_instances_cache_stub(config)
    cc_clear_service_plan_visibilities_cache_stub(config)

    sql(config.ccdb_uri, 'DELETE FROM service_plan_annotations')
    sql(config.ccdb_uri, 'DELETE FROM service_plan_labels')
    sql(config.ccdb_uri, 'DELETE FROM service_plans')

    @cc_service_plans_deleted = true
  end

  def cc_clear_service_plan_visibilities_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM service_plan_visibilities')

    @cc_service_plan_visibilities_deleted = true
  end

  def cc_clear_services_cache_stub(config)
    cc_clear_service_plans_cache_stub(config)

    sql(config.ccdb_uri, 'DELETE FROM service_offering_annotations')
    sql(config.ccdb_uri, 'DELETE FROM service_offering_labels')
    sql(config.ccdb_uri, 'DELETE FROM services')

    @cc_services_deleted = true
  end

  def cc_clear_space_quota_definitions_cache_stub(config)
    cc_clear_spaces_cache_stub(config)

    sql(config.ccdb_uri, 'DELETE FROM space_quota_definitions')

    @cc_space_quota_definitions_deleted = true
  end

  def cc_clear_spaces_cache_stub(config)
    cc_clear_routes_cache_stub(config)
    cc_clear_security_groups_spaces_cache_stub(config)
    cc_clear_staging_security_groups_spaces_cache_stub(config)
    cc_clear_service_brokers_cache_stub(config)
    cc_clear_users_cache_stub(config)
    cc_clear_apps_cache_stub(config)

    sql(config.ccdb_uri, 'DELETE FROM events')
    sql(config.ccdb_uri, 'DELETE FROM space_annotations')
    sql(config.ccdb_uri, 'DELETE FROM space_labels')
    sql(config.ccdb_uri, 'DELETE FROM spaces')

    @cc_spaces_deleted = true
  end

  def cc_clear_stacks_cache_stub(config)
    cc_clear_buildpack_lifecycle_data_cache_stub(config)

    sql(config.ccdb_uri, 'DELETE FROM stack_annotations')
    sql(config.ccdb_uri, 'DELETE FROM stack_labels')
    sql(config.ccdb_uri, 'DELETE from stacks')

    @cc_stacks_deleted = true
  end

  def cc_clear_staging_security_groups_spaces_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM staging_security_groups_spaces')

    @cc_staging_security_groups_spaces_deleted = true
  end

  def cc_clear_tasks_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM task_annotations')
    sql(config.ccdb_uri, 'DELETE FROM task_labels')
    sql(config.ccdb_uri, 'DELETE from tasks')

    @cc_tasks_deleted = true
  end

  def cc_clear_users_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM user_annotations')
    sql(config.ccdb_uri, 'DELETE FROM user_labels')
    sql(config.ccdb_uri, 'DELETE FROM spaces_auditors')
    sql(config.ccdb_uri, 'DELETE FROM spaces_developers')
    sql(config.ccdb_uri, 'DELETE FROM spaces_managers')
    sql(config.ccdb_uri, 'DELETE FROM organizations_auditors')
    sql(config.ccdb_uri, 'DELETE FROM organizations_billing_managers')
    sql(config.ccdb_uri, 'DELETE FROM organizations_managers')
    sql(config.ccdb_uri, 'DELETE FROM organizations_users')
    sql(config.ccdb_uri, 'DELETE FROM request_counts')
    sql(config.ccdb_uri, 'DELETE FROM users')

    @cc_users_deleted = true
  end

  def uaa_clear_approvals_cache_stub(config)
    sql(config.uaadb_uri, 'DELETE FROM authz_approvals')
  end

  def uaa_clear_clients_cache_stub(config)
    uaa_clear_approvals_cache_stub(config)
    uaa_clear_revocable_tokens_cache_stub(config)

    sql(config.uaadb_uri, 'DELETE FROM oauth_client_details')

    @uaa_clients_deleted = true
  end

  def uaa_clear_group_membership_cache_stub(config)
    sql(config.uaadb_uri, 'DELETE FROM group_membership')

    @uaa_group_membership_deleted = true
  end

  def uaa_clear_groups_cache_stub(config)
    uaa_clear_approvals_cache_stub(config)
    uaa_clear_group_membership_cache_stub(config)

    sql(config.uaadb_uri, 'DELETE FROM groups')

    @uaa_groups_deleted = true
  end

  def uaa_clear_identity_providers_cache_stub(config)
    sql(config.uaadb_uri, 'DELETE FROM identity_provider')

    @uaa_identity_providers_deleted = true
  end

  def uaa_clear_identity_zones_cache_stub(config)
    uaa_clear_clients_cache_stub(config)
    uaa_clear_groups_cache_stub(config)
    uaa_clear_identity_providers_cache_stub(config)
    uaa_clear_mfa_providers_cache_stub(config)
    uaa_clear_service_providers_cache_stub(config)
    uaa_clear_users_cache_stub(config)

    sql(config.uaadb_uri, 'DELETE FROM identity_zone')

    @uaa_identity_zones_deleted = true
  end

  def uaa_clear_mfa_providers_cache_stub(config)
    sql(config.uaadb_uri, 'DELETE FROM mfa_providers')

    @uaa_mfa_providers_deleted = true
  end

  def uaa_clear_revocable_tokens_cache_stub(config)
    sql(config.uaadb_uri, 'DELETE FROM revocable_tokens')

    @uaa_revocable_tokens_deleted = true
  end

  def uaa_clear_service_providers_cache_stub(config)
    sql(config.uaadb_uri, 'DELETE FROM service_provider')

    @uaa_service_providers_deleted = true
  end

  def uaa_clear_users_cache_stub(config)
    uaa_clear_approvals_cache_stub(config)
    uaa_clear_group_membership_cache_stub(config)
    uaa_clear_revocable_tokens_cache_stub(config)

    sql(config.uaadb_uri, 'DELETE FROM users')

    @uaa_users_deleted = true
  end

  def cc_app
    {
      created_at:           unique_time('cc_app_created'),
      desired_state:        'STARTED',
      droplet_guid:         cc_droplet_guid,
      enable_ssh:           true,
      guid:                 'application1',
      id:                   unique_id('cc_app'),
      max_task_sequence_id: 1,
      name:                 'test',
      revisions_enabled:    true,
      space_guid:           cc_space[:guid],
      updated_at:           unique_time('cc_app_updated')
    }
  end

  def cc_app_rename
    'renamed_test'
  end

  def cc_app_annotation
    {
      created_at:    unique_time('cc_app_annotation_created'),
      guid:          'app_annotation1',
      id:            unique_id('cc_app_annotation'),
      key:           'appannotationkey',
      key_prefix:    'appannotationkeyprefix.com',
      resource_guid: cc_app[:guid],
      updated_at:    unique_time('cc_app_annotation_updated'),
      value:         'appannotationvalue'
    }
  end

  def cc_app_environment_variable_name
    'app_env_key'
  end

  def cc_app_environment_variable
    return {} if @cc_apps_environment_variables_deleted

    {
      cc_app_environment_variable_name => 'app_env_value'
    }
  end

  def cc_app_label
    {
      created_at:    unique_time('cc_app_label_created'),
      guid:          'app_label1',
      id:            unique_id('cc_app_label'),
      key_name:      'applabelkeyname',
      key_prefix:    'applabelkeyprefix.com',
      resource_guid: cc_app[:guid],
      updated_at:    unique_time('cc_app_label_updated'),
      value:         'applabelvalue'
    }
  end

  def cc_buildpack
    {
      created_at: unique_time('cc_buildpack_created'),
      enabled:    true,
      filename:   'buildpack1.zip',
      guid:       'buildpack1',
      id:         unique_id('cc_buildpack'),
      key:        'buildpack_key1',
      locked:     false,
      name:       'Node.js',
      position:   1,
      stack:      cc_stack[:name],
      updated_at: unique_time('cc_buildpack_updated')
    }
  end

  def cc_buildpack_rename
    'renamed Node.js'
  end

  def cc_buildpack_annotation
    {
      created_at:    unique_time('cc_buildpack_annotation_created'),
      guid:          'buildpack_annotation1',
      id:            unique_id('cc_buildpack_annotation'),
      key:           'bpannotationkey',
      key_prefix:    'bpannotationkeyprefix.com',
      resource_guid: cc_buildpack[:guid],
      updated_at:    unique_time('cc_buildpack_annotation_updated'),
      value:         'bpannotationvalue'
    }
  end

  def cc_buildpack_label
    {
      created_at:    unique_time('cc_buildpack_label_created'),
      guid:          'buildpack_label1',
      id:            unique_id('cc_buildpack_label'),
      key_name:      'bplabelkeyname',
      key_prefix:    'bplabelkeyprefix.com',
      resource_guid: cc_buildpack[:guid],
      updated_at:    unique_time('cc_buildpack_label_updated'),
      value:         'bplabelvalue'
    }
  end

  def cc_buildpack_lifecycle_data
    {
      app_guid:   cc_app[:guid],
      created_at: unique_time('cc_buildpack_lifecycle_data_created'),
      guid:       'buildpack_lifecycle_data1',
      id:         unique_id('cc_buildpack_lifecycle_data'),
      stack:      cc_stack[:name]
    }
  end

  def cc_domain
    {
      created_at:             unique_time('cc_domain_created'),
      guid:                   'domain1',
      id:                     unique_id('cc_domain'),
      internal:               false,
      name:                   'test_domain',
      owning_organization_id: cc_organization[:id],
      updated_at:             unique_time('cc_domain_updated')
    }
  end

  def cc_domain_annotation
    {
      created_at:    unique_time('cc_domain_annotation_created'),
      guid:          'domain_annotation1',
      id:            unique_id('cc_domain_annotation'),
      key:           'dmannotationkey',
      key_prefix:    'dmannotationkeyprefix.com',
      resource_guid: cc_domain[:guid],
      updated_at:    unique_time('cc_domain_annotation_updated'),
      value:         'dmannotationvalue'
    }
  end

  def cc_domain_label
    {
      created_at:    unique_time('cc_domain_label_created'),
      guid:          'domain_label1',
      id:            unique_id('cc_domain_label'),
      key_name:      'dmlabelkeyname',
      key_prefix:    'dmlabelkeyprefix.com',
      resource_guid: cc_domain[:guid],
      updated_at:    unique_time('cc_domain_label_updated'),
      value:         'dmlabelvalue'
    }
  end

  def cc_droplet_guid
    'droplet1'
  end

  def cc_droplet
    {
      app_guid:                         cc_app[:guid],
      buildpack_receipt_detect_output:  'node.js',
      buildpack_receipt_buildpack:      cc_buildpack[:name],
      buildpack_receipt_buildpack_guid: cc_buildpack[:guid],
      created_at:                       unique_time('cc_droplet_created'),
      droplet_hash:                     'droplet_hash1',
      error_description:                'An app was not successfully detected by any available buildpack',
      error_id:                         'NoAppDetectedError',
      execution_metadata:               '{}',
      guid:                             cc_droplet_guid,
      id:                               unique_id('cc_droplet'),
      package_guid:                     cc_package[:guid],
      process_types:                    '{"web":"node test.js"}',
      staging_disk_in_mb:               4096,
      staging_memory_in_mb:             1024,
      state:                            'STAGED',
      updated_at:                       unique_time('cc_droplet_updated')
    }
  end

  def cc_env_group
    {
      created_at:             unique_time('cc_env_group_created'),
      guid:                   'env_group1',
      id:                     unique_id('cc_env_group'),
      name:                   'running',
      updated_at:             unique_time('cc_env_group_updated')
    }
  end

  def cc_env_group_variable
    {
      'env_key' => 'env_value'
    }
  end

  def cc_event_app
    {
      actee:             cc_app[:guid],
      actee_name:        cc_app[:name],
      actee_type:        'app',
      actor:             cc_user[:guid],
      actor_name:        uaa_user[:email],
      actor_type:        'user',
      actor_username:    uaa_user[:username],
      created_at:        unique_time('cc_event_app_created'),
      guid:              'event1',
      id:                unique_id('cc_event_app'),
      metadata:          '{}',
      organization_guid: cc_organization[:guid],
      space_guid:        cc_space[:guid],
      timestamp:         unique_time('cc_event_app_timestamp'),
      type:              'audit.app.create',
      updated_at:        unique_time('cc_event_app_updated')
    }
  end

  def cc_event_organization
    {
      actee:             cc_organization[:guid],
      actee_name:        cc_organization[:name],
      actee_type:        'organization',
      actor:             cc_user[:guid],
      actor_name:        uaa_user[:email],
      actor_type:        'user',
      actor_username:    uaa_user[:username],
      created_at:        unique_time('cc_event_organization_created'),
      guid:              'event1',
      id:                unique_id('cc_event_organization'),
      metadata:          '{}',
      organization_guid: cc_organization[:guid],
      space_guid:        '',
      timestamp:         unique_time('cc_event_organization_timestamp'),
      type:              'audit.organization.create',
      updated_at:        unique_time('cc_event_organization_updated')
    }
  end

  def cc_event_route
    {
      actee:             cc_route[:guid],
      actee_name:        cc_route[:host],
      actee_type:        'route',
      actor:             cc_user[:guid],
      actor_name:        uaa_user[:email],
      actor_type:        'user',
      actor_username:    uaa_user[:username],
      created_at:        unique_time('cc_event_route_created'),
      guid:              'event1',
      id:                unique_id('cc_event_route'),
      metadata:          '{}',
      organization_guid: cc_organization[:guid],
      space_guid:        cc_space[:guid],
      timestamp:         unique_time('cc_event_route_timestamp'),
      type:              'audit.route.create',
      updated_at:        unique_time('cc_event_route_updated')
    }
  end

  def cc_event_service
    {
      actee:             cc_service[:guid],
      actee_name:        cc_service[:label],
      actee_type:        'service',
      actor:             cc_service_broker[:guid],
      actor_name:        cc_service_broker[:name],
      actor_type:        'service_broker',
      actor_username:    nil,
      created_at:        unique_time('cc_event_service_created'),
      guid:              'event1',
      id:                unique_id('cc_event_service'),
      metadata:          '{}',
      organization_guid: '',
      space_guid:        '',
      timestamp:         unique_time('cc_event_service_timestamp'),
      type:              'audit.service.create',
      updated_at:        unique_time('cc_event_service_updated')
    }
  end

  def cc_event_service_binding
    {
      actee:             cc_service_binding[:guid],
      actee_name:        nil,
      actee_type:        'service_binding',
      actor:             cc_user[:guid],
      actor_name:        uaa_user[:email],
      actor_type:        'user',
      actor_username:    uaa_user[:username],
      created_at:        unique_time('cc_event_service_binding_created'),
      guid:              'event1',
      id:                unique_id('cc_event_service_binding'),
      metadata:          '{}',
      organization_guid: cc_organization[:guid],
      space_guid:        cc_space[:guid],
      timestamp:         unique_time('cc_event_service_binding_timestamp'),
      type:              'audit.service_binding.create',
      updated_at:        unique_time('cc_event_service_binding_updated')
    }
  end

  def cc_event_service_broker
    {
      actee:             cc_service_broker[:guid],
      actee_name:        cc_service_broker[:name],
      actee_type:        'service_broker',
      actor:             cc_user[:guid],
      actor_name:        uaa_user[:email],
      actor_type:        'user',
      actor_username:    uaa_user[:username],
      created_at:        unique_time('cc_event_service_broker_created'),
      guid:              'event1',
      id:                unique_id('cc_event_service_broker'),
      metadata:          '{}',
      organization_guid: '',
      space_guid:        '',
      timestamp:         unique_time('cc_event_service_broker_timestamp'),
      type:              'audit.service_broker.create',
      updated_at:        unique_time('cc_event_service_broker_updated')
    }
  end

  def cc_event_service_dashboard_client
    {
      actee:             uaa_client[:client_id],
      actee_name:        uaa_client[:client_id],
      actee_type:        'service_dashboard_client',
      actor:             cc_service_broker[:guid],
      actor_name:        cc_service_broker[:name],
      actor_type:        'service_broker',
      actor_username:    nil,
      created_at:        unique_time('cc_event_service_dashboard_client_created'),
      guid:              'event1',
      id:                unique_id('cc_event_service_dashboard_client'),
      metadata:          '{}',
      organization_guid: '',
      space_guid:        '',
      timestamp:         unique_time('cc_event_service_dashboard_client_timestamp'),
      type:              'audit.service_dashboard_client.create',
      updated_at:        unique_time('cc_event_service_dashboard_client_updated')
    }
  end

  def cc_event_service_instance
    {
      actee:             cc_service_instance[:guid],
      actee_name:        cc_service_instance[:name],
      actee_type:        'service_instance',
      actor:             cc_user[:guid],
      actor_name:        uaa_user[:email],
      actor_type:        'user',
      actor_username:    uaa_user[:username],
      created_at:        unique_time('cc_event_service_instance_created'),
      guid:              'event1',
      id:                unique_id('cc_event_service_instance'),
      metadata:          '{}',
      organization_guid: cc_organization[:guid],
      space_guid:        cc_space[:guid],
      timestamp:         unique_time('cc_event_service_instance_timestamp'),
      type:              'audit.service_instance.create',
      updated_at:        unique_time('cc_event_service_instance_updated')
    }
  end

  def cc_event_service_key
    {
      actee:             cc_service_key[:guid],
      actee_name:        cc_service_key[:name],
      actee_type:        'service_key',
      actor:             cc_user[:guid],
      actor_name:        uaa_user[:email],
      actor_type:        'user',
      actor_username:    uaa_user[:username],
      created_at:        unique_time('cc_event_service_key_created'),
      guid:              'event1',
      id:                unique_id('cc_event_service_key'),
      metadata:          '{}',
      organization_guid: cc_organization[:guid],
      space_guid:        cc_space[:guid],
      timestamp:         unique_time('cc_event_service_key_timestamp'),
      type:              'audit.service_key.create',
      updated_at:        unique_time('cc_event_service_key_updated')
    }
  end

  def cc_event_service_plan
    {
      actee:             cc_service_plan[:guid],
      actee_name:        cc_service_plan[:name],
      actee_type:        'service_plan',
      actor:             cc_service_broker[:guid],
      actor_name:        cc_service_broker[:name],
      actor_type:        'service_broker',
      actor_username:    nil,
      created_at:        unique_time('cc_event_service_plan_created'),
      guid:              'event1',
      id:                unique_id('cc_event_service_plan'),
      metadata:          '{}',
      organization_guid: '',
      space_guid:        '',
      timestamp:         unique_time('cc_event_service_plan_timestamp'),
      type:              'audit.service_plan.create',
      updated_at:        unique_time('cc_event_service_plan_updated')
    }
  end

  def cc_event_service_plan_visibility
    {
      actee:             cc_service_plan_visibility[:guid],
      actee_name:        nil,
      actee_type:        'service_plan_visibility',
      actor:             cc_user[:guid],
      actor_name:        uaa_user[:email],
      actor_type:        'user',
      actor_username:    uaa_user[:username],
      created_at:        unique_time('cc_event_service_plan_visibility_created'),
      guid:              'event1',
      id:                unique_id('cc_event_service_plan_visibility'),
      metadata:          '{}',
      organization_guid: cc_organization[:guid],
      space_guid:        '',
      timestamp:         unique_time('cc_event_service_plan_visibility_timestamp'),
      type:              'audit.service_plan_visibility.create',
      updated_at:        unique_time('cc_event_service_plan_visibility_updated')
    }
  end

  def cc_event_space
    {
      actee:             cc_space[:guid],
      actee_name:        cc_space[:name],
      actee_type:        'space',
      actor:             cc_user[:guid],
      actor_name:        uaa_user[:email],
      actor_type:        'user',
      actor_username:    uaa_user[:username],
      created_at:        unique_time('cc_event_space_created'),
      guid:              'event1',
      id:                unique_id('cc_event_space'),
      metadata:          '{}',
      organization_guid: cc_organization[:guid],
      space_guid:        cc_space[:guid],
      timestamp:         unique_time('cc_event_space_timestamp'),
      type:              'audit.space.create',
      updated_at:        unique_time('cc_event_space_updated')
    }
  end

  def cc_feature_flag
    {
      created_at:    unique_time('cc_feature_flag_created'),
      enabled:       true,
      error_message: 'feature flag error message',
      guid:          'feature1',
      id:            unique_id('cc_feature_flag'),
      name:          'app_scaling',
      updated_at:    unique_time('cc_feature_flag_updated')
    }
  end

  def cc_info_api_version
    '2.153.0'
  end

  def cc_info_build
    '2222'
  end

  def cc_info_name
    'Cloud Foundry'
  end

  def cc_info_osbapi_version
    '2.15'
  end

  def cc_info_token_endpoint
    'http://token_endpoint.com'
  end

  # /v2/info returned from the system is not symbols
  def cc_info
    {
      'api_version'              => cc_info_api_version,
      'authorization_endpoint'   => 'http://authorization_endpoint.com',
      'build'                    => cc_info_build,
      'doppler_logging_endpoint' => 'wss://doppler_logging_endpoint.com',
      'name'                     => cc_info_name,
      'osbapi_version'           => cc_info_osbapi_version,
      'token_endpoint'           => cc_info_token_endpoint
    }
  end

  def cc_isolation_segment
    {
      created_at:          unique_time('cc_isolation_segment_created'),
      guid:                'isolation_segment1',
      id:                  unique_id('cc_isolation_segment'),
      name:                'test_isol',
      updated_at:          unique_time('cc_isolation_segment_updated')
    }
  end

  def cc_isolation_segment_rename
    'renamed_test_isol'
  end

  def cc_isolation_segment2
    {
      created_at:          Time.new,
      guid:                'isolation_segment2',
      id:                  unique_id('cc_isolation_segment2'),
      name:                'new_isol',
      updated_at:          Time.new
    }
  end

  def cc_isolation_segment_annotation
    {
      created_at:    unique_time('cc_isolation_segment_annotation_created'),
      guid:          'isolation_segment_annotation1',
      id:            unique_id('cc_isolation_segment_annotation'),
      key:           'isannotationkey',
      key_prefix:    'isannotationkeyprefix.com',
      resource_guid: cc_isolation_segment[:guid],
      updated_at:    unique_time('cc_isolation_segment_annotation_updated'),
      value:         'isannotationvalue'
    }
  end

  def cc_isolation_segment_label
    {
      created_at:    unique_time('cc_isolation_segment_label_created'),
      guid:          'isolation_segment_label1',
      id:            unique_id('cc_isolation_segment_label'),
      key_name:      'islabelkeyname',
      key_prefix:    'islabelkeyprefix.com',
      resource_guid: cc_isolation_segment[:guid],
      updated_at:    unique_time('cc_isolation_segment_label_updated'),
      value:         'islabelvalue'
    }
  end

  # We cannot initially insert organization with default_isolation_segment_guid due to foreign keys.
  def cc_organization_without_default_isolation_segment_guid
    {
      billing_enabled:                false,
      created_at:                     unique_time('cc_organization_created'),
      default_isolation_segment_guid: nil,
      guid:                           'organization1',
      id:                             unique_id('cc_organization'),
      name:                           'test_org',
      quota_definition_id:            cc_quota_definition[:id],
      status:                         'active',
      updated_at:                     unique_time('cc_organization_updated')
    }
  end

  def cc_organization
    cc_organization_without_default_isolation_segment_guid.merge(default_isolation_segment_guid: cc_isolation_segment[:guid])
  end

  def cc_organization_rename
    'renamed_test_org'
  end

  def cc_organization2
    {
      billing_enabled:                false,
      created_at:                     Time.new,
      guid:                           'organization2',
      id:                             unique_id('cc_organization2'),
      default_isolation_segment_guid: nil,
      name:                           'new_org',
      quota_definition_id:            cc_quota_definition[:id],
      status:                         'active',
      updated_at:                     nil
    }
  end

  def cc_organization_annotation
    {
      created_at:    unique_time('cc_organization_annotation_created'),
      guid:          'organization_annotation1',
      id:            unique_id('cc_organization_annotation'),
      key:           'organnotationkey',
      key_prefix:    'organnotationkeyprefix.com',
      resource_guid: cc_organization[:guid],
      updated_at:    unique_time('cc_organization_annotation_updated'),
      value:         'organnotationvalue'
    }
  end

  def cc_organization_auditor
    {
      created_at:                unique_time('cc_organization_auditor_created'),
      organizations_auditors_pk: unique_id('cc_organization_auditor'),
      organization_id:           cc_organization[:id],
      role_guid:                 'OrgAuditor1',
      updated_at:                unique_time('cc_organization_auditor_updated'),
      user_id:                   cc_user[:id]
    }
  end

  def cc_organization_billing_manager
    {
      created_at:                        unique_time('cc_organization_billing_manager_created'),
      organizations_billing_managers_pk: unique_id('cc_organization_billing_manager'),
      organization_id:                   cc_organization[:id],
      role_guid:                         'OrgBillingManager1',
      updated_at:                        unique_time('cc_organization_billing_manager_updated'),
      user_id:                           cc_user[:id]
    }
  end

  def cc_organization_isolation_segment
    {
      organization_guid:      cc_organization[:guid],
      isolation_segment_guid: cc_isolation_segment[:guid]
    }
  end

  def cc_organization_label
    {
      created_at:    unique_time('cc_organization_label_created'),
      guid:          'organization_label1',
      id:            unique_id('cc_organization_label'),
      key_name:      'orglabelkeyname',
      key_prefix:    'orglabelkeyprefix.com',
      resource_guid: cc_organization[:guid],
      updated_at:    unique_time('cc_organization_label_updated'),
      value:         'orglabelvalue'
    }
  end

  def cc_organization_manager
    {
      created_at:                unique_time('cc_organization_manager_created'),
      organizations_managers_pk: unique_id('cc_organization_manager'),
      organization_id:           cc_organization[:id],
      role_guid:                 'OrgManager1',
      updated_at:                unique_time('cc_organization_manager_updated'),
      user_id:                   cc_user[:id]
    }
  end

  def cc_organization_private_domain
    {
      organizations_private_domains_pk: unique_id('cc_organization_private_domain'),
      organization_id:                  cc_organization[:id],
      private_domain_id:                cc_domain[:id]
    }
  end

  def cc_organization_user
    {
      created_at:             unique_time('cc_organization_user_created'),
      organizations_users_pk: unique_id('cc_organization_user'),
      organization_id:        cc_organization[:id],
      role_guid:              'OrgUser1',
      updated_at:             unique_time('cc_organization_user_updated'),
      user_id:                cc_user[:id]
    }
  end

  def cc_package
    {
      app_guid:     cc_app[:guid],
      created_at:   unique_time('cc_package_created'),
      docker_image: 'cloudfoundry/diego-docker-app:latest',
      error:        nil,
      guid:         'package1',
      id:           unique_id('cc_package'),
      package_hash: 'package_hash1',
      state:        'READY',
      type:         'bits',
      updated_at:   unique_time('cc_package_updated')
    }
  end

  def cc_process
    {
      app_guid:                        cc_app[:guid],
      command:                         'node test.js',
      created_at:                      unique_time('cc_process_created'),
      detected_buildpack:              cc_buildpack[:name],
      diego:                           true,
      disk_quota:                      1024,
      enable_ssh:                      true,
      file_descriptors:                16_384,
      guid:                            'process1',
      health_check_http_endpoint:      'http://health_check_http_endpoint.com',
      health_check_invocation_timeout: 6,
      health_check_timeout:            5,
      health_check_type:               'http',
      id:                              unique_id('cc_process'),
      instances:                       1,
      memory:                          128,
      metadata:                        '{}',
      package_updated_at:              unique_time('cc_process_package_updated'),
      ports:                           '"[8081]"',
      production:                      true,
      state:                           'STARTED',
      type:                            'web',
      updated_at:                      unique_time('cc_process_updated'),
      version:                         '87dc4122-8d26-4801-a98f-87d97cc76976'
    }
  end

  def cc_quota_definition
    {
      app_instance_limit:         10,
      app_task_limit:             10,
      created_at:                 unique_time('cc_quota_definition_created'),
      guid:                       'quota1',
      id:                         unique_id('cc_quota_definition'),
      instance_memory_limit:      512,
      memory_limit:               1024,
      name:                       'test_quota_1',
      non_basic_services_allowed: true,
      total_private_domains:      10,
      total_reserved_route_ports: 100,
      total_routes:               100,
      total_services:             100,
      total_service_keys:         100,
      updated_at:                 unique_time('cc_quota_definition_updated')
    }
  end

  def cc_quota_definition_rename
    'renamed_test_quota_1'
  end

  def cc_quota_definition2
    {
      app_instance_limit:         10,
      app_task_limit:             10,
      created_at:                 Time.new,
      guid:                       'quota2',
      id:                         unique_id('cc_quota_definition2'),
      instance_memory_limit:      512,
      memory_limit:               1024,
      name:                       'test_quota_2',
      non_basic_services_allowed: true,
      total_private_domains:      10,
      total_reserved_route_ports: 100,
      total_routes:               100,
      total_services:             100,
      total_service_keys:         100,
      updated_at:                 nil
    }
  end

  def cc_request_count
    {
      count:       11,
      id:          unique_id('cc_request_count'),
      user_guid:   cc_user[:guid],
      valid_until: unique_time('cc_request_count_valid')
    }
  end

  def cc_route
    {
      created_at: unique_time('cc_route_created'),
      domain_id:  cc_domain[:id],
      guid:       'route1',
      host:       'test_host',
      id:         unique_id('cc_route'),
      path:       '/path1',
      port:       0,
      space_id:   cc_space[:id],
      updated_at: unique_time('cc_route_updated'),
      vip_offset: 1
    }
  end

  def cc_route_annotation
    {
      created_at:    unique_time('cc_route_annotation_created'),
      guid:          'route_annotation1',
      id:            unique_id('cc_route_annotation'),
      key:           'rtannotationkey',
      key_prefix:    'rtannotationkeyprefix.com',
      resource_guid: cc_route[:guid],
      updated_at:    unique_time('cc_route_annotation_updated'),
      value:         'rtannotationvalue'
    }
  end

  def cc_route_binding
    {
      created_at:          unique_time('cc_route_binding_created'),
      guid:                'route_binding1',
      id:                  unique_id('cc_route_binding'),
      route_id:            cc_route[:id],
      route_service_url:   cc_service_instance[:route_service_url],
      service_instance_id: cc_service_instance[:id],
      updated_at:          unique_time('cc_route_binding_updated')
    }
  end

  def cc_route_binding_annotation
    {
      created_at:    unique_time('cc_route_binding_annotation_created'),
      guid:          'route_binding_annotation1',
      id:            unique_id('cc_route_binding_annotation'),
      key:           'rbannotationkey',
      key_prefix:    'rbannotationkeyprefix.com',
      resource_guid: cc_route_binding[:guid],
      updated_at:    unique_time('cc_route_binding_annotation_updated'),
      value:         'rbannotationvalue'
    }
  end

  def cc_route_binding_label
    {
      created_at:    unique_time('cc_route_binding_label_created'),
      guid:          'route_binding_label1',
      id:            unique_id('cc_route_binding_label'),
      key_name:      'rblabelkeyname',
      key_prefix:    'rblabelkeyprefix.com',
      resource_guid: cc_route_binding[:guid],
      updated_at:    unique_time('cc_route_binding_label_updated'),
      value:         'rblabelvalue'
    }
  end

  def cc_route_binding_operation
    {
      broker_provided_operation: 'TestRouteBindingOperation broker operation',
      created_at:                unique_time('cc_route_binding_operation_created'),
      description:               'TestRouteBindingOperation description',
      id:                        unique_id('cc_route_binding_operation'),
      route_binding_id:          cc_route_binding[:id],
      state:                     'succeeded',
      type:                      'create',
      updated_at:                unique_time('cc_route_binding_operation_updated')
    }
  end

  def cc_route_label
    {
      created_at:    unique_time('cc_route_label_created'),
      guid:          'route_label1',
      id:            unique_id('cc_route_label'),
      key_name:      'rtlabelkeyname',
      key_prefix:    'rtlabelkeyprefix.com',
      resource_guid: cc_route[:guid],
      updated_at:    unique_time('cc_route_label_updated'),
      value:         'rtlabelvalue'
    }
  end

  def cc_route_mapping
    {
      app_guid:     cc_app[:guid],
      app_port:     8080,
      created_at:   unique_time('cc_route_mapping_created'),
      guid:         'route_mapping1',
      id:           unique_id('cc_route_mapping'),
      process_type: 'web',
      route_guid:   cc_route[:guid],
      updated_at:   unique_time('cc_route_mapping_updated'),
      weight:       1
    }
  end

  def cc_security_group
    {
      created_at:          unique_time('cc_security_group_created'),
      guid:                'security_group1',
      id:                  unique_id('cc_security_group'),
      name:                'TestSecurityGroup',
      rules:               '[{"destination":"0.0.0.0/0","log":true,"protocol":"tcp","ports":"53","type":1,"code":2}]',
      running_default:     true,
      staging_default:     true,
      updated_at:          unique_time('cc_security_group_updated')
    }
  end

  def cc_security_group_rename
    'renamed_TestSecurityGroup'
  end

  def cc_security_group_space
    {
      security_groups_spaces_pk: unique_id('cc_security_group_space'),
      security_group_id:         cc_security_group[:id],
      space_id:                  cc_space[:id]
    }
  end

  def cc_service_display_name
    'TestService display name'
  end

  def cc_service_provider_display_name
    'TestService prov display name'
  end

  def cc_service_shareable
    true
  end

  def cc_service
    {
      active:                true,
      allow_context_updates: true,
      bindable:              true,
      bindings_retrievable:  true,
      created_at:            unique_time('cc_service_created'),
      description:           'TestService description',
      extra:                 "{\"displayName\":\"#{cc_service_display_name}\",\"documentationUrl\":\"http://documentationUrl.com\",\"imageUrl\":\"http://docs.cloudfoundry.com/images/favicon.ico\",\"longDescription\":\"long description\",\"providerDisplayName\":\"#{cc_service_provider_display_name}\",\"shareable\":#{cc_service_shareable},\"supportUrl\":\"http://supportUrl.com\"}",
      guid:                  'service1',
      id:                    unique_id('cc_service'),
      instances_retrievable: true,
      label:                 'TestService',
      plan_updateable:       true,
      purging:               false,
      requires:              '["syslog_drain", "route_forwarding", "volume_mount"]',
      service_broker_id:     cc_service_broker[:id],
      tags:                  '["service_tag1", "service_tag2"]',
      unique_id:             'service_unique_id',
      updated_at:            unique_time('cc_service_updated')
    }
  end

  def cc_service_offering_annotation
    {
      created_at:    unique_time('cc_service_offering_annotation_created'),
      guid:          'service_offering_annotation1',
      id:            unique_id('cc_service_offering_annotation'),
      key:           'soannotationkey',
      key_prefix:    'soannotationkeyprefix.com',
      resource_guid: cc_service[:guid],
      updated_at:    unique_time('cc_service_offering_annotation_updated'),
      value:         'soannotationvalue'
    }
  end

  def cc_service_offering_label
    {
      created_at:    unique_time('cc_service_offering_label_created'),
      guid:          'service_offering_label1',
      id:            unique_id('cc_service_offering_label'),
      key_name:      'solabelkeyname',
      key_prefix:    'solabelkeyprefix.com',
      resource_guid: cc_service[:guid],
      updated_at:    unique_time('cc_service_offering_label_updated'),
      value:         'solabelvalue'
    }
  end

  def cc_service_binding
    {
      app_guid:              cc_app[:guid],
      created_at:            unique_time('cc_service_binding_created'),
      guid:                  'service_binding1',
      id:                    unique_id('cc_service_binding'),
      name:                  'TestServiceBinding',
      service_instance_guid: cc_service_instance[:guid],
      syslog_drain_url:      'http://service_binding_syslog_drain_url.com',
      updated_at:            unique_time('cc_service_binding_updated')
    }
  end

  def cc_service_binding_credential
    {
      'service_binding_key' => 'service_binding_value'
    }
  end

  # We do not retrieve credentials, but it is required for insert
  def cc_service_binding_with_credentials
    cc_service_binding.merge(credentials: cc_service_binding_credential)
  end

  def cc_service_binding_annotation
    {
      created_at:    unique_time('cc_service_binding_annotation_created'),
      guid:          'service_binding_annotation1',
      id:            unique_id('cc_service_binding_annotation'),
      key:           'sbannotationkey',
      key_prefix:    'sbannotationkeyprefix.com',
      resource_guid: cc_service_binding[:guid],
      updated_at:    unique_time('cc_service_binding_annotation_updated'),
      value:         'sbannotationvalue'
    }
  end

  def cc_service_binding_label
    {
      created_at:    unique_time('cc_service_binding_label_created'),
      guid:          'service_binding_label1',
      id:            unique_id('cc_service_binding_label'),
      key_name:      'sblabelkeyname',
      key_prefix:    'sblabelkeyprefix.com',
      resource_guid: cc_service_binding[:guid],
      updated_at:    unique_time('cc_service_binding_label_updated'),
      value:         'sblabelvalue'
    }
  end

  def cc_service_binding_operation
    {
      broker_provided_operation: 'TestServiceBindingOperation broker operation',
      created_at:                unique_time('cc_service_binding_operation_created'),
      description:               'TestServiceBindingOperation description',
      id:                        unique_id('cc_service_binding_operation'),
      service_binding_id:        cc_service_binding[:id],
      state:                     'succeeded',
      type:                      'create',
      updated_at:                unique_time('cc_service_binding_operation_updated')
    }
  end

  def cc_service_binding_volume_mounts
    [
      {
        'container_dir' => 'container_dir1',
        'device_type'   => 'device_type1',
        'mode'          => 'bogus mode1'
      }
    ]
  end

  def cc_service_broker
    {
      auth_username: 'username',
      broker_url:    'http://broker_url.com',
      created_at:    unique_time('cc_service_broker_created'),
      guid:          'service_broker1',
      id:            unique_id('cc_service_broker'),
      name:          'TestServiceBroker',
      space_id:      cc_space[:id],
      state:         'AVAILABLE',
      updated_at:    unique_time('cc_service_broker_updated')
    }
  end

  # We do not retrieve auth_password, but it is required for insert
  def cc_service_broker_with_password
    cc_service_broker.merge(auth_password: 'password')
  end

  def cc_service_broker_rename
    'renamed_TestServiceBroker'
  end

  def cc_service_broker_annotation
    {
      created_at:    unique_time('cc_service_broker_annotation_created'),
      guid:          'service_broker_annotation1',
      id:            unique_id('cc_service_broker_annotation'),
      key:           'sbannotationkey',
      key_prefix:    'sbannotationkeyprefix.com',
      resource_guid: cc_service_broker[:guid],
      updated_at:    unique_time('cc_service_broker_annotation_updated'),
      value:         'sbannotationvalue'
    }
  end

  def cc_service_broker_label
    {
      created_at:    unique_time('cc_service_broker_label_created'),
      guid:          'service_broker_label1',
      id:            unique_id('cc_service_broker_label'),
      key_name:      'sblabelkeyname',
      key_prefix:    'sblabelkeyprefix.com',
      resource_guid: cc_service_broker[:guid],
      updated_at:    unique_time('cc_service_broker_label_updated'),
      value:         'sblabelvalue'
    }
  end

  def cc_service_dashboard_client
    {
      service_broker_id: cc_service_broker[:id],
      uaa_id:            uaa_client[:client_id]
    }
  end

  def cc_service_instance
    {
      created_at:         unique_time('cc_service_instance_created'),
      guid:               'service_instance1',
      id:                 unique_id('cc_service_instance'),
      dashboard_url:      'http://dashboard_url.com',
      gateway_data:       nil,
      gateway_name:       nil,
      is_gateway_service: true,
      maintenance_info:   '{"description":"ServiceInstance Maintenance Info Description","version":"4.5.6"}',
      name:               'TestServiceInstance',
      route_service_url:  'http://service_instance_route_service_url.com',
      service_plan_id:    cc_service_plan[:id],
      space_id:           cc_space[:id],
      syslog_drain_url:   'http://service_instance_syslog_drain_url.com',
      tags:               '["service_instance_tag1", "service_instance_tag2"]',
      updated_at:         unique_time('cc_service_instance_updated')
    }
  end

  def cc_service_instance_credential
    {
      'service_instance_key' => 'service_instance_value'
    }
  end

  # We do not retrieve credentials, but it is required for insert
  def cc_service_instance_with_credentials
    cc_service_instance.merge(credentials: cc_service_instance_credential)
  end

  def cc_service_instance_rename
    'renamed_TestServiceInstance'
  end

  def cc_service_instance_annotation
    {
      created_at:    unique_time('cc_service_instance_annotation_created'),
      guid:          'service_instance_annotation1',
      id:            unique_id('cc_service_instance_annotation'),
      key:           'siannotationkey',
      key_prefix:    'siannotationkeyprefix.com',
      resource_guid: cc_service_instance[:guid],
      updated_at:    unique_time('cc_service_instance_annotation_updated'),
      value:         'siannotationvalue'
    }
  end

  def cc_service_instance_label
    {
      created_at:    unique_time('cc_service_instance_label_created'),
      guid:          'service_instance_label1',
      id:            unique_id('cc_service_instance_label'),
      key_name:      'silabelkeyname',
      key_prefix:    'silabelkeyprefix.com',
      resource_guid: cc_service_instance[:guid],
      updated_at:    unique_time('cc_service_instance_label_updated'),
      value:         'silabelvalue'
    }
  end

  def cc_service_instance_operation
    {
      broker_provided_operation: 'TestServiceInstanceOperation broker operation',
      created_at:                unique_time('cc_service_instance_operation_created'),
      description:               'TestServiceInstanceOperation description',
      guid:                      'service_instance_operation1',
      id:                        unique_id('cc_service_instance_operation'),
      proposed_changes:          '{}',
      service_instance_id:       cc_service_instance[:id],
      state:                     'succeeded',
      type:                      'create',
      updated_at:                unique_time('cc_service_instance_operation_updated')
    }
  end

  def cc_service_instance_share
    {
      service_instance_guid: cc_service_instance[:guid],
      target_space_guid:     cc_space[:guid]
    }
  end

  def cc_service_key
    {
      created_at:          unique_time('cc_service_key_created'),
      guid:                'service_key1',
      id:                  unique_id('cc_service_key'),
      name:                'TestServiceKey',
      service_instance_id: cc_service_instance[:id],
      updated_at:          unique_time('cc_service_key_updated')
    }
  end

  def cc_service_key_credential
    {
      'service_key_key' => 'service_key_value'
    }
  end

  # We do not retrieve credentials, but it is required for insert
  def cc_service_key_with_credentials
    cc_service_key.merge(credentials: cc_service_key_credential)
  end

  def cc_service_key_annotation
    {
      created_at:    unique_time('cc_service_key_annotation_created'),
      guid:          'service_key_annotation1',
      id:            unique_id('cc_service_key_annotation'),
      key:           'skannotationkey',
      key_prefix:    'skannotationkeyprefix.com',
      resource_guid: cc_service_key[:guid],
      updated_at:    unique_time('cc_service_key_annotation_updated'),
      value:         'skannotationvalue'
    }
  end

  def cc_service_key_label
    {
      created_at:    unique_time('cc_service_key_label_created'),
      guid:          'service_key_label1',
      id:            unique_id('cc_service_key_label'),
      key_name:      'sklabelkeyname',
      key_prefix:    'sklabelkeyprefix.com',
      resource_guid: cc_service_key[:guid],
      updated_at:    unique_time('cc_service_key_label_updated'),
      value:         'sklabelvalue'
    }
  end

  def cc_service_key_operation
    {
      broker_provided_operation: 'TestServiceKeyOperation broker operation',
      created_at:                unique_time('cc_service_key_operation_created'),
      description:               'TestServiceKeyOperation description',
      id:                        unique_id('cc_service_key_operation'),
      service_key_id:            cc_service_key[:id],
      state:                     'succeeded',
      type:                      'create',
      updated_at:                unique_time('cc_service_key_operation_updated')
    }
  end

  def cc_service_plan_display_name
    'TestServicePlan display name'
  end

  def cc_service_plan
    {
      active:                   true,
      bindable:                 true,
      created_at:               unique_time('cc_service_plan_created'),
      create_binding_schema:    '{"key":"value"}',
      create_instance_schema:   '{"key2":"value2"}',
      description:              'TestServicePlan description',
      extra:                    "{\"displayName\":\"#{cc_service_plan_display_name}\",\"bullets\":[\"bullet1\",\"bullet2\"]}",
      free:                     true,
      guid:                     'service_plan1',
      id:                       unique_id('cc_service_plan'),
      maintenance_info:         '{"description":"ServicePlan Maintenance Info Description","version":"1.2.3"}',
      maximum_polling_duration: 1234,
      name:                     'TestServicePlan',
      plan_updateable:          true,
      public:                   true,
      service_id:               cc_service[:id],
      unique_id:                'service_plan_unique_id1',
      update_instance_schema:   '{"key3":"value3"}',
      updated_at:               unique_time('cc_service_plan_updated')
    }
  end

  def cc_service_plan_annotation
    {
      created_at:    unique_time('cc_service_plan_annotation_created'),
      guid:          'service_plan_annotation1',
      id:            unique_id('cc_service_plan_annotation'),
      key:           'spannotationkey',
      key_prefix:    'spannotationkeyprefix.com',
      resource_guid: cc_service_plan[:guid],
      updated_at:    unique_time('cc_service_plan_annotation_updated'),
      value:         'spannotationvalue'
    }
  end

  def cc_service_plan_label
    {
      created_at:    unique_time('cc_service_plan_label_created'),
      guid:          'service_plan_label1',
      id:            unique_id('cc_service_plan_label'),
      key_name:      'splabelkeyname',
      key_prefix:    'splabelkeyprefix.com',
      resource_guid: cc_service_plan[:guid],
      updated_at:    unique_time('cc_service_plan_label_updated'),
      value:         'splabelvalue'
    }
  end

  def cc_service_plan_visibility
    {
      created_at:      unique_time('cc_service_plan_visibility_created'),
      guid:            'service_plan_visibility1',
      id:              unique_id('cc_service_plan_visibility'),
      organization_id: cc_organization[:id],
      service_plan_id: cc_service_plan[:id],
      updated_at:      unique_time('cc_service_plan_visibility_updated')
    }
  end

  def cc_space
    {
      allow_ssh:                 true,
      created_at:                unique_time('cc_space_created'),
      guid:                      'space1',
      id:                        unique_id('cc_space'),
      isolation_segment_guid:    cc_isolation_segment[:guid],
      name:                      'test_space',
      organization_id:           cc_organization[:id],
      space_quota_definition_id: cc_space_quota_definition[:id],
      updated_at:                unique_time('cc_space_updated')
    }
  end

  def cc_space_rename
    'renamed_test_space'
  end

  def cc_space_annotation
    {
      created_at:    unique_time('cc_space_annotation_created'),
      guid:          'space_annotation1',
      id:            unique_id('cc_space_annotation'),
      key:           'spaceannotationkey',
      key_prefix:    'spaceannotationkeyprefix.com',
      resource_guid: cc_space[:guid],
      updated_at:    unique_time('cc_space_annotation_updated'),
      value:         'spaceannotationvalue'
    }
  end

  def cc_space_auditor
    {
      created_at:         unique_time('cc_space_auditor_created'),
      role_guid:          'SpaceAuditor1',
      spaces_auditors_pk: unique_id('cc_space_auditor'),
      space_id:           cc_space[:id],
      updated_at:         unique_time('cc_space_auditor_updated'),
      user_id:            cc_user[:id]
    }
  end

  def cc_space_developer
    {
      created_at:           unique_time('cc_space_developer_created'),
      role_guid:            'SpaceDeveloper1',
      spaces_developers_pk: unique_id('cc_space_developer'),
      space_id:             cc_space[:id],
      updated_at:           unique_time('cc_space_developer_updated'),
      user_id:              cc_user[:id]
    }
  end

  def cc_space_label
    {
      created_at:    unique_time('cc_space_label_created'),
      guid:          'space_label1',
      id:            unique_id('cc_space_label'),
      key_name:      'spacelabelkeyname',
      key_prefix:    'spacelabelkeyprefix.com',
      resource_guid: cc_space[:guid],
      updated_at:    unique_time('cc_space_label_updated'),
      value:         'spacelabelvalue'
    }
  end

  def cc_space_manager
    {
      created_at:         unique_time('cc_space_manager_created'),
      role_guid:          'SpaceManager1',
      spaces_managers_pk: unique_id('cc_space_manager'),
      space_id:           cc_space[:id],
      updated_at:         unique_time('cc_space_manager_updated'),
      user_id:            cc_user[:id]
    }
  end

  def cc_space_quota_definition
    {
      app_instance_limit:         5,
      app_task_limit:             5,
      created_at:                 unique_time('cc_space_quota_definition_created'),
      guid:                       'space_quota1',
      id:                         unique_id('cc_space_quota_definition'),
      instance_memory_limit:      512,
      memory_limit:               1024,
      name:                       'test_space_quota_1',
      organization_id:            cc_organization[:id],
      non_basic_services_allowed: true,
      total_reserved_route_ports: 100,
      total_routes:               100,
      total_services:             100,
      total_service_keys:         100,
      updated_at:                 unique_time('cc_space_quota_definition_updated')
    }
  end

  def cc_space_quota_definition_rename
    'renamed_test_s_q_1' # Name needs to be 20 characters or less or the UI will truncate
  end

  def cc_space_quota_definition2
    {
      app_instance_limit:         5,
      app_task_limit:             5,
      created_at:                 Time.new,
      guid:                       'space_quota2',
      id:                         unique_id('cc_space_quota_definition2'),
      instance_memory_limit:      512,
      memory_limit:               1024,
      name:                       'test_space_quota_2',
      non_basic_services_allowed: true,
      organization_id:            cc_organization[:id],
      total_reserved_route_ports: 100,
      total_routes:               100,
      total_services:             100,
      total_service_keys:         100,
      updated_at:                 nil
    }
  end

  def cc_stack
    {
      created_at:  unique_time('cc_stack_created'),
      description: 'TestStack description',
      guid:        'stack1',
      id:          unique_id('cc_stack'),
      name:        'cflinuxfs2',
      updated_at:  unique_time('cc_stack_updated')
    }
  end

  def cc_stack_annotation
    {
      created_at:    unique_time('cc_stack_annotation_created'),
      guid:          'stack_annotation1',
      id:            unique_id('cc_stack_annotation'),
      key:           'stackannotationkey',
      key_prefix:    'stackannotationkeyprefix.com',
      resource_guid: cc_stack[:guid],
      updated_at:    unique_time('cc_stack_annotation_updated'),
      value:         'stackannotationvalue'
    }
  end

  def cc_stack_label
    {
      created_at:    unique_time('cc_stack_label_created'),
      guid:          'stack_label1',
      id:            unique_id('cc_stack_label'),
      key_name:      'stacklabelkeyname',
      key_prefix:    'stacklabelkeyprefix.com',
      resource_guid: cc_stack[:guid],
      updated_at:    unique_time('cc_stack_label_updated'),
      value:         'stacklabelvalue'
    }
  end

  def cc_staging_security_group_space
    {
      staging_security_groups_spaces_pk: unique_id('cc_staging_security_group_space'),
      staging_security_group_id:         cc_security_group[:id],
      staging_space_id:                  cc_space[:id]
    }
  end

  def cc_task
    {
      app_guid:       cc_app[:guid],
      command:        'bogus command',
      created_at:     unique_time('cc_task_created'),
      disk_in_mb:     1_024,
      droplet_guid:   cc_droplet[:guid],
      failure_reason: 'Unable to request task to be run',
      guid:           'task1',
      id:             unique_id('cc_task'),
      memory_in_mb:   128,
      name:           'test_task',
      sequence_id:    4,
      state:          'RUNNING',
      updated_at:     unique_time('cc_task_updated')
    }
  end

  def cc_task_annotation
    {
      created_at:    unique_time('cc_task_annotation_created'),
      guid:          'task_annotation1',
      id:            unique_id('cc_task_annotation'),
      key:           'taskannotationkey',
      key_prefix:    'taskannotationkeyprefix.com',
      resource_guid: cc_task[:guid],
      updated_at:    unique_time('cc_task_annotation_updated'),
      value:         'taskannotationvalue'
    }
  end

  def cc_task_label
    {
      created_at:    unique_time('cc_task_label_created'),
      guid:          'task_label1',
      id:            unique_id('cc_task_label'),
      key_name:      'tasklabelkeyname',
      key_prefix:    'tasklabelkeyprefix.com',
      resource_guid: cc_task[:guid],
      updated_at:    unique_time('cc_task_label_updated'),
      value:         'tasklabelvalue'
    }
  end

  def cc_user
    {
      active:           true,
      admin:            false,
      created_at:       unique_time('cc_user_created'),
      default_space_id: cc_space[:id],
      guid:             uaa_user[:id],
      id:               unique_id('cc_user'),
      updated_at:       unique_time('cc_user_updated')
    }
  end

  def cc_user_annotation
    {
      created_at:    unique_time('cc_user_annotation_created'),
      guid:          'user_annotation1',
      id:            unique_id('cc_user_annotation'),
      key:           'userannotationkey',
      key_prefix:    'userannotationkeyprefix.com',
      resource_guid: cc_user[:guid],
      updated_at:    unique_time('cc_user_annotation_updated'),
      value:         'userannotationvalue'
    }
  end

  def cc_user_label
    {
      created_at:    unique_time('cc_user_label_created'),
      guid:          'user_label1',
      id:            unique_id('cc_user_label'),
      key_name:      'userlabelkeyname',
      key_prefix:    'userlabelkeyprefix.com',
      resource_guid: cc_user[:guid],
      updated_at:    unique_time('cc_user_label_updated'),
      value:         'userlabelvalue'
    }
  end

  def uaa_approval
    {
      client_id:        uaa_client[:client_id],
      expiresat:        unique_time('uaa_appoval_expires'),
      identity_zone_id: uaa_identity_zone[:id],
      lastmodifiedat:   unique_time('uaa_appoval_last'),
      scope:            uaa_client[:scope],
      status:           'APPROVED',
      user_id:          uaa_user[:id]
    }
  end

  def uaa_client_autoapprove
    true
  end

  def uaa_client
    {
      access_token_validity:   1_209_600,
      additional_information:  "{\"autoapprove\":#{uaa_client_autoapprove}}",
      app_launch_url:          'http://app_launch_url.com',
      authorities:             'auth1',
      authorized_grant_types:  'grant1',
      autoapprove:             uaa_client_autoapprove.to_s,
      client_id:               'client1',
      identity_zone_id:        uaa_identity_zone[:id],
      lastmodified:            unique_time('uaa_client_last'),
      refresh_token_validity:  2_592_000,
      required_user_groups:    'scope1',
      scope:                   'scope1',
      show_on_home_page:       false,
      web_server_redirect_uri: 'http://redirect_uri.com'
    }
  end

  def uaa_group
    {
      created:          unique_time('uaa_group_created'),
      description:      'TestGroup description',
      displayname:      'group1',
      id:               'group1',
      identity_zone_id: uaa_identity_zone[:id],
      lastmodified:     unique_time('uaa_group_last'),
      version:          5
    }
  end

  def uaa_group_membership
    {
      added:            unique_time('uaa_group_membership_added'),
      group_id:         uaa_group[:id],
      id:               unique_id('uaa_group_membership'),
      identity_zone_id: uaa_identity_zone[:id],
      member_id:        uaa_user[:id]
    }
  end

  def uaa_identity_provider
    {
      active:           true,
      config:           '{"key1":"value1","key2":"value2"}',
      created:          unique_time('uaa_identity_provider_created'),
      id:               'identity_provider1',
      identity_zone_id: uaa_identity_zone[:id],
      lastmodified:     unique_time('uaa_identity_provider_last'),
      name:             'identity_provider_name',
      origin_key:       'identity_provider_origin_key1',
      type:             'identity_provider_type1',
      version:          5
    }
  end

  def uaa_identity_zone
    {
      active:       true,
      config:       '{"tokenPolicy":{"accessTokenValidity":43200,"refreshTokenValidity":2592000,"keys":{}},"samlConfig":{"requestSigned":false,"wantAssertionSigned":false,"certificate":null,"privateKey":null}}',
      created:      unique_time('uaa_identity_zone_created'),
      description:  'Identity zone description',
      id:           'identity_zone1',
      lastmodified: unique_time('uaa_identity_zone_last'),
      name:         'identity_zone_name',
      subdomain:    'identity_zone_subdomain',
      version:      5
    }
  end

  def uaa_info_app_version
    '4.120.0'
  end

  # /info returned from the UAA system is not symbols
  def uaa_info
    {
      'app' =>
      {
        'version' => uaa_info_app_version
      }
    }
  end

  def uaa_mfa_provider
    {
      config:           '{"algorithm":"SHA256","digits":6,"duration":30,"issuer":"uaa","providerDescription":"Test MFA for default zone"}',
      created:          unique_time('uaa_mfa_provider_created'),
      id:               'mfa_provider1',
      identity_zone_id: uaa_identity_zone[:id],
      lastmodified:     unique_time('uaa_mfa_provider_last'),
      name:             'mfa_provider_name',
      type:             'mfa_provider_type1'
    }
  end

  def uaa_revocable_token
    {
      client_id:        uaa_client[:client_id],
      expires_at:       unique_time('uaa_revocable_token_expires_at').to_f * 1000,
      format:           'JWT',
      identity_zone_id: uaa_identity_zone[:id],
      response_type:    'ACCESS_TOKEN',
      issued_at:        unique_time('uaa_revocable_token_issued_at').to_f * 1000,
      scope:            '[scope1]',
      token_id:         'revocable_token1',
      user_id:          uaa_user[:id]
    }
  end

  # We do not retrieve data, but it is required for insert
  def uaa_revocable_token_with_data
    uaa_revocable_token.merge(data: '')
  end

  def uaa_service_provider
    {
      active:              true,
      created:             unique_time('uaa_service_provider_created'),
      entity_id:           'test.cloudfoundry-saml-login',
      id:                  'service_provider1',
      identity_zone_id:    uaa_identity_zone[:id],
      name:                'service_provider_name',
      lastmodified:        unique_time('uaa_service_provider_last'),
      version:             5
    }
  end

  def uaa_user
    {
      active:                      true,
      created:                     unique_time('uaa_user_created'),
      email:                       'admin@something.com',
      familyname:                  'Flintstone',
      givenname:                   'Fred',
      id:                          'user1',
      identity_zone_id:            uaa_identity_zone[:id],
      lastmodified:                unique_time('uaa_user_last'),
      last_logon_success_time:     unique_time('uaa_user_last_login_success_time').to_f * 1000,
      passwd_change_required:      false,
      passwd_lastmodified:         unique_time('uaa_user_passwd'),
      phonenumber:                 '012-345-6789',
      previous_logon_success_time: unique_time('uaa_user_previous_login_success_time').to_f * 1000,
      username:                    'admin',
      verified:                    true,
      version:                     5
    }
  end

  # We do not retrieve password, but it is required for insert
  def uaa_user_with_password
    uaa_user.merge(password: 'password')
  end

  private

  def uaa_oauth
    {
      'token_type'   => 'bearer',
      'access_token' => 'bogus'
    }
  end

  def ccdb_inserts(insert_second_quota_definition, event_type, use_route)
    result = [
               [:buildpacks,                       cc_buildpack],
               [:buildpack_annotations,            cc_buildpack_annotation],
               [:buildpack_labels,                 cc_buildpack_label],
               [:env_groups,                       cc_env_group],
               [:feature_flags,                    cc_feature_flag],
               [:quota_definitions,                cc_quota_definition],
               [:security_groups,                  cc_security_group],
               [:service_dashboard_clients,        cc_service_dashboard_client],
               [:stacks,                           cc_stack],
               [:stack_annotations,                cc_stack_annotation],
               [:stack_labels,                     cc_stack_label],
               [:isolation_segments,               cc_isolation_segment],
               [:isolation_segment_annotations,    cc_isolation_segment_annotation],
               [:isolation_segment_labels,         cc_isolation_segment_label],
               [:organizations,                    cc_organization_without_default_isolation_segment_guid],
               [:organization_annotations,         cc_organization_annotation],
               [:organization_labels,              cc_organization_label],
               [:organizations_isolation_segments, cc_organization_isolation_segment],
               [:domains,                          cc_domain],
               [:domain_annotations,               cc_domain_annotation],
               [:domain_labels,                    cc_domain_label],
               [:space_quota_definitions,          cc_space_quota_definition],
               [:organizations_private_domains,    cc_organization_private_domain],
               [:spaces,                           cc_space],
               [:space_annotations,                cc_space_annotation],
               [:space_labels,                     cc_space_label],
               [:security_groups_spaces,           cc_security_group_space],
               [:staging_security_groups_spaces,   cc_staging_security_group_space],
               [:apps,                             cc_app],
               [:app_annotations,                  cc_app_annotation],
               [:app_labels,                       cc_app_label],
               [:processes,                        cc_process],
               [:packages,                         cc_package],
               [:droplets,                         cc_droplet],
               [:buildpack_lifecycle_data,         cc_buildpack_lifecycle_data],
               [:routes,                           cc_route],
               [:route_annotations,                cc_route_annotation],
               [:route_labels,                     cc_route_label],
               [:service_brokers,                  cc_service_broker_with_password],
               [:service_broker_annotations,       cc_service_broker_annotation],
               [:service_broker_labels,            cc_service_broker_label],
               [:users,                            cc_user],
               [:user_annotations,                 cc_user_annotation],
               [:user_labels,                      cc_user_label],
               [:request_counts,                   cc_request_count],
               [:organizations_auditors,           cc_organization_auditor],
               [:organizations_billing_managers,   cc_organization_billing_manager],
               [:organizations_managers,           cc_organization_manager],
               [:organizations_users,              cc_organization_user],
               [:services,                         cc_service],
               [:service_offering_annotations,     cc_service_offering_annotation],
               [:service_offering_labels,          cc_service_offering_label],
               [:spaces_auditors,                  cc_space_auditor],
               [:spaces_developers,                cc_space_developer],
               [:spaces_managers,                  cc_space_manager],
               [:service_plans,                    cc_service_plan],
               [:service_plan_annotations,         cc_service_plan_annotation],
               [:service_plan_labels,              cc_service_plan_label],
               [:service_instances,                cc_service_instance_with_credentials],
               [:service_instance_annotations,     cc_service_instance_annotation],
               [:service_instance_labels,          cc_service_instance_label],
               [:service_instance_shares,          cc_service_instance_share],
               [:service_plan_visibilities,        cc_service_plan_visibility],
               [:service_bindings,                 cc_service_binding_with_credentials],
               [:service_binding_annotations,      cc_service_binding_annotation],
               [:service_binding_labels,           cc_service_binding_label],
               [:service_instance_operations,      cc_service_instance_operation],
               [:service_binding_operations,       cc_service_binding_operation],
               [:service_keys,                     cc_service_key_with_credentials],
               [:service_key_annotations,          cc_service_key_annotation],
               [:service_key_labels,               cc_service_key_label],
               [:service_key_operations,           cc_service_key_operation],
               [:tasks,                            cc_task],
               [:task_annotations,                 cc_task_annotation],
               [:task_labels,                      cc_task_label]
             ]

    if use_route
      result << [:route_bindings, cc_route_binding]
      result << [:route_binding_annotations, cc_route_binding_annotation]
      result << [:route_binding_labels, cc_route_binding_label]
      result << [:route_binding_operations, cc_route_binding_operation]
      result << [:route_mappings, cc_route_mapping]
    end

    if insert_second_quota_definition
      result << [:quota_definitions, cc_quota_definition2]
      result << [:space_quota_definitions, cc_space_quota_definition2]
    end

    result << [:events, cc_event_app] if event_type == 'app'
    result << [:events, cc_event_organization] if event_type == 'organization'
    result << [:events, cc_event_route] if event_type == 'route'
    result << [:events, cc_event_service] if event_type == 'service'
    result << [:events, cc_event_service_binding] if event_type == 'service_binding'
    result << [:events, cc_event_service_broker] if event_type == 'service_broker'
    result << [:events, cc_event_service_dashboard_client] if event_type == 'service_dashboard_client'
    result << [:events, cc_event_service_instance] if event_type == 'service_instance'
    result << [:events, cc_event_service_key] if event_type == 'service_key'
    result << [:events, cc_event_service_plan] if event_type == 'service_plan'
    result << [:events, cc_event_service_plan_visibility] if event_type == 'service_plan_visibility'
    result << [:events, cc_event_space] if event_type == 'space'

    result
  end

  def uaadb_inserts
    [
      [:identity_zone,        uaa_identity_zone],
      [:identity_provider,    uaa_identity_provider],
      [:groups,               uaa_group],
      [:mfa_providers,        uaa_mfa_provider],
      [:service_provider,     uaa_service_provider],
      [:users,                uaa_user_with_password],
      [:group_membership,     uaa_group_membership],
      [:oauth_client_details, uaa_client],
      [:authz_approvals,      uaa_approval],
      [:revocable_tokens,     uaa_revocable_token_with_data]
    ]
  end

  def cc_app_instance_index
    0
  end

  def cc_app_not_found
    NotFound.new('errors' =>
                 [
                   {
                     'code'   => 100_004,
                     'detail' => "The app name could not be found: #{cc_app[:guid]}",
                     'title'  => 'CF-AppNotFound'
                   }
                 ])
  end

  def cc_app_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/apps/#{cc_app[:guid]}/environment_variables", AdminUI::Utils::HTTP_GET, anything, anything, anything, anything, anything) do
      OK.new({ 'var' => cc_app_environment_variable })
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v2/apps/#{cc_app[:guid]}/restage", AdminUI::Utils::HTTP_POST, anything, anything, anything, anything, anything) do
      if @cc_apps_deleted
        cc_app_not_found
      else
        Created.new
      end
    end

    # Remove metadata
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/apps/#{cc_app[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, anything, anything, anything, anything) do
      if @cc_apps_deleted
        cc_app_not_found
      else
        cc_clear_apps_cache_stub(config)
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/apps/#{cc_app[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, "{\"name\":\"#{cc_app_rename}\"}", anything, anything, anything) do
      if @cc_apps_deleted
        cc_app_not_found
      else
        sql(config.ccdb_uri, "UPDATE apps SET name = '#{cc_app_rename}' WHERE guid = '#{cc_app[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/apps/#{cc_app[:guid]}/actions/stop", AdminUI::Utils::HTTP_POST, anything, anything, anything, anything, anything) do
      if @cc_apps_deleted
        cc_app_not_found
      else
        sql(config.ccdb_uri, "UPDATE apps SET desired_state = 'STOPPED' WHERE guid = '#{cc_app[:guid]}'")
        sql(config.ccdb_uri, "UPDATE processes SET state = 'STOPPED' WHERE app_guid = '#{cc_app[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/apps/#{cc_app[:guid]}/actions/start", AdminUI::Utils::HTTP_POST, anything, anything, anything, anything, anything) do
      if @cc_apps_deleted
        cc_app_not_found
      else
        sql(config.ccdb_uri, "UPDATE apps SET desired_state = 'STARTED' WHERE guid = '#{cc_app[:guid]}'")
        sql(config.ccdb_uri, "UPDATE processes SET state = 'STARTED' WHERE app_guid = '#{cc_app[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v2/apps/#{cc_app[:guid]}", AdminUI::Utils::HTTP_PUT, anything, '{"diego":true}', anything, anything, anything) do
      if @cc_apps_deleted
        cc_app_not_found
      else
        sql(config.ccdb_uri, "UPDATE processes SET diego = 'true' WHERE app_guid = '#{cc_app[:guid]}'")
        Created.new
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v2/apps/#{cc_app[:guid]}", AdminUI::Utils::HTTP_PUT, anything, '{"diego":false}', anything, anything, anything) do
      if @cc_apps_deleted
        cc_app_not_found
      else
        sql(config.ccdb_uri, "UPDATE processes SET diego = 'false' WHERE app_guid = '#{cc_app[:guid]}'")
        Created.new
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/apps/#{cc_app[:guid]}/features/ssh", AdminUI::Utils::HTTP_PATCH, anything, '{"enabled":true}', anything, anything, anything) do
      if @cc_apps_deleted
        cc_app_not_found
      else
        sql(config.ccdb_uri, "UPDATE apps SET enable_ssh = 'true' WHERE guid = '#{cc_app[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/apps/#{cc_app[:guid]}/features/ssh", AdminUI::Utils::HTTP_PATCH, anything, '{"enabled":false}', anything, anything, anything) do
      if @cc_apps_deleted
        cc_app_not_found
      else
        sql(config.ccdb_uri, "UPDATE apps SET enable_ssh = 'false' WHERE guid = '#{cc_app[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/apps/#{cc_app[:guid]}/features/revisions", AdminUI::Utils::HTTP_PATCH, anything, '{"enabled":true}', anything, anything, anything) do
      if @cc_apps_deleted
        cc_app_not_found
      else
        sql(config.ccdb_uri, "UPDATE apps SET revisions_enabled = 'true' WHERE guid = '#{cc_app[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/apps/#{cc_app[:guid]}/features/revisions", AdminUI::Utils::HTTP_PATCH, anything, '{"enabled":false}', anything, anything, anything) do
      if @cc_apps_deleted
        cc_app_not_found
      else
        sql(config.ccdb_uri, "UPDATE apps SET revisions_enabled = 'false' WHERE guid = '#{cc_app[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/apps/#{cc_app[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_apps_deleted
        cc_app_not_found
      else
        cc_clear_apps_cache_stub(config)
        Accepted.new({})
      end
    end

    # Since set of environment variable not supported, assuming PATCH is to delete
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/apps/#{cc_app[:guid]}/environment_variables", AdminUI::Utils::HTTP_PATCH, anything, anything, anything, anything, anything) do
      if @cc_apps_deleted
        cc_app_not_found
      else
        @cc_apps_environment_variables_deleted = true
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v2/apps/#{cc_app[:guid]}/instances/#{cc_app_instance_index}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_apps_deleted
        cc_app_not_found
      else
        cc_clear_apps_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end
  end

  def cc_apps_deleted
    @cc_apps_deleted
  end

  def cc_buildpack_not_found
    NotFound.new('errors' =>
                 [
                   {
                     'code'   => 10_000,
                     'detail' => 'Unknown request',
                     'title'  => 'CF-NotFound'
                   }
                 ])
  end

  def cc_buildpack_stubs(config)
    # Remove metadata
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/buildpacks/#{cc_buildpack[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, anything, anything, anything, anything) do
      if @cc_buildpacks_deleted
        cc_buildpack_not_found
      else
        cc_clear_buildpacks_cache_stub(config)
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/buildpacks/#{cc_buildpack[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, "{\"name\":\"#{cc_buildpack_rename}\"}", anything, anything, anything) do
      if @cc_buildpacks_deleted
        cc_buildpack_not_found
      else
        sql(config.ccdb_uri, "UPDATE buildpacks SET name = '#{cc_buildpack_rename}' WHERE guid = '#{cc_buildpack[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/buildpacks/#{cc_buildpack[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, '{"enabled":true}', anything, anything, anything) do
      if @cc_buildpacks_deleted
        cc_buildpack_not_found
      else
        sql(config.ccdb_uri, "UPDATE buildpacks SET enabled = 'true' WHERE guid = '#{cc_buildpack[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/buildpacks/#{cc_buildpack[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, '{"enabled":false}', anything, anything, anything) do
      if @cc_buildpacks_deleted
        cc_buildpack_not_found
      else
        sql(config.ccdb_uri, "UPDATE buildpacks SET enabled = 'false' WHERE guid = '#{cc_buildpack[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/buildpacks/#{cc_buildpack[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, '{"locked":true}', anything, anything, anything) do
      if @cc_buildpacks_deleted
        cc_buildpack_not_found
      else
        sql(config.ccdb_uri, "UPDATE buildpacks SET locked = 'true' WHERE guid = '#{cc_buildpack[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/buildpacks/#{cc_buildpack[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, '{"locked":false}', anything, anything, anything) do
      if @cc_buildpacks_deleted
        cc_buildpack_not_found
      else
        sql(config.ccdb_uri, "UPDATE buildpacks SET locked = 'false' WHERE guid = '#{cc_buildpack[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/buildpacks/#{cc_buildpack[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_buildpacks_deleted
        cc_buildpack_not_found
      else
        cc_clear_buildpacks_cache_stub(config)
        Accepted.new({})
      end
    end
  end

  def cc_domain_not_found
    NotFound.new('errors' =>
                 [
                   {
                     'code'   => 130_002,
                     'detail' => "The domain could not be found: #{cc_domain[:guid]}",
                     'title'  => 'CF-DomainNotFound'
                   }
                 ])
  end

  def cc_domain_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/domains/#{cc_domain[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_domains_deleted
        cc_domain_not_found
      else
        cc_clear_domains_cache_stub(config)
        Accepted.new({})
      end
    end

    # Remove metadata
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/domains/#{cc_domain[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, anything, anything, anything, anything) do
      if @cc_domains_deleted
        cc_domain_not_found
      else
        cc_clear_domains_cache_stub(config)
        OK.new({})
      end
    end
  end

  def cc_env_group_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/environment_variable_groups/#{cc_env_group[:name]}", AdminUI::Utils::HTTP_GET, anything, anything, anything, anything, anything) do
      OK.new('var' => cc_env_group_variable)
    end
  end

  def cc_feature_flag_not_found
    NotFound.new('errors' =>
                 [
                   {
                     'code'   => 330_000,
                     'detail' => "The feature flag could not be found: #{cc_feature_flag[:name]}",
                     'title'  => 'CF-FeatureFlagNotFound'
                   }
                 ])
  end

  def cc_feature_flag_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/feature_flags/#{cc_feature_flag[:name]}", AdminUI::Utils::HTTP_PATCH, anything, '{"enabled":true}', anything, anything, anything) do
      if @cc_feature_flags_deleted
        cc_feature_flag_not_found
      else
        sql(config.ccdb_uri, "UPDATE feature_flags SET enabled = 'true' WHERE name= '#{cc_feature_flag[:name]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/feature_flags/#{cc_feature_flag[:name]}", AdminUI::Utils::HTTP_PATCH, anything, '{"enabled":false}', anything, anything, anything) do
      if @cc_feature_flags_deleted
        cc_feature_flag_not_found
      else
        sql(config.ccdb_uri, "UPDATE feature_flags SET enabled = 'false' WHERE name= '#{cc_feature_flag[:name]}'")
        OK.new({})
      end
    end
  end

  def cc_isolation_segment_not_found
    NotFound.new('errors' =>
                 [
                   {
                     'code'   => 10_010,
                     'detail' => 'Isolation segment not found',
                     'title'  => 'CF-ResourceNotFound'
                   }
                 ])
  end

  def cc_isolation_segment_taken
    BadRequest.new('errors' =>
                   [
                     {
                       'code'   => 10_008,
                       'detail' => 'The request is semantically invalid: Isolation Segment names are case insensitive and must be unique',
                       'title'  => 'CF-UnprocessableEntity'
                     }
                   ])
  end

  def cc_isolation_segment_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/isolation_segments", AdminUI::Utils::HTTP_POST, anything, "{\"name\":\"#{cc_isolation_segment2[:name]}\"}", anything, anything, anything) do
      if @cc_isolation_segment_created
        cc_isolation_segment_taken
      else
        Sequel.connect(config.ccdb_uri, single_threaded: true, max_connections: 1, timeout: 1) do |connection|
          items = connection[:isolation_segments]
          loop do
            items.insert(cc_isolation_segment2)
            break
          rescue Sequel::DatabaseError => error
            wrapped_exception = error.wrapped_exception
            raise unless wrapped_exception && wrapped_exception.instance_of?(SQLite3::BusyException)
          end
        end
        @cc_isolation_segment_created = true
        Created.new
      end
    end

    # Remove metadata
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/isolation_segments/#{cc_isolation_segment[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, anything, anything, anything, anything) do
      if @cc_isolation_segments_deleted
        cc_isolation_segment_not_found
      else
        cc_clear_isolation_segments_cache_stub(config)
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/isolation_segments/#{cc_isolation_segment[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, "{\"name\":\"#{cc_isolation_segment_rename}\"}", anything, anything, anything) do
      if @cc_isolation_segments_deleted
        cc_isolation_segment_not_found
      else
        sql(config.ccdb_uri, "UPDATE isolation_segments SET name = '#{cc_isolation_segment_rename}' WHERE guid = '#{cc_isolation_segment[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/isolation_segments/#{cc_isolation_segment[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_isolation_segments_deleted
        cc_isolation_segment_not_found
      else
        cc_clear_isolation_segments_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/isolation_segments/#{cc_isolation_segment[:guid]}/relationships/organizations/#{cc_organization[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_isolation_segments_deleted
        cc_isolation_segment_not_found
      else
        cc_clear_organizations_isolation_segments_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end
  end

  def cc_login_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v2/info", AdminUI::Utils::HTTP_GET) do
      OK.new(cc_info)
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{cc_info_token_endpoint}/info", AdminUI::Utils::HTTP_GET) do
      OK.new(uaa_info)
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{cc_info_token_endpoint}/oauth/token", AdminUI::Utils::HTTP_POST, anything, anything, anything, anything) do
      OK.new(uaa_oauth)
    end
  end

  def cc_organization_not_found
    NotFound.new('errors' =>
                 [
                   {
                     'code'   => 30_003,
                     'detail' => "The organization could not be found: #{cc_organization[:guid]}",
                     'title'  => 'CF-OrganizationNotFound'
                   }
                 ])
  end

  def cc_organization_taken
    BadRequest.new('errors' =>
                   [
                     {
                       'code'   => 30_002,
                       'detail' => "The organization name is taken: #{cc_organization2[:name]}",
                       'title'  => 'CF-OrganizationNameTaken'
                     }
                   ])
  end

  def cc_organization_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/organizations", AdminUI::Utils::HTTP_POST, anything, "{\"name\":\"#{cc_organization2[:name]}\"}", anything, anything, anything) do
      if @cc_organization_created
        cc_organization_taken
      else
        Sequel.connect(config.ccdb_uri, single_threaded: true, max_connections: 1, timeout: 1) do |connection|
          items = connection[:organizations]
          loop do
            items.insert(cc_organization2)
            break
          rescue Sequel::DatabaseError => error
            wrapped_exception = error.wrapped_exception
            raise unless wrapped_exception && wrapped_exception.instance_of?(SQLite3::BusyException)
          end
        end
        @cc_organization_created = true
        Created.new
      end
    end

    # Remove metadata
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/organizations/#{cc_organization[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, anything, anything, anything, anything) do
      if @cc_organizations_deleted
        cc_organization_not_found
      else
        cc_clear_organizations_cache_stub(config)
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/organizations/#{cc_organization[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, "{\"name\":\"#{cc_organization_rename}\"}", anything, anything, anything) do
      if @cc_organizations_deleted
        cc_organization_not_found
      else
        sql(config.ccdb_uri, "UPDATE organizations SET name = '#{cc_organization_rename}' WHERE guid = '#{cc_organization[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/organizations/#{cc_organization[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, '{"suspended":true}', anything, anything, anything) do
      if @cc_organizations_deleted
        cc_organization_not_found
      else
        sql(config.ccdb_uri, "UPDATE organizations SET status = 'suspended' WHERE guid = '#{cc_organization[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/organizations/#{cc_organization[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, '{"suspended":false}', anything, anything, anything) do
      if @cc_organizations_deleted
        cc_organization_not_found
      else
        sql(config.ccdb_uri, "UPDATE organizations SET status = 'active' WHERE guid = '#{cc_organization[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/organization_quotas/#{cc_quota_definition2[:guid]}/relationships/organizations", AdminUI::Utils::HTTP_POST, anything, "{\"data\":[{\"guid\":\"#{cc_organization[:guid]}\"}]}", anything, anything, anything) do
      if @cc_organizations_deleted
        cc_organization_not_found
      else
        sql(config.ccdb_uri, "UPDATE organizations SET quota_definition_id = (SELECT id FROM quota_definitions WHERE guid = '#{cc_quota_definition2[:guid]}')")
        Created.new
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/organizations/#{cc_organization[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_organizations_deleted
        cc_organization_not_found
      else
        cc_clear_organizations_cache_stub(config)
        Accepted.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/organizations/#{cc_organization[:guid]}/relationships/default_isolation_segment", AdminUI::Utils::HTTP_PATCH, anything, anything, anything, anything, anything) do
      if @cc_organizations_deleted
        cc_organization_not_found
      else
        sql(config.ccdb_uri, "UPDATE organizations SET default_isolation_segment_guid = NULL WHERE guid = '#{cc_organization[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/roles/#{cc_organization_auditor[:role_guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_organizations_deleted
        cc_organization_not_found
      else
        sql(config.ccdb_uri, "DELETE FROM organizations_auditors WHERE organization_id = '#{cc_organization[:id]}' AND user_id = '#{cc_user[:id]}'")
        Accepted.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/roles/#{cc_organization_billing_manager[:role_guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_organizations_deleted
        cc_organization_not_found
      else
        sql(config.ccdb_uri, "DELETE FROM organizations_billing_managers WHERE organization_id = '#{cc_organization[:id]}' AND user_id = '#{cc_user[:id]}'")
        Accepted.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/roles/#{cc_organization_manager[:role_guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_organizations_deleted
        cc_organization_not_found
      else
        sql(config.ccdb_uri, "DELETE FROM organizations_managers WHERE organization_id = '#{cc_organization[:id]}' AND user_id = '#{cc_user[:id]}'")
        Accepted.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/roles/#{cc_organization_user[:role_guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_organizations_deleted
        cc_organization_not_found
      else
        sql(config.ccdb_uri, "DELETE FROM organizations_users WHERE organization_id = '#{cc_organization[:id]}' AND user_id = '#{cc_user[:id]}'")
        Accepted.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/domains/#{cc_domain[:guid]}/relationships/shared_organizations/#{cc_organization[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_organizations_deleted
        cc_organization_not_found
      else
        sql(config.ccdb_uri, "DELETE FROM organizations_private_domains WHERE organization_id = '#{cc_organization[:id]}' AND private_domain_id = '#{cc_domain[:id]}'")
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end
  end

  def cc_quota_definition_not_found
    NotFound.new('errors' =>
                 [
                   {
                     'code'   => 240_001,
                     'detail' => "Quota Definition could not be found: #{cc_quota_definition[:guid]}",
                     'title'  => 'CF-QuotaDefinitionNotFound'
                   }
                 ])
  end

  def cc_quota_definition_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/organization_quotas/#{cc_quota_definition[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, "{\"name\":\"#{cc_quota_definition_rename}\"}", anything, anything, anything) do
      if @cc_quota_definitions_deleted
        cc_quota_definition_not_found
      else
        sql(config.ccdb_uri, "UPDATE quota_definitions SET name = '#{cc_quota_definition_rename}' WHERE guid = '#{cc_quota_definition[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/organization_quotas/#{cc_quota_definition[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_quota_definitions_deleted
        cc_quota_definition_not_found
      else
        cc_clear_quota_definitions_cache_stub(config)
        Accepted.new({})
      end
    end
  end

  def cc_route_not_found
    NotFound.new('errors' =>
                 [
                   {
                     'code'   => 210_002,
                     'detail' => "The route could not be found: #{cc_route[:guid]}",
                     'title'  => 'CF-RouteNotFound'
                   }
                 ])
  end

  def cc_route_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/routes/#{cc_route[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_routes_deleted
        cc_route_not_found
      else
        cc_clear_routes_cache_stub(config)
        Accepted.new({})
      end
    end

    # Remove metadata
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/routes/#{cc_route[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, anything, anything, anything, anything) do
      if @cc_routes_deleted
        cc_route_not_found
      else
        cc_clear_routes_cache_stub(config)
        OK.new({})
      end
    end
  end

  def cc_route_binding_not_found
    BadRequest.new('code'        => 1_002,
                   'description' => "Invalid relation: Route #{cc_route[:guid]} is not bound to service instance #{cc_service_instance[:guid]}.",
                   'error_code'  => 'CF-InvalidRelation')
  end

  def cc_route_binding_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v2/service_instances/#{cc_service_instance[:guid]}/routes/#{cc_route[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_route_bindings_deleted
        cc_route_binding_not_found
      else
        cc_clear_route_bindings_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end

    # Remove metadata
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/service_route_bindings/#{cc_route_binding[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, anything, anything, anything, anything) do
      if @cc_route_bindings_deleted
        cc_route_binding_not_found
      else
        cc_clear_route_bindings_cache_stub(config)
        OK.new({})
      end
    end
  end

  def cc_route_mapping_not_found
    NotFound.new('errors' =>
                 [
                   {
                     'code'   => 210_007,
                     'detail' => "The route mapping could not be found: #{cc_route_mapping[:guid]}",
                     'title'  => 'CF-RouteMappingNotFound'
                   }
                 ])
  end

  def cc_route_mapping_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/routes/#{cc_route[:guid]}/destinations/#{cc_route_mapping[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_route_mappings_deleted
        cc_route_mapping_not_found
      else
        cc_clear_route_mappings_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end
  end

  def cc_security_group_not_found
    NotFound.new('errors' =>
                 [
                   {
                     'code'   => 300_002,
                     'detail' => "The security group could not be found: #{cc_security_group[:guid]}",
                     'title'  => 'CF-SecurityGroupNotFound'
                   }
                 ])
  end

  def cc_security_group_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/security_groups/#{cc_security_group[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, "{\"name\":\"#{cc_security_group_rename}\"}", anything, anything, anything) do
      if @cc_security_groups_deleted
        cc_security_group_not_found
      else
        sql(config.ccdb_uri, "UPDATE security_groups SET name = '#{cc_security_group_rename}' WHERE guid = '#{cc_security_group[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/security_groups/#{cc_security_group[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, '{"globally_enabled":{"running":true}}', anything, anything, anything) do
      if @cc_security_groups_deleted
        cc_security_group_not_found
      else
        sql(config.ccdb_uri, "UPDATE security_groups SET running_default = 'true' WHERE guid = '#{cc_security_group[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/security_groups/#{cc_security_group[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, '{"globally_enabled":{"staging":true}}', anything, anything, anything) do
      if @cc_security_groups_deleted
        cc_security_group_not_found
      else
        sql(config.ccdb_uri, "UPDATE security_groups SET staging_default = 'true' WHERE guid = '#{cc_security_group[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/security_groups/#{cc_security_group[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, '{"globally_enabled":{"running":false}}', anything, anything, anything) do
      if @cc_security_groups_deleted
        cc_security_group_not_found
      else
        sql(config.ccdb_uri, "UPDATE security_groups SET running_default = 'false' WHERE guid = '#{cc_security_group[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/security_groups/#{cc_security_group[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, '{"globally_enabled":{"staging":false}}', anything, anything, anything) do
      if @cc_security_groups_deleted
        cc_security_group_not_found
      else
        sql(config.ccdb_uri, "UPDATE security_groups SET staging_default = 'false' WHERE guid = '#{cc_security_group[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/security_groups/#{cc_security_group[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_security_groups_deleted
        cc_security_group_not_found
      else
        cc_clear_security_groups_cache_stub(config)
        Accepted.new({})
      end
    end
  end

  def cc_security_group_space_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/security_groups/#{cc_security_group[:guid]}/relationships/running_spaces/#{cc_space[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_security_groups_deleted
        cc_security_group_not_found
      else
        cc_clear_security_groups_spaces_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end
  end

  def cc_service_not_found
    NotFound.new('errors' =>
                 [
                   {
                     'code'   => 120_003,
                     'detail' => "The service could not be found: #{cc_service[:guid]}",
                     'title'  => 'CF-ServiceNotFound'
                   }
                 ])
  end

  def cc_service_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/service_offerings/#{cc_service[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_services_deleted
        cc_service_not_found
      else
        cc_clear_services_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/service_offerings/#{cc_service[:guid]}?purge=true", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_services_deleted
        cc_service_not_found
      else
        cc_clear_services_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end

    # Remove metadata
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/service_offerings/#{cc_service[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, anything, anything, anything, anything) do
      if @cc_services_deleted
        cc_service_not_found
      else
        cc_clear_services_cache_stub(config)
        OK.new({})
      end
    end
  end

  def cc_service_binding_not_found
    NotFound.new('code'        => 90_004,
                 'description' => "The service binding could not be found: #{cc_service_binding[:guid]}",
                 'error_code'  => 'CF-ServiceBindingNotFound')
  end

  def cc_service_binding_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v2/service_bindings/#{cc_service_binding[:guid]}", AdminUI::Utils::HTTP_GET, anything, anything, anything, anything, anything) do
      OK.new('entity' => { 'credentials' => cc_service_binding_credential, 'volume_mounts' => cc_service_binding_volume_mounts })
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v2/service_bindings/#{cc_service_binding[:guid]}?accepts_incomplete=true", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_service_bindings_deleted
        cc_service_binding_not_found
      else
        cc_clear_service_bindings_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end

    # Remove metadata
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/service_credential_bindings/#{cc_service_binding[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, anything, anything, anything, anything) do
      if @cc_service_bindings_deleted
        cc_service_binding_not_found
      else
        cc_clear_service_bindings_cache_stub(config)
        OK.new({})
      end
    end
  end

  def cc_service_broker_not_found
    NotFound.new('errors' =>
                 [
                   {
                     'code'   => 10_000,
                     'detail' => 'Unknown request',
                     'title'  => 'CF-NotFound'
                   }
                 ])
  end

  def cc_service_broker_stubs(config)
    # Remove metadata
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/service_brokers/#{cc_service_broker[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, anything, anything, anything, anything) do
      if @cc_service_brokers_deleted
        cc_service_broker_not_found
      else
        cc_clear_service_brokers_cache_stub(config)
        Accepted.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/service_brokers/#{cc_service_broker[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, "{\"name\":\"#{cc_service_broker_rename}\"}", anything, anything, anything) do
      if @cc_service_brokers_deleted
        cc_service_broker_not_found
      else
        sql(config.ccdb_uri, "UPDATE service_brokers SET name = '#{cc_service_broker_rename}' WHERE guid = '#{cc_service_broker[:guid]}'")
        Accepted.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/service_brokers/#{cc_service_broker[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_service_brokers_deleted
        cc_service_broker_not_found
      else
        cc_clear_service_brokers_cache_stub(config)
        Accepted.new({})
      end
    end
  end

  def cc_service_instance_not_found
    NotFound.new('code'        => 60_004,
                 'description' => "The service instance could not be found: #{cc_service_instance[:guid]}",
                 'error_code'  => 'CF-ServiceInstanceNotFound')
  end

  def cc_service_instance_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v2/service_instances/#{cc_service_instance[:guid]}", AdminUI::Utils::HTTP_GET, anything, anything, anything, anything, anything) do
      OK.new('entity' => { 'credentials' => cc_service_instance_credential })
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v2/service_instances/#{cc_service_instance[:guid]}", AdminUI::Utils::HTTP_PUT, anything, "{\"name\":\"#{cc_service_instance_rename}\"}", anything, anything, anything) do
      if @cc_service_instances_deleted
        cc_service_instance_not_found
      else
        sql(config.ccdb_uri, "UPDATE service_instances SET name = '#{cc_service_instance_rename}' WHERE guid = '#{cc_service_instance[:guid]}'")
        Created.new
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v2/service_instances/#{cc_service_instance[:guid]}?accepts_incomplete=true", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_service_instances_deleted
        cc_service_instance_not_found
      else
        cc_clear_service_instances_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v2/service_instances/#{cc_service_instance[:guid]}?accepts_incomplete=true&recursive=true", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_service_instances_deleted
        cc_service_instance_not_found
      else
        cc_clear_service_instances_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v2/service_instances/#{cc_service_instance[:guid]}?accepts_incomplete=true&recursive=true&purge=true", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_service_instances_deleted
        cc_service_instance_not_found
      else
        cc_clear_service_instances_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end

    # Remove metadata
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/service_instances/#{cc_service_instance[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, anything, anything, anything, anything) do
      if @cc_service_instances_deleted
        cc_service_instance_not_found
      else
        cc_clear_service_instances_cache_stub(config)
        OK.new({})
      end
    end
  end

  def cc_service_instance_share_unprocessable_entity
    UnprocessableEntity.new('errors' =>
                            [
                              {
                                'code'   => 10_008,
                                'detail' => "Unable to unshare service instance from space #{cc_space[:guid]}. Ensure the space exists and the service instance has been shared to this space.",
                                'title'  => 'CF-UnprocessableEntity'
                              }
                            ])
  end

  def cc_service_instance_share_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/service_instances/#{cc_service_instance[:guid]}/relationships/shared_spaces/#{cc_space[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_service_instance_shares_deleted
        cc_service_instance_share_unprocessable_entity
      else
        cc_clear_service_instance_shares_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end
  end

  def cc_service_key_not_found
    NotFound.new('code'        => 360_003,
                 'description' => "The service key could not be found: #{cc_service_key[:guid]}",
                 'error_code'  => 'CF-ServiceKeyNotFound')
  end

  def cc_service_key_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v2/service_keys/#{cc_service_key[:guid]}", AdminUI::Utils::HTTP_GET, anything, anything, anything, anything, anything) do
      OK.new('entity' => { 'credentials' => cc_service_key_credential })
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v2/service_keys/#{cc_service_key[:guid]}?accepts_incomplete=true", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_service_keys_deleted
        cc_service_key_not_found
      else
        cc_clear_service_keys_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end

    # Remove metadata
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/service_credential_bindings/#{cc_service_key[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, anything, anything, anything, anything) do
      if @cc_service_keys_deleted
        cc_service_key_not_found
      else
        cc_clear_service_keys_cache_stub(config)
        OK.new({})
      end
    end
  end

  def cc_service_plan_not_found
    NotFound.new('errors' =>
                 [
                   {
                     'code'   => 110_003,
                     'detail' => "The service plan could not be found: #{cc_service_plan[:guid]}",
                     'title'  => 'CF-ServicePlanNotFound'
                   }
                 ])
  end

  def cc_service_plan_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/service_plans/#{cc_service_plan[:guid]}/visibility", AdminUI::Utils::HTTP_POST, anything, '{"type":"public"}', anything, anything, anything) do
      if @cc_service_plans_deleted
        cc_service_plan_not_found
      else
        sql(config.ccdb_uri, "UPDATE service_plans SET public = 'true' WHERE guid = '#{cc_service_plan[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/service_plans/#{cc_service_plan[:guid]}/visibility", AdminUI::Utils::HTTP_POST, anything, '{"type":"admin"}', anything, anything, anything) do
      if @cc_service_plans_deleted
        cc_service_plan_not_found
      else
        sql(config.ccdb_uri, "UPDATE service_plans SET public = 'false' WHERE guid = '#{cc_service_plan[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/service_plans/#{cc_service_plan[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_service_plans_deleted
        cc_service_plan_not_found
      else
        cc_clear_service_plans_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end

    # Remove metadata
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/service_plans/#{cc_service_plan[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, anything, anything, anything, anything) do
      if @cc_service_plans_deleted
        cc_service_plan_not_found
      else
        cc_clear_service_plans_cache_stub(config)
        OK.new({})
      end
    end
  end

  def cc_service_plan_visibility_not_found
    NotFound.new('errors' =>
                 [
                   {
                     'code'   => 260_003,
                     'detail' => "The service plan visibility could not be found: #{cc_service_plan[:guid]}",
                     'title'  => 'CF-ServicePlanVisibilityNotFound'
                   }
                 ])
  end

  def cc_service_plan_visibility_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/service_plans/#{cc_service_plan[:guid]}/visibility/#{cc_organization[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_service_plan_visibilities_deleted
        cc_service_plan_visibility_not_found
      else
        cc_clear_service_plan_visibilities_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end
  end

  def cc_space_not_found
    NotFound.new('errors' =>
                 [
                   {
                     'code'        => 40_004,
                     'detail' => "The app space could not be found: #{cc_space[:guid]}",
                     'title'  => 'CF-SpaceNotFound'
                   }
                 ])
  end

  def cc_space_stubs(config)
    # Remove metadata
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/spaces/#{cc_space[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, anything, anything, anything, anything) do
      if @cc_spaces_deleted
        cc_space_not_found
      else
        cc_clear_spaces_cache_stub(config)
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/spaces/#{cc_space[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, "{\"name\":\"#{cc_space_rename}\"}", anything, anything, anything) do
      if @cc_spaces_deleted
        cc_space_not_found
      else
        sql(config.ccdb_uri, "UPDATE spaces SET name = '#{cc_space_rename}' WHERE guid = '#{cc_space[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/spaces/#{cc_space[:guid]}/features/ssh", AdminUI::Utils::HTTP_PATCH, anything, '{"enabled":true}', anything, anything, anything) do
      if @cc_spaces_deleted
        cc_space_not_found
      else
        sql(config.ccdb_uri, "UPDATE spaces SET allow_ssh = 'true' WHERE guid = '#{cc_space[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/spaces/#{cc_space[:guid]}/features/ssh", AdminUI::Utils::HTTP_PATCH, anything, '{"enabled":false}', anything, anything, anything) do
      if @cc_spaces_deleted
        cc_space_not_found
      else
        sql(config.ccdb_uri, "UPDATE spaces SET allow_ssh = 'false' WHERE guid = '#{cc_space[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/spaces/#{cc_space[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_spaces_deleted
        cc_space_not_found
      else
        cc_clear_spaces_cache_stub(config)
        Accepted.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/roles/#{cc_space_auditor[:role_guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_spaces_deleted
        cc_space_not_found
      else
        sql(config.ccdb_uri, "DELETE FROM spaces_auditors WHERE space_id = '#{cc_space[:id]}' AND user_id = '#{cc_user[:id]}'")
        Accepted.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/roles/#{cc_space_developer[:role_guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_spaces_deleted
        cc_space_not_found
      else
        sql(config.ccdb_uri, "DELETE FROM spaces_developers WHERE space_id = '#{cc_space[:id]}' AND user_id = '#{cc_user[:id]}'")
        Accepted.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/roles/#{cc_space_manager[:role_guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_spaces_deleted
        cc_space_not_found
      else
        sql(config.ccdb_uri, "DELETE FROM spaces_managers WHERE space_id = '#{cc_space[:id]}' AND user_id = '#{cc_user[:id]}'")
        Accepted.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/spaces/#{cc_space[:guid]}/relationships/isolation_segment", AdminUI::Utils::HTTP_PATCH, anything, anything, anything, anything, anything) do
      if @cc_spaces_deleted
        cc_space_not_found
      else
        sql(config.ccdb_uri, "UPDATE spaces SET isolation_segment_guid = NULL WHERE guid = '#{cc_space[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/spaces/#{cc_space[:guid]}/routes?unmapped=true", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_spaces_deleted
        cc_space_not_found
      else
        cc_clear_route_annotations_cache_stub(config)
        cc_clear_route_labels_cache_stub(config)
        sql(config.ccdb_uri, "DELETE FROM routes WHERE space_id = '#{cc_space[:id]}' AND NOT EXISTS (SELECT * FROM route_mappings WHERE routes.guid == route_mappings.route_guid)")
        Accepted.new({})
      end
    end
  end

  def cc_space_quota_definition_not_found
    NotFound.new('errors' =>
                 [
                   {
                     'code'        => 310_007,
                     'detail' => "Space Quota Definition could not be found: #{cc_space_quota_definition[:guid]}",
                     'title'  => 'CF-SpaceQuotaDefinitionNotFound'
                   }
                 ])
  end

  def cc_space_quota_definition_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/space_quotas/#{cc_space_quota_definition[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, "{\"name\":\"#{cc_space_quota_definition_rename}\"}", anything, anything, anything) do
      if @cc_space_quota_definitions_deleted
        cc_space_quota_definition_not_found
      else
        sql(config.ccdb_uri, "UPDATE space_quota_definitions SET name = '#{cc_space_quota_definition_rename}' WHERE guid = '#{cc_space_quota_definition[:guid]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/space_quotas/#{cc_space_quota_definition2[:guid]}/relationships/spaces", AdminUI::Utils::HTTP_POST, anything, anything, anything, anything, anything) do
      if @cc_space_quota_definitions_deleted
        cc_space_quota_definition_not_found
      else
        sql(config.ccdb_uri, "UPDATE spaces SET space_quota_definition_id = (SELECT id FROM space_quota_definitions WHERE guid = '#{cc_space_quota_definition2[:guid]}')")
        Created.new
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/space_quotas/#{cc_space_quota_definition[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_space_quota_definitions_deleted
        cc_space_quota_definition_not_found
      else
        cc_clear_space_quota_definitions_cache_stub(config)
        Accepted.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/space_quotas/#{cc_space_quota_definition[:guid]}/relationships/spaces/#{cc_space[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_space_quota_definitions_deleted
        cc_space_quota_definition_not_found
      else
        sql(config.ccdb_uri, 'UPDATE spaces SET space_quota_definition_id = NULL')
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end
  end

  def cc_stack_not_found
    NotFound.new('errors' =>
                 [
                   {
                     'code'   => 250_003,
                     'detail' => "The stack could not be found: #{cc_stack[:guid]}",
                     'title'  => 'CF-StackNotFound'
                   }
                 ])
  end

  def cc_stack_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/stacks/#{cc_stack[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_stacks_deleted
        cc_stack_not_found
      else
        cc_clear_stacks_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end

    # Remove metadata
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/stacks/#{cc_stack[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, anything, anything, anything, anything) do
      if @cc_stacks_deleted
        cc_stack_not_found
      else
        cc_clear_stacks_cache_stub(config)
        OK.new({})
      end
    end
  end

  def cc_staging_security_group_space_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/security_groups/#{cc_security_group[:guid]}/relationships/staging_spaces/#{cc_space[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_security_groups_deleted
        cc_security_group_not_found
      else
        cc_clear_staging_security_groups_spaces_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end
  end

  def cc_task_not_found
    NotFound.new('errors' =>
                 [
                   {
                     'code'   => 10_010,
                     'detail' => 'Task not found',
                     'title'  => 'CF-ResourceNotFound'
                   }
                 ])
  end

  def cc_task_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/tasks/#{cc_task[:guid]}/actions/cancel", AdminUI::Utils::HTTP_POST, anything, anything, anything, anything, anything) do
      if @cc_tasks_deleted
        cc_task_not_found
      else
        sql(config.ccdb_uri, "UPDATE tasks SET state = 'FAILED' WHERE guid = '#{cc_task[:guid]}'")
        Accepted.new({})
      end
    end

    # Remove metadata
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/tasks/#{cc_task[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, anything, anything, anything, anything) do
      if @cc_tasks_deleted
        cc_task_not_found
      else
        cc_clear_tasks_cache_stub(config)
        OK.new({})
      end
    end
  end

  def cc_user_not_found
    NotFound.new('errors' =>
                 [
                   {
                     'code'   => 20_003,
                     'detail' => "The user could not be found: #{cc_user[:guid]}",
                     'title'  => 'CF-UserNotFound'
                   }
                 ])
  end

  def cc_user_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/users/#{cc_user[:guid]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @cc_users_deleted
        cc_user_not_found
      else
        cc_clear_users_cache_stub(config)
        Accepted.new({})
      end
    end

    # Remove metadata
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{config.cloud_controller_uri}/v3/users/#{cc_user[:guid]}", AdminUI::Utils::HTTP_PATCH, anything, anything, anything, anything, anything) do
      if @cc_users_deleted
        cc_user_not_found
      else
        cc_clear_users_cache_stub(config)
        Created.new
      end
    end
  end

  def uaa_client_not_found
    NotFound.new('message' => 'Not Found')
  end

  def uaa_client_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{cc_info_token_endpoint}/oauth/token/revoke/client/#{uaa_client[:client_id]}", AdminUI::Utils::HTTP_GET, anything, anything, anything, anything, anything) do
      if @uaa_clients_deleted
        uaa_client_not_found
      else
        uaa_clear_revocable_tokens_cache_stub(config)
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{cc_info_token_endpoint}/oauth/clients/#{uaa_client[:client_id]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @uaa_clients_deleted
        uaa_client_not_found
      else
        uaa_clear_clients_cache_stub(config)
        OK.new({})
      end
    end
  end

  def uaa_group_not_found
    NotFound.new('message' => "Group #{uaa_group[:id]} does not exist")
  end

  def uaa_group_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{cc_info_token_endpoint}/Groups/#{uaa_group[:id]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @uaa_groups_deleted
        uaa_group_not_found
      else
        uaa_clear_groups_cache_stub(config)
        OK.new({})
      end
    end
  end

  def uaa_group_membership_not_found
    NotFound.new('message' => "Member #{uaa_user[:id]} does not exist in group #{uaa_group[:id]}")
  end

  def uaa_group_membership_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{cc_info_token_endpoint}/Groups/#{uaa_group[:id]}/members/#{uaa_user[:id]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @uaa_group_membership_deleted
        uaa_group_membership_not_found
      else
        uaa_clear_group_membership_cache_stub(config)
        OK.new({})
      end
    end
  end

  def uaa_identity_provider_not_found
    NotFound.new('message' => 'Provider not found')
  end

  def uaa_identity_provider_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{cc_info_token_endpoint}/identity-providers/#{uaa_identity_provider[:id]}/status", AdminUI::Utils::HTTP_PATCH, anything, '{"requirePasswordChange":true}', anything, anything, anything) do
      if @uaa_identity_providers_deleted
        uaa_identity_provider_not_found
      else
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{cc_info_token_endpoint}/identity-providers/#{uaa_identity_provider[:id]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @uaa_identity_providers_deleted
        uaa_identity_provider_not_found
      else
        uaa_clear_identity_providers_cache_stub(config)
        OK.new({})
      end
    end
  end

  def uaa_identity_zone_not_found
    NotFound.new('message' => 'Not Found')
  end

  def uaa_identity_zone_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{cc_info_token_endpoint}/identity-zones/#{uaa_identity_zone[:id]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @uaa_identity_zones_deleted
        uaa_identity_zone_not_found
      else
        uaa_clear_identity_zones_cache_stub(config)
        OK.new({})
      end
    end
  end

  def uaa_mfa_provider_not_found
    NotFound.new('message' => 'Not Found')
  end

  def uaa_mfa_provider_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{cc_info_token_endpoint}/mfa-providers/#{uaa_mfa_provider[:id]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @uaa_mfa_providers_deleted
        uaa_mfa_provider_not_found
      else
        uaa_clear_mfa_providers_cache_stub(config)
        OK.new({})
      end
    end
  end

  def uaa_revocable_token_not_found
    NotFound.new('message' => 'Not Found')
  end

  def uaa_revocable_token_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{cc_info_token_endpoint}/oauth/token/revoke/#{uaa_revocable_token[:token_id]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @uaa_revocable_tokens_deleted
        uaa_revocable_token_not_found
      else
        uaa_clear_revocable_tokens_cache_stub(config)
        OK.new({})
      end
    end
  end

  def uaa_service_provider_not_found
    NotFound.new('message' => 'Not Found')
  end

  def uaa_service_provider_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{cc_info_token_endpoint}/saml/service-providers/#{uaa_service_provider[:id]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @uaa_service_providers_deleted
        uaa_service_provider_not_found
      else
        uaa_clear_service_providers_cache_stub(config)
        OK.new({})
      end
    end
  end

  def uaa_user_not_found
    NotFound.new('message' => "User #{uaa_user[:id]} does not exist")
  end

  def uaa_user_stubs(config)
    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{cc_info_token_endpoint}/oauth/token/revoke/user/#{uaa_user[:id]}", AdminUI::Utils::HTTP_GET, anything, anything, anything, anything, anything) do
      if @uaa_users_deleted
        uaa_user_not_found
      else
        uaa_clear_revocable_tokens_cache_stub(config)
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{cc_info_token_endpoint}/Users/#{uaa_user[:id]}", AdminUI::Utils::HTTP_PATCH, anything, '{"active":true}', anything, anything, anything) do
      if @uaa_users_deleted
        uaa_user_not_found
      else
        sql(config.uaadb_uri, "UPDATE users SET active = 'true' WHERE id = '#{uaa_user[:id]}'")
        Created.new
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{cc_info_token_endpoint}/Users/#{uaa_user[:id]}", AdminUI::Utils::HTTP_PATCH, anything, '{"active":false}', anything, anything, anything) do
      if @uaa_users_deleted
        uaa_user_not_found
      else
        sql(config.uaadb_uri, "UPDATE users SET active = 'false' WHERE id = '#{uaa_user[:id]}'")
        Created.new
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{cc_info_token_endpoint}/Users/#{uaa_user[:id]}", AdminUI::Utils::HTTP_PATCH, anything, '{"verified":true}', anything, anything, anything) do
      if @uaa_users_deleted
        uaa_user_not_found
      else
        sql(config.uaadb_uri, "UPDATE users SET verified = 'true' WHERE id = '#{uaa_user[:id]}'")
        Created.new
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{cc_info_token_endpoint}/Users/#{uaa_user[:id]}", AdminUI::Utils::HTTP_PATCH, anything, '{"verified":false}', anything, anything, anything) do
      if @uaa_users_deleted
        uaa_user_not_found
      else
        sql(config.uaadb_uri, "UPDATE users SET verified = 'false' WHERE id = '#{uaa_user[:id]}'")
        Created.new
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{cc_info_token_endpoint}/Users/#{uaa_user[:id]}/status", AdminUI::Utils::HTTP_PATCH, anything, '{"locked":false}', anything, anything, anything) do
      if @uaa_users_deleted
        uaa_user_not_found
      else
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{cc_info_token_endpoint}/Users/#{uaa_user[:id]}/status", AdminUI::Utils::HTTP_PATCH, anything, '{"passwordChangeRequired":true}', anything, anything, anything) do
      if @uaa_users_deleted
        uaa_user_not_found
      else
        sql(config.uaadb_uri, "UPDATE users SET passwd_change_required = 'true' WHERE id = '#{uaa_user[:id]}'")
        OK.new({})
      end
    end

    allow(AdminUI::Utils).to receive(:http_request).with(anything, anything, "#{cc_info_token_endpoint}/Users/#{uaa_user[:id]}", AdminUI::Utils::HTTP_DELETE, anything, anything, anything, anything, anything) do
      if @uaa_users_deleted
        uaa_user_not_found
      else
        uaa_clear_users_cache_stub(config)
        OK.new({})
      end
    end
  end

  def populate_db(db_uri, path, ordered_inserts)
    Sequel.connect(db_uri, single_threaded: true, max_connections: 1, timeout: 1) do |connection|
      Sequel::Migrator.apply(connection, path)

      ordered_inserts.each do |entry|
        items = connection[entry[0]]
        loop do
          items.insert(entry[1])
          break
        rescue Sequel::DatabaseError => error
          wrapped_exception = error.wrapped_exception
          raise unless wrapped_exception && wrapped_exception.instance_of?(SQLite3::BusyException)
        end
      end
    end
  end

  def sql(uri, sql)
    Sequel.connect(uri, single_threaded: true, max_connections: 1, timeout: 1) do |connection|
      loop do
        connection.run(sql)
        break
      rescue Sequel::DatabaseError => error
        wrapped_exception = error.wrapped_exception
        raise unless wrapped_exception && wrapped_exception.instance_of?(SQLite3::BusyException)
      end
    end
  end

  def unique_id(key)
    result = @unique_ids[key]
    return result unless result.nil?

    @last_unique_id += 1
    @unique_ids[key] = @last_unique_id
    @last_unique_id
  end

  def unique_time(key)
    result = @unique_times[key]
    return result unless result.nil?

    @last_unique_time += 1
    @unique_times[key] = @last_unique_time
    @last_unique_time
  end
end
