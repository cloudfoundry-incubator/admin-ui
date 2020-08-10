require 'logger'
require 'openssl'
require 'webrick/httprequest'
require 'webrick/https'
require 'webrick/version'
require_relative 'admin/config'
require_relative 'admin/cc'
require_relative 'admin/cc_rest_client'
require_relative 'admin/db/dbstore_migration'
require_relative 'admin/doppler'
require_relative 'admin/email'
require_relative 'admin/event_machine_loop'
require_relative 'admin/login'
require_relative 'admin/log_files'
require_relative 'admin/logger'
require_relative 'admin/nats'
require_relative 'admin/operation'
require_relative 'admin/stats'
require_relative 'admin/varz'
require_relative 'admin/view_models'

module AdminUI
  class Admin
    def initialize(config_hash, testing, start_callback = nil)
      @config_hash    = config_hash
      @testing        = testing
      @start_callback = start_callback

      @running = true
    end

    def start
      setup_traps
      setup_config
      setup_logger
      setup_dbstore
      setup_event_machine_loop
      setup_components

      display_files

      launch_web
    end

    def shutdown
      return unless @running

      @running = false

      @view_models.shutdown
      @stats.shutdown
      @varz.shutdown
      @nats.shutdown
      @doppler.shutdown
      @cc.shutdown
      @event_machine_loop.shutdown

      @view_models.join
      @stats.join
      @varz.join
      @nats.join
      @doppler.join
      @cc.join
      @event_machine_loop.join

      Rack::Handler::WEBrick.shutdown
    end

    private

    def setup_traps
      %w[TERM INT].each do |signal|
        trap(signal) do
          puts "\n\n"
          puts 'Shutting down ...'

          # Synchronize cannot be called from a trap context in ruby 2.x
          thread = Thread.new do
            shutdown
          end
          thread.join

          puts 'Exiting'
          puts "\n"
          exit!
        end
      end
    end

    def setup_config
      @config = Config.load(@config_hash)
    end

    def setup_logger
      @logger = AdminUILogger.new(@config.log_file, Logger::DEBUG)
    end

    def setup_dbstore
      connection = DBStoreMigration.new(@config, @logger, @testing)
      connection.migrate_to_db
    end

    def setup_event_machine_loop
      @event_machine_loop = EventMachineLoop.new(@config, @logger, @testing)
    end

    def setup_components
      email = EMail.new(@config, @logger)

      @client      = CCRestClient.new(@config, @logger)
      @cc          = CC.new(@config, @logger, @testing)
      @doppler     = Doppler.new(@config, @logger, @client, email, @testing)
      @log_files   = LogFiles.new(@config, @logger)
      @login       = Login.new(@config, @logger, @client)
      @nats        = NATS.new(@config, @logger, email, @testing)
      @varz        = VARZ.new(@config, @logger, @nats, @testing)
      @stats       = Stats.new(@config, @logger, @cc, @doppler, @varz, @testing)
      @view_models = ViewModels.new(@config, @logger, @cc, @client, @doppler, @log_files, @stats, @varz, @testing)
      @operation   = Operation.new(@config, @logger, @cc, @client, @doppler, @varz, @view_models, @testing)
    end

    def display_files
      return if @testing

      puts "\n\n"
      puts 'AdminUI...'

      begin
        puts "  #{RUBY_ENGINE}           #{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"
        @logger.info("#{RUBY_ENGINE} #{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}")
      rescue => error
        @logger.error("Unable to display RUBY_ENGINE, RUBY_VERSION or RUBY_PATCHLEVEL: #{error.inspect}")
      end

      puts "  data:          #{@config.data_file}"
      puts "  doppler data:  #{@config.doppler_data_file}"
      puts "  log:           #{@config.log_file}"
      puts "  stats:         #{@config.db_uri}"
      puts "\n"
    end

    def launch_web
      if defined?(WEBrick::HTTPRequest)
        # TODO: Look at moving to Thin to avoid this limitation
        # We have to increase the WEBrick HTTPRequest constant MAX_URI_LENGTH from its defined value of 2083
        # or we will have problems with the jQuery DataTables server side ajax calls causing WEBrick::HTTPStatus::RequestURITooLarge
        WEBrick::HTTPRequest.instance_eval { remove_const :MAX_URI_LENGTH }
        WEBrick::HTTPRequest.const_set('MAX_URI_LENGTH', 10_240)
      end

      # Only show error and fatal messages
      error_logger = Logger.new($stderr)
      error_logger.level = Logger::ERROR

      web_hash =
        {
          AccessLog:          [],
          BindAddress:        @config.bind_address,
          Host:               @config.bind_address, # Newer Rack::Handler::WEBrick requires Host
          DoNotReverseLookup: true,
          Logger:             error_logger,
          Port:               @config.port,
          ServerSoftware:     "WEBrick/#{WEBrick::VERSION} (Ruby/#{RUBY_VERSION}/#{RUBY_RELEASE_DATE})" # Default value includes OpenSSL version which is a security exposure
        }

      web_hash[:StartCallback] = @start_callback if @start_callback

      @logger.debug("config.secured_client_connection: #{@config.secured_client_connection}")

      if @config.secured_client_connection
        pkey  = OpenSSL::PKey::RSA.new(File.open(@config.ssl_private_key_file_path).read, @config.ssl_private_key_pass_phrase)
        cert  = OpenSSL::X509::Certificate.new(File.open(@config.ssl_certificate_file_path).read)
        names = OpenSSL::X509::Name.parse cert.subject.to_s

        web_hash[:SSLCertificate]  = cert
        web_hash[:SSLCertName]     = names
        web_hash[:SSLEnable]       = true
        web_hash[:SSLPrivateKey]   = pkey
        web_hash[:SSLVerifyClient] = OpenSSL::SSL::VERIFY_NONE
      end

      # Delay this require until after config is loaded
      require_relative 'admin/web'

      web = Web.new(@config,
                    @logger,
                    @cc,
                    @client,
                    @doppler,
                    @login,
                    @log_files,
                    @operation,
                    @stats,
                    @varz,
                    @view_models)

      Rack::Handler::WEBrick.run(web, **web_hash)
    end
  end
end
