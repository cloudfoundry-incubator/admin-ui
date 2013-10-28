require_relative '../spec_helper'

describe IBM::AdminUI::Config do
  context 'Values loaded and returned' do
    it 'cloud_controller_discovery_interval' do
      cloud_controller_discovery_interval = 11
      config = IBM::AdminUI::Config.load('cloud_controller_discovery_interval' => cloud_controller_discovery_interval)
      expect(config.cloud_controller_discovery_interval).to eq(cloud_controller_discovery_interval)
    end

    it 'cloud_controller_uri' do
      cloud_controller_uri = 'http://api.localhost'
      config = IBM::AdminUI::Config.load('cloud_controller_uri' => cloud_controller_uri)
      expect(config.cloud_controller_uri).to eq(cloud_controller_uri)
    end

    it 'component_connection_retries' do
      component_connection_retries = 22
      config = IBM::AdminUI::Config.load('component_connection_retries' => component_connection_retries)
      expect(config.component_connection_retries).to eq(component_connection_retries)
    end

    it 'data_file' do
      data_file = 'data.json'
      config = IBM::AdminUI::Config.load('data_file' => data_file)
      expect(config.data_file).to eq(data_file)
    end

    it 'log_file' do
      log_file = 'admin_ui.log'
      config = IBM::AdminUI::Config.load('log_file' => log_file)
      expect(config.log_file).to eq(log_file)
    end

    it 'log_file_page_size' do
      log_file_page_size = 33
      config = IBM::AdminUI::Config.load('log_file_page_size' => log_file_page_size)
      expect(config.log_file_page_size).to eq(log_file_page_size)
    end

    it 'log_files' do
      log_files = %w(file1 file2)
      config = IBM::AdminUI::Config.load('log_files' => log_files)
      expect(config.log_files).to eq(log_files)
    end

    it 'mbus' do
      mbus = 'nats://nats:c1oudc0w@localhost:14222'
      config = IBM::AdminUI::Config.load('mbus' => mbus)
      expect(config.mbus).to eq(mbus)
    end

    it 'monitored_components' do
      monitored_components = ['ALL']
      config = IBM::AdminUI::Config.load('monitored_components' => monitored_components)
      expect(config.monitored_components).to eq(monitored_components)
    end

    it 'nats_discovery_interval' do
      nats_discovery_interval = 44
      config = IBM::AdminUI::Config.load('nats_discovery_interval' => nats_discovery_interval)
      expect(config.nats_discovery_interval).to eq(nats_discovery_interval)
    end

    it 'nats_discovery_timeout' do
      nats_discovery_timeout = 55
      config = IBM::AdminUI::Config.load('nats_discovery_timeout' => nats_discovery_timeout)
      expect(config.nats_discovery_timeout).to eq(nats_discovery_timeout)
    end

    it 'port' do
      port = 55
      config = IBM::AdminUI::Config.load('port' => port)
      expect(config.port).to eq(port)
    end

    it 'receiver_emails' do
      receiver_emails = ['bogus@localhost.com']
      config = IBM::AdminUI::Config.load('receiver_emails' => receiver_emails)
      expect(config.receiver_emails).to eq(receiver_emails)
    end

    context 'sender_email' do
      let(:sender_email) { { 'server' => 'localhost', 'account' => 'bogus@localhost.com' } }
      let(:config) { IBM::AdminUI::Config.load('sender_email' => sender_email) }

      it 'sender_email_account' do
        expect(config.sender_email_account).to eq(sender_email['account'])
      end

      it 'sender_email_server' do
        expect(config.sender_email_server).to eq(sender_email['server'])
      end
    end

    it 'stats_file' do
      stats_file = 'stats.json'
      config = IBM::AdminUI::Config.load('stats_file' => stats_file)
      expect(config.stats_file).to eq(stats_file)
    end

    it 'stats_refresh_time' do
      stats_refresh_time = 66
      config = IBM::AdminUI::Config.load('stats_refresh_time' => stats_refresh_time)
      expect(config.stats_refresh_time).to eq(stats_refresh_time)
    end

    it 'stats_retries' do
      stats_retries = 77
      config = IBM::AdminUI::Config.load('stats_retries' => stats_retries)
      expect(config.stats_retries).to eq(stats_retries)
    end

    it 'stats_retry_interval' do
      stats_retry_interval = 88
      config = IBM::AdminUI::Config.load('stats_retry_interval' => stats_retry_interval)
      expect(config.stats_retry_interval).to eq(stats_retry_interval)
    end

    it 'tasks_refresh_interval' do
      tasks_refresh_interval = 99
      config = IBM::AdminUI::Config.load('tasks_refresh_interval' => tasks_refresh_interval)
      expect(config.tasks_refresh_interval).to eq(tasks_refresh_interval)
    end

    context 'uaa_admin_credentials' do
      let(:uaa_admin_credentials) { { 'password' => 'uaa_admin_bogus_password', 'username' => 'uaa_admin_bogus_username' } }
      let(:config) { IBM::AdminUI::Config.load('uaa_admin_credentials' => uaa_admin_credentials) }

      it 'uaa_admin_credentials_password' do
        expect(config.uaa_admin_credentials_password).to eq(uaa_admin_credentials['password'])
      end

      it 'uaa_admin_credentials_username' do
        expect(config.uaa_admin_credentials_username).to eq(uaa_admin_credentials['username'])
      end
    end

    context 'ui_admin_credentials' do
      let(:ui_admin_credentials) { { 'password' => 'ui_admin_bogus_password', 'username' => 'ui_admin_bogus_username' } }
      let(:config) { IBM::AdminUI::Config.load('ui_admin_credentials' => ui_admin_credentials) }

      it 'ui_admin_credentials_password' do
        expect(config.ui_admin_credentials_password).to eq(ui_admin_credentials['password'])
      end

      it 'ui_admin_credentials_username' do
        expect(config.ui_admin_credentials_username).to eq(ui_admin_credentials['username'])
      end
    end

    context 'ui_credentials' do
      let(:ui_credentials) { { 'password' => 'ui_bogus_password', 'username' => 'ui_bogus_username' } }
      let(:config) { IBM::AdminUI::Config.load('ui_credentials' => ui_credentials) }

      it 'ui_credentials_password' do
        expect(config.ui_credentials_password).to eq(ui_credentials['password'])
      end

      it 'ui_credentials_username' do
        expect(config.ui_credentials_username).to eq(ui_credentials['username'])
      end
    end

    it 'varz_discovery_interval' do
      varz_discovery_interval = 111
      config = IBM::AdminUI::Config.load('varz_discovery_interval' => varz_discovery_interval)
      expect(config.varz_discovery_interval).to eq(varz_discovery_interval)
    end
  end

  context 'Defaults' do
    let(:config) { IBM::AdminUI::Config.load({}) }

    it 'cloud_controller_discovery_interval' do
      expect(config.cloud_controller_discovery_interval).to eq(300)
    end

    it 'cloud_controller_uri' do
      expect(config.cloud_controller_uri).to be_nil
    end

    it 'component_connection_retries' do
      expect(config.component_connection_retries).to eq(2)
    end

    it 'data_file' do
      expect(config.data_file).to be_nil
    end

    it 'log_file' do
      expect(config.log_file).to be_nil
    end

    it 'log_file_page_size' do
      expect(config.log_file_page_size).to eq(51_200)
    end

    it 'log_files' do
      expect(config.log_files).to be_nil
    end

    it 'mbus' do
      expect(config.mbus).to be_nil
    end

    it 'monitored_components' do
      expect(config.monitored_components).to be_nil
    end

    it 'nats_discovery_interval' do
      expect(config.nats_discovery_interval).to eq(30)
    end

    it 'nats_discovery_timeout' do
      expect(config.nats_discovery_timeout).to eq(10)
    end

    it 'port' do
      expect(config.port).to be_nil
    end

    it 'receiver_emails' do
      expect(config.receiver_emails).to be_nil
    end

    context 'sender_email' do
      it 'sender_email_account' do
        expect(config.sender_email_account).to be_nil
      end

      it 'sender_email_server' do
        expect(config.sender_email_server).to be_nil
      end
    end

    it 'stats_file' do
      expect(config.stats_file).to be_nil
    end

    it 'stats_refresh_time' do
      expect(config.stats_refresh_time).to eq(60 * 5)
    end

    it 'stats_retries' do
      expect(config.stats_retries).to eq(5)
    end

    it 'stats_retry_interval' do
      expect(config.stats_retry_interval).to eq(300)
    end

    it 'tasks_refresh_interval' do
      expect(config.tasks_refresh_interval).to eq(5_000)
    end

    context 'uaa_admin_credentials' do
      it 'uaa_admin_credentials_password' do
        expect(config.uaa_admin_credentials_password).to be_nil
      end

      it 'uaa_admin_credentials_username' do
        expect(config.uaa_admin_credentials_username).to be_nil
      end
    end

    context 'ui_admin_credentials' do
      it 'ui_admin_credentials_password' do
        expect(config.ui_admin_credentials_password).to be_nil
      end

      it 'ui_admin_credentials_username' do
        expect(config.ui_admin_credentials_username).to be_nil
      end
    end

    context 'ui_credentials' do
      it 'ui_credentials_password' do
        expect(config.ui_credentials_password).to be_nil
      end

      it 'ui_credentials_username' do
        expect(config.ui_credentials_username).to be_nil
      end
    end

    it 'varz_discovery_interval' do
      expect(config.varz_discovery_interval).to eq(30)
    end
  end
end
