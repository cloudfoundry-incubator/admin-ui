require_relative '../spec_helper'

describe AdminUI::Config do
  include ConfigHelper

  context 'Single values' do
    before do
      config_stub
    end

    it 'bind_address' do
      bind_address = '0.0.0.0'
      config = AdminUI::Config.load('bind_address' => bind_address)
      expect(config.bind_address).to eq(bind_address)
    end

    context 'Values loaded and returned' do
      it 'ccdb_uri' do
        ccdb_uri = 'sqlite://bogus.db'
        config = AdminUI::Config.load('ccdb_uri' => ccdb_uri)
        expect(config.ccdb_uri).to eq(ccdb_uri)
      end

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

      it 'cookie_key' do
        cookie_key = 'mytestingkey'
        config = AdminUI::Config.load('cookie_key' => cookie_key)
        expect(config.cookie_key).to eq(cookie_key)
      end

      it 'cookie_secret' do
        cookie_secret = 'mytestingsecret'
        config = AdminUI::Config.load('cookie_secret' => cookie_secret)
        expect(config.cookie_secret).to eq(cookie_secret)
      end

      it 'cookie_secure' do
        cookie_secure = true
        config = AdminUI::Config.load('cookie_secure' => cookie_secure)
        expect(config.cookie_secure).to eq(cookie_secure)
      end

      it 'data_file' do
        data_file = 'data.json'
        config = AdminUI::Config.load('data_file' => data_file)
        expect(config.data_file).to eq(data_file)
      end

      it 'db_uri' do
        db_uri = 'sqlite:///tmp/admin_ui_store.db'
        config = AdminUI::Config.load('db_uri' => db_uri)
        expect(config.db_uri).to eq(db_uri)
      end

      it 'display_encrypted_values' do
        display_encrypted_values = false
        config = AdminUI::Config.load('display_encrypted_values' => false)
        expect(config.display_encrypted_values).to eq(display_encrypted_values)
      end

      it 'doppler_data_file' do
        doppler_data_file = 'doppler_data.json'
        config = AdminUI::Config.load('doppler_data_file' => doppler_data_file)
        expect(config.doppler_data_file).to eq(doppler_data_file)
      end

      it 'doppler_logging_endpoint_override' do
        doppler_logging_endpoint_override = 'wss://doppler_logging_endpoint_override.com'
        config = AdminUI::Config.load('doppler_logging_endpoint_override' => doppler_logging_endpoint_override)
        expect(config.doppler_logging_endpoint_override).to eq(doppler_logging_endpoint_override)
      end

      it 'doppler_reconnect_delay' do
        doppler_reconnect_delay = 333
        config = AdminUI::Config.load('doppler_reconnect_delay' => doppler_reconnect_delay)
        expect(config.doppler_reconnect_delay).to eq(doppler_reconnect_delay)
      end

      it 'doppler_rollup_interval' do
        doppler_rollup_interval = 33
        config = AdminUI::Config.load('doppler_rollup_interval' => doppler_rollup_interval)
        expect(config.doppler_rollup_interval).to eq(doppler_rollup_interval)
      end

      it 'doppler_ssl_verify_none' do
        doppler_ssl_verify_none = true
        config = AdminUI::Config.load('doppler_ssl_verify_none' => true)
        expect(config.doppler_ssl_verify_none).to eq(doppler_ssl_verify_none)
      end

      it 'event_days' do
        event_days = 35
        config = AdminUI::Config.load('event_days' => event_days)
        expect(config.event_days).to eq(event_days)
      end

      it 'http_debug' do
        http_debug = true
        config = AdminUI::Config.load('http_debug' => http_debug)
        expect(config.http_debug).to eq(http_debug)
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
        log_files = %w[file1 file2]
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

      context 'nats_tls is in use' do
        let(:nats_tls) { { 'ca_file' => 'ca_file', 'cert_chain_file' => 'cert_chain_file', 'private_key_file' => 'private_key_file', 'verify_peer' => true } }
        let(:config) { AdminUI::Config.load('nats_tls' => nats_tls) }

        it 'nats_tls_ca_file' do
          expect(config.nats_tls_ca_file).to eq('ca_file')
        end

        it 'nats_tls_cert_chain_file' do
          expect(config.nats_tls_cert_chain_file).to eq('cert_chain_file')
        end

        it 'nats_tls_private_key_file' do
          expect(config.nats_tls_private_key_file).to eq('private_key_file')
        end

        it 'nats_tls_verify_peer' do
          expect(config.nats_tls_verify_peer).to eq(true)
        end
      end

      it 'port' do
        port = 55
        config = AdminUI::Config.load('port' => port)
        expect(config.port).to eq(port)

        # PORT environment variable testing
        env = '54'
        ENV['PORT'] = env
        expect(config.port).to eq(env)

        # Unset PORT environment variable testing
        ENV['PORT'] = nil
        expect(config.port).to eq(port)
      end

      it 'receiver_emails' do
        receiver_emails = ['bogus@localhost.com']
        config = AdminUI::Config.load('receiver_emails' => receiver_emails)
        expect(config.receiver_emails).to eq(receiver_emails)
      end

      it 'secured_client_connection' do
        config = AdminUI::Config.load('secured_client_connection' => true)
        expect(config.secured_client_connection).to eq(true)
      end

      context 'sender_email' do
        let(:sender_email) do
          {
            'server'   => 'localhost',
            'port'     => 25,
            'domain'   => 'localhost',
            'account'  => 'bogus@localhost.com',
            'secret'   => 'my password',
            'authtype' => 'login'
          }
        end
        let(:config) { AdminUI::Config.load('sender_email' => sender_email) }

        it 'sender_email_account' do
          expect(config.sender_email_account).to eq(sender_email['account'])
        end

        it 'sender_email_authtype' do
          expect(config.sender_email_authtype).to eq(sender_email['authtype'].to_sym)
        end

        it 'sender_email_domain' do
          expect(config.sender_email_domain).to eq(sender_email['domain'])
        end

        it 'sender_email_port' do
          expect(config.sender_email_port).to eq(sender_email['port'])
        end

        it 'sender_email_secret' do
          expect(config.sender_email_secret).to eq(sender_email['secret'])
        end

        it 'sender_email_server' do
          expect(config.sender_email_server).to eq(sender_email['server'])
        end
      end

      context 'ssl is in use' do
        let(:ssl) { { 'certificate_file_path' => 'certificate_file_path', 'private_key_file_path' => 'private_key_file_path', 'private_key_pass_phrase' => 'private_key_pass_phrase', 'max_session_idle_length' => 4 } }
        let(:config) { AdminUI::Config.load('ssl' => ssl) }

        it 'ssl_certificate_file_path' do
          expect(config.ssl_certificate_file_path).to eq('certificate_file_path')
        end

        it 'ssl_private_key_file_path' do
          expect(config.ssl_private_key_file_path).to eq('private_key_file_path')
        end

        it 'ssl_private_key_pass_phrase' do
          expect(config.ssl_private_key_pass_phrase).to eq('private_key_pass_phrase')
        end

        it 'max_session_idle_length' do
          expect(config.ssl_max_session_idle_length).to eq(4)
          expect(AdminUI::Config.ssl_max_session_idle_length).to eq(4)
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
        expect(config.stats_refresh_schedules).to eq(['6 1 * * *'])
      end

      it 'stats_refresh_time with mix use of range and sequence' do
        stats_schedule_spec = ['0 1,4-8 * * *', '0 12-17 * * 1-5']
        config = AdminUI::Config.load('stats_refresh_schedules' => stats_schedule_spec)
        expect(config.stats_refresh_schedules).to eq(['0 1,4-8 * * *', '0 12-17 * * 1-5'])
      end

      it 'stats_refresh_time' do
        stats_schedule_spec = ['0 1,4,8 * * *', '0 12-17 * * 1-5']
        config = AdminUI::Config.load('stats_refresh_schedules' => stats_schedule_spec)
        expect(config.stats_refresh_schedules).to eq(['0 1,4,8 * * *', '0 12-17 * * 1-5'])
      end

      it 'converts stats_refresh_time to stats_refresh_schedules' do
        schedule_minutes = 30
        config = AdminUI::Config.load('stats_refresh_time' => schedule_minutes)
        expect(config.stats_refresh_schedules).to eq(["#{schedule_minutes} * * * *"])
      end

      it 'converts stats_refresh_time to stats_refresh_schedules - 66+60*24*31*13 minutes (1 year, 1 month, 1 day, 1 hour, 6 mintues into the future)' do
        schedule_minutes = 580_386
        config = AdminUI::Config.load('stats_refresh_time' => schedule_minutes)
        expect(config.stats_refresh_schedules).to eq(['6 1 * * *'])
      end

      it 'converts stats_refresh_time to stats_refresh_schedules - overriding default' do
        stats_refresh_schedules = []
        config = AdminUI::Config.load('stats_refresh_schedules' => stats_refresh_schedules)
        expect(config.stats_refresh_schedules).to eq(stats_refresh_schedules)
      end

      it 'stats_refresh_schedules for predefined schedule - @hourly' do
        stats_refresh_schedules = ['@hourly']
        config = AdminUI::Config.load('stats_refresh_schedules' => stats_refresh_schedules)
        expect(config.stats_refresh_schedules).to eq(['@hourly'])
      end

      it 'stats_refresh_schedules for predefined schedule - @monthly' do
        stats_refresh_schedules = ['@monthly']
        config = AdminUI::Config.load('stats_refresh_schedules' => stats_refresh_schedules)
        expect(config.stats_refresh_schedules).to eq(['@monthly'])
      end

      it 'stats_refresh_schedules for predefined schedule - @yearly' do
        stats_refresh_schedules = ['@yearly']
        config = AdminUI::Config.load('stats_refresh_schedules' => stats_refresh_schedules)
        expect(config.stats_refresh_schedules).to eq(['@yearly'])
      end

      it 'stats_refresh_schedules for predefined schedule - @annually' do
        stats_refresh_schedules = ['@annually']
        config = AdminUI::Config.load('stats_refresh_schedules' => stats_refresh_schedules)
        expect(config.stats_refresh_schedules).to eq(['@annually'])
      end

      it 'has neither stats_refresh_time nor stats_refresh_schedules entry' do
        config = AdminUI::Config.load({})
        expect(config.stats_refresh_schedules.length).to eq(0)
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

      it 'table_height' do
        table_height = '287px'
        config = AdminUI::Config.load('table_height' => table_height)
        expect(config.table_height).to eq(table_height)
      end

      it 'table_page_size' do
        table_page_size = '10'
        config = AdminUI::Config.load('table_page_size' => table_page_size)
        expect(config.table_page_size).to eq(table_page_size)
      end

      it 'uaadb_uri' do
        uaadb_uri = 'sqlite://bogus2.db'
        config = AdminUI::Config.load('uaadb_uri' => uaadb_uri)
        expect(config.uaadb_uri).to eq(uaadb_uri)
      end

      context 'uaa_client' do
        let(:uaa_client) { { 'id' => 'id', 'secret' => 'secret' } }
        let(:config) { AdminUI::Config.load('uaa_client' => uaa_client) }

        it 'uaa_client_id' do
          expect(config.uaa_client_id).to eq(uaa_client['id'])
        end

        it 'uaa_client_secret' do
          expect(config.uaa_client_secret).to eq(uaa_client['secret'])
        end
      end

      context 'uaa_groups_admin' do
        let(:uaa_groups_admin) { %w[admin1 admin2] }
        let(:config) { AdminUI::Config.load('uaa_groups_admin' => uaa_groups_admin) }

        it 'uaa_groups_admin' do
          expect(config.uaa_groups_admin).to eq(uaa_groups_admin)
        end
      end

      context 'uaa_groups_user' do
        let(:uaa_groups_user) { %w[user1 user2] }
        let(:config) { AdminUI::Config.load('uaa_groups_user' => uaa_groups_user) }

        it 'uaa_groups_user' do
          expect(config.uaa_groups_user).to eq(uaa_groups_user)
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
        expect(config.bind_address).to eq('0.0.0.0')
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

      it 'cookie_key' do
        expect(config.cookie_key).to eq('rack.session')
      end

      it 'cookie_secret' do
        expect(config.cookie_secret).to eq('mysecre')
      end

      it 'cookie_secure' do
        expect(config.cookie_secure).to eq(false)
      end

      it 'data_file' do
        expect(config.data_file).to be_nil
      end

      it 'db_uri' do
        expect(config.db_uri).to be_nil
      end

      it 'display_encrypted_values' do
        expect(config.display_encrypted_values).to eq(true)
      end

      it 'doppler_data_file' do
        expect(config.doppler_data_file).to be_nil
      end

      it 'doppler_logging_endpoint_override' do
        expect(config.doppler_logging_endpoint_override).to be_nil
      end

      it 'doppler_reconnect_delay' do
        expect(config.doppler_reconnect_delay).to eq(300)
      end

      it 'doppler_rollup_interval' do
        expect(config.doppler_rollup_interval).to eq(30)
      end

      it 'doppler_ssl_verify_none' do
        expect(config.doppler_ssl_verify_none).to eq(false)
      end

      it 'event_days' do
        expect(config.event_days).to eq(7)
      end

      it 'http_debug' do
        expect(config.http_debug).to eq(false)
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

      context 'nats_tls' do
        it 'nats_tls_ca_file' do
          expect(config.nats_tls_ca_file).to be_nil
        end

        it 'nats_tls_cert_chain_file' do
          expect(config.nats_tls_cert_chain_file).to be_nil
        end

        it 'nats_tls_private_key_file' do
          expect(config.nats_tls_private_key_file).to be_nil
        end

        it 'nats_tls_verify_peer' do
          expect(config.nats_tls_verify_peer).to be_nil
        end
      end

      it 'port' do
        expect(config.port).to be_nil
      end

      it 'receiver_emails' do
        expect(config.receiver_emails).to eq([])
      end

      it 'secured_client_connection' do
        expect(config.secured_client_connection).to eq(false)
      end

      context 'sender_email' do
        it 'sender_email_account' do
          expect(config.sender_email_account).to be_nil
        end

        it 'sender_email_authtype' do
          expect(config.sender_email_authtype).to be_nil
        end

        it 'sender_email_domain' do
          expect(config.sender_email_domain).to be_nil
        end

        it 'sender_email_port' do
          expect(config.sender_email_port).to be_nil
        end

        it 'sender_email_secret' do
          expect(config.sender_email_secret).to be_nil
        end

        it 'sender_email_server' do
          expect(config.sender_email_server).to be_nil
        end
      end

      context 'ssl' do
        it 'ssl_certificate_file_path to be nil' do
          expect(config.ssl_certificate_file_path).to be_nil
        end

        it 'ssl_private_key_file_path' do
          expect(config.ssl_private_key_file_path).to be_nil
        end

        it 'ssl_private_key_pass_phrase' do
          expect(config.ssl_private_key_pass_phrase).to be_nil
        end

        it 'max_session_idle_length' do
          expect(config.ssl_max_session_idle_length).to be_nil
          expect(AdminUI::Config.ssl_max_session_idle_length).to be_nil
        end
      end

      it 'stats_file' do
        expect(config.stats_file).to be_nil
      end

      it 'stats_refresh_schedules' do
        expect(config.stats_refresh_schedules).to eq([])
      end

      it 'stats_retries' do
        expect(config.stats_retries).to eq(5)
      end

      it 'stats_retry_interval' do
        expect(config.stats_retry_interval).to eq(300)
      end

      it 'table_height' do
        expect(config.table_height).to eq('287px')
      end

      it 'table_page_size' do
        expect(config.table_page_size).to eq(10)
      end

      context 'uaa_client' do
        it 'uaa_client_id' do
          expect(config.uaa_client_id).to be_nil
        end

        it 'uaa_client_secret' do
          expect(config.uaa_client_secret).to be_nil
        end
      end

      context 'uaa_groups.admin' do
        it 'uaa_groups_admin' do
          expect(config.uaa_groups_admin).to eq(['admin_ui.admin'])
        end
      end

      context 'uaa_groups_user' do
        it 'uaa_groups_user' do
          expect(config.uaa_groups_user).to eq(['admin_ui.user'])
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
        ccdb_uri:             'sqlite://tmp/ccdb.db',
        cloud_controller_uri: 'http://api.localhost',
        data_file:            '/tmp/admin_ui_data.json',
        db_uri:               'sqlite:///tmp/admin_ui_store.db',
        doppler_data_file:    '/tmp/admin_ui_doppler_data.json',
        log_file:             '/tmp/admin_ui.log',
        mbus:                 'nats://nats:c1oudc0w@10.10.10.10:4222',
        port:                 8070,
        stats_file:           '/tmp/admin_ui_stats.json',
        uaadb_uri:            'sqlite://tmp/uaadb.db',
        uaa_client:           { id: 'id', secret: 'secret' },
        uaa_groups_admin:     ['cloud_controller.admin'],
        uaa_groups_user:      ['cloud_controller.admin']
      }
    end

    it 'base works' do
      AdminUI::Config.load(config)
    end

    context 'Invalid value types' do
      it 'bind_address' do
        expect { AdminUI::Config.load(config.merge(bind_address: 22)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'ccdb_uri' do
        expect { AdminUI::Config.load(config.merge(ccdb_uri: 5)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'cloud_controller_discovery_interval' do
        expect { AdminUI::Config.load(config.merge(cloud_controller_discovery_interval: 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'cloud_controller_ssl_verify_none' do
        expect { AdminUI::Config.load(config.merge(cloud_controller_ssl_verify_none: 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'cloud_controller_uri' do
        expect { AdminUI::Config.load(config.merge(cloud_controller_uri: 5)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'component_connection_retries' do
        expect { AdminUI::Config.load(config.merge(component_connection_retries: 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'cookie_key' do
        expect { AdminUI::Config.load(config.merge(cookie_key: 5)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'cookie_secret' do
        expect { AdminUI::Config.load(config.merge(cookie_secret: 5)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'cookie_secure' do
        expect { AdminUI::Config.load(config.merge(cookie_secure: 5)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'data_file' do
        expect { AdminUI::Config.load(config.merge(data_file: 5)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'db_uri' do
        expect { AdminUI::Config.load(config.merge(db_uri: 5)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'display_encrypted_values' do
        expect { AdminUI::Config.load(config.merge(display_encrypted_values: 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'doppler_data_file' do
        expect { AdminUI::Config.load(config.merge(doppler_data_file: 5)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'doppler_logging_endpoint_override' do
        expect { AdminUI::Config.load(config.merge(doppler_logging_endpoint_override: 5)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'doppler_reconnect_delay' do
        expect { AdminUI::Config.load(config.merge(doppler_reconnect_delay: 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'doppler_rollup_interval' do
        expect { AdminUI::Config.load(config.merge(doppler_rollup_interval: 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'doppler_ssl_verify_none' do
        expect { AdminUI::Config.load(config.merge(doppler_ssl_verify_none: 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'event_days' do
        expect { AdminUI::Config.load(config.merge(event_days: 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'http_debug' do
        expect { AdminUI::Config.load(config.merge(http_debug: 5)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'log_file' do
        expect { AdminUI::Config.load(config.merge(log_file: 5)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'log_file_page_size' do
        expect { AdminUI::Config.load(config.merge(log_file_page_size: 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'log_file_sftp_keys' do
        expect { AdminUI::Config.load(config.merge(log_file_sftp_keys: [1, 2, 3])) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'log_files' do
        expect { AdminUI::Config.load(config.merge(log_files: [1, 2, 3])) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'mbus' do
        expect { AdminUI::Config.load(config.merge(mbus: 5)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'monitored_components' do
        expect { AdminUI::Config.load(config.merge(monitored_components: [1, 2, 3])) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'nats_discovery_interval' do
        expect { AdminUI::Config.load(config.merge(nats_discovery_interval: 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'nats_discovery_timeout' do
        expect { AdminUI::Config.load(config.merge(nats_discovery_timeout: 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      context 'nats_tls' do
        it 'nats_tls_ca_file' do
          expect { AdminUI::Config.load(config.merge(nats_tls: { ca_file: 5 })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'nats_tls_cert_chain_file' do
          expect { AdminUI::Config.load(config.merge(nats_tls: { cert_chain_file: 5 })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'nats_tls_private_key_file' do
          expect { AdminUI::Config.load(config.merge(nats_tls: { private_key_file: 5 })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'nats_tls_verify_peer' do
          expect { AdminUI::Config.load(config.merge(nats_tls: { verify_peer: 5 })) }.to raise_error(Membrane::SchemaValidationError)
        end
      end

      it 'port' do
        expect { AdminUI::Config.load(config.merge(port: 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'receiver_emails' do
        expect { AdminUI::Config.load(config.merge(receiver_emails: [1, 2, 3])) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'secured_client_connection' do
        expect { AdminUI::Config.load(config.merge(secured_client_connection: 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      context 'sender_email' do
        it 'sender_email_account' do
          expect { AdminUI::Config.load(config.merge(sender_email: { account: 5, server: 'hi' })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'sender_email_authtype' do
          expect { AdminUI::Config.load(config.merge(sender_email: { account: 'hi', authtype: 3, server: 'hi' })) }.to raise_error(Membrane::SchemaValidationError)

          expect { AdminUI::Config.load(config.merge(sender_email: { account: 'hi', authtype: 'logon', server: 'hi' })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'sender_email_domain' do
          expect { AdminUI::Config.load(config.merge(sender_email: { account: 'hi', server: 'hi', domain: 3 })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'sender_email_port' do
          expect { AdminUI::Config.load(config.merge(sender_email: { account: 'hi', server: 'hi', port: 'hi' })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'sender_email_secret' do
          expect { AdminUI::Config.load(config.merge(sender_email: { account: 'hi', secret: 3, server: 'hi' })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'sender_email_server' do
          expect { AdminUI::Config.load(config.merge(sender_email: { account: 'hi', server: 5 })) }.to raise_error(Membrane::SchemaValidationError)
        end
      end

      context 'ssl' do
        it 'ssl_certificate_file_path' do
          expect { AdminUI::Config.load(config.merge(ssl: { certificate_file_path: 1, private_key_file_path: 'hi', private_key_pass_phrase: 'hi', max_session_idle_length: 1 })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'ssl_private_key_file_path' do
          expect { AdminUI::Config.load(config.merge(ssl: { certificate_file_path: 'hi', private_key_file_path: 1, private_key_pass_phrase: 'hi', max_session_idle_length: 1 })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'ssl_private_key_pass_phrase' do
          expect { AdminUI::Config.load(config.merge(ssl: { certificate_file_path: 'hi', private_key_file_path: 'hi', private_key_pass_phrase: 1, max_session_idle_length: 1 })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'max_session_idle_length' do
          expect { AdminUI::Config.load(config.merge(ssl: { certificate_file_path: 'hi', private_key_file_path: 'hi', private_key_pass_phrase: 'hi', max_session_idle_length: 'hi' })) }.to raise_error(Membrane::SchemaValidationError)
        end
      end

      it 'stats_file' do
        expect { AdminUI::Config.load(config.merge(stats_file: 5)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'stats_refresh_time' do
        expect { AdminUI::Config.load(config.merge(stats_refresh_time: 'hi')) }.to raise_error(Membrane::SchemaValidationError, '{ stats_refresh_time => Expected instance of Integer, given an instance of String }')
      end

      it 'stats_refresh_schedules' do
        expect { AdminUI::Config.load(config.merge(stats_refresh_schedules: ['hi'])) }.to raise_error(Membrane::SchemaValidationError, '{ stats_refresh_schedules => At index 0: Value hi doesn\'t match regexp /@yearly|@annually|@monthly|@weekly|@daily|@midnight|@hourly|(((((\d+)((,|-)(\d+))*)|(\*))(\s+)){4}+)(((\d+)((,|-)(\d+))*)|(\*))/ }')
      end

      it 'stats_refresh_schedules with specs not compliant to crontab format - extra commma' do
        expect { AdminUI::Config.load(config.merge(stats_refresh_schedules: ['0 1,,2 * * *', '0 12-17 * * 1-5'])) }.to raise_error(Membrane::SchemaValidationError, '{ stats_refresh_schedules => At index 0: Value 0 1,,2 * * * doesn\'t match regexp /@yearly|@annually|@monthly|@weekly|@daily|@midnight|@hourly|(((((\d+)((,|-)(\d+))*)|(\*))(\s+)){4}+)(((\d+)((,|-)(\d+))*)|(\*))/ }')
      end

      it 'stats_refresh_schedules with specs not compliant to crontab format - extra range symbol' do
        expect { AdminUI::Config.load(config.merge(stats_refresh_schedules: ['0 1--2 * * *', '0 12-17 * * 1-5'])) }.to raise_error(Membrane::SchemaValidationError, '{ stats_refresh_schedules => At index 0: Value 0 1--2 * * * doesn\'t match regexp /@yearly|@annually|@monthly|@weekly|@daily|@midnight|@hourly|(((((\d+)((,|-)(\d+))*)|(\*))(\s+)){4}+)(((\d+)((,|-)(\d+))*)|(\*))/ }')
      end

      it 'stats_refresh_schedules with specs not compliant to crontab format - use of step' do
        expect { AdminUI::Config.load(config.merge(stats_refresh_schedules: ['0 /2 * * *', '0 12-17 * * 1-5'])) }.to raise_error(Membrane::SchemaValidationError, '{ stats_refresh_schedules => At index 0: Value 0 /2 * * * doesn\'t match regexp /@yearly|@annually|@monthly|@weekly|@daily|@midnight|@hourly|(((((\d+)((,|-)(\d+))*)|(\*))(\s+)){4}+)(((\d+)((,|-)(\d+))*)|(\*))/ }')
      end

      it 'has both stats_refresh_time and stats_refresh_schedules entry' do
        expect { AdminUI::Config.load(stats_refresh_schedules: ['@daily'], stats_refresh_time: 300) }.to raise_error(Membrane::SchemaValidationError, 'Two mutally exclusive properties, stats_refresh_time and stats_refresh_schedules, are both present in the configuration file. Please remove one of the two properties.')
      end

      it 'stats_retries' do
        expect { AdminUI::Config.load(config.merge(stats_retries: 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'stats_retry_interval' do
        expect { AdminUI::Config.load(config.merge(stats_retry_interval: 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'table_height' do
        expect { AdminUI::Config.load(config.merge(table_height: 5)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'table_page_size' do
        expect { AdminUI::Config.load(config.merge(table_page_size: 6)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'uaadb_uri' do
        expect { AdminUI::Config.load(config.merge(uaadb_uri: 5)) }.to raise_error(Membrane::SchemaValidationError)
      end

      context 'uaa_client' do
        it 'uaa_client_id' do
          expect { AdminUI::Config.load(config.merge(uaa_client: { id: 5, secret: 'secret' })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'uaa_client_secret' do
          expect { AdminUI::Config.load(config.merge(uaa_client: { id: 'id', secret: 5 })) }.to raise_error(Membrane::SchemaValidationError)
        end
      end

      it 'uaa_groups_admin' do
        expect { AdminUI::Config.load(config.merge(uaa_groups_admin: 5)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'uaa_groups_user' do
        expect { AdminUI::Config.load(config.merge(uaa_groups_user: 5)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'varz_discovery_interval' do
        expect { AdminUI::Config.load(config.merge(varz_discovery_interval: 'hi')) }.to raise_error(Membrane::SchemaValidationError)
      end
    end

    context 'Missing values' do
      it 'ccdb_uri' do
        expect { AdminUI::Config.load(config.merge(ccdb_uri: nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'cloud_controller_discovery_interval' do
        expect { AdminUI::Config.load(config.merge(cloud_controller_discovery_interval: nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'cloud_controller_ssl_verify_none' do
        expect { AdminUI::Config.load(config.merge(cloud_controller_ssl_verify_none: nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'cloud_controller_uri' do
        expect { AdminUI::Config.load(config.merge(cloud_controller_uri: nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'data_file' do
        expect { AdminUI::Config.load(config.merge(data_file: nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'db_uri' do
        expect { AdminUI::Config.load(config.merge(db_uri: nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'doppler_data_file' do
        expect { AdminUI::Config.load(config.merge(doppler_data_file: nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'doppler_reconnect_delay' do
        expect { AdminUI::Config.load(config.merge(doppler_reconnect_delay: nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'doppler_rollup_interval' do
        expect { AdminUI::Config.load(config.merge(doppler_rollup_interval: nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'doppler_ssl_verify_none' do
        expect { AdminUI::Config.load(config.merge(doppler_ssl_verify_none: nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'event_days' do
        expect { AdminUI::Config.load(config.merge(event_days: nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'log_file' do
        expect { AdminUI::Config.load(config.merge(log_file: nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'mbus' do
        expect { AdminUI::Config.load(config.merge(mbus: nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      context 'nats_tls' do
        it 'nats_tls_cert_chain_file' do
          expect { AdminUI::Config.load(config.merge(nats_tls: { private_key_file: 'hi' })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'nats_tls_private_key_file' do
          expect { AdminUI::Config.load(config.merge(nats_tls: { cert_chain_file: 'hi' })) }.to raise_error(Membrane::SchemaValidationError)
        end
      end

      it 'port' do
        expect { AdminUI::Config.load(config.merge(port: nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'secured_client_connection' do
        expect { AdminUI::Config.load(config.merge(secured_client_connection: nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'stats_file' do
        expect { AdminUI::Config.load(config.merge(stats_file: nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      context 'ssl' do
        it 'ssl_certificate_file_path' do
          expect { AdminUI::Config.load(config.merge(ssl: { private_key_file_path: 'hi', private_key_pass_phrase: 'hi', max_session_idle_length: 1 })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'ssl_private_key_file_path' do
          expect { AdminUI::Config.load(config.merge(ssl: { certificate_file_path: 'hi', private_key_pass_phrase: 'hi', max_session_idle_length: 1 })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'ssl_private_key_pass_phrase' do
          expect { AdminUI::Config.load(config.merge(ssl: { certificate_file_path: 'hi', private_key_file_path: 'hi', max_session_idle_length: 1 })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'max_session_idle_length' do
          expect { AdminUI::Config.load(config.merge(ssl: { certificate_file_path: 'hi', private_key_file_path: 'hi', private_key_pass_phrase: 'hi' })) }.to raise_error(Membrane::SchemaValidationError)
        end
      end

      it 'uaadb_uri' do
        expect { AdminUI::Config.load(config.merge(uaadb_uri: nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      context 'uaa_client' do
        it 'uaa_client_id' do
          expect { AdminUI::Config.load(config.merge(uaa_client: { secret: 'secret' })) }.to raise_error(Membrane::SchemaValidationError)
        end

        it 'uaa_client_secret' do
          expect { AdminUI::Config.load(config.merge(uaa_client: { id: 'id' })) }.to raise_error(Membrane::SchemaValidationError)
        end
      end

      it 'uaa_groups_admin' do
        expect { AdminUI::Config.load(config.merge(uaa_groups_admin: nil)) }.to raise_error(Membrane::SchemaValidationError)
      end

      it 'uaa_groups_user' do
        expect { AdminUI::Config.load(config.merge(uaa_groups_user: nil)) }.to raise_error(Membrane::SchemaValidationError)
      end
    end
  end
end
