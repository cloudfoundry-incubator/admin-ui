require 'logger'
require 'openssl'
require 'webrick/httprequest'
require 'webrick/https'
require_relative 'admin/config'
require_relative 'admin/cc'
require_relative 'admin/cc_rest_client'
require_relative 'admin/db/dbstore_migration'
require_relative 'admin/email'
require_relative 'admin/login'
require_relative 'admin/log_files'
require_relative 'admin/nats'
require_relative 'admin/operation'
require_relative 'admin/secure_web'
require_relative 'admin/stats'
require_relative 'admin/tasks'
require_relative 'admin/varz'
require_relative 'admin/view_models'
require_relative 'admin/web'

module AdminUI
  class Admin
    def initialize(config_hash, testing = false)
      @config_hash = config_hash
      @testing     = testing
    end

    def start
      setup_traps
      setup_config
      setup_logger
      setup_dbstore
      setup_components

      display_files

      launch_web
    end

    private

    def setup_traps
      %w(TERM INT).each { |sig| trap(sig) { exit! } }
    end

    def setup_config
      @config = Config.load(@config_hash)
    end

    def setup_logger
      @logger = Logger.new(@config.log_file)
      @logger.level = Logger::DEBUG
    end

    def setup_dbstore
      db_conn = DBStoreMigration.new(@config, @logger)
      db_conn.migrate_to_db
    end

    def setup_components
      client = CCRestClient.new(@config, @logger)
      email  = EMail.new(@config, @logger)
      nats   = NATS.new(@config, @logger, email)

      @cc          = CC.new(@config, @logger, client, @testing)
      @log_files   = LogFiles.new(@config, @logger)
      @login       = Login.new(@config, @logger, client)
      @tasks       = Tasks.new(@config, @logger)
      @varz        = VARZ.new(@config, @logger, nats, @testing)
      @stats       = Stats.new(@config, @logger, @cc, @varz)
      @view_models = ViewModels.new(@config, @logger, @cc, @log_files, @stats, @tasks, @varz)
      @operation   = Operation.new(@config, @logger, @cc, client, @varz, @view_models)
    end

    def display_files
    end

    def launch_web
      if @config.secured_client_connection
        web = AdminUI::SecureWeb.new(@config,
                                     @logger,
                                     @cc,
                                     @login,
                                     @log_files,
                                     @operation,
                                     @stats,
                                     @tasks,
                                     @varz,
                                     @view_models)
      else
        web =       AdminUI::Web.new(@config,
                                     @logger,
                                     @cc,
                                     @login,
                                     @log_files,
                                     @operation,
                                     @stats,
                                     @tasks,
                                     @varz,
                                     @view_models)
      end

      # Only show error and fatal messages
      error_logger = Logger.new(STDERR)
      error_logger.level = Logger::ERROR

      if defined?(WEBrick::HTTPRequest)
        # TODO: Look at moving to Thin to avoid this limitation
        # We have to increase the WEBrick HTTPRequest constant MAX_URI_LENGTH from its defined value of 2083
        # or we will have problems with the jQuery DataTables server side ajax calls causing WEBrick::HTTPStatus::RequestURITooLarge
        WEBrick::HTTPRequest.instance_eval { remove_const :MAX_URI_LENGTH }
        WEBrick::HTTPRequest.const_set('MAX_URI_LENGTH', 10_240)
      end

      if @config.secured_client_connection
        pkey = OpenSSL::PKey::RSA.new(File.open(@config.ssl_private_key_file_path).read, @config.ssl_private_key_pass_phrase)
        cert = OpenSSL::X509::Certificate.new(File.open(@config.ssl_certificate_file_path).read)
        names = OpenSSL::X509::Name.parse cert.subject.to_s
        Rack::Handler::WEBrick.run(web,
                                   :AccessLog          => [],
                                   :BindAddress        => @config.bind_address,
                                   :DoNotReverseLookup => true,
                                   :Logger             => error_logger,
                                   :Port               => @config.port,
                                   :SSLEnable          => true,
                                   :SSLVerifyClient    => OpenSSL::SSL::VERIFY_NONE,
                                   :SSLCertificate     => cert,
                                   :SSLPrivateKey      => pkey,
                                   :SSLCertName        => names
                                  )
      else
        Rack::Handler::WEBrick.run(web,
                                   :AccessLog          => [],
                                   :BindAddress        => @config.bind_address,
                                   :DoNotReverseLookup => true,
                                   :Logger             => error_logger,
                                   :Port               => @config.port
                                  )
      end
    end
  end
end
