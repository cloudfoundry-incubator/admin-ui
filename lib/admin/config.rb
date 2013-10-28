module IBM
  module AdminUI
    class Config
      DEFAULTS_CONFIG =
      {
        :cloud_controller_discovery_interval =>    300,
        :component_connection_retries        =>      2,
        :log_file_page_size                  => 51_200,
        :nats_discovery_interval             =>     30,
        :nats_discovery_timeout              =>     10,
        :stats_refresh_time                  => 60 * 5,
        :stats_retries                       =>      5,
        :stats_retry_interval                =>    300,
        :tasks_refresh_interval              =>  5_000,
        :varz_discovery_interval             =>     30
      }

      def self.load(config)
        Config.new(config)
      end

      def cloud_controller_discovery_interval
        @config[:cloud_controller_discovery_interval]
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
        @config = DEFAULTS_CONFIG.merge(symbolize_keys(config))
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
end
