module AdminUI
  class Base
    def initialize(logger)
      @logger = logger
    end

    def items
      do_items
    rescue => error
      @logger.error("Error within #{self.class.name}: #{error.inspect}")
      @logger.error(error.backtrace.join("\n"))
      result
    end

    # Subclasses should override and return values in the following format:
    # {
    #   connected:                     whether the fetch is successful
    #   items:                         array of rows. Each row is an array of objects
    #   detail_hash:                   hash of values where the key is used to find the row object details
    #   searchable_columns:            array of searchable column indices
    #   case_insensitive_sort_columns: array of column indices where values need downcasing prior to comparison
    # }
    # Any raised exception will be logged and treated as not connected with no results
    def do_items
      raise "do_items method must be overridden by subclass #{self.class.name}"
    end

    # Useful method for subclasses to return items object
    def result(connected                     = false,
               items                         = nil,
               detail_hash                   = nil,
               searchable_columns            = nil,
               case_insensitive_sort_columns = nil)
      if connected
        answer =
          {
            connected: true,
            items:     items
          }

        answer[:detail_hash]                   = detail_hash if detail_hash
        answer[:searchable_columns]            = searchable_columns if searchable_columns
        answer[:case_insensitive_sort_columns] = case_insensitive_sort_columns if case_insensitive_sort_columns
        answer
      else
        {
          connected: false,
          items:     []
        }
      end
    end
  end
end
