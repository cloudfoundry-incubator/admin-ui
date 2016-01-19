require 'net/http'
require 'logger'
require_relative 'config'

module AdminUI
  class AdminUILogger < Logger
    alias super_info info

    def initialize(file_name, level)
      super(file_name, level)
    end

    def info_user(user_name, op, msg)
      super_info("[ #{user_name} ] : [ #{op} ] : #{msg}")
    end

    def debug(msg)
      super("[ -- ] : [ -- ] : #{msg}")
    end

    def error(msg)
      super("[ -- ] : [ -- ] : #{msg}")
    end

    def fatal(msg)
      super("[ -- ] : [ -- ] : #{msg}")
    end

    def info(msg)
      super("[ -- ] : [ -- ] : #{msg}")
    end

    def warn(msg)
      super("[ -- ] : [ -- ] : #{msg}")
    end
  end
end
