require 'logger'
require_relative '../spec_helper'

describe AdminUI::Operation, :type => :integration do
  include CCHelper
  include NATSHelper
  include VARZHelper

  let(:ccdb_file) { '/tmp/admin_ui_ccdb.db' }
  let(:ccdb_uri) { "sqlite://#{ ccdb_file }" }
  let(:data_file) { '/tmp/admin_ui_data.json' }
  let(:db_file) { '/tmp/admin_ui_store.db' }
  let(:db_uri) { "sqlite://#{ db_file }" }
  let(:insert_second_quota_definition) { false }
  let(:log_file) { '/tmp/admin_ui.log' }
  let(:logger) { Logger.new(log_file) }
  let(:uaadb_file) { '/tmp/admin_ui_uaadb.db' }
  let(:uaadb_uri) { "sqlite://#{ uaadb_file }" }
  let(:config) do
    AdminUI::Config.load(:ccdb_uri                            => ccdb_uri,
                         :cloud_controller_discovery_interval => 10,
                         :cloud_controller_uri                => 'http://api.cloudfoundry',
                         :data_file                           => data_file,
                         :db_uri                              => "#{ db_uri }",
                         :monitored_components                => [],
                         :uaadb_uri                           => uaadb_uri,
                         :uaa_client                          => { :id => 'id', :secret => 'secret' })
  end

  let(:client) { AdminUI::CCRestClient.new(config, logger) }

  def cleanup_files
    Process.wait(Process.spawn({}, "rm -fr #{ ccdb_file } #{ db_file } #{ log_file } #{ uaadb_file }"))
  end

  before do
    cleanup_files

    AdminUI::Config.any_instance.stub(:validate)
    cc_stub(config, insert_second_quota_definition)
    nats_stub
    varz_stub
  end

  let(:cc) { AdminUI::CC.new(config, logger, client, true) }
  let(:email) { AdminUI::EMail.new(config, logger) }
  let(:log_files) { AdminUI::LogFiles.new(config, logger) }
  let(:nats) { AdminUI::NATS.new(config, logger, email) }
  let(:varz) { AdminUI::VARZ.new(config, logger, nats, true) }
  let(:stats) { AdminUI::Stats.new(config, logger, cc, varz) }
  let(:tasks) { AdminUI::Tasks.new(config, logger) }
  let(:view_models) { AdminUI::ViewModels.new(config, logger, cc, log_files, stats, tasks, varz, true) }
  let(:operation) { AdminUI::Operation.new(config, logger, cc, client, varz, view_models) }

  after do
    cleanup_files
  end

  context 'Stubbed HTTP' do
    context 'manage application' do
      before do
        # Make sure the original application status is STARTED
        expect(cc.applications['items'][0][:state]).to eq('STARTED')
      end

      def stop_application
        operation.manage_application(cc_app[:guid], '{"state":"STOPPED"}')
      end

      it 'stops the running application' do
        # Mock the http request to return stopped application
        expect { stop_application }.to change { cc.applications['items'][0][:state] }.from('STARTED').to('STOPPED')
      end

      it 'starts the stopped application' do
        # Make sure the application is stopped at first.
        stop_application

        expect { operation.manage_application(cc_app[:guid], '{"state":"STARTED"}') }.to change { cc.applications['items'][0][:state] }.from('STOPPED').to('STARTED')
      end

      it 'deletes the application' do
        expect { operation.delete_application(cc_app[:guid]) }.to change { cc.applications['items'].length }.from(1).to(0)
      end
    end

    context 'manage organization' do
      before do
        # Make sure there is an organization
        expect(cc.organizations['items'].length).to eq(1)
      end

      it 'creates a new organization' do
        expect { operation.create_organization("{\"name\":\"#{ cc_organization2[:name] }\"}") }.to change { cc.organizations['items'].length }.from(1).to(2)
        expect(cc.organizations['items'][1][:name]).to eq(cc_organization2[:name])
      end

      it 'deletes specific organization' do
        expect { operation.delete_organization(cc_organization[:guid]) }.to change { cc.organizations['items'].length }.from(1).to(0)
      end

      context 'sets the quota for an organization' do
        let(:insert_second_quota_definition) { true }
        it 'sets the quota for an organization' do
          expect { operation.manage_organization(cc_organization[:guid], "{\"quota_definition_guid\":\"#{ cc_quota_definition2[:guid] }\"}") }.to change { cc.organizations['items'][0][:quota_definition_id] }.from(cc_quota_definition[:id]).to(cc_quota_definition2[:id])
        end
      end

      it 'suspends the organization' do
        expect { operation.manage_organization(cc_organization[:guid], '{"status":"suspended"}') }.to change { cc.organizations['items'][0][:status] }.from('active').to('suspended')
      end
    end

    context 'manage organization roles' do
      it 'deletes specific organization auditor role' do
        expect { operation.delete_organization_role(cc_organization[:guid], 'auditors', cc_user[:guid]) }.to change { cc.organizations_auditors['items'].length }.from(1).to(0)
      end

      it 'deletes specific organization billing_manager role' do
        expect { operation.delete_organization_role(cc_organization[:guid], 'billing_managers', cc_user[:guid]) }.to change { cc.organizations_billing_managers['items'].length }.from(1).to(0)
      end

      it 'deletes specific organization manager role' do
        expect { operation.delete_organization_role(cc_organization[:guid], 'managers', cc_user[:guid]) }.to change { cc.organizations_managers['items'].length }.from(1).to(0)
      end

      it 'deletes specific organization user role' do
        expect { operation.delete_organization_role(cc_organization[:guid], 'users', cc_user[:guid]) }.to change { cc.organizations_users['items'].length }.from(1).to(0)
      end
    end

    context 'manage route' do
      before do
        # Make sure there is a route
        expect(cc.routes['items'].length).to eq(1)
      end

      it 'deletes specific route' do
        expect { operation.delete_route(cc_route[:guid]) }.to change { cc.routes['items'].length }.from(1).to(0)
      end
    end

    context 'manage service plan' do
      before do
        # Make sure the original service plan's public field is true
        expect(cc.service_plans['items'][0][:public].to_s).to eq('true')
      end

      it 'makes service plan private' do
        expect { operation.manage_service_plan(cc_service_plan[:guid], '{"public": false }') }.to change { cc.service_plans['items'][0][:public].to_s }.from('true').to('false')
      end
    end

    context 'manage space roles' do
      it 'deletes specific space auditor role' do
        expect { operation.delete_space_role(cc_space[:guid], 'auditors', cc_user[:guid]) }.to change { cc.spaces_auditors['items'].length }.from(1).to(0)
      end

      it 'deletes specific space developer role' do
        expect { operation.delete_space_role(cc_space[:guid], 'developers', cc_user[:guid]) }.to change { cc.spaces_developers['items'].length }.from(1).to(0)
      end

      it 'deletes specific space manager role' do
        expect { operation.delete_space_role(cc_space[:guid], 'managers', cc_user[:guid]) }.to change { cc.spaces_managers['items'].length }.from(1).to(0)
      end
    end

    context 'manage varz components' do
      before do
        expect(varz.components['items'].length).to eq(5)
      end

      after do
        expect(varz.components['items'].length).to eq(4)
      end

      it 'removes cloud_controller' do
        expect { operation.remove_component(nats_cloud_controller_varz) }.to change { varz.cloud_controllers['items'].length }.from(1).to(0)
      end

      it 'removes dea' do
        expect { operation.remove_component(nats_dea_varz) }.to change { varz.deas['items'].length }.from(1).to(0)
      end

      it 'removes gateway' do
        expect { operation.remove_component(nats_provisioner_varz) }.to change { varz.gateways['items'].length }.from(1).to(0)
      end

      it 'removes health_manager' do
        expect { operation.remove_component(nats_health_manager_varz) }.to change { varz.health_managers['items'].length }.from(1).to(0)
      end

      it 'removes router' do
        expect { operation.remove_component(nats_router_varz) }.to change { varz.routers['items'].length }.from(1).to(0)
      end
    end
  end
end
