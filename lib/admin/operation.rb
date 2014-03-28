module AdminUI
  class Operation
    def initialize(config, logger, cc, client, varz)
      @cc     = cc
      @client = client
      @config = config
      @logger = logger
      @varz   = varz
    end

    def manage_application(app_guid, control_message)
      url = "v2/apps/#{ app_guid }"

      @client.put_cc(url, control_message)

      @cc.invalid_applications
      @varz.invalid
    end
  end
end
