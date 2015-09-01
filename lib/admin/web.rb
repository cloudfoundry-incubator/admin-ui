require 'sinatra'
require 'yajl'
require_relative 'cc_rest_client'
require_relative 'cc_rest_client_response_error'
require_relative 'logger'
require_relative 'view_models/all_actions'
require_relative 'view_models/download'

module AdminUI
  class Web < Sinatra::Base
    def initialize(config, logger, cc, client, login, log_files, operation, stats, tasks, varz, view_models)
      super({})

      @config      = config
      @logger      = logger
      @cc          = cc
      @client      = client
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
          @logger.error('Authorization failure, redirecting to login...')
          redirect_to_login
        end
      end
    end

    get '/' do
      redirect_to_login
    end

    get '/application_instances_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/application_instances_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.application_instances, params).items)
    end

    get '/application_instances_view_model/:app_guid/:instance_id', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/application_instances_view_model/#{params[:app_guid]}/#{params[:instance_id]}")
      result = @view_models.application_instance(params[:app_guid], params[:instance_id])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/applications_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/applications_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.applications, params).items)
    end

    get '/applications_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/applications_view_model/#{params[:guid]}")
      result = @view_models.application(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/buildpacks_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/buildpacks_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.buildpacks, params).items)
    end

    get '/buildpacks_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/buildpacks_view_model/#{params[:guid]}")
      result = @view_models.buildpack(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/clients_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/clients_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.clients, params).items)
    end

    get '/clients_view_model/:id', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/clients_view_model/#{params[:id]}")
      result = @view_models.client(params[:id])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/cloud_controllers_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/cloud_controllers_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.cloud_controllers, params).items)
    end

    get '/cloud_controllers_view_model/:name', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/cloud_controllers_view_model/#{params[:name]}")
      result = @view_models.cloud_controller(params[:name])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/components_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/components_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.components, params).items)
    end

    get '/components_view_model/:name', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/components_view_model/#{params[:name]}")
      result = @view_models.component(params[:name])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/current_statistics' do
      @logger.info_user(session[:username], 'get', '/current_statistics')
      Yajl::Encoder.encode(@stats.current_stats)
    end

    get '/deas_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/deas_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.deas, params).items)
    end

    get '/deas_view_model/:name', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/deas_view_model/#{params[:name]}")
      result = @view_models.dea(params[:name])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/domains_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/domains_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.domains, params).items)
    end

    get '/domains_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/domains_view_model/#{params[:guid]}")
      result = @view_models.domain(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/download', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/download?path=#{params['path']}")
      file = @log_files.file(params['path'])
      if file.nil?
        redirect_to_login
      else
        send_file(file,
                  disposition: 'attachment',
                  filename:    File.basename(file))
      end
    end

    get '/events_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/events_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.events, params).items)
    end

    get '/events_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/events_view_model/#{params[:guid]}")
      result = @view_models.event(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/favicon.ico' do
    end

    get '/feature_flags_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/feature_flags_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.feature_flags, params).items)
    end

    get '/feature_flags_view_model/:name', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/feature_flags_view_model/#{params[:name]}")
      result = @view_models.feature_flag(params[:name])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/gateways_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/gateways_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.gateways, params).items)
    end

    get '/gateways_view_model/:name', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/gateways_view_model/#{params[:name]}")
      result = @view_models.gateway(params[:name])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/health_managers_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/health_managers_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.health_managers, params).items)
    end

    get '/health_managers_view_model/:name', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/health_managers_view_model/#{params[:name]}")
      result = @view_models.health_manager(params[:name])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/identity_providers_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/identity_providers_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.identity_providers, params).items)
    end

    get '/identity_providers_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/identity_providers_view_model/#{params[:guid]}")
      result = @view_models.identity_provider(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/identity_zones_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/identity_zones_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.identity_zones, params).items)
    end

    get '/identity_zones_view_model/:id', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/identity_zones_view_model/#{params[:id]}")
      result = @view_models.identity_zone(params[:id])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/log', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/log?path=#{params['path']}")
      result = @log_files.content(params['path'], params['start'])
      if result.nil?
        redirect_to_login
      else
        Yajl::Encoder.encode(result)
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
          redirect "scopeError.html?user=#{user_name}", 303
        end
      rescue => error
        @logger.error("Error during /login: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        halt 500, error.message
      end
    end

    get '/logout', auth: [:user] do
      begin
        @logger.info_user(session[:username], 'get', '/logout')
        session.destroy
        Yajl::Encoder.encode('redirect' => @login.logout(request.base_url))
      rescue => error
        @logger.error("Error during /logout: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        halt 500, error.message
      end
    end

    get '/logs_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/logs_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.logs, params).items)
    end

    get '/organizations_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/organizations_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.organizations, params).items)
    end

    get '/organizations_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/organizations_view_model/#{params[:guid]}")
      result = @view_models.organization(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/organization_roles_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/organization_roles_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.organization_roles, params).items)
    end

    get '/organization_roles_view_model/:organization_guid/:role/:user_guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/organization_roles_view_model/#{params[:organization_guid]}/#{params[:role]}/#{params[:user_guid]}")
      result = @view_models.organization_role(params[:organization_guid], params[:role], params[:user_guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/quotas_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/quotas_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.quotas, params).items)
    end

    get '/quotas_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/quotas_view_model/#{params[:guid]}")
      result = @view_models.quota(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/routers_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/routers_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.routers, params).items)
    end

    get '/routers_view_model/:name', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/routers_view_model/#{params[:name]}")
      result = @view_models.router(params[:name])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/routes_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/routes_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.routes, params).items)
    end

    get '/routes_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/routes_view_model/#{params[:guid]}")
      result = @view_models.route(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/settings', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/settings')
      Yajl::Encoder.encode(admin:                  session[:admin],
                           build:                  @client.build,
                           cloud_controller_uri:   @config.cloud_controller_uri,
                           table_height:           @config.table_height,
                           table_page_size:        @config.table_page_size,
                           tasks_refresh_interval: @config.tasks_refresh_interval,
                           user:                   session[:username])
    end

    get '/service_bindings_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/service_bindings_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.service_bindings, params).items)
    end

    get '/service_bindings_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/service_bindings_view_model/#{params[:guid]}")
      result = @view_models.service_binding(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/service_brokers_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/service_brokers_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.service_brokers, params).items)
    end

    get '/service_brokers_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/service_brokers_view_model/#{params[:guid]}")
      result = @view_models.service_broker(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/service_instances_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/service_instances_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.service_instances, params).items)
    end

    get '/service_instances_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/service_instances_view_model/#{params[:guid]}")
      result = @view_models.service_instance(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/service_keys_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/service_keys_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.service_keys, params).items)
    end

    get '/service_keys_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/service_keys_view_model/#{params[:guid]}")
      result = @view_models.service_key(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/service_plans_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/service_plans_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.service_plans, params).items)
    end

    get '/service_plans_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/service_plans_view_model/#{params[:guid]}")
      result = @view_models.service_plan(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/service_plan_visibilities_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/service_plan_visibilities_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.service_plan_visibilities, params).items)
    end

    get '/service_plan_visibilities_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/service_plan_visibilities_view_model/#{params[:guid]}")
      result = @view_models.service_plan_visibility(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/services_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/services_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.services, params).items)
    end

    get '/services_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/services_view_model/#{params[:guid]}")
      result = @view_models.service(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/space_quotas_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/space_quotas_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.space_quotas, params).items)
    end

    get '/space_quotas_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/space_quotas_view_model/#{params[:guid]}")
      result = @view_models.space_quota(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/space_roles_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/space_roles_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.space_roles, params).items)
    end

    get '/space_roles_view_model/:space_guid/:role/:user_guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/space_roles_view_model/#{params[:space_guid]}/#{params[:role]}/#{params[:user_guid]}")
      result = @view_models.space_role(params[:space_guid], params[:role], params[:user_guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/spaces_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/spaces_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.spaces, params).items)
    end

    get '/spaces_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/spaces_view_model/#{params[:guid]}")
      result = @view_models.space(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/stacks_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/stacks_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.stacks, params).items)
    end

    get '/stacks_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/stacks_view_model/#{params[:guid]}")
      result = @view_models.stack(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/statistics' do
      @logger.info_user(session[:username], 'get', '/statistics')
      Yajl::Encoder.encode(@stats.stats)
    end

    get '/stats_view_model' do
      @logger.info_user(session[:username], 'get', '/stats_view_model')
      extended_result = AllActions.new(@logger, @view_models.stats, params).items
      extended_result[:items][:label] = @config.cloud_controller_uri
      extended_result[:items][:build] = @client.build
      Yajl::Encoder.encode(extended_result)
    end

    get '/stats' do
      @logger.info_user(session[:username], 'get', '/stats')
      send_file File.expand_path('stats.html', settings.public_folder)
    end

    get '/tasks_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/tasks_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.tasks, params).items)
    end

    get '/task_status', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/task_status?task_id=#{params['task_id']};updates=#{params['updates']}")
      result = @tasks.task(params['task_id'].to_i,
                           params['updates'] || 'false',
                           session[:last_task_update] || 0)

      if result.nil?
        Yajl::Encoder.encode({})
      else
        session[:last_task_update] = result[:updated]
        Yajl::Encoder.encode(result)
      end
    end

    get '/users_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/users_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.users, params).items)
    end

    get '/users_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/users_view_model/#{params[:guid]}")
      result = @view_models.user(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    post '/application_instances_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/application_instances_view_model')
      file = Download.download(request.body.read, 'application_instances', @view_models.application_instances)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'application_instances.csv')
    end

    post '/applications/:app_guid/restage', auth: [:admin] do
      begin
        @logger.info_user(session[:username], 'post', "/applications/#{params[:app_guid]}/restage")
        @operation.restage_application(params[:app_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during restage application: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during restage application: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    post '/applications_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/applications_view_model')
      file = Download.download(request.body.read, 'applications', @view_models.applications)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'applications.csv')
    end

    post '/buildpacks_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/buildpacks_view_model')
      file = Download.download(request.body.read, 'buildpacks', @view_models.buildpacks)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'buildpacks.csv')
    end

    post '/clients_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/clients_view_model')
      file = Download.download(request.body.read, 'clients', @view_models.clients)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'clients.csv')
    end

    post '/cloud_controllers_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/cloud_controllers_view_model')
      file = Download.download(request.body.read, 'cloud_controllers', @view_models.cloud_controllers)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'cloud_controllers.csv')
    end

    post '/components_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/components_view_model')
      file = Download.download(request.body.read, 'components', @view_models.components)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'components.csv')
    end

    post '/deas', auth: [:admin] do
      @logger.info_user(session[:username], 'post', '/deas')
      result = { task_id: @tasks.new_dea }
      @view_models.invalidate_tasks
      Yajl::Encoder.encode(result)
    end

    post '/deas_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/deas_view_model')
      file = Download.download(request.body.read, 'deas', @view_models.deas)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'deas.csv')
    end

    post '/domains_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/domains_view_model')
      file = Download.download(request.body.read, 'domains', @view_models.domains)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'domains.csv')
    end

    post '/events_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/events_view_model')
      file = Download.download(request.body.read, 'events', @view_models.events)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'events.csv')
    end

    post '/feature_flags_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/feature_flags_view_model')
      file = Download.download(request.body.read, 'feature_flags', @view_models.feature_flags)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'feature_flags.csv')
    end

    post '/gateways_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/gateways_view_model')
      file = Download.download(request.body.read, 'gateways', @view_models.gateways)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'gateways.csv')
    end

    post '/health_managers_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/health_managers_view_model')
      file = Download.download(request.body.read, 'health_managers', @view_models.health_managers)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'health_managers.csv')
    end

    post '/identity_providers_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/identity_providers_view_model')
      file = Download.download(request.body.read, 'identity_providers', @view_models.identity_providers)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'identity_providers.csv')
    end

    post '/identity_zones_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/identity_zones_view_model')
      file = Download.download(request.body.read, 'identity_zones', @view_models.identity_zones)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'identity_zones.csv')
    end

    post '/logs_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/logs_view_model')
      file = Download.download(request.body.read, 'logs', @view_models.logs)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'logs.csv')
    end

    post '/organizations', auth: [:admin] do
      begin
        control_message = request.body.read.to_s
        @logger.info_user(session[:username], 'post', "/organizations; body = #{control_message}")
        @operation.create_organization(control_message)
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during create organization: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during create organization: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    post '/organizations_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/organizations_view_model')
      file = Download.download(request.body.read, 'organizations', @view_models.organizations)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'organizations.csv')
    end

    post '/organization_roles_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/organization_roles_view_model')
      file = Download.download(request.body.read, 'organization_roles', @view_models.organization_roles)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'organization_roles.csv')
    end

    post '/quotas_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/quotas_view_model')
      file = Download.download(request.body.read, 'quotas', @view_models.quotas)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'quotas.csv')
    end

    post '/routers_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/routers_view_model')
      file = Download.download(request.body.read, 'routers', @view_models.routers)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'routers.csv')
    end

    post '/routes_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/routes_view_model')
      file = Download.download(request.body.read, 'routes', @view_models.routes)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'routes.csv')
    end

    post '/service_bindings_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/service_bindings_view_model')
      file = Download.download(request.body.read, 'service_bindings', @view_models.service_bindings)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'service_bindings.csv')
    end

    post '/service_brokers_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/service_brokers_view_model')
      file = Download.download(request.body.read, 'service_brokers', @view_models.service_brokers)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'service_brokers.csv')
    end

    post '/service_instances_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/service_instances_view_model')
      file = Download.download(request.body.read, 'service_instances', @view_models.service_instances)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'service_instances.csv')
    end

    post '/service_keys_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/service_keys_view_model')
      file = Download.download(request.body.read, 'service_keys', @view_models.service_keys)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'service_keys.csv')
    end

    post '/service_plans_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/service_plans_view_model')
      file = Download.download(request.body.read, 'service_plans', @view_models.service_plans)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'service_plans.csv')
    end

    post '/service_plan_visibilities_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/service_plan_visibilities_view_model')
      file = Download.download(request.body.read, 'service_plan_visibilities', @view_models.service_plan_visibilities)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'service_plan_visibilities.csv')
    end

    post '/services_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/services_view_model')
      file = Download.download(request.body.read, 'services', @view_models.services)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'services.csv')
    end

    post '/space_quotas_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/space_quotas_view_model')
      file = Download.download(request.body.read, 'space_quotas', @view_models.space_quotas)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'space_quotas.csv')
    end

    post '/space_roles_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/space_roles_view_model')
      file = Download.download(request.body.read, 'space_roles', @view_models.space_roles)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'space_roles.csv')
    end

    post '/spaces_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/spaces_view_model')
      file = Download.download(request.body.read, 'spaces', @view_models.spaces)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'spaces.csv')
    end

    post '/stacks_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/stacks_view_model')
      file = Download.download(request.body.read, 'stacks', @view_models.stacks)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'stacks.csv')
    end

    post '/statistics', auth: [:admin] do
      stats = @stats.create_stats(apps:              params['apps'].empty? ? nil : params['apps'].to_i,
                                  deas:              params['deas'].empty? ? nil : params['deas'].to_i,
                                  organizations:     params['organizations'].empty? ? nil : params['organizations'].to_i,
                                  running_instances: params['running_instances'].empty? ? nil : params['running_instances'].to_i,
                                  spaces:            params['spaces'].empty? ? nil : params['spaces'].to_i,
                                  timestamp:         params['timestamp'].to_i,
                                  total_instances:   params['total_instances'].empty? ? nil : params['total_instances'].to_i,
                                  users:             params['users'].empty? ? nil : params['users'].to_i)

      query = '/statistics?'
      query += "apps=#{params['apps']};" unless params['apps'].empty?
      query += "deas=#{params['deas']};" unless params['deas'].empty?
      query += "organizations=#{params['organizations']};" unless params['organizations'].empty?
      query += "running_instances=#{params['running_instances']};" unless params['running_instances'].empty?
      query += "spaces=#{params['spaces']};" unless params['spaces'].empty?
      query += "timestamp=#{params['timestamp']};"
      query += "total_instances=#{params['total_instances']};" unless params['total_instances'].empty?
      query += "users=#{params['users']};" unless params['users'].empty?
      query = query.chomp(';')
      query = '/statistics' if query == '/statistics?'

      @logger.info_user(session[:username], 'post', query)
      halt 500 if stats.nil?

      @view_models.invalidate_stats

      [200, Yajl::Encoder.encode(stats)]
    end

    post '/stats_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/stats_view_model')
      file = Download.download(request.body.read, 'stats', @view_models.stats)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'stats.csv')
    end

    post '/tasks_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/tasks_view_model')
      file = Download.download(request.body.read, 'tasks', @view_models.tasks)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'tasks.csv')
    end

    post '/users_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/users_view_model')
      file = Download.download(request.body.read, 'users', @view_models.users)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'users.csv')
    end

    put '/applications/:app_guid', auth: [:admin] do
      begin
        control_message = request.body.read.to_s
        @logger.info_user(session[:username], 'put', "/applications/#{params[:app_guid]}; body = #{control_message}")
        @operation.manage_application(params[:app_guid], control_message)
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during update application: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during update application: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    put '/buildpacks/:buildpack_guid', auth: [:admin] do
      begin
        control_message = request.body.read.to_s
        @logger.info_user(session[:username], 'put', "/buildpacks/#{params[:buildpack_guid]}; body = #{control_message}")
        @operation.manage_buildpack(params[:buildpack_guid], control_message)
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during update buildpack: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during update buildpack: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    put '/feature_flags/:feature_flag_name', auth: [:admin] do
      begin
        control_message = request.body.read.to_s
        @logger.info_user(session[:username], 'put', "/feature_flags/#{params[:feature_flag_name]}; body = #{control_message}")
        @operation.manage_feature_flag(params[:feature_flag_name], control_message)
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during update feature_flag: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during update feature_flag: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    put '/organizations/:organization_guid', auth: [:admin] do
      begin
        control_message = request.body.read.to_s
        @logger.info_user(session[:username], 'put', "/organizations/#{params[:organization_guid]}; body = #{control_message}")
        @operation.manage_organization(params[:organization_guid], control_message)
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during update organization: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during update organization: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    put '/quota_definitions/:quota_definition_guid', auth: [:admin] do
      begin
        control_message = request.body.read.to_s
        @logger.info_user(session[:username], 'put', "/quota_definitions/#{params[:quota_definition_guid]}; body = #{control_message}")
        @operation.manage_quota_definition(params[:quota_definition_guid], control_message)
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during update quota definition: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during update quota definition: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    put '/service_brokers/:service_broker_guid', auth: [:admin] do
      begin
        control_message = request.body.read.to_s
        @logger.info_user(session[:username], 'put', "/service_brokers/#{params[:service_broker_guid]}; body = #{control_message}")
        @operation.manage_service_broker(params[:service_broker_guid], control_message)
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during update service broker: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during update service broker: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    put '/service_instances/:service_instance_guid/:is_gateway_service', auth: [:admin] do
      begin
        control_message = request.body.read.to_s
        @logger.info_user(session[:username], 'put', "/service_instances/#{params[:service_instance_guid]}/#{params[:is_gateway_service]}; body = #{control_message}")
        @operation.manage_service_instance(params[:service_instance_guid], params[:is_gateway_service] == 'true', control_message)
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during update service instance: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during update service instance #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    put '/service_plans/:service_plan_guid', auth: [:admin] do
      begin
        control_message = request.body.read.to_s
        @logger.info_user(session[:username], 'put', "/service_plans/#{params[:service_plan_guid]}; body = #{control_message}")
        @operation.manage_service_plan(params[:service_plan_guid], control_message)
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during update service plan: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during update service plan #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    put '/spaces/:space_guid', auth: [:admin] do
      begin
        control_message = request.body.read.to_s
        @logger.info_user(session[:username], 'put', "/spaces/#{params[:space_guid]}; body = #{control_message}")
        @operation.manage_space(params[:space_guid], control_message)
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during update space: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during update space: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    put '/space_quota_definitions/:space_quota_definition_guid', auth: [:admin] do
      begin
        control_message = request.body.read.to_s
        @logger.info_user(session[:username], 'put', "/space_quota_definitions/#{params[:space_quota_definition_guid]}; body = #{control_message}")
        @operation.manage_space_quota_definition(params[:space_quota_definition_guid], control_message)
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during update space quota definition: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during update space quota definition: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    put '/space_quota_definitions/:space_quota_definition_guid/spaces/:space_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'put', "/space_quota_definitions/#{params[:space_quota_definition_guid]}/spaces/#{params[:space_guid]}")
      begin
        @operation.create_space_quota_definition_space(params[:space_quota_definition_guid], params[:space_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during put space quota definition space: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during put space quota definition space: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/applications/:app_guid', auth: [:admin] do
      recursive = params[:recursive] == 'true'
      url = "/applications/#{params[:app_guid]}"
      url += '?recursive=true' if recursive
      @logger.info_user(session[:username], 'delete', url)
      begin
        @operation.delete_application(params[:app_guid], recursive)
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete application: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete application: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/applications/:app_guid/:instance_index', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/applications/#{params[:app_guid]}/#{params[:instance_index]}")
      begin
        @operation.delete_application_instance(params[:app_guid], params[:instance_index])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete application instance: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete application instance: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/buildpacks/:buildpack_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/buildpacks/#{params[:buildpack_guid]}")
      begin
        @operation.delete_buildpack(params[:buildpack_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete buildpack: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete buildpack: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/components', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/components/#{params[:uri]}")
      begin
        @operation.remove_component(params[:uri])
        204
      rescue => error
        @logger.error("Error during removing component: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/domains/:domain_guid', auth: [:admin] do
      recursive = params[:recursive] == 'true'
      url = "/domains/#{params[:domain_guid]}"
      url += '?recursive=true' if recursive
      @logger.info_user(session[:username], 'delete', url)
      begin
        @operation.delete_domain(params[:domain_guid], recursive)
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete domain: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete domain: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/organizations/:organization_guid', auth: [:admin] do
      recursive = params[:recursive] == 'true'
      url = "/organizations/#{params[:organization_guid]}"
      url += '?recursive=true' if recursive
      @logger.info_user(session[:username], 'delete', url)
      begin
        @operation.delete_organization(params[:organization_guid], recursive)
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete organization: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete organization: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/organizations/:organization_guid/:role/:user_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/organizations/#{params[:organization_guid]}/#{params[:role]}/#{params[:user_guid]}")
      begin
        @operation.delete_organization_role(params[:organization_guid], params[:role], params[:user_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete organization role: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete organization role: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/quota_definitions/:quota_definition_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/quota_definitions/#{params[:quota_definition_guid]}")
      begin
        @operation.delete_quota_definition(params[:quota_definition_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete quota definition: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete quota definition: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/routes/:route_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/routes/#{params[:route_guid]}")
      begin
        @operation.delete_route(params[:route_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete route: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete route: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/service_bindings/:service_binding_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/service_bindings/#{params[:service_binding_guid]}")
      begin
        @operation.delete_service_binding(params[:service_binding_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete service binding: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete service binding: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/service_brokers/:service_broker_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/service_brokers/#{params[:service_broker_guid]}")
      begin
        @operation.delete_service_broker(params[:service_broker_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete service broker: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete service broker: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/service_instances/:service_instance_guid/:is_gateway_service', auth: [:admin] do
      recursive = params[:recursive] == 'true'
      url = "/service_instances/#{params[:service_instance_guid]}/#{params[:is_gateway_service]}"
      url += '?recursive=true' if recursive
      @logger.info_user(session[:username], 'delete', url)
      begin
        @operation.delete_service_instance(params[:service_instance_guid], params[:is_gateway_service], recursive)
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete service instance: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete service instance: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/service_keys/:service_key_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/service_keys/#{params[:service_key_guid]}")
      begin
        @operation.delete_service_key(params[:service_key_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete service key: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete service key: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/service_plans/:service_plan_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/service_plans/#{params[:service_plan_guid]}")
      begin
        @operation.delete_service_plan(params[:service_plan_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete service plan: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete service plan: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/service_plan_visibilities/:service_plan_visibility_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/service_plan_visibilities/#{params[:service_plan_visibility_guid]}")
      begin
        @operation.delete_service_plan_visibility(params[:service_plan_visibility_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete service plan visibility: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete service plan visibility: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/services/:service_guid', auth: [:admin] do
      purge = params[:purge] == 'true'
      url = "/services/#{params[:service_guid]}"
      url += '?purge=true' if purge
      @logger.info_user(session[:username], 'delete', url)
      begin
        @operation.delete_service(params[:service_guid], purge)
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete service: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete service: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/space_quota_definitions/:space_quota_definition_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/space_quota_definitions/#{params[:space_quota_definition_guid]}")
      begin
        @operation.delete_space_quota_definition(params[:space_quota_definition_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete space quota definition: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete space quota definition: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/space_quota_definitions/:space_quota_definition_guid/spaces/:space_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/space_quota_definitions/#{params[:space_quota_definition_guid]}/spaces/#{params[:space_guid]}")
      begin
        @operation.delete_space_quota_definition_space(params[:space_quota_definition_guid], params[:space_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete space quota definition space: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete space quota definition space: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/spaces/:space_guid', auth: [:admin] do
      recursive = params[:recursive] == 'true'
      url = "/spaces/#{params[:space_guid]}"
      url += '?recursive=true' if recursive
      @logger.info_user(session[:username], 'delete', url)
      begin
        @operation.delete_space(params[:space_guid], recursive)
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete space: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete space: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/spaces/:space_guid/:role/:user_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/spaces/#{params[:space_guid]}/#{params[:role]}/#{params[:user_guid]}")
      begin
        @operation.delete_space_role(params[:space_guid], params[:role], params[:user_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete space role: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete space role: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
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

      @logger.info_user(username, 'authenticated', "is admin? #{admin}")
      redirect 'application.html', 303
    end

    def redirect_to_login
      session.destroy

      if request.xhr?
        halt 303
      else
        redirect @login.login_redirect_uri(local_redirect_uri(request)), 303
      end
    rescue => error
      @logger.error("Error during redirect_to_login: #{error.inspect}")
      @logger.error(error.backtrace.join("\n"))
      halt 500, error.message
    end

    def local_redirect_uri(request)
      "#{request.base_url}/login"
    end
  end
end
