require 'json'
require 'net/http'
require 'time'
require 'uri'
require_relative '../spec_helper'

module CCHelper
  # Workaround since I cannot instantiate Net::HTTPOK and have body() function successfully
  # Failing with NoMethodError: undefined method `closed?
  class OK < Net::HTTPOK
    attr_reader :body
    def initialize(hash)
      super(1.0, 200, 'OK')
      @body = hash.to_json
    end
  end

  # Workaround since I cannot instantiate Net::HTTPCreated and have body() function successfully
  # Failing with NoMethodError: undefined method `closed?
  class Created < Net::HTTPOK
    attr_reader :body
    def initialize(hash)
      super(1.0, 201, 'Created')
      @body = hash.to_json
    end
  end

  # Workaround since I cannot instantiate Net::HTTPNotFound and have body() function successfully
  # Failing with NoMethodError: undefined method `closed?
  class NotFound < Net::HTTPNotFound
    attr_reader :body
    def initialize(hash)
      super(1.0, 404, 'NotFound')
      @body = hash.to_json
    end
  end

  # Workaround since I cannot instantiate Net::HTTPBadRequest and have body() function successfully
  # Failing with NoMethodError: undefined method `closed?
  class BadRequest < Net::HTTPBadRequest
    attr_reader :body
    def initialize(hash)
      super(1.0, 400, 'BadRequest')
      @body = hash.to_json
    end
  end

  def cc_stub(config, insert_second_quota_definition = false, event_type = 'space')
    @cc_apps_deleted                      = false
    @cc_domains_deleted                   = false
    @cc_organizations_deleted             = false
    @cc_quota_definitions_deleted         = false
    @cc_routes_deleted                    = false
    @cc_services_deleted                  = false
    @cc_service_bindings_deleted          = false
    @cc_service_brokers_deleted           = false
    @cc_service_instances_deleted         = false
    @cc_service_keys_deleted              = false
    @cc_service_plans_deleted             = false
    @cc_service_plan_visibilities_deleted = false
    @cc_space_quota_definitions_deleted   = false
    @cc_spaces_deleted                    = false

    @cc_organization_created = false

    populate_db(config.ccdb_uri,  File.join(File.dirname(__FILE__), './ccdb'), ccdb_inserts(insert_second_quota_definition, event_type))
    populate_db(config.uaadb_uri, File.join(File.dirname(__FILE__), './uaadb'), uaadb_inserts)

    cc_login_stubs(config)
    cc_app_stubs(config)
    cc_domain_stubs(config)
    cc_organization_stubs(config)
    cc_quota_definition_stubs(config)
    cc_route_stubs(config)
    cc_service_stubs(config)
    cc_service_binding_stubs(config)
    cc_service_broker_stubs(config)
    cc_service_instance_stubs(config)
    cc_service_key_stubs(config)
    cc_service_plan_stubs(config)
    cc_service_plan_visibility_stubs(config)
    cc_space_stubs(config)
    cc_space_quota_definition_stubs(config)
  end

  def cc_clear_apps_cache_stub(config)
    cc_clear_service_bindings_cache_stub(config)

    sql(config.ccdb_uri, 'DELETE FROM apps_routes')
    sql(config.ccdb_uri, 'DELETE FROM apps')

    @cc_apps_deleted = true
  end

  def cc_clear_domains_cache_stub(config)
    cc_clear_routes_cache_stub(config)

    sql(config.ccdb_uri, 'DELETE FROM organizations_private_domains')
    sql(config.ccdb_uri, 'DELETE FROM domains')

    @cc_domains_deleted = true
  end

  def cc_clear_organizations_cache_stub(config)
    cc_clear_domains_cache_stub(config)
    cc_clear_service_plan_visibilities_cache_stub(config)
    cc_clear_space_quota_definitions_cache_stub(config)
    cc_clear_spaces_cache_stub(config)

    sql(config.ccdb_uri, 'DELETE FROM organizations_auditors')
    sql(config.ccdb_uri, 'DELETE FROM organizations_billing_managers')
    sql(config.ccdb_uri, 'DELETE FROM organizations_managers')
    sql(config.ccdb_uri, 'DELETE FROM organizations_users')
    sql(config.ccdb_uri, 'DELETE FROM organizations')

    @cc_organizations_deleted = true
    @cc_organization_created  = false
  end

  def cc_clear_quota_definitions_cache_stub(config)
    cc_clear_organizations_cache_stub(config)

    sql(config.ccdb_uri, 'DELETE FROM quota_definitions')

    @cc_quota_definitions_deleted = true
  end

  def cc_clear_routes_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM apps_routes')
    sql(config.ccdb_uri, 'DELETE FROM routes')

    @cc_routes_deleted = true
  end

  def cc_clear_service_bindings_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM service_bindings')

    @cc_service_bindings_deleted = true
  end

  def cc_clear_service_brokers_cache_stub(config)
    cc_clear_services_cache_stub(config)

    sql(config.ccdb_uri, 'DELETE FROM service_dashboard_clients')
    sql(config.ccdb_uri, 'DELETE FROM service_brokers')

    @cc_service_brokers_deleted = true
  end

  def cc_clear_service_instances_cache_stub(config)
    cc_clear_service_bindings_cache_stub(config)
    cc_clear_service_keys_cache_stub(config)

    sql(config.ccdb_uri, 'DELETE FROM service_instance_operations')
    sql(config.ccdb_uri, 'DELETE FROM service_instances')

    @cc_service_instances_deleted = true
  end

  def cc_clear_service_keys_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM service_keys')

    @cc_service_keys_deleted = true
  end

  def cc_clear_service_plans_cache_stub(config)
    cc_clear_service_instances_cache_stub(config)
    cc_clear_service_plan_visibilities_cache_stub(config)

    sql(config.ccdb_uri, 'DELETE FROM service_plans')

    @cc_service_plans_deleted = true
  end

  def cc_clear_service_plan_visibilities_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM service_plan_visibilities')

    @cc_service_plan_visibilities_deleted = true
  end

  def cc_clear_services_cache_stub(config)
    cc_clear_service_plans_cache_stub(config)

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
    cc_clear_service_instances_cache_stub(config)

    sql(config.ccdb_uri, 'DELETE FROM apps')
    sql(config.ccdb_uri, 'DELETE FROM spaces_auditors')
    sql(config.ccdb_uri, 'DELETE FROM spaces_developers')
    sql(config.ccdb_uri, 'DELETE FROM spaces_managers')
    sql(config.ccdb_uri, 'DELETE FROM events')
    sql(config.ccdb_uri, 'DELETE FROM spaces')

    @cc_spaces_deleted = true
  end

  def uaa_clear_clients_cache_stub(config)
    sql(config.uaadb_uri, 'DELETE FROM oauth_client_details')
  end

  def cc_app
    {
      buildpack:             nil,
      command:               'node test.js',
      created_at:            Time.new('2015-04-23 08:00:00 -0500'),
      detected_buildpack:    'Node.js',
      diego:                 false,
      disk_quota:            12,
      docker_image:          'docker_image_1',
      droplet_hash:          'droplet1',
      guid:                  'application1',
      health_check_timeout:  nil,
      health_check_type:     'port',
      id:                    0,
      instances:             1,
      metadata:              '{}',
      memory:                11,
      name:                  'test',
      package_pending_since: Time.new('2015-04-23 08:00:01 -0500'),
      package_state:        'STAGED',
      package_updated_at:    Time.new('2015-04-23 08:00:02 -0500'),
      production:            nil,
      space_id:              cc_space[:id],
      stack_id:              cc_stack[:id],
      staging_task_id:       nil,
      state:                 'STARTED',
      type:                  'web',
      updated_at:            Time.new('2015-04-23 08:00:03 -0500'),
      version:               nil
    }
  end

  def cc_app_route
    {
      app_id:   cc_app[:id],
      route_id: cc_route[:id]
    }
  end

  def cc_domain
    {
      created_at:             Time.new('2015-04-23 08:00:04 -0500'),
      guid:                   'domain1',
      id:                     1,
      name:                   'test_domain',
      owning_organization_id: cc_organization[:id],
      updated_at:             Time.new('2015-04-23 08:00:05 -0500')
    }
  end

  def cc_event_app
    {
      actee:             cc_app[:guid],
      actee_name:        cc_app[:name],
      actee_type:        'app',
      actor:             cc_user[:guid],
      actor_name:        uaa_user[:username],
      actor_type:        'user',
      created_at:        Time.new('2015-04-23 08:00:06 -0500'),
      guid:              'event1',
      id:                2,
      metadata:          '{}',
      organization_guid: cc_organization[:guid],
      space_guid:        cc_space[:guid],
      space_id:          cc_space[:id],
      timestamp:         Time.new('2015-04-23 08:00:07 -0500'),
      type:              'audit.app.create',
      updated_at:        Time.new('2015-04-23 08:00:08 -0500')
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
      created_at:        Time.new('2015-04-23 08:00:09 -0500'),
      guid:              'event1',
      id:                3,
      metadata:          '{}',
      organization_guid: '',
      space_guid:        '',
      space_id:          nil,
      timestamp:         Time.new('2015-04-23 08:00:10 -0500'),
      type:              'audit.service.create',
      updated_at:        Time.new('2015-04-23 08:00:11 -0500')
    }
  end

  def cc_event_service_binding
    {
      actee:             cc_service_binding[:guid],
      actee_name:        nil,
      actee_type:        'service_binding',
      actor:             cc_user[:guid],
      actor_name:        uaa_user[:username],
      actor_type:        'user',
      created_at:        Time.new('2015-04-23 08:00:12 -0500'),
      guid:              'event1',
      id:                4,
      metadata:          '{}',
      organization_guid: cc_organization[:guid],
      space_guid:        cc_space[:guid],
      space_id:          cc_space[:id],
      timestamp:         Time.new('2015-04-23 08:00:13 -0500'),
      type:              'audit.service_binding.create',
      updated_at:        Time.new('2015-04-23 08:00:14 -0500')
    }
  end

  def cc_event_service_broker
    {
      actee:             cc_service_broker[:guid],
      actee_name:        cc_service_broker[:name],
      actee_type:        'service_broker',
      actor:             cc_user[:guid],
      actor_name:        uaa_user[:username],
      actor_type:        'user',
      created_at:        Time.new('2015-04-23 08:00:15 -0500'),
      guid:              'event1',
      id:                5,
      metadata:          '{}',
      organization_guid: '',
      space_guid:        '',
      space_id:          nil,
      timestamp:         Time.new('2015-04-23 08:00:16 -0500'),
      type:              'audit.service_broker.create',
      updated_at:        Time.new('2015-04-23 08:00:17 -0500')
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
      created_at:        Time.new('2015-04-23 08:00:18 -0500'),
      guid:              'event1',
      id:                6,
      metadata:          '{}',
      organization_guid: '',
      space_guid:        '',
      space_id:          nil,
      timestamp:         Time.new('2015-04-23 08:00:19 -0500'),
      type:              'audit.service_dashboard_client.create',
      updated_at:        Time.new('2015-04-23 08:00:20 -0500')
    }
  end

  def cc_event_service_instance
    {
      actee:             cc_service_instance[:guid],
      actee_name:        cc_service_instance[:name],
      actee_type:        'service_instance',
      actor:             cc_user[:guid],
      actor_name:        uaa_user[:username],
      actor_type:        'user',
      created_at:        Time.new('2015-04-23 08:00:21 -0500'),
      guid:              'event1',
      id:                7,
      metadata:          '{}',
      organization_guid: cc_organization[:guid],
      space_guid:        cc_space[:guid],
      space_id:          cc_space[:id],
      timestamp:         Time.new('2015-04-23 08:00:22 -0500'),
      type:              'audit.service_instance.create',
      updated_at:        Time.new('2015-04-23 08:00:23 -0500')
    }
  end

  def cc_event_service_key
    {
      actee:             cc_service_key[:guid],
      actee_name:        cc_service_key[:name],
      actee_type:        'service_key',
      actor:             cc_user[:guid],
      actor_name:        uaa_user[:username],
      actor_type:        'user',
      created_at:        Time.new('2015-04-23 08:00:24 -0500'),
      guid:              'event1',
      id:                8,
      metadata:          '{}',
      organization_guid: cc_organization[:guid],
      space_guid:        cc_space[:guid],
      space_id:          cc_space[:id],
      timestamp:         Time.new('2015-04-23 08:00:25 -0500'),
      type:              'audit.service_key.create',
      updated_at:        Time.new('2015-04-23 08:00:26 -0500')
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
      created_at:        Time.new('2015-04-23 08:00:27 -0500'),
      guid:              'event1',
      id:                9,
      metadata:          '{}',
      organization_guid: '',
      space_guid:        '',
      space_id:          nil,
      timestamp:         Time.new('2015-04-23 08:00:28 -0500'),
      type:              'audit.service_plan.create',
      updated_at:        Time.new('2015-04-23 08:00:29 -0500')
    }
  end

  def cc_event_service_plan_visibility
    {
      actee:             cc_service_plan_visibility[:guid],
      actee_name:        nil,
      actee_type:        'service_plan_visibility',
      actor:             cc_user[:guid],
      actor_name:        uaa_user[:username],
      actor_type:        'user',
      created_at:        Time.new('2015-04-23 08:00:30 -0500'),
      guid:              'event1',
      id:                10,
      metadata:          '{}',
      organization_guid: cc_organization[:guid],
      space_guid:        '',
      space_id:          nil,
      timestamp:         Time.new('2015-04-23 08:00:31 -0500'),
      type:              'audit.service_plan_visibility.create',
      updated_at:        Time.new('2015-04-23 08:00:32 -0500')
    }
  end

  def cc_event_space
    {
      actee:             cc_space[:guid],
      actee_name:        cc_space[:name],
      actee_type:        'space',
      actor:             cc_user[:guid],
      actor_name:        uaa_user[:username],
      actor_type:        'user',
      created_at:        Time.new('2015-04-23 08:00:33 -0500'),
      guid:              'event1',
      id:                11,
      metadata:          '{}',
      organization_guid: cc_organization[:guid],
      space_guid:        cc_space[:guid],
      space_id:          cc_space[:id],
      timestamp:         Time.new('2015-04-23 08:00:34 -0500'),
      type:              'audit.space.create',
      updated_at:        Time.new('2015-04-23 08:00:35 -0500')
    }
  end

  def cc_organization
    {
      billing_enabled:     false,
      created_at:          Time.new('2015-04-23 08:00:36 -0500'),
      guid:                'organization1',
      id:                  12,
      name:                'test_org',
      quota_definition_id: cc_quota_definition[:id],
      status:              'active',
      updated_at:          Time.new('2015-04-23 08:00:37 -0500')
    }
  end

  def cc_organization2
    {
      billing_enabled:     false,
      created_at:          Time.new,
      guid:                'organization2',
      id:                  13,
      name:                'new_org',
      quota_definition_id: cc_quota_definition[:id],
      status:              'active',
      updated_at:          nil
    }
  end

  def cc_organization_auditor
    {
      organization_id: cc_organization[:id],
      user_id:         cc_user[:id]
    }
  end

  def cc_organization_billing_manager
    {
      organization_id: cc_organization[:id],
      user_id:         cc_user[:id]
    }
  end

  def cc_organization_manager
    {
      organization_id: cc_organization[:id],
      user_id:         cc_user[:id]
    }
  end

  def cc_organization_private_domain
    {
      organization_id:   cc_organization[:id],
      private_domain_id: cc_domain[:id]
    }
  end

  def cc_organization_user
    {
      organization_id: cc_organization[:id],
      user_id:         cc_user[:id]
    }
  end

  def cc_quota_definition
    {
      created_at:                 Time.new('2015-04-23 08:00:38 -0500'),
      guid:                       'quota1',
      id:                         14,
      instance_memory_limit:      512,
      memory_limit:               1024,
      name:                       'test_quota_1',
      non_basic_services_allowed: true,
      total_routes:               100,
      total_services:             100,
      updated_at:                 Time.new('2015-04-23 08:00:39 -0500')
    }
  end

  def cc_quota_definition2
    {
      created_at:                 Time.new,
      guid:                       'quota2',
      id:                         15,
      instance_memory_limit:      512,
      memory_limit:               1024,
      name:                       'test_quota_2',
      non_basic_services_allowed: true,
      total_routes:               100,
      total_services:             100,
      updated_at:                 nil
    }
  end

  def cc_route
    {
      created_at: Time.new('2015-04-23 08:00:40 -0500'),
      domain_id:  cc_domain[:id],
      guid:       'route1',
      host:       'test_host',
      id:         16,
      space_id:   cc_space[:id],
      updated_at: Time.new('2015-04-23 08:00:41 -0500')
    }
  end

  def cc_service
    {
      active:            true,
      bindable:          true,
      created_at:        Time.new('2015-04-23 08:00:42 -0500'),
      description:       'TestService description',
      documentation_url: 'http://documentation_url.com',
      extra:             '{"displayName":"display name","documentationUrl":"http://documentationUrl.com","imageUrl":"http://docs.cloudfoundry.com/images/favicon.ico","longDescription":"long description","providerDisplayName":"provider display name","supportUrl":"http://supportUrl.com"}',
      guid:              'service1',
      id:                17,
      info_url:          'http://info_url.com',
      label:             'TestService',
      long_description:  nil,
      plan_updateable:   true,
      provider:          'test',
      requires:          nil,
      service_broker_id: cc_service_broker[:id],
      tags:              '["tag1", "tag2"]',
      unique_id:         'service_unique_id',
      updated_at:        Time.new('2015-04-23 08:00:43 -0500'),
      url:               nil,
      version:           '1.0'
    }
  end

  def cc_service_binding
    {
      app_id:              cc_app[:id],
      binding_options:     nil,
      created_at:          Time.new('2015-04-23 08:00:44 -0500'),
      gateway_data:        nil,
      gateway_name:        '',
      guid:                'service_binding1',
      id:                  18,
      service_instance_id: cc_service_instance[:id],
      syslog_drain_url:    nil,
      updated_at:          Time.new('2015-04-23 08:00:45 -0500')
    }
  end

  # We do not retrieve credentials, but it is required for insert
  def cc_service_binding_with_credentials
    cc_service_binding.merge(credentials: '{}')
  end

  def cc_service_broker
    {
      auth_username: 'username',
      broker_url:    'http://bogus',
      created_at:    Time.new('2015-04-23 08:00:46 -0500'),
      guid:          'service_broker1',
      id:            19,
      name:          'TestServiceBroker',
      updated_at:    Time.new('2015-04-23 08:00:47 -0500')
    }
  end

  # We do not retrieve auth_password, but it is required for insert
  def cc_service_broker_with_password
    cc_service_broker.merge(auth_password: 'password')
  end

  def cc_service_dashboard_client
    {
      service_broker_id: cc_service_broker[:id],
      uaa_id:            uaa_client[:client_id]
    }
  end

  def cc_service_instance
    {
      created_at:      Time.new('2015-04-23 08:00:48 -0500'),
      guid:            'service_instance1',
      id:              20,
      dashboard_url:   'http://www.ibm.com',
      gateway_data:    nil,
      gateway_name:    nil,
      name:            'TestService-random',
      service_plan_id: cc_service_plan[:id],
      space_id:        cc_space[:id],
      updated_at:      Time.new('2015-04-23 08:00:49 -0500')
    }
  end

  def cc_service_instance_operation
    {
      created_at:          Time.new('2015-04-23 08:00:48 -0500'),
      description:         'TestServiceInstanceOperation description',
      guid:                'service_instance_operation1',
      id:                  20,
      proposed_changes:    '{}',
      service_instance_id: cc_service_instance[:id],
      state:               'succeeded',
      type:                'create',
      updated_at:          Time.new('2015-04-23 08:00:49 -0500')
    }
  end

  def cc_service_key
    {
      created_at:          Time.new('2015-04-23 08:00:50 -0500'),
      guid:                'service_key1',
      id:                  21,
      name:                'TestServiceKey',
      service_instance_id: cc_service_instance[:id],
      updated_at:          Time.new('2015-04-23 08:00:51 -0500')
    }
  end

  # We do not retrieve credentials, but it is required for insert
  def cc_service_key_with_credentials
    cc_service_key.merge(credentials: '{}')
  end

  def cc_service_plan
    {
      active:      true,
      created_at:  Time.new('2015-04-23 08:00:52 -0500'),
      description: 'TestServicePlan description',
      extra:       '{"displayName":"display name","bullets":["bullet1","bullet2"]}',
      free:        true,
      guid:        'service_plan1',
      id:          22,
      name:        'TestServicePlan',
      public:      true,
      service_id:  cc_service[:id],
      unique_id:   'service_plan_unique_id1',
      updated_at:  Time.new('2015-04-23 08:00:53 -0500')
    }
  end

  def cc_service_plan_visibility
    {
      created_at:      Time.new('2015-04-23 08:00:54 -0500'),
      guid:            'service_plan_visibility1',
      id:              23,
      organization_id: cc_organization[:id],
      service_plan_id: cc_service_plan[:id],
      updated_at:      Time.new('2015-04-23 08:00:55 -0500')
    }
  end

  def cc_space
    {
      created_at:                Time.new('2015-04-23 08:00:56 -0500'),
      guid:                      'space1',
      id:                        24,
      name:                      'test_space',
      organization_id:           cc_organization[:id],
      space_quota_definition_id: cc_space_quota_definition[:id],
      updated_at:                Time.new('2015-04-23 08:00:57 -0500')
    }
  end

  def cc_space_auditor
    {
      space_id: cc_space[:id],
      user_id:  cc_user[:id]
    }
  end

  def cc_space_developer
    {
      space_id: cc_space[:id],
      user_id:  cc_user[:id]
    }
  end

  def cc_space_manager
    {
      space_id: cc_space[:id],
      user_id:  cc_user[:id]
    }
  end

  def cc_space_quota_definition
    {
      created_at:                 Time.new('2015-04-23 08:00:38 -0500'),
      guid:                       'space_quota1',
      id:                         14,
      instance_memory_limit:      512,
      memory_limit:               1024,
      name:                       'test_space_quota_1',
      organization_id:            cc_organization[:id],
      non_basic_services_allowed: true,
      total_routes:               100,
      total_services:             100,
      updated_at:                 Time.new('2015-04-23 08:00:39 -0500')
    }
  end

  def cc_space_quota_definition2
    {
      created_at:                 Time.new,
      guid:                       'space_quota2',
      id:                         15,
      instance_memory_limit:      512,
      memory_limit:               1024,
      name:                       'test_space_quota_2',
      non_basic_services_allowed: true,
      organization_id:            cc_organization[:id],
      total_routes:               100,
      total_services:             100,
      updated_at:                 nil
    }
  end

  def cc_stack
    {
      created_at:  Time.new('2015-04-23 08:00:58 -0500'),
      description: 'TestStack description',
      guid:        'stack1',
      id:          25,
      name:        'lucid64',
      updated_at:  Time.new('2015-04-23 08:00:58 -0500')
    }
  end

  def cc_user
    {
      active:           true,
      admin:            false,
      created_at:       Time.new('2015-04-23 08:00:59 -0500'),
      default_space_id: nil,
      guid:             uaa_user[:id],
      id:               26,
      updated_at:       nil
    }
  end

  def uaa_client_autoapprove
    true
  end

  def uaa_client
    {
      additional_information:  "{\"autoapprove\":#{ uaa_client_autoapprove }}",
      authorities:             'auth1',
      authorized_grant_types:  'grant1',
      client_id:               'client1',
      scope:                   'scope1',
      web_server_redirect_uri: 'http://redirect1'
    }
  end

  def uaa_group
    {
      created:     Time.new('2015-04-23 08:01:00 -0500'),
      displayname: 'group1',
      id:          'group1',
      lastmodified: Time.new('2015-04-23 08:01:01 -0500'),
      version:      5
    }
  end

  def uaa_group_membership
    {
      group_id:  uaa_group[:id],
      member_id: uaa_user[:id]
    }
  end

  def uaa_user
    {
      active:       true,
      created:      Time.new('2015-04-23 08:01:02 -0500'),
      email:        'admin',
      familyname:   'Flintstone',
      givenname:    'Fred',
      id:           'user1',
      lastmodified: Time.new('2015-04-23 08:01:03 -0500'),
      username:     'admin',
      verified:     true,
      version:      5
    }
  end

  # We do not retrieve password, but it is required for insert
  def uaa_user_with_password
    uaa_user.merge(password: 'password')
  end

  private

  def authorization_endpoint
    'http://authorization_endpoint'
  end

  def token_endpoint
    'http://token_endpoint'
  end

  def cc_info
    {
      'authorization_endpoint' => authorization_endpoint,
      'token_endpoint'         => token_endpoint
    }
  end

  def uaa_oauth
    {
      'token_type'   => 'bearer',
      'access_token' => 'bogus'
    }
  end

  def ccdb_inserts(insert_second_quota_definition, event_type)
    result = [[:quota_definitions,              cc_quota_definition],
              [:service_brokers,                cc_service_broker_with_password],
              [:service_dashboard_clients,      cc_service_dashboard_client],
              [:stacks,                         cc_stack],
              [:organizations,                  cc_organization],
              [:services,                       cc_service],
              [:domains,                        cc_domain],
              [:service_plans,                  cc_service_plan],
              [:service_plan_visibilities,      cc_service_plan_visibility],
              [:space_quota_definitions,        cc_space_quota_definition],
              [:spaces,                         cc_space],
              [:apps,                           cc_app],
              [:routes,                         cc_route],
              [:service_instances,              cc_service_instance],
              [:service_instance_operations,    cc_service_instance_operation],
              [:users,                          cc_user],
              [:apps_routes,                    cc_app_route],
              [:service_bindings,               cc_service_binding_with_credentials],
              [:service_keys,                   cc_service_key_with_credentials],
              [:organizations_auditors,         cc_organization_auditor],
              [:organizations_billing_managers, cc_organization_billing_manager],
              [:organizations_managers,         cc_organization_manager],
              [:organizations_private_domains,  cc_organization_private_domain],
              [:organizations_users,            cc_organization_user],
              [:spaces_auditors,                cc_space_auditor],
              [:spaces_developers,              cc_space_developer],
              [:spaces_managers,                cc_space_manager]
             ]

    result << [:quota_definitions, cc_quota_definition2] if insert_second_quota_definition
    result << [:space_quota_definitions, cc_space_quota_definition2] if insert_second_quota_definition

    result << [:events, cc_event_app] if event_type == 'app'
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
    [[:groups,               uaa_group],
     [:users,                uaa_user_with_password],
     [:group_membership,     uaa_group_membership],
     [:oauth_client_details, uaa_client]
    ]
  end

  def cc_app_instance_index
    0
  end

  def cc_app_not_found
    NotFound.new('code'        => 100_004,
                 'description' => "The app name could not be found: #{ cc_app[:guid] }",
                 'error_code'  => 'CF-AppNotFound')
  end

  def cc_app_stubs(config)
    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/apps/#{ cc_app[:guid] }/restage", AdminUI::Utils::HTTP_POST, anything, anything, anything) do
      if @cc_apps_deleted
        cc_app_not_found
      else
        Created.new('{}')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/apps/#{ cc_app[:guid] }", AdminUI::Utils::HTTP_PUT, anything, '{"state":"STOPPED"}', anything) do
      if @cc_apps_deleted
        cc_app_not_found
      else
        sql(config.ccdb_uri, "UPDATE apps SET state = 'STOPPED' WHERE guid = '#{ cc_app[:guid] }'")
        OK.new('{}')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/apps/#{ cc_app[:guid] }", AdminUI::Utils::HTTP_PUT, anything, '{"state":"STARTED"}', anything) do
      if @cc_apps_deleted
        cc_app_not_found
      else
        sql(config.ccdb_uri, "UPDATE apps SET state = 'STARTED' WHERE guid = '#{ cc_app[:guid] }'")
        OK.new('{}')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/apps/#{ cc_app[:guid] }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_apps_deleted
        cc_app_not_found
      else
        cc_clear_apps_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/apps/#{ cc_app[:guid] }?recursive=true", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_apps_deleted
        cc_app_not_found
      else
        cc_clear_apps_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/apps/#{ cc_app[:guid] }/instances/#{ cc_app_instance_index }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_apps_deleted
        cc_app_not_found
      else
        cc_clear_apps_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end
  end

  # rubocop:disable Style/TrivialAccessors
  def cc_apps_deleted
    @cc_apps_deleted
  end
  # rubocop:enable Style/TrivialAccessors

  def cc_domain_not_found
    NotFound.new('code'        => 130_002,
                 'description' => "The domain could not be found: #{ cc_domain[:guid] }",
                 'error_code'  => 'CF-DomainNotFound')
  end

  def cc_domain_stubs(config)
    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/domains/#{ cc_domain[:guid] }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_domains_deleted
        cc_domain_not_found
      else
        cc_clear_domains_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/domains/#{ cc_domain[:guid] }?recursive=true", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_domains_deleted
        cc_domain_not_found
      else
        cc_clear_domains_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end
  end

  def cc_login_stubs(config)
    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/info", AdminUI::Utils::HTTP_GET) do
      OK.new(cc_info)
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ token_endpoint }/oauth/token", AdminUI::Utils::HTTP_POST, anything, anything) do
      OK.new(uaa_oauth)
    end
  end

  def cc_organization_not_found
    NotFound.new('code'        => 30_003,
                 'description' => "The organization could not be found: #{ cc_organization[:guid] }",
                 'error_code'  => 'CF-OrganizationNotFound')
  end

  def cc_organization_taken
    BadRequest.new('code'        => 30_002,
                   'description' => "The organization name is taken: #{ cc_organization2[:name] }",
                   'error_code'  => 'CF-OrganizationNameTaken')
  end

  def cc_organization_stubs(config)
    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/organizations", AdminUI::Utils::HTTP_POST, anything, "{\"name\":\"#{ cc_organization2[:name] }\"}", anything) do
      if @cc_organization_created
        cc_organization_taken
      else
        Sequel.connect(config.ccdb_uri, single_threaded: false, max_connections: 1, timeout: 1) do |connection|
          items = connection[:organizations]
          loop do
            begin
              items.insert(cc_organization2)
              break
            rescue Sequel::DatabaseError => error
              wrapped_exception = error.wrapped_exception
              raise unless wrapped_exception && wrapped_exception.instance_of?(SQLite3::BusyException)
            end
          end
        end
        @cc_organization_created = true
        OK.new('{}')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/organizations/#{ cc_organization[:guid] }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_organizations_deleted
        cc_organization_not_found
      else
        cc_clear_organizations_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/organizations/#{ cc_organization[:guid] }?recursive=true", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_organizations_deleted
        cc_organization_not_found
      else
        cc_clear_organizations_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/organizations/#{ cc_organization[:guid] }/auditors/#{ cc_user[:guid] }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_organizations_deleted
        cc_organization_not_found
      else
        sql(config.ccdb_uri, "DELETE FROM organizations_auditors WHERE organization_id = '#{ cc_organization[:id] }' AND user_id = '#{ cc_user[:id] }'")
        Net::HTTPCreated.new(1.0, 201, 'Created')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/organizations/#{ cc_organization[:guid] }/billing_managers/#{ cc_user[:guid] }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_organizations_deleted
        cc_organization_not_found
      else
        sql(config.ccdb_uri, "DELETE FROM organizations_billing_managers WHERE organization_id = '#{ cc_organization[:id] }' AND user_id = '#{ cc_user[:id] }'")
        Net::HTTPCreated.new(1.0, 201, 'Created')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/organizations/#{ cc_organization[:guid] }/managers/#{ cc_user[:guid] }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_organizations_deleted
        cc_organization_not_found
      else
        sql(config.ccdb_uri, "DELETE FROM organizations_managers WHERE organization_id = '#{ cc_organization[:id] }' AND user_id = '#{ cc_user[:id] }'")
        Net::HTTPCreated.new(1.0, 201, 'Created')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/organizations/#{ cc_organization[:guid] }/users/#{ cc_user[:guid] }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_organizations_deleted
        cc_organization_not_found
      else
        sql(config.ccdb_uri, "DELETE FROM organizations_users WHERE organization_id = '#{ cc_organization[:id] }' AND user_id = '#{ cc_user[:id] }'")
        Net::HTTPCreated.new(1.0, 201, 'Created')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/organizations/#{ cc_organization[:guid] }", AdminUI::Utils::HTTP_PUT, anything, "{\"quota_definition_guid\":\"#{ cc_quota_definition2[:guid] }\"}", anything) do
      if @cc_organizations_deleted
        cc_organization_not_found
      else
        sql(config.ccdb_uri, "UPDATE organizations SET quota_definition_id = (SELECT id FROM quota_definitions WHERE guid = '#{ cc_quota_definition2[:guid] }')")
        OK.new('{}')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/organizations/#{ cc_organization[:guid] }", AdminUI::Utils::HTTP_PUT, anything, '{"status":"suspended"}', anything) do
      if @cc_organizations_deleted
        cc_organization_not_found
      else
        sql(config.ccdb_uri, "UPDATE organizations SET status = 'suspended' WHERE guid = '#{ cc_organization[:guid] }'")
        OK.new('{}')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/organizations/#{ cc_organization[:guid] }", AdminUI::Utils::HTTP_PUT, anything, '{"status":"active"}', anything) do
      if @cc_organizations_deleted
        cc_organization_not_found
      else
        sql(config.ccdb_uri, "UPDATE organizations SET status = 'active' WHERE guid = '#{ cc_organization[:guid] }'")
        OK.new('{}')
      end
    end
  end

  def cc_quota_definition_not_found
    NotFound.new('code'        => 240_001,
                 'description' => "Quota Definition could not be found: #{ cc_quota_definition[:guid] }",
                 'error_code'  => 'CF-QuotaDefinitionNotFound')
  end

  def cc_quota_definition_stubs(config)
    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/quota_definitions/#{ cc_quota_definition[:guid] }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_quota_definitions_deleted
        cc_quota_definition_not_found
      else
        cc_clear_quota_definitions_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end
  end

  def cc_route_not_found
    NotFound.new('code'        => 210_002,
                 'description' => "The route could not be found: #{ cc_route[:guid] }",
                 'error_code'  => 'CF-RouteNotFound')
  end

  def cc_route_stubs(config)
    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/routes/#{ cc_route[:guid] }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_routes_deleted
        cc_route_not_found
      else
        cc_clear_routes_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end
  end

  def cc_service_not_found
    NotFound.new('code'        => 120_003,
                 'description' => "The service could not be found: #{ cc_service[:guid] }",
                 'error_code'  => 'CF-ServiceNotFound')
  end

  def cc_service_stubs(config)
    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/services/#{ cc_service[:guid] }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_services_deleted
        cc_service_not_found
      else
        cc_clear_services_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/services/#{ cc_service[:guid] }?purge=true", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_services_deleted
        cc_service_not_found
      else
        cc_clear_services_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end
  end

  def cc_service_binding_not_found
    NotFound.new('code'        => 90_004,
                 'description' => "The service binding could not be found: #{ cc_service_binding[:guid] }",
                 'error_code'  => 'CF-ServiceBindingNotFound')
  end

  def cc_service_binding_stubs(config)
    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/service_bindings/#{ cc_service_binding[:guid] }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_service_bindings_deleted
        cc_service_binding_not_found
      else
        cc_clear_service_bindings_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end
  end

  def cc_service_broker_not_found
    NotFound.new('code'        => 10_000,
                 'description' => 'Unknown request',
                 'error_code'  => 'CF-NotFound')
  end

  def cc_service_broker_stubs(config)
    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/service_brokers/#{ cc_service_broker[:guid] }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_service_brokers_deleted
        cc_service_broker_not_found
      else
        cc_clear_service_brokers_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end
  end

  def cc_service_instance_not_found
    NotFound.new('code'        => 60_004,
                 'description' => "The service instance could not be found: #{ cc_service_instance[:guid] }",
                 'error_code'  => 'CF-ServiceInstanceNotFound')
  end

  def cc_service_instance_stubs(config)
    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/service_instances/#{ cc_service_instance[:guid] }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_service_instances_deleted
        cc_service_instance_not_found
      else
        cc_clear_service_instances_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/service_instances/#{ cc_service_instance[:guid] }?recursive=true", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_service_instances_deleted
        cc_service_instance_not_found
      else
        cc_clear_service_instances_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end
  end

  def cc_service_key_not_found
    NotFound.new('code'        => 360_003,
                 'description' => "The service key could not be found: #{ cc_service_key[:guid] }",
                 'error_code'  => 'CF-ServiceKeyNotFound')
  end

  def cc_service_key_stubs(config)
    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/service_keys/#{ cc_service_key[:guid] }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_service_keys_deleted
        cc_service_key_not_found
      else
        cc_clear_service_keys_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end
  end

  def cc_service_plan_not_found
    NotFound.new('code'        => 110_003,
                 'description' => "The service plan could not be found: #{ cc_service_plan[:guid] }",
                 'error_code'  => 'CF-ServicePlanNotFound')
  end

  def cc_service_plan_stubs(config)
    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/service_plans/#{ cc_service_plan[:guid] }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_service_plans_deleted
        cc_service_plan_not_found
      else
        cc_clear_service_plans_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/service_plans/#{ cc_service_plan[:guid] }", AdminUI::Utils::HTTP_PUT, anything, '{"public": true }', anything) do
      if @cc_service_plans_deleted
        cc_service_plan_not_found
      else
        sql(config.ccdb_uri, "UPDATE service_plans SET public = 'true' WHERE guid = '#{ cc_service_plan[:guid] }'")
        OK.new('{}')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/service_plans/#{ cc_service_plan[:guid] }", AdminUI::Utils::HTTP_PUT, anything, '{"public": false }', anything) do
      if @cc_service_plans_deleted
        cc_service_plan_not_found
      else
        sql(config.ccdb_uri, "UPDATE service_plans SET public = 'false' WHERE guid = '#{ cc_service_plan[:guid] }'")
        OK.new('{}')
      end
    end
  end

  def cc_service_plan_visibility_not_found
    NotFound.new('code'        => 260_003,
                 'description' => "The service plan visibility could not be found: #{ cc_service_plan[:guid] }",
                 'error_code'  => 'CF-ServicePlanVisibilityNotFound')
  end

  def cc_service_plan_visibility_stubs(config)
    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/service_plan_visibilities/#{ cc_service_plan_visibility[:guid] }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_service_plan_visibilities_deleted
        cc_service_plan_visibility_not_found
      else
        cc_clear_service_plan_visibilities_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end
  end

  def cc_space_not_found
    NotFound.new('code'        => 40_004,
                 'description' => "The app space could not be found: #{ cc_space[:guid] }",
                 'error_code'  => 'CF-SpaceNotFound')
  end

  def cc_space_stubs(config)
    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/spaces/#{ cc_space[:guid] }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_spaces_deleted
        cc_space_not_found
      else
        cc_clear_spaces_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/spaces/#{ cc_space[:guid] }?recursive=true", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_spaces_deleted
        cc_space_not_found
      else
        cc_clear_spaces_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/spaces/#{ cc_space[:guid] }/auditors/#{ cc_user[:guid] }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_spaces_deleted
        cc_space_not_found
      else
        sql(config.ccdb_uri, "DELETE FROM spaces_auditors WHERE space_id = '#{ cc_space[:id] }' AND user_id = '#{ cc_user[:id] }'")
        Net::HTTPCreated.new(1.0, 201, 'Created')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/spaces/#{ cc_space[:guid] }/developers/#{ cc_user[:guid] }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_spaces_deleted
        cc_space_not_found
      else
        sql(config.ccdb_uri, "DELETE FROM spaces_developers WHERE space_id = '#{ cc_space[:id] }' AND user_id = '#{ cc_user[:id] }'")
        Net::HTTPCreated.new(1.0, 201, 'Created')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/spaces/#{ cc_space[:guid] }/managers/#{ cc_user[:guid] }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_spaces_deleted
        cc_space_not_found
      else
        sql(config.ccdb_uri, "DELETE FROM spaces_managers WHERE space_id = '#{ cc_space[:id] }' AND user_id = '#{ cc_user[:id] }'")
        Net::HTTPCreated.new(1.0, 201, 'Created')
      end
    end
  end

  def cc_space_quota_definition_not_found
    NotFound.new('code'        => 310_007,
                 'description' => "Space Quota Definition could not be found: #{ cc_space_quota_definition[:guid] }",
                 'error_code'  => 'CF-SpaceQuotaDefinitionNotFound')
  end

  def cc_space_quota_definition_stubs(config)
    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/space_quota_definitions/#{ cc_space_quota_definition[:guid] }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_space_quota_definitions_deleted
        cc_space_quota_definition_not_found
      else
        cc_clear_space_quota_definitions_cache_stub(config)
        Net::HTTPNoContent.new(1.0, 204, 'OK')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/space_quota_definitions/#{ cc_space_quota_definition[:guid] }/spaces/#{ cc_space[:guid] }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      if @cc_space_quota_definitions_deleted
        cc_space_quota_definition_not_found
      else
        sql(config.ccdb_uri, 'UPDATE spaces SET space_quota_definition_id = null')
        OK.new('{}')
      end
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/space_quota_definitions/#{ cc_space_quota_definition2[:guid] }/spaces/#{ cc_space[:guid] }", AdminUI::Utils::HTTP_PUT, anything, anything, anything) do
      if @cc_space_quota_definitions_deleted
        cc_space_quota_definition_not_found
      else
        sql(config.ccdb_uri, "UPDATE spaces SET space_quota_definition_id = (SELECT id FROM space_quota_definitions WHERE guid = '#{ cc_space_quota_definition2[:guid] }')")
        OK.new('{}')
      end
    end
  end

  def populate_db(db_uri, path, ordered_inserts)
    Sequel.connect(db_uri, single_threaded: false, max_connections: 1, timeout: 1) do |connection|
      Sequel::Migrator.apply(connection, path)

      ordered_inserts.each do |entry|
        items = connection[entry[0]]
        loop do
          begin
            items.insert(entry[1])
            break
          rescue Sequel::DatabaseError => error
            wrapped_exception = error.wrapped_exception
            raise unless wrapped_exception && wrapped_exception.instance_of?(SQLite3::BusyException)
          end
        end
      end
    end
  end

  def sql(uri, sql)
    Sequel.connect(uri, single_threaded: false, max_connections: 1, timeout: 1) do |connection|
      loop do
        begin
          connection.run(sql)
          break
        rescue Sequel::DatabaseError => error
          wrapped_exception = error.wrapped_exception
          raise unless wrapped_exception && wrapped_exception.instance_of?(SQLite3::BusyException)
        end
      end
    end
  end
end
