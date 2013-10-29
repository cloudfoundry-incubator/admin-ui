require 'webrick'
require_relative '../spec_helper'

shared_context :server_context do
  include CCHelper
  include NATSHelper
  include VARZHelper

  let(:host) { 'localhost' }
  let(:port) { 8071 }

  let(:data_file) { '/tmp/admin_ui_data.json' }
  let(:log_file) { '/tmp/admin_ui.log' }
  let(:stats_file) { '/tmp/admin_ui_stats.json' }

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
      :log_files              => [log_file],
      :mbus                   => 'nats://nats:c1oudc0w@localhost:14222',
      :monitored_components   => ['ALL'],
      :port                   => port,
      :receiver_emails        => [],
      :sender_email           => { :account => 'system@localhost', :server => 'localhost' },
      :stats_file             => stats_file,
      :uaa_admin_credentials  => { :password => 'c1oudc0w', :username => 'admin' },
      :ui_admin_credentials   => { :password => admin_password, :username => admin_user },
      :ui_credentials         => { :password => user_password, :username => user }
    }
  end

  before do
    cc_stub(IBM::AdminUI::Config.load(config))
    nats_stub
    varz_stub

    ::WEBrick::Log.any_instance.stub(:log)

    Thread.new do
      IBM::AdminUI::Admin.new(config).start
    end

    sleep(1)
  end

  after do
    Rack::Handler::WEBrick.shutdown

    Thread.list.each do |thread|
      unless thread == Thread.main
        thread.kill
        thread.join
      end
    end
    Process.wait(Process.spawn({}, "rm -fr #{ data_file } #{ log_file } #{ stats_file }"))
  end
end
