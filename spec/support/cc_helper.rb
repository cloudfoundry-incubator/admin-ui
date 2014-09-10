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

  def cc_stub(config, insert_second_quota_definition = false)
    populate_db(config.ccdb_uri,  File.join(File.dirname(__FILE__), './ccdb'), ccdb_inserts(insert_second_quota_definition))
    populate_db(config.uaadb_uri, File.join(File.dirname(__FILE__), './uaadb'), uaadb_inserts)

    cc_login_stubs(config)
    cc_app_stubs(config)
    cc_organization_stubs(config)
    cc_route_stubs(config)
    cc_service_plan_stubs(config)
  end

  def cc_clear_apps_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM service_bindings')
    sql(config.ccdb_uri, 'DELETE FROM apps_routes')
    sql(config.ccdb_uri, 'DELETE FROM apps')
  end

  def cc_clear_organizations_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM service_bindings')
    sql(config.ccdb_uri, 'DELETE FROM service_instances')
    sql(config.ccdb_uri, 'DELETE FROM service_plan_visibilities')
    sql(config.ccdb_uri, 'DELETE FROM apps_routes')
    sql(config.ccdb_uri, 'DELETE FROM apps')
    sql(config.ccdb_uri, 'DELETE FROM routes')
    sql(config.ccdb_uri, 'DELETE FROM spaces_developers')
    sql(config.ccdb_uri, 'DELETE FROM spaces')
    sql(config.ccdb_uri, 'DELETE FROM domains')
    sql(config.ccdb_uri, 'DELETE FROM organizations')
  end

  def cc_clear_routes_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM apps_routes')
    sql(config.ccdb_uri, 'DELETE FROM routes')
  end

  def cc_clear_service_plans_cache_stub(config)
    sql(config.ccdb_uri, 'DELETE FROM service_bindings')
    sql(config.ccdb_uri, 'DELETE FROM service_instances')
    sql(config.ccdb_uri, 'DELETE FROM service_plan_visibilities')
    sql(config.ccdb_uri, 'DELETE FROM service_plans')
  end

  def cc_app
    {
      :buildpack            => nil,
      :created_at           => Time.new('2013-10-18 08:28:35 -0500'),
      :detected_buildpack   => 'Ruby/Rack',
      :diego                => false,
      :disk_quota           => 12,
      :docker_image         => 'docker_image_1',
      :guid                 => 'application1',
      :health_check_timeout => nil,
      :id                   => 1,
      :instances            => 1,
      :metadata             => '{}',
      :memory               => 11,
      :name                 => 'test',
      :package_state        => 'STAGED',
      :production           => nil,
      :space_id             => cc_space[:id],
      :stack_id             => cc_stack[:id],
      :staging_task_id      => nil,
      :state                => 'STARTED',
      :updated_at           => Time.new('2013-10-20 08:28:35 -0500'),
      :version              => nil
    }
  end

  def cc_app_route
    {
      :app_id   => cc_app[:id],
      :route_id => cc_route[:id]
    }
  end

  def cc_domain
    {
      :created_at             => Time.new('2014-02-12T09:40:52-06:00'),
      :guid                   => 'domain1',
      :id                     => 2,
      :name                   => 'test_domain',
      :owning_organization_id => cc_organization[:id],
      :updated_at             => Time.new('2014-02-12T09:40:52-06:00')
    }
  end

  def cc_organization
    {
      :billing_enabled     => false,
      :created_at          => Time.new('2013-10-16T08:55:46-05:00'),
      :guid                => 'organization1',
      :id                  => 3,
      :name                => 'test_org',
      :quota_definition_id => cc_quota_definition[:id],
      :status              => 'active',
      :updated_at          => Time.new('2013-10-17T08:55:46-05:00')
    }
  end

  def cc_organization2
    {
      :billing_enabled     => false,
      :created_at          => Time.new,
      :guid                => 'organization2',
      :id                  => 300,
      :name                => 'new_org',
      :quota_definition_id => cc_quota_definition[:id],
      :status              => 'active',
      :updated_at          => nil
    }
  end

  def cc_quota_definition
    {
      :created_at                 => Time.new('2013-10-16T08:55:46-05:00'),
      :guid                       => 'quota1',
      :id                         => 4,
      :instance_memory_limit      => 512,
      :memory_limit               => 1024,
      :name                       => 'test_quota_1',
      :non_basic_services_allowed => true,
      :total_routes               => 100,
      :total_services             => 100,
      :updated_at                 => Time.new('2013-11-16T08:55:46-05:00')
    }
  end

  def cc_quota_definition2
    {
      :created_at                 => Time.new,
      :guid                       => 'quota2',
      :id                         => 400,
      :instance_memory_limit      => 512,
      :memory_limit               => 1024,
      :name                       => 'test_quota_2',
      :non_basic_services_allowed => true,
      :total_routes               => 100,
      :total_services             => 100,
      :updated_at                 => nil
    }
  end

  def cc_route
    {
      :created_at => Time.new('2014-02-12T09:40:52-06:00'),
      :domain_id  => cc_domain[:id],
      :guid       => 'route1',
      :host       => 'test_host',
      :id         => 5,
      :space_id   => cc_space[:id],
      :updated_at => Time.new('2014-02-13T09:40:52-06:00')
    }
  end

  def cc_service
    {
      :active            => true,
      :bindable          => true,
      :created_at        => Time.new('2014-02-12T09:32:31-06:00'),
      :description       => 'TestService description',
      :documentation_url => 'http://documentation_url.com',
      :extra             => '{"displayName":"displayname","imageUrl":"http://docs.cloudfoundry.com/images/favicon.ico","longDescription":"long description","providerDisplayName":"provider name"}',
      :guid              => 'service1',
      :id                => 6,
      :info_url          => 'http://info_url.com',
      :label             => 'TestService',
      :long_description  => nil,
      :provider          => 'test',
      :requires          => nil,
      :service_broker_id => cc_service_broker[:id],
      :tags              => '["tag1", "tag2"]',
      :unique_id         => 'service_unique_id',
      :updated_at        => Time.new('2014-02-12T09:32:31-06:00'),
      :url               => nil,
      :version           => '1.0'
    }
  end

  def cc_service_binding
    {
      :app_id              => cc_app[:id],
      :binding_options     => nil,
      :created_at          => Time.new('2014-02-12T09:41:42-06:00'),
      :gateway_data        => nil,
      :gateway_name        => '',
      :guid                => 'service_binding1',
      :id                  => 7,
      :service_instance_id => cc_service_instance[:id],
      :syslog_drain_url    => nil,
      :updated_at          => nil
    }
  end

  # We do not retrieve credentials, but it is required for insert
  def cc_service_binding_with_credentials
    cc_service_binding.merge(:credentials => '{}')
  end

  def cc_service_broker
    {
      :auth_username => 'username',
      :broker_url    => 'http://bogus',
      :created_at    => Time.new('2014-02-12T09:41:42-06:00'),
      :guid          => 'service_broker1',
      :id            => 8,
      :name          => 'TestServiceBroker',
      :updated_at    => Time.new('2014-03-12T09:41:42-06:00')
    }
  end

  # We do not retrieve auth_password, but it is required for insert
  def cc_service_broker_with_password
    cc_service_broker.merge(:auth_password => 'password')
  end

  def cc_service_instance
    {
      :created_at      => Time.new('2014-02-12T09:40:52-06:00'),
      :guid            => 'service_instance1',
      :id              => 9,
      :dashboard_url   => 'http://www.ibm.com',
      :gateway_data    => nil,
      :gateway_name    => nil,
      :name            => 'TestService-random',
      :service_plan_id => cc_service_plan[:id],
      :space_id        => cc_space[:id],
      :updated_at      => Time.new('2014-03-12T09:40:52-06:00')
    }
  end

  def cc_service_plan
    {
      :active      => true,
      :created_at  => Time.new('2014-02-12T09:34:10-06:00'),
      :description => 'TestServicePlan description',
      :extra       => 'service plan extra',
      :free        => true,
      :guid        => 'service_plan1',
      :id          => 10,
      :name        => 'TestServicePlan',
      :public      => true,
      :service_id  => cc_service[:id],
      :unique_id   => 'service_plan_unique_id1',
      :updated_at  => Time.new('2014-03-12T09:34:10-06:00')
    }
  end

  def cc_service_plan_visibility
    {
      :created_at       => Time.new('2014-02-12T09:34:10-06:00'),
      :guid             => 'service_plan_visibility1',
      :id               => 11,
      :organization_id  => cc_organization[:id],
      :service_plan_id  => cc_service_plan[:id],
      :updated_at       => Time.new('2014-03-12T09:34:10-06:00')
    }
  end

  def cc_space
    {
      :created_at      => Time.new('2013-10-16T08:55:54-05:00'),
      :guid            => 'space1',
      :id              => 12,
      :name            => 'test_space',
      :organization_id => cc_organization[:id],
      :updated_at      => Time.new('2013-10-17T08:55:54-05:00')
    }
  end

  def cc_space_developer
    {
      :space_id => cc_space[:id],
      :user_id  => cc_user[:id]
    }
  end

  def cc_stack
    {
      :created_at  => Time.new('2013-10-16T08:55:54-05:00'),
      :description => 'TestStack description',
      :guid        => 'stack1',
      :id          => 13,
      :name        => 'lucid64'
    }
  end

  def cc_user
    {
      :active           => true,
      :admin            => false,
      :created_at       => Time.new('2013-10-16T08:55:54-05:00'),
      :default_space_id => nil,
      :guid             => 'user1',
      :id               => 14,
      :updated_at       => nil
    }
  end

  def uaa_group
    {
      :created      => Time.new('2014-10-16T08:55:27.339Z'),
      :displayname  => 'group1',
      :id           => 'group1',
      :lastmodified => Time.new('2014-10-23T07:07:50.425Z'),
      :version      => 5
    }
  end

  def uaa_group_membership
    {
      :group_id  => uaa_group[:id],
      :member_id => uaa_user[:id]
    }
  end

  def uaa_user
    {
      :active       => true,
      :created      => Time.new('2014-10-16T08:55:27.339Z'),
      :email        => 'admin',
      :familyname   => 'Flintstone',
      :givenname    => 'Fred',
      :id           => 'user1',
      :lastmodified => Time.new('2014-10-23T07:07:50.425Z'),
      :username     => 'admin',
      :version      => 5
    }
  end

  # We do not retrieve password, but it is required for insert
  def uaa_user_with_password
    uaa_user.merge(:password => 'password')
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

  def ccdb_inserts(insert_second_quota_definition)
    result = [[:quota_definitions,         cc_quota_definition],
              [:service_brokers,           cc_service_broker_with_password],
              [:stacks,                    cc_stack],
              [:organizations,             cc_organization],
              [:services,                  cc_service],
              [:domains,                   cc_domain],
              [:service_plans,             cc_service_plan],
              [:service_plan_visibilities, cc_service_plan_visibility],
              [:spaces,                    cc_space],
              [:apps,                      cc_app],
              [:routes,                    cc_route],
              [:service_instances,         cc_service_instance],
              [:users,                     cc_user],
              [:apps_routes,               cc_app_route],
              [:service_bindings,          cc_service_binding_with_credentials],
              [:spaces_developers,         cc_space_developer]
             ]

    result << [:quota_definitions, cc_quota_definition2] if insert_second_quota_definition
    result
  end

  def uaadb_inserts
    [[:groups,           uaa_group],
     [:users,            uaa_user_with_password],
     [:group_membership, uaa_group_membership]
    ]
  end

  def cc_app_stubs(config)
    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/apps/#{ cc_app[:guid] }", AdminUI::Utils::HTTP_PUT, anything, '{"state":"STOPPED"}', anything) do
      sql(config.ccdb_uri, "UPDATE apps SET state = 'STOPPED' WHERE guid = '#{ cc_app[:guid] }'")
      OK.new('{}')
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/apps/#{ cc_app[:guid] }", AdminUI::Utils::HTTP_PUT, anything, '{"state":"STARTED"}', anything) do
      sql(config.ccdb_uri, "UPDATE apps SET state = 'STARTED' WHERE guid = '#{ cc_app[:guid] }'")
      OK.new('{}')
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/apps/#{ cc_app[:guid] }?recursive=true", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      cc_clear_apps_cache_stub(config)
      Net::HTTPNoContent.new(1.0, 204, 'OK')
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

  def cc_organization_stubs(config)
    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/organizations", AdminUI::Utils::HTTP_POST, anything, "{\"name\":\"#{ cc_organization2[:name] }\"}", anything) do
      Sequel.connect(config.ccdb_uri, :single_threaded => false, :max_connections => 1) do |connection|
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
      OK.new('{}')
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/organizations/#{ cc_organization[:guid] }?recursive=true", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      cc_clear_organizations_cache_stub(config)
      Net::HTTPNoContent.new(1.0, 204, 'OK')
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/organizations/#{ cc_organization[:guid] }", AdminUI::Utils::HTTP_PUT, anything, "{\"quota_definition_guid\":\"#{ cc_quota_definition2[:guid] }\"}", anything) do
      sql(config.ccdb_uri, "UPDATE organizations SET quota_definition_id = (SELECT id FROM quota_definitions WHERE guid = '#{ cc_quota_definition2[:guid] }')")
      OK.new('{}')
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/organizations/#{ cc_organization[:guid] }", AdminUI::Utils::HTTP_PUT, anything, '{"status":"suspended"}', anything) do
      sql(config.ccdb_uri, "UPDATE organizations SET status = 'suspended' WHERE guid = '#{ cc_organization[:guid] }'")
      OK.new('{}')
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/organizations/#{ cc_organization[:guid] }", AdminUI::Utils::HTTP_PUT, anything, '{"status":"active"}', anything) do
      sql(config.ccdb_uri, "UPDATE organizations SET status = 'active' WHERE guid = '#{ cc_organization[:guid] }'")
      OK.new('{}')
    end
  end

  def cc_route_stubs(config)
    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/routes/#{ cc_route[:guid] }", AdminUI::Utils::HTTP_DELETE, anything, anything, anything) do
      cc_clear_routes_cache_stub(config)
      Net::HTTPNoContent.new(1.0, 204, 'OK')
    end
  end

  def cc_service_plan_stubs(config)
    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/service_plans/#{ cc_service_plan[:guid] }", AdminUI::Utils::HTTP_PUT, anything, '{"public": true }', anything) do
      sql(config.ccdb_uri, "UPDATE service_plans SET public = 'true' WHERE guid = '#{ cc_service_plan[:guid] }'")
      OK.new('{}')
    end

    AdminUI::Utils.stub(:http_request).with(anything, "#{ config.cloud_controller_uri }/v2/service_plans/#{ cc_service_plan[:guid] }", AdminUI::Utils::HTTP_PUT, anything, '{"public": false }', anything) do
      sql(config.ccdb_uri, "UPDATE service_plans SET public = 'false' WHERE guid = '#{ cc_service_plan[:guid] }'")
      OK.new('{}')
    end
  end

  def populate_db(db_uri, path, ordered_inserts)
    Sequel.connect(db_uri, :single_threaded => false, :max_connections => 1) do |connection|
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
    Sequel.connect(uri, :single_threaded => false, :max_connections => 1, :timeout => 1) do |connection|
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
