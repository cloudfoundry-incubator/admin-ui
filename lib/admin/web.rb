require 'sinatra'
require 'yajl'
require_relative 'cc_rest_client'
require_relative 'cc_rest_client_response_error'
require_relative 'logger'
require_relative 'view_models/all_actions'
require_relative 'view_models/download'

module AdminUI
  class Web < Sinatra::Base
    def initialize(config, logger, cc, client, doppler, login, log_files, operation, stats, varz, view_models)
      super({})

      @config      = config
      @logger      = logger
      @cc          = cc
      @client      = client
      @doppler     = doppler
      @login       = login
      @log_files   = log_files
      @operation   = operation
      @stats       = stats
      @varz        = varz
      @view_models = view_models
    end

    configure do
      enable :sessions
      use Rack::Session::Cookie, secure: Config.cookie_secure, secret: Config.cookie_secret
      set :static_cache_control, :no_cache
      set :environment, :production
      set :show_exceptions, false
    end

    set(:auth) do |*roles|
      condition do
        unless session[:username] &&
               ((session[:role] == 'admin') ||
                (session[:role] == 'user' && !roles.include?(:admin)) ||
                (!roles.include?(:admin) && !roles.include?(:user))
               )
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

    get '/application_instances_view_model/:app_guid/:instance_index', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/application_instances_view_model/#{params[:app_guid]}/#{params[:instance_index]}")
      result = @view_models.application_instance(params[:app_guid], params[:instance_index])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/applications_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/applications_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.applications, params).items)
    end

    get '/applications_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/applications_view_model/#{params[:guid]}")
      result = @view_models.application(params[:guid], session[:role] == 'admin')
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/approvals_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/approvals_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.approvals, params).items)
    end

    get '/approvals_view_model/:user_id/:client_id/:scope', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/approvals_view_model/#{params[:user_id]}/#{params[:client_id]}/#{params[:scope]}")
      result = @view_models.approval(params[:user_id], params[:client_id], params[:scope])
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

    get '/cells_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/cells_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.cells, params).items)
    end

    get '/cells_view_model/:key', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/cells_view_model/#{params[:key]}")
      result = @view_models.cell(params[:key])
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

    get '/domains_view_model/:guid/:is_shared', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/domains_view_model/#{params[:guid]}/#{params[:is_shared]}")
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

    get '/environment_groups_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/environment_groups_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.environment_groups, params).items)
    end

    get '/environment_groups_view_model/:name', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/environment_groups_view_model/#{params[:name]}")
      result = @view_models.environment_group(params[:name])
      return Yajl::Encoder.encode(result) if result
      404
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

    get '/group_members_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/group_members_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.group_members, params).items)
    end

    get '/group_members_view_model/:group_id/:member_id', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/group_members_view_model/#{params[:group_id]}/#{params[:member_id]}")
      result = @view_models.group_member(params[:group_id], params[:member_id])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/groups_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/groups_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.groups, params).items)
    end

    get '/groups_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/groups_view_model/#{params[:guid]}")
      result = @view_models.group(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/health' do
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

    get '/isolation_segments_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/isolation_segments_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.isolation_segments, params).items)
    end

    get '/isolation_segments_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/isolation_segments_view_model/#{params[:guid]}")
      result = @view_models.isolation_segment(params[:guid])
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
          authenticated(user_name, 'admin', true)
        elsif AdminUI::Login::LOGIN_USER == user_type
          authenticated(user_name, 'user', true)
        else
          authenticated(user_name, 'anyone', false)
        end
      rescue => error
        @logger.error("Error during /login: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        halt 500, error.message
      end
    end

    get '/logout', auth: [:anyone] do
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

    get '/mfa_providers_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/mfa_providers_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.mfa_providers, params).items)
    end

    get '/mfa_providers_view_model/:id', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/mfa_providers_view_model/#{params[:id]}")
      result = @view_models.mfa_provider(params[:id])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/organizations_isolation_segments_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/organizations_isolation_segments_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.organizations_isolation_segments, params).items)
    end

    get '/organizations_isolation_segments_view_model/:organization_guid/:isolation_segment_guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/organizations_isolation_segments_view_model/#{params[:organization_guid]}/#{params[:isolation_segment_guid]}")
      result = @view_models.organization_isolation_segment(params[:organization_guid], params[:isolation_segment_guid])
      return Yajl::Encoder.encode(result) if result
      404
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

    get '/revocable_tokens_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/revocable_tokens_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.revocable_tokens, params).items)
    end

    get '/revocable_tokens_view_model/:token_id', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/revocable_tokens_view_model/#{params[:token_id]}")
      result = @view_models.revocable_token(params[:token_id])
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

    get '/route_bindings_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/route_bindings_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.route_bindings, params).items)
    end

    get '/route_bindings_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/route_bindings_view_model/#{params[:guid]}")
      result = @view_models.route_binding(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/route_mappings_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/route_mappings_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.route_mappings, params).items)
    end

    get '/route_mappings_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/route_mappings_view_model/#{params[:guid]}")
      result = @view_models.route_mapping(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/security_groups_spaces_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/security_groups_spaces_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.security_groups_spaces, params).items)
    end

    get '/security_groups_spaces_view_model/:security_group_guid/:space_guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/security_groups_spaces_view_model/#{params[:security_group_guid]}/#{params[:space_guid]}")
      result = @view_models.security_group_space(params[:security_group_guid], params[:space_guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/security_groups_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/security_groups_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.security_groups, params).items)
    end

    get '/security_groups_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/security_groups_view_model/#{params[:guid]}")
      result = @view_models.security_group(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/settings', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/settings')
      Yajl::Encoder.encode(admin:                session[:role] == 'admin',
                           api_version:          @client.api_version,
                           build:                @client.build,
                           cloud_controller_uri: @config.cloud_controller_uri,
                           table_height:         @config.table_height,
                           table_page_size:      @config.table_page_size,
                           user:                 session[:username])
    end

    get '/service_bindings_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/service_bindings_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.service_bindings, params).items)
    end

    get '/service_bindings_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/service_bindings_view_model/#{params[:guid]}")
      result = @view_models.service_binding(params[:guid], session[:role] == 'admin')
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

    get '/service_instances_view_model/:guid/:is_gateway_service', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/service_instances_view_model/#{params[:guid]}/#{params[:is_gateway_service]}")
      result = @view_models.service_instance(params[:guid], params[:is_gateway_service] == 'true', session[:role] == 'admin')
      return Yajl::Encoder.encode(result) if result
      404
    end

    get '/service_keys_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/service_keys_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.service_keys, params).items)
    end

    get '/service_keys_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/service_keys_view_model/#{params[:guid]}")
      result = @view_models.service_key(params[:guid], session[:role] == 'admin')
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

    get '/service_providers_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/service_providers_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.service_providers, params).items)
    end

    get '/service_providers_view_model/:id', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/service_providers_view_model/#{params[:id]}")
      result = @view_models.service_provider(params[:id])
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

    get '/shared_service_instances_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/shared_service_instances_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.shared_service_instances, params).items)
    end

    get '/shared_service_instances_view_model/:service_instance_guid/:target_space_guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/shared_service_instances_view_model/#{params[:service_instance_guid]}/#{params[:target_space_guid]}")
      result = @view_models.shared_service_instance(params[:service_instance_guid], params[:target_space_guid])
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

    get '/staging_security_groups_spaces_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'get', '/staging_security_groups_spaces_view_model')
      Yajl::Encoder.encode(AllActions.new(@logger, @view_models.staging_security_groups_spaces, params).items)
    end

    get '/staging_security_groups_spaces_view_model/:staging_security_group_guid/:staging_space_guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/staging_security_groups_spaces_view_model/#{params[:staging_security_group_guid]}/#{params[:staging_space_guid]}")
      result = @view_models.staging_security_group_space(params[:staging_security_group_guid], params[:staging_space_guid])
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

    get '/tasks_view_model/:guid', auth: [:user] do
      @logger.info_user(session[:username], 'get', "/tasks_view_model/#{params[:guid]}")
      result = @view_models.task(params[:guid])
      return Yajl::Encoder.encode(result) if result
      404
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

    post '/approvals_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/approvals_view_model')
      file = Download.download(request.body.read, 'approvals', @view_models.approvals)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'approvals.csv')
    end

    post '/buildpacks_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/buildpacks_view_model')
      file = Download.download(request.body.read, 'buildpacks', @view_models.buildpacks)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'buildpacks.csv')
    end

    post '/cells_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/cells_view_model')
      file = Download.download(request.body.read, 'cells', @view_models.cells)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'cells.csv')
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

    post '/environment_groups_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/environment_groups_view_model')
      file = Download.download(request.body.read, 'environment_groups', @view_models.environment_groups)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'environment_groups.csv')
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

    post '/group_members_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/group_members_view_model')
      file = Download.download(request.body.read, 'group_members', @view_models.group_members)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'group_members.csv')
    end

    post '/groups_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/groups_view_model')
      file = Download.download(request.body.read, 'groups', @view_models.groups)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'groups.csv')
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

    post '/isolation_segments', auth: [:admin] do
      begin
        control_message = request.body.read.to_s
        @logger.info_user(session[:username], 'post', "/isolation_segments; body = #{control_message}")
        @operation.create_isolation_segment(control_message)
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during create isolation segment: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during create isolation segment: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    post '/isolation_segments_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/isolation_segments_view_model')
      file = Download.download(request.body.read, 'isolation_segments', @view_models.isolation_segments)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'isolation_segments.csv')
    end

    post '/logs_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/logs_view_model')
      file = Download.download(request.body.read, 'logs', @view_models.logs)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'logs.csv')
    end

    post '/mfa_providers_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/mfa_providers_view_model')
      file = Download.download(request.body.read, 'mfa_providers', @view_models.mfa_providers)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'mfa_providers.csv')
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

    post '/organizations_isolation_segments_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/organizations_isolation_segments_view_model')
      file = Download.download(request.body.read, 'organizations_isolation_segments', @view_models.organizations_isolation_segments)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'organizations_isolation_segments.csv')
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

    post '/revocable_tokens_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/revocable_tokens_view_model')
      file = Download.download(request.body.read, 'revocable_tokens', @view_models.revocable_tokens)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'revocable_tokens.csv')
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

    post '/route_bindings_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/route_bindings_view_model')
      file = Download.download(request.body.read, 'route_bindings', @view_models.route_bindings)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'route_bindings.csv')
    end

    post '/route_mappings_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/route_mappings_view_model')
      file = Download.download(request.body.read, 'route_mappings', @view_models.route_mappings)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'route_mappings.csv')
    end

    post '/security_groups_spaces_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/security_groups_spaces_view_model')
      file = Download.download(request.body.read, 'security_groups_spaces', @view_models.security_groups_spaces)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'security_groups_spaces.csv')
    end

    post '/security_groups_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/security_groups_view_model')
      file = Download.download(request.body.read, 'security_groups', @view_models.security_groups)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'security_groups.csv')
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

    post '/service_providers_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/service_providers_view_model')
      file = Download.download(request.body.read, 'service_providers', @view_models.service_providers)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'service_providers.csv')
    end

    post '/services_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/services_view_model')
      file = Download.download(request.body.read, 'services', @view_models.services)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'services.csv')
    end

    post '/shared_service_instances_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/shared_service_instances_view_model')
      file = Download.download(request.body.read, 'shared_service_instances', @view_models.shared_service_instances)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'shared_service_instances.csv')
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

    post '/staging_security_groups_spaces_view_model', auth: [:user] do
      @logger.info_user(session[:username], 'post', '/staging_security_groups_spaces_view_model')
      file = Download.download(request.body.read, 'staging_security_groups_spaces', @view_models.staging_security_groups_spaces)
      send_file(file.path,
                disposition: 'attachment',
                filename:    'staging_security_groups_spaces.csv')
    end

    post '/statistics', auth: [:admin] do
      stats = @stats.create_stats(apps:              params['apps'].empty? ? nil : params['apps'].to_i,
                                  cells:             params['cells'].empty? ? nil : params['cells'].to_i,
                                  deas:              params['deas'].empty? ? nil : params['deas'].to_i,
                                  organizations:     params['organizations'].empty? ? nil : params['organizations'].to_i,
                                  running_instances: params['running_instances'].empty? ? nil : params['running_instances'].to_i,
                                  spaces:            params['spaces'].empty? ? nil : params['spaces'].to_i,
                                  timestamp:         params['timestamp'].to_i,
                                  total_instances:   params['total_instances'].empty? ? nil : params['total_instances'].to_i,
                                  users:             params['users'].empty? ? nil : params['users'].to_i)

      query = '/statistics?'
      query += "apps=#{params['apps']};" unless params['apps'].empty?
      query += "cells=#{params['cells']};" unless params['cells'].empty?
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
        @logger.error("Error during update feature flag: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during update feature flag: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    put '/identity_providers/:identity_provider_id/status', auth: [:admin] do
      begin
        control_message = request.body.read.to_s
        @logger.info_user(session[:username], 'put', "/identity_providers/#{params[:identity_provider_id]}/status; body = #{control_message}")
        @operation.manage_identity_provider_status(params[:identity_provider_id], control_message)
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during update identity provider status: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during update identity provider status: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    put '/isolation_segments/:isolation_segment_guid', auth: [:admin] do
      begin
        control_message = request.body.read.to_s
        @logger.info_user(session[:username], 'put', "/isolation_segments/#{params[:isolation_segment_guid]}; body = #{control_message}")
        @operation.manage_isolation_segment(params[:isolation_segment_guid], control_message)
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during update isolation segment: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during update isolation segment: #{error.inspect}")
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

    put '/security_groups/:security_group_guid', auth: [:admin] do
      begin
        control_message = request.body.read.to_s
        @logger.info_user(session[:username], 'put', "/security_groups/#{params[:security_group_guid]}; body = #{control_message}")
        @operation.manage_security_group(params[:security_group_guid], control_message)
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during update security group: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during update security group: #{error.inspect}")
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
        @logger.error("Error during update service instance: #{error.inspect}")
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
        @logger.error("Error during update service plan: #{error.inspect}")
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

    put '/users/:user_guid', auth: [:admin] do
      begin
        control_message = request.body.read.to_s
        @logger.info_user(session[:username], 'put', "/users/#{params[:user_guid]}; body = #{control_message}")
        @operation.manage_user(params[:user_guid], control_message)
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during update user: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during update user: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    put '/users/:user_guid/status', auth: [:admin] do
      begin
        control_message = request.body.read.to_s
        @logger.info_user(session[:username], 'put', "/users/#{params[:user_guid]}/status; body = #{control_message}")
        @operation.manage_user_status(params[:user_guid], control_message)
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during update user status: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during update user status: #{error.inspect}")
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

    delete '/applications/:app_guid/environment_variables/:environment_variable', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/applications/#{params[:app_guid]}/environment_variables/#{params[:environment_variable]}")
      begin
        @operation.delete_application_environment_variable(params[:app_guid], params[:environment_variable])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete application environment variable: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete application environment variable: #{error.inspect}")
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

    delete '/clients/:client_id', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/clients/#{params[:client_id]}")
      begin
        @operation.delete_client(params[:client_id])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete client: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete client: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/clients/:client_id/tokens', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/clients/#{params[:client_id]}/tokens")
      begin
        @operation.delete_client_tokens(params[:client_id])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete client tokens: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete client tokens: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/components', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/components?uri=#{params[:uri]}")
      begin
        @operation.remove_component(params[:uri])
        204
      rescue => error
        @logger.error("Error during removing component: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/domains/:domain_guid/:is_shared', auth: [:admin] do
      recursive = params[:recursive] == 'true'
      url = "/domains/#{params[:domain_guid]}/#{params[:is_shared]}"
      url += '?recursive=true' if recursive
      @logger.info_user(session[:username], 'delete', url)
      begin
        @operation.delete_domain(params[:domain_guid], params[:is_shared] == 'true', recursive)
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

    delete '/domains/:domain_guid/:is_shared/:organization_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/domains/#{params[:domain_guid]}/#{params[:is_shared]}/#{params[:organization_guid]}")
      begin
        @operation.delete_organization_private_domain(params[:organization_guid], params[:domain_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete domain organization: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete domain organization: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/doppler_components', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/doppler_components?uri=#{params[:uri]}")
      begin
        @operation.remove_doppler_component(params[:uri])
        204
      rescue => error
        @logger.error("Error during removing doppler component: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/groups/:group_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/groups/#{params[:group_guid]}")
      begin
        @operation.delete_group(params[:group_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete group: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete group: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/groups/:group_guid/:member_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/groups/#{params[:group_guid]}/#{params[:member_guid]}")
      begin
        @operation.delete_group_member(params[:group_guid], params[:member_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete group member: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete group member: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/identity_providers/:id', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/identity_providers/#{params[:id]}")
      begin
        @operation.delete_identity_provider(params[:id])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete identity provider: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete identity provider: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/identity_zones/:id', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/identity_zones/#{params[:id]}")
      begin
        @operation.delete_identity_zone(params[:id])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete identity zone: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete identity zone: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/isolation_segments/:isolation_segment_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/isolation_segments/#{params[:isolation_segment_guid]}")
      begin
        @operation.delete_isolation_segment(params[:isolation_segment_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete isolation segment: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete isolation segment: #{error.inspect}")
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

    delete '/organizations/:organization_guid/default_isolation_segment', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/organizations/#{params[:organization_guid]}/default_isolation_segment")
      begin
        @operation.remove_organization_default_isolation_segment(params[:organization_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during remove organization default isolation segment: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during remove organization default isolation segment: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/organizations/:organization_guid/:isolation_segment_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/organizations/#{params[:organization_guid]}/#{params[:isolation_segment_guid]}")
      begin
        @operation.delete_organization_isolation_segment(params[:organization_guid], params[:isolation_segment_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete organization isolation segment: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete organization isolation segment: #{error.inspect}")
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

    delete '/revocable_tokens/:token_id', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/revocable_tokens/#{params[:token_id]}")
      begin
        @operation.delete_revocable_token(params[:token_id])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete revocable token: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete revocable token: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/routes/:route_guid', auth: [:admin] do
      recursive = params[:recursive] == 'true'
      url = "/routes/#{params[:route_guid]}"
      url += '?recursive=true' if recursive
      @logger.info_user(session[:username], 'delete', url)
      begin
        @operation.delete_route(params[:route_guid], recursive)
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

    delete '/route_bindings/:service_instance_guid/:route_guid/:is_gateway_service', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/route_bindings/#{params[:service_instance_guid]}/#{params[:route_guid]}/#{params[:is_gateway_service]}")
      begin
        @operation.delete_route_binding(params[:service_instance_guid], params[:route_guid], params[:is_gateway_service] == 'true')
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete route binding: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete route binding: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/route_mappings/:route_mapping_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/route_mappings/#{params[:route_mapping_guid]}")
      begin
        @operation.delete_route_mapping(params[:route_mapping_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete route mapping: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete route mapping: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/security_groups/:security_group_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/security_groups/#{params[:security_group_guid]}")
      begin
        @operation.delete_security_group(params[:security_group_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete security group: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete security group: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/security_groups/:security_group_guid/:space_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/security_groups/#{params[:security_group_guid]}/#{params[:space_guid]}")
      begin
        @operation.delete_security_group_space(params[:security_group_guid], params[:space_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete security group space: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete security group space: #{error.inspect}")
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
      purge     = params[:purge] == 'true'
      url = "/service_instances/#{params[:service_instance_guid]}/#{params[:is_gateway_service]}"
      if recursive
        url += '?recursive=true'
        url += '&purge=true' if purge
      end
      @logger.info_user(session[:username], 'delete', url)
      begin
        @operation.delete_service_instance(params[:service_instance_guid], params[:is_gateway_service] == 'true', recursive, purge)
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

    delete '/service_providers/:service_provider_id', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/service_providers/#{params[:service_provider_id]}")
      begin
        @operation.delete_service_provider(params[:service_provider_id])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete service provider: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete service provider: #{error.inspect}")
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

    delete '/shared_service_instances/:service_instance_guid/:target_space_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/shared_service_instances/#{params[:service_instance_guid]}/#{params[:target_space_guid]}")
      begin
        @operation.delete_shared_service_instance(params[:service_instance_guid], params[:target_space_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete shared service instance: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete shared service instance: #{error.inspect}")
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

    delete '/spaces/:space_guid/isolation_segment', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/spaces/#{params[:space_guid]}/isolation_segment")
      begin
        @operation.remove_space_isolation_segment(params[:space_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during remove space isolation segment: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during remove space isolation segment: #{error.inspect}")
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

    delete '/spaces/:space_guid/unmapped_routes', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/spaces/#{params[:space_guid]}/unmapped_routes")
      begin
        @operation.delete_space_unmapped_routes(params[:space_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete space unmapped routes: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete space unmapped_routes: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/stacks/:stack_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/stacks/#{params[:stack_guid]}")
      begin
        @operation.delete_stack(params[:stack_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete stack: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete stack: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/staging_security_groups/:staging_security_group_guid/:staging_space_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/staging_security_groups/#{params[:staging_security_group_guid]}/#{params[:staging_space_guid]}")
      begin
        @operation.delete_staging_security_group_space(params[:staging_security_group_guid], params[:staging_space_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete staging security group space: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete staging security group space: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/tasks/:task_guid/cancel', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/tasks/#{params[:task_guid]}/cancel")
      begin
        @operation.cancel_task(params[:task_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during cancel task: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during cancel task: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/users/:user_guid', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/users/#{params[:user_guid]}")
      begin
        @operation.delete_user(params[:user_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete user: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete user: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    delete '/users/:user_guid/tokens', auth: [:admin] do
      @logger.info_user(session[:username], 'delete', "/users/#{params[:user_guid]}/tokens")
      begin
        @operation.delete_user_tokens(params[:user_guid])
        204
      rescue CCRestClientResponseError => error
        @logger.error("Error during delete user tokens: #{error.to_h}")
        content_type(:json)
        status(error.http_code)
        body(Yajl::Encoder.encode(error.to_h))
      rescue => error
        @logger.error("Error during delete user tokens: #{error.inspect}")
        @logger.error(error.backtrace.join("\n"))
        500
      end
    end

    def route_missing
      [404, 'Page Not Found']
    end

    private

    def authenticated(username, role, authorized)
      @logger.info_user(username, 'authenticated', "role #{role}, authorized #{authorized}")

      session[:username] = username
      session[:role]     = role

      if authorized
        redirect 'application.html', 303
      else
        redirect "scopeError.html?user=#{username}", 303
      end
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
