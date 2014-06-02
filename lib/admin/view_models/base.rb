module AdminUI
  class Base
    def initialize(logger)
      @logger = logger
    end

    def items
      do_items
    rescue => error
      @logger.debug("Error within #{ self.class.name }: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      result
    end

    # Subclasses should override and return values in the following format:
    # { :connected => whether the fetch is successful
    #   :items => array of rows.  Each row is an array of objects.
    #   :visible_columns => array of visible column indices,
    #   ::case_insensitive_sort_columns => array of column indices where values need downcasing prior to comparison
    # }
    # Any raised exception will be logged and treated as not connected with no results
    def do_items
      fail "do_items method must be overridden by subclass #{ self.class.name }"
    end

    # Useful method for subclasses to return items object
    def result(items                         = nil,
               visible_columns               = nil,
               case_insensitive_sort_columns = nil)
      if items.nil?
        {
          :connected                     => false,
          :items                         => [],
          :visible_columns               => [],
          :case_insensitive_sort_columns => []
        }
      else
        {
          :connected                     => true,
          :items                         => items,
          :visible_columns               => visible_columns,
          :case_insensitive_sort_columns => case_insensitive_sort_columns
        }
      end
    end
  end
end
