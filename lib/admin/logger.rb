require 'logger'

module AdminUI
  class AdminUILogger < Logger
    alias super_info info

    def info_user(user_name, op, msg)
      super_info("[ #{user_name} ] : [ #{op} ] : #{msg}")
    end

    def <<(msg)
      return if msg.nil?

      msg = msg.to_s.strip
      return unless msg.length.positive?

      unknown("[ -- ] : [ -- ] : #{msg}")
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
