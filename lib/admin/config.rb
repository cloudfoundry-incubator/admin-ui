require 'cron_parser'
require 'membrane'
require_relative 'utils'

module AdminUI
  class Config
    DEFAULTS_CONFIG =
      {
        # rubocop:disable Layout/HashAlignment
        bind_address:                                 '0.0.0.0',
        cloud_controller_discovery_interval:                300,
        cloud_controller_ssl_verify_none:                 false,
        component_connection_retries:                         2,
        cookie_key:                              'rack.session',
        cookie_secret:                                'mysecre',
        cookie_secure:                                    false,
        display_encrypted_values:                          true,
        doppler_reconnect_delay:                            300,
        doppler_rollup_interval:                             30,
        doppler_ssl_verify_none:                          false,
        event_days:                                           7,
        http_debug:                                       false,
        log_file_page_size:                              51_200,
        log_file_sftp_keys:                                  [],
        log_files:                                           [],
        monitored_components:                                [],
        nats_discovery_interval:                             30,
        nats_discovery_timeout:                              10,
        receiver_emails:                                     [],
        secured_client_connection:                        false,
        stats_refresh_schedules:                  ['0 5 * * *'],
        stats_retries:                                        5,
        stats_retry_interval:                               300,
        table_height:                                   '287px',
        table_page_size:                                     10,
        uaa_groups_admin:                    ['admin_ui.admin'],
        uaa_groups_user:                      ['admin_ui.user'],
        varz_discovery_interval:                             30
        # rubocop:enable Layout/HashAlignment
      }.freeze

    def self.schema
      ::Membrane::SchemaParser.parse do
        schema =
          {
            optional(:bind_address)                        => /[^\r\n\t]+/,
            ccdb_uri:                                         /[^\r\n\t]+/,
            optional(:cloud_controller_discovery_interval) => Integer,
            optional(:cloud_controller_ssl_verify_none)    => bool,
            cloud_controller_uri:                             %r{(https?://[^\r\n\t]+)},
            optional(:component_connection_retries)        => Integer,
            optional(:cookie_key)                          => /[^\r\n\t]+/,
            optional(:cookie_secret)                       => /[^\r\n\t]+/,
            optional(:cookie_secure)                       => bool,
            data_file:                                        /[^\r\n\t]+/,
            db_uri:                                           /[^\r\n\t]+/,
            optional(:display_encrypted_values)            => bool,
            doppler_data_file:                                /[^\r\n\t]+/,
            optional(:doppler_logging_endpoint_override)   => String,
            optional(:doppler_reconnect_delay)             => Integer,
            optional(:doppler_rollup_interval)             => Integer,
            optional(:doppler_ssl_verify_none)             => bool,
            optional(:event_days)                          => Integer,
            optional(:http_debug)                          => bool,
            log_file:                                         /[^\r\n\t]+/,
            optional(:log_file_sftp_keys)                  => [String],
            optional(:log_file_page_size)                  => Integer,
            optional(:log_files)                           => [String],
            mbus:                                             %r{(nats://[^\r\n\t]+)},
            optional(:monitored_components)                => [/[^\r\n\t]+/],
            optional(:nats_discovery_interval)             => Integer,
            optional(:nats_discovery_timeout)              => Integer,
            optional(:nats_tls)                            =>
            {
              optional(:ca_file)     => String,
              cert_chain_file:          String,
              private_key_file:         String,
              optional(:verify_peer) => bool
            },
            port:                                             Integer,
            optional(:receiver_emails)                     => [/[^\r\n\t]+/],
            optional(:sender_email)                        =>
            {
              server:                /[^\r\n\t]+/,
              optional(:port)     => Integer,
              optional(:domain)   => /[^\r\n\t]+/,
              account:               /[^\r\n\t]+/,
              optional(:secret)   => String,
              optional(:authtype) => enum('plain', 'login', 'cram_md5')
            },
            secured_client_connection:                        bool,
            optional(:ssl)                                 =>
            {
              certificate_file_path:   String,
              private_key_file_path:   String,
              private_key_pass_phrase: String,
              max_session_idle_length: Integer
            },
            optional(:stats_file)                          => /[^\r\n\t]+/,
            optional(:stats_refresh_time)                  => Integer,
            optional(:stats_refresh_schedules)             => [/@yearly|@annually|@monthly|@weekly|@daily|@midnight|@hourly|(((((\d+)((,|-)(\d+))*)|(\*))(\s+)){4}+)(((\d+)((,|-)(\d+))*)|(\*))/],
            optional(:stats_retries)                       => Integer,
            optional(:stats_retry_interval)                => Integer,
            optional(:table_height)                        => /[^\r\n\t]+/,
            optional(:table_page_size)                     => enum(5, 10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10_000),
            uaa_client:
            {
              id:     /[^\r\n\t]+/,
              secret: /[^\r\n\t]+/
            },
            uaadb_uri:                            /[^\r\n\t]+/,
            uaa_groups_admin:                     [/[^\r\n\t]+/],
            uaa_groups_user:                      [/[^\r\n\t]+/],
            optional(:varz_discovery_interval) => Integer
          }

        schema[:stats_refresh_schedules]&.each do |spec|
          CronParser.new(spec)
        rescue => error
          raise Membrane::SchemaValidationError, error.inspect
        end
        schema
      end
    end

    def self.load(config)
      # pre-processing: work on deprecated properties
      filtered_select = Utils.symbolize_keys(config)
      if filtered_select[:stats_refresh_schedules].nil? && filtered_select[:stats_refresh_time].nil?
        filtered_select[:stats_refresh_schedules] = []
      elsif filtered_select[:stats_refresh_schedules].nil?
        to_convert_stats_refresh_time = true
        filtered_select[:stats_refresh_schedules] = [] # this is to override default value of ['0 5 * * *']
      elsif filtered_select[:stats_refresh_time].nil?
        # let the mechanism of :stats_refresh_schedules to take effect, so do nothing else.
      else
        raise Membrane::SchemaValidationError, 'Two mutally exclusive properties, stats_refresh_time and stats_refresh_schedules, are both present in the configuration file. Please remove one of the two properties.'
      end

      config_instance = Config.new(filtered_select).tap(&:validate)
      # post init processing: convert stats_fresh_time
      if to_convert_stats_refresh_time == true
        stats_refresh_time = filtered_select[:stats_refresh_time]
        config_instance.stats_refresh_schedules.push("#{Utils.minutes_in_an_hour(stats_refresh_time)} #{Utils.hours_in_a_day(stats_refresh_time).positive? ? Utils.hours_in_a_day(stats_refresh_time) : '*'} * * *")
      end

      # In order to allow class load of Web to use these values, they have to be static
      # rubocop:disable Style/ClassVars
      @@cookie_key                  = config_instance.cookie_key
      @@cookie_secret               = config_instance.cookie_secret
      @@cookie_secure               = config_instance.cookie_secure
      @@secured_client_connection   = config_instance.secured_client_connection
      @@ssl_max_session_idle_length = config_instance.ssl_max_session_idle_length
      # rubocop:enable Style/ClassVars

      config_instance
    end

    def self.cookie_key
      @@cookie_key
    end

    def self.cookie_secret
      @@cookie_secret
    end

    def self.cookie_secure
      @@cookie_secure
    end

    def self.secured_client_connection
      @@secured_client_connection
    end

    def self.ssl_max_session_idle_length
      @@ssl_max_session_idle_length
    end

    def validate
      self.class.schema.validate(@config)
    end

    def bind_address
      @config[:bind_address]
    end

    def ccdb_uri
      @config[:ccdb_uri]
    end

    def cloud_controller_discovery_interval
      @config[:cloud_controller_discovery_interval]
    end

    def cloud_controller_ssl_verify_none
      @config[:cloud_controller_ssl_verify_none]
    end

    def cloud_controller_uri
      @config[:cloud_controller_uri]
    end

    def component_connection_retries
      @config[:component_connection_retries]
    end

    def cookie_key
      @config[:cookie_key]
    end

    def cookie_secret
      @config[:cookie_secret]
    end

    def cookie_secure
      @config[:cookie_secure]
    end

    def data_file
      @config[:data_file]
    end

    def db_uri
      @config[:db_uri]
    end

    def display_encrypted_values
      @config[:display_encrypted_values]
    end

    def doppler_data_file
      @config[:doppler_data_file]
    end

    def doppler_logging_endpoint_override
      @config[:doppler_logging_endpoint_override]
    end

    def doppler_reconnect_delay
      @config[:doppler_reconnect_delay]
    end

    def doppler_rollup_interval
      @config[:doppler_rollup_interval]
    end

    def doppler_ssl_verify_none
      @config[:doppler_ssl_verify_none]
    end

    def event_days
      @config[:event_days]
    end

    def http_debug
      @config[:http_debug]
    end

    def log_file
      @config[:log_file]
    end

    def log_file_page_size
      @config[:log_file_page_size]
    end

    def log_file_sftp_keys
      @config[:log_file_sftp_keys]
    end

    def log_files
      @config[:log_files]
    end

    def mbus
      @config[:mbus]
    end

    def monitored_components
      @config[:monitored_components]
    end

    def nats_discovery_interval
      @config[:nats_discovery_interval]
    end

    def nats_discovery_timeout
      @config[:nats_discovery_timeout]
    end

    def nats_tls_ca_file
      return nil if @config[:nats_tls].nil?

      @config[:nats_tls][:ca_file]
    end

    def nats_tls_cert_chain_file
      return nil if @config[:nats_tls].nil?

      @config[:nats_tls][:cert_chain_file]
    end

    def nats_tls_private_key_file
      return nil if @config[:nats_tls].nil?

      @config[:nats_tls][:private_key_file]
    end

    def nats_tls_verify_peer
      return nil if @config[:nats_tls].nil?

      @config[:nats_tls][:verify_peer]
    end

    def port
      # If running as a Cloud Foundry application, get the port from the environment.
      ENV['PORT'] || @config[:port]
    end

    def receiver_emails
      @config[:receiver_emails]
    end

    def secured_client_connection
      @config[:secured_client_connection]
    end

    def sender_email_account
      return nil if @config[:sender_email].nil?

      @config[:sender_email][:account]
    end

    def sender_email_authtype
      return nil if @config[:sender_email].nil?

      @config[:sender_email][:authtype]&.to_sym
    end

    def sender_email_domain
      return nil if @config[:sender_email].nil?

      @config[:sender_email][:domain] || 'localhost'
    end

    def sender_email_port
      return nil if @config[:sender_email].nil?

      @config[:sender_email][:port] || 25
    end

    def sender_email_secret
      return nil if @config[:sender_email].nil?

      @config[:sender_email][:secret]
    end

    def sender_email_server
      return nil if @config[:sender_email].nil?

      @config[:sender_email][:server]
    end

    def ssl_certificate_file_path
      return nil if @config[:ssl].nil?

      @config[:ssl][:certificate_file_path]
    end

    def ssl_max_session_idle_length
      return nil if @config[:ssl].nil?

      @config[:ssl][:max_session_idle_length]
    end

    def ssl_private_key_file_path
      return nil if @config[:ssl].nil?

      @config[:ssl][:private_key_file_path]
    end

    def ssl_private_key_pass_phrase
      return nil if @config[:ssl].nil?

      @config[:ssl][:private_key_pass_phrase]
    end

    def stats_file
      @config[:stats_file]
    end

    def stats_refresh_schedules
      @config[:stats_refresh_schedules]
    end

    def stats_retries
      @config[:stats_retries]
    end

    def stats_retry_interval
      @config[:stats_retry_interval]
    end

    def table_height
      @config[:table_height]
    end

    def table_page_size
      @config[:table_page_size]
    end

    def uaa_client_id
      return nil if @config[:uaa_client].nil?

      @config[:uaa_client][:id]
    end

    def uaa_client_secret
      return nil if @config[:uaa_client].nil?

      @config[:uaa_client][:secret]
    end

    def uaadb_uri
      @config[:uaadb_uri]
    end

    def uaa_groups_admin
      @config[:uaa_groups_admin]
    end

    def uaa_groups_user
      @config[:uaa_groups_user]
    end

    def varz_discovery_interval
      @config[:varz_discovery_interval]
    end

    private

    def initialize(config)
      @config = DEFAULTS_CONFIG.merge(Utils.symbolize_keys(config))
    end
  end
end
