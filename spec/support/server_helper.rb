require 'webrick'
require_relative '../spec_helper'
require_relative 'cc_helper'
require_relative 'login_helper'
require_relative 'nats_helper'
require_relative 'varz_helper'
require_relative 'view_models_helper'

shared_context :server_context do
  include CCHelper
  include DopplerHelper
  include LoginHelper
  include NATSHelper
  include VARZHelper
  include ViewModelsHelper

  let(:application_instance_source)              { :doppler_dea }
  let(:ccdb_file)                                { '/tmp/admin_ui_ccdb.db' }
  let(:ccdb_uri)                                 { "sqlite://#{ccdb_file}" }
  let(:cloud_controller_uri)                     { 'http://api.localhost' }
  let(:data_file)                                { '/tmp/admin_ui_data.json' }
  let(:db_file)                                  { '/tmp/admin_ui_store.db' }
  let(:db_uri)                                   { "sqlite://#{db_file}" }
  let(:doppler_data_file)                        { '/tmp/admin_ui_doppler_data.json' }
  let(:event_type)                               { 'space' }
  let(:host)                                     { 'localhost' }
  let(:insert_second_quota_definition)           { false }
  let(:log_file)                                 { '/tmp/admin_ui.log' }
  let(:log_file_displayed)                       { '/tmp/admin_ui_displayed.log' }
  let(:log_file_displayed_contents)              { 'These are test log file contents' }
  let(:log_file_displayed_contents_length)       { log_file_displayed_contents.length }
  let(:log_file_displayed_modified)              { Time.new(1976, 7, 4, 12, 34, 56, 0) }
  let(:log_file_displayed_modified_milliseconds) { AdminUI::Utils.time_in_milliseconds(log_file_displayed_modified) }
  let(:log_file_page_size)                       { 100 }
  let(:port)                                     { 8071 }
  let(:router_source)                            { :varz_router }
  let(:table_height)                             { '300px' }
  let(:table_page_size)                          { 10 }
  let(:uaadb_file)                               { '/tmp/admin_ui_uaadb.db' }
  let(:uaadb_uri)                                { "sqlite://#{uaadb_file}" }
  let(:use_route)                                { true }
  let(:used_cpu)                                 { determine_used_cpu(application_instance_source) }
  let(:used_disk)                                { determine_used_disk(application_instance_source) }
  let(:used_memory)                              { determine_used_memory(application_instance_source) }

  let(:config) do
    {
      ccdb_uri:                ccdb_uri,
      cloud_controller_uri:    cloud_controller_uri,
      data_file:               data_file,
      db_uri:                  db_uri,
      doppler_data_file:       doppler_data_file,
      doppler_rollup_interval: 1,
      log_file:                log_file,
      log_file_page_size:      log_file_page_size,
      log_files:               [log_file_displayed],
      mbus:                    'nats://nats:c1oudc0w@localhost:14222',
      nats_discovery_timeout:  1,
      port:                    port,
      table_height:            table_height,
      table_page_size:         table_page_size,
      uaadb_uri:               uaadb_uri,
      uaa_client:              {
                                 id:     'id',
                                 secret: 'secret'
                               }
    }
  end

  def cleanup_files
    Process.wait(Process.spawn({}, "rm -fr #{ccdb_file} #{data_file} #{db_file} #{doppler_data_file} #{log_file} #{log_file_displayed} #{uaadb_file}"))
  end

  before do
    cleanup_files

    File.open(log_file_displayed, 'w') do |file|
      file << log_file_displayed_contents
    end
    File.utime(log_file_displayed_modified, log_file_displayed_modified, log_file_displayed)

    cc_stub(AdminUI::Config.load(config), true, insert_second_quota_definition, event_type, use_route)
    doppler_stub(cc_info['doppler_logging_endpoint'], application_instance_source, router_source)
    login_stub_admin
    nats_stub(router_source)
    varz_stub
    view_models_stub(application_instance_source, router_source)

    allow_any_instance_of(::WEBrick::Log).to receive(:log)

    mutex                  = Mutex.new
    condition              = ConditionVariable.new
    start_callback_invoked = false
    start_callback         = proc do
      mutex.synchronize do
        start_callback_invoked = true
        condition.broadcast
      end
    end

    @admin = AdminUI::Admin.new(config, true, start_callback)

    Thread.new do
      @admin.start
    end

    mutex.synchronize do
      condition.wait(mutex) until start_callback_invoked
    end
  end

  after do
    @admin.shutdown

    cleanup_files
  end
end
