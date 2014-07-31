require 'sinatra'
require_relative 'view_models/all_actions'

module AdminUI
  class Web < Sinatra::Base
    def initialize(config, logger, cc, login, log_files, operation, stats, tasks, varz, view_models)
      super({})

      @config      = config
      @logger      = logger
      @cc          = cc
      @login       = login
      @log_files   = log_files
      @operation   = operation
      @stats       = stats
      @tasks       = tasks
      @varz        = varz
      @view_models = view_models
    end

    configure do
      enable :sessions
      set :static_cache_control, :no_cache
      set :environment, :production
      set :show_exceptions, false
    end

    set(:auth) do |*roles|
      condition do
        unless session[:username] && (!roles.include?(:admin) || session[:admin])
          env['rack.session.options'][:expire_after] = @config.ssl_max_session_idle_length.to_i if @config.secured_client_connection
          @logger.debug('Authorization failure, redirecting to login...')
          redirect_to_login
        end
      end
    end

    get '/' do
      redirect_to_login
    end

    get '/applications_view_model', :auth => [:user] do
      AllActions.new(@logger, @view_models.applications, params).items.to_json
    end

    get '/applications', :auth => [:user] do
      @cc.applications.to_json
    end

    get '/cloud_controllers_view_model', :auth => [:user] do
      AllActions.new(@logger, @view_models.cloud_controllers, params).items.to_json
    end

    get '/cloud_controllers', :auth => [:user] do
      @varz.cloud_controllers.to_json
    end

    get '/components_view_model', :auth => [:user] do
      AllActions.new(@logger, @view_models.components, params).items.to_json
    end

    get '/components', :auth => [:user] do
      @varz.components.to_json
    end

    get '/current_statistics' do
      @stats.current_stats(false).to_json
    end

    get '/deas_view_model', :auth => [:user] do
      AllActions.new(@logger, @view_models.deas, params).items.to_json
    end

    get '/deas', :auth => [:user] do
      @varz.deas.to_json
    end

    get '/developers_view_model', :auth => [:user] do
      AllActions.new(@logger, @view_models.developers, params).items.to_json
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

    get '/gateways_view_model', :auth => [:user] do
      AllActions.new(@logger, @view_models.gateways, params).items.to_json
    end

    get '/gateways', :auth => [:user] do
      @varz.gateways.to_json
    end

    get '/health_managers_view_model', :auth => [:user] do
      AllActions.new(@logger, @view_models.health_managers, params).items.to_json
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

    get '/login' do
      begin
        code = params['code']
        user_name, user_type = @login.login_user(code, local_redirect_uri(request))

        if AdminUI::Login::LOGIN_ADMIN == user_type
          authenticated(user_name, true)
        elsif AdminUI::Login::LOGIN_USER == user_type
          authenticated(user_name, false)
        else
          redirect "scopeError.html?user=#{ user_name }", 303
        end
      rescue => error
        @logger.debug("Error during /login: #{ error.inspect }")
        @logger.debug(error.backtrace.join("\n"))
        halt 500, error.message
      end
    end

    get '/logout' do
      begin
        session.destroy
        { 'redirect' => @login.logout(request.base_url) }.to_json
      rescue => error
        @logger.debug("Error during /logout: #{ error.inspect }")
        @logger.debug(error.backtrace.join("\n"))
        halt 500, error.message
      end
    end

    get '/logs_view_model', :auth => [:user] do
      AllActions.new(@logger, @view_models.logs, params).items.to_json
    end

    get '/logs', :auth => [:user] do
      { :items => @log_files.infos }.to_json
    end

    get '/organizations_view_model', :auth => [:user] do
      AllActions.new(@logger, @view_models.organizations, params).items.to_json
    end

    get '/organizations', :auth => [:user] do
      @cc.organizations.to_json
    end

    get '/quota_definitions', :auth => [:user] do
      @cc.quota_definitions.to_json
    end

    get '/quotas_view_model', :auth => [:user] do
      AllActions.new(@logger, @view_models.quotas, params).items.to_json
    end

    get '/routers_view_model', :auth => [:user] do
      AllActions.new(@logger, @view_models.routers, params).items.to_json
    end

    get '/routes_view_model', :auth => [:user] do
      AllActions.new(@logger, @view_models.routes, params).items.to_json
    end

    get '/routers', :auth => [:user] do
      @varz.routers.to_json
    end

    get '/routes', :auth => [:user] do
      @cc.routes.to_json
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

    get '/service_brokers', :auth => [:user] do
      @cc.service_brokers.to_json
    end

    get '/service_instances_view_model', :auth => [:user] do
      AllActions.new(@logger, @view_models.service_instances, params).items.to_json
    end

    get '/service_instances', :auth => [:user] do
      @cc.service_instances.to_json
    end

    get '/service_plans_view_model', :auth => [:user] do
      AllActions.new(@logger, @view_models.service_plans, params).items.to_json
    end

    get '/service_plans', :auth => [:user] do
      @cc.service_plans.to_json
    end

    get '/spaces_view_model', :auth => [:user] do
      AllActions.new(@logger, @view_models.spaces, params).items.to_json
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

    get '/stats_view_model' do
      extended_result = AllActions.new(@logger, @view_models.stats, params).items
      extended_result[:items][:label] = @config.cloud_controller_uri
      extended_result.to_json
    end

    get '/stats' do
      send_file File.expand_path('stats.html', settings.public_folder)
    end

    get '/tasks_view_model', :auth => [:user] do
      AllActions.new(@logger, @view_models.tasks, params).items.to_json
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
      result = { :task_id => @tasks.new_dea }
      @view_models.invalidate_tasks
      result.to_json
    end

    post '/organizations', :auth => [:admin] do
      begin
        control_message = request.body.read.to_s
        @operation.create_organization(control_message)

        204
      rescue => error
        @logger.debug("Error during creating organization: #{ error.inspect }")
        @logger.debug(error.backtrace.join("\n"))
        500
      end
    end

    post '/statistics', :auth => [:admin] do
      stats = @stats.create_stats(:apps              => params['apps'].empty? ? nil : params['apps'].to_i,
                                  :deas              => params['deas'].empty? ? nil : params['deas'].to_i,
                                  :organizations     => params['organizations'].empty? ? nil : params['organizations'].to_i,
                                  :running_instances => params['running_instances'].empty? ? nil : params['running_instances'].to_i,
                                  :spaces            => params['spaces'].empty? ? nil : params['spaces'].to_i,
                                  :timestamp         => params['timestamp'].to_i,
                                  :total_instances   => params['total_instances'].empty? ? nil : params['total_instances'].to_i,
                                  :users             => params['users'].empty? ? nil : params['users'].to_i)

      halt 500 if stats.nil?

      @view_models.invalidate_stats

      [200, stats.to_json]

    end

    put '/applications/:app_guid', :auth => [:admin] do
      begin
        control_message = request.body.read.to_s
        @operation.manage_application(params[:app_guid], control_message)

        204
      rescue => error
        @logger.debug("Error during update application: #{ error.inspect }")
        @logger.debug(error.backtrace.join("\n"))
        500
      end
    end

    put '/organizations/:org_guid', :auth => [:admin] do
      begin
        control_message = request.body.read.to_s
        @operation.manage_organization(params[:org_guid], control_message)

        204
      rescue => error
        @logger.debug("Error during update organization: #{ error.inspect }")
        @logger.debug(error.backtrace.join("\n"))
        500
      end
    end

    put '/service_plans/:service_plan_guid', :auth => [:admin] do
      begin
        control_message = request.body.read.to_s
        @operation.manage_service_plan(params[:service_plan_guid], control_message)

        204
      rescue => error
        @logger.debug("Error during update to service plan #{ error.inspect }")
        @logger.debug(error.backtrace.join("\n"))
        500
      end
    end

    delete '/applications/:app_guid', :auth => [:admin] do
      begin
        @operation.delete_application(params[:app_guid])
        204
      rescue => error
        @logger.debug("Error during deleting application: #{ error.inspect }")
        @logger.debug(error.backtrace.join("\n"))
        500
      end
    end

    delete '/components', :auth => [:user] do
      @varz.remove(params['uri'])

      204
    end

    delete '/organizations/:org_guid', :auth => [:admin] do
      begin
        @operation.delete_organization(params[:org_guid])
        204
      rescue => error
        @logger.debug("Error during deleting organization: #{ error.inspect }")
        @logger.debug(error.backtrace.join("\n"))
        500
      end
    end

    delete '/routes/:route_guid', :auth => [:admin] do
      begin
        @operation.manage_route(params[:route_guid])
        204
      rescue => error
        @logger.debug("Error during deleting route: #{ error.inspect }")
        @logger.debug(error.backtrace.join("\n"))
        500
      end
    end

    def route_missing
      [404, 'Page Not Found']
    end

    private

    def authenticated(username, admin)
      session[:username] = username

      session[:admin] = admin

      redirect "application.html?user=#{ username }", 303
    end

    def redirect_to_login
      session.destroy

      if request.xhr?
        halt 303
      else
        redirect @login.login_redirect_uri(local_redirect_uri(request)), 303
      end
    rescue => error
      @logger.debug("Error during redirect_to_login: #{ error.inspect }")
      @logger.debug(error.backtrace.join("\n"))
      halt 500, error.message
    end

    def local_redirect_uri(request)
      "#{ request.base_url }/login"
    end
  end
end
