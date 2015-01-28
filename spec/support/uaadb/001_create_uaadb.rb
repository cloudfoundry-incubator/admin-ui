Sequel.migration do
  change do
    create_table(:authz_approvals) do
      String :user_id, :size=>36, :null=>false
      String :client_id, :size=>36, :null=>false
      String :scope, :size=>255, :null=>false
      DateTime :expiresat, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      String :status, :default=>"APPROVED", :size=>50, :null=>false
      DateTime :lastmodifiedat, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      
      primary_key [:user_id, :client_id, :scope]
    end
    
    create_table(:authz_approvals_old) do
      String :username, :size=>255, :null=>false
      String :clientid, :size=>36, :null=>false
      String :scope, :size=>255, :null=>false
      DateTime :expiresat, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      String :status, :default=>"APPROVED", :size=>50, :null=>false
      DateTime :lastmodifiedat, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      
      primary_key [:username, :clientid, :scope]
    end
    
    create_table(:expiring_code_store) do
      String :code, :size=>255, :null=>false
      Bignum :expiresat, :null=>false
      String :data, :text=>true, :null=>false
      
      primary_key [:code]
    end
    
    create_table(:external_group_mapping) do
      String :group_id, :size=>36, :null=>false
      String :external_group, :size=>255, :null=>false
      DateTime :added, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      
      primary_key [:group_id, :external_group]
    end
    
    create_table(:group_membership) do
      String :group_id, :size=>36, :null=>false
      String :member_id, :size=>36, :null=>false
      String :member_type, :default=>"USER", :size=>8, :null=>false
      String :authorities, :default=>"READ", :size=>255, :null=>false
      DateTime :added, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      String :origin, :default=>"uaa", :size=>36, :null=>false
      
      primary_key [:group_id, :member_id]
    end
    
    create_table(:groups, :ignore_index_errors=>true) do
      String :id, :size=>36, :null=>false
      String :displayname, :size=>255, :null=>false
      DateTime :created, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :lastmodified, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      Bignum :version, :default=>0, :null=>false
      
      primary_key [:id]
      
      index [:displayname], :name=>:unique_uk_2, :unique=>true
    end
    
    create_table(:oauth_client_details) do
      String :client_id, :size=>256, :null=>false
      String :resource_ids, :size=>1024
      String :client_secret, :size=>256
      String :scope, :size=>1024
      String :authorized_grant_types, :size=>256
      String :web_server_redirect_uri, :size=>1024
      String :authorities, :size=>1024
      Integer :access_token_validity
      Integer :refresh_token_validity, :default=>0
      String :additional_information, :size=>4096
      String :autoapprove, :size=>1024
      
      primary_key [:client_id]
    end
    
    create_table(:oauth_code) do
      String :code, :size=>256
      File :authentication
    end
    
    create_table(:schema_version, :ignore_index_errors=>true) do
      Integer :version_rank, :null=>false
      Integer :installed_rank, :null=>false
      String :version, :size=>50, :null=>false
      String :description, :size=>200, :null=>false
      String :type, :size=>20, :null=>false
      String :script, :size=>1000, :null=>false
      Integer :checksum
      String :installed_by, :size=>100, :null=>false
      DateTime :installed_on, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      Integer :execution_time, :null=>false
      TrueClass :success, :null=>false
      
      primary_key [:version]
      
      index [:installed_rank], :name=>:schema_version_ir_idx
      index [:success], :name=>:schema_version_s_idx
      index [:version_rank], :name=>:schema_version_vr_idx
    end
    
    create_table(:sec_audit, :ignore_index_errors=>true) do
      String :principal_id, :size=>36, :fixed=>true, :null=>false
      Integer :event_type, :null=>false
      String :origin, :size=>255, :null=>false
      String :event_data, :size=>255
      DateTime :created, :default=>Sequel::CURRENT_TIMESTAMP
      
      index [:created], :name=>:audit_created
      index [:principal_id], :name=>:audit_principal
    end
    
    create_table(:users) do
      String :id, :size=>36, :fixed=>true, :null=>false
      DateTime :created, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :lastmodified, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      Bignum :version, :default=>0, :null=>false
      String :username, :size=>255, :null=>false
      String :password, :size=>255, :null=>false
      String :email, :size=>255, :null=>false
      Bignum :authority, :default=>0, :null=>false
      String :givenname, :size=>255
      String :familyname, :size=>255
      TrueClass :active, :default=>true
      String :phonenumber, :size=>255
      String :authorities, :default=>"uaa.user", :size=>1024
      TrueClass :verified, :default=>false
      String :origin, :default=>"uaa", :size=>36, :null=>false
      String :external_id, :size=>255
      
      primary_key [:id]
    end
  end
end
