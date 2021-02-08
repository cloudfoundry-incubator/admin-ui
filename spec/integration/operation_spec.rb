require 'logger'
require_relative '../spec_helper'

describe AdminUI::Operation, type: :integration do
  include CCHelper
  include ConfigHelper
  include DopplerHelper
  include NATSHelper
  include VARZHelper
  include ViewModelsHelper

  let(:application_instance_source)    { :doppler_dea }
  let(:ccdb_file)                      { '/tmp/admin_ui_ccdb.db' }
  let(:ccdb_uri)                       { "sqlite://#{ccdb_file}" }
  let(:data_file)                      { '/tmp/admin_ui_data.json' }
  let(:db_file)                        { '/tmp/admin_ui_store.db' }
  let(:db_uri)                         { "sqlite://#{db_file}" }
  let(:doppler_data_file)              { '/tmp/admin_ui_doppler_data.json' }
  let(:insert_second_quota_definition) { false }
  let(:log_file)                       { '/tmp/admin_ui.log' }
  let(:uaadb_file)                     { '/tmp/admin_ui_uaadb.db' }
  let(:uaadb_uri)                      { "sqlite://#{uaadb_file}" }
  let(:use_route)                      { true }

  let(:config) do
    AdminUI::Config.load(ccdb_uri:                ccdb_uri,
                         cloud_controller_uri:    'http://api.cloudfoundry',
                         data_file:               data_file,
                         db_uri:                  db_uri,
                         doppler_data_file:       doppler_data_file,
                         doppler_rollup_interval: 1,
                         mbus:                    'nats://nats:c1oudc0w@localhost:14222',
                         monitored_components:    [],
                         nats_discovery_timeout:  1,
                         uaadb_uri:               uaadb_uri,
                         uaa_client:              {
                                                    id:     'id',
                                                    secret: 'secret'
                                                  })
  end

  let(:cc)                 { AdminUI::CC.new(config, logger, true) }
  let(:client)             { AdminUI::CCRestClient.new(config, logger) }
  let(:doppler)            { AdminUI::Doppler.new(config, logger, client, email, true) }
  let(:email)              { AdminUI::EMail.new(config, logger) }
  let(:event_machine_loop) { AdminUI::EventMachineLoop.new(config, logger, true) }
  let(:logger)             { Logger.new(log_file) }
  let(:log_files)          { AdminUI::LogFiles.new(config, logger) }
  let(:nats)               { AdminUI::NATS.new(config, logger, email, true) }
  let(:operation)          { AdminUI::Operation.new(config, logger, cc, client, doppler, varz, view_models, true) }
  let(:router_source)      { :varz_router }
  let(:stats)              { AdminUI::Stats.new(config, logger, cc, doppler, varz, true) }
  let(:varz)               { AdminUI::VARZ.new(config, logger, nats, true) }
  let(:view_models)        { AdminUI::ViewModels.new(config, logger, cc, client, doppler, log_files, stats, varz, true) }

  def cleanup_files
    Process.wait(Process.spawn({}, "rm -fr #{ccdb_file} #{data_file} #{db_file} #{doppler_data_file} #{log_file} #{uaadb_file}"))
  end

  before do
    cleanup_files

    config_stub
    cc_stub(config, true, insert_second_quota_definition, 'space', use_route)
    doppler_stub(cc_info['doppler_logging_endpoint'], application_instance_source, router_source)
    nats_stub(router_source)
    varz_stub
    view_models_stub(application_instance_source, router_source)

    event_machine_loop
  end

  after do
    view_models.shutdown
    stats.shutdown
    varz.shutdown
    nats.shutdown
    doppler.shutdown
    cc.shutdown
    event_machine_loop.shutdown

    view_models.join
    stats.join
    varz.join
    nats.join
    doppler.join
    cc.join
    event_machine_loop.join

    cleanup_files
  end

  context 'Stubbed HTTP' do
    context 'manage application' do
      before do
        expect(cc.applications['items'].length).to eq(1)
      end

      def rename_application
        operation.manage_application(cc_app[:guid], "{\"name\":\"#{cc_app_rename}\"}")
      end

      def delete_application
        operation.delete_application(cc_app[:guid], false)
      end

      def delete_application_recursive
        operation.delete_application(cc_app[:guid], true)
      end

      def delete_application_annotation
        operation.delete_application_annotation(cc_app[:guid], cc_app_annotation[:key_prefix], cc_app_annotation[:key])
      end

      def delete_application_environment_variable
        operation.delete_application_environment_variable(cc_app[:guid], cc_app_environment_variable_name)
      end

      def delete_application_label
        operation.delete_application_label(cc_app[:guid], cc_app_label[:key_prefix], cc_app_label[:key_name])
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

      def enable_diego_application
        operation.manage_application(cc_app[:guid], '{"diego":true}')
      end

      def disable_diego_application
        operation.manage_application(cc_app[:guid], '{"diego":false}')
      end

      def enable_ssh_application
        operation.manage_application(cc_app[:guid], '{"enable_ssh":true}')
      end

      def disable_ssh_application
        operation.manage_application(cc_app[:guid], '{"enable_ssh":false}')
      end

      def enable_revisions_application
        operation.manage_application(cc_app[:guid], '{"revisions_enabled":true}')
      end

      def disable_revisions_application
        operation.manage_application(cc_app[:guid], '{"revisions_enabled":false}')
      end

      it 'renames the application' do
        expect { rename_application }.to change { cc.applications['items'][0][:name] }.from(cc_app[:name]).to(cc_app_rename)
      end

      it 'stops the running application' do
        start_application
        expect { stop_application }.to change { cc.processes['items'][0][:state] }.from('STARTED').to('STOPPED')
      end

      it 'starts the stopped application' do
        stop_application
        expect { start_application }.to change { cc.processes['items'][0][:state] }.from('STOPPED').to('STARTED')
      end

      it 'restages the application' do
        restage_application
      end

      it 'enables application diego' do
        disable_diego_application
        expect { enable_diego_application }.to change { cc.processes['items'][0][:diego] }.from(false).to(true)
      end

      it 'disables application diego' do
        enable_diego_application
        expect { disable_diego_application }.to change { cc.processes['items'][0][:diego] }.from(true).to(false)
      end

      it 'enables application ssh' do
        disable_ssh_application
        expect { enable_ssh_application }.to change { cc.applications['items'][0][:enable_ssh] }.from(false).to(true)
      end

      it 'disables application ssh' do
        enable_ssh_application
        expect { disable_ssh_application }.to change { cc.applications['items'][0][:enable_ssh] }.from(true).to(false)
      end

      it 'enables application revisions' do
        disable_revisions_application
        expect { enable_revisions_application }.to change { cc.applications['items'][0][:revisions_enabled] }.from(false).to(true)
      end

      it 'disables application revisions' do
        enable_revisions_application
        expect { disable_revisions_application }.to change { cc.applications['items'][0][:revisions_enabled] }.from(true).to(false)
      end

      it 'deletes the application' do
        expect { delete_application }.to change { cc.applications['items'].length }.from(1).to(0)
      end

      it 'deletes the application recursive' do
        expect { delete_application_recursive }.to change { cc.applications['items'].length }.from(1).to(0)
      end

      it 'deletes the application annotation' do
        expect { delete_application_annotation }.to change { cc.application_annotations['items'].length }.from(1).to(0)
      end

      it 'deletes the application environment variable' do
        expect { delete_application_environment_variable }.to change { cc_app_environment_variable.keys.length }.from(1).to(0)
      end

      it 'deletes the application label' do
        expect { delete_application_label }.to change { cc.application_labels['items'].length }.from(1).to(0)
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

        it 'fails renaming deleted app' do
          expect { rename_application }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_app_not_found(exception) }
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

        it 'fails enabling diego on deleted app' do
          expect { enable_diego_application }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_app_not_found(exception) }
        end

        it 'fails disabling diego on deleted app' do
          expect { disable_diego_application }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_app_not_found(exception) }
        end

        it 'fails enabling ssh on deleted app' do
          expect { enable_ssh_application }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_app_not_found(exception) }
        end

        it 'fails disabling ssh on deleted app' do
          expect { disable_ssh_application }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_app_not_found(exception) }
        end

        it 'fails enabling revisions on deleted app' do
          expect { enable_revisions_application }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_app_not_found(exception) }
        end

        it 'fails disabling revisions on deleted app' do
          expect { disable_revisions_application }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_app_not_found(exception) }
        end

        it 'fails deleting deleted app' do
          expect { delete_application }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_app_not_found(exception) }
        end

        it 'fails deleting recursive deleted app' do
          expect { delete_application_recursive }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_app_not_found(exception) }
        end

        it 'fails deleting annotation on deleted app' do
          expect { delete_application_annotation }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_app_not_found(exception) }
        end

        it 'fails deleting environment variable on deleted app' do
          expect { delete_application_environment_variable }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_app_not_found(exception) }
        end

        it 'fails deleting label on deleted app' do
          expect { delete_application_label }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_app_not_found(exception) }
        end
      end
    end

    context 'manage application instance' do
      before do
        expect(doppler.containers['items'].length).to eq(1)
      end

      def delete_application_instance
        operation.delete_application_instance(cc_app[:guid], cc_app_instance_index)
      end

      it 'deletes the application instance' do
        expect { delete_application_instance }.to change { doppler.containers['items'].length }.from(1).to(0)
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

    context 'manage buildpack' do
      before do
        expect(cc.buildpacks['items'].length).to eq(1)
      end

      def rename_buildpack
        operation.manage_buildpack(cc_buildpack[:guid], "{\"name\":\"#{cc_buildpack_rename}\"}")
      end

      def delete_buildpack
        operation.delete_buildpack(cc_buildpack[:guid])
      end

      def delete_buildpack_annotation
        operation.delete_buildpack_annotation(cc_buildpack[:guid], cc_buildpack_annotation[:key_prefix], cc_buildpack_annotation[:key])
      end

      def delete_buildpack_label
        operation.delete_buildpack_label(cc_buildpack[:guid], cc_buildpack_label[:key_prefix], cc_buildpack_label[:key_name])
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

      it 'renames the buildpack' do
        expect { rename_buildpack }.to change { cc.buildpacks['items'][0][:name] }.from(cc_buildpack[:name]).to(cc_buildpack_rename)
      end

      it 'disables the buildpack' do
        enable_buildpack
        expect { disable_buildpack }.to change { cc.buildpacks['items'][0][:enabled] }.from(true).to(false)
      end

      it 'enables the buildpack' do
        disable_buildpack
        expect { enable_buildpack }.to change { cc.buildpacks['items'][0][:enabled] }.from(false).to(true)
      end

      it 'locks the buildpack' do
        unlock_buildpack
        expect { lock_buildpack }.to change { cc.buildpacks['items'][0][:locked] }.from(false).to(true)
      end

      it 'unlocks the buildpack' do
        lock_buildpack
        expect { unlock_buildpack }.to change { cc.buildpacks['items'][0][:locked] }.from(true).to(false)
      end

      it 'deletes the buildpack' do
        expect { delete_buildpack }.to change { cc.buildpacks['items'].length }.from(1).to(0)
      end

      it 'deletes the buildpack annotation' do
        expect { delete_buildpack_annotation }.to change { cc.buildpack_annotations['items'].length }.from(1).to(0)
      end

      it 'deletes the buildpack label' do
        expect { delete_buildpack_label }.to change { cc.buildpack_labels['items'].length }.from(1).to(0)
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

        it 'fails renaming deleted buildpack' do
          expect { rename_buildpack }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_buildpack_not_found(exception) }
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

        it 'fails deleting annotation on deleted buildpack' do
          expect { delete_buildpack_annotation }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_buildpack_not_found(exception) }
        end

        it 'fails deleting label on deleted buildpack' do
          expect { delete_buildpack_label }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_buildpack_not_found(exception) }
        end
      end
    end

    context 'manage client' do
      before do
        expect(cc.clients['items'].length).to eq(1)
      end

      def revoke_tokens
        operation.delete_client_tokens(uaa_client[:client_id])
      end

      def delete_client
        operation.delete_client(uaa_client[:client_id])
      end

      it 'revokes client tokens' do
        revoke_tokens
        expect(cc.revocable_tokens['items'].length).to eq(0)
      end

      it 'deletes client' do
        expect { delete_client }.to change { cc.clients['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_client
        end

        def verify_client_not_found(exception)
          expect(exception.cf_code).to eq(nil)
          expect(exception.cf_error_code).to eq(nil)
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq('Not Found')
        end

        it 'fails revoking tokens for deleted client' do
          expect { revoke_tokens }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_client_not_found(exception) }
        end

        it 'fails deleting deleted client' do
          expect { delete_client }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_client_not_found(exception) }
        end
      end
    end

    context 'manage domain' do
      before do
        expect(cc.domains['items'].length).to eq(1)
      end

      def delete_domain
        operation.delete_domain(cc_domain[:guid], false, false)
      end

      def delete_domain_recursive
        operation.delete_domain(cc_domain[:guid], false, true)
      end

      def delete_domain_annotation
        operation.delete_domain_annotation(cc_domain[:guid], cc_domain_annotation[:key_prefix], cc_domain_annotation[:key])
      end

      def delete_domain_label
        operation.delete_domain_label(cc_domain[:guid], cc_domain_label[:key_prefix], cc_domain_label[:key_name])
      end

      it 'deletes domain' do
        expect { delete_domain }.to change { cc.domains['items'].length }.from(1).to(0)
      end

      it 'deletes domain recursive' do
        expect { delete_domain_recursive }.to change { cc.domains['items'].length }.from(1).to(0)
      end

      it 'deletes the domain annotation' do
        expect { delete_domain_annotation }.to change { cc.domain_annotations['items'].length }.from(1).to(0)
      end

      it 'deletes the domain label' do
        expect { delete_domain_label }.to change { cc.domain_labels['items'].length }.from(1).to(0)
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

        it 'fails deleting annotation on deleted domain' do
          expect { delete_domain_annotation }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_domain_not_found(exception) }
        end

        it 'fails deleting label on deleted domain' do
          expect { delete_domain_label }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_domain_not_found(exception) }
        end
      end
    end

    context 'manage feature_flag' do
      before do
        expect(cc.feature_flags['items'].length).to eq(1)
      end

      def disable_feature_flag
        operation.manage_feature_flag(cc_feature_flag[:name], '{"enabled":false}')
      end

      def enable_feature_flag
        operation.manage_feature_flag(cc_feature_flag[:name], '{"enabled":true}')
      end

      it 'disables the feature_flag' do
        enable_feature_flag
        expect { disable_feature_flag }.to change { cc.feature_flags['items'][0][:enabled] }.from(true).to(false)
      end

      it 'enables the feature_flag ' do
        disable_feature_flag
        expect { enable_feature_flag }.to change { cc.feature_flags['items'][0][:enabled] }.from(false).to(true)
      end

      context 'errors' do
        before do
          cc_clear_feature_flags_cache_stub(config)
        end

        def verify_feature_flag_not_found(exception)
          expect(exception.cf_code).to eq(330_000)
          expect(exception.cf_error_code).to eq('CF-FeatureFlagNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The feature flag could not be found: #{cc_feature_flag[:name]}")
        end

        it 'fails disabling deleted feature_flag' do
          expect { disable_feature_flag }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_feature_flag_not_found(exception) }
        end

        it 'fails enabling deleted feature_flag' do
          expect { enable_feature_flag }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_feature_flag_not_found(exception) }
        end
      end
    end

    context 'manage group' do
      before do
        expect(cc.groups['items'].length).to eq(1)
      end

      def delete_group
        operation.delete_group(uaa_group[:id])
      end

      it 'deletes group' do
        expect { delete_group }.to change { cc.groups['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_group
        end

        def verify_group_not_found(exception)
          expect(exception.cf_code).to eq(nil)
          expect(exception.cf_error_code).to eq(nil)
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("Group #{uaa_group[:id]} does not exist")
        end

        it 'fails deleting deleted group' do
          expect { delete_group }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_group_not_found(exception) }
        end
      end
    end

    context 'manage group member' do
      before do
        expect(cc.group_membership['items'].length).to eq(1)
      end

      def delete_group_member
        operation.delete_group_member(uaa_group[:id], uaa_user[:id])
      end

      it 'deletes group member' do
        expect { delete_group_member }.to change { cc.group_membership['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_group_member
        end

        def verify_group_member_not_found(exception)
          expect(exception.cf_code).to eq(nil)
          expect(exception.cf_error_code).to eq(nil)
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("Member #{uaa_user[:id]} does not exist in group #{uaa_group[:id]}")
        end

        it 'fails deleting deleted group member' do
          expect { delete_group_member }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_group_member_not_found(exception) }
        end
      end
    end

    context 'manage identity provider' do
      before do
        expect(cc.identity_providers['items'].length).to eq(1)
      end

      def require_password_change_identity_provider
        operation.manage_identity_provider_status(uaa_identity_provider[:id], '{"requirePasswordChange":true}')
      end

      def delete_identity_provider
        operation.delete_identity_provider(uaa_identity_provider[:id])
      end

      it 'require password change identity provider' do
        require_password_change_identity_provider
      end

      it 'deletes identity provider' do
        expect { delete_identity_provider }.to change { cc.identity_providers['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_identity_provider
        end

        def verify_identity_provider_not_found(exception)
          expect(exception.cf_code).to eq(nil)
          expect(exception.cf_error_code).to eq(nil)
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq('Provider not found')
        end

        it 'fails requiring password change for deleted identity provider' do
          expect { require_password_change_identity_provider }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_identity_provider_not_found(exception) }
        end

        it 'fails deleting deleted identity provider' do
          expect { delete_identity_provider }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_identity_provider_not_found(exception) }
        end
      end
    end

    context 'manage identity zone' do
      before do
        expect(cc.identity_zones['items'].length).to eq(1)
      end

      def delete_identity_zone
        operation.delete_identity_zone(uaa_identity_zone[:id])
      end

      it 'deletes identity zone' do
        expect { delete_identity_zone }.to change { cc.identity_zones['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_identity_zone
        end

        def verify_identity_zone_not_found(exception)
          expect(exception.cf_code).to eq(nil)
          expect(exception.cf_error_code).to eq(nil)
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq('Not Found')
        end

        it 'fails deleting deleted identity zone' do
          expect { delete_identity_zone }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_identity_zone_not_found(exception) }
        end
      end
    end

    context 'manage isolation segment' do
      before do
        expect(cc.isolation_segments['items'].length).to eq(1)
      end

      def create_isolation_segment
        operation.create_isolation_segment("{\"name\":\"#{cc_isolation_segment2[:name]}\"}")
      end

      def rename_isolation_segment
        operation.manage_isolation_segment(cc_isolation_segment[:guid], "{\"name\":\"#{cc_isolation_segment_rename}\"}")
      end

      def delete_isolation_segment
        operation.delete_isolation_segment(cc_isolation_segment[:guid])
      end

      def delete_isolation_segment_annotation
        operation.delete_isolation_segment_annotation(cc_isolation_segment[:guid], cc_isolation_segment_annotation[:key_prefix], cc_isolation_segment_annotation[:key])
      end

      def delete_isolation_segment_label
        operation.delete_isolation_segment_label(cc_isolation_segment[:guid], cc_isolation_segment_label[:key_prefix], cc_isolation_segment_label[:key_name])
      end

      it 'creates a new isolation segment' do
        expect { create_isolation_segment }.to change { cc.isolation_segments['items'].length }.from(1).to(2)
        expect(cc.isolation_segments['items'][1][:name]).to eq(cc_isolation_segment2[:name])
      end

      it 'renames the isolation segment' do
        expect { rename_isolation_segment }.to change { cc.isolation_segments['items'][0][:name] }.from(cc_isolation_segment[:name]).to(cc_isolation_segment_rename)
      end

      it 'deletes isolation segment' do
        expect { delete_isolation_segment }.to change { cc.isolation_segments['items'].length }.from(1).to(0)
      end

      it 'deletes the isolation segment annotation' do
        expect { delete_isolation_segment_annotation }.to change { cc.isolation_segment_annotations['items'].length }.from(1).to(0)
      end

      it 'deletes the isolation segment label' do
        expect { delete_isolation_segment_label }.to change { cc.isolation_segment_labels['items'].length }.from(1).to(0)
      end

      context 'errors' do
        context 'not found error' do
          before do
            delete_isolation_segment
          end

          def verify_isolation_segment_not_found(exception)
            expect(exception.cf_code).to eq(10_010)
            expect(exception.cf_error_code).to eq('CF-ResourceNotFound')
            expect(exception.http_code).to eq(404)
            expect(exception.message).to eq('Isolation segment not found')
          end

          it 'fails renaming deleted isolation segment' do
            expect { rename_isolation_segment }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_isolation_segment_not_found(exception) }
          end

          it 'fails deleting deleted isolation segment' do
            expect { delete_isolation_segment }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_isolation_segment_not_found(exception) }
          end

          it 'fails deleting annotation on deleted isolation segment' do
            expect { delete_isolation_segment_annotation }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_isolation_segment_not_found(exception) }
          end

          it 'fails deleting label on deleted isolation segment' do
            expect { delete_isolation_segment_label }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_isolation_segment_not_found(exception) }
          end
        end

        context 'bad request' do
          before do
            create_isolation_segment
          end

          def verify_isolation_segment_name_taken(exception)
            expect(exception.cf_code).to eq(10_008)
            expect(exception.cf_error_code).to eq('CF-UnprocessableEntity')
            expect(exception.http_code).to eq(400)
            expect(exception.message).to eq('The request is semantically invalid: Isolation Segment names are case insensitive and must be unique')
          end

          it 'failed creating created isolation segment' do
            expect { create_isolation_segment }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_isolation_segment_name_taken(exception) }
          end
        end
      end
    end

    context 'manage mfa provider' do
      before do
        expect(cc.mfa_providers['items'].length).to eq(1)
      end

      def delete_mfa_provider
        operation.delete_mfa_provider(uaa_mfa_provider[:id])
      end

      it 'deletes MFA provider' do
        expect { delete_mfa_provider }.to change { cc.mfa_providers['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_mfa_provider
        end

        def verify_mfa_provider_not_found(exception)
          expect(exception.cf_code).to eq(nil)
          expect(exception.cf_error_code).to eq(nil)
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq('Not Found')
        end

        it 'fails deleting deleted MFA provider' do
          expect { delete_mfa_provider }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_mfa_provider_not_found(exception) }
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
        operation.manage_organization(cc_organization[:guid], "{\"name\":\"#{cc_organization_rename}\"}")
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

      def remove_organization_default_isolation_segment
        operation.remove_organization_default_isolation_segment(cc_organization[:guid])
      end

      def delete_organization
        operation.delete_organization(cc_organization[:guid], false)
      end

      def delete_organization_recursive
        operation.delete_organization(cc_organization[:guid], true)
      end

      def delete_organization_annotation
        operation.delete_organization_annotation(cc_organization[:guid], cc_organization_annotation[:key_prefix], cc_organization_annotation[:key])
      end

      def delete_organization_label
        operation.delete_organization_label(cc_organization[:guid], cc_organization_label[:key_prefix], cc_organization_label[:key_name])
      end

      it 'creates a new organization' do
        expect { create_organization }.to change { cc.organizations['items'].length }.from(1).to(2)
        expect(cc.organizations['items'][1][:name]).to eq(cc_organization2[:name])
      end

      it 'renames the organization' do
        expect { rename_organization }.to change { cc.organizations['items'][0][:name] }.from(cc_organization[:name]).to(cc_organization_rename)
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
        activate_organization
        expect { suspend_organization }.to change { cc.organizations['items'][0][:status] }.from('active').to('suspended')
      end

      it 'removes the organization default isolation segment' do
        expect { remove_organization_default_isolation_segment }.to change { cc.organizations['items'][0][:default_isolation_segment_guid] }.from(cc_isolation_segment[:guid]).to(nil)
      end

      it 'deletes organization' do
        expect { delete_organization }.to change { cc.organizations['items'].length }.from(1).to(0)
      end

      it 'deletes organization recursive' do
        expect { delete_organization_recursive }.to change { cc.organizations['items'].length }.from(1).to(0)
      end

      it 'deletes the organization annotation' do
        expect { delete_organization_annotation }.to change { cc.organization_annotations['items'].length }.from(1).to(0)
      end

      it 'deletes organization label' do
        expect { delete_organization_label }.to change { cc.organization_labels['items'].length }.from(1).to(0)
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

          it 'fails removing default isolation segment on deleted organization' do
            expect { remove_organization_default_isolation_segment }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_organization_not_found(exception) }
          end

          it 'fails deleting deleted organization' do
            expect { delete_organization }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_organization_not_found(exception) }
          end

          it 'fails deleting recursive deleted organization' do
            expect { delete_organization_recursive }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_organization_not_found(exception) }
          end

          it 'fails deleting annotation on deleted organization' do
            expect { delete_organization_annotation }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_organization_not_found(exception) }
          end

          it 'fails deleting label on deleted organization' do
            expect { delete_organization_label }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_organization_not_found(exception) }
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

    context 'manage organization isolation segment' do
      def delete_organization_isolation_segment
        operation.delete_organization_isolation_segment(cc_organization[:guid], cc_isolation_segment[:guid])
      end

      it 'deletes organization isolation segment' do
        expect { delete_organization_isolation_segment }.to change { cc.organizations_isolation_segments['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          cc_clear_isolation_segments_cache_stub(config)
        end

        def verify_isolation_segment_not_found(exception)
          expect(exception.cf_code).to eq(10_010)
          expect(exception.cf_error_code).to eq('CF-ResourceNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq('Isolation segment not found')
        end

        it 'failed deleting organization isolation segment due to deleted isolation segment' do
          expect { delete_organization_isolation_segment }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_isolation_segment_not_found(exception) }
        end
      end
    end

    context 'manage organization private domain' do
      def delete_organization_private_domain
        operation.delete_organization_private_domain(cc_organization[:guid], cc_domain[:guid])
      end

      it 'deletes organization program domain' do
        expect { delete_organization_private_domain }.to change { cc.organizations_private_domains['items'].length }.from(1).to(0)
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

        it 'failed deleting organization private domain due to deleted organization' do
          expect { delete_organization_private_domain }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_organization_not_found(exception) }
        end
      end
    end

    context 'manage organization roles' do
      def delete_organization_auditor
        operation.delete_organization_role(cc_organization[:guid], cc_organization_auditor[:role_guid], 'auditors', cc_user[:guid])
      end

      def delete_organization_billing_manager
        operation.delete_organization_role(cc_organization[:guid], cc_organization_billing_manager[:role_guid], 'billing_managers', cc_user[:guid])
      end

      def delete_organization_manager
        operation.delete_organization_role(cc_organization[:guid], cc_organization_manager[:role_guid], 'managers', cc_user[:guid])
      end

      def delete_organization_user
        operation.delete_organization_role(cc_organization[:guid], cc_organization_user[:role_guid], 'users', cc_user[:guid])
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

      def rename_quota_definition
        operation.manage_quota_definition(cc_quota_definition[:guid], "{\"name\":\"#{cc_quota_definition_rename}\"}")
      end

      def delete_quota_definition
        operation.delete_quota_definition(cc_quota_definition[:guid])
      end

      it 'renames the quota definition' do
        expect { rename_quota_definition }.to change { cc.quota_definitions['items'][0][:name] }.from(cc_quota_definition[:name]).to(cc_quota_definition_rename)
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

        it 'fails renaming deleted quota definition' do
          expect { rename_quota_definition }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_quota_definition_not_found(exception) }
        end

        it 'fails deleting deleted quota definition' do
          expect { delete_quota_definition }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_quota_definition_not_found(exception) }
        end
      end
    end

    context 'manage revocable token' do
      before do
        expect(cc.revocable_tokens['items'].length).to eq(1)
      end

      def delete_revocable_token
        operation.delete_revocable_token(uaa_revocable_token[:token_id])
      end

      it 'deletes revocable token' do
        delete_revocable_token
        expect(cc.revocable_tokens['items'].length).to eq(0)
      end

      context 'errors' do
        before do
          delete_revocable_token
        end

        def verify_revocable_token_not_found(exception)
          expect(exception.cf_code).to eq(nil)
          expect(exception.cf_error_code).to eq(nil)
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq('Not Found')
        end

        it 'fails deleting deleted revocable token' do
          expect { delete_revocable_token }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_revocable_token_not_found(exception) }
        end
      end
    end

    context 'manage route' do
      before do
        expect(cc.routes['items'].length).to eq(1)
      end

      def delete_route
        operation.delete_route(cc_route[:guid], false)
      end

      def delete_route_recursive
        operation.delete_route(cc_route[:guid], true)
      end

      def delete_route_annotation
        operation.delete_route_annotation(cc_route[:guid], cc_route_annotation[:key_prefix], cc_route_annotation[:key])
      end

      def delete_route_label
        operation.delete_route_label(cc_route[:guid], cc_route_label[:key_prefix], cc_route_label[:key_name])
      end

      it 'deletes route' do
        expect { delete_route }.to change { cc.routes['items'].length }.from(1).to(0)
      end

      it 'deletes route recursive' do
        expect { delete_route_recursive }.to change { cc.routes['items'].length }.from(1).to(0)
      end

      it 'deletes the route annotation' do
        expect { delete_route_annotation }.to change { cc.route_annotations['items'].length }.from(1).to(0)
      end

      it 'deletes the route label' do
        expect { delete_route_label }.to change { cc.route_labels['items'].length }.from(1).to(0)
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

        it 'fails deleting recursive deleted route' do
          expect { delete_route_recursive }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_route_not_found(exception) }
        end

        it 'fails deleting annotation on deleted route' do
          expect { delete_route_annotation }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_route_not_found(exception) }
        end

        it 'fails deleting label on deleted route' do
          expect { delete_route_label }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_route_not_found(exception) }
        end
      end
    end

    context 'manage route binding' do
      before do
        expect(cc.route_bindings['items'].length).to eq(1)
      end

      def delete_route_binding
        operation.delete_route_binding(cc_service_instance[:guid], cc_route[:guid], cc_service_instance[:is_gateway_service])
      end

      def delete_route_binding_annotation
        operation.delete_route_binding_annotation(cc_route_binding[:guid], cc_route_binding_annotation[:key_prefix], cc_route_binding_annotation[:key])
      end

      def delete_route_binding_label
        operation.delete_route_binding_label(cc_route_binding[:guid], cc_route_binding_label[:key_prefix], cc_route_binding_label[:key_name])
      end

      it 'deletes route binding' do
        expect { delete_route_binding }.to change { cc.route_bindings['items'].length }.from(1).to(0)
      end

      it 'deletes the route binding annotation' do
        expect { delete_route_binding_annotation }.to change { cc.route_binding_annotations['items'].length }.from(1).to(0)
      end

      it 'deletes the route binding label' do
        expect { delete_route_binding_label }.to change { cc.route_binding_labels['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_route_binding
        end

        def verify_route_binding_not_found(exception)
          expect(exception.cf_code).to eq(1_002)
          expect(exception.cf_error_code).to eq('CF-InvalidRelation')
          expect(exception.http_code).to eq(400)
          expect(exception.message).to eq("Invalid relation: Route #{cc_route[:guid]} is not bound to service instance #{cc_service_instance[:guid]}.")
        end

        it 'fails deleting deleted route binding' do
          expect { delete_route_binding }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_route_binding_not_found(exception) }
        end

        it 'fails deleting annotation on deleted route binding' do
          expect { delete_route_binding_annotation }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_route_binding_not_found(exception) }
        end

        it 'fails deleting label on deleted route binding' do
          expect { delete_route_binding_label }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_route_binding_not_found(exception) }
        end
      end
    end

    context 'manage route mapping' do
      before do
        expect(cc.route_mappings['items'].length).to eq(1)
      end

      def delete_route_mapping
        operation.delete_route_mapping(cc_route_mapping[:guid], cc_route[:guid])
      end

      it 'deletes route mapping' do
        expect { delete_route_mapping }.to change { cc.route_mappings['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_route_mapping
        end

        def verify_route_mapping_not_found(exception)
          expect(exception.cf_code).to eq(210_007)
          expect(exception.cf_error_code).to eq('CF-RouteMappingNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The route mapping could not be found: #{cc_route_mapping[:guid]}")
        end

        it 'fails deleting deleted route mapping' do
          expect { delete_route_mapping }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_route_mapping_not_found(exception) }
        end
      end
    end

    context 'manage security group' do
      before do
        expect(cc.security_groups['items'].length).to eq(1)
      end

      def rename_security_group
        operation.manage_security_group(cc_security_group[:guid], "{\"name\":\"#{cc_security_group_rename}\"}")
      end

      def disable_security_group_running_default
        operation.manage_security_group(cc_security_group[:guid], '{"running_default":false}')
      end

      def enable_security_group_running_default
        operation.manage_security_group(cc_security_group[:guid], '{"running_default":true}')
      end

      def disable_security_group_staging_default
        operation.manage_security_group(cc_security_group[:guid], '{"staging_default":false}')
      end

      def enable_security_group_staging_default
        operation.manage_security_group(cc_security_group[:guid], '{"staging_default":true}')
      end

      def delete_security_group
        operation.delete_security_group(cc_security_group[:guid])
      end

      it 'renames the security_group' do
        expect { rename_security_group }.to change { cc.security_groups['items'][0][:name] }.from(cc_security_group[:name]).to(cc_security_group_rename)
      end

      it 'disables the security_group running default' do
        enable_security_group_running_default
        expect { disable_security_group_running_default }.to change { cc.security_groups['items'][0][:running_default] }.from(true).to(false)
      end

      it 'enables the security_group running default' do
        disable_security_group_running_default
        expect { enable_security_group_running_default }.to change { cc.security_groups['items'][0][:running_default] }.from(false).to(true)
      end

      it 'disables the security_group staging default' do
        enable_security_group_staging_default
        expect { disable_security_group_staging_default }.to change { cc.security_groups['items'][0][:staging_default] }.from(true).to(false)
      end

      it 'enables the security_group staging default' do
        disable_security_group_staging_default
        expect { enable_security_group_staging_default }.to change { cc.security_groups['items'][0][:staging_default] }.from(false).to(true)
      end

      it 'deletes security group' do
        expect { delete_security_group }.to change { cc.security_groups['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_security_group
        end

        def verify_security_group_not_found(exception)
          expect(exception.cf_code).to eq(300_002)
          expect(exception.cf_error_code).to eq('CF-SecurityGroupNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The security group could not be found: #{cc_security_group[:guid]}")
        end

        it 'fails renaming deleted security_group' do
          expect { rename_security_group }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_security_group_not_found(exception) }
        end

        it 'fails disabling running default on deleted security_group' do
          expect { disable_security_group_running_default }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_security_group_not_found(exception) }
        end

        it 'fails enabling running default on deleted security_group' do
          expect { enable_security_group_running_default }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_security_group_not_found(exception) }
        end

        it 'fails disabling staging default on deleted security_group' do
          expect { disable_security_group_staging_default }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_security_group_not_found(exception) }
        end

        it 'fails disabling staging default on deleted security_group' do
          expect { disable_security_group_staging_default }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_security_group_not_found(exception) }
        end

        it 'fails deleting deleted security group' do
          expect { delete_security_group }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_security_group_not_found(exception) }
        end
      end
    end

    context 'manage security group space' do
      before do
        expect(cc.security_groups_spaces['items'].length).to eq(1)
      end

      def delete_security_group_space
        operation.delete_security_group_space(cc_security_group[:guid], cc_space[:guid])
      end

      it 'deletes security group space' do
        expect { delete_security_group_space }.to change { cc.security_groups_spaces['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          cc_clear_security_groups_cache_stub(config)
        end

        def verify_security_group_not_found(exception)
          expect(exception.cf_code).to eq(300_002)
          expect(exception.cf_error_code).to eq('CF-SecurityGroupNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The security group could not be found: #{cc_security_group[:guid]}")
        end

        it 'failed deleting security group space due to deleted security group' do
          expect { delete_security_group_space }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_security_group_not_found(exception) }
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

      def delete_service_offering_annotation
        operation.delete_service_offering_annotation(cc_service[:guid], cc_service_offering_annotation[:key_prefix], cc_service_offering_annotation[:key])
      end

      def delete_service_offering_label
        operation.delete_service_offering_label(cc_service[:guid], cc_service_offering_label[:key_prefix], cc_service_offering_label[:key_name])
      end

      it 'deletes service' do
        expect { delete_service }.to change { cc.services['items'].length }.from(1).to(0)
      end

      it 'purges service' do
        expect { purge_service }.to change { cc.services['items'].length }.from(1).to(0)
      end

      it 'deletes the service offering annotation' do
        expect { delete_service_offering_annotation }.to change { cc.service_offering_annotations['items'].length }.from(1).to(0)
      end

      it 'deletes the service offering label' do
        expect { delete_service_offering_label }.to change { cc.service_offering_labels['items'].length }.from(1).to(0)
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

        it 'fails deleting annotation on deleted service' do
          expect { delete_service_offering_annotation }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_not_found(exception) }
        end

        it 'fails deleting label on deleted service' do
          expect { delete_service_offering_label }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_not_found(exception) }
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

      def delete_service_binding_annotation
        operation.delete_service_binding_annotation(cc_service_binding[:guid], cc_service_binding_annotation[:key_prefix], cc_service_binding_annotation[:key])
      end

      def delete_service_binding_label
        operation.delete_service_binding_label(cc_service_binding[:guid], cc_service_binding_label[:key_prefix], cc_service_binding_label[:key_name])
      end

      it 'deletes service binding' do
        expect { delete_service_binding }.to change { cc.service_bindings['items'].length }.from(1).to(0)
      end

      it 'deletes the service binding annotation' do
        expect { delete_service_binding_annotation }.to change { cc.service_binding_annotations['items'].length }.from(1).to(0)
      end

      it 'deletes the service binding label' do
        expect { delete_service_binding_label }.to change { cc.service_binding_labels['items'].length }.from(1).to(0)
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

        it 'fails deleting annotation on deleted service binding' do
          expect { delete_service_binding_annotation }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_binding_not_found(exception) }
        end

        it 'fails deleting label on deleted service binding' do
          expect { delete_service_binding_label }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_binding_not_found(exception) }
        end
      end
    end

    context 'manage service broker' do
      before do
        expect(cc.service_brokers['items'].length).to eq(1)
      end

      def rename_service_broker
        operation.manage_service_broker(cc_service_broker[:guid], "{\"name\":\"#{cc_service_broker_rename}\"}")
      end

      def delete_service_broker
        operation.delete_service_broker(cc_service_broker[:guid])
      end

      def delete_service_broker_annotation
        operation.delete_service_broker_annotation(cc_service_broker[:guid], cc_service_broker_annotation[:key_prefix], cc_service_broker_annotation[:key])
      end

      def delete_service_broker_label
        operation.delete_service_broker_label(cc_service_broker[:guid], cc_service_broker_label[:key_prefix], cc_service_broker_label[:key_name])
      end

      it 'renames the service broker' do
        expect { rename_service_broker }.to change { cc.service_brokers['items'][0][:name] }.from(cc_service_broker[:name]).to(cc_service_broker_rename)
      end

      it 'deletes service broker' do
        expect { delete_service_broker }.to change { cc.service_brokers['items'].length }.from(1).to(0)
      end

      it 'deletes the service broker annotation' do
        expect { delete_service_broker_annotation }.to change { cc.service_broker_annotations['items'].length }.from(1).to(0)
      end

      it 'deletes the service broker label' do
        expect { delete_service_broker_label }.to change { cc.service_broker_labels['items'].length }.from(1).to(0)
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

        it 'fails renaming deleted service broker' do
          expect { rename_service_broker }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_broker_not_found(exception) }
        end

        it 'fails deleting deleted service broker' do
          expect { delete_service_broker }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_broker_not_found(exception) }
        end

        it 'fails deleting annotation on deleted service broker' do
          expect { delete_service_broker_annotation }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_broker_not_found(exception) }
        end

        it 'fails deleting label on deleted service broker' do
          expect { delete_service_broker_label }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_broker_not_found(exception) }
        end
      end
    end

    context 'manage service instance' do
      before do
        expect(cc.service_instances['items'].length).to eq(1)
      end

      def rename_service_instance
        operation.manage_service_instance(cc_service_instance[:guid], cc_service_instance[:is_gateway_service], "{\"name\":\"#{cc_service_instance_rename}\"}")
      end

      def delete_service_instance
        operation.delete_service_instance(cc_service_instance[:guid], cc_service_instance[:is_gateway_service], false, false)
      end

      def delete_service_instance_recursive
        operation.delete_service_instance(cc_service_instance[:guid], cc_service_instance[:is_gateway_service], true, false)
      end

      def delete_service_instance_recursive_purge
        operation.delete_service_instance(cc_service_instance[:guid], cc_service_instance[:is_gateway_service], true, true)
      end

      def delete_service_instance_annotation
        operation.delete_service_instance_annotation(cc_service_instance[:guid], cc_service_instance_annotation[:key_prefix], cc_service_instance_annotation[:key])
      end

      def delete_service_instance_label
        operation.delete_service_instance_label(cc_service_instance[:guid], cc_service_instance_label[:key_prefix], cc_service_instance_label[:key_name])
      end

      it 'renames the service instance' do
        expect { rename_service_instance }.to change { cc.service_instances['items'][0][:name] }.from(cc_service_instance[:name]).to(cc_service_instance_rename)
      end

      it 'deletes service instance' do
        expect { delete_service_instance }.to change { cc.service_instances['items'].length }.from(1).to(0)
      end

      it 'deletes service instance recursive' do
        expect { delete_service_instance_recursive }.to change { cc.service_instances['items'].length }.from(1).to(0)
      end

      it 'deletes service instance recursive purge' do
        expect { delete_service_instance_recursive_purge }.to change { cc.service_instances['items'].length }.from(1).to(0)
      end

      it 'deletes the service instance annotation' do
        expect { delete_service_instance_annotation }.to change { cc.service_instance_annotations['items'].length }.from(1).to(0)
      end

      it 'deletes the service instance label' do
        expect { delete_service_instance_label }.to change { cc.service_instance_labels['items'].length }.from(1).to(0)
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

        it 'fails renaming deleted service instance' do
          expect { rename_service_instance }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_instance_not_found(exception) }
        end

        it 'fails deleting deleted service instance' do
          expect { delete_service_instance }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_instance_not_found(exception) }
        end

        it 'fails deleting recursive deleted service instance' do
          expect { delete_service_instance_recursive }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_instance_not_found(exception) }
        end

        it 'fails deleting recursive purge deleted service instance' do
          expect { delete_service_instance_recursive_purge }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_instance_not_found(exception) }
        end

        it 'fails deleting annotation on deleted service instance' do
          expect { delete_service_instance_annotation }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_instance_not_found(exception) }
        end

        it 'fails deleting label on deleted service instance' do
          expect { delete_service_instance_label }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_instance_not_found(exception) }
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

      def delete_service_key_annotation
        operation.delete_service_key_annotation(cc_service_key[:guid], cc_service_key_annotation[:key_prefix], cc_service_key_annotation[:key])
      end

      def delete_service_key_label
        operation.delete_service_key_label(cc_service_key[:guid], cc_service_key_label[:key_prefix], cc_service_key_label[:key_name])
      end

      it 'deletes service key' do
        expect { delete_service_key }.to change { cc.service_keys['items'].length }.from(1).to(0)
      end

      it 'deletes the service key annotation' do
        expect { delete_service_key_annotation }.to change { cc.service_key_annotations['items'].length }.from(1).to(0)
      end

      it 'deletes the service key label' do
        expect { delete_service_key_label }.to change { cc.service_key_labels['items'].length }.from(1).to(0)
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

        it 'fails deleting annotation on deleted service key' do
          expect { delete_service_key_annotation }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_key_not_found(exception) }
        end

        it 'fails deleting label on deleted service key' do
          expect { delete_service_key_label }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_key_not_found(exception) }
        end
      end
    end

    context 'manage service plan' do
      before do
        expect(cc.service_plans['items'].length).to eq(1)
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

      def delete_service_plan_annotation
        operation.delete_service_plan_annotation(cc_service_plan[:guid], cc_service_plan_annotation[:key_prefix], cc_service_plan_annotation[:key])
      end

      def delete_service_plan_label
        operation.delete_service_plan_label(cc_service_plan[:guid], cc_service_plan_label[:key_prefix], cc_service_plan_label[:key_name])
      end

      it 'makes service plan public' do
        make_service_plan_private
        expect { make_service_plan_public }.to change { cc.service_plans['items'][0][:public] }.from(false).to(true)
      end

      it 'makes service plan private' do
        make_service_plan_public
        expect { make_service_plan_private }.to change { cc.service_plans['items'][0][:public] }.from(true).to(false)
      end

      it 'deletes service plan' do
        expect { delete_service_plan }.to change { cc.service_plans['items'].length }.from(1).to(0)
      end

      it 'deletes the service plan annotation' do
        expect { delete_service_plan_annotation }.to change { cc.service_plan_annotations['items'].length }.from(1).to(0)
      end

      it 'deletes the service plan label' do
        expect { delete_service_plan_label }.to change { cc.service_plan_labels['items'].length }.from(1).to(0)
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

        it 'fails deleting annotation on deleted service plan' do
          expect { delete_service_plan_annotation }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_plan_not_found(exception) }
        end

        it 'fails deleting label on deleted service plan' do
          expect { delete_service_plan_label }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_plan_not_found(exception) }
        end
      end
    end

    context 'manage service plan visibility' do
      before do
        expect(cc.service_plan_visibilities['items'].length).to eq(1)
      end

      def delete_service_plan_visibility
        operation.delete_service_plan_visibility(cc_service_plan_visibility[:guid], cc_service_plan[:guid], cc_organization[:guid])
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

    context 'manage service provider' do
      before do
        expect(cc.service_providers['items'].length).to eq(1)
      end

      def delete_service_provider
        operation.delete_service_provider(uaa_service_provider[:id])
      end

      it 'deletes service provider' do
        expect { delete_service_provider }.to change { cc.service_providers['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_service_provider
        end

        def verify_service_provider_not_found(exception)
          expect(exception.cf_code).to eq(nil)
          expect(exception.cf_error_code).to eq(nil)
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq('Not Found')
        end

        it 'fails deleting deleted service provider' do
          expect { delete_service_provider }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_service_provider_not_found(exception) }
        end
      end
    end

    context 'manage shared service instance' do
      before do
        expect(cc.service_instance_shares['items'].length).to eq(1)
      end

      def delete_shared_service_instance
        operation.delete_shared_service_instance(cc_service_instance[:guid], cc_space[:guid])
      end

      it 'deletes shared service instance' do
        expect { delete_shared_service_instance }.to change { cc.service_instance_shares['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_shared_service_instance
        end

        def verify_shared_service_instance_unprocessable_entity(exception)
          expect(exception.cf_code).to eq(10_008)
          expect(exception.cf_error_code).to eq('CF-UnprocessableEntity')
          expect(exception.http_code).to eq(422)
          expect(exception.message).to eq("Unable to unshare service instance from space #{cc_space[:guid]}. Ensure the space exists and the service instance has been shared to this space.")
        end

        it 'fails deleting deleted shared service instance' do
          expect { delete_shared_service_instance }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_shared_service_instance_unprocessable_entity(exception) }
        end
      end
    end

    context 'manage space' do
      before do
        expect(cc.spaces['items'].length).to eq(1)
      end

      def rename_space
        operation.manage_space(cc_space[:guid], "{\"name\":\"#{cc_space_rename}\"}")
      end

      def allow_ssh_space
        operation.manage_space(cc_space[:guid], '{"allow_ssh":true}')
      end

      def disallow_ssh_space
        operation.manage_space(cc_space[:guid], '{"allow_ssh":false}')
      end

      def remove_space_isolation_segment
        operation.remove_space_isolation_segment(cc_space[:guid])
      end

      def delete_space_unmapped_routes
        operation.delete_space_unmapped_routes(cc_space[:guid])
      end

      def delete_space
        operation.delete_space(cc_space[:guid], false)
      end

      def delete_space_recursive
        operation.delete_space(cc_space[:guid], true)
      end

      def delete_space_annotation
        operation.delete_space_annotation(cc_space[:guid], cc_space_annotation[:key_prefix], cc_space_annotation[:key])
      end

      def delete_space_label
        operation.delete_space_label(cc_space[:guid], cc_space_label[:key_prefix], cc_space_label[:key_name])
      end

      it 'renames the space' do
        expect { rename_space }.to change { cc.spaces['items'][0][:name] }.from(cc_space[:name]).to(cc_space_rename)
      end

      it 'allows space ssh' do
        disallow_ssh_space
        expect { allow_ssh_space }.to change { cc.spaces['items'][0][:allow_ssh] }.from(false).to(true)
      end

      it 'disallows space ssh' do
        allow_ssh_space
        expect { disallow_ssh_space }.to change { cc.spaces['items'][0][:allow_ssh] }.from(true).to(false)
      end

      it 'removes space isolation segment' do
        expect { remove_space_isolation_segment }.to change { cc.spaces['items'][0][:isolation_segment_guid] }.from(cc_isolation_segment[:guid]).to(nil)
      end

      context 'deletes space unmapped routes' do
        let(:use_route) { false }

        it 'deletes space unmapped routes' do
          expect { delete_space_unmapped_routes }.to change { cc.routes['items'].length }.from(1).to(0)
        end
      end

      it 'deletes space' do
        expect { delete_space }.to change { cc.spaces['items'].length }.from(1).to(0)
      end

      it 'deletes space recursive' do
        expect { delete_space_recursive }.to change { cc.spaces['items'].length }.from(1).to(0)
      end

      it 'deletes the space annotation' do
        expect { delete_space_annotation }.to change { cc.space_annotations['items'].length }.from(1).to(0)
      end

      it 'deletes space label' do
        expect { delete_space_label }.to change { cc.space_labels['items'].length }.from(1).to(0)
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

        it 'fails renaming deleted space' do
          expect { rename_space }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_space_not_found(exception) }
        end

        it 'fails allowing ssh on deleted space' do
          expect { allow_ssh_space }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_space_not_found(exception) }
        end

        it 'fails disallowing ssh on deleted space' do
          expect { disallow_ssh_space }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_space_not_found(exception) }
        end

        it 'fails removing isolation segment on deleted space' do
          expect { remove_space_isolation_segment }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_space_not_found(exception) }
        end

        it 'fails deleting unmapped routes on deleted space' do
          expect { delete_space_unmapped_routes }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_space_not_found(exception) }
        end

        it 'fails deleting deleted space' do
          expect { delete_space }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_space_not_found(exception) }
        end

        it 'fails deleting recursive deleted space' do
          expect { delete_space_recursive }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_space_not_found(exception) }
        end

        it 'fails deleting annotation on deleted space' do
          expect { delete_space_annotation }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_space_not_found(exception) }
        end

        it 'fails deleting label on deleted space' do
          expect { delete_space_label }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_space_not_found(exception) }
        end
      end
    end

    context 'manage space quota definition' do
      before do
        expect(cc.space_quota_definitions['items'].length).to eq(1)
      end

      def rename_space_quota_definition
        operation.manage_space_quota_definition(cc_space_quota_definition[:guid], "{\"name\":\"#{cc_space_quota_definition_rename}\"}")
      end

      def delete_space_quota_definition
        operation.delete_space_quota_definition(cc_space_quota_definition[:guid])
      end

      it 'renames the space quota definition' do
        expect { rename_space_quota_definition }.to change { cc.space_quota_definitions['items'][0][:name] }.from(cc_space_quota_definition[:name]).to(cc_space_quota_definition_rename)
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

        it 'fails renaming deleted space quota definition' do
          expect { rename_space_quota_definition }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_space_quota_definition_not_found(exception) }
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
        operation.delete_space_role(cc_space[:guid], cc_space_auditor[:role_guid], 'auditors', cc_user[:guid])
      end

      def delete_space_developer
        operation.delete_space_role(cc_space[:guid], cc_space_developer[:role_guid], 'developers', cc_user[:guid])
      end

      def delete_space_manager
        operation.delete_space_role(cc_space[:guid], cc_space_manager[:role_guid], 'managers', cc_user[:guid])
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

    context 'manage stack' do
      before do
        expect(cc.stacks['items'].length).to eq(1)
      end

      def delete_stack
        operation.delete_stack(cc_stack[:guid])
      end

      def delete_stack_annotation
        operation.delete_stack_annotation(cc_stack[:guid], cc_stack_annotation[:key_prefix], cc_stack_annotation[:key])
      end

      def delete_stack_label
        operation.delete_stack_label(cc_stack[:guid], cc_stack_label[:key_prefix], cc_stack_label[:key_name])
      end

      it 'deletes stack' do
        expect { delete_stack }.to change { cc.stacks['items'].length }.from(1).to(0)
      end

      it 'deletes the stack annotation' do
        expect { delete_stack_annotation }.to change { cc.stack_annotations['items'].length }.from(1).to(0)
      end

      it 'deletes the stack label' do
        expect { delete_stack_label }.to change { cc.stack_labels['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_stack
        end

        def verify_stack_not_found(exception)
          expect(exception.cf_code).to eq(250_003)
          expect(exception.cf_error_code).to eq('CF-StackNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The stack could not be found: #{cc_stack[:guid]}")
        end

        it 'fails deleting deleted stack' do
          expect { delete_stack }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_stack_not_found(exception) }
        end

        it 'fails deleting annotation on deleted stack' do
          expect { delete_stack_annotation }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_stack_not_found(exception) }
        end

        it 'fails deleting label on deleted stack' do
          expect { delete_stack_label }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_stack_not_found(exception) }
        end
      end
    end

    context 'manage staging security group space' do
      before do
        expect(cc.staging_security_groups_spaces['items'].length).to eq(1)
      end

      def delete_staging_security_group_space
        operation.delete_staging_security_group_space(cc_security_group[:guid], cc_space[:guid])
      end

      it 'deletes staging security group space' do
        expect { delete_staging_security_group_space }.to change { cc.staging_security_groups_spaces['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          cc_clear_security_groups_cache_stub(config)
        end

        def verify_security_group_not_found(exception)
          expect(exception.cf_code).to eq(300_002)
          expect(exception.cf_error_code).to eq('CF-SecurityGroupNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The security group could not be found: #{cc_security_group[:guid]}")
        end

        it 'failed deleting staging security group space due to deleted security group' do
          expect { delete_staging_security_group_space }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_security_group_not_found(exception) }
        end
      end
    end

    context 'manage task' do
      before do
        expect(cc.tasks['items'].length).to eq(1)
      end

      def cancel_task
        operation.cancel_task(cc_task[:guid])
      end

      def delete_task_annotation
        operation.delete_task_annotation(cc_task[:guid], cc_task_annotation[:key_prefix], cc_task_annotation[:key])
      end

      def delete_task_label
        operation.delete_task_label(cc_task[:guid], cc_task_label[:key_prefix], cc_task_label[:key_name])
      end

      it 'cancels the task' do
        expect { cancel_task }.to change { cc.tasks['items'][0][:state] }.from(cc_task[:state]).to('FAILED')
      end

      it 'deletes the task annotation' do
        expect { delete_task_annotation }.to change { cc.task_annotations['items'].length }.from(1).to(0)
      end

      it 'deletes the task label' do
        expect { delete_task_label }.to change { cc.task_labels['items'].length }.from(1).to(0)
      end

      context 'errors' do
        context 'not found error' do
          before do
            cc_clear_tasks_cache_stub(config)
          end

          def verify_task_not_found(exception)
            expect(exception.cf_code).to eq(10_010)
            expect(exception.cf_error_code).to eq('CF-ResourceNotFound')
            expect(exception.http_code).to eq(404)
            expect(exception.message).to eq('Task not found')
          end

          it 'fails canceling deleted task' do
            expect { cancel_task }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_task_not_found(exception) }
          end

          it 'fails deleting annotation on deleted task' do
            expect { delete_task_annotation }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_task_not_found(exception) }
          end

          it 'fails deleting label on deleted task' do
            expect { delete_task_label }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_task_not_found(exception) }
          end
        end
      end
    end

    context 'manage user' do
      before do
        expect(cc.users_cc['items'].length).to eq(1)
        expect(cc.users_uaa['items'].length).to eq(1)
      end

      def activate_user
        operation.manage_user(uaa_user[:id], '{"active":true}')
      end

      def deactivate_user
        operation.manage_user(uaa_user[:id], '{"active":false}')
      end

      def verify_user
        operation.manage_user(uaa_user[:id], '{"verified":true}')
      end

      def unverify_user
        operation.manage_user(uaa_user[:id], '{"verified":false}')
      end

      def unlock_user
        operation.manage_user_status(uaa_user[:id], '{"locked":false}')
      end

      def require_password_change_user
        operation.manage_user_status(uaa_user[:id], '{"passwordChangeRequired":true}')
      end

      def revoke_tokens
        operation.delete_user_tokens(cc_user[:guid])
      end

      def delete_user
        operation.delete_user(cc_user[:guid])
      end

      def delete_user_annotation
        operation.delete_user_annotation(cc_user[:guid], cc_user_annotation[:key_prefix], cc_user_annotation[:key])
      end

      def delete_user_label
        operation.delete_user_label(cc_user[:guid], cc_user_label[:key_prefix], cc_user_label[:key_name])
      end

      it 'activates user' do
        deactivate_user
        expect { activate_user }.to change { cc.users_uaa['items'][0][:active] }.from(false).to(true)
      end

      it 'deactivates user' do
        activate_user
        expect { deactivate_user }.to change { cc.users_uaa['items'][0][:active] }.from(true).to(false)
      end

      it 'verifies user' do
        unverify_user
        expect { verify_user }.to change { cc.users_uaa['items'][0][:verified] }.from(false).to(true)
      end

      it 'unverifies user' do
        verify_user
        expect { unverify_user }.to change { cc.users_uaa['items'][0][:verified] }.from(true).to(false)
      end

      it 'unlocks user' do
        # No database modification to verify the change actually worked
        unlock_user
      end

      it 'require password change user' do
        expect { require_password_change_user }.to change { cc.users_uaa['items'][0][:passwd_change_required] }.from(false).to(true)
      end

      it 'revokes user tokens' do
        revoke_tokens
        expect(cc.revocable_tokens['items'].length).to eq(0)
      end

      it 'deletes user' do
        expect { delete_user }.to change { cc.users_uaa['items'].length }.from(1).to(0)
        expect(cc.users_uaa['items'].length).to eq(0)
      end

      it 'deletes the user annotation' do
        expect { delete_user_annotation }.to change { cc.user_annotations['items'].length }.from(1).to(0)
      end

      it 'deletes the user label' do
        expect { delete_user_label }.to change { cc.user_labels['items'].length }.from(1).to(0)
      end

      context 'errors' do
        before do
          delete_user
        end

        def verify_cc_user_not_found(exception)
          expect(exception.cf_code).to eq(20_003)
          expect(exception.cf_error_code).to eq('CF-UserNotFound')
          expect(exception.http_code).to eq(404)
          expect(exception.message).to eq("The user could not be found: #{cc_user[:guid]}")
        end

        def verify_uaa_user_not_found(exception)
          expect(exception.message).to eq("User #{uaa_user[:id]} does not exist")
        end

        it 'fails activating deleted user' do
          expect { activate_user }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_uaa_user_not_found(exception) }
        end

        it 'fails deactivating deleted user' do
          expect { deactivate_user }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_uaa_user_not_found(exception) }
        end

        it 'fails verifying deleted user' do
          expect { verify_user }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_uaa_user_not_found(exception) }
        end

        it 'fails unverifying deleted user' do
          expect { unverify_user }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_uaa_user_not_found(exception) }
        end

        it 'fails unlocking deleted user' do
          expect { unlock_user }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_uaa_user_not_found(exception) }
        end

        it 'fails requiring password change for deleted user' do
          expect { require_password_change_user }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_uaa_user_not_found(exception) }
        end

        it 'fails revoking tokens for deleted user' do
          expect { revoke_tokens }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_uaa_user_not_found(exception) }
        end

        it 'fails deleting deleted user' do
          expect { delete_user }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_cc_user_not_found(exception) }
        end

        it 'fails deleting annotation on deleted user' do
          expect { delete_user_annotation }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_cc_user_not_found(exception) }
        end

        it 'fails deleting label on deleted user' do
          expect { delete_user_label }.to raise_error(AdminUI::CCRestClientResponseError) { |exception| verify_cc_user_not_found(exception) }
        end
      end
    end

    context 'manage doppler components' do
      context 'doppler analyzer' do
        before do
          expect(doppler.components['items'].length).to eq(2)
        end

        after do
          expect(doppler.components['items'].length).to eq(1)
        end

        it 'removes analyzer' do
          expect { operation.remove_doppler_component("#{analyzer_envelope.origin}:#{analyzer_envelope.index}:#{analyzer_envelope.ip}") }.to change { doppler.analyzers['items'].length }.from(1).to(0)
        end
      end

      context 'doppler router' do
        let(:router_source) { :doppler_router }
        before do
          expect(doppler.components['items'].length).to eq(3)
        end

        after do
          expect(doppler.components['items'].length).to eq(2)
        end

        it 'removes gorouter' do
          expect { operation.remove_doppler_component("#{gorouter_envelope.origin}:#{gorouter_envelope.index}:#{gorouter_envelope.ip}") }.to change { doppler.gorouters['items'].length }.from(1).to(0)
        end
      end

      context 'doppler cell' do
        let(:application_instance_source) { :doppler_cell }
        before do
          expect(doppler.components['items'].length).to eq(2)
        end

        after do
          expect(doppler.components['items'].length).to eq(1)
        end

        it 'removes rep' do
          expect { operation.remove_doppler_component("#{rep_envelope.origin}:#{rep_envelope.index}:#{rep_envelope.ip}") }.to change { doppler.reps['items'].length }.from(1).to(0)
        end
      end

      context 'doppler dea' do
        before do
          expect(doppler.components['items'].length).to eq(2)
        end

        after do
          expect(doppler.components['items'].length).to eq(1)
        end

        it 'removes dea' do
          expect { operation.remove_doppler_component("#{dea_envelope.origin}:#{dea_envelope.index}:#{dea_envelope.ip}") }.to change { doppler.deas['items'].length }.from(1).to(0)
        end
      end
    end

    context 'manage varz components' do
      before do
        expect(varz.components['items'].length).to eq(3)
      end

      after do
        expect(varz.components['items'].length).to eq(2)
      end

      it 'removes cloud_controller' do
        expect { operation.remove_component(nats_cloud_controller_varz) }.to change { varz.cloud_controllers['items'].length }.from(1).to(0)
      end

      it 'removes gateway' do
        expect { operation.remove_component(nats_provisioner_varz) }.to change { varz.gateways['items'].length }.from(1).to(0)
      end

      it 'removes router' do
        expect { operation.remove_component(nats_router_varz) }.to change { varz.routers['items'].length }.from(1).to(0)
      end
    end
  end
end
