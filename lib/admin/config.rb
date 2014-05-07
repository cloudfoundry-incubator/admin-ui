require 'cron_parser'
require 'membrane'
require_relative 'utils'

module AdminUI
  class Config
    DEFAULTS_CONFIG =
    {
      :bind_address                        => '127.0.0.1',
      :cloud_controller_discovery_interval =>         300,
      :cloud_controller_ssl_verify_none    =>       false,
      :component_connection_retries        =>           2,
      :log_file_page_size                  =>      51_200,
      :log_file_sftp_keys                  =>          [],
      :log_files                           =>          [],
      :monitored_components                =>          [],
      :nats_discovery_interval             =>          30,
      :nats_discovery_timeout              =>          10,
      :receiver_emails                     =>          [],
      :stats_refresh_schedules             =>          [],
      :stats_retries                       =>           5,
      :stats_retry_interval                =>         300,
      :tasks_refresh_interval              =>       5_000,
      :varz_discovery_interval             =>          30
    }

    def self.schema
      ::Membrane::SchemaParser.parse do
        schema =
        {
          optional(:bind_address)                        => /[^\r\n\t]+/,
          optional(:cloud_controller_discovery_interval) => Integer,
          optional(:cloud_controller_ssl_verify_none)    => bool,
          :cloud_controller_uri                          => %r{(http[s]?://[^\r\n\t]+)},
          optional(:component_connection_retries)        => Integer,
          :data_file                                     => /[^\r\n\t]+/,
          :log_file                                      => /[^\r\n\t]+/,
          optional(:log_file_sftp_keys)                  => [String],
          optional(:log_file_page_size)                  => Integer,
          optional(:log_files)                           => [String],
          :mbus                                          => %r{(nats://[^\r\n\t]+)},
          optional(:monitored_components)                => [/[^\r\n\t]+/],
          optional(:nats_discovery_interval)             => Integer,
          optional(:nats_discovery_timeout)              => Integer,
          :port                                          => Integer,
          optional(:receiver_emails)                     => [/[^\r\n\t]+/],
          optional(:sender_email)                        =>
          {
            :server  => /[^\r\n\t]+/,
            :account => /[^\r\n\t]+/
          },

          :stats_file                                    => /[^\r\n\t]+/,
          optional(:stats_refresh_time)                  => Integer,
          optional(:stats_refresh_schedules)             => [/@yearly|@annually|@monthly|@weekly|@daily|@midnight|@hourly|(((((\d+)((\,|-)(\d+))*)|(\*))([\s]+)){4}+)(((\d+)((\,|-)(\d+))*)|(\*))/],
          optional(:stats_retries)                       => Integer,
          optional(:stats_retry_interval)                => Integer,
          optional(:tasks_refresh_interval)              => Integer,
          :uaa_admin_credentials                         =>
          {
            :username => /[^\r\n\t]+/,
            :password => /[^\r\n\t]+/
          },

          :ui_credentials                                =>
          {
            :username => /[^\r\n\t]+/,
            :password => /[^\r\n\t]+/
          },

          :ui_admin_credentials                          =>
          {
            :username => /[^\r\n\t]+/,
            :password => /[^\r\n\t]+/
          },

          optional(:varz_discovery_interval)             => Integer
        }
        unless schema[:stats_refresh_schedules].nil?
          schema[:stats_refresh_schedules].each do | spec |
            begin
              CronParser.new(spec)
            rescue => error
              raise Membrane::SchemaValidationError, error.inspect
            end
          end
        end
        schema
      end
    end

    def self.load(config)
      Config.new(config).tap(&:validate)
    end

    def validate
      self.class.schema.validate(@config)
    end

    def bind_address
      @config[:bind_address]
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

    def data_file
      @config[:data_file]
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

    def port
      @config[:port]
    end

    def receiver_emails
      @config[:receiver_emails]
    end

    def sender_email_account
      return nil if @config[:sender_email].nil?
      @config[:sender_email][:account]
    end

    def sender_email_server
      return nil if @config[:sender_email].nil?
      @config[:sender_email][:server]
    end

    def stats_file
      @config[:stats_file]
    end

    def stats_refresh_schedules
      @config[:stats_refresh_schedules]
    end

    def stats_refresh_time
      @config[:stats_refresh_time]
    end

    def stats_retries
      @config[:stats_retries]
    end

    def stats_retry_interval
      @config[:stats_retry_interval]
    end

    def tasks_refresh_interval
      @config[:tasks_refresh_interval]
    end

    def uaa_admin_credentials_password
      return nil if @config[:uaa_admin_credentials].nil?
      @config[:uaa_admin_credentials][:password]
    end

    def uaa_admin_credentials_username
      return nil if @config[:uaa_admin_credentials].nil?
      @config[:uaa_admin_credentials][:username]
    end

    def ui_admin_credentials_password
      return nil if @config[:ui_admin_credentials].nil?
      @config[:ui_admin_credentials][:password]
    end

    def ui_admin_credentials_username
      return nil if @config[:ui_admin_credentials].nil?
      @config[:ui_admin_credentials][:username]
    end

    def ui_credentials_password
      return nil if @config[:ui_credentials].nil?
      @config[:ui_credentials][:password]
    end

    def ui_credentials_username
      return nil if @config[:ui_credentials].nil?
      @config[:ui_credentials][:username]
    end

    def varz_discovery_interval
      @config[:varz_discovery_interval]
    end

    private

    def initialize(config)
      user_select = symbolize_keys(config)
      if user_select[:stats_refresh_schedules].nil? && user_select[:stats_refresh_time].nil?
        # when neither properties is present in default.yml, the hard-coded default value of stats_refresh_schedules, which is [], takes effect.
      elsif user_select[:stats_refresh_schedules].nil?
        # this can happen when user deletes the stats_refresh_schedules property from default.yml and add the stats_refresh_time,
        # especially when they swap in an old copy of default.yml
        stats_refresh_time = user_select[:stats_refresh_time]
        begin
          Integer(stats_refresh_time)
        rescue ArgumentError, TypeError
          raise Membrane::SchemaValidationError, 'stats_refresh_time requires an interger for number of minutes from midnight.'
        end
        # convert the stats_refresh_time to stats_refresh_schedules
        user_select[:stats_refresh_schedules] = []
        user_select[:stats_refresh_schedules].push("#{Utils.minutes_in_an_hour(stats_refresh_time)} #{Utils.hours_in_a_day(stats_refresh_time) > 0 ? Utils.hours_in_a_day(stats_refresh_time) : '*' } * * *")
      elsif user_select[:stats_refresh_time].nil?
        # let the mechanism of :stats_refresh_schedules to take effect, so do nothing else.
      else
        fail Membrane::SchemaValidationError, 'Two mutally exclusive properties, stats_refresh_time and stats_refresh_schedules, are both present in the configuration file.  Please remove one of the two properties.'
      end
      @config = DEFAULTS_CONFIG.merge(user_select)
    end

    def symbolize_keys(hash)
      if hash.is_a? Hash
        new_hash = {}
        hash.each { |k, v| new_hash[k.to_sym] = symbolize_keys(v) }
        new_hash
      else
        hash
      end
    end
  end
end
