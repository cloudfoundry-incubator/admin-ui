Sequel.migration do
  change do
    create_table(:authz_approvals) do
      String :user_id, :size=>36, :null=>false
      String :client_id, :size=>255, :null=>false
      String :scope, :size=>255, :null=>false
      DateTime :expiresat, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      String :status, :default=>"APPROVED", :size=>50, :null=>false
      DateTime :lastmodifiedat, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      String :identity_zone_id, :size=>36
      
      primary_key [:user_id, :client_id, :scope]
    end
    
    create_table(:expiring_code_store) do
      String :code, :size=>255, :null=>false
      Bignum :expiresat, :null=>false
      String :data, :text=>true, :null=>false
      String :intent, :text=>true
      String :identity_zone_id, :default=>"uaa", :size=>36, :null=>false
      
      primary_key [:code]
    end
    
    create_table(:external_group_mapping, :ignore_index_errors=>true) do
      String :group_id, :size=>36, :null=>false
      String :external_group, :size=>255, :null=>false
      DateTime :added, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      String :origin, :size=>36
      String :identity_zone_id, :size=>36
      primary_key :id, :keep_order=>true
      
      index [:origin, :external_group, :group_id], :name=>:external_group_unique_key, :unique=>true
    end
    
    create_table(:group_membership, :ignore_index_errors=>true) do
      String :group_id, :size=>36, :null=>false
      String :member_id, :size=>36, :null=>false
      String :member_type, :default=>"USER", :size=>8, :null=>false
      String :authorities, :default=>"READ", :size=>255
      DateTime :added, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      String :origin, :default=>"uaa", :size=>36, :null=>false
      String :identity_zone_id, :size=>36
      primary_key :id, :keep_order=>true
      
      index [:group_id], :name=>:group_membership_perf_group_idx
      index [:member_id, :group_id], :name=>:group_membership_unique_key, :unique=>true
    end
    
    create_table(:groups, :ignore_index_errors=>true) do
      String :id, :size=>36, :null=>false
      String :displayname, :size=>255, :null=>false
      DateTime :created, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :lastmodified, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      Bignum :version, :default=>0, :null=>false
      String :identity_zone_id, :default=>"uaa", :size=>36, :null=>false
      String :description, :size=>255
      
      primary_key [:id]
      
      index [:displayname, :identity_zone_id], :name=>:groups_unique_key, :unique=>true
    end
    
    create_table(:identity_provider, :ignore_index_errors=>true) do
      String :id, :size=>36, :null=>false
      DateTime :created, :default=>Sequel::CURRENT_TIMESTAMP
      DateTime :lastmodified, :default=>Sequel::CURRENT_TIMESTAMP
      Bignum :version, :default=>0
      String :identity_zone_id, :size=>36, :null=>false
      String :name, :size=>255, :null=>false
      String :origin_key, :size=>36, :null=>false
      String :type, :size=>255, :null=>false
      String :config, :text=>true
      TrueClass :active, :default=>true, :null=>false
      
      primary_key [:id]
      
      index [:identity_zone_id, :active], :name=>:active_in_zone
      index [:identity_zone_id, :origin_key], :name=>:key_in_zone, :unique=>true
    end
    
    create_table(:identity_zone, :ignore_index_errors=>true) do
      String :id, :size=>36, :null=>false
      DateTime :created, :default=>Sequel::CURRENT_TIMESTAMP
      DateTime :lastmodified, :default=>Sequel::CURRENT_TIMESTAMP
      Bignum :version, :default=>0
      String :subdomain, :size=>255, :null=>false
      String :name, :size=>255, :null=>false
      String :description, :text=>true
      String :config, :text=>true
      TrueClass :active, :default=>true, :null=>false
      
      primary_key [:id]
      
      index [:subdomain], :name=>:subdomain, :unique=>true
    end
    
    create_table(:mfa_providers) do
      String :id, :size=>36, :null=>false
      DateTime :created, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :lastmodified
      String :identity_zone_id, :size=>36, :null=>false
      String :name, :size=>255, :null=>false
      String :type, :size=>255, :null=>false
      String :config, :text=>true
      
      primary_key [:id]
    end
    
    create_table(:oauth_client_details) do
      String :client_id, :size=>255, :null=>false
      String :resource_ids, :size=>1024
      String :client_secret, :size=>256
      String :scope, :text=>true
      String :authorized_grant_types, :size=>256
      String :web_server_redirect_uri, :size=>1024
      String :authorities, :text=>true
      Integer :access_token_validity
      Integer :refresh_token_validity, :default=>0
      String :additional_information, :size=>4096
      String :autoapprove, :size=>1024
      String :identity_zone_id, :default=>"uaa", :size=>36, :null=>false
      DateTime :lastmodified, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      TrueClass :show_on_home_page, :default=>true, :null=>false
      String :app_launch_url, :size=>1024
      File :app_icon
      String :created_by, :size=>36, :fixed=>true
      String :required_user_groups, :size=>1024
      
      primary_key [:client_id, :identity_zone_id]
    end
    
    create_table(:oauth_code, :ignore_index_errors=>true) do
      String :code, :size=>256
      File :authentication
      DateTime :created, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      Bignum :expiresat, :default=>0, :null=>false
      String :user_id, :size=>36
      String :client_id, :size=>255
      String :identity_zone_id, :size=>36
      primary_key :id, :keep_order=>true
      
      index [:expiresat], :name=>:oauth_code_expiresat_idx
      index [:code], :name=>:oauth_code_uq_idx, :unique=>true
    end
    
    create_table(:revocable_tokens, :ignore_index_errors=>true) do
      String :token_id, :size=>36, :null=>false
      String :client_id, :size=>255, :null=>false
      String :user_id, :size=>36
      String :format, :size=>255
      String :response_type, :size=>25, :null=>false
      Bignum :issued_at, :null=>false
      Bignum :expires_at, :null=>false
      String :scope, :text=>true
      String :data, :text=>true, :null=>false
      String :identity_zone_id, :default=>"uaa", :size=>36, :null=>false
      
      primary_key [:token_id]
      
      index [:client_id], :name=>:idx_revocable_token_client_id
      index [:expires_at], :name=>:idx_revocable_token_expires_at
      index [:user_id], :name=>:idx_revocable_token_user_id
      index [:user_id, :client_id, :response_type, :identity_zone_id], :name=>:revocable_tokens_user_id_client_id_response_type_identity__idx
      index [:identity_zone_id], :name=>:revocable_tokens_zone_id
    end
    
    create_table(:schema_version, :ignore_index_errors=>true) do
      Integer :installed_rank, :null=>false
      String :version, :size=>50
      String :description, :size=>200, :null=>false
      String :type, :size=>20, :null=>false
      String :script, :size=>1000, :null=>false
      Integer :checksum
      String :installed_by, :size=>100, :null=>false
      DateTime :installed_on, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      Integer :execution_time, :null=>false
      TrueClass :success, :null=>false
      
      primary_key [:installed_rank]
      
      index [:success], :name=>:schema_version_s_idx
    end
    
    create_table(:sec_audit, :ignore_index_errors=>true) do
      String :principal_id, :size=>255, :null=>false
      Integer :event_type, :null=>false
      String :origin, :size=>255, :null=>false
      String :event_data, :size=>255
      DateTime :created, :default=>Sequel::CURRENT_TIMESTAMP
      String :identity_zone_id, :default=>"uaa", :size=>36
      primary_key :id, :keep_order=>true
      
      index [:created], :name=>:audit_created
      index [:principal_id], :name=>:audit_principal
      index [:created], :name=>:sec_audit_created_idx
      index [:principal_id], :name=>:sec_audit_principal_idx
    end
    
    create_table(:service_provider, :ignore_index_errors=>true) do
      String :id, :size=>36, :null=>false
      DateTime :created, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :lastmodified, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      Bignum :version, :default=>0
      String :identity_zone_id, :size=>36, :null=>false
      String :name, :size=>255, :null=>false
      String :entity_id, :size=>255, :null=>false
      String :config, :text=>true
      TrueClass :active, :default=>true, :null=>false
      
      primary_key [:id]
      
      index [:identity_zone_id, :entity_id], :name=>:entity_in_zone, :unique=>true
    end
    
    create_table(:spring_session, :ignore_index_errors=>true) do
      String :primary_id, :size=>36, :fixed=>true, :null=>false
      String :session_id, :size=>36, :fixed=>true, :null=>false
      Bignum :creation_time, :null=>false
      Bignum :last_access_time, :null=>false
      Integer :max_inactive_interval, :null=>false
      Bignum :expiry_time, :null=>false
      String :principal_name, :size=>100
      
      primary_key [:primary_id]
      
      index [:session_id], :name=>:spring_session_ix1, :unique=>true
      index [:expiry_time], :name=>:spring_session_ix2
      index [:principal_name], :name=>:spring_session_ix3
    end
    
    create_table(:user_google_mfa_credentials) do
      String :user_id, :size=>36, :null=>false
      String :secret_key, :size=>255, :null=>false
      Integer :validation_code
      String :scratch_codes, :size=>255, :null=>false
      String :mfa_provider_id, :size=>36, :fixed=>true, :null=>false
      String :zone_id, :size=>36, :fixed=>true, :null=>false
      String :encryption_key_label, :size=>255
      String :encrypted_validation_code, :size=>255
      
      primary_key [:user_id, :mfa_provider_id]
    end
    
    create_table(:user_info) do
      String :user_id, :size=>36, :null=>false
      String :info, :text=>true, :null=>false
      
      primary_key [:user_id]
    end
    
    create_table(:users, :ignore_index_errors=>true) do
      String :id, :size=>36, :fixed=>true, :null=>false
      DateTime :created, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :lastmodified, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      Bignum :version, :default=>0, :null=>false
      String :username, :size=>255, :null=>false
      String :password, :size=>255, :null=>false
      String :email, :size=>255, :null=>false
      String :givenname, :size=>255
      String :familyname, :size=>255
      TrueClass :active, :default=>true
      String :phonenumber, :size=>255
      String :authorities, :default=>"uaa.user", :size=>1024
      TrueClass :verified, :default=>false, :null=>false
      String :origin, :default=>"uaa", :size=>36, :null=>false
      String :external_id, :size=>255
      String :identity_zone_id, :default=>"uaa", :size=>36, :null=>false
      String :salt, :size=>36
      DateTime :passwd_lastmodified
      TrueClass :legacy_verification_behavior, :default=>false, :null=>false
      TrueClass :passwd_change_required, :default=>false, :null=>false
      Bignum :last_logon_success_time
      Bignum :previous_logon_success_time
      
      primary_key [:id]
      
      index [:identity_zone_id], :name=>:user_identity_zone
    end
    
    create_table(:spring_session_attributes) do
      foreign_key :session_primary_id, :spring_session, :type=>String, :size=>36, :fixed=>true, :null=>false, :key=>[:primary_id], :on_delete=>:cascade
      String :attribute_name, :size=>200, :null=>false
      File :attribute_bytes, :null=>false
      
      primary_key [:session_primary_id, :attribute_name]
    end
  end
end
