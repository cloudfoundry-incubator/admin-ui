require_relative '../spec_helper'

describe AdminUI::Config do
  context 'Single values' do
    before do
      AdminUI::Config.any_instance.stub(:validate)
    end

    it 'bind_address' do
      bind_address = '0.0.0.0'
      config = AdminUI::Config.load('bind_address' => bind_address)
      expect(config.bind_address).to eq(bind_address)
    end

    context 'Values loaded and returned' do
      it 'cloud_controller_discovery_interval' do
        cloud_controller_discovery_interval = 11
        config = AdminUI::Config.load('cloud_controller_discovery_interval' => cloud_controller_discovery_interval)
        expect(config.cloud_controller_discovery_interval).to eq(cloud_controller_discovery_interval)
      end

      it 'cloud_controller_ssl_verify_none' do
        cloud_controller_ssl_verify_none = true
        config = AdminUI::Config.load('cloud_controller_ssl_verify_none' => true)
        expect(config.cloud_controller_ssl_verify_none).to eq(cloud_controller_ssl_verify_none)
      end

      it 'cloud_controller_uri' do
        cloud_controller_uri = 'http://api.localhost'
        config = AdminUI::Config.load('cloud_controller_uri' => cloud_controller_uri)
        expect(config.cloud_controller_uri).to eq(cloud_controller_uri)
      end

      it 'component_connection_retries' do
        component_connection_retries = 22
        config = AdminUI::Config.load('component_connection_retries' => component_connection_retries)
        expect(config.component_connection_retries).to eq(component_connection_retries)
      end

      it 'data_file' do
        data_file = 'data.json'
        config = AdminUI::Config.load('data_file' => data_file)
        expect(config.data_file).to eq(data_file)
      end

      it 'log_file' do
        log_file = 'admin_ui.log'
        config = AdminUI::Config.load('log_file' => log_file)
        expect(config.log_file).to eq(log_file)
      end

      it 'log_file_page_size' do
        log_file_page_size = 33
        config = AdminUI::Config.load('log_file_page_size' => log_file_page_size)
        expect(config.log_file_page_size).to eq(log_file_page_size)
      end

      it 'log_file_sftp_keys' do
        log_file_sftp_keys = ['bogus1.pem', 'bogus2.pem']
        config = AdminUI::Config.load('log_file_sftp_keys' => log_file_sftp_keys)
        expect(config.log_file_sftp_keys).to eq(log_file_sftp_keys)
      end

      it 'log_files' do
        log_files = %w(file1 file2)
        config = AdminUI::Config.load('log_files' => log_files)
        expect(config.log_files).to eq(log_files)
      end

      it 'mbus' do
        mbus = 'nats://nats:c1oudc0w@localhost:14222'
        config = AdminUI::Config.load('mbus' => mbus)
        expect(config.mbus).to eq(mbus)
      end

      it 'monitored_components' do
        monitored_components = ['ALL']
        config = AdminUI::Config.load('monitored_components' => monitored_components)
        expect(config.monitored_components).to eq(monitored_components)
      end

      it 'nats_discovery_interval' do
        nats_discovery_interval = 44
        config = AdminUI::Config.load('nats_discovery_interval' => nats_discovery_interval)
        expect(config.nats_discovery_interval).to eq(nats_discovery_interval)
      end

      it 'nats_discovery_timeout' do
        nats_discovery_timeout = 55
        config = AdminUI::Config.load('nats_discovery_timeout' => nats_discovery_timeout)
        expect(config.nats_discovery_timeout).to eq(nats_discovery_timeout)
      end

      it 'port' do
        port = 55
        config = AdminUI::Config.load('port' => port)
        expect(config.port).to eq(port)
      end

      it 'receiver_emails' do
        receiver_emails = ['bogus@localhost.com']
        config = AdminUI::Config.load('receiver_emails' => receiver_emails)
        expect(config.receiver_emails).to eq(receiver_emails)
      end

      context 'sender_email' do
        let(:sender_email) { { 'server' => 'localhost', 'account' => 'bogus@localhost.com' } }
        let(:config) { AdminUI::Config.load('sender_email' => sender_email) }

        it 'sender_email_account' do
          expect(config.sender_email_account).to eq(sender_email['account'])
        end

        it 'sender_email_server' do
          expect(config.sender_email_server).to eq(sender_email['server'])
        end
      end

      it 'stats_file' do
        stats_file = 'stats.json'
        config = AdminUI::Config.load('stats_file' => stats_file)
        expect(config.stats_file).to eq(stats_file)
      end

      it 'stats_refresh_time' do
        stats_refresh_time = 66
        config = AdminUI::Config.load('stats_refresh_time' => stats_refresh_time)
        expect(config.stats_refresh_time).to eq(stats_refresh_time)
      end

      it 'stats_retries' do
        stats_retries = 77
        config = AdminUI::Config.load('stats_retries' => stats_retries)
        expect(config.stats_retries).to eq(stats_retries)
      end

      it 'stats_retry_interval' do
        stats_retry_interval = 88
        config = AdminUI::Config.load('stats_retry_interval' => stats_retry_interval)
        expect(config.stats_retry_interval).to eq(stats_retry_interval)
      end

      it 'tasks_refresh_interval' do
        tasks_refresh_interval = 99
        config = AdminUI::Config.load('tasks_refresh_interval' => tasks_refresh_interval)
        expect(config.tasks_refresh_interval).to eq(tasks_refresh_interval)
      end

      context 'uaa_admin_credentials' do
        let(:uaa_admin_credentials) { { 'password' => 'uaa_admin_bogus_password', 'username' => 'uaa_admin_bogus_username' } }
        let(:config) { AdminUI::Config.load('uaa_admin_credentials' => uaa_admin_credentials) }

        it 'uaa_admin_credentials_password' do
          expect(config.uaa_admin_credentials_password).to eq(uaa_admin_credentials['password'])
        end

        it 'uaa_admin_credentials_username' do
          expect(config.uaa_admin_credentials_username).to eq(uaa_admin_credentials['username'])
        end
      end

      context 'ui_admin_credentials' do
        let(:ui_admin_credentials) { { 'password' => 'ui_admin_bogus_password', 'username' => 'ui_admin_bogus_username' } }
        let(:config) { AdminUI::Config.load('ui_admin_credentials' => ui_admin_credentials) }

        it 'ui_admin_credentials_password' do
          expect(config.ui_admin_credentials_password).to eq(ui_admin_credentials['password'])
        end

        it 'ui_admin_credentials_username' do
          expect(config.ui_admin_credentials_username).to eq(ui_admin_credentials['username'])
        end
      end

      context 'ui_credentials' do
        let(:ui_credentials) { { 'password' => 'ui_bogus_password', 'username' => 'ui_bogus_username' } }
        let(:config) { AdminUI::Config.load('ui_credentials' => ui_credentials) }

        it 'ui_credentials_password' do
          expect(config.ui_credentials_password).to eq(ui_credentials['password'])
        end

        it 'ui_credentials_username' do
          expect(config.ui_credentials_username).to eq(ui_credentials['username'])
        end
      end

      it 'varz_discovery_interval' do
        varz_discovery_interval = 111
        config = AdminUI::Config.load('varz_discovery_interval' => varz_discovery_interval)
        expect(config.varz_discovery_interval).to eq(varz_discovery_interval)
      end
    end

    context 'Defaults' do
      let(:config) { AdminUI::Config.load({}) }

      it 'bind_address' do
        expect(config.bind_address).to eq('127.0.0.1')
      end

      it 'cloud_controller_discovery_interval' do
        expect(config.cloud_controller_discovery_interval).to eq(300)
      end

      it 'cloud_controller_ssl_verify_none' do
        expect(config.cloud_controller_ssl_verify_none).to eq(false)
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

      it 'log_file_sftp_keys' do
        expect(config.log_file_sftp_keys).to eq([])
      end

      it 'log_files' do
        expect(config.log_files).to eq([])
      end

      it 'mbus' do
        expect(config.mbus).to be_nil
      end

      it 'monitored_components' do
        expect(config.monitored_components).to eq([])
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
        expect(config.receiver_emails).to eq([])
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

  context 'Errors' do
    let(:config) do
      {
        :cloud_controller_uri  => 'http://api.localhost',
        :data_file             => '/tmp/admin_ui_data.json',
        :log_file              => '/tmp/admin_ui.log',
        :mbus                  => 'nats://nats:c1oudc0w@10.10.10.10:4222',
        :port                  => 8070,
        :stats_file            => '/tmp/admin_ui_stats.json',
        :uaa_admin_credentials => { :username => 'uaa_user', :password => 'uaa_password' },
        :ui_credentials        => { :username => 'ui_user', :password => 'ui_user_password' },
        :ui_admin_credentials  => { :username => 'ui_admin_user', :password => 'ui_admin_user_password' }
      }
    end

    it 'base works' do
      AdminUI::Config.load(config)
    end

    context 'Invalid value types' do
      it 'bind_address' do
        expect { AdminUI::Config.load(config.merge(:bind_address => 22)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'cloud_controller_discovery_interval' do
        expect { AdminUI::Config.load(config.merge(:cloud_controller_discovery_interval => 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'cloud_controller_ssl_verify_none' do
        expect { AdminUI::Config.load(config.merge(:cloud_controller_ssl_verify_none => 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'cloud_controller_uri' do
        expect { AdminUI::Config.load(config.merge(:cloud_controller_uri => 5)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'component_connection_retries' do
        expect { AdminUI::Config.load(config.merge(:component_connection_retries => 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'data_file' do
        expect { AdminUI::Config.load(config.merge(:data_file => 5)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'log_file' do
        expect { AdminUI::Config.load(config.merge(:log_file => 5)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'log_file_page_size' do
        expect { AdminUI::Config.load(config.merge(:log_file_page_size => 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'log_file_sftp_keys' do
        expect { AdminUI::Config.load(config.merge(:log_file_sftp_keys => [1, 2, 3])) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'log_files' do
        expect { AdminUI::Config.load(config.merge(:log_files => [1, 2, 3])) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'mbus' do
        expect { AdminUI::Config.load(config.merge(:mbus => 5)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'monitored_components' do
        expect { AdminUI::Config.load(config.merge(:monitored_components => [1, 2, 3])) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'nats_discovery_interval' do
        expect { AdminUI::Config.load(config.merge(:nats_discovery_interval => 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'nats_discovery_timeout' do
        expect { AdminUI::Config.load(config.merge(:nats_discovery_timeout => 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'port' do
        expect { AdminUI::Config.load(config.merge(:port => 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'receiver_emails' do
        expect { AdminUI::Config.load(config.merge(:receiver_emails => [1, 2, 3])) }.to raise_error(Membrane::SchemaValidationError)
      end

      context 'sender_email' do
        it 'sender_email_account' do
          expect { AdminUI::Config.load(config.merge(:sender_email => { :account => 5, :server => 'hi'  })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'sender_email_server' do
          expect { AdminUI::Config.load(config.merge(:sender_email => { :account => 'hi', :server => 5  })) }.to raise_error(Membrane::SchemaValidationError)
        end
      end

      it 'stats_file' do
        expect { AdminUI::Config.load(config.merge(:stats_file => 5)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'stats_refresh_time' do
        expect { AdminUI::Config.load(config.merge(:stats_refresh_time => 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'stats_retries' do
        expect { AdminUI::Config.load(config.merge(:stats_retries => 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'stats_retry_interval' do
        expect { AdminUI::Config.load(config.merge(:stats_retry_interval => 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'tasks_refresh_interval' do
        expect { AdminUI::Config.load(config.merge(:tasks_refresh_interval => 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      context 'uaa_admin_credentials' do
        it 'uaa_admin_credentials_password' do
          expect { AdminUI::Config.load(config.merge(:uaa_admin_credentials => { :password => 5, :username => 'hi' })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'uaa_admin_credentials_username' do
          expect { AdminUI::Config.load(config.merge(:uaa_admin_credentials => { :password => 'hi', :username => 5 })) }.to raise_error(Membrane::SchemaValidationError)
        end
      end

      context 'ui_admin_credentials' do
        it 'ui_admin_credentials_password' do
          expect { AdminUI::Config.load(config.merge(:ui_admin_credentials => { :password => 5, :username => 'hi' })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'ui_admin_credentials_username' do
          expect { AdminUI::Config.load(config.merge(:ui_admin_credentials => { :password => 'hi', :username => 5 })) }.to raise_error(Membrane::SchemaValidationError)
        end
      end

      context 'ui_credentials' do
        it 'ui_credentials_password' do
          expect { AdminUI::Config.load(config.merge(:ui_credentials => { :password => 5, :username => 'hi' })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'ui_credentials_username' do
          expect { AdminUI::Config.load(config.merge(:ui_credentials => { :password => 'hi', :username => 5 })) }.to raise_error(Membrane::SchemaValidationError)
        end
      end

      it 'varz_discovery_interval' do
        expect { AdminUI::Config.load(config.merge(:varz_discovery_interval => 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end
    end

    context 'Missing values' do
      it 'cloud_controller_discovery_interval' do
        expect { AdminUI::Config.load(config.merge(:cloud_controller_discovery_interval => nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'cloud_controller_ssl_verify_none' do
        expect { AdminUI::Config.load(config.merge(:cloud_controller_ssl_verify_none => nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'cloud_controller_uri' do
        expect { AdminUI::Config.load(config.merge(:cloud_controller_uri => nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'data_file' do
        expect { AdminUI::Config.load(config.merge(:data_file => nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'log_file' do
        expect { AdminUI::Config.load(config.merge(:log_file => nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'mbus' do
        expect { AdminUI::Config.load(config.merge(:mbus => nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'port' do
        expect { AdminUI::Config.load(config.merge(:port => nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'stats_file' do
        expect { AdminUI::Config.load(config.merge(:stats_file => nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      context 'uaa_admin_credentials' do
        it 'uaa_admin_credentials_password' do
          expect { AdminUI::Config.load(config.merge(:uaa_admin_credentials => { :username => 'hi' })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'uaa_admin_credentials_username' do
          expect { AdminUI::Config.load(config.merge(:uaa_admin_credentials => { :password => 'hi' })) }.to raise_error(Membrane::SchemaValidationError)
        end
      end

      context 'ui_admin_credentials' do
        it 'ui_admin_credentials_password' do
          expect { AdminUI::Config.load(config.merge(:ui_admin_credentials => { :username => 'hi' })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'ui_admin_credentials_username' do
          expect { AdminUI::Config.load(config.merge(:ui_admin_credentials => { :password => 'hi' })) }.to raise_error(Membrane::SchemaValidationError)
        end
      end

      context 'ui_credentials' do
        it 'ui_credentials_password' do
          expect { AdminUI::Config.load(config.merge(:ui_credentials => { :username => 'hi' })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'ui_credentials_username' do
          expect { AdminUI::Config.load(config.merge(:ui_credentials => { :password => 'hi' })) }.to raise_error(Membrane::SchemaValidationError)
        end
      end
    end
  end
end
