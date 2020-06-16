require 'fileutils'
require 'sequel'
require 'sequel/extensions/migration'
require_relative 'config'
require_relative 'utils'

module AdminUI
  class DBStore
    def initialize(config, logger, testing)
      @config  = config
      @logger  = logger
      @testing = testing
      @db_uri  = @config.db_uri
    end

    def connect
      @logger.debug("AdminUI::DBStore.connect: creating database connection to #{@db_uri}")
      filename = @db_uri.sub(%r{sqlite://}, '')
      if filename != @db_uri && !File.exist?(filename)
        @logger.debug("AdminUI::DBStore.connect: creating new instance of sqlite database at #{filename}")
        FileUtils.mkpath File.dirname(filename)
      end
      Sequel.connect(@db_uri, logger: @logger, single_threaded: @testing, max_connections: 14)
    end
  end
end
