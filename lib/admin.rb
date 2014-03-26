require 'logger'
require_relative 'admin/config'
require_relative 'admin/cc'
require_relative 'admin/cc_rest_client'
require_relative 'admin/email'
require_relative 'admin/log_files'
require_relative 'admin/nats'
require_relative 'admin/stats'
require_relative 'admin/tasks'
require_relative 'admin/varz'
require_relative 'admin/web'

module AdminUI
  class Admin
    def initialize(config_hash)
      @config_hash = config_hash
    end

    def start
      setup_traps
      setup_config
      setup_logger
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

    def setup_components
      client = RestClient.new(@config, @logger)
      email = EMail.new(@config, @logger)
      nats  = NATS.new(@config, @logger, email)

      @cc        = CC.new(@config, @logger, client)
      @log_files = LogFiles.new(@config, @logger)
      @tasks     = Tasks.new(@config, @logger)
      @varz      = VARZ.new(@config, @logger, nats)
      @stats     = Stats.new(@config, @logger, @cc, @varz)
    end

    def display_files
      puts "\n\n"
      puts 'AdminUI files...'
      puts "  data:  #{ @config.data_file }"
      puts "  log:   #{ @config.log_file }"
      puts "  stats: #{ @config.stats_file }"
      puts "\n"
    end

    def launch_web
      web = AdminUI::Web.new(@config,
                             @logger,
                             @cc,
                             @log_files,
                             @stats,
                             @tasks,
                             @varz)

      Rack::Handler::WEBrick.run(web, :Port => @config.port, :BindAddress => @config.bind_address)
    end
  end
end
