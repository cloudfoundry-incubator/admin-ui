Sequel.migration do
  change do
    create_table(:app_usage_events, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      Integer :instance_count, :null=>false
      Integer :memory_in_mb_per_instance, :null=>false
      String :state, :text=>true, :null=>false
      String :app_guid, :text=>true, :null=>false
      String :app_name, :text=>true, :null=>false
      String :space_guid, :text=>true, :null=>false
      String :space_name, :text=>true, :null=>false
      String :org_guid, :text=>true, :null=>false
      String :buildpack_guid, :text=>true
      String :buildpack_name, :text=>true
      
      index [:guid], :unique=>true
      index [:created_at], :name=>:usage_events_created_at_index
    end
    
    create_table(:billing_events, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      DateTime :timestamp, :null=>false
      String :kind, :text=>true, :null=>false
      String :organization_guid, :text=>true, :null=>false
      String :organization_name, :text=>true, :null=>false
      String :space_guid, :text=>true
      String :space_name, :text=>true
      String :app_guid, :text=>true
      String :app_name, :text=>true
      String :app_plan_name, :text=>true
      String :app_run_id, :text=>true
      Integer :app_memory
      Integer :app_instance_count
      String :service_instance_guid, :text=>true
      String :service_instance_name, :text=>true
      String :service_guid, :text=>true
      String :service_label, :text=>true
      String :service_provider, :text=>true
      String :service_version, :text=>true
      String :service_plan_guid, :text=>true
      String :service_plan_name, :text=>true
      
      index [:created_at], :name=>:be_created_at_index
      index [:timestamp], :name=>:be_event_timestamp_index
      index [:guid], :name=>:be_guid_index, :unique=>true
      index [:updated_at], :name=>:be_updated_at_index
    end
    
    create_table(:buildpacks, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      String :name, :text=>true, :null=>false
      String :key, :text=>true
      Integer :position, :null=>false
      TrueClass :enabled, :default=>true
      TrueClass :locked, :default=>false
      String :filename, :text=>true
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:name], :unique=>true
      index [:updated_at]
    end
    
    create_table(:delayed_jobs, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      Integer :priority, :default=>0
      Integer :attempts, :default=>0
      String :handler, :text=>true
      String :last_error, :text=>true
      DateTime :run_at
      DateTime :locked_at
      DateTime :failed_at
      String :locked_by, :text=>true
      String :queue, :text=>true
      String :cf_api_error, :text=>true
      
      index [:priority, :run_at], :name=>:dj
      index [:created_at], :name=>:dj_created_at_index
      index [:guid], :name=>:dj_guid_index, :unique=>true
      index [:updated_at], :name=>:dj_updated_at_index
    end
    
    create_table(:droplets, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      Integer :app_id, :null=>false
      String :droplet_hash, :text=>true, :null=>false
      String :detected_start_command, :text=>true
      
      index [:app_id]
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:env_groups, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      String :name, :text=>true, :null=>false
      String :environment_json, :text=>true
      String :salt, :text=>true
      
      index [:name], :unique=>true
      index [:created_at], :name=>:evg_created_at_index
      index [:guid], :name=>:evg_guid_index, :unique=>true
      index [:updated_at], :name=>:evg_updated_at_index
    end
    
    create_table(:feature_flags, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      String :name, :text=>true, :null=>false
      TrueClass :enabled, :null=>false
      String :error_message, :text=>true
      
      index [:created_at], :name=>:feature_flag_created_at_index
      index [:guid], :name=>:feature_flag_guid_index, :unique=>true
      index [:updated_at], :name=>:feature_flag_updated_at_index
      index [:name], :unique=>true
    end
    
    create_table(:quota_definitions, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      String :name, :null=>false
      TrueClass :non_basic_services_allowed, :null=>false
      Integer :total_services, :null=>false
      Integer :memory_limit, :null=>false
      Integer :total_routes, :null=>false
      Integer :instance_memory_limit, :default=>-1, :null=>false
      
      index [:created_at], :name=>:qd_created_at_index
      index [:guid], :name=>:qd_guid_index, :unique=>true
      index [:name], :name=>:qd_name_index, :unique=>true
      index [:updated_at], :name=>:qd_updated_at_index
      index [:name], :name=>:quota_definitions_name_key, :unique=>true
    end
    
    create_table(:schema_migrations) do
      String :filename, :text=>true, :null=>false
      
      primary_key [:filename]
    end
    
    create_table(:security_groups, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      String :name, :text=>true, :null=>false
      String :rules, :size=>2048
      TrueClass :staging_default, :default=>false
      TrueClass :running_default, :default=>false
      
      index [:created_at], :name=>:sg_created_at_index
      index [:guid], :name=>:sg_guid_index
      index [:name], :name=>:sg_name_index
      index [:updated_at], :name=>:sg_updated_at_index
      index [:running_default], :name=>:sgs_running_default_index
      index [:staging_default], :name=>:sgs_staging_default_index
    end
    
    create_table(:service_auth_tokens, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      String :label, :null=>false
      String :provider, :null=>false
      String :token, :text=>true, :null=>false
      String :salt, :text=>true
      
      index [:created_at], :name=>:sat_created_at_index
      index [:guid], :name=>:sat_guid_index, :unique=>true
      index [:label, :provider], :name=>:sat_label_provider_index, :unique=>true
      index [:updated_at], :name=>:sat_updated_at_index
    end
    
    create_table(:service_brokers, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      String :name, :text=>true, :null=>false
      String :broker_url, :text=>true, :null=>false
      String :auth_password, :text=>true, :null=>false
      String :salt, :text=>true
      String :auth_username, :text=>true
      
      index [:broker_url], :name=>:sb_broker_url_index, :unique=>true
      index [:created_at], :name=>:sbrokers_created_at_index
      index [:guid], :name=>:sbrokers_guid_index, :unique=>true
      index [:updated_at], :name=>:sbrokers_updated_at_index
      index [:name], :unique=>true
    end
    
    create_table(:service_dashboard_clients, :ignore_index_errors=>true) do
      primary_key :id
      DateTime :created_at, :null=>false
      DateTime :updated_at
      String :uaa_id, :text=>true, :null=>false
      Integer :service_broker_id
      
      index [:created_at], :name=>:s_d_clients_created_at_index
      index [:uaa_id], :name=>:s_d_clients_uaa_id_unique, :unique=>true
      index [:updated_at], :name=>:s_d_clients_updated_at_index
      index [:service_broker_id], :name=>:svc_dash_cli_svc_brkr_id_idx
    end
    
    create_table(:service_usage_events, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      String :state, :text=>true, :null=>false
      String :org_guid, :text=>true, :null=>false
      String :space_guid, :text=>true, :null=>false
      String :space_name, :text=>true, :null=>false
      String :service_instance_guid, :text=>true, :null=>false
      String :service_instance_name, :text=>true, :null=>false
      String :service_instance_type, :text=>true, :null=>false
      String :service_plan_guid, :text=>true
      String :service_plan_name, :text=>true
      String :service_guid, :text=>true
      String :service_label, :text=>true
      
      index [:created_at], :name=>:created_at_index
      index [:guid], :name=>:usage_events_guid_index, :unique=>true
    end
    
    create_table(:stacks, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      String :name, :text=>true, :null=>false
      String :description, :text=>true, :null=>false
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:name], :unique=>true
      index [:updated_at]
    end
    
    create_table(:organizations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      String :name, :null=>false
      TrueClass :billing_enabled, :default=>false, :null=>false
      foreign_key :quota_definition_id, :quota_definitions, :null=>false, :key=>[:id]
      String :status, :default=>"active", :text=>true
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:name], :unique=>true
      index [:updated_at]
    end
    
    create_table(:services, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      String :label, :null=>false
      String :provider, :default=>"", :null=>false
      String :url, :text=>true
      String :description, :text=>true, :null=>false
      String :version, :text=>true
      String :info_url, :text=>true
      String :acls, :text=>true
      Integer :timeout
      TrueClass :active, :default=>false
      String :extra, :text=>true
      String :unique_id, :text=>true
      TrueClass :bindable, :null=>false
      String :tags, :text=>true
      String :documentation_url, :text=>true
      foreign_key :service_broker_id, :service_brokers, :key=>[:id]
      String :long_description, :text=>true
      String :requires, :text=>true
      TrueClass :purging, :default=>false, :null=>false
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:label]
      index [:label, :provider], :unique=>true
      index [:unique_id], :unique=>true
      index [:updated_at]
    end
    
    create_table(:domains, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      String :name, :null=>false
      TrueClass :wildcard, :default=>true, :null=>false
      foreign_key :owning_organization_id, :organizations, :key=>[:id]
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:name], :unique=>true
      index [:updated_at]
    end
    
    create_table(:service_plans, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      String :name, :null=>false
      String :description, :text=>true, :null=>false
      TrueClass :free, :null=>false
      foreign_key :service_id, :services, :null=>false, :key=>[:id]
      String :extra, :text=>true
      String :unique_id, :text=>true, :null=>false
      TrueClass :public, :default=>true
      TrueClass :active, :default=>true
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:unique_id], :unique=>true
      index [:updated_at]
      index [:service_id, :name], :name=>:svc_plan_svc_id_name_index, :unique=>true
    end
    
    create_table(:space_quota_definitions, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      String :name, :text=>true, :null=>false
      TrueClass :non_basic_services_allowed, :null=>false
      Integer :total_services, :null=>false
      Integer :memory_limit, :null=>false
      Integer :total_routes, :null=>false
      Integer :instance_memory_limit, :default=>-1, :null=>false
      foreign_key :organization_id, :organizations, :null=>false, :key=>[:id]
      
      index [:created_at], :name=>:sqd_created_at_index
      index [:guid], :name=>:sqd_guid_index, :unique=>true
      index [:organization_id, :name], :name=>:sqd_org_id_index, :unique=>true
      index [:updated_at], :name=>:sqd_updated_at_index
    end
    
    create_table(:service_plan_visibilities, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      foreign_key :service_plan_id, :service_plans, :null=>false, :key=>[:id]
      foreign_key :organization_id, :organizations, :null=>false, :key=>[:id]
      
      index [:created_at], :name=>:spv_created_at_index
      index [:guid], :name=>:spv_guid_index, :unique=>true
      index [:organization_id, :service_plan_id], :name=>:spv_org_id_sp_id_index, :unique=>true
      index [:updated_at], :name=>:spv_updated_at_index
    end
    
    create_table(:spaces, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      String :name, :null=>false
      foreign_key :organization_id, :organizations, :null=>false, :key=>[:id]
      foreign_key :space_quota_definition_id, :space_quota_definitions, :key=>[:id]
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:organization_id, :name], :name=>:spaces_org_id_name_index, :unique=>true
      index [:updated_at]
    end
    
    create_table(:apps, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      String :name, :null=>false
      TrueClass :production, :default=>false
      Integer :memory
      Integer :instances, :default=>1
      Integer :file_descriptors, :default=>16384
      Integer :disk_quota, :default=>2048
      String :state, :default=>"STOPPED", :text=>true, :null=>false
      String :package_state, :default=>"PENDING", :text=>true, :null=>false
      String :package_hash, :text=>true
      String :droplet_hash, :text=>true
      String :version, :text=>true
      String :metadata, :default=>"{}", :text=>true, :null=>false
      String :buildpack, :text=>true
      foreign_key :space_id, :spaces, :null=>false, :key=>[:id]
      foreign_key :stack_id, :stacks, :null=>false, :key=>[:id]
      String :detected_buildpack, :text=>true
      String :staging_task_id, :text=>true
      TrueClass :kill_after_multiple_restarts, :default=>false
      DateTime :deleted_at
      TrueClass :not_deleted, :default=>true
      String :salt, :text=>true
      String :encrypted_environment_json, :text=>true
      Integer :admin_buildpack_id
      Integer :health_check_timeout
      String :detected_buildpack_guid, :text=>true
      String :detected_buildpack_name, :text=>true
      String :staging_failed_reason, :text=>true
      TrueClass :diego, :default=>false
      String :docker_image, :text=>true
      DateTime :package_updated_at
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:name]
      index [:space_id, :name, :not_deleted], :name=>:apps_space_id_name_nd_idx, :unique=>true
      index [:updated_at]
    end
    
    create_table(:events, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      DateTime :timestamp, :null=>false
      String :type, :text=>true, :null=>false
      String :actor, :text=>true, :null=>false
      String :actor_type, :text=>true, :null=>false
      String :actee, :text=>true, :null=>false
      String :actee_type, :text=>true, :null=>false
      String :metadata, :text=>true
      foreign_key :space_id, :spaces, :key=>[:id], :on_delete=>:set_null
      String :organization_guid, :default=>"", :text=>true, :null=>false
      String :space_guid, :default=>"", :text=>true, :null=>false
      String :actor_name, :text=>true
      String :actee_name, :text=>true
      
      index [:actee]
      index [:created_at]
      index [:guid], :unique=>true
      index [:timestamp]
      index [:type]
      index [:updated_at]
    end
    
    create_table(:routes, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      String :host, :default=>"", :null=>false
      foreign_key :domain_id, :domains, :null=>false, :key=>[:id]
      foreign_key :space_id, :spaces, :null=>false, :key=>[:id]
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:host, :domain_id], :unique=>true
      index [:updated_at]
    end
    
    create_table(:security_groups_spaces, :ignore_index_errors=>true) do
      foreign_key :security_group_id, :security_groups, :null=>false, :key=>[:id]
      foreign_key :space_id, :spaces, :null=>false, :key=>[:id]
      
      index [:security_group_id, :space_id], :name=>:sgs_spaces_ids
    end
    
    create_table(:service_instances, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      String :name, :size=>50, :null=>false
      String :credentials, :text=>true
      String :gateway_name, :text=>true
      String :gateway_data, :size=>2048
      foreign_key :space_id, :spaces, :null=>false, :key=>[:id]
      foreign_key :service_plan_id, :service_plans, :key=>[:id]
      String :salt, :text=>true
      String :dashboard_url, :text=>true
      TrueClass :is_gateway_service, :default=>true, :null=>false
      String :syslog_drain_url, :text=>true
      
      index [:name]
      index [:created_at], :name=>:si_created_at_index
      index [:gateway_name], :name=>:si_gateway_name_index
      index [:guid], :name=>:si_guid_index, :unique=>true
      index [:space_id, :name], :name=>:si_space_id_name_index, :unique=>true
      index [:updated_at], :name=>:si_updated_at_index
    end
    
    create_table(:users, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      foreign_key :default_space_id, :spaces, :key=>[:id]
      TrueClass :admin, :default=>false
      TrueClass :active, :default=>false
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:app_events, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      foreign_key :app_id, :apps, :null=>false, :key=>[:id]
      String :instance_guid, :text=>true, :null=>false
      Integer :instance_index, :null=>false
      Integer :exit_status, :null=>false
      DateTime :timestamp, :null=>false
      String :exit_description, :text=>true
      
      index [:app_id]
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:apps_routes, :ignore_index_errors=>true) do
      foreign_key :app_id, :apps, :null=>false, :key=>[:id]
      foreign_key :route_id, :routes, :null=>false, :key=>[:id]
      
      index [:app_id, :route_id], :name=>:ar_app_id_route_id_index, :unique=>true
    end
    
    create_table(:organizations_auditors, :ignore_index_errors=>true) do
      foreign_key :organization_id, :organizations, :null=>false, :key=>[:id]
      foreign_key :user_id, :users, :null=>false, :key=>[:id]
      
      index [:organization_id, :user_id], :name=>:org_auditors_idx, :unique=>true
    end
    
    create_table(:organizations_billing_managers, :ignore_index_errors=>true) do
      foreign_key :organization_id, :organizations, :null=>false, :key=>[:id]
      foreign_key :user_id, :users, :null=>false, :key=>[:id]
      
      index [:organization_id, :user_id], :name=>:org_billing_managers_idx, :unique=>true
    end
    
    create_table(:organizations_managers, :ignore_index_errors=>true) do
      foreign_key :organization_id, :organizations, :null=>false, :key=>[:id]
      foreign_key :user_id, :users, :null=>false, :key=>[:id]
      
      index [:organization_id, :user_id], :name=>:org_managers_idx, :unique=>true
    end
    
    create_table(:organizations_users, :ignore_index_errors=>true) do
      foreign_key :organization_id, :organizations, :null=>false, :key=>[:id]
      foreign_key :user_id, :users, :null=>false, :key=>[:id]
      
      index [:organization_id, :user_id], :name=>:org_users_idx, :unique=>true
    end
    
    create_table(:service_bindings, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at
      String :credentials, :text=>true, :null=>false
      String :binding_options, :text=>true
      String :gateway_name, :default=>"", :text=>true, :null=>false
      String :configuration, :text=>true
      String :gateway_data, :text=>true
      foreign_key :app_id, :apps, :null=>false, :key=>[:id]
      foreign_key :service_instance_id, :service_instances, :null=>false, :key=>[:id]
      String :salt, :text=>true
      String :syslog_drain_url, :text=>true
      
      index [:app_id, :service_instance_id], :name=>:sb_app_id_srv_inst_id_index, :unique=>true
      index [:created_at], :name=>:sb_created_at_index
      index [:guid], :name=>:sb_guid_index, :unique=>true
      index [:updated_at], :name=>:sb_updated_at_index
    end
    
    create_table(:spaces_auditors, :ignore_index_errors=>true) do
      foreign_key :space_id, :spaces, :null=>false, :key=>[:id]
      foreign_key :user_id, :users, :null=>false, :key=>[:id]
      
      index [:space_id, :user_id], :name=>:space_auditors_idx, :unique=>true
    end
    
    create_table(:spaces_developers, :ignore_index_errors=>true) do
      foreign_key :space_id, :spaces, :null=>false, :key=>[:id]
      foreign_key :user_id, :users, :null=>false, :key=>[:id]
      
      index [:space_id, :user_id], :name=>:space_developers_idx, :unique=>true
    end
    
    create_table(:spaces_managers, :ignore_index_errors=>true) do
      foreign_key :space_id, :spaces, :null=>false, :key=>[:id]
      foreign_key :user_id, :users, :null=>false, :key=>[:id]
      
      index [:space_id, :user_id], :name=>:space_managers_idx, :unique=>true
    end
  end
end
