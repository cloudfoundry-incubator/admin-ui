require 'rubygems'
require_relative '../../spec_helper'
require_relative '../../support/web_helper'

describe AdminUI::Admin, type: :integration, firefox_available: true do
  include_context :server_context
  include_context :web_context

  context 'authenticated' do
    before do
      login_stub_user
      login('Administration')
    end

    it 'shows the logged in user' do
      expect(@driver.find_element(class_name: 'userContainer').displayed?).to be(true)
      expect(@driver.find_element(class_name: 'user').text).to eq(LoginHelper::LOGIN_USER)
    end

    shared_examples 'verifies first button is copy button' do
      it 'verifies first button is copy button' do
        click_tab(tab_id, true)

        begin
          Selenium::WebDriver::Wait.new(timeout: 5).until do
            @driver.find_element(id: page_id).displayed?
          end
        rescue Selenium::WebDriver::Error::TimeoutError
        end
        expect(@driver.find_element(id: page_id).displayed?).to eq(true)

        select_first_row

        begin
          Selenium::WebDriver::Wait.new(timeout: 5).until do
            @driver.find_element(id: button_id).text == 'Copy'
          end
        rescue Selenium::WebDriver::Error::TimeoutError
        end
        expect(@driver.find_element(id: button_id).text).to eq('Copy')
      end
    end

    shared_examples 'verifies subtable is not shown' do
      it 'verifies subtable is not shown' do
        click_tab(tab_id, true)

        begin
          Selenium::WebDriver::Wait.new(timeout: 5).until do
            @driver.find_element(id: page_id).displayed?
          end
        rescue Selenium::WebDriver::Error::TimeoutError
        end
        expect(@driver.find_element(id: page_id).displayed?).to eq(true)

        select_first_row

        expect(@driver.find_element(id: table_id_label).displayed?).to be(false)
        expect(@driver.find_element(id: table_id).displayed?).to be(false)
      end
    end

    context 'Organizations tab does not have create, rename, set quota, activate, suspend, remove default isolation segment or delete buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Organizations' }
        let(:page_id)   { 'OrganizationsPage' }
        let(:button_id) { 'Buttons_OrganizationsTable_0' }
      end
    end

    context 'Organizations tab Labels subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Organizations' }
        let(:page_id)   { 'OrganizationsPage' }
        let(:button_id) { 'Buttons_OrganizationsLabelsTable_0' }
      end
    end

    context 'Organizations tab Annotations subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Organizations' }
        let(:page_id)   { 'OrganizationsPage' }
        let(:button_id) { 'Buttons_OrganizationsAnnotationsTable_0' }
      end
    end

    context 'Spaces tab does not have rename, allow ssh, disallow ssh, remove isolation segment, delete unmapped routes or delete buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Spaces' }
        let(:page_id)   { 'SpacesPage' }
        let(:button_id) { 'Buttons_SpacesTable_0' }
      end
    end

    context 'Spaces tab Labels subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Spaces' }
        let(:page_id)   { 'SpacesPage' }
        let(:button_id) { 'Buttons_SpacesLabelsTable_0' }
      end
    end

    context 'Spaces tab Annotations subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Spaces' }
        let(:page_id)   { 'SpacesPage' }
        let(:button_id) { 'Buttons_SpacesAnnotationsTable_0' }
      end
    end

    context 'Applications tab does not have rename, start, stop, restage, enable diego, disable diego, enable ssh, disable ssh, enable revisions, disable revisions or delete buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Applications' }
        let(:page_id)   { 'ApplicationsPage' }
        let(:button_id) { 'Buttons_ApplicationsTable_0' }
      end
    end

    context 'Applications tab Labels subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Applications' }
        let(:page_id)   { 'ApplicationsPage' }
        let(:button_id) { 'Buttons_ApplicationsLabelsTable_0' }
      end
    end

    context 'Applications tab Annotations subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Applications' }
        let(:page_id)   { 'ApplicationsPage' }
        let(:button_id) { 'Buttons_ApplicationsAnnotationsTable_0' }
      end
    end

    context 'Applications tab does not have environment variables subtable' do
      it_behaves_like('verifies subtable is not shown') do
        let(:tab_id)         { 'Applications' }
        let(:page_id)        { 'ApplicationsPage' }
        let(:table_id)       { 'ApplicationsEnvironmentVariablesTable' }
        let(:table_id_label) { 'ApplicationsEnvironmentVariablesDetailsLabel' }
      end
    end

    context 'Application Instances tab does not have restart button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'ApplicationInstances' }
        let(:page_id)   { 'ApplicationInstancesPage' }
        let(:button_id) { 'Buttons_ApplicationInstancesTable_0' }
      end
    end

    context 'Routes tab does not have delete buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Routes' }
        let(:page_id)   { 'RoutesPage' }
        let(:button_id) { 'Buttons_RoutesTable_0' }
      end
    end

    context 'Routes tab Labels subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Routes' }
        let(:page_id)   { 'RoutesPage' }
        let(:button_id) { 'Buttons_RoutesLabelsTable_0' }
      end
    end

    context 'Routes tab Annotations subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Routes' }
        let(:page_id)   { 'RoutesPage' }
        let(:button_id) { 'Buttons_RoutesAnnotationsTable_0' }
      end
    end

    context 'Route Mappings tab does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'RouteMappings' }
        let(:page_id)   { 'RouteMappingsPage' }
        let(:button_id) { 'Buttons_RouteMappingsTable_0' }
      end
    end

    context 'Service Instances tab does not have rename, delete, delete recursive or purge buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'ServiceInstances' }
        let(:page_id)   { 'ServiceInstancesPage' }
        let(:button_id) { 'Buttons_ServiceInstancesTable_0' }
      end
    end

    context 'Service Instances tab Labels subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'ServiceInstances' }
        let(:page_id)   { 'ServiceInstancesPage' }
        let(:button_id) { 'Buttons_ServiceInstancesLabelsTable_0' }
      end
    end

    context 'Service Instances tab Annotations subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'ServiceInstances' }
        let(:page_id)   { 'ServiceInstancesPage' }
        let(:button_id) { 'Buttons_ServiceInstancesAnnotationsTable_0' }
      end
    end

    context 'Service Instances tab does not have credentials subtable' do
      it_behaves_like('verifies subtable is not shown') do
        let(:tab_id)         { 'ServiceInstances' }
        let(:page_id)        { 'ServiceInstancesPage' }
        let(:table_id)       { 'ServiceInstancesCredentialsTable' }
        let(:table_id_label) { 'ServiceInstancesCredentialsDetailsLabel' }
      end
    end

    context 'Shared Service Instances tab does not have unshare button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'SharedServiceInstances' }
        let(:page_id)   { 'SharedServiceInstancesPage' }
        let(:button_id) { 'Buttons_SharedServiceInstancesTable_0' }
      end
    end

    context 'Service Bindings tab does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'ServiceBindings' }
        let(:page_id)   { 'ServiceBindingsPage' }
        let(:button_id) { 'Buttons_ServiceBindingsTable_0' }
      end
    end

    context 'Service Bindings tab Labels subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'ServiceBindings' }
        let(:page_id)   { 'ServiceBindingsPage' }
        let(:button_id) { 'Buttons_ServiceBindingsLabelsTable_0' }
      end
    end

    context 'Service Bindings tab Annotations subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'ServiceBindings' }
        let(:page_id)   { 'ServiceBindingsPage' }
        let(:button_id) { 'Buttons_ServiceBindingsAnnotationsTable_0' }
      end
    end

    context 'Service Bindings tab does not have credentials subtable' do
      it_behaves_like('verifies subtable is not shown') do
        let(:tab_id)         { 'ServiceBindings' }
        let(:page_id)        { 'ServiceBindingsPage' }
        let(:table_id)       { 'ServiceBindingsCredentialsTable' }
        let(:table_id_label) { 'ServiceBindingsCredentialsDetailsLabel' }
      end
    end

    context 'Service Bindings tab does not have volume mounts subtable' do
      it_behaves_like('verifies subtable is not shown') do
        let(:tab_id)         { 'ServiceBindings' }
        let(:page_id)        { 'ServiceBindingsPage' }
        let(:table_id)       { 'ServiceBindingsVolumeMountsTable' }
        let(:table_id_label) { 'ServiceBindingsVolumeMountsDetailsLabel' }
      end
    end

    context 'Service Keys tab does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'ServiceKeys' }
        let(:page_id)   { 'ServiceKeysPage' }
        let(:button_id) { 'Buttons_ServiceKeysTable_0' }
      end
    end

    context 'Service Keys tab Labels subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'ServiceKeys' }
        let(:page_id)   { 'ServiceKeysPage' }
        let(:button_id) { 'Buttons_ServiceKeysLabelsTable_0' }
      end
    end

    context 'Service Keys tab Annotations subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'ServiceKeys' }
        let(:page_id)   { 'ServiceKeysPage' }
        let(:button_id) { 'Buttons_ServiceKeysAnnotationsTable_0' }
      end
    end

    context 'Service Keys tab does not have credentials subtable' do
      it_behaves_like('verifies subtable is not shown') do
        let(:tab_id)         { 'ServiceKeys' }
        let(:page_id)        { 'ServiceKeysPage' }
        let(:table_id)       { 'ServiceKeysCredentialsTable' }
        let(:table_id_label) { 'ServiceKeysCredentialsDetailsLabel' }
      end
    end

    context 'Route Bindings tab does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'RouteBindings' }
        let(:page_id)   { 'RouteBindingsPage' }
        let(:button_id) { 'Buttons_RouteBindingsTable_0' }
      end
    end

    context 'Route Bindings tab Labels subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'RouteBindings' }
        let(:page_id)   { 'RouteBindingsPage' }
        let(:button_id) { 'Buttons_RouteBindingsLabelsTable_0' }
      end
    end

    context 'Route Bindings tab Annotations subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'RouteBindings' }
        let(:page_id)   { 'RouteBindingsPage' }
        let(:button_id) { 'Buttons_RouteBindingsAnnotationsTable_0' }
      end
    end

    context 'Tasks tab does not have stop button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Tasks' }
        let(:page_id)   { 'TasksPage' }
        let(:button_id) { 'Buttons_TasksTable_0' }
      end
    end

    context 'Tasks tab Labels subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Tasks' }
        let(:page_id)   { 'TasksPage' }
        let(:button_id) { 'Buttons_TasksLabelsTable_0' }
      end
    end

    context 'Tasks tab Annotations subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Tasks' }
        let(:page_id)   { 'TasksPage' }
        let(:button_id) { 'Buttons_TasksAnnotationsTable_0' }
      end
    end

    context 'Organization Roles tab does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'OrganizationRoles' }
        let(:page_id)   { 'OrganizationRolesPage' }
        let(:button_id) { 'Buttons_OrganizationRolesTable_0' }
      end
    end

    context 'Space Roles tab does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'SpaceRoles' }
        let(:page_id)   { 'SpaceRolesPage' }
        let(:button_id) { 'Buttons_SpaceRolesTable_0' }
      end
    end

    context 'Clients tab does not have revoke tokens or delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Clients' }
        let(:page_id)   { 'ClientsPage' }
        let(:button_id) { 'Buttons_ClientsTable_0' }
      end
    end

    context 'Users tab does not have activate, deactivate, verify, unverify, unlock, require password change, revoke tokens or delete buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Users' }
        let(:page_id)   { 'UsersPage' }
        let(:button_id) { 'Buttons_UsersTable_0' }
      end
    end

    context 'Users tab Labels subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Users' }
        let(:page_id)   { 'UsersPage' }
        let(:button_id) { 'Buttons_UsersLabelsTable_0' }
      end
    end

    context 'Users tab Annotations subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Users' }
        let(:page_id)   { 'UsersPage' }
        let(:button_id) { 'Buttons_UsersAnnotationsTable_0' }
      end
    end

    context 'Groups tab does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Groups' }
        let(:page_id)   { 'GroupsPage' }
        let(:button_id) { 'Buttons_GroupsTable_0' }
      end
    end

    context 'Group Members tab does not have remove button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'GroupMembers' }
        let(:page_id)   { 'GroupMembersPage' }
        let(:button_id) { 'Buttons_GroupMembersTable_0' }
      end
    end

    context 'Revocable Tokens tab does not have revoke button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'RevocableTokens' }
        let(:page_id)   { 'RevocableTokensPage' }
        let(:button_id) { 'Buttons_RevocableTokensTable_0' }
      end
    end

    context 'Buildpacks tab does not have rename, enable, disable, lock, unlock or delete buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Buildpacks' }
        let(:page_id)   { 'BuildpacksPage' }
        let(:button_id) { 'Buttons_BuildpacksTable_0' }
      end
    end

    context 'Buildpacks tab Labels subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Buildpacks' }
        let(:page_id)   { 'BuildpacksPage' }
        let(:button_id) { 'Buttons_BuildpacksLabelsTable_0' }
      end
    end

    context 'Buildpacks tab Annotations subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Buildpacks' }
        let(:page_id)   { 'BuildpacksPage' }
        let(:button_id) { 'Buttons_BuildpacksAnnotationsTable_0' }
      end
    end

    context 'Domains tab does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Domains' }
        let(:page_id)   { 'DomainsPage' }
        let(:button_id) { 'Buttons_DomainsTable_0' }
      end
    end

    context 'Domains tab Labels subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Domains' }
        let(:page_id)   { 'DomainsPage' }
        let(:button_id) { 'Buttons_DomainsLabelsTable_0' }
      end
    end

    context 'Domains tab Annotations subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Domains' }
        let(:page_id)   { 'DomainsPage' }
        let(:button_id) { 'Buttons_DomainsAnnotationsTable_0' }
      end
    end

    context 'Domains tab Shared organizations does not have unshare button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Domains' }
        let(:page_id)   { 'DomainsPage' }
        let(:button_id) { 'Buttons_DomainsOrganizationsTable_0' }
      end
    end

    context 'Feature Flags tab does not have enable or disable buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'FeatureFlags' }
        let(:page_id)   { 'FeatureFlagsPage' }
        let(:button_id) { 'Buttons_FeatureFlagsTable_0' }
      end
    end

    context 'Quotas tab does not have rename or delete buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Quotas' }
        let(:page_id)   { 'QuotasPage' }
        let(:button_id) { 'Buttons_QuotasTable_0' }
      end
    end

    context 'Space Quotas tab does not have rename or delete buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'SpaceQuotas' }
        let(:page_id)   { 'SpaceQuotasPage' }
        let(:button_id) { 'Buttons_SpaceQuotasTable_0' }
      end
    end

    context 'Stacks tab does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Stacks' }
        let(:page_id)   { 'StacksPage' }
        let(:button_id) { 'Buttons_StacksTable_0' }
      end
    end

    context 'Stacks tab Labels subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Stacks' }
        let(:page_id)   { 'StacksPage' }
        let(:button_id) { 'Buttons_StacksLabelsTable_0' }
      end
    end

    context 'Stacks tab Annotations subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Stacks' }
        let(:page_id)   { 'StacksPage' }
        let(:button_id) { 'Buttons_StacksAnnotationsTable_0' }
      end
    end

    context 'Service Brokers tab does not have rename or delete buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'ServiceBrokers' }
        let(:page_id)   { 'ServiceBrokersPage' }
        let(:button_id) { 'Buttons_ServiceBrokersTable_0' }
      end
    end

    context 'Service Brokers tab Labels subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'ServiceBrokers' }
        let(:page_id)   { 'ServiceBrokersPage' }
        let(:button_id) { 'Buttons_ServiceBrokersLabelsTable_0' }
      end
    end

    context 'Service Brokers tab Annotations subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'ServiceBrokers' }
        let(:page_id)   { 'ServiceBrokersPage' }
        let(:button_id) { 'Buttons_ServiceBrokersAnnotationsTable_0' }
      end
    end

    context 'Services tab does not have delete or purge buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Services' }
        let(:page_id)   { 'ServicesPage' }
        let(:button_id) { 'Buttons_ServicesTable_0' }
      end
    end

    context 'Services tab Labels subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Services' }
        let(:page_id)   { 'ServicesPage' }
        let(:button_id) { 'Buttons_ServicesLabelsTable_0' }
      end
    end

    context 'Service tab Annotations subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Services' }
        let(:page_id)   { 'ServicesPage' }
        let(:button_id) { 'Buttons_ServicesAnnotationsTable_0' }
      end
    end

    context 'Service Plans tab does not have public, private or delete buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'ServicePlans' }
        let(:page_id)   { 'ServicePlansPage' }
        let(:button_id) { 'Buttons_ServicePlansTable_0' }
      end
    end

    context 'Service Plans tab Labels subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'ServicePlans' }
        let(:page_id)   { 'ServicePlansPage' }
        let(:button_id) { 'Buttons_ServicePlansLabelsTable_0' }
      end
    end

    context 'Service Plans tab Annotations subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'ServicePlans' }
        let(:page_id)   { 'ServicePlansPage' }
        let(:button_id) { 'Buttons_ServicePlansAnnotationsTable_0' }
      end
    end

    context 'Service Plan Visibilities tab does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'ServicePlanVisibilities' }
        let(:page_id)   { 'ServicePlanVisibilitiesPage' }
        let(:button_id) { 'Buttons_ServicePlanVisibilitiesTable_0' }
      end
    end

    context 'Identity Zones tab does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'IdentityZones' }
        let(:page_id)   { 'IdentityZonesPage' }
        let(:button_id) { 'Buttons_IdentityZonesTable_0' }
      end
    end

    context 'Identity Providers tab does not have require password change for users or delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'IdentityProviders' }
        let(:page_id)   { 'IdentityProvidersPage' }
        let(:button_id) { 'Buttons_IdentityProvidersTable_0' }
      end
    end

    context 'SAML Providers tab does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'ServiceProviders' }
        let(:page_id)   { 'ServiceProvidersPage' }
        let(:button_id) { 'Buttons_ServiceProvidersTable_0' }
      end
    end

    context 'MFA Providers tab does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'MFAProviders' }
        let(:page_id)   { 'MFAProvidersPage' }
        let(:button_id) { 'Buttons_MFAProvidersTable_0' }
      end
    end

    context 'Security Groups tab does not have rename, enable staging, disable staging, enable running, disable running or delete buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'SecurityGroups' }
        let(:page_id)   { 'SecurityGroupsPage' }
        let(:button_id) { 'Buttons_SecurityGroupsTable_0' }
      end
    end

    context 'Security Groups Spaces tab does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'SecurityGroupsSpaces' }
        let(:page_id)   { 'SecurityGroupsSpacesPage' }
        let(:button_id) { 'Buttons_SecurityGroupsSpacesTable_0' }
      end
    end

    context 'Staging Security Groups Spaces tab does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'StagingSecurityGroupsSpaces' }
        let(:page_id)   { 'StagingSecurityGroupsSpacesPage' }
        let(:button_id) { 'Buttons_StagingSecurityGroupsSpacesTable_0' }
      end
    end

    context 'Isolation Segments tab does not have create, rename or delete buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'IsolationSegments' }
        let(:page_id)   { 'IsolationSegmentsPage' }
        let(:button_id) { 'Buttons_IsolationSegmentsTable_0' }
      end
    end

    context 'Isolation Segments tab Labels subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'IsolationSegments' }
        let(:page_id)   { 'IsolationSegmentsPage' }
        let(:button_id) { 'Buttons_IsolationSegmentsLabelsTable_0' }
      end
    end

    context 'Isolation Segments tab Annotations subtable does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'IsolationSegments' }
        let(:page_id)   { 'IsolationSegmentsPage' }
        let(:button_id) { 'Buttons_IsolationSegmentsAnnotationsTable_0' }
      end
    end

    context 'Organizations Isolation Segments tab does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'OrganizationsIsolationSegments' }
        let(:page_id)   { 'OrganizationsIsolationSegmentsPage' }
        let(:button_id) { 'Buttons_OrganizationsIsolationSegmentsTable_0' }
      end
    end

    context 'Components tab does not have a remove all components buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Components' }
        let(:page_id)   { 'ComponentsPage' }
        let(:button_id) { 'Buttons_ComponentsTable_0' }
      end
    end

    context 'Stats tab does not have a create stats button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Stats' }
        let(:page_id)   { 'StatsPage' }
        let(:button_id) { 'Buttons_StatsTable_0' }
      end
    end
  end
end
