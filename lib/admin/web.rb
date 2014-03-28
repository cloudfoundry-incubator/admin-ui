require 'sinatra'

module AdminUI
  class Web < Sinatra::Base
    def initialize(config, logger, cc, log_files, operation, stats, tasks, varz)
      super({})

      @config    = config
      @logger    = logger
      @cc        = cc
      @log_files = log_files
      @operation = operation
      @stats     = stats
      @tasks     = tasks
      @varz      = varz
    end

    configure do
      enable :sessions
      set :static_cache_control, :no_cache
    end

    set(:auth) do |*roles|
      condition do
        unless !session[:username].nil? && (!roles.include?(:admin) || session[:admin])
          @logger.debug('Authorization failure, redirecting to login...')
          redirect_to_login
        end
      end
    end

    get '/' do
      send_file File.expand_path('login.html', settings.public_folder)
    end

    get '/applications', :auth => [:user] do
      @cc.applications.to_json
    end

    get '/cloud_controllers', :auth => [:user] do
      @varz.cloud_controllers.to_json
    end

    get '/components', :auth => [:user] do
      @varz.components.to_json
    end

    get '/current_statistics' do
      @stats.current_stats.to_json
    end

    get '/deas', :auth => [:user] do
      @varz.deas.to_json
    end

    get '/download', :auth => [:user] do
      file = @log_files.file(params['path'])
      if file.nil?
        redirect_to_login
      else
        send_file(file,
                  :disposition => 'attachment',
                  :filename    => File.basename(file))
      end
    end

    get '/favicon.ico' do
    end

    get '/gateways', :auth => [:user] do
      @varz.gateways.to_json
    end

    get '/health_managers', :auth => [:user] do
      @varz.health_managers.to_json
    end

    get '/log', :auth => [:user] do
      result = @log_files.content(params['path'], params['start'])
      if result.nil?
        redirect_to_login
      else
        result.to_json
      end
    end

    get '/logs', :auth => [:user] do
      { :items => @log_files.infos }.to_json
    end

    get '/organizations', :auth => [:user] do
      @cc.organizations.to_json
    end

    get '/routers', :auth => [:user] do
      @varz.routers.to_json
    end

    get '/settings', :auth => [:user] do
      {
        :admin                  => session[:admin],
        :cloud_controller_uri   => @config.cloud_controller_uri,
        :tasks_refresh_interval => @config.tasks_refresh_interval
      }.to_json
    end

    get '/services', :auth => [:user] do
      @cc.services.to_json
    end

    get '/service_bindings', :auth => [:user] do
      @cc.service_bindings.to_json
    end

    get '/service_instances', :auth => [:user] do
      @cc.service_instances.to_json
    end

    get '/service_plans', :auth => [:user] do
      @cc.service_plans.to_json
    end

    get '/spaces', :auth => [:user] do
      @cc.spaces.to_json
    end

    get '/spaces_auditors', :auth => [:user] do
      @cc.spaces_auditors.to_json
    end

    get '/spaces_developers', :auth => [:user] do
      @cc.spaces_developers.to_json
    end

    get '/spaces_managers', :auth => [:user] do
      @cc.spaces_managers.to_json
    end

    get '/statistics' do
      @stats.stats.to_json
    end

    get '/stats' do
      send_file File.expand_path('stats.html', settings.public_folder)
    end

    get '/tasks', :auth => [:user] do
      { :items => @tasks.tasks }.to_json
    end

    get '/task_status', :auth => [:user] do
      result = @tasks.task(params['task_id'].to_i,
                           params['updates'] || 'false',
                           session[:last_task_update] || 0)

      if result.nil?
        {}.to_json
      else
        session[:last_task_update] = result[:updated]
        result.to_json
      end
    end

    get '/users', :auth => [:user] do
      @cc.users.to_json
    end

    post '/deas', :auth => [:admin] do
      { :task_id => @tasks.new_dea }.to_json
    end

    post '/login' do
      username = params['username']
      password = params['password']

      if username.nil?
        redirect_to_login
      elsif @config.ui_credentials_username == username && @config.ui_credentials_password == password
        authenticated(username, false)
      elsif @config.ui_admin_credentials_username == username && @config.ui_admin_credentials_password == password
        authenticated(username, true)
      else
        session[:username] = nil

        redirect 'login.html?error=true'
      end
    end

    post '/statistics', :auth => [:admin] do
      stats = @stats.create_stats(:apps              => params['apps'].to_i,
                                  :deas              => params['deas'].to_i,
                                  :organizations     => params['organizations'].to_i,
                                  :running_instances => params['running_instances'].to_i,
                                  :spaces            => params['spaces'].to_i,
                                  :timestamp         => params['timestamp'].to_i,
                                  :total_instances   => params['total_instances'].to_i,
                                  :users             => params['users'].to_i)

      halt 500 if stats.nil?

      [200, stats.to_json]

    end

    put '/applications/:app_guid', :auth => [:admin] do
      control_message = request.body.read.to_s
      @operation.manage_application(params[:app_guid], control_message)

      204
    end

    delete '/components', :auth => [:user] do
      @varz.remove(params['uri'])

      204
    end

    private

    def authenticated(username, admin)
      session[:username] = username

      session[:admin] = admin

      redirect "application.html?user=#{ username }"
    end

    def redirect_to_login
      session[:username] = nil
      session[:admin]    = nil

      if request.xhr?
        halt 303
      else
        redirect 'login.html', 303
      end
    end
  end
end
