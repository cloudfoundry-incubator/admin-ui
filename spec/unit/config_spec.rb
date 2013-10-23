require_relative '../spec_helper'

describe IBM::AdminUI::Config do
  context 'Values loaded and returned' do
    it 'cloud_controller_discovery_interval' do
      cloud_controller_discovery_interval = 11
      IBM::AdminUI::Config.load('cloud_controller_discovery_interval' => cloud_controller_discovery_interval)
      IBM::AdminUI::Config.cloud_controller_discovery_interval.should eq(cloud_controller_discovery_interval)
    end

    it 'cloud_controller_uri' do
      cloud_controller_uri = 'http://api.localhost'
      IBM::AdminUI::Config.load('cloud_controller_uri' => cloud_controller_uri)
      IBM::AdminUI::Config.cloud_controller_uri.should eq(cloud_controller_uri)
    end

    it 'component_connection_retries' do
      component_connection_retries = 22
      IBM::AdminUI::Config.load('component_connection_retries' => component_connection_retries)
      IBM::AdminUI::Config.component_connection_retries.should eq(component_connection_retries)
    end

    it 'data_file' do
      data_file = 'data.json'
      IBM::AdminUI::Config.load('data_file' => data_file)
      IBM::AdminUI::Config.data_file.should eq(data_file)
    end

    it 'log_file' do
      log_file = 'admin_ui.log'
      IBM::AdminUI::Config.load('log_file' => log_file)
      IBM::AdminUI::Config.log_file.should eq(log_file)
    end

    it 'log_file_page_size' do
      log_file_page_size = 33
      IBM::AdminUI::Config.load('log_file_page_size' => log_file_page_size)
      IBM::AdminUI::Config.log_file_page_size.should eq(log_file_page_size)
    end

    it 'log_files' do
      log_files = %w(file1 file2)
      IBM::AdminUI::Config.load('log_files' => log_files)
      IBM::AdminUI::Config.log_files.should eq(log_files)
    end

    it 'mbus' do
      mbus = 'nats://nats:c1oudc0w@localhost:14222'
      IBM::AdminUI::Config.load('mbus' => mbus)
      IBM::AdminUI::Config.mbus.should eq(mbus)
    end

    it 'monitored_components' do
      monitored_components = ['ALL']
      IBM::AdminUI::Config.load('monitored_components' => monitored_components)
      IBM::AdminUI::Config.monitored_components.should eq(monitored_components)
    end

    it 'nats_discovery_interval' do
      nats_discovery_interval = 44
      IBM::AdminUI::Config.load('nats_discovery_interval' => nats_discovery_interval)
      IBM::AdminUI::Config.nats_discovery_interval.should eq(nats_discovery_interval)
    end

    it 'nats_discovery_timeout' do
      nats_discovery_timeout = 55
      IBM::AdminUI::Config.load('nats_discovery_timeout' => nats_discovery_timeout)
      IBM::AdminUI::Config.nats_discovery_timeout.should eq(nats_discovery_timeout)
    end

    it 'port' do
      port = 55
      IBM::AdminUI::Config.load('port' => port)
      IBM::AdminUI::Config.port.should eq(port)
    end

    it 'receiver_emails' do
      receiver_emails = ['bogus@localhost.com']
      IBM::AdminUI::Config.load('receiver_emails' => receiver_emails)
      IBM::AdminUI::Config.receiver_emails.should eq(receiver_emails)
    end

    context 'sender_email' do
      sender_email = { 'server' => 'localhost', 'account' => 'bogus@localhost.com' }

      before do
        IBM::AdminUI::Config.load('sender_email' => sender_email)
      end

      it 'sender_email_account' do
        IBM::AdminUI::Config.sender_email_account.should eq(sender_email['account'])
      end

      it 'sender_email_server' do
        IBM::AdminUI::Config.sender_email_server.should eq(sender_email['server'])
      end
    end

    it 'stats_file' do
      stats_file = 'stats.json'
      IBM::AdminUI::Config.load('stats_file' => stats_file)
      IBM::AdminUI::Config.stats_file.should eq(stats_file)
    end

    it 'stats_refresh_time' do
      stats_refresh_time = 66
      IBM::AdminUI::Config.load('stats_refresh_time' => stats_refresh_time)
      IBM::AdminUI::Config.stats_refresh_time.should eq(stats_refresh_time)
    end

    it 'stats_retries' do
      stats_retries = 77
      IBM::AdminUI::Config.load('stats_retries' => stats_retries)
      IBM::AdminUI::Config.stats_retries.should eq(stats_retries)
    end

    it 'stats_retry_interval' do
      stats_retry_interval = 88
      IBM::AdminUI::Config.load('stats_retry_interval' => stats_retry_interval)
      IBM::AdminUI::Config.stats_retry_interval.should eq(stats_retry_interval)
    end

    it 'tasks_refresh_interval' do
      tasks_refresh_interval = 99
      IBM::AdminUI::Config.load('tasks_refresh_interval' => tasks_refresh_interval)
      IBM::AdminUI::Config.tasks_refresh_interval.should eq(tasks_refresh_interval)
    end

    context 'uaa_admin_credentials' do
      uaa_admin_credentials = { 'password' => 'uaa_admin_bogus_password', 'username' => 'uaa_admin_bogus_username' }

      before do
        IBM::AdminUI::Config.load('uaa_admin_credentials' => uaa_admin_credentials)
      end

      it 'uaa_admin_credentials_password' do
        IBM::AdminUI::Config.uaa_admin_credentials_password.should eq(uaa_admin_credentials['password'])
      end

      it 'uaa_admin_credentials_username' do
        IBM::AdminUI::Config.uaa_admin_credentials_username.should eq(uaa_admin_credentials['username'])
      end
    end

    context 'ui_admin_credentials' do
      ui_admin_credentials = { 'password' => 'ui_admin_bogus_password', 'username' => 'ui_admin_bogus_username' }

      before do
        IBM::AdminUI::Config.load('ui_admin_credentials' => ui_admin_credentials)
      end

      it 'ui_admin_credentials_password' do
        IBM::AdminUI::Config.ui_admin_credentials_password.should eq(ui_admin_credentials['password'])
      end

      it 'ui_admin_credentials_username' do
        IBM::AdminUI::Config.ui_admin_credentials_username.should eq(ui_admin_credentials['username'])
      end
    end

    context 'ui_credentials' do
      ui_credentials = { 'password' => 'ui_bogus_password', 'username' => 'ui_bogus_username' }

      before do
        IBM::AdminUI::Config.load('ui_credentials' => ui_credentials)
      end

      it 'ui_credentials_password' do
        IBM::AdminUI::Config.ui_credentials_password.should eq(ui_credentials['password'])
      end

      it 'ui_credentials_username' do
        IBM::AdminUI::Config.ui_credentials_username.should eq(ui_credentials['username'])
      end
    end

    it 'varz_discovery_interval' do
      varz_discovery_interval = 111
      IBM::AdminUI::Config.load('varz_discovery_interval' => varz_discovery_interval)
      IBM::AdminUI::Config.varz_discovery_interval.should eq(varz_discovery_interval)
    end
  end

  context 'Defaults' do
    before do
      IBM::AdminUI::Config.load({})
    end

    it 'cloud_controller_discovery_interval' do
      IBM::AdminUI::Config.cloud_controller_discovery_interval.should eq(300)
    end

    it 'cloud_controller_uri' do
      IBM::AdminUI::Config.cloud_controller_uri.should be_nil
    end

    it 'component_connection_retries' do
      IBM::AdminUI::Config.component_connection_retries.should eq(2)
    end

    it 'data_file' do
      IBM::AdminUI::Config.data_file.should be_nil
    end

    it 'log_file' do
      IBM::AdminUI::Config.log_file.should be_nil
    end

    it 'log_file_page_size' do
      IBM::AdminUI::Config.log_file_page_size.should eq(51_200)
    end

    it 'log_files' do
      IBM::AdminUI::Config.log_files.should be_nil
    end

    it 'mbus' do
      IBM::AdminUI::Config.mbus.should be_nil
    end

    it 'monitored_components' do
      IBM::AdminUI::Config.monitored_components.should be_nil
    end

    it 'nats_discovery_interval' do
      IBM::AdminUI::Config.nats_discovery_interval.should eq(30)
    end

    it 'nats_discovery_timeout' do
      IBM::AdminUI::Config.nats_discovery_timeout.should eq(10)
    end

    it 'port' do
      IBM::AdminUI::Config.port.should be_nil
    end

    it 'receiver_emails' do
      IBM::AdminUI::Config.receiver_emails.should be_nil
    end

    context 'sender_email' do
      it 'sender_email_account' do
        IBM::AdminUI::Config.sender_email_account.should be_nil
      end

      it 'sender_email_server' do
        IBM::AdminUI::Config.sender_email_server.should be_nil
      end
    end

    it 'stats_file' do
      IBM::AdminUI::Config.stats_file.should be_nil
    end

    it 'stats_refresh_time' do
      IBM::AdminUI::Config.stats_refresh_time.should eq(60 * 5)
    end

    it 'stats_retries' do
      IBM::AdminUI::Config.stats_retries.should eq(5)
    end

    it 'stats_retry_interval' do
      IBM::AdminUI::Config.stats_retry_interval.should eq(300)
    end

    it 'tasks_refresh_interval' do
      IBM::AdminUI::Config.tasks_refresh_interval.should eq(5_000)
    end

    context 'uaa_admin_credentials' do
      it 'uaa_admin_credentials_password' do
        IBM::AdminUI::Config.uaa_admin_credentials_password.should be_nil
      end

      it 'uaa_admin_credentials_username' do
        IBM::AdminUI::Config.uaa_admin_credentials_username.should be_nil
      end
    end

    context 'ui_admin_credentials' do
      it 'ui_admin_credentials_password' do
        IBM::AdminUI::Config.ui_admin_credentials_password.should be_nil
      end

      it 'ui_admin_credentials_username' do
        IBM::AdminUI::Config.ui_admin_credentials_username.should be_nil
      end
    end

    context 'ui_credentials' do
      it 'ui_credentials_password' do
        IBM::AdminUI::Config.ui_credentials_password.should be_nil
      end

      it 'ui_credentials_username' do
        IBM::AdminUI::Config.ui_credentials_username.should be_nil
      end
    end

    it 'varz_discovery_interval' do
      IBM::AdminUI::Config.varz_discovery_interval.should eq(30)
    end
  end
end
