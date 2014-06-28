require 'webrick'
require_relative '../spec_helper'

shared_context :server_context do
  include CCHelper
  include NATSHelper
  include VARZHelper
  include OperationHelper

  let(:host) { 'localhost' }
  let(:port) { 8071 }

  let(:data_file) { '/tmp/admin_ui_data.json' }
  let(:log_file) { '/tmp/admin_ui.log' }
  let(:log_file_displayed) { '/tmp/admin_ui_displayed.log' }
  let(:log_file_displayed_contents) { 'These are test log file contents' }
  let(:log_file_displayed_contents_length) { log_file_displayed_contents.length }
  let(:log_file_displayed_modified) { Time.new(1976, 7, 4, 12, 34, 56, 0) }
  let(:log_file_displayed_modified_milliseconds) { AdminUI::Utils.time_in_milliseconds(log_file_displayed_modified) }
  let(:log_file_page_size) { 100 }
  let(:db_file) { '/tmp/admin_ui_store.db' }

  let(:admin_user) { 'admin' }
  let(:admin_password) { 'admin_passw0rd' }

  let(:user) { 'user' }
  let(:user_password) { 'user_passw0rd' }

  let(:cloud_controller_uri) { 'http://api.localhost' }
  let(:config) do
    {
      :cloud_controller_uri   => cloud_controller_uri,
      :data_file              => data_file,
      :log_file               => log_file,
      :log_file_page_size     => log_file_page_size,
      :log_files              => [log_file_displayed],
      :mbus                   => 'nats://nats:c1oudc0w@localhost:14222',
      :port                   => port,
      :db_uri                 => "sqlite://#{db_file}",
      :uaa_admin_credentials  => { :password => 'c1oudc0w', :username => 'admin' },
      :ui_admin_credentials   => { :password => admin_password, :username => admin_user },
      :ui_credentials         => { :password => user_password, :username => user },
      :cloud_controller_discovery_interval    => 3,
      :nats_discovery_interval                => 3,
      :varz_discovery_interval                => 3
    }
  end

  before do
    File.open(log_file_displayed, 'w') do |file|
      file << log_file_displayed_contents
    end
    File.utime(log_file_displayed_modified, log_file_displayed_modified, log_file_displayed)

    cc_stub(AdminUI::Config.load(config))
    nats_stub
    varz_stub
    operation_stub(AdminUI::Config.load(config))

    ::WEBrick::Log.any_instance.stub(:log)

    Thread.new do
      AdminUI::Admin.new(config, true).start
    end

    sleep(5)
  end

  after do
    Rack::Handler::WEBrick.shutdown

    Thread.list.each do |thread|
      unless thread == Thread.main
        thread.kill
        thread.join
      end
    end

    Process.wait(Process.spawn({}, "rm -fr #{ data_file } #{ log_file } #{ log_file_displayed } #{ db_file }"))
  end
end
