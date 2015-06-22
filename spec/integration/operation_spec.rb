require 'logger'
require_relative '../spec_helper'

describe AdminUI::Operation, type: :integration do
  include CCHelper
  include ConfigHelper
  include NATSHelper
  include VARZHelper

  let(:ccdb_file) { '/tmp/admin_ui_ccdb.db' }
  let(:ccdb_uri) { "sqlite://#{ccdb_file}" }
  let(:data_file) { '/tmp/admin_ui_data.json' }
  let(:db_file) { '/tmp/admin_ui_store.db' }
  let(:db_uri) { "sqlite://#{db_file}" }
  let(:insert_second_quota_definition) { false }
  let(:log_file) { '/tmp/admin_ui.log' }
  let(:logger) { Logger.new(log_file) }
  let(:uaadb_file) { '/tmp/admin_ui_uaadb.db' }
  let(:uaadb_uri) { "sqlite://#{uaadb_file}" }
  let(:config) do
    AdminUI::Config.load(ccdb_uri:             ccdb_uri,
                         cloud_controller_uri: 'http://api.cloudfoundry',
                         data_file:            data_file,
                         db_uri:               db_uri,
                         mbus:                 'nats://nats:c1oudc0w@localhost:14222',
                         monitored_components: [],
                         uaadb_uri:            uaadb_uri,
                         uaa_client:           { id: 'id', secret: 'secret' })
  end
  let(:client) { AdminUI::CCRestClient.new(config, logger) }
  let(:cc) { AdminUI::CC.new(config, logger, client, true) }
  let(:email) { AdminUI::EMail.new(config, logger) }
  let(:log_files) { AdminUI::LogFiles.new(config, logger) }
  let(:nats) { AdminUI::NATS.new(config, logger, email) }
  let(:varz) { AdminUI::VARZ.new(config, logger, nats, true) }
  let(:stats) { AdminUI::Stats.new(config, logger, cc, varz, true) }
  let(:tasks) { AdminUI::Tasks.new(config, logger) }
  let(:view_models) { AdminUI::ViewModels.new(config, logger, cc, log_files, stats, tasks, varz, true) }
  let(:operation) { AdminUI::Operation.new(config, logger, cc, client, varz, view_models) }

  def cleanup_files
    Process.wait(Process.spawn({}, "rm -fr #{ccdb_file} #{data_file} #{db_file} #{log_file} #{uaadb_file}"))
  end

  before do
    cleanup_files

    config_stub
    cc_stub(config, insert_second_quota_definition)
    nats_stub
    varz_stub
  end

  after do
    view_models.shutdown
    stats.shutdown
    varz.shutdown
    nats.shutdown
    cc.shutdown

    view_models.join
    stats.join
    varz.join
    nats.join
    cc.join

    cleanup_files
  end

  context 'Stubbed HTTP' do
    context 'manage application' do
      before do
        expect(cc.applications['items'][0][:state]).to eq('STARTED')
      end

      def delete_application
        operation.delete_application(cc_app[:guid], false)
      end

      def delete_application_recursive
        operation.delete_application(cc_app[:guid], true)
      end

      def restage_application
        operation.restage_application(cc_app[:guid])
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
        stop_application
        expect { start_application }.to change { cc.applications['items'][0][:state] }.from('STOPPED').to('STARTED')
      end

      it 'restages the application' do
        restage_application
      end

      it 'deletes the application' do
        expect { delete_application }.to change { cc.applications['items'].length }.from(1).to(0)
      end

      it 'deletes the application recursive' do
        expect { delete_application_recursive }.to change { cc.applications['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_application
        end

        def verify_app_not_found(exception)
          expect(exception.cf_code).to eq(100_004)
          expect(exception.cf_error_code).to eq('CF-AppNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The app name could not be found: #{cc_app[:guid]}")
        end

        it 'fails starting deleted app' do
          expect { start_application }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_app_not_found(exception) }
        end

        it 'fails stopping deleted app' do
          expect { stop_application }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_app_not_found(exception) }
        end

        it 'fails restaging deleted app' do
          expect { restage_application }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_app_not_found(exception) }
        end

        it 'fails deleting deleted app' do
          expect { delete_application }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_app_not_found(exception) }
        end

        it 'fails deleting recursive deleted app' do
          expect { delete_application_recursive }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_app_not_found(exception) }
        end
      end
    end

    context 'manage application instance' do
      before do
        expect(varz.deas['items'].length).to eq(1)
        expect(varz.deas['items'][0]['data']['instance_registry'].length).to eq(1)
      end

      def delete_application_instance
        operation.delete_application_instance(cc_app[:guid], cc_app_instance_index)
      end

      it 'deletes the application instance' do
        expect { delete_application_instance }.to change { varz.deas['items'][0]['data']['instance_registry'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_application_instance
        end

        def verify_app_not_found(exception)
          expect(exception.cf_code).to eq(100_004)
          expect(exception.cf_error_code).to eq('CF-AppNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The app name could not be found: #{cc_app[:guid]}")
        end

        it 'fails deleting instance of deleted app' do
          expect { delete_application_instance }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_app_not_found(exception) }
        end
      end
    end

    context 'buildpack' do
      before do
        expect(cc.buildpacks['items'][0][:enabled]).to eq(true)
        expect(cc.buildpacks['items'][0][:locked]).to eq(false)
      end

      def delete_buildpack
        operation.delete_buildpack(cc_buildpack[:guid])
      end

      def disable_buildpack
        operation.manage_buildpack(cc_buildpack[:guid], '{"enabled":false}')
      end

      def enable_buildpack
        operation.manage_buildpack(cc_buildpack[:guid], '{"enabled":true}')
      end

      def lock_buildpack
        operation.manage_buildpack(cc_buildpack[:guid], '{"locked":true}')
      end

      def unlock_buildpack
        operation.manage_buildpack(cc_buildpack[:guid], '{"locked":false}')
      end

      it 'disables the buildpack' do
        expect { disable_buildpack }.to change { cc.buildpacks['items'][0][:enabled] }.from(true).to(false)
      end

      it 'enables the buildpack' do
        disable_buildpack
        expect { enable_buildpack }.to change { cc.buildpacks['items'][0][:enabled] }.from(false).to(true)
      end

      it 'locks the buildpack' do
        expect { lock_buildpack }.to change { cc.buildpacks['items'][0][:locked] }.from(false).to(true)
      end

      it 'unlocks the buildpack' do
        lock_buildpack
        expect { unlock_buildpack }.to change { cc.buildpacks['items'][0][:locked] }.from(true).to(false)
      end

      it 'deletes the buildpack' do
        expect { delete_buildpack }.to change { cc.buildpacks['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_buildpack
        end

        def verify_buildpack_not_found(exception)
          expect(exception.cf_code).to eq(10_000)
          expect(exception.cf_error_code).to eq('CF-NotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq('Unknown request')
        end

        it 'fails disabling deleted buildpack' do
          expect { disable_buildpack }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_buildpack_not_found(exception) }
        end

        it 'fails enabling deleted buildpack' do
          expect { enable_buildpack }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_buildpack_not_found(exception) }
        end

        it 'fails locked deleted buildpack' do
          expect { lock_buildpack }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_buildpack_not_found(exception) }
        end

        it 'fails unlocking deleted buildpack' do
          expect { unlock_buildpack }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_buildpack_not_found(exception) }
        end

        it 'fails deleting deleted buildpack' do
          expect { delete_buildpack }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_buildpack_not_found(exception) }
        end
      end
    end

    context 'manage domain' do
      before do
        expect(cc.domains['items'].length).to eq(1)
      end

      def delete_domain
        operation.delete_domain(cc_domain[:guid], false)
      end

      def delete_domain_recursive
        operation.delete_domain(cc_domain[:guid], true)
      end

      it 'deletes domain' do
        expect { delete_domain }.to change { cc.domains['items'].length }.from(1).to(0)
      end

      it 'deletes domain recursive' do
        expect { delete_domain_recursive }.to change { cc.domains['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_domain
        end

        def verify_domain_not_found(exception)
          expect(exception.cf_code).to eq(130_002)
          expect(exception.cf_error_code).to eq('CF-DomainNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The domain could not be found: #{cc_domain[:guid]}")
        end

        it 'fails deleting deleted domain' do
          expect { delete_domain }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_domain_not_found(exception) }
        end

        it 'fails deleting recursive deleted domain' do
          expect { delete_domain_recursive }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_domain_not_found(exception) }
        end
      end
    end

    context 'manage organization' do
      before do
        expect(cc.organizations['items'].length).to eq(1)
      end

      def create_organization
        operation.create_organization("{\"name\":\"#{cc_organization2[:name]}\"}")
      end

      def rename_organization
        operation.manage_organization(cc_organization[:guid], "{\"name\":\"#{cc_organization2[:name]}\"}")
      end

      def set_organization_quota
        operation.manage_organization(cc_organization[:guid], "{\"quota_definition_guid\":\"#{cc_quota_definition2[:guid]}\"}")
      end

      def activate_organization
        operation.manage_organization(cc_organization[:guid], '{"status":"active"}')
      end

      def suspend_organization
        operation.manage_organization(cc_organization[:guid], '{"status":"suspended"}')
      end

      def delete_organization
        operation.delete_organization(cc_organization[:guid], false)
      end

      def delete_organization_recursive
        operation.delete_organization(cc_organization[:guid], true)
      end

      it 'creates a new organization' do
        expect { create_organization }.to change { cc.organizations['items'].length }.from(1).to(2)
        expect(cc.organizations['items'][1][:name]).to eq(cc_organization2[:name])
      end

      it 'renames the organization' do
        expect { rename_organization }.to change { cc.organizations['items'][0][:name] }.from(cc_organization[:name]).to(cc_organization2[:name])
      end

      context 'sets the quota for an organization' do
        let(:insert_second_quota_definition) { true }
        it 'sets the quota for an organization' do
          expect { set_organization_quota }.to change { cc.organizations['items'][0][:quota_definition_id] }.from(cc_quota_definition[:id]).to(cc_quota_definition2[:id])
        end
      end

      it 'activates the organization' do
        suspend_organization
        expect { activate_organization }.to change { cc.organizations['items'][0][:status] }.from('suspended').to('active')
      end

      it 'suspends the organization' do
        expect { suspend_organization }.to change { cc.organizations['items'][0][:status] }.from('active').to('suspended')
      end

      it 'deletes organization' do
        expect { delete_organization }.to change { cc.organizations['items'].length }.from(1).to(0)
      end

      it 'deletes organization recursive' do
        expect { delete_organization_recursive }.to change { cc.organizations['items'].length }.from(1).to(0)
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
            expect(exception.message).to eq("The organization could not be found: #{cc_organization[:guid]}")
          end

          it 'fails renaming deleted organization' do
            expect { rename_organization }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_organization_not_found(exception) }
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

          it 'fails deleting deleted organization' do
            expect { delete_organization }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_organization_not_found(exception) }
          end

          it 'fails deleting recursive deleted organization' do
            expect { delete_organization_recursive }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_organization_not_found(exception) }
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
            expect(exception.message).to eq("The organization name is taken: #{cc_organization2[:name]}")
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

      it 'deletes organization auditor role' do
        expect { delete_organization_auditor }.to change { cc.organizations_auditors['items'].length }.from(1).to(0)
      end

      it 'deletes organization billing_manager role' do
        expect { delete_organization_billing_manager }.to change { cc.organizations_billing_managers['items'].length }.from(1).to(0)
      end

      it 'deletes organization manager role' do
        expect { delete_organization_manager }.to change { cc.organizations_managers['items'].length }.from(1).to(0)
      end

      it 'deletes organization user role' do
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
          expect(exception.message).to eq("The organization could not be found: #{cc_organization[:guid]}")
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
        expect(cc.quota_definitions['items'].length).to eq(1)
      end

      def delete_quota_definition
        operation.delete_quota_definition(cc_quota_definition[:guid])
      end

      it 'deletes quota definition' do
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
          expect(exception.message).to eq("Quota Definition could not be found: #{cc_quota_definition[:guid]}")
        end

        it 'fails deleting deleted quota definition' do
          expect { delete_quota_definition }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_quota_definition_not_found(exception) }
        end
      end
    end

    context 'manage route' do
      before do
        expect(cc.routes['items'].length).to eq(1)
      end

      def delete_route
        operation.delete_route(cc_route[:guid])
      end

      it 'deletes route' do
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
          expect(exception.message).to eq("The route could not be found: #{cc_route[:guid]}")
        end

        it 'fails deleting deleted route' do
          expect { delete_route }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_route_not_found(exception) }
        end
      end
    end

    context 'manage service' do
      before do
        expect(cc.services['items'].length).to eq(1)
      end

      def delete_service
        operation.delete_service(cc_service[:guid], false)
      end

      def purge_service
        operation.delete_service(cc_service[:guid], true)
      end

      it 'deletes service' do
        expect { delete_service }.to change { cc.services['items'].length }.from(1).to(0)
      end

      it 'purges service' do
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
          expect(exception.message).to eq("The service could not be found: #{cc_service[:guid]}")
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
        expect(cc.service_bindings['items'].length).to eq(1)
      end

      def delete_service_binding
        operation.delete_service_binding(cc_service_binding[:guid])
      end

      it 'deletes service binding' do
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
          expect(exception.message).to eq("The service binding could not be found: #{cc_service_binding[:guid]}")
        end

        it 'fails deleting deleted service binding' do
          expect { delete_service_binding }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_binding_not_found(exception) }
        end
      end
    end

    context 'manage service broker' do
      before do
        expect(cc.service_brokers['items'].length).to eq(1)
      end

      def delete_service_broker
        operation.delete_service_broker(cc_service_broker[:guid])
      end

      it 'deletes service broker' do
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
        expect(cc.service_instances['items'].length).to eq(1)
      end

      def delete_service_instance
        operation.delete_service_instance(cc_service_instance[:guid], false)
      end

      def delete_service_instance_recursive
        operation.delete_service_instance(cc_service_instance[:guid], true)
      end

      it 'deletes service instance' do
        expect { delete_service_instance }.to change { cc.service_instances['items'].length }.from(1).to(0)
      end

      it 'deletes service instance recursive' do
        expect { delete_service_instance_recursive }.to change { cc.service_instances['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_service_instance
        end

        def verify_service_instance_not_found(exception)
          expect(exception.cf_code).to eq(60_004)
          expect(exception.cf_error_code).to eq('CF-ServiceInstanceNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The service instance could not be found: #{cc_service_instance[:guid]}")
        end

        it 'fails deleting deleted service instance' do
          expect { delete_service_instance }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_instance_not_found(exception) }
        end

        it 'fails deleting recursive deleted service instance' do
          expect { delete_service_instance_recursive }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_instance_not_found(exception) }
        end
      end
    end

    context 'manage service key' do
      before do
        expect(cc.service_keys['items'].length).to eq(1)
      end

      def delete_service_key
        operation.delete_service_key(cc_service_key[:guid])
      end

      it 'deletes service key' do
        expect { delete_service_key }.to change { cc.service_keys['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_service_key
        end

        def verify_service_key_not_found(exception)
          expect(exception.cf_code).to eq(360_003)
          expect(exception.cf_error_code).to eq('CF-ServiceKeyNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The service key could not be found: #{cc_service_key[:guid]}")
        end

        it 'fails deleting deleted service key' do
          expect { delete_service_key }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_key_not_found(exception) }
        end
      end
    end

    context 'manage service plan' do
      before do
        expect(cc.service_plans['items'].length).to eq(1)
        expect(cc.service_plans['items'][0][:public].to_s).to eq('true')
      end

      def make_service_plan_public
        operation.manage_service_plan(cc_service_plan[:guid], '{"public":true}')
      end

      def make_service_plan_private
        operation.manage_service_plan(cc_service_plan[:guid], '{"public":false}')
      end

      def delete_service_plan
        operation.delete_service_plan(cc_service_plan[:guid])
      end

      it 'makes service plan public' do
        make_service_plan_private
        expect { make_service_plan_public }.to change { cc.service_plans['items'][0][:public].to_s }.from('false').to('true')
      end

      it 'makes service plan private' do
        expect { make_service_plan_private }.to change { cc.service_plans['items'][0][:public].to_s }.from('true').to('false')
      end

      it 'deletes service plan' do
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
          expect(exception.message).to eq("The service plan could not be found: #{cc_service_plan[:guid]}")
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
        expect(cc.service_plan_visibilities['items'].length).to eq(1)
      end

      def delete_service_plan_visibility
        operation.delete_service_plan_visibility(cc_service_plan_visibility[:guid])
      end

      it 'deletes service plan visibility' do
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
          expect(exception.message).to eq("The service plan visibility could not be found: #{cc_service_plan[:guid]}")
        end

        it 'fails deleting deleted service plan visibility' do
          expect { delete_service_plan_visibility }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_plan_visibility_not_found(exception) }
        end
      end
    end

    context 'manage space' do
      before do
        expect(cc.spaces['items'].length).to eq(1)
      end

      def delete_space
        operation.delete_space(cc_space[:guid], false)
      end

      def delete_space_recursive
        operation.delete_space(cc_space[:guid], true)
      end

      it 'deletes space' do
        expect { delete_space }.to change { cc.spaces['items'].length }.from(1).to(0)
      end

      it 'deletes space recursive' do
        expect { delete_space_recursive }.to change { cc.spaces['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_space
        end

        def verify_space_not_found(exception)
          expect(exception.cf_code).to eq(40_004)
          expect(exception.cf_error_code).to eq('CF-SpaceNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The app space could not be found: #{cc_space[:guid]}")
        end

        it 'fails deleting deleted space' do
          expect { delete_space }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_space_not_found(exception) }
        end

        it 'fails deleting recursive deleted space' do
          expect { delete_space_recursive }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_space_not_found(exception) }
        end
      end
    end

    context 'manage space quota definition' do
      before do
        expect(cc.space_quota_definitions['items'].length).to eq(1)
      end

      def delete_space_quota_definition
        operation.delete_space_quota_definition(cc_space_quota_definition[:guid])
      end

      it 'deletes space_quota definition' do
        expect { delete_space_quota_definition }.to change { cc.space_quota_definitions['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_space_quota_definition
        end

        def verify_space_quota_definition_not_found(exception)
          expect(exception.cf_code).to eq(310_007)
          expect(exception.cf_error_code).to eq('CF-SpaceQuotaDefinitionNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("Space Quota Definition could not be found: #{cc_space_quota_definition[:guid]}")
        end

        it 'fails deleting deleted space quota definition' do
          expect { delete_space_quota_definition }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_space_quota_definition_not_found(exception) }
        end
      end
    end

    context 'manage space quota definition space' do
      def delete_space_quota_definition
        operation.delete_space_quota_definition(cc_space_quota_definition[:guid])
      end

      def create_space_quota_definition_space
        operation.create_space_quota_definition_space(cc_space_quota_definition2[:guid], cc_space[:guid])
      end

      def delete_space_quota_definition_space
        operation.delete_space_quota_definition_space(cc_space_quota_definition[:guid], cc_space[:guid])
      end

      context 'sets the space quota definition for a space' do
        let(:insert_second_quota_definition) { true }
        it 'creates space quota definition space' do
          expect { create_space_quota_definition_space }.to change { cc.spaces['items'][0][:space_quota_definition_id] }.from(cc_space_quota_definition[:id]).to(cc_space_quota_definition2[:id])
        end
      end

      it 'deletes space quota definition space' do
        expect { delete_space_quota_definition_space }.to change { cc.spaces['items'][0][:space_quota_definition_id] }.from(cc_space_quota_definition[:id]).to(nil)
      end

      context 'errors' do
        before do
          delete_space_quota_definition
        end

        def verify_space_quota_definition_not_found(exception)
          expect(exception.cf_code).to eq(310_007)
          expect(exception.cf_error_code).to eq('CF-SpaceQuotaDefinitionNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("Space Quota Definition could not be found: #{cc_space_quota_definition[:guid]}")
        end

        context 'fails setting space quota for a deleted space quota definition' do
          let(:insert_second_quota_definition) { true }
          it 'fails creating space quota for a deleted space quota definition' do
            expect { create_space_quota_definition_space }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_space_quota_definition_not_found(exception) }
          end
        end

        it 'fails deleting space quota definition space for a deleted space quota definition' do
          expect { delete_space_quota_definition }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_space_quota_definition_not_found(exception) }
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

      it 'deletes space auditor role' do
        expect { delete_space_auditor }.to change { cc.spaces_auditors['items'].length }.from(1).to(0)
      end

      it 'deletes space developer role' do
        expect { delete_space_developer }.to change { cc.spaces_developers['items'].length }.from(1).to(0)
      end

      it 'deletes space manager role' do
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
          expect(exception.message).to eq("The app space could not be found: #{cc_space[:guid]}")
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
