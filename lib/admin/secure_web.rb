require 'rack/ssl'
require 'sinatra'
require_relative 'web'

module AdminUI
  class SecureWeb < AdminUI::Web
    def initialize(config, logger, cc, login, log_files, operation, stats, tasks, varz, view_models)
      logger.debug 'use AdminUI::SecureWeb'
      super(config, logger, cc, login, log_files, operation, stats, tasks, varz, view_models)
    end

    configure do
      enable :sessions
      set :static_cache_control, :no_cache
      set :environment, :production
      set :show_exceptions, false
      use Rack::SSL, :exclude => ->(env) { env['RACK_ENV'] != 'production' }
      use Rack::Session::Cookie, :secure => true, :expire_after => 60, :secret => 'mysecre'
    end
  end
end
