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
      String :package_state, :text=>true
      String :parent_app_name, :text=>true
      String :parent_app_guid, :text=>true
      String :process_type, :text=>true
      String :task_guid, :text=>true
      String :task_name, :text=>true
      String :package_guid, :text=>true
      String :previous_state, :text=>true
      String :previous_package_state, :text=>true
      Integer :previous_memory_in_mb_per_instance
      Integer :previous_instance_count
      
      index [:guid], :unique=>true
      index [:created_at], :name=>:usage_events_created_at_index
    end
    
    create_table(:buildpack_lifecycle_data, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :app_guid, :text=>true
      String :droplet_guid, :text=>true
      String :stack, :text=>true
      String :encrypted_buildpack_url, :text=>true
      String :encrypted_buildpack_url_salt, :text=>true
      String :admin_buildpack_name, :text=>true
      String :build_guid, :text=>true
      String :encryption_key_label, :size=>255
      Integer :encryption_iterations, :default=>2048, :null=>false
      
      index [:droplet_guid], :name=>:bp_lifecycle_data_droplet_guid
      index [:admin_buildpack_name]
      index [:app_guid], :name=>:buildpack_lifecycle_data_app_guid
      index [:build_guid]
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:buildpacks, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :name, :text=>true, :null=>false
      String :key, :text=>true
      Integer :position, :null=>false
      TrueClass :enabled, :default=>true
      TrueClass :locked, :default=>false
      String :filename, :text=>true
      String :sha256_checksum, :text=>true
      String :stack, :size=>255
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:key]
      index [:updated_at]
      index [:name, :stack], :name=>:unique_name_and_stack, :unique=>true
    end
    
    create_table(:clock_jobs, :ignore_index_errors=>true) do
      primary_key :id
      String :name, :text=>true, :null=>false
      DateTime :last_started_at
      DateTime :last_completed_at
      
      index [:name], :name=>:clock_jobs_name_unique, :unique=>true
    end
    
    create_table(:delayed_jobs, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
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
      
      index [:queue, :locked_at, :locked_by, :failed_at, :run_at], :name=>:delayed_jobs_reserve
      index [:created_at], :name=>:dj_created_at_index
      index [:guid], :name=>:dj_guid_index, :unique=>true
      index [:updated_at], :name=>:dj_updated_at_index
    end
    
    create_table(:encryption_key_sentinels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :expected_value, :size=>255
      String :encrypted_value, :size=>255
      String :encryption_key_label, :size=>255
      String :salt, :size=>255
      Integer :encryption_iterations, :default=>2048, :null=>false
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:encryption_key_label], :name=>:encryption_key_sentinels_label_index, :unique=>true
      index [:updated_at]
    end
    
    create_table(:env_groups, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :name, :text=>true, :null=>false
      String :environment_json, :text=>true
      String :salt, :text=>true
      String :encryption_key_label, :size=>255
      Integer :encryption_iterations, :default=>2048, :null=>false
      
      index [:name], :unique=>true
      index [:created_at], :name=>:evg_created_at_index
      index [:guid], :name=>:evg_guid_index, :unique=>true
      index [:updated_at], :name=>:evg_updated_at_index
    end
    
    create_table(:events, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      DateTime :timestamp, :null=>false
      String :type, :text=>true, :null=>false
      String :actor, :text=>true, :null=>false
      String :actor_type, :text=>true, :null=>false
      String :actee, :text=>true, :null=>false
      String :actee_type, :text=>true, :null=>false
      String :metadata, :text=>true
      String :organization_guid, :default=>"", :text=>true, :null=>false
      String :space_guid, :default=>"", :text=>true, :null=>false
      String :actor_name, :text=>true
      String :actee_name, :text=>true
      String :actor_username, :text=>true
      
      index [:actee]
      index [:actee_type]
      index [:created_at]
      index [:guid], :unique=>true
      index [:organization_guid]
      index [:space_guid]
      index [:timestamp, :id]
      index [:type]
      index [:updated_at]
    end
    
    create_table(:feature_flags, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :name, :text=>true, :null=>false
      TrueClass :enabled, :null=>false
      String :error_message, :text=>true
      
      index [:created_at], :name=>:feature_flag_created_at_index
      index [:guid], :name=>:feature_flag_guid_index, :unique=>true
      index [:updated_at], :name=>:feature_flag_updated_at_index
      index [:name], :unique=>true
    end
    
    create_table(:isolation_segments, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :name, :null=>false
      
      index [:name], :name=>:isolation_segment_name_unique_constraint, :unique=>true
      index [:created_at]
      index [:guid], :unique=>true
      index [:name]
      index [:updated_at]
    end
    
    create_table(:jobs, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :state, :text=>true
      String :operation, :text=>true
      String :resource_guid, :text=>true
      String :resource_type, :text=>true
      String :delayed_job_guid, :text=>true
      String :cf_api_error, :size=>16000
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:lockings, :ignore_index_errors=>true) do
      primary_key :id
      String :name, :text=>true, :null=>false
      
      index [:name], :unique=>true
    end
    
    create_table(:orphaned_blobs, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :blob_key, :text=>true
      Integer :dirty_count
      String :blobstore_type, :text=>true
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:blob_key, :blobstore_type], :name=>:orphaned_blobs_unique_blob_index, :unique=>true
      index [:updated_at]
    end
    
    create_table(:quota_definitions, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :name, :null=>false
      TrueClass :non_basic_services_allowed, :null=>false
      Integer :total_services, :null=>false
      Integer :memory_limit, :null=>false
      Integer :total_routes, :null=>false
      Integer :instance_memory_limit, :null=>false
      Integer :total_private_domains, :null=>false
      Integer :app_instance_limit
      Integer :app_task_limit
      Integer :total_service_keys
      Integer :total_reserved_route_ports, :default=>0
      
      index [:created_at], :name=>:qd_created_at_index
      index [:guid], :name=>:qd_guid_index, :unique=>true
      index [:name], :name=>:qd_name_index, :unique=>true
      index [:updated_at], :name=>:qd_updated_at_index
      index [:name], :name=>:quota_definitions_name_key, :unique=>true
    end
    
    create_table(:request_counts, :ignore_index_errors=>true) do
      primary_key :id
      String :user_guid, :text=>true
      Integer :count, :default=>0
      DateTime :valid_until
      
      index [:user_guid]
    end
    
    create_table(:schema_migrations) do
      String :filename, :text=>true, :null=>false
      
      primary_key [:filename]
    end
    
    create_table(:security_groups, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :name, :text=>true, :null=>false
      String :rules, :text=>true
      TrueClass :staging_default, :default=>false
      TrueClass :running_default, :default=>false
      
      index [:created_at], :name=>:sg_created_at_index
      index [:guid], :name=>:sg_guid_index
      index [:name], :name=>:sg_name_index
      index [:updated_at], :name=>:sg_updated_at_index
      index [:running_default], :name=>:sgs_running_default_index
      index [:staging_default], :name=>:sgs_staging_default_index
    end
    
    create_table(:service_dashboard_clients, :ignore_index_errors=>true) do
      primary_key :id
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
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
      String :service_broker_name, :text=>true
      String :service_broker_guid, :size=>255
      
      index [:created_at], :name=>:created_at_index
      index [:service_guid]
      index [:service_instance_type]
      index [:guid], :name=>:usage_events_guid_index, :unique=>true
    end
    
    create_table(:stacks, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :name, :text=>true, :null=>false
      String :description, :text=>true
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:name], :unique=>true
      index [:updated_at]
    end
    
    create_table(:buildpack_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :buildpacks, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
      index [:resource_guid], :name=>:fk_buildpack_annotations_resource_guid_index
    end
    
    create_table(:buildpack_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :buildpacks, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:key_prefix, :key_name, :value], :name=>:buildpack_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
      index [:resource_guid], :name=>:fk_buildpack_labels_resource_guid_index
    end
    
    create_table(:buildpack_lifecycle_buildpacks, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :admin_buildpack_name, :text=>true
      String :encrypted_buildpack_url, :size=>16000
      String :encrypted_buildpack_url_salt, :text=>true
      foreign_key :buildpack_lifecycle_data_guid, :buildpack_lifecycle_data, :type=>String, :text=>true, :key=>[:guid]
      String :encryption_key_label, :size=>255
      String :version, :size=>255
      String :buildpack_name, :size=>2047
      Integer :encryption_iterations, :default=>2048, :null=>false
      
      index [:buildpack_lifecycle_data_guid], :name=>:bl_buildpack_bldata_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:isolation_segment_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :isolation_segments, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:resource_guid], :name=>:fk_isolation_segment_annotations_resource_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:isolation_segment_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :isolation_segments, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:resource_guid], :name=>:fk_isolation_segment_labels_resource_guid_index
      index [:key_prefix, :key_name, :value], :name=>:isolation_segment_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:job_warnings, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :detail, :size=>16000, :null=>false
      Integer :job_id, :null=>false
      foreign_key :fk_jobs_id, :jobs, :key=>[:id]
      
      index [:job_id], :name=>:fk_jobs_id_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:stack_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :stacks, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:resource_guid], :name=>:fk_stack_annotations_resource_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:stack_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :stacks, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:resource_guid], :name=>:fk_stack_labels_resource_guid_index
      index [:key_prefix, :key_name, :value], :name=>:stack_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:app_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :resource_guid, :size=>255
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
      index [:resource_guid], :name=>:fk_app_annotations_resource_guid_index
    end
    
    create_table(:app_events, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      Integer :app_id, :null=>false
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
    
    create_table(:app_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :resource_guid, :size=>255
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:key_prefix, :key_name, :value], :name=>:app_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
      index [:resource_guid], :name=>:fk_app_labels_resource_guid_index
    end
    
    create_table(:apps, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :space_guid, :text=>true
      String :name
      String :droplet_guid, :text=>true
      String :desired_state, :default=>"STOPPED", :text=>true
      String :encrypted_environment_variables, :text=>true
      String :salt, :text=>true
      Integer :max_task_sequence_id, :default=>1
      String :buildpack_cache_sha256_checksum, :text=>true
      TrueClass :enable_ssh
      String :encryption_key_label, :size=>255
      Integer :encryption_iterations, :default=>2048, :null=>false
      TrueClass :revisions_enabled, :default=>true
      
      index [:droplet_guid], :name=>:apps_desired_droplet_guid
      index [:created_at], :name=>:apps_v3_created_at_index
      index [:guid], :name=>:apps_v3_guid_index, :unique=>true
      index [:name], :name=>:apps_v3_name_index
      index [:space_guid], :name=>:apps_v3_space_guid_index
      index [:space_guid, :name], :name=>:apps_v3_space_guid_name_index, :unique=>true
      index [:updated_at], :name=>:apps_v3_updated_at_index
    end
    
    create_table(:builds, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :state, :text=>true
      String :package_guid, :text=>true
      String :error_description, :text=>true
      foreign_key :app_guid, :apps, :type=>String, :text=>true, :key=>[:guid]
      String :error_id, :text=>true
      String :created_by_user_guid, :text=>true
      String :created_by_user_name, :text=>true
      String :created_by_user_email, :text=>true
      
      index [:app_guid]
      index [:created_at]
      index [:guid], :unique=>true
      index [:state]
      index [:updated_at]
    end
    
    create_table(:deployments, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :state, :size=>255
      foreign_key :app_guid, :apps, :type=>String, :size=>255, :key=>[:guid]
      String :droplet_guid, :size=>255
      String :deploying_web_process_guid, :size=>255
      String :previous_droplet_guid, :size=>255
      Integer :original_web_process_instance_count, :null=>false
      String :revision_guid, :size=>255
      Integer :revision_version
      DateTime :last_healthy_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      String :status_value, :size=>255
      String :status_reason, :size=>255
      String :strategy, :default=>"rolling", :size=>255, :null=>false
      
      index [:app_guid]
      index [:created_at]
      index [:guid], :unique=>true
      index [:state]
      index [:status_reason]
      index [:status_value]
      index [:updated_at]
    end
    
    create_table(:droplets, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :droplet_hash, :text=>true
      String :execution_metadata, :text=>true
      String :state, :text=>true, :null=>false
      String :process_types, :text=>true
      String :error_id, :text=>true
      String :error_description, :text=>true
      String :encrypted_environment_variables, :text=>true
      String :salt, :text=>true
      Integer :staging_memory_in_mb
      Integer :staging_disk_in_mb
      String :buildpack_receipt_buildpack, :text=>true
      String :buildpack_receipt_buildpack_guid, :text=>true
      String :buildpack_receipt_detect_output, :text=>true
      String :docker_receipt_image, :text=>true
      String :package_guid, :text=>true
      foreign_key :app_guid, :apps, :type=>String, :text=>true, :key=>[:guid]
      String :sha256_checksum, :text=>true
      String :build_guid, :text=>true
      String :docker_receipt_username, :text=>true
      String :docker_receipt_password_salt, :text=>true
      String :encrypted_docker_receipt_password, :size=>16000
      String :encryption_key_label, :size=>255
      Integer :encryption_iterations, :default=>2048, :null=>false
      String :sidecars, :text=>true
      
      index [:app_guid], :name=>:droplet_app_guid_index
      index [:build_guid], :name=>:droplet_build_guid_index
      index [:created_at]
      index [:droplet_hash]
      index [:guid, :droplet_hash]
      index [:guid], :unique=>true
      index [:sha256_checksum]
      index [:state]
      index [:updated_at]
      index [:package_guid], :name=>:package_guid_index
    end
    
    create_table(:packages, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :type, :text=>true
      String :package_hash, :text=>true
      String :state, :text=>true, :null=>false
      String :error, :text=>true
      foreign_key :app_guid, :apps, :type=>String, :text=>true, :key=>[:guid]
      String :docker_image, :text=>true
      String :sha256_checksum, :text=>true
      String :docker_username, :text=>true
      String :docker_password_salt, :text=>true
      String :encrypted_docker_password, :size=>16000
      String :encryption_key_label, :size=>255
      Integer :encryption_iterations, :default=>2048, :null=>false
      
      index [:app_guid], :name=>:package_app_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:state]
      index [:type]
      index [:updated_at]
    end
    
    create_table(:processes, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      TrueClass :production, :default=>false
      Integer :memory
      Integer :instances, :default=>1
      Integer :file_descriptors, :default=>16384
      Integer :disk_quota, :default=>2048
      String :state, :default=>"STOPPED", :text=>true, :null=>false
      String :version, :text=>true
      String :metadata, :default=>"{}", :size=>4096, :null=>false
      String :detected_buildpack, :text=>true
      TrueClass :not_deleted, :default=>true
      Integer :health_check_timeout
      TrueClass :diego, :default=>false
      DateTime :package_updated_at
      foreign_key :app_guid, :apps, :type=>String, :text=>true, :key=>[:guid]
      String :type, :default=>"web", :text=>true
      String :health_check_type, :default=>"port", :text=>true
      String :command, :size=>4096
      TrueClass :enable_ssh, :default=>false
      String :encrypted_docker_credentials_json, :text=>true
      String :docker_salt, :text=>true
      String :ports, :text=>true
      String :health_check_http_endpoint, :text=>true
      Integer :health_check_invocation_timeout
      String :revision_guid, :size=>255
      
      index [:created_at], :name=>:apps_created_at_index
      index [:diego], :name=>:apps_diego_index
      index [:guid], :name=>:apps_guid_index, :unique=>true
      index [:updated_at], :name=>:apps_updated_at_index
      index [:app_guid]
    end
    
    create_table(:revisions, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :app_guid, :apps, :type=>String, :size=>255, :key=>[:guid]
      Integer :version, :default=>1
      String :droplet_guid, :size=>255
      String :encrypted_environment_variables, :text=>true
      String :salt, :size=>255
      String :encryption_key_label, :size=>255
      Integer :encryption_iterations, :default=>2048, :null=>false
      String :description, :default=>"N/A", :text=>true, :null=>false
      
      index [:app_guid], :name=>:fk_revision_app_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:sidecars, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :name, :size=>255, :null=>false
      String :command, :size=>4096, :null=>false
      foreign_key :app_guid, :apps, :type=>String, :size=>255, :null=>false, :key=>[:guid]
      Integer :memory
      String :origin, :default=>"user", :size=>255, :null=>false
      
      index [:app_guid], :name=>:fk_sidecar_app_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:tasks, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :name, :null=>false
      String :command, :text=>true, :null=>false
      String :state, :text=>true, :null=>false
      Integer :memory_in_mb
      String :encrypted_environment_variables, :text=>true
      String :salt, :text=>true
      String :failure_reason, :size=>4096
      foreign_key :app_guid, :apps, :type=>String, :text=>true, :null=>false, :key=>[:guid]
      String :droplet_guid, :text=>true, :null=>false
      Integer :sequence_id
      Integer :disk_in_mb
      String :encryption_key_label, :size=>255
      Integer :encryption_iterations, :default=>2048, :null=>false
      
      index [:app_guid]
      index [:created_at]
      index [:guid], :unique=>true
      index [:name]
      index [:state]
      index [:updated_at]
      index [:app_guid, :sequence_id], :name=>:unique_task_app_guid_sequence_id, :unique=>true
    end
    
    create_table(:build_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :builds, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
      index [:resource_guid], :name=>:fk_build_annotations_resource_guid_index
    end
    
    create_table(:build_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :builds, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:key_prefix, :key_name, :value], :name=>:build_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
      index [:resource_guid], :name=>:fk_build_labels_resource_guid_index
    end
    
    create_table(:deployment_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :deployments, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
      index [:resource_guid], :name=>:fk_deployment_annotations_resource_guid_index
    end
    
    create_table(:deployment_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :deployments, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:key_prefix, :key_name, :value], :name=>:deployment_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
      index [:resource_guid], :name=>:fk_deployment_labels_resource_guid_index
    end
    
    create_table(:deployment_processes, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :process_guid, :size=>255
      String :process_type, :size=>255
      foreign_key :deployment_guid, :deployments, :type=>String, :size=>255, :key=>[:guid]
      
      index [:created_at]
      index [:deployment_guid]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:droplet_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :droplets, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
      index [:resource_guid], :name=>:fk_droplet_annotations_resource_guid_index
    end
    
    create_table(:droplet_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :droplets, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:key_prefix, :key_name, :value], :name=>:droplet_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
      index [:resource_guid], :name=>:fk_droplet_labels_resource_guid_index
    end
    
    create_table(:kpack_lifecycle_data, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :build_guid, :builds, :type=>String, :size=>255, :key=>[:guid]
      String :droplet_guid, :size=>255
      foreign_key :app_guid, :apps, :type=>String, :size=>255, :key=>[:guid]
      String :buildpacks, :default=>"[]", :size=>5000
      
      index [:build_guid], :name=>:fk_kpack_lifecycle_build_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
      index [:droplet_guid], :name=>:kpack_lifecycle_droplet_guid_index
    end
    
    create_table(:package_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :packages, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:resource_guid], :name=>:fk_package_annotations_resource_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:package_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :packages, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:resource_guid], :name=>:fk_package_labels_resource_guid_index
      index [:key_prefix, :key_name, :value], :name=>:package_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:process_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :processes, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:resource_guid], :name=>:fk_process_annotations_resource_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:process_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :processes, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:resource_guid], :name=>:fk_process_labels_resource_guid_index
      index [:key_prefix, :key_name, :value], :name=>:process_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:revision_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :revisions, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:resource_guid], :name=>:fk_revision_annotations_resource_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:revision_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :revisions, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:resource_guid], :name=>:fk_revision_labels_resource_guid_index
      index [:key_prefix, :key_name, :value], :name=>:revision_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:revision_process_commands, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :revision_guid, :revisions, :type=>String, :size=>255, :null=>false, :key=>[:guid]
      String :process_type, :size=>255, :null=>false
      String :process_command, :size=>4096
      
      index [:revision_guid], :name=>:rev_commands_revision_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:revision_sidecars, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :name, :size=>255, :null=>false
      String :command, :size=>4096, :null=>false
      foreign_key :revision_guid, :revisions, :type=>String, :size=>255, :null=>false, :key=>[:guid]
      Integer :memory
      
      index [:revision_guid], :name=>:fk_sidecar_revision_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:sidecar_process_types, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :type, :size=>255, :null=>false
      foreign_key :sidecar_guid, :sidecars, :type=>String, :size=>255, :null=>false, :key=>[:guid]
      String :app_guid, :size=>255, :null=>false
      
      index [:sidecar_guid], :name=>:fk_sidecar_proc_type_sidecar_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:task_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :tasks, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:resource_guid], :name=>:fk_task_annotations_resource_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:task_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :tasks, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:resource_guid], :name=>:fk_task_labels_resource_guid_index
      index [:key_prefix, :key_name, :value], :name=>:task_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:revision_sidecar_process_types, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :type, :size=>255, :null=>false
      foreign_key :revision_sidecar_guid, :revision_sidecars, :type=>String, :size=>255, :null=>false, :key=>[:guid]
      
      index [:revision_sidecar_guid], :name=>:fk_revision_sidecar_proc_type_sidecar_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:domain_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :resource_guid, :size=>255
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
      index [:resource_guid], :name=>:fk_domain_annotations_resource_guid_index
    end
    
    create_table(:domain_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :resource_guid, :size=>255
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:key_prefix, :key_name, :value], :name=>:domain_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
      index [:resource_guid], :name=>:fk_domain_labels_resource_guid_index
    end
    
    create_table(:domains, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :name, :null=>false
      TrueClass :wildcard, :default=>true, :null=>false
      Integer :owning_organization_id
      String :router_group_guid, :text=>true
      TrueClass :internal, :default=>false
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:name], :unique=>true
      index [:updated_at]
    end
    
    create_table(:organization_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :resource_guid, :size=>255
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:resource_guid], :name=>:fk_organization_annotations_resource_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:organization_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :resource_guid, :size=>255
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:resource_guid], :name=>:fk_organization_labels_resource_guid_index
      index [:key_prefix, :key_name, :value], :name=>:organization_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:organizations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :name, :null=>false
      TrueClass :billing_enabled, :default=>false, :null=>false
      foreign_key :quota_definition_id, :quota_definitions, :null=>false, :key=>[:id]
      String :status, :default=>"active", :text=>true
      String :default_isolation_segment_guid, :text=>true
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:name], :unique=>true
      index [:updated_at]
    end
    
    create_table(:organizations_isolation_segments) do
      foreign_key :organization_guid, :organizations, :type=>String, :text=>true, :null=>false, :key=>[:guid]
      foreign_key :isolation_segment_guid, :isolation_segments, :type=>String, :text=>true, :null=>false, :key=>[:guid]
      
      primary_key [:organization_guid, :isolation_segment_guid]
    end
    
    create_table(:organizations_private_domains, :ignore_index_errors=>true) do
      foreign_key :organization_id, :organizations, :null=>false, :key=>[:id]
      foreign_key :private_domain_id, :domains, :null=>false, :key=>[:id]
      primary_key :organizations_private_domains_pk, :keep_order=>true
      
      index [:organization_id, :private_domain_id], :name=>:orgs_pd_ids, :unique=>true
    end
    
    create_table(:space_quota_definitions, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :name, :text=>true, :null=>false
      TrueClass :non_basic_services_allowed, :null=>false
      Integer :total_services, :null=>false
      Integer :memory_limit, :null=>false
      Integer :total_routes, :null=>false
      Integer :instance_memory_limit, :null=>false
      foreign_key :organization_id, :organizations, :null=>false, :key=>[:id]
      Integer :app_instance_limit
      Integer :app_task_limit, :default=>5
      Integer :total_service_keys, :null=>false
      Integer :total_reserved_route_ports
      
      index [:created_at], :name=>:sqd_created_at_index
      index [:guid], :name=>:sqd_guid_index, :unique=>true
      index [:organization_id, :name], :name=>:sqd_org_id_index, :unique=>true
      index [:updated_at], :name=>:sqd_updated_at_index
    end
    
    create_table(:spaces, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :name, :null=>false
      foreign_key :organization_id, :organizations, :null=>false, :key=>[:id]
      foreign_key :space_quota_definition_id, :space_quota_definitions, :key=>[:id]
      TrueClass :allow_ssh, :default=>true
      foreign_key :isolation_segment_guid, :isolation_segments, :type=>String, :text=>true, :key=>[:guid]
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:organization_id, :name], :name=>:spaces_org_id_name_index, :unique=>true
      index [:updated_at]
    end
    
    create_table(:routes, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :host, :default=>"", :null=>false
      foreign_key :domain_id, :domains, :null=>false, :key=>[:id]
      foreign_key :space_id, :spaces, :null=>false, :key=>[:id]
      String :path, :default=>"", :null=>false
      Integer :port, :default=>0, :null=>false
      Integer :vip_offset
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:host, :domain_id, :path, :port], :unique=>true
      index [:updated_at]
      index [:vip_offset], :unique=>true
    end
    
    create_table(:security_groups_spaces, :ignore_index_errors=>true) do
      foreign_key :security_group_id, :security_groups, :null=>false, :key=>[:id]
      foreign_key :space_id, :spaces, :null=>false, :key=>[:id]
      primary_key :security_groups_spaces_pk, :keep_order=>true
      
      index [:security_group_id, :space_id], :name=>:sgs_spaces_ids
    end
    
    create_table(:service_brokers, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :name, :text=>true, :null=>false
      String :broker_url, :text=>true, :null=>false
      String :auth_password, :text=>true, :null=>false
      String :salt, :text=>true
      String :auth_username, :text=>true
      foreign_key :space_id, :spaces, :key=>[:id]
      String :encryption_key_label, :size=>255
      Integer :encryption_iterations, :default=>2048, :null=>false
      String :state, :default=>"", :size=>255, :null=>false
      
      index [:broker_url], :name=>:sb_broker_url_index
      index [:created_at], :name=>:sbrokers_created_at_index
      index [:guid], :name=>:sbrokers_guid_index, :unique=>true
      index [:updated_at], :name=>:sbrokers_updated_at_index
      index [:name], :unique=>true
    end
    
    create_table(:space_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :spaces, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:resource_guid], :name=>:fk_space_annotations_resource_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:space_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :spaces, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:resource_guid], :name=>:fk_space_labels_resource_guid_index
      index [:key_prefix, :key_name, :value], :name=>:space_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:staging_security_groups_spaces, :ignore_index_errors=>true) do
      foreign_key :staging_security_group_id, :security_groups, :null=>false, :key=>[:id]
      foreign_key :staging_space_id, :spaces, :null=>false, :key=>[:id]
      primary_key :staging_security_groups_spaces_pk, :keep_order=>true
      
      index [:staging_security_group_id, :staging_space_id], :name=>:staging_security_groups_spaces_ids, :unique=>true
    end
    
    create_table(:users, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :default_space_id, :spaces, :key=>[:id]
      TrueClass :admin, :default=>false
      TrueClass :active, :default=>false
      TrueClass :is_oauth_client
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:organizations_auditors, :ignore_index_errors=>true) do
      foreign_key :organization_id, :organizations, :null=>false, :key=>[:id]
      foreign_key :user_id, :users, :null=>false, :key=>[:id]
      primary_key :organizations_auditors_pk, :keep_order=>true
      String :role_guid, :size=>255
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      
      index [:organization_id, :user_id], :name=>:org_auditors_idx, :unique=>true
      index [:created_at]
      index [:role_guid]
      index [:updated_at]
    end
    
    create_table(:organizations_billing_managers, :ignore_index_errors=>true) do
      foreign_key :organization_id, :organizations, :null=>false, :key=>[:id]
      foreign_key :user_id, :users, :null=>false, :key=>[:id]
      primary_key :organizations_billing_managers_pk, :keep_order=>true
      String :role_guid, :size=>255
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      
      index [:organization_id, :user_id], :name=>:org_billing_managers_idx, :unique=>true
      index [:created_at]
      index [:role_guid]
      index [:updated_at]
    end
    
    create_table(:organizations_managers, :ignore_index_errors=>true) do
      foreign_key :organization_id, :organizations, :null=>false, :key=>[:id]
      foreign_key :user_id, :users, :null=>false, :key=>[:id]
      primary_key :organizations_managers_pk, :keep_order=>true
      String :role_guid, :size=>255
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      
      index [:organization_id, :user_id], :name=>:org_managers_idx, :unique=>true
      index [:created_at]
      index [:role_guid]
      index [:updated_at]
    end
    
    create_table(:organizations_users, :ignore_index_errors=>true) do
      foreign_key :organization_id, :organizations, :null=>false, :key=>[:id]
      foreign_key :user_id, :users, :null=>false, :key=>[:id]
      primary_key :organizations_users_pk, :keep_order=>true
      String :role_guid, :size=>255
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      
      index [:organization_id, :user_id], :name=>:org_users_idx, :unique=>true
      index [:created_at]
      index [:role_guid]
      index [:updated_at]
    end
    
    create_table(:route_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :routes, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:resource_guid], :name=>:fk_route_annotations_resource_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:route_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :routes, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:resource_guid], :name=>:fk_route_labels_resource_guid_index
      index [:key_prefix, :key_name, :value], :name=>:route_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:route_mappings, :ignore_index_errors=>true) do
      primary_key :id
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      Integer :app_port
      String :guid, :text=>true, :null=>false
      foreign_key :app_guid, :apps, :type=>String, :text=>true, :null=>false, :key=>[:guid]
      foreign_key :route_guid, :routes, :type=>String, :text=>true, :null=>false, :key=>[:guid]
      String :process_type, :text=>true
      Integer :weight
      
      index [:created_at], :name=>:apps_routes_created_at_index
      index [:guid], :name=>:apps_routes_guid_index, :unique=>true
      index [:updated_at], :name=>:apps_routes_updated_at_index
      index [:app_guid]
      index [:app_guid, :route_guid, :process_type, :app_port], :name=>:route_mappings_app_guid_route_guid_process_type_app_port_key, :unique=>true
      index [:process_type]
    end
    
    create_table(:service_broker_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :service_brokers, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:resource_guid], :name=>:fk_service_broker_annotations_resource_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:service_broker_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :service_brokers, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:resource_guid], :name=>:fk_service_broker_labels_resource_guid_index
      index [:key_prefix, :key_name, :value], :name=>:service_broker_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:service_broker_update_requests, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :name, :size=>255
      String :broker_url, :size=>255
      String :authentication, :size=>16000
      String :salt, :size=>255
      String :encryption_key_label, :size=>255
      Integer :encryption_iterations, :default=>2048, :null=>false
      Integer :service_broker_id, :null=>false
      foreign_key :fk_service_brokers_id, :service_brokers, :key=>[:id]
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:services, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :label, :null=>false
      String :description, :text=>true, :null=>false
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
      TrueClass :plan_updateable, :default=>false
      TrueClass :bindings_retrievable, :default=>false, :null=>false
      TrueClass :instances_retrievable, :default=>false, :null=>false
      TrueClass :allow_context_updates, :default=>false, :null=>false
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:label]
      index [:unique_id]
      index [:updated_at]
    end
    
    create_table(:spaces_auditors, :ignore_index_errors=>true) do
      foreign_key :space_id, :spaces, :null=>false, :key=>[:id]
      foreign_key :user_id, :users, :null=>false, :key=>[:id]
      primary_key :spaces_auditors_pk, :keep_order=>true
      String :role_guid, :size=>255
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      
      index [:space_id, :user_id], :name=>:space_auditors_idx, :unique=>true
      index [:created_at]
      index [:role_guid]
      index [:updated_at]
    end
    
    create_table(:spaces_developers, :ignore_index_errors=>true) do
      foreign_key :space_id, :spaces, :null=>false, :key=>[:id]
      foreign_key :user_id, :users, :null=>false, :key=>[:id]
      primary_key :spaces_developers_pk, :keep_order=>true
      String :role_guid, :size=>255
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      
      index [:space_id, :user_id], :name=>:space_developers_idx, :unique=>true
      index [:created_at]
      index [:role_guid]
      index [:updated_at]
    end
    
    create_table(:spaces_managers, :ignore_index_errors=>true) do
      foreign_key :space_id, :spaces, :null=>false, :key=>[:id]
      foreign_key :user_id, :users, :null=>false, :key=>[:id]
      primary_key :spaces_managers_pk, :keep_order=>true
      String :role_guid, :size=>255
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      
      index [:space_id, :user_id], :name=>:space_managers_idx, :unique=>true
      index [:created_at]
      index [:role_guid]
      index [:updated_at]
    end
    
    create_table(:user_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :users, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:resource_guid], :name=>:fk_user_annotations_resource_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:user_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :users, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:resource_guid], :name=>:fk_user_labels_resource_guid_index
      index [:key_prefix, :key_name, :value], :name=>:user_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:service_broker_update_request_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :service_broker_update_requests, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:resource_guid], :name=>:fk_sb_update_request_annotations_resource_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:service_broker_update_request_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :service_broker_update_requests, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:resource_guid], :name=>:fk_sb_update_request_labels_resource_guid_index
      index [:key_prefix, :key_name, :value], :name=>:sb_update_request_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:service_offering_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :services, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:resource_guid], :name=>:fk_service_offering_annotations_resource_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:service_offering_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :services, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:resource_guid], :name=>:fk_service_offering_labels_resource_guid_index
      index [:key_prefix, :key_name, :value], :name=>:service_offering_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:service_plans, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :name, :null=>false
      String :description, :text=>true, :null=>false
      TrueClass :free, :null=>false
      foreign_key :service_id, :services, :null=>false, :key=>[:id]
      String :extra, :text=>true
      String :unique_id, :text=>true, :null=>false
      TrueClass :public, :default=>true
      TrueClass :active, :default=>true
      TrueClass :bindable
      String :create_instance_schema, :text=>true
      String :update_instance_schema, :text=>true
      String :create_binding_schema, :text=>true
      TrueClass :plan_updateable
      Integer :maximum_polling_duration
      String :maintenance_info, :text=>true
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:unique_id]
      index [:updated_at]
      index [:service_id, :name], :name=>:svc_plan_svc_id_name_index, :unique=>true
    end
    
    create_table(:service_instances, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :name, :text=>true, :null=>false
      String :credentials, :text=>true
      String :gateway_name, :text=>true
      String :gateway_data, :size=>2048
      foreign_key :space_id, :spaces, :null=>false, :key=>[:id]
      foreign_key :service_plan_id, :service_plans, :key=>[:id]
      String :salt, :text=>true
      String :dashboard_url, :size=>16000
      TrueClass :is_gateway_service, :default=>true, :null=>false
      String :syslog_drain_url, :text=>true
      String :tags, :text=>true
      String :route_service_url, :text=>true
      String :encryption_key_label, :size=>255
      Integer :encryption_iterations, :default=>2048, :null=>false
      String :maintenance_info, :text=>true
      
      index [:name]
      index [:created_at], :name=>:si_created_at_index
      index [:gateway_name], :name=>:si_gateway_name_index
      index [:guid], :name=>:si_guid_index, :unique=>true
      index [:space_id, :name], :name=>:si_space_id_name_index, :unique=>true
      index [:updated_at], :name=>:si_updated_at_index
    end
    
    create_table(:service_plan_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :service_plans, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:resource_guid], :name=>:fk_service_plan_annotations_resource_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:service_plan_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :service_plans, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:resource_guid], :name=>:fk_service_plan_labels_resource_guid_index
      index [:key_prefix, :key_name, :value], :name=>:service_plan_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:service_plan_visibilities, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :service_plan_id, :service_plans, :null=>false, :key=>[:id]
      foreign_key :organization_id, :organizations, :null=>false, :key=>[:id]
      
      index [:created_at], :name=>:spv_created_at_index
      index [:guid], :name=>:spv_guid_index, :unique=>true
      index [:organization_id, :service_plan_id], :name=>:spv_org_id_sp_id_index, :unique=>true
      index [:updated_at], :name=>:spv_updated_at_index
    end
    
    create_table(:route_bindings, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :route_id, :routes, :key=>[:id]
      foreign_key :service_instance_id, :service_instances, :key=>[:id]
      String :route_service_url, :text=>true
      
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:service_bindings, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :credentials, :text=>true, :null=>false
      String :salt, :text=>true
      String :syslog_drain_url, :text=>true
      String :volume_mounts, :text=>true
      String :volume_mounts_salt, :text=>true
      foreign_key :app_guid, :apps, :type=>String, :text=>true, :null=>false, :key=>[:guid]
      foreign_key :service_instance_guid, :service_instances, :type=>String, :text=>true, :null=>false, :key=>[:guid]
      String :type, :text=>true
      String :name, :size=>255
      String :encryption_key_label, :size=>255
      Integer :encryption_iterations, :default=>2048, :null=>false
      
      index [:created_at], :name=>:sb_created_at_index
      index [:guid], :name=>:sb_guid_index, :unique=>true
      index [:updated_at], :name=>:sb_updated_at_index
      index [:app_guid]
      index [:name]
      index [:service_instance_guid]
      index [:app_guid, :name], :name=>:unique_service_binding_app_guid_name, :unique=>true
      index [:service_instance_guid, :app_guid], :name=>:unique_service_binding_service_instance_guid_app_guid, :unique=>true
    end
    
    create_table(:service_instance_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :service_instances, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:resource_guid], :name=>:fk_service_instance_annotations_resource_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:service_instance_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :service_instances, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:resource_guid], :name=>:fk_service_instance_labels_resource_guid_index
      index [:key_prefix, :key_name, :value], :name=>:service_instance_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:service_instance_operations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :service_instance_id, :service_instances, :key=>[:id]
      String :type, :text=>true
      String :state, :text=>true
      String :description, :text=>true
      String :proposed_changes, :default=>"{}", :text=>true, :null=>false
      String :broker_provided_operation, :text=>true
      
      index [:created_at], :name=>:svc_inst_op_created_at_index
      index [:guid], :name=>:svc_inst_op_guid_index, :unique=>true
      index [:updated_at], :name=>:svc_inst_op_updated_at_index
      index [:service_instance_id], :name=>:svc_instance_id_index
    end
    
    create_table(:service_instance_shares) do
      foreign_key :service_instance_guid, :service_instances, :type=>String, :size=>255, :null=>false, :key=>[:guid], :on_delete=>:cascade
      foreign_key :target_space_guid, :spaces, :type=>String, :size=>255, :null=>false, :key=>[:guid], :on_delete=>:cascade
      
      primary_key [:service_instance_guid, :target_space_guid]
    end
    
    create_table(:service_keys, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      String :name, :text=>true, :null=>false
      String :salt, :text=>true
      String :credentials, :text=>true, :null=>false
      foreign_key :service_instance_id, :service_instances, :null=>false, :key=>[:id]
      String :encryption_key_label, :size=>255
      Integer :encryption_iterations, :default=>2048, :null=>false
      
      index [:created_at], :name=>:sk_created_at_index
      index [:guid], :name=>:sk_guid_index, :unique=>true
      index [:updated_at], :name=>:sk_updated_at_index
      index [:name, :service_instance_id], :name=>:svc_key_name_instance_id_index, :unique=>true
    end
    
    create_table(:route_binding_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :route_bindings, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:resource_guid], :name=>:fk_route_binding_annotations_resource_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:route_binding_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :route_bindings, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:resource_guid], :name=>:fk_route_binding_labels_resource_guid_index
      index [:key_prefix, :key_name, :value], :name=>:route_binding_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:route_binding_operations, :ignore_index_errors=>true) do
      primary_key :id
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :route_binding_id, :route_bindings, :key=>[:id], :on_delete=>:cascade
      String :state, :size=>255, :null=>false
      String :type, :size=>255, :null=>false
      String :description, :size=>10000
      String :broker_provided_operation, :size=>10000
      
      index [:route_binding_id], :name=>:route_binding_id_index, :unique=>true
      index [:created_at]
      index [:updated_at]
    end
    
    create_table(:service_binding_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :service_bindings, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:resource_guid], :name=>:fk_service_binding_annotations_resource_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:service_binding_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :service_bindings, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:resource_guid], :name=>:fk_service_binding_labels_resource_guid_index
      index [:key_prefix, :key_name, :value], :name=>:service_binding_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:service_binding_operations, :ignore_index_errors=>true) do
      primary_key :id
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :service_binding_id, :service_bindings, :key=>[:id], :on_delete=>:cascade
      String :state, :size=>255, :null=>false
      String :type, :size=>255, :null=>false
      String :description, :size=>10000
      String :broker_provided_operation, :size=>10000
      
      index [:created_at]
      index [:updated_at]
      index [:service_binding_id], :name=>:svc_binding_id_index, :unique=>true
    end
    
    create_table(:service_key_annotations, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :service_keys, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key, :size=>1000
      String :value, :size=>5000
      
      index [:resource_guid], :name=>:fk_service_key_annotations_resource_guid_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:service_key_labels, :ignore_index_errors=>true) do
      primary_key :id
      String :guid, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :resource_guid, :service_keys, :type=>String, :size=>255, :key=>[:guid]
      String :key_prefix, :size=>253
      String :key_name, :size=>63
      String :value, :size=>63
      
      index [:resource_guid], :name=>:fk_service_key_labels_resource_guid_index
      index [:key_prefix, :key_name, :value], :name=>:service_key_labels_compound_index
      index [:created_at]
      index [:guid], :unique=>true
      index [:updated_at]
    end
    
    create_table(:service_key_operations, :ignore_index_errors=>true) do
      primary_key :id
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :updated_at
      foreign_key :service_key_id, :service_keys, :key=>[:id], :on_delete=>:cascade
      String :state, :size=>255, :null=>false
      String :type, :size=>255, :null=>false
      String :description, :size=>10000
      String :broker_provided_operation, :size=>10000
      
      index [:created_at]
      index [:updated_at]
      index [:service_key_id], :name=>:svc_key_id_index, :unique=>true
    end
    
    alter_table(:app_annotations) do
      add_foreign_key [:resource_guid], :apps, :name=>:fk_app_annotations_resource_guid, :key=>[:guid], :schema=>:public
    end
    
    alter_table(:app_events) do
      add_foreign_key [:app_id], :processes, :name=>:fk_app_events_app_id, :key=>[:id], :schema=>:public
    end
    
    alter_table(:app_labels) do
      add_foreign_key [:resource_guid], :apps, :name=>:fk_app_labels_resource_guid, :key=>[:guid], :schema=>:public
    end
    
    alter_table(:apps) do
      add_foreign_key [:space_guid], :spaces, :name=>:fk_apps_space_guid, :key=>[:guid], :schema=>:public
    end
    
    alter_table(:domain_annotations) do
      add_foreign_key [:resource_guid], :domains, :name=>:fk_domain_annotations_resource_guid, :key=>[:guid], :schema=>:public
    end
    
    alter_table(:domain_labels) do
      add_foreign_key [:resource_guid], :domains, :name=>:fk_domain_labels_resource_guid, :key=>[:guid], :schema=>:public
    end
    
    alter_table(:domains) do
      add_foreign_key [:owning_organization_id], :organizations, :name=>:fk_domains_owning_org_id, :key=>[:id], :schema=>:public
    end
    
    alter_table(:organization_annotations) do
      add_foreign_key [:resource_guid], :organizations, :name=>:fk_organization_annotations_resource_guid, :key=>[:guid], :schema=>:public
    end
    
    alter_table(:organization_labels) do
      add_foreign_key [:resource_guid], :organizations, :name=>:fk_organization_labels_resource_guid, :key=>[:guid], :schema=>:public
    end
    
    alter_table(:organizations) do
      add_foreign_key [:guid, :default_isolation_segment_guid], :organizations_isolation_segments, :name=>:organizations_isolation_segments_pk, :key=>[:organization_guid, :isolation_segment_guid], :schema=>:public
    end
  end
end
