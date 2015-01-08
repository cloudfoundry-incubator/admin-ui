require 'sequel'
require_relative '../dbstore'

module AdminUI
  class StatsDBStore  < AdminUI::DBStore
    def append(record)
      @logger.debug("AdminUI::StatsDBStore.append: appending record #{ record } to database")
      db_conn = connect
      begin
        db_conn.synchronize do
          db_conn.transaction do
            items = db_conn[:stats]
            items.insert(apps:              record[:apps],
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
        db_conn.disconnect
      end
    end

    def retrieve
      result = []
      db_conn = connect
      begin
        db_conn.synchronize do
          result = db_conn.fetch('SELECT * from stats').all
        end
      ensure
        db_conn.disconnect
      end
      result
    end
  end
end
