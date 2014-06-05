require 'fileutils'
require 'json'
require 'ostruct'
require 'sequel'
require 'sequel/extensions/migration'

require_relative 'config'
require_relative 'utils'

module AdminUI
  class DatabasePersistence
    attr_reader :db_conn, :db_uri
    @persistence = nil

    def self.create_storage(config, logger)
      persistence_inst = AdminUI::DatabasePersistence.new(config, logger)
      if @persistence.nil?
        @persistence = persistence_inst
        does_schema_exist = @persistence.db_conn.table_exists? :schema_migrations
        setup_database(@persistence.db_conn)
        migrate_to_db(config, logger) unless does_schema_exist
      end
      persistence_inst
    end

    def self.migrate_to_db(config, logger)
      if config.stats_file
        file_path = config.stats_file
        if File.exist?(file_path)
          logger.debug('AdminUI::DatabasePersistence.migrate_to_db: found stats_file.  Prepare for data migration from stats_file to database.')
          record_array = JSON.parse(IO.read(file_path))
          @persistence.store(record_array)
          backup_file_path = "#{config.stats_file}.bak"
          FileUtils.move(config.stats_file, backup_file_path)
          logger.debug("AdminUI::DatabasePersistence.migrate_to_db: completed data migration from stats_file to database.  The stats_file is now renamed to #{backup_file_path}.")
        end
      end
    end

    def self.setup_database(db_conn)
      # schema_migrations
      Sequel::Migrator.apply(db_conn, 'db/migrations')
    end

    def initialize(config, logger)
      @config = config
      @logger = logger
      @db_uri = @config.db_uri
      connect
    end

    def append(hash_record)
      @logger.debug("AdminUI::DatabasePersistence.append: appending record #{hash_record} to database")
      record = OpenStruct.new(hash_record)
      result = false
      @db_conn.transaction do
        @db_conn.run("insert into stats values ('#{record.apps}', '#{record.deas}', '#{record.organizations}', '#{record.running_instances}', '#{record.spaces}', '#{record.timestamp}', '#{record.total_instances}', '#{record.users}')")
        result = true
      end
      result
    end

    def connect
      @logger.debug("AdminUI::DatabasePersistence.connect: creating database connection to #{@db_uri}")
      filename = @db_uri.sub(%r{sqlite:\/\/}, '')
      if filename != @db_uri && !File.exist?(filename)
        @logger.debug("AdminUI::DatabasePersistence.connect: creating new instance of sqlite database at #{filename}")
        File.new("#{filename}", 'w')
      end
      @db_conn = Sequel.connect "#{@db_uri}", :logger => @logger
    end

    def retrieve
      @db_conn.fetch('SELECT * from stats').all
    end

    def store(records)
      @db_conn.transaction do
        @db_conn.run('DELETE from stats')
        @logger.debug('AdminUI::DatabasePersistence.store: finish delete_sql')
        records.each do | hash_record |
          record = OpenStruct.new(hash_record)
          @db_conn.run("insert into stats values ('#{record.apps}', '#{record.deas}', '#{record.organizations}', '#{record.running_instances}', '#{record.spaces}', '#{record.timestamp}', '#{record.total_instances}', '#{record.users}')")
        end
      end
    end
  end
end
