require 'logger'
require_relative '../spec_helper'

describe AdminUI::Operation, :type => :integration do
  include CCHelper
  include NATSHelper
  include VARZHelper
  include OperationHelper

  let(:data_file) { '/tmp/admin_ui_data.json' }
  let(:log_file) { '/tmp/admin_ui.log' }
  let(:logger) { Logger.new(log_file) }
  let(:config) do
    AdminUI::Config.load(:cloud_controller_discovery_interval => 10,
                         :cloud_controller_uri                => 'http://api.cloudfoundry',
                         :data_file                           => data_file,
                         :monitored_components                => [],
                         :uaa_admin_credentials               => { :username => 'user', :password => 'password' })
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
  let(:nats) { AdminUI::NATS.new(config, logger, email) }
  let(:varz) { AdminUI::VARZ.new(config, logger, nats) }
  let(:operation) { AdminUI::Operation.new(config, logger, cc, client, varz) }

  after do
    Process.wait(Process.spawn({}, "rm -fr #{ log_file }"))
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
    end

    context 'manage route' do
      before do
        # Make sure there is a route
        expect(cc.routes['items'].length).to eq(1)
      end

      it 'deletes specific route' do
        cc_empty_routes_stub(config)
        expect { operation.manage_route('DELETE', 'route1') }.to change { cc.routes['items'].length }.from(1).to(0)
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
  end
end
