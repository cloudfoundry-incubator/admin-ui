require 'json'
require 'net/http'
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

  def cc_stub(config)
    IBM::AdminUI::Utils.stub(:http_get).with("#{ config.cloud_controller_uri }/info") do
      OK.new(cc_info)
    end

    IBM::AdminUI::Utils.stub(:http_post).with("#{ authorization_endpoint }/oauth/token", anything, anything) do
      OK.new(uaa_oauth)
    end

    IBM::AdminUI::Utils.stub(:http_get).with("#{ config.cloud_controller_uri }/v2/apps", anything, anything) do
      OK.new(cc_apps)
    end

    IBM::AdminUI::Utils.stub(:http_get).with("#{ config.cloud_controller_uri }/v2/organizations", anything, anything) do
      OK.new(cc_organizations)
    end

    IBM::AdminUI::Utils.stub(:http_get).with("#{ config.cloud_controller_uri }/v2/spaces", anything, anything) do
      OK.new(cc_spaces)
    end

    IBM::AdminUI::Utils.stub(:http_get).with("#{ config.cloud_controller_uri }/v2/users?inline-relations-depth=1", anything, anything) do
      OK.new(cc_users_deep)
    end

    IBM::AdminUI::Utils.stub(:http_get).with("#{ token_endpoint }/Users", anything, anything) do
      OK.new(uaa_users)
    end
  end

  def cc_apps
    {
      'total_results' => 1,
      'resources'     =>
      [
        {
          'metadata' =>
          {
            'created_at' => '2013-10-18T08:28:35-05:00',
            'guid'       => 'application1'
          },
          'entity'   =>
          {
            'detected_buildpack' => 'Ruby/Rack',
            'disk_quota'         => 12,
            'instances'          => 1,
            'memory'             => 11,
            'name'               => 'test',
            'space_guid'         => 'space1',
            'state'              => 'STARTED'
          }
        }
      ]
    }
  end

  def cc_organizations
    {
      'total_results' => 1,
      'resources'     =>
      [
        {
          'metadata' =>
          {
            'created_at' => '2013-10-16T08:55:46-05:00',
            'guid'       => 'organization1',
          },
          'entity'   =>
          {
            'billing_enabled' => false,
            'name'            => 'test_org',
            'status'          => 'active'
          }
        }
      ]
    }
  end

  def cc_spaces
    {
      'total_results' => 1,
      'resources'     =>
      [
        {
          'metadata' =>
          {
            'created_at' => '2013-10-16T08:55:54-05:00',
            'guid'       => 'space1'
          },
          'entity'   =>
          {
            'name'              => 'test_space',
            'organization_guid' => 'organization1'
          }
        }
      ]
    }
  end

  def cc_users_deep
    {
      'total_results' => 1,
      'resources'     =>
      [
        {
          'metadata' =>
          {
            'guid' => 'user1',
          },
          'entity' =>
          {
            'spaces' =>
            [
              {
                'metadata' =>
                {
                  'guid' => 'space1'
                }
              }
            ],
            'managed_spaces' =>
            [
              {
                'metadata' =>
                {
                  'guid' => 'space1'
                }
              }
            ],
            'audited_spaces' =>
            [
              {
                'metadata' =>
                {
                  'guid' => 'space1'
                }
              }
            ]
          }
        }
      ]
    }
  end

  def uaa_users
    {
      'totalResults' => 1,
      'resources'    =>
      [
        {
          'active'   => true,
          'id'       => 'user1',
          'userName' => 'admin',
          'meta'     =>
          {
            'created'      => '2013-10-16T08:55:27.339Z',
            'lastModified' => '2013-10-23T07:07:50.425Z',
            'version'      => 5,
          },
          'name'     =>
          {
            'familyName' => 'Flintstone',
            'givenName'  => 'Fred'
          },
          'emails'   =>
          [
            {
              'value' => 'admin'
            }
          ],
          'groups'   =>
          [
            {
              'display' => 'approvals.me'
            },
            {
              'display' => 'cloud_controller.admin'
            },
            {
              'display' => 'scim.read'
            },
            {
              'display' => 'openid'
            },
            {
              'display' => 'scim.write'
            },
            {
              'display' => 'cloud_controller.read'
            },
            {
              'display' => 'scim.userids'
            },
            {
              'display' => 'password.write'
            },
            {
              'display' => 'scim.me'
            },
            {
              'display' => 'cloud_controller.write'
            },
            {
              'display' => 'uaa.user'
            }
          ],
        },
      ]
    }
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
end
