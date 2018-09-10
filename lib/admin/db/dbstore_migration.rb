require 'fileutils'
require 'sequel'
require 'sequel/extensions/migration'
require 'yajl'
require_relative '../config'
require_relative '../dbstore'

module AdminUI
  class DBStoreMigration < AdminUI::DBStore
    def migrate_to_db
      connection = connect
      begin
        does_schema_exist = connection.table_exists? :schema_migrations
        Sequel::Migrator.apply(connection, 'db/migrations')
        return if @config.stats_file.nil?

        file_path = @config.stats_file
        if File.exist?(file_path) && !does_schema_exist
          @logger.debug('AdminUI::DBStoreMigration.migrate_to_db: found stats_file. Prepare for data migration from stats_file to database.')
          record_array = Yajl::Parser.parse(IO.read(file_path))
          store(connection, record_array)
          backup_file_path = "#{@config.stats_file}.bak"
          FileUtils.move(@config.stats_file, backup_file_path)
          @logger.debug("AdminUI::DBStoreMigration.migrate_to_db: completed data migration from stats_file to database. The stats_file is now renamed to #{backup_file_path}.")
        end
      ensure
        connection.disconnect
        Sequel.synchronize { ::Sequel::DATABASES.delete(connection) }
      end
    end

    def store(connection, records)
      connection.transaction do
        connection.run('DELETE from stats')
        @logger.debug('AdminUI::DBStoreMigration.store: finish delete_sql')
        records.each do |record|
          items = connection[:stats]
          items.insert(apps:              record['apps'],
                       cells:             nil,
                       deas:              record['deas'],
                       organizations:     record['organizations'],
                       running_instances: record['running_instances'],
                       spaces:            record['spaces'],
                       timestamp:         record['timestamp'],
                       total_instances:   record['total_instances'],
                       users:             record['users'])
        end
      end
    end
  end
end
