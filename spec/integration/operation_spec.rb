require 'logger'
require_relative '../spec_helper'

describe AdminUI::Operation, type: :integration do
  include CCHelper
  include NATSHelper
  include ThreadHelper
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
    AdminUI::Config.load(ccdb_uri:                            ccdb_uri,
                         cloud_controller_discovery_interval: 10,
                         cloud_controller_uri:                'http://api.cloudfoundry',
                         data_file:                           data_file,
                         db_uri:                              db_uri,
                         mbus:                                'nats://nats:c1oudc0w@localhost:14222',
                         monitored_components:                [],
                         uaadb_uri:                           uaadb_uri,
                         uaa_client:                          { id: 'id', secret: 'secret' })
  end

  let(:client) { AdminUI::CCRestClient.new(config, logger) }

  def cleanup_files
    Process.wait(Process.spawn({}, "rm -fr #{ ccdb_file } #{ data_file } #{ db_file } #{ log_file } #{ uaadb_file }"))
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
    kill_threads
    cleanup_files
  end

  context 'Stubbed HTTP' do
    context 'manage application' do
      before do
        # Make sure the original application status is STARTED
        expect(cc.applications['items'][0][:state]).to eq('STARTED')
      end

      def delete_application
        operation.delete_application(cc_app[:guid])
      end

      def start_application
        operation.manage_application(cc_app[:guid], '{"state":"STARTED"}')
      end

      def stop_application
        operation.manage_application(cc_app[:guid], '{"state":"STOPPED"}')
      end

      it 'stops the running application' do
        expect { stop_application }.to change { cc.applications['items'][0][:state] }.from('STARTED').to('STOPPED')
      end

      it 'starts the stopped application' do
        # Make sure the application is stopped at first.
        stop_application

        expect { start_application }.to change { cc.applications['items'][0][:state] }.from('STOPPED').to('STARTED')
      end

      it 'deletes the application' do
        expect { delete_application }.to change { cc.applications['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_application
        end

        def verify_app_not_found(exception)
          expect(exception.cf_code).to eq(100_004)
          expect(exception.cf_error_code).to eq('CF-AppNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The app name could not be found: #{ cc_app[:guid] }")
        end

        it 'fails deleting deleted app' do
          expect { delete_application }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_app_not_found(exception) }
        end

        it 'fails starting deleted app' do
          expect { start_application }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_app_not_found(exception) }
        end

        it 'fails stopping deleted app' do
          expect { stop_application }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_app_not_found(exception) }
        end
      end
    end

    context 'manage domain' do
      before do
        # Make sure there is a domain
        expect(cc.domains['items'].length).to eq(1)
      end

      def delete_domain
        operation.delete_domain(cc_domain[:guid])
      end

      it 'deletes specific domain' do
        expect { delete_domain }.to change { cc.domains['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_domain
        end

        def verify_domain_not_found(exception)
          expect(exception.cf_code).to eq(130_002)
          expect(exception.cf_error_code).to eq('CF-DomainNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The domain could not be found: #{ cc_domain[:guid] }")
        end

        it 'fails deleting deleted domain' do
          expect { delete_domain }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_domain_not_found(exception) }
        end
      end
    end

    context 'manage organization' do
      before do
        # Make sure there is an organization
        expect(cc.organizations['items'].length).to eq(1)
      end

      def activate_organization
        operation.manage_organization(cc_organization[:guid], '{"status":"active"}')
      end

      def create_organization
        operation.create_organization("{\"name\":\"#{ cc_organization2[:name] }\"}")
      end

      def delete_organization
        operation.delete_organization(cc_organization[:guid])
      end

      def suspend_organization
        operation.manage_organization(cc_organization[:guid], '{"status":"suspended"}')
      end

      def set_organization_quota
        operation.manage_organization(cc_organization[:guid], "{\"quota_definition_guid\":\"#{ cc_quota_definition2[:guid] }\"}")
      end

      it 'creates a new organization' do
        expect { create_organization }.to change { cc.organizations['items'].length }.from(1).to(2)
        expect(cc.organizations['items'][1][:name]).to eq(cc_organization2[:name])
      end

      it 'deletes specific organization' do
        expect { delete_organization }.to change { cc.organizations['items'].length }.from(1).to(0)
      end

      context 'sets the quota for an organization' do
        let(:insert_second_quota_definition) { true }
        it 'sets the quota for an organization' do
          expect { set_organization_quota }.to change { cc.organizations['items'][0][:quota_definition_id] }.from(cc_quota_definition[:id]).to(cc_quota_definition2[:id])
        end
      end

      it 'activates the organization' do
        # Make sure the organization is suspended first.
        suspend_organization

        expect { activate_organization }.to change { cc.organizations['items'][0][:status] }.from('suspended').to('active')
      end

      it 'suspends the organization' do
        expect { suspend_organization }.to change { cc.organizations['items'][0][:status] }.from('active').to('suspended')
      end

      context 'errors' do
        context 'not found error' do
          before do
            delete_organization
          end

          def verify_organization_not_found(exception)
            expect(exception.cf_code).to eq(30_003)
            expect(exception.cf_error_code).to eq('CF-OrganizationNotFound')
            expect(exception.http_code).to eq(404)
            expect(exception.message).to eq("The organization could not be found: #{ cc_organization[:guid] }")
          end

          it 'fails deleting deleted organization' do
            expect { delete_organization }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_organization_not_found(exception) }
          end

          context 'fails setting quota for a deleted organization' do
            let(:insert_second_quota_definition) { true }
            it 'fails setting quota for a deleted organization' do
              expect { set_organization_quota }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_organization_not_found(exception) }
            end
          end

          it 'fails activating deleted organization' do
            expect { activate_organization }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_organization_not_found(exception) }
          end

          it 'fails suspending deleted organization' do
            expect { suspend_organization }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_organization_not_found(exception) }
          end
        end

        context 'bad request' do
          before do
            create_organization
          end

          def verify_organization_name_taken(exception)
            expect(exception.cf_code).to eq(30_002)
            expect(exception.cf_error_code).to eq('CF-OrganizationNameTaken')
            expect(exception.http_code).to eq(400)
            expect(exception.message).to eq("The organization name is taken: #{ cc_organization2[:name] }")
          end

          it 'failed creating created organization' do
            expect { create_organization }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_organization_name_taken(exception) }
          end
        end
      end
    end

    context 'manage organization roles' do
      def delete_organization_auditor
        operation.delete_organization_role(cc_organization[:guid], 'auditors', cc_user[:guid])
      end

      def delete_organization_billing_manager
        operation.delete_organization_role(cc_organization[:guid], 'billing_managers', cc_user[:guid])
      end

      def delete_organization_manager
        operation.delete_organization_role(cc_organization[:guid], 'managers', cc_user[:guid])
      end

      def delete_organization_user
        operation.delete_organization_role(cc_organization[:guid], 'users', cc_user[:guid])
      end

      it 'deletes specific organization auditor role' do
        expect { delete_organization_auditor }.to change { cc.organizations_auditors['items'].length }.from(1).to(0)
      end

      it 'deletes specific organization billing_manager role' do
        expect { delete_organization_billing_manager }.to change { cc.organizations_billing_managers['items'].length }.from(1).to(0)
      end

      it 'deletes specific organization manager role' do
        expect { delete_organization_manager }.to change { cc.organizations_managers['items'].length }.from(1).to(0)
      end

      it 'deletes specific organization user role' do
        expect { delete_organization_user }.to change { cc.organizations_users['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          cc_clear_organizations_cache_stub(config)
        end

        def verify_organization_not_found(exception)
          expect(exception.cf_code).to eq(30_003)
          expect(exception.cf_error_code).to eq('CF-OrganizationNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The organization could not be found: #{ cc_organization[:guid] }")
        end

        it 'failed deleting organization auditor role due to deleted organization' do
          expect { delete_organization_auditor }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_organization_not_found(exception) }
        end

        it 'failed deleting organization billing manager role due to deleted organization' do
          expect { delete_organization_billing_manager }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_organization_not_found(exception) }
        end

        it 'failed deleting organization manager role due to deleted organization' do
          expect { delete_organization_manager }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_organization_not_found(exception) }
        end

        it 'failed deleting organization user role due to deleted organization' do
          expect { delete_organization_user }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_organization_not_found(exception) }
        end
      end
    end

    context 'manage quota definition' do
      before do
        # Make sure there is a quota definition
        expect(cc.quota_definitions['items'].length).to eq(1)
      end

      def delete_quota_definition
        operation.delete_quota_definition(cc_quota_definition[:guid])
      end

      it 'deletes specific quota definition' do
        expect { delete_quota_definition }.to change { cc.quota_definitions['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_quota_definition
        end

        def verify_quota_definition_not_found(exception)
          expect(exception.cf_code).to eq(240_001)
          expect(exception.cf_error_code).to eq('CF-QuotaDefinitionNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("Quota Definition could not be found: #{ cc_quota_definition[:guid] }")
        end

        it 'fails deleting deleted quota definition' do
          expect { delete_quota_definition }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_quota_definition_not_found(exception) }
        end
      end
    end

    context 'manage route' do
      before do
        # Make sure there is a route
        expect(cc.routes['items'].length).to eq(1)
      end

      def delete_route
        operation.delete_route(cc_route[:guid])
      end

      it 'deletes specific route' do
        expect { delete_route }.to change { cc.routes['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_route
        end

        def verify_route_not_found(exception)
          expect(exception.cf_code).to eq(210_002)
          expect(exception.cf_error_code).to eq('CF-RouteNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The route could not be found: #{ cc_route[:guid] }")
        end

        it 'fails deleting deleted route' do
          expect { delete_route }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_route_not_found(exception) }
        end
      end
    end

    context 'manage service' do
      before do
        # Make sure there is a service
        expect(cc.services['items'].length).to eq(1)
      end

      def delete_service
        operation.delete_service(cc_service[:guid], false)
      end

      def purge_service
        operation.delete_service(cc_service[:guid], true)
      end

      it 'deletes specific service' do
        expect { delete_service }.to change { cc.services['items'].length }.from(1).to(0)
      end

      it 'purges specific service' do
        expect { purge_service }.to change { cc.services['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_service
        end

        def verify_service_not_found(exception)
          expect(exception.cf_code).to eq(120_003)
          expect(exception.cf_error_code).to eq('CF-ServiceNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The service could not be found: #{ cc_service[:guid] }")
        end

        it 'fails deleting deleted service' do
          expect { delete_service }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_not_found(exception) }
        end

        it 'fails purging deleted service' do
          expect { purge_service }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_not_found(exception) }
        end
      end
    end

    context 'manage service binding' do
      before do
        # Make sure there is a service binding
        expect(cc.service_bindings['items'].length).to eq(1)
      end

      def delete_service_binding
        operation.delete_service_binding(cc_service_binding[:guid])
      end

      it 'deletes specific service binding' do
        expect { delete_service_binding }.to change { cc.service_bindings['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_service_binding
        end

        def verify_service_binding_not_found(exception)
          expect(exception.cf_code).to eq(90_004)
          expect(exception.cf_error_code).to eq('CF-ServiceBindingNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The service binding could not be found: #{ cc_service_binding[:guid] }")
        end

        it 'fails deleting deleted service binding' do
          expect { delete_service_binding }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_binding_not_found(exception) }
        end
      end
    end

    context 'manage service broker' do
      before do
        # Make sure there is a service broker
        expect(cc.service_brokers['items'].length).to eq(1)
      end

      def delete_service_broker
        operation.delete_service_broker(cc_service_broker[:guid])
      end

      it 'deletes specific service broker' do
        expect { delete_service_broker }.to change { cc.service_brokers['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_service_broker
        end

        def verify_service_broker_not_found(exception)
          expect(exception.cf_code).to eq(10_000)
          expect(exception.cf_error_code).to eq('CF-NotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq('Unknown request')
        end

        it 'fails deleting deleted service broker' do
          expect { delete_service_broker }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_broker_not_found(exception) }
        end
      end
    end

    context 'manage service instance' do
      before do
        # Make sure there is a service instance
        expect(cc.service_instances['items'].length).to eq(1)
      end

      def delete_service_instance
        operation.delete_service_instance(cc_service_instance[:guid])
      end

      it 'deletes specific service instance' do
        expect { delete_service_instance }.to change { cc.service_instances['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_service_instance
        end

        def verify_service_instance_not_found(exception)
          expect(exception.cf_code).to eq(60_004)
          expect(exception.cf_error_code).to eq('CF-ServiceInstanceNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The service instance could not be found: #{ cc_service_instance[:guid] }")
        end

        it 'fails deleting deleted service instance' do
          expect { delete_service_instance }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_instance_not_found(exception) }
        end
      end
    end

    context 'manage service plan' do
      before do
        # Make sure there is a service plan
        expect(cc.service_plans['items'].length).to eq(1)

        # Make sure the original service plan's public field is true
        expect(cc.service_plans['items'][0][:public].to_s).to eq('true')
      end

      def make_service_plan_public
        operation.manage_service_plan(cc_service_plan[:guid], '{"public": true }')
      end

      def make_service_plan_private
        operation.manage_service_plan(cc_service_plan[:guid], '{"public": false }')
      end

      def delete_service_plan
        operation.delete_service_plan(cc_service_plan[:guid])
      end

      it 'makes service plan public' do
        # Make sure the service plan is private first.
        make_service_plan_private

        expect { make_service_plan_public }.to change { cc.service_plans['items'][0][:public].to_s }.from('false').to('true')
      end

      it 'makes service plan private' do
        expect { make_service_plan_private }.to change { cc.service_plans['items'][0][:public].to_s }.from('true').to('false')
      end

      it 'deletes specific service plan' do
        expect { delete_service_plan }.to change { cc.service_plans['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_service_plan
        end

        def verify_service_plan_not_found(exception)
          expect(exception.cf_code).to eq(110_003)
          expect(exception.cf_error_code).to eq('CF-ServicePlanNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The service plan could not be found: #{ cc_service_plan[:guid] }")
        end

        it 'fails making service plan public when service plan is deleted' do
          expect { make_service_plan_public }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_plan_not_found(exception) }
        end

        it 'fails making service plan private when service plan is deleted' do
          expect { make_service_plan_private }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_plan_not_found(exception) }
        end

        it 'fails deleting deleted service plan' do
          expect { delete_service_plan }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_plan_not_found(exception) }
        end
      end
    end

    context 'manage service plan visibility' do
      before do
        # Make sure there is a service plan visibility
        expect(cc.service_plan_visibilities['items'].length).to eq(1)
      end

      def delete_service_plan_visibility
        operation.delete_service_plan_visibility(cc_service_plan_visibility[:guid])
      end

      it 'deletes specific service plan visibility' do
        expect { delete_service_plan_visibility }.to change { cc.service_plan_visibilities['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_service_plan_visibility
        end

        def verify_service_plan_visibility_not_found(exception)
          expect(exception.cf_code).to eq(260_003)
          expect(exception.cf_error_code).to eq('CF-ServicePlanVisibilityNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The service plan visibility could not be found: #{ cc_service_plan[:guid] }")
        end

        it 'fails deleting deleted service plan visibility' do
          expect { delete_service_plan_visibility }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_plan_visibility_not_found(exception) }
        end
      end
    end

    context 'manage space' do
      before do
        # Make sure there is a space
        expect(cc.spaces['items'].length).to eq(1)
      end

      def delete_space
        operation.delete_space(cc_space[:guid])
      end

      it 'deletes specific space' do
        expect { delete_space }.to change { cc.spaces['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_space
        end

        def verify_space_not_found(exception)
          expect(exception.cf_code).to eq(40_004)
          expect(exception.cf_error_code).to eq('CF-SpaceNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The app space could not be found: #{ cc_space[:guid] }")
        end

        it 'fails deleting deleted space' do
          expect { delete_space }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_space_not_found(exception) }
        end
      end
    end

    context 'manage space roles' do
      def delete_space_auditor
        operation.delete_space_role(cc_space[:guid], 'auditors', cc_user[:guid])
      end

      def delete_space_developer
        operation.delete_space_role(cc_space[:guid], 'developers', cc_user[:guid])
      end

      def delete_space_manager
        operation.delete_space_role(cc_space[:guid], 'managers', cc_user[:guid])
      end

      it 'deletes specific space auditor role' do
        expect { delete_space_auditor }.to change { cc.spaces_auditors['items'].length }.from(1).to(0)
      end

      it 'deletes specific space developer role' do
        expect { delete_space_developer }.to change { cc.spaces_developers['items'].length }.from(1).to(0)
      end

      it 'deletes specific space manager role' do
        expect { delete_space_manager }.to change { cc.spaces_managers['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          cc_clear_spaces_cache_stub(config)
        end

        def verify_space_not_found(exception)
          expect(exception.cf_code).to eq(40_004)
          expect(exception.cf_error_code).to eq('CF-SpaceNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The app space could not be found: #{ cc_space[:guid] }")
        end

        it 'failed deleting space auditor role due to deleted space' do
          expect { delete_space_auditor }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_space_not_found(exception) }
        end

        it 'failed deleting space developer role due to deleted space' do
          expect { delete_space_developer }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_space_not_found(exception) }
        end

        it 'failed deleting space manager role due to deleted space' do
          expect { delete_space_manager }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_space_not_found(exception) }
        end
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
