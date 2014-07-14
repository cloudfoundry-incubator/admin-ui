require 'logger'
require_relative '../spec_helper'

describe AdminUI::Operation, :type => :integration do
  include CCHelper
  include NATSHelper
  include VARZHelper
  include OperationHelper

  let(:data_file) { '/tmp/admin_ui_data.json' }
  let(:db_file)   { '/tmp/admin_ui_store.db' }
  let(:db_uri)    { "sqlite://#{ db_file }" }
  let(:log_file) { '/tmp/admin_ui.log' }
  let(:logger) { Logger.new(log_file) }
  let(:config) do
    AdminUI::Config.load(:cloud_controller_discovery_interval => 10,
                         :cloud_controller_uri                => 'http://api.cloudfoundry',
                         :data_file                           => data_file,
                         :db_uri                              => "#{ db_uri }",
                         :monitored_components                => [],
                         :uaa_client                          => { :id => 'id', :secret => 'secret' })
  end

  let(:client) { AdminUI::CCRestClient.new(config, logger) }

  before do
    AdminUI::Config.any_instance.stub(:validate)
    cc_stub(config)
    nats_stub
    varz_stub
    operation_stub(config)
  end

  let(:cc) { AdminUI::CC.new(config, logger, client) }
  let(:email) { AdminUI::EMail.new(config, logger) }
  let(:log_files) { AdminUI::LogFiles.new(config, logger) }
  let(:nats) { AdminUI::NATS.new(config, logger, email) }
  let(:varz) { AdminUI::VARZ.new(config, logger, nats) }
  let(:stats) { AdminUI::Stats.new(config, logger, cc, varz) }
  let(:tasks) { AdminUI::Tasks.new(config, logger) }
  let(:view_models) { AdminUI::ViewModels.new(config, logger, cc, log_files, stats, tasks, varz) }
  let(:operation) { AdminUI::Operation.new(config, logger, cc, client, varz, view_models) }

  after do
    Process.wait(Process.spawn({}, "rm -fr #{ db_file } #{ log_file }"))
  end

  context 'Stubbed HTTP' do
    context 'manage application' do
      before do
        # Make sure the original application status is STARTED
        expect(cc.applications['items'][0]['state']).to eq('STARTED')
      end

      it 'stops the running application' do
        # Mock the http request to return stopped application
        cc_stopped_apps_stub(config)
        expect { operation.manage_application('application1', '{"state":"STOPPED"}') }.to change { cc.applications['items'][0]['state'] }.from('STARTED').to('STOPPED')
      end

      it 'starts the stopped application' do
        # Make sure the application is stopped at first.
        cc_apps_stop_to_start_stub(config)
        operation.manage_application('application1', '{"state":"STOPPED"}')

        expect { operation.manage_application('application1', '{"state":"STARTED"}') }.to change { cc.applications['items'][0]['state'] }.from('STOPPED').to('STARTED')
      end

      it 'deletes the application' do
        cc_empty_applications_stub(config)
        expect { operation.delete_application('application1') }.to change { cc.applications['items'].length }.from(1).to(0)
      end
    end

    context 'manage organization' do
      before do
        # Make sure there is an organization
        expect(cc.organizations['items'].length).to eq(1)
      end

      it 'creates a new organization' do
        cc_multiple_organizations_stub(config)
        expect { operation.create_organization('{"name":"new_org"}') }.to change { cc.organizations['items'].length }.from(1).to(2)
        expect(cc.organizations['items'][1]['name']).to eq('new_org')
      end

      it 'deletes specific organization' do
        cc_empty_organizations_stub(config)
        expect { operation.delete_organization('organization1') }.to change { cc.organizations['items'].length }.from(1).to(0)
      end
    end

    context 'manage route' do
      before do
        # Make sure there is a route
        expect(cc.routes['items'].length).to eq(1)
      end

      it 'deletes specific route' do
        cc_empty_routes_stub(config)
        expect { operation.manage_route('route1') }.to change { cc.routes['items'].length }.from(1).to(0)
      end
    end

    context 'manage service plan' do
      before do
        # Make sure the original service plan's public field is true
        expect(cc.service_plans['items'][0]['public'].to_s).to eq('true')
      end

      it 'makes service plan private' do
        # Mock the http response for private service plan
        cc_service_plans_private_stub(config)
        expect { operation.manage_service_plan('service_plan1', '{"public": false }') }.to change { cc.service_plans['items'][0]['public'].to_s }.from('true').to('false')
      end
    end

    context 'manage organization' do
      before do
        # Make sure there is an organization
        expect(cc.organizations['items'].length).to eq(1)
      end

      it 'sets the quota for an organization' do
        cc_organization_with_different_quota_stub(config)
        expect { operation.manage_organization('organization1', '{"quota_definition_guid":"quota2"}') }.to change { cc.organizations['items'][0]['quota_definition_guid'] }.from('quota1').to('quota2')
      end

      it 'suspends the organization' do
        cc_suspended_organizations_stub(config)
        expect { operation.manage_organization('organization1', '{"status":"suspended"}') }.to change { cc.organizations['items'][0]['status'] }.from('active').to('suspended')
      end
    end
  end
end
