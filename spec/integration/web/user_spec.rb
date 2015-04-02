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
      expect(@driver.find_element(class: 'userContainer').displayed?).to be_true
      expect(@driver.find_element(class: 'user').text).to eq('user')
    end

    it 'Organizations tab does not have create, set quota, delete, activate and suspend buttons' do
      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          scroll_tab_into_view('Organizations').click
          @driver.find_element(class_name: 'menuItemSelected').attribute('id') == 'Organizations'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(class_name: 'menuItemSelected').attribute('id')).to eq('Organizations')

      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          @driver.find_element(id: 'OrganizationsPage').displayed? &&
            @driver.find_element(id: 'ToolTables_OrganizationsTable_0').text == 'Copy'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(id: 'OrganizationsPage').displayed?).to eq(true)
      expect(@driver.find_element(id: 'ToolTables_OrganizationsTable_0').text).to eq('Copy')
    end

    it 'Spaces tab does not have delete button' do
      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          scroll_tab_into_view('Spaces').click
          @driver.find_element(class_name: 'menuItemSelected').attribute('id') == 'Spaces'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(class_name: 'menuItemSelected').attribute('id')).to eq('Spaces')

      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          @driver.find_element(id: 'SpacesPage').displayed? &&
            @driver.find_element(id: 'ToolTables_SpacesTable_0').text == 'Copy'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(id: 'SpacesPage').displayed?).to eq(true)
      expect(@driver.find_element(id: 'ToolTables_SpacesTable_0').text).to eq('Copy')
    end

    it 'Applications tab does not have start, stop, restart or delete buttons' do
      # Need to wait until the page has been rendered.
      # Move the click operation into the wait block to ensure the action has been taken, this is used to fit Travis CI system.
      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          scroll_tab_into_view('Applications').click
          @driver.find_element(class_name: 'menuItemSelected').attribute('id') == 'Applications'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(class_name: 'menuItemSelected').attribute('id')).to eq('Applications')

      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          @driver.find_element(id: 'ApplicationsPage').displayed? &&
            @driver.find_element(id: 'ToolTables_ApplicationsTable_0').text == 'Copy'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(id: 'ApplicationsPage').displayed?).to eq(true)
      expect(@driver.find_element(id: 'ToolTables_ApplicationsTable_0').text).to eq('Copy')
    end

    it 'Routes tab does not have delete button' do
      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          scroll_tab_into_view('Routes').click
          @driver.find_element(class_name: 'menuItemSelected').attribute('id') == 'Routes'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(class_name: 'menuItemSelected').attribute('id')).to eq('Routes')

      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          @driver.find_element(id: 'RoutesPage').displayed? &&
            @driver.find_element(id: 'ToolTables_RoutesTable_0').text == 'Copy'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(id: 'RoutesPage').displayed?).to eq(true)
      expect(@driver.find_element(id: 'ToolTables_RoutesTable_0').text).to eq('Copy')
    end

    it 'Service Instances tab does not have delete button' do
      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          scroll_tab_into_view('ServiceInstances').click
          @driver.find_element(class_name: 'menuItemSelected').attribute('id') == 'ServiceInstances'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(class_name: 'menuItemSelected').attribute('id')).to eq('ServiceInstances')

      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          @driver.find_element(id: 'ServiceInstancesPage').displayed? &&
            @driver.find_element(id: 'ToolTables_ServiceInstancesTable_0').text == 'Copy'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(id: 'ServiceInstancesPage').displayed?).to eq(true)
      expect(@driver.find_element(id: 'ToolTables_ServiceInstancesTable_0').text).to eq('Copy')
    end

    it 'Service Bindings tab does not have delete button' do
      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          scroll_tab_into_view('ServiceBindings').click
          @driver.find_element(class_name: 'menuItemSelected').attribute('id') == 'ServiceBindings'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(class_name: 'menuItemSelected').attribute('id')).to eq('ServiceBindings')

      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          @driver.find_element(id: 'ServiceBindingsPage').displayed? &&
            @driver.find_element(id: 'ToolTables_ServiceBindingsTable_0').text == 'Copy'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(id: 'ServiceBindingsPage').displayed?).to eq(true)
      expect(@driver.find_element(id: 'ToolTables_ServiceBindingsTable_0').text).to eq('Copy')
    end

    it 'Organization Roles tab does not have delete button' do
      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          scroll_tab_into_view('OrganizationRoles').click
          @driver.find_element(class_name: 'menuItemSelected').attribute('id') == 'OrganizationRoles'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(class_name: 'menuItemSelected').attribute('id')).to eq('OrganizationRoles')

      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          @driver.find_element(id: 'OrganizationRolesPage').displayed? &&
            @driver.find_element(id: 'ToolTables_OrganizationRolesTable_0').text == 'Copy'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(id: 'OrganizationRolesPage').displayed?).to eq(true)
      expect(@driver.find_element(id: 'ToolTables_OrganizationRolesTable_0').text).to eq('Copy')
    end

    it 'Space Roles tab does not have delete button' do
      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          scroll_tab_into_view('SpaceRoles').click
          @driver.find_element(class_name: 'menuItemSelected').attribute('id') == 'SpaceRoles'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(class_name: 'menuItemSelected').attribute('id')).to eq('SpaceRoles')

      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          @driver.find_element(id: 'SpaceRolesPage').displayed? &&
            @driver.find_element(id: 'ToolTables_SpaceRolesTable_0').text == 'Copy'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(id: 'SpaceRolesPage').displayed?).to eq(true)
      expect(@driver.find_element(id: 'ToolTables_SpaceRolesTable_0').text).to eq('Copy')
    end

    it 'Service Plans tab does not have public and private buttons' do
      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          scroll_tab_into_view('ServicePlans').click
          @driver.find_element(class_name: 'menuItemSelected').attribute('id') == 'ServicePlans'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(class_name: 'menuItemSelected').attribute('id')).to eq('ServicePlans')

      begin
        Selenium::WebDriver::Wait.new(timeout: 10).until do
          @driver.find_element(id: 'ServicePlansPage').displayed? &&
            @driver.find_element(id: 'ToolTables_ServicePlansTable_0').text == 'Copy'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(id: 'ServicePlansPage').displayed?).to eq(true)
      expect(@driver.find_element(id: 'ToolTables_ServicePlansTable_0').text).to eq('Copy')
    end

    it 'DEAs tab does not have a create DEA button' do
      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          scroll_tab_into_view('DEAs').click
          @driver.find_element(class_name: 'menuItemSelected').attribute('id') == 'DEAs'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(class_name: 'menuItemSelected').attribute('id')).to eq('DEAs')

      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          @driver.find_element(id: 'DEAsPage').displayed? &&
            @driver.find_element(id: 'ToolTables_DEAsTable_0').text == 'Copy'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(id: 'DEAsPage').displayed?).to eq(true)
      expect(@driver.find_element(id: 'ToolTables_DEAsTable_0').text).to eq('Copy')
    end

    it 'Components tab does not have a remove all components button' do
      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          scroll_tab_into_view('Components').click
          @driver.find_element(class_name: 'menuItemSelected').attribute('id') == 'Components'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(class_name: 'menuItemSelected').attribute('id')).to eq('Components')

      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          @driver.find_element(id: 'ComponentsPage').displayed? &&
            @driver.find_element(id: 'ToolTables_ComponentsTable_0').text == 'Copy'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(id: 'ComponentsPage').displayed?).to eq(true)
      expect(@driver.find_element(id: 'ToolTables_ComponentsTable_0').text).to eq('Copy')
    end

    it 'Tasks tab does not exist' do
      expect(scroll_tab_into_view('Tasks').displayed?).to be_false
    end

    it 'Stats tab does not have a create stats button' do
      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          scroll_tab_into_view('Stats').click
          @driver.find_element(class_name: 'menuItemSelected').attribute('id') == 'Stats'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(class_name: 'menuItemSelected').attribute('id')).to eq('Stats')

      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          @driver.find_element(id: 'StatsPage').displayed? &&
            @driver.find_element(id: 'ToolTables_StatsTable_0').text == 'Copy'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(id: 'StatsPage').displayed?).to eq(true)
      expect(@driver.find_element(id: 'ToolTables_StatsTable_0').text).to eq('Copy')
    end
  end
end
