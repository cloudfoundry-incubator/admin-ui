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
        begin
          Selenium::WebDriver::Wait.new(timeout: 5).until do
            # TODO: Bug in selenium-webdriver.  Entire item must be displayed for it to click.  Workaround following after commented out code
            # scroll_tab_into_view(tab_id, true).click
            @driver.execute_script('arguments[0].click();', scroll_tab_into_view(tab_id, true))

            @driver.find_element(class_name: 'menuItemSelected').attribute('id') == tab_id
          end
        rescue Selenium::WebDriver::Error::TimeOutError
        end
        expect(@driver.find_element(class_name: 'menuItemSelected').attribute('id')).to eq(tab_id)

        begin
          Selenium::WebDriver::Wait.new(timeout: 5).until do
            @driver.find_element(id: page_id).displayed? &&
              @driver.find_element(id: button_id).text == 'Copy'
          end
        rescue Selenium::WebDriver::Error::TimeOutError
        end
        expect(@driver.find_element(id: page_id).displayed?).to eq(true)
        expect(@driver.find_element(id: button_id).text).to eq('Copy')
      end
    end

    context 'Organizations tab does not have create, rename, set quota, activate, suspend or delete buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Organizations' }
        let(:page_id)   { 'OrganizationsPage' }
        let(:button_id) { 'Buttons_OrganizationsTable_0' }
      end
    end

    context 'Spaces tab does not have rename, allow ssh, disallow ssh, remove isolation segment or delete buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Spaces' }
        let(:page_id)   { 'SpacesPage' }
        let(:button_id) { 'Buttons_SpacesTable_0' }
      end
    end

    context 'Applications tab does not have rename, start, stop, restage, enable diego, disable diego, enable ssh, disable ssh or delete buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Applications' }
        let(:page_id)   { 'ApplicationsPage' }
        let(:button_id) { 'Buttons_ApplicationsTable_0' }
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

    context 'Service Bindings tab does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'ServiceBindings' }
        let(:page_id)   { 'ServiceBindingsPage' }
        let(:button_id) { 'Buttons_ServiceBindingsTable_0' }
      end
    end

    context 'Service Keys tab does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'ServiceKeys' }
        let(:page_id)   { 'ServiceKeysPage' }
        let(:button_id) { 'Buttons_ServiceKeysTable_0' }
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

    context 'Clients tab does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Clients' }
        let(:page_id)   { 'ClientsPage' }
        let(:button_id) { 'Buttons_ClientsTable_0' }
      end
    end

    context 'Users tab does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Users' }
        let(:page_id)   { 'UsersPage' }
        let(:button_id) { 'Buttons_UsersTable_0' }
      end
    end

    context 'Groups tab does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Groups' }
        let(:page_id)   { 'GroupsPage' }
        let(:button_id) { 'Buttons_GroupsTable_0' }
      end
    end

    context 'Buildpacks tab does not have rename, enable, disable, lock, unlock or delete buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Buildpacks' }
        let(:page_id)   { 'BuildpacksPage' }
        let(:button_id) { 'Buttons_BuildpacksTable_0' }
      end
    end

    context 'Domains tab does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Domains' }
        let(:page_id)   { 'DomainsPage' }
        let(:button_id) { 'Buttons_DomainsTable_0' }
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

    context 'Service Brokers tab does not have rename or delete buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'ServiceBrokers' }
        let(:page_id)   { 'ServiceBrokersPage' }
        let(:button_id) { 'Buttons_ServiceBrokersTable_0' }
      end
    end

    context 'Services tab does not have delete or purge buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'Services' }
        let(:page_id)   { 'ServicesPage' }
        let(:button_id) { 'Buttons_ServicesTable_0' }
      end
    end

    context 'Service Plans tab does not have public, private or delete buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'ServicePlans' }
        let(:page_id)   { 'ServicePlansPage' }
        let(:button_id) { 'Buttons_ServicePlansTable_0' }
      end
    end

    context 'Service Plan Visibilities tab does not have delete button' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'ServicePlanVisibilities' }
        let(:page_id)   { 'ServicePlanVisibilitiesPage' }
        let(:button_id) { 'Buttons_ServicePlanVisibilitiesTable_0' }
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

    context 'Isolation Segments tab does not have create, rename or delete buttons' do
      it_behaves_like('verifies first button is copy button') do
        let(:tab_id)    { 'IsolationSegments' }
        let(:page_id)   { 'IsolationSegmentsPage' }
        let(:button_id) { 'Buttons_IsolationSegmentsTable_0' }
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
