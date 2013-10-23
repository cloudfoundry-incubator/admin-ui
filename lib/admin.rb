require 'logger'
require_relative 'admin/config'
require_relative 'admin/cc'
require_relative 'admin/email'
require_relative 'admin/log_files'
require_relative 'admin/nats'
require_relative 'admin/stats'
require_relative 'admin/tasks'
require_relative 'admin/varz'
require_relative 'admin/web'

module IBM::AdminUI
  class Admin
    def initialize(config)
      @config = config
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
      Config.load(@config)
    end

    def setup_logger
      @logger = Logger.new(Config.log_file)
      @logger.level = Logger::DEBUG
    end

    def setup_components
      email = EMail.new(@logger)
      nats  = NATS.new(@logger, email)

      @cc        = CC.new(@logger)
      @log_files = LogFiles.new(@logger)
      @tasks     = Tasks.new(@logger)
      @varz      = VARZ.new(@logger, nats)
      @stats     = Stats.new(@logger, @cc, @varz)
    end

    def display_files
      puts "\n\n"
      puts 'AdminUI files...'
      puts "  data:  #{ Config.data_file }"
      puts "  log:   #{ Config.log_file }"
      puts "  stats: #{ Config.stats_file }"
      puts "\n"
    end

    def launch_web
      web = IBM::AdminUI::Web.new(@logger,
                                  @cc,
                                  @log_files,
                                  @stats,
                                  @tasks,
                                  @varz)

      Rack::Handler::WEBrick.run web, { :Port => Config.port }
    end
  end
end
