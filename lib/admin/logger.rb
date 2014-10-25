require 'net/http'
require 'logger'
require_relative 'config'

module AdminUI
  class AdminUILogger < Logger
    alias_method :parent_debug, :debug
    alias_method :parent_info, :info

    def initialize(file_name, level)
      super(file_name, level)
    end

    def debug_user(user_name, op, msg)
      parent_debug("[ #{ user_name } ] : [ #{ op } ] : #{ msg }")
    end

    def info_user(user_name, op, msg)
      parent_info("[ #{ user_name } ] : [ #{ op } ] : #{ msg }")
    end

    def debug(msg)
      parent_debug("[ -- ] : [ -- ] : #{ msg }")
    end

    def info(msg)
      parent_info("[ -- ] : [ -- ] : #{ msg }")
    end
  end
end
