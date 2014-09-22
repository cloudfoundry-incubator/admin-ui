require 'logger'
require_relative '../spec_helper'

describe AdminUI::CC, :type => :integration do
  include ViewModelsHelper

  let(:ccdb_file) { '/tmp/admin_ui_ccdb.db' }
  let(:ccdb_uri) { "sqlite://#{ ccdb_file }" }
  let(:data_file) { '/tmp/admin_ui.data' }
  let(:db_file) { '/tmp/admin_ui_store.db' }
  let(:db_uri) { "sqlite://#{ db_file }" }
  let(:log_file) { '/tmp/admin_ui.log' }
  let(:log_file_displayed) { '/tmp/admin_ui_displayed.log' }
  let(:log_file_displayed_contents) { 'These are test log file contents' }
  let(:log_file_displayed_modified) { Time.new(1976, 7, 4, 12, 34, 56, 0) }
  let(:logger) { Logger.new(log_file) }
  let(:uaadb_file) { '/tmp/admin_ui_uaadb.db' }
  let(:uaadb_uri)  { "sqlite://#{ uaadb_file }" }
  let(:config) do
    AdminUI::Config.load(:ccdb_uri                            => ccdb_uri,
                         :cloud_controller_discovery_interval => 1,
                         :cloud_controller_uri                => 'http://api.cloudfoundry',
                         :data_file                           => data_file,
                         :db_uri                              => db_uri,
                         :log_file                            => log_file,
                         :log_files                           => [log_file_displayed],
                         :mbus                                => 'nats://nats:c1oudc0w@localhost:14222',
                         :nats_discovery_interval             => 1,
                         :uaadb_uri                           => uaadb_uri,
                         :varz_discovery_interval             => 1)
  end

  def cleanup_files
    Process.wait(Process.spawn({}, "rm -fr #{ ccdb_file } #{ data_file } #{ db_file } #{ log_file } #{ log_file_displayed } #{ uaadb_file }"))
  end

  before do
    cleanup_files

    File.open(log_file_displayed, 'w') do |file|
      file << log_file_displayed_contents
    end
    File.utime(log_file_displayed_modified, log_file_displayed_modified, log_file_displayed)

    AdminUI::Config.any_instance.stub(:validate)
    cc_stub(config)
    nats_stub
    varz_stub
  end

  let(:client) { AdminUI::CCRestClient.new(config, logger) }
  let(:cc) { AdminUI::CC.new(config, logger, client, true) }
  let(:email) { AdminUI::EMail.new(config, logger) }
  let(:log_files) { AdminUI::LogFiles.new(config, logger) }
  let(:nats) { AdminUI::NATS.new(config, logger, email) }
  let(:tasks) { AdminUI::Tasks.new(config, logger) }
  let(:varz) { AdminUI::VARZ.new(config, logger, nats, true) }
  let(:stats) { AdminUI::Stats.new(config, logger, cc, varz) }
  let(:view_models) { AdminUI::ViewModels.new(config, logger, cc, log_files, stats, tasks, varz, true) }

  after do
    Thread.list.each do |thread|
      unless thread == Thread.main
        thread.kill
        thread.join
      end
    end

    cleanup_files
  end

  context 'Stubbed HTTP' do
    shared_examples 'common view model retrieval' do
      it 'verify view model retrieval' do
        expect(results[:connected]).to eq(true)
        expect(results[:items]).to_not be(nil)

        items = results[:items]

        expected.each do |expected_entry|
          expect(items).to include(expected_entry)
        end
      end
    end

    context 'returns connected applications_view_model' do
      let(:results)  { view_models.applications }
      let(:expected) { view_models_applications }

      it_behaves_like('common view model retrieval')
    end

    context 'returns connected cloud_controllers_view_model' do
      let(:results)  { view_models.cloud_controllers }
      let(:expected) { view_models_cloud_controllers }

      it_behaves_like('common view model retrieval')
    end

    context 'returns connected components_view_model' do
      let(:results)  { view_models.components }
      let(:expected) { view_models_components }

      it_behaves_like('common view model retrieval')
    end

    context 'returns connected deas_view_model' do
      let(:results)  { view_models.deas }
      let(:expected) { view_models_deas }

      it_behaves_like('common view model retrieval')
    end

    context 'returns connected domains_view_model' do
      let(:results)  { view_models.domains }
      let(:expected) { view_models_domains }

      it_behaves_like('common view model retrieval')
    end

    context 'returns connected gateways_view_model' do
      let(:results)  { view_models.gateways }
      let(:expected) { view_models_gateways }

      it_behaves_like('common view model retrieval')
    end

    context 'returns connected health_managers_view_model' do
      let(:results)  { view_models.health_managers }
      let(:expected) { view_models_health_managers }

      it_behaves_like('common view model retrieval')
    end

    context 'returns connected logs_view_model' do
      let(:results)                                  { view_models.logs }
      let(:log_file_displayed_contents_length)       { log_file_displayed_contents.length }
      let(:log_file_displayed_modified_milliseconds) { AdminUI::Utils.time_in_milliseconds(log_file_displayed_modified) }
      let(:expected)                                 { view_models_logs(log_file_displayed, log_file_displayed_contents_length, log_file_displayed_modified_milliseconds) }

      it_behaves_like('common view model retrieval')
    end

    context 'returns connected organizations_view_model' do
      let(:results)  { view_models.organizations }
      let(:expected) { view_models_organizations }

      it_behaves_like('common view model retrieval')
    end

    context 'returns connected organization_roles_view_model' do
      let(:results)  { view_models.organization_roles }
      let(:expected) { view_models_organization_roles }

      it_behaves_like('common view model retrieval')
    end

    context 'returns connected quotas_view_model' do
      let(:results)  { view_models.quotas }
      let(:expected) { view_models_quotas }

      it_behaves_like('common view model retrieval')
    end

    context 'returns connected routers_view_model' do
      let(:results)  { view_models.routers }
      let(:expected) { view_models_routers }

      it_behaves_like('common view model retrieval')
    end

    context 'returns connected routes_view_model' do
      let(:results)  { view_models.routes }
      let(:expected) { view_models_routes }

      it_behaves_like('common view model retrieval')
    end

    context 'returns connected service_instances_view_model' do
      let(:results)  { view_models.service_instances }
      let(:expected) { view_models_service_instances }

      it_behaves_like('common view model retrieval')
    end

    context 'returns connected service_plans_view_model' do
      let(:results)  { view_models.service_plans }
      let(:expected) { view_models_service_plans }

      it_behaves_like('common view model retrieval')
    end

    context 'returns connected spaces_view_model' do
      let(:results)  { view_models.spaces }
      let(:expected) { view_models_spaces }

      it_behaves_like('common view model retrieval')
    end

    context 'returns connected space_roles_view_model' do
      let(:results)  { view_models.space_roles }
      let(:expected) { view_models_space_roles }

      it_behaves_like('common view model retrieval')
    end

    context 'returns connected stats_view_model' do
      let(:results)   { view_models.stats }
      let(:timestamp) { results[:items][0][8][:timestamp] } # We have to copy the timestamp from the result since it is variable
      let(:expected)  { view_models_stats(timestamp) }

      it_behaves_like('common view model retrieval')
    end

    context 'returns connected users_view_model' do
      let(:results)  { view_models.users }
      let(:expected) { view_models_users }

      it_behaves_like('common view model retrieval')
    end
  end
end
