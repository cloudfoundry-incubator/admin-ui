require 'sequel'
require_relative '../dbstore'

module AdminUI
  class StatsDBStore < AdminUI::DBStore
    def append(record)
      @logger.debug("AdminUI::StatsDBStore.append: appending record #{record} to database")
      connection = connect
      begin
        connection.synchronize do
          connection.transaction do
            items = connection[:stats]
            items.insert(apps:              record[:apps],
                         cells:             record[:cells],
                         deas:              record[:deas],
                         organizations:     record[:organizations],
                         running_instances: record[:running_instances],
                         spaces:            record[:spaces],
                         timestamp:         record[:timestamp],
                         total_instances:   record[:total_instances],
                         users:             record[:users])
          end
        end
      ensure
        connection.disconnect
        Sequel.synchronize { ::Sequel::DATABASES.delete(connection) }
      end
    end

    def retrieve
      result = []
      connection = connect
      begin
        connection.synchronize do
          result = connection.fetch('SELECT * from stats').all
        end
      ensure
        connection.disconnect
        Sequel.synchronize { ::Sequel::DATABASES.delete(connection) }
      end
      result
    end
  end
end
