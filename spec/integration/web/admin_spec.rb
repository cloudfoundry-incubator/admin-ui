require 'date'
require 'rubygems'
require_relative '../../spec_helper'
require_relative '../../support/web_helper'

describe AdminUI::Admin, :type => :integration, :firefox_available => true do
  include_context :server_context
  include_context :web_context

  it 'requires valid credentials' do
    login(admin_user, 'bad_password', 'Login')
  end

  context 'authenticated' do
    before do
      login(admin_user, admin_password, 'Administration')
    end

    it 'has a title' do
      # Need to wait until the page has been rendered
      begin
        Selenium::WebDriver::Wait.new(:timeout => 5).until { @driver.find_element(:class => 'cloudControllerText').text == cloud_controller_uri }
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(:class => 'cloudControllerText').text).to eq(cloud_controller_uri)
    end

    it 'has tabs' do
      expect(@driver.find_element(:id => 'Organizations').displayed?).to be_true
      expect(@driver.find_element(:id => 'Spaces').displayed?).to be_true
      expect(@driver.find_element(:id => 'Applications').displayed?).to be_true
      expect(@driver.find_element(:id => 'ServiceInstances').displayed?).to be_true
      expect(@driver.find_element(:id => 'Developers').displayed?).to be_true
      expect(@driver.find_element(:id => 'Quotas').displayed?).to be_true
      expect(@driver.find_element(:id => 'ServicePlans').displayed?).to be_true
      expect(@driver.find_element(:id => 'DEAs').displayed?).to be_true
      expect(@driver.find_element(:id => 'CloudControllers').displayed?).to be_true
      expect(@driver.find_element(:id => 'HealthManagers').displayed?).to be_true
      expect(@driver.find_element(:id => 'Gateways').displayed?).to be_true
      expect(@driver.find_element(:id => 'Routers').displayed?).to be_true
      expect(@driver.find_element(:id => 'Routes').displayed?).to be_true
      expect(@driver.find_element(:id => 'Components').displayed?).to be_true
      expect(@driver.find_element(:id => 'Logs').displayed?).to be_true
      expect(@driver.find_element(:id => 'Tasks').displayed?).to be_true
      expect(@driver.find_element(:id => 'Stats').displayed?).to be_true
    end

    it 'has a refresh button' do
      expect(@driver.find_element(:id => 'RefreshButton').displayed?).to be_true
    end

    it 'shows the logged in user' do
      expect(@driver.find_element(:class => 'userContainer').displayed?).to be_true
      expect(@driver.find_element(:class => 'user').text).to eq(admin_user)
    end

    context 'tabs' do
      let(:table_has_data) { true }
      before do
        # Move click action into the wait blog to ensure relevant tab has been clicked and rendered
        # This part is modified to fit Travis CI system.
        begin
          Selenium::WebDriver::Wait.new(:timeout => 5).until do
            @driver.find_element(:id => tab_id).click
            @driver.find_element(:class_name => 'menuItemSelected').attribute('id') == tab_id
          end
        rescue Selenium::WebDriver::Error::TimeOutError
        end
        expect(@driver.find_element(:class_name => 'menuItemSelected').attribute('id')).to eq(tab_id)
        # Need to wait until the page has been rendered
        begin
          Selenium::WebDriver::Wait.new(:timeout => 5).until { @driver.find_element(:id => "#{ tab_id }Page").displayed? }
        rescue Selenium::WebDriver::Error::TimeOutError
        end
        expect(@driver.find_element(:id => "#{ tab_id }Page").displayed?).to eq(true)

        if table_has_data
          # Need to wait until the table on the page has data
          begin
            Selenium::WebDriver::Wait.new(:timeout => 10).until { @driver.find_element(:xpath => "//table[@id='#{ tab_id }Table']/tbody/tr").text != 'No data available in table' }
          rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
          end
          expect(@driver.find_element(:xpath => "//table[@id='#{ tab_id }Table']/tbody/tr").text).not_to eq('No data available in table')
        end
      end

      context 'Organizations' do
        let(:tab_id) { 'Organizations' }
        it 'has a table' do
          check_table_layout([{ :columns         => @driver.find_elements(:xpath => "//div[@id='OrganizationsTableContainer']/div/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                :expected_length => 6,
                                :labels          => ['', 'Routes', 'Used', 'Reserved', 'App States', 'App Package States'],
                                :colspans        => %w(8 3 5 2 3 3)
                              },
                              { :columns         => @driver.find_elements(:xpath => "//div[@id='OrganizationsTableContainer']/div/div[6]/div[1]/div/table/thead/tr[2]/th"),
                                :expected_length => 24,
                                :labels          => [' ', 'Name', 'Status', 'Created', 'Updated', 'Spaces', 'Developers', 'Quota', 'Total', 'Used', 'Unused', 'Instances', 'Services', 'Memory', 'Disk', '% CPU', 'Memory', 'Disk', 'Total', 'Started', 'Stopped', 'Pending', 'Staged', 'Failed'],
                                :colspans        => nil
                              }
                             ])
          check_table_data(@driver.find_elements(:xpath => "//table[@id='OrganizationsTable']/tbody/tr/td"),
                           [
                             '',
                             cc_organizations['resources'][0]['entity']['name'],
                             cc_organizations['resources'][0]['entity']['status'].upcase,
                             @driver.execute_script("return Format.formatString(\"#{ cc_organizations['resources'][0]['metadata']['created_at'] }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_organizations['resources'][0]['metadata']['updated_at'] }\")"),
                             cc_spaces['resources'].length.to_s,
                             cc_users_deep['resources'].length.to_s,
                             cc_quota_definitions['resources'][0]['entity']['name'],
                             cc_routes['resources'].length.to_s,
                             cc_routes['resources'].length.to_s,
                             '0',
                             cc_started_apps['resources'][0]['entity']['instances'].to_s,
                             varz_dea['instance_registry']['application1']['application1_instance1']['services'].length.to_s,
                             @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_memory_in_bytes'] })").to_s,
                             @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_disk_in_bytes'] })").to_s,
                             @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry']['application1']['application1_instance1']['computed_pcpu'] * 100 })").to_s,
                             cc_started_apps['resources'][0]['entity']['memory'].to_s,
                             cc_started_apps['resources'][0]['entity']['disk_quota'].to_s,
                             cc_started_apps['resources'].length.to_s,
                             cc_started_apps['resources'][0]['entity']['state'] == 'STARTED' ? '1' : '0',
                             cc_started_apps['resources'][0]['entity']['state'] == 'STOPPED' ? '1' : '0',
                             cc_started_apps['resources'][0]['entity']['package_state'] == 'PENDING' ? '1' : '0',
                             cc_started_apps['resources'][0]['entity']['package_state'] == 'STAGED'  ? '1' : '0',
                             cc_started_apps['resources'][0]['entity']['package_state'] == 'FAILED'  ? '1' : '0'
                           ])
        end

        it 'has a checkbox in the first column' do
          inputs = @driver.find_elements(:xpath => "//table[@id='OrganizationsTable']/tbody/tr/td[1]/input")
          expect(inputs.length).to eq(1)
          expect(inputs[0].attribute('value')).to eq("#{ cc_organizations['resources'][0]['metadata']['guid'] }")
        end

        context 'set quota' do
          def check_first_row
            @driver.find_elements(:xpath => "//table[@id='OrganizationsTable']/tbody/tr/td[1]/input")[0].click
          end

          def check_operation_result
            alert = nil
            Selenium::WebDriver::Wait.new(:timeout => 5).until { alert = @driver.switch_to.alert }
            expect(alert.text).to eq("The operation finished without error.\nPlease refresh the page later for the updated result.")
            alert.dismiss
          end

          it 'has a set quota button' do
            expect(@driver.find_element(:id => 'ToolTables_OrganizationsTable_1').text).to eq('Set Quota')
          end

          it 'alerts the user to select at least one row when clicking the button without selecting a row' do
            @driver.find_element(:id => 'ToolTables_OrganizationsTable_1').click
            alert = @driver.switch_to.alert
            expect(alert.text).to eq('Please select at least one row!')
            alert.dismiss
          end

          it 'sets the specific quota for the organization' do
            cc_organization_with_different_quota_stub(AdminUI::Config.load(config))

            check_first_row
            @driver.find_element(:id => 'ToolTables_OrganizationsTable_1').click

            # Check whether the dialog is displayed
            expect(@driver.find_element(:id => 'ModalDialogMessageDiv').displayed?).to be_true
            expect(@driver.find_element(:id => 'quotaSelector').displayed?).to be_true
            expect(@driver.find_element(:xpath => '//select[@id="quotaSelector"]/option[1]').text).to eq('test_quota_1')
            expect(@driver.find_element(:xpath => '//select[@id="quotaSelector"]/option[2]').text).to eq('test_quota_2')

            # Select another quota and click the set button
            @driver.find_element(:xpath => '//select[@id="quotaSelector"]/option[2]').click
            @driver.find_element(:id => 'modalDialogButton0').click
            check_operation_result

            begin
              Selenium::WebDriver::Wait.new(:timeout => 5).until { @driver.find_element(:xpath => "//table[@id='OrganizationsTable']/tbody/tr/td[7]").text == 'test_quota_2' }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(:xpath => "//table[@id='OrganizationsTable']/tbody/tr/td[8]").text).to eq('test_quota_2')
          end
        end

        context 'manage organization' do
          def check_first_row
            @driver.find_elements(:xpath => "//table[@id='OrganizationsTable']/tbody/tr/td[1]/input")[0].click
          end

          it 'has a create button' do
            expect(@driver.find_element(:id => 'ToolTables_OrganizationsTable_0').text).to eq('Create')
          end

          it 'has a delete button' do
            expect(@driver.find_element(:id => 'ToolTables_OrganizationsTable_2').text).to eq('Delete')
          end

          it 'creates an organization' do
            cc_multiple_organizations_stub(AdminUI::Config.load(config))

            @driver.find_element(:id => 'ToolTables_OrganizationsTable_0').click

            # Check whether the dialog is displayed
            expect(@driver.find_element(:id => 'ModalDialogMessageDiv').displayed?).to be_true
            expect(@driver.find_element(:id => 'ModalDialogTitleDiv').text).to eq('Create new organization')
            expect(@driver.find_element(:id => 'organizationName').displayed?).to be_true

            # Click the create button without input an organization name
            @driver.find_element(:id => 'modalDialogButton0').click
            alert = @driver.switch_to.alert
            expect(alert.text).to eq('Please input the name of the organization first!')
            alert.dismiss

            # Input the name of the organization and click 'Create'
            @driver.find_element(:id => 'organizationName').send_keys 'new_org'
            @driver.find_element(:id => 'modalDialogButton0').click

            alert = nil
            Selenium::WebDriver::Wait.new(:timeout => 5).until { alert = @driver.switch_to.alert }
            expect(alert.text).to eq("The operation finished without error.\nPlease refresh the page later for the updated result.")
            alert.dismiss

            begin
              Selenium::WebDriver::Wait.new(:timeout => 5).until { @driver.find_element(:xpath => "//table[@id='OrganizationsTable']/tbody/tr[2]/td[2]").text == 'new_org' }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(:xpath => "//table[@id='OrganizationsTable']/tbody/tr[2]/td[2]").text).to eq('new_org')
          end

          it 'has an activate button' do
            expect(@driver.find_element(:id => 'ToolTables_OrganizationsTable_3').text).to eq('Activate')
          end

          it 'has a suspend button' do
            expect(@driver.find_element(:id => 'ToolTables_OrganizationsTable_4').text).to eq('Suspend')
          end

          shared_examples 'click button without selecting a single row' do
            it 'alerts the user to select at least one row when clicking the button' do
              @driver.find_element(:id => buttonId).click
              alert = @driver.switch_to.alert
              expect(alert.text).to eq('Please select at least one row!')
              alert.dismiss
            end
          end

          # Delete button
          it_behaves_like('click button without selecting a single row') do
            let(:buttonId) { 'ToolTables_OrganizationsTable_2' }
          end

          # Activate button
          it_behaves_like('click button without selecting a single row') do
            let(:buttonId) { 'ToolTables_OrganizationsTable_3' }
          end

          # Suspend button
          it_behaves_like('click button without selecting a single row') do
            let(:buttonId) { 'ToolTables_OrganizationsTable_4' }
          end

          def manage_org(button_id, message, result_message)
            check_first_row

            @driver.find_element(:id => button_id).click
            confirm = @driver.switch_to.alert
            expect(confirm.text).to eq(message)
            confirm.accept

            alert = nil
            Selenium::WebDriver::Wait.new(:timeout => 5).until { alert = @driver.switch_to.alert }
            expect(alert.text).to eq(result_message)
            alert.dismiss
          end

          def suspend_org
            manage_org('ToolTables_OrganizationsTable_4', 'Are you sure you want to suspend the selected organizations?', "The operation finished without error.\nPlease refresh the page later for the updated result.")
          end

          def activate_org
            manage_org('ToolTables_OrganizationsTable_3', 'Are you sure you want to activate the selected organizations?', "The operation finished without error.\nPlease refresh the page later for the updated result.")
          end

          def delete_org
            manage_org('ToolTables_OrganizationsTable_2', 'Are you sure you want to delete the selected organizations?', 'Organizations successfully deleted.')
          end

          def check_organization_status(status)
            begin
              Selenium::WebDriver::Wait.new(:timeout => 5).until { @driver.find_element(:xpath => "//table[@id='OrganizationsTable']/tbody/tr/td[3]").text == status }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(:xpath => "//table[@id='OrganizationsTable']/tbody/tr/td[3]").text).to eq(status)
          end

          it 'activates the selected organization' do
            cc_organizations_suspend_active_stub(AdminUI::Config.load(config))

            suspend_org
            check_organization_status('SUSPENDED')

            activate_org
            check_organization_status('ACTIVE')
          end

          it 'suspends the selected organization' do
            cc_suspended_organizations_stub(AdminUI::Config.load(config))

            suspend_org
            check_organization_status('ACTIVE')
          end

          it 'deletes the selected organization' do
            cc_empty_organizations_stub(AdminUI::Config.load(config))

            delete_org

            begin
              Selenium::WebDriver::Wait.new(:timeout => 5).until { @driver.find_element(:xpath => "//table[@id='OrganizationsTable']/tbody/tr").text == 'No data available in table' }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(:xpath => "//table[@id='OrganizationsTable']/tbody/tr").text).to eq('No data available in table')
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end
          it 'has details' do
            check_details([{ :label => 'Name',            :tag => 'div', :value => cc_organizations['resources'][0]['entity']['name'] },
                           { :label => 'Status',          :tag =>   nil, :value => cc_organizations['resources'][0]['entity']['status'].upcase },
                           { :label => 'Created',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_organizations['resources'][0]['metadata']['created_at'] }\")") },
                           { :label => 'Updated',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_organizations['resources'][0]['metadata']['updated_at'] }\")") },
                           { :label => 'Billing Enabled', :tag =>   nil, :value => cc_organizations['resources'][0]['entity']['billing_enabled'].to_s },
                           { :label => 'Spaces',          :tag =>   'a', :value => cc_spaces['resources'].length.to_s },
                           { :label => 'Developers',      :tag =>   'a', :value => cc_users_deep['resources'].length.to_s },
                           { :label => 'Quota',           :tag =>   nil, :value => cc_quota_definitions['resources'][0]['entity']['name'] },
                           { :label => 'Total Routes',    :tag =>   'a', :value => cc_routes['resources'].length.to_s },
                           { :label => 'Used Routes',     :tag =>   nil, :value => cc_routes['resources'].length.to_s },
                           { :label => 'Unused Routes',   :tag =>   nil, :value => '0' },
                           { :label => 'Instances Used',  :tag =>   'a', :value => cc_started_apps['resources'][0]['entity']['instances'].to_s },
                           { :label => 'Services Used',   :tag =>   'a', :value => varz_dea['instance_registry']['application1']['application1_instance1']['services'].length.to_s },
                           { :label => 'Memory Used',     :tag =>   nil, :value => @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_memory_in_bytes'] })").to_s },
                           { :label => 'Disk Used',       :tag =>   nil, :value => @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_disk_in_bytes'] })").to_s },
                           { :label => 'CPU Used',        :tag =>   nil, :value => @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry']['application1']['application1_instance1']['computed_pcpu'] * 100 })").to_s },
                           { :label => 'Memory Reserved', :tag =>   nil, :value => cc_started_apps['resources'][0]['entity']['memory'].to_s },
                           { :label => 'Disk Reserved',   :tag =>   nil, :value => cc_started_apps['resources'][0]['entity']['disk_quota'].to_s },
                           { :label => 'Total Apps',      :tag =>   'a', :value => cc_started_apps['resources'].length.to_s },
                           { :label => 'Started Apps',    :tag =>   nil, :value => cc_started_apps['resources'][0]['entity']['state'] == 'STARTED' ? '1' : '0' },
                           { :label => 'Stopped Apps',    :tag =>   nil, :value => cc_started_apps['resources'][0]['entity']['state'] == 'STOPPED' ? '1' : '0' },
                           { :label => 'Pending Apps',    :tag =>   nil, :value => cc_started_apps['resources'][0]['entity']['package_state'] == 'PENDING' ? '1' : '0' },
                           { :label => 'Staged Apps',     :tag =>   nil, :value => cc_started_apps['resources'][0]['entity']['package_state'] == 'STAGED'  ? '1' : '0' },
                           { :label => 'Failed Apps',     :tag =>   nil, :value => cc_started_apps['resources'][0]['entity']['package_state'] == 'FAILED'  ? '1' : '0' }
                          ])
          end
          it 'has spaces link' do
            check_filter_link('Organizations', 5, 'Spaces', "#{ cc_organizations['resources'][0]['entity']['name'] }/")
          end
          it 'has developers link' do
            check_filter_link('Organizations', 6, 'Developers', "#{ cc_organizations['resources'][0]['entity']['name'] }/")
          end
          it 'has quota link' do
            check_filter_link('Organizations', 7, 'Quotas', "#{ cc_quota_definitions['resources'][0]['entity']['name'] }")
          end
          it 'has routes link' do
            check_filter_link('Organizations', 8, 'Routes', "#{ cc_organizations['resources'][0]['entity']['name'] }/")
          end
          it 'has instances link' do
            check_filter_link('Organizations', 11, 'Applications', "#{ cc_organizations['resources'][0]['entity']['name'] }/")
          end
          it 'has services link' do
            check_filter_link('Organizations', 12, 'ServiceInstances', "#{ cc_organizations['resources'][0]['entity']['name'] }/")
          end
          it 'has applications link' do
            check_filter_link('Organizations', 18, 'Applications', "#{ cc_organizations['resources'][0]['entity']['name'] }/")
          end
        end
      end

      context 'Spaces' do
        let(:tab_id) { 'Spaces' }
        it 'has a table' do
          check_table_layout([{ :columns         => @driver.find_elements(:xpath => "//div[@id='SpacesTableContainer']/div/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                :expected_length => 6,
                                :labels          => ['', 'Routes', 'Used', 'Reserved', 'App States', 'App Package States'],
                                :colspans        => %w(5 3 5 2 3 3)
                              },
                              {
                                :columns         => @driver.find_elements(:xpath => "//div[@id='SpacesTableContainer']/div/div[6]/div[1]/div/table/thead/tr[2]/th"),
                                :expected_length => 21,
                                :labels          => ['Name', 'Target', 'Created', 'Updated', 'Developers', 'Total', 'Used', 'Unused', 'Instances', 'Services', 'Memory', 'Disk', '% CPU', 'Memory', 'Disk', 'Total', 'Started', 'Stopped', 'Pending', 'Staged', 'Failed'],
                                :colspans        => nil
                              }
                             ])
          check_table_data(@driver.find_elements(:xpath => "//table[@id='SpacesTable']/tbody/tr/td"),
                           [
                             cc_spaces['resources'][0]['entity']['name'],
                             "#{ cc_organizations['resources'][0]['entity']['name'] }/#{ cc_spaces['resources'][0]['entity']['name'] }",
                             @driver.execute_script("return Format.formatString(\"#{ cc_spaces['resources'][0]['metadata']['created_at'] }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_spaces['resources'][0]['metadata']['updated_at'] }\")"),
                             cc_users_deep['resources'].length.to_s,
                             cc_routes['resources'].length.to_s,
                             cc_routes['resources'].length.to_s,
                             '0',
                             cc_started_apps['resources'][0]['entity']['instances'].to_s,
                             varz_dea['instance_registry']['application1']['application1_instance1']['services'].length.to_s,
                             @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_memory_in_bytes'] })").to_s,
                             @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_disk_in_bytes'] })").to_s,
                             @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry']['application1']['application1_instance1']['computed_pcpu'] * 100 })").to_s,
                             cc_started_apps['resources'][0]['entity']['memory'].to_s,
                             cc_started_apps['resources'][0]['entity']['disk_quota'].to_s,
                             cc_started_apps['resources'].length.to_s,
                             cc_started_apps['resources'][0]['entity']['state'] == 'STARTED' ? '1' : '0',
                             cc_started_apps['resources'][0]['entity']['state'] == 'STOPPED' ? '1' : '0',
                             cc_started_apps['resources'][0]['entity']['package_state'] == 'PENDING' ? '1' : '0',
                             cc_started_apps['resources'][0]['entity']['package_state'] == 'STAGED'  ? '1' : '0',
                             cc_started_apps['resources'][0]['entity']['package_state'] == 'FAILED'  ? '1' : '0'
                           ])
        end
        context 'selectable' do
          before do
            select_first_row
          end
          it 'has details' do
            check_details([{ :label => 'Name',            :tag => 'div', :value => cc_spaces['resources'][0]['entity']['name'] },
                           { :label => 'Organization',    :tag =>   'a', :value => cc_organizations['resources'][0]['entity']['name'] },
                           { :label => 'Created',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_spaces['resources'][0]['metadata']['created_at'] }\")") },
                           { :label => 'Updated',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_spaces['resources'][0]['metadata']['updated_at'] }\")") },
                           { :label => 'Developers',      :tag =>   'a', :value => cc_users_deep['resources'].length.to_s },
                           { :label => 'Total Routes',    :tag =>   nil, :value => cc_routes['resources'].length.to_s },
                           { :label => 'Used Routes',     :tag =>   nil, :value => cc_routes['resources'].length.to_s },
                           { :label => 'Unused Routes',   :tag =>   nil, :value => '0' },
                           { :label => 'Instances Used',  :tag =>   'a', :value => cc_started_apps['resources'][0]['entity']['instances'].to_s },
                           { :label => 'Services Used',   :tag =>   'a', :value => varz_dea['instance_registry']['application1']['application1_instance1']['services'].length.to_s },
                           { :label => 'Memory Used',     :tag =>   nil, :value => @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_memory_in_bytes'] })").to_s },
                           { :label => 'Disk Used',       :tag =>   nil, :value => @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_disk_in_bytes'] })").to_s },
                           { :label => 'CPU Used',        :tag =>   nil, :value => @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry']['application1']['application1_instance1']['computed_pcpu'] * 100 })").to_s },
                           { :label => 'Memory Reserved', :tag =>   nil, :value => cc_started_apps['resources'][0]['entity']['memory'].to_s },
                           { :label => 'Disk Reserved',   :tag =>   nil, :value => cc_started_apps['resources'][0]['entity']['disk_quota'].to_s },
                           { :label => 'Total Apps',      :tag =>   'a', :value => cc_started_apps['resources'].length.to_s },
                           { :label => 'Started Apps',    :tag =>   nil, :value => cc_started_apps['resources'][0]['entity']['state'] == 'STARTED' ? '1' : '0' },
                           { :label => 'Stopped Apps',    :tag =>   nil, :value => cc_started_apps['resources'][0]['entity']['state'] == 'STOPPED' ? '1' : '0' },
                           { :label => 'Pending Apps',    :tag =>   nil, :value => cc_started_apps['resources'][0]['entity']['package_state'] == 'PENDING' ? '1' : '0' },
                           { :label => 'Staged Apps',     :tag =>   nil, :value => cc_started_apps['resources'][0]['entity']['package_state'] == 'STAGED'  ? '1' : '0' },
                           { :label => 'Failed Apps',     :tag =>   nil, :value => cc_started_apps['resources'][0]['entity']['package_state'] == 'FAILED'  ? '1' : '0' }
                          ])
          end
          it 'has organization link' do
            check_filter_link('Spaces', 1, 'Organizations', cc_organizations['resources'][0]['entity']['name'])
          end
          it 'has developers link' do
            check_filter_link('Spaces', 4, 'Developers', "#{ cc_organizations['resources'][0]['entity']['name'] }/#{ cc_spaces['resources'][0]['entity']['name'] }")
          end
          it 'has routes link' do
            check_filter_link('Spaces', 5, 'Routes', "#{ cc_organizations['resources'][0]['entity']['name'] }/#{ cc_spaces['resources'][0]['entity']['name'] }")
          end
          it 'has instances link' do
            check_filter_link('Spaces', 8, 'Applications', "#{ cc_organizations['resources'][0]['entity']['name'] }/#{ cc_spaces['resources'][0]['entity']['name'] }")
          end
          it 'has services link' do
            check_filter_link('Spaces', 9, 'ServiceInstances', "#{ cc_organizations['resources'][0]['entity']['name'] }/#{ cc_spaces['resources'][0]['entity']['name'] }")
          end
          it 'has applications link' do
            check_filter_link('Spaces', 15, 'Applications', "#{ cc_organizations['resources'][0]['entity']['name'] }/#{ cc_spaces['resources'][0]['entity']['name'] }")
          end
        end
      end

      context 'Applications' do
        let(:tab_id) { 'Applications' }
        it 'has a table' do
          check_table_layout([{ :columns         => @driver.find_elements(:xpath => "//div[@id='ApplicationsTableContainer']/div/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                :expected_length => 4,
                                :labels          => ['', 'Used', 'Reserved', ''],
                                :colspans        => %w(11 4 2 2)
                              },
                              {
                                :columns         => @driver.find_elements(:xpath => "//div[@id='ApplicationsTableContainer']/div/div[6]/div[1]/div/table/thead/tr[2]/th"),
                                :expected_length => 19,
                                :labels          => [' ', 'Name', 'State', "Package\nState", "Instance\nState", 'Created', 'Updated', 'Started', 'URI', 'Buildpack', 'Instance', 'Services', 'Memory', 'Disk', '% CPU', 'Memory', 'Disk', 'Target', 'DEA'],
                                :colspans        => nil
                              }
                             ])
          check_table_data(@driver.find_elements(:xpath => "//table[@id='ApplicationsTable']/tbody/tr/td"),
                           [
                             '',
                             cc_started_apps['resources'][0]['entity']['name'],
                             cc_started_apps['resources'][0]['entity']['state'],
                             @driver.execute_script('return Constants.STATUS__STAGED'),
                             varz_dea['instance_registry']['application1']['application1_instance1']['state'],
                             @driver.execute_script("return Format.formatString(\"#{ cc_started_apps['resources'][0]['metadata']['created_at'] }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_started_apps['resources'][0]['metadata']['updated_at'] }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ DateTime.parse(Time.at(varz_dea['instance_registry']['application1']['application1_instance1']['state_running_timestamp']).to_s).rfc3339 }\")"),
                             "http://#{ varz_dea['instance_registry']['application1']['application1_instance1']['application_uris'][0] }",
                             cc_started_apps['resources'][0]['entity']['detected_buildpack'],
                             varz_dea['instance_registry']['application1']['application1_instance1']['instance_index'].to_s,
                             varz_dea['instance_registry']['application1']['application1_instance1']['services'].length.to_s,
                             @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_memory_in_bytes'] })").to_s,
                             @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_disk_in_bytes'] })").to_s,
                             @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry']['application1']['application1_instance1']['computed_pcpu'] * 100 })").to_s,
                             cc_started_apps['resources'][0]['entity']['memory'].to_s,
                             cc_started_apps['resources'][0]['entity']['disk_quota'].to_s,
                             "#{ cc_organizations['resources'][0]['entity']['name'] }/#{ cc_spaces['resources'][0]['entity']['name'] }",
                             nats_dea['host']
                           ])
        end

        it 'has a checkbox in the first column' do
          inputs = @driver.find_elements(:xpath => "//table[@id='ApplicationsTable']/tbody/tr/td[1]/input")
          expect(inputs.length).to eq(1)
          expect(inputs[0].attribute('value')).to eq("#{ cc_started_apps['resources'][0]['metadata']['guid'] }")
        end

        context 'manage application' do
          def manage_application(buttonIndex)
            check_first_row
            @driver.find_element(:id => 'ToolTables_ApplicationsTable_' + buttonIndex.to_s).click
            check_operation_result
          end

          def check_first_row
            @driver.find_elements(:xpath => "//table[@id='ApplicationsTable']/tbody/tr/td[1]/input")[0].click
          end

          def check_app_state(expect_state)
            # As the UI table will be refreshed and recreated, add a try-catch block in case the selenium stale element
            # error happens.
            Selenium::WebDriver::Wait.new(:timeout => 5).until { @driver.find_element(:xpath => "//table[@id='ApplicationsTable']/tbody/tr/td[3]").text == expect_state }
          rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            expect(@driver.find_element(:xpath => "//table[@id='ApplicationsTable']/tbody/tr/td[3]").text).to eq(expect_state)
          end

          def check_operation_result
            alert = nil
            Selenium::WebDriver::Wait.new(:timeout => 5).until { alert = @driver.switch_to.alert }
            expect(alert.text).to eq("The operation finished without error.\nPlease refresh the page later for the updated result.")
            alert.dismiss
          end

          it 'has a start button' do
            expect(@driver.find_element(:id => 'ToolTables_ApplicationsTable_0').text).to eq('Start')
          end

          it 'has a stop button' do
            expect(@driver.find_element(:id => 'ToolTables_ApplicationsTable_1').text).to eq('Stop')
          end

          it 'has a restart button' do
            expect(@driver.find_element(:id => 'ToolTables_ApplicationsTable_2').text).to eq('Restart')
          end

          it 'has a delete button' do
            expect(@driver.find_element(:id => 'ToolTables_ApplicationsTable_3').text).to eq('Delete')
          end

          shared_examples 'click start button without selecting a single row' do
            it 'alerts the user to select at least one row when clicking the button' do
              @driver.find_element(:id => buttonId).click
              alert = @driver.switch_to.alert
              expect(alert.text).to eq('Please select at least one row!')
              alert.dismiss
            end
          end

          # Start button
          it_behaves_like('click start button without selecting a single row') do
            let(:buttonId) { 'ToolTables_ApplicationsTable_0' }
          end
          # Stop button
          it_behaves_like('click start button without selecting a single row') do
            let(:buttonId) { 'ToolTables_ApplicationsTable_1' }
          end
          # Restart button
          it_behaves_like('click start button without selecting a single row') do
            let(:buttonId) { 'ToolTables_ApplicationsTable_2' }
          end
          # Delete button
          it_behaves_like('click start button without selecting a single row') do
            let(:buttonId) { 'ToolTables_ApplicationsTable_3' }
          end

          it 'stops the selected application' do
            cc_stopped_apps_stub(AdminUI::Config.load(config))

            # stop the app
            manage_application(1)
            check_app_state('STOPPED')
          end
          it 'starts the selected application' do
            # let app in stopped state first
            cc_apps_stop_to_start_stub(AdminUI::Config.load(config))
            manage_application(1)
            check_app_state('STOPPED')

            # start the app
            manage_application(0)
            check_app_state('STARTED')
          end
          it 'restart the selected application' do
            # let app in stopped state first
            cc_apps_stop_to_start_stub(AdminUI::Config.load(config))
            manage_application(1)
            check_app_state('STOPPED')

            # restart the app
            manage_application(2)
            check_app_state('STARTED')
          end

          def check_deleted_app_table_data
            check_table_data(@driver.find_elements(:xpath => "//table[@id='ApplicationsTable']/tbody/tr/td"),
                             [
                               '',
                               cc_started_apps['resources'][0]['entity']['name'],
                               '',
                               '',
                               varz_dea['instance_registry']['application1']['application1_instance1']['state'],
                               '',
                               '',
                               @driver.execute_script("return Format.formatString(\"#{ DateTime.parse(Time.at(varz_dea['instance_registry']['application1']['application1_instance1']['state_running_timestamp']).to_s).rfc3339 }\")"),
                               "http://#{ varz_dea['instance_registry']['application1']['application1_instance1']['application_uris'][0] }",
                               '',
                               '0',
                               varz_dea['instance_registry']['application1']['application1_instance1']['services'].length.to_s,
                               @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_memory_in_bytes'] })").to_s,
                               @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_disk_in_bytes'] })").to_s,
                               @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry']['application1']['application1_instance1']['computed_pcpu'] * 100 })").to_s,
                               cc_started_apps['resources'][0]['entity']['memory'].to_s,
                               cc_started_apps['resources'][0]['entity']['disk_quota'].to_s,
                               '',
                               nats_dea['host']
                             ])
          end

          it 'deletes the selected application' do
            cc_empty_applications_stub(AdminUI::Config.load(config))

            # delete the application
            check_first_row
            @driver.find_element(:id => 'ToolTables_ApplicationsTable_3').click
            confirm = @driver.switch_to.alert
            expect(confirm.text).to eq('Are you sure you want to delete the selected applications?')
            confirm.accept

            check_operation_result

            begin
              Selenium::WebDriver::Wait.new(:timeout => 5).until do
                begin
                  check_deleted_app_table_data
                rescue RSpec::Expectations::ExpectationNotMetError
                end
              end
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            check_deleted_app_table_data
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end
          it 'has details' do
            check_details([{ :label => 'Name',            :tag => 'div', :value => cc_started_apps['resources'][0]['entity']['name'] },
                           { :label => 'State',           :tag =>   nil, :value => cc_started_apps['resources'][0]['entity']['state'] },
                           { :label => 'Package State',   :tag =>   nil, :value => cc_started_apps['resources'][0]['entity']['package_state'] },
                           { :label => 'Instance State',  :tag =>   nil, :value => varz_dea['instance_registry']['application1']['application1_instance1']['state'] },
                           { :label => 'Created',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_started_apps['resources'][0]['metadata']['created_at']}\")") },
                           { :label => 'Updated',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_started_apps['resources'][0]['metadata']['updated_at'] }\")") },
                           { :label => 'Started',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateNumber(#{ (varz_dea['instance_registry']['application1']['application1_instance1']['state_running_timestamp'] * 1000) })") },
                           { :label => 'URI',             :tag =>   'a', :value => "http://#{ varz_dea['instance_registry']['application1']['application1_instance1']['application_uris'][0] }" },
                           { :label => 'Buildpack',       :tag =>   nil, :value => cc_started_apps['resources'][0]['entity']['detected_buildpack'] },
                           { :label => 'Instance Index',  :tag =>   nil, :value => varz_dea['instance_registry']['application1']['application1_instance1']['instance_index'].to_s },
                           { :label => 'Droplet Hash',    :tag =>   nil, :value => varz_dea['instance_registry']['application1']['application1_instance1']['droplet_sha1'].to_s },
                           { :label => 'Services Used',        :tag =>   nil, :value => varz_dea['instance_registry']['application1']['application1_instance1']['services'].length.to_s },
                           { :label => 'Memory Used',     :tag =>   nil, :value => @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_memory_in_bytes'] })").to_s },
                           { :label => 'Disk Used',       :tag =>   nil, :value => @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_disk_in_bytes'] })").to_s },
                           { :label => 'CPU Used',        :tag =>   nil, :value => @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry']['application1']['application1_instance1']['computed_pcpu'] * 100 })").to_s },
                           { :label => 'Memory Reserved', :tag =>   nil, :value => cc_started_apps['resources'][0]['entity']['memory'].to_s },
                           { :label => 'Disk Reserved',   :tag =>   nil, :value => cc_started_apps['resources'][0]['entity']['disk_quota'].to_s },
                           { :label => 'Space',           :tag =>   'a', :value => cc_spaces['resources'][0]['entity']['name'] },
                           { :label => 'Organization',    :tag =>   'a', :value => cc_organizations['resources'][0]['entity']['name'] },
                           { :label => 'DEA',             :tag =>   'a', :value => nats_dea['host'] }
                          ])
          end
          it 'has services' do
            expect(@driver.find_element(:id => 'ApplicationsServicesDetailsLabel').displayed?).to be_true
            check_table_headers(:columns         => @driver.find_elements(:xpath => "//div[@id='ApplicationsServicesTableContainer']/div[2]/div[5]/div[1]/div/table/thead/tr/th"),
                                :expected_length => 5,
                                :labels          => ['Instance Name', 'Provider', 'Service Name', 'Version', 'Plan Name'],
                                :colspans        => nil)
            check_table_data(@driver.find_elements(:xpath => "//table[@id='ApplicationsServicesTable']/tbody/tr/td"),
                             [
                               varz_dea['instance_registry']['application1']['application1_instance1']['services'][0]['name'],
                               varz_dea['instance_registry']['application1']['application1_instance1']['services'][0]['provider'],
                               varz_dea['instance_registry']['application1']['application1_instance1']['services'][0]['vendor'],
                               varz_dea['instance_registry']['application1']['application1_instance1']['services'][0]['version'],
                               varz_dea['instance_registry']['application1']['application1_instance1']['services'][0]['plan']
                             ])
          end
          it 'has space link' do
            check_filter_link('Applications', 17, 'Spaces', "#{ cc_organizations['resources'][0]['entity']['name'] }/#{ cc_spaces['resources'][0]['entity']['name'] }")
          end
          it 'has organization link' do
            check_filter_link('Applications', 18, 'Organizations', cc_organizations['resources'][0]['entity']['name'])
          end
          it 'has DEA link' do
            check_filter_link('Applications', 19, 'DEAs', nats_dea['host'])
          end
        end
      end

      context 'Routes' do
        let(:tab_id) { 'Routes' }
        it 'has a table' do
          check_table_layout([{ :columns         => @driver.find_elements(:xpath => "//div[@id='RoutesTableContainer']/div/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                :expected_length => 7,
                                :labels          => [' ', 'Host', 'Domain', 'Created', 'Updated', 'Target', 'Application'],
                                :colspans        => nil
                              }
                              ])
          app_names = []
          cc_routes['resources'][0]['entity']['apps'].each do |app|
            app_names.push(app['entity']['name'])
          end

          check_table_data(@driver.find_elements(:xpath => "//table[@id='RoutesTable']/tbody/tr/td"),
                           [
                             '',
                             cc_routes['resources'][0]['entity']['host'],
                             cc_routes['resources'][0]['entity']['domain']['entity']['name'],
                             @driver.execute_script("return Format.formatString(\"#{ cc_routes['resources'][0]['metadata']['created_at'] }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_routes['resources'][0]['metadata']['updated_at'] }\")"),
                             "#{ cc_organizations['resources'][0]['entity']['name'] }/#{ cc_spaces['resources'][0]['entity']['name'] }",
                             app_names.join('\n')
                           ])
        end

        it 'has a checkbox in the first column' do
          inputs = @driver.find_elements(:xpath => "//table[@id='RoutesTable']/tbody/tr/td[1]/input")
          expect(inputs.length).to eq(1)
          expect(inputs[0].attribute('value')).to eq("#{ cc_routes['resources'][0]['metadata']['guid']}")
        end

        context 'manage routes' do
          def check_first_row
            @driver.find_elements(:xpath => "//table[@id='RoutesTable']/tbody/tr/td[1]/input")[0].click
          end

          it 'has a delete button' do
            expect(@driver.find_element(:id => 'ToolTables_RoutesTable_0').text).to eq('Delete')
          end

          it 'alerts the user to select at least one row when clicking the delete button' do
            @driver.find_element(:id => 'ToolTables_RoutesTable_0').click
            alert = @driver.switch_to.alert
            expect(alert.text).to eq('Please select at least one row!')
            alert.dismiss
          end

          it 'deletes the selected route' do
            cc_empty_routes_stub(AdminUI::Config.load(config))

            # delete the route
            check_first_row
            @driver.find_element(:id => 'ToolTables_RoutesTable_0').click
            confirm = @driver.switch_to.alert
            expect(confirm.text).to eq('Are you sure you want to delete the selected routes?')
            confirm.accept

            alert = nil
            Selenium::WebDriver::Wait.new(:timeout => 5).until { alert = @driver.switch_to.alert }
            expect(alert.text).to eq('Routes successfully deleted.')
            alert.dismiss

            begin
              Selenium::WebDriver::Wait.new(:timeout => 5).until { @driver.find_element(:xpath => "//table[@id='RoutesTable']/tbody/tr").text == 'No data available in table' }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(:xpath => "//table[@id='RoutesTable']/tbody/tr").text).to eq('No data available in table')
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([{ :label => 'Host',          :tag => nil, :value => cc_routes['resources'][0]['entity']['host'] },
                           { :label => 'Domain',        :tag => nil, :value => cc_routes['resources'][0]['entity']['domain']['entity']['name'] },
                           { :label => 'Created',       :tag => nil, :value => Selenium::WebDriver::Wait.new(:timeout => 5).until { @driver.execute_script("return Format.formatDateString(\"#{ cc_routes['resources'][0]['metadata']['created_at'] }\")") } },
                           { :label => 'Updated',       :tag => nil, :value => Selenium::WebDriver::Wait.new(:timeout => 5).until { @driver.execute_script("return Format.formatDateString(\"#{ cc_routes['resources'][0]['metadata']['updated_at'] }\")") } },
                           { :label => 'Applications',  :tag => 'a', :value => cc_routes['resources'][0]['entity']['apps'].length.to_s },
                           { :label => 'Space',         :tag => 'a', :value => cc_spaces['resources'][0]['entity']['name'] },
                           { :label => 'Organization',  :tag => 'a', :value => cc_organizations['resources'][0]['entity']['name'] }
                          ])
          end

          it 'has applications link' do
            check_filter_link('Routes', 4, 'Applications', "#{ cc_routes['resources'][0]['entity']['host'] }.#{ cc_routes['resources'][0]['entity']['domain']['entity']['name'] }")
          end
          it 'has space link' do
            check_filter_link('Routes', 5, 'Spaces', "#{ cc_organizations['resources'][0]['entity']['name'] }/#{ cc_spaces['resources'][0]['entity']['name']}")
          end
          it 'has organization link' do
            check_filter_link('Routes', 6, 'Organizations', "#{ cc_organizations['resources'][0]['entity']['name'] }")
          end
        end
      end

      context 'Service Instances' do
        let(:tab_id) { 'ServiceInstances' }
        it 'has a table' do
          check_table_layout([{ :columns         => @driver.find_elements(:xpath => "//div[@id='ServiceInstancesTableContainer']/div/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                :expected_length => 5,
                                :labels          => ['Service Broker', 'Service', 'Service Plan', 'Service Instance', ''],
                                :colspans        => %w(3 5 5 4 1)
                              },
                              {
                                :columns         => @driver.find_elements(:xpath => "//div[@id='ServiceInstancesTableContainer']/div/div[6]/div[1]/div/table/thead/tr[2]/th"),
                                :expected_length => 18,
                                :labels          => %w(Name Created Updated Provider Label Version Created Updated Name Created Updated Public Target Name Created Updated Bindings Target),
                                :colspans        => nil
                              }
                             ])
          check_table_data(@driver.find_elements(:xpath => "//table[@id='ServiceInstancesTable']/tbody/tr/td"),
                           [
                             cc_service_brokers['resources'][0]['entity']['name'],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_brokers['resources'][0]['metadata']['created_at'] }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_brokers['resources'][0]['metadata']['updated_at'] }\")"),
                             cc_services['resources'][0]['entity']['provider'],
                             cc_services['resources'][0]['entity']['label'],
                             cc_services['resources'][0]['entity']['version'],
                             @driver.execute_script("return Format.formatString(\"#{ cc_services['resources'][0]['metadata']['created_at'] }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_services['resources'][0]['metadata']['updated_at'] }\")"),
                             cc_service_plans['resources'][0]['entity']['name'],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_plans['resources'][0]['metadata']['created_at'] }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_plans['resources'][0]['metadata']['updated_at'] }\")"),
                             cc_service_plans['resources'][0]['entity']['public'].to_s,
                             @driver.execute_script("return Format.formatTarget(\"#{ cc_services['resources'][0]['entity']['provider'] }/#{ cc_services['resources'][0]['entity']['label'] }/#{ cc_service_plans['resources'][0]['entity']['name'] }\")").gsub(/<\/?[^>]+>/, ''),
                             cc_service_instances['resources'][0]['entity']['name'],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_instances['resources'][0]['metadata']['created_at'] }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_instances['resources'][0]['metadata']['updated_at'] }\")"),
                             cc_service_bindings['total_results'].to_s,
                             "#{ cc_organizations['resources'][0]['entity']['name'] }/#{ cc_spaces['resources'][0]['entity']['name'] }"
                           ])
        end
        context 'selectable' do
          before do
            select_first_row
          end
          it 'has details' do
            check_details([{ :label => 'Service Instance Name',          :tag => 'div', :value => cc_service_instances['resources'][0]['entity']['name'] },
                           { :label => 'Service Instance Created',       :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service_instances['resources'][0]['metadata']['created_at'] }\")") },
                           { :label => 'Service Instance Updated',       :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service_instances['resources'][0]['metadata']['updated_at'] }\")") },
                           { :label => 'Service Instance Dashboard URL', :tag =>   nil, :value => cc_service_instances['resources'][0]['entity']['dashboard_url'] },
                           { :label => 'Service Broker Name',            :tag =>   nil, :value => cc_service_brokers['resources'][0]['entity']['name'] },
                           { :label => 'Service Broker Created',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service_brokers['resources'][0]['metadata']['created_at'] }\")") },
                           { :label => 'Service Broker Updated',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service_brokers['resources'][0]['metadata']['updated_at'] }\")") },
                           { :label => 'Service Provider',               :tag =>   nil, :value => cc_services['resources'][0]['entity']['provider'] },
                           { :label => 'Service Label',                  :tag =>   nil, :value => cc_services['resources'][0]['entity']['label'] },
                           { :label => 'Service Version',                :tag =>   nil, :value => cc_services['resources'][0]['entity']['version'] },
                           { :label => 'Service Created',                :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_services['resources'][0]['metadata']['created_at'] }\")") },
                           { :label => 'Service Updated',                :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_services['resources'][0]['metadata']['updated_at'] }\")") },
                           { :label => 'Service Description',            :tag =>   nil, :value => cc_services['resources'][0]['entity']['description'] },
                           { :label => 'Service Bindable',               :tag =>   nil, :value => cc_services['resources'][0]['entity']['bindable'].to_s },
                           { :label => 'Service Extra',                  :tag =>   nil, :value => cc_services['resources'][0]['entity']['extra'] },
                           { :label => 'Service Tag',                    :tag =>   nil, :value => cc_services['resources'][0]['entity']['tags'][0] },
                           { :label => 'Service Tag',                    :tag =>   nil, :value => cc_services['resources'][0]['entity']['tags'][1] },
                           { :label => 'Service Documentation URL',      :tag =>   nil, :value => cc_services['resources'][0]['entity']['documentation_url'] },
                           { :label => 'Service Info URL',               :tag =>   nil, :value => cc_services['resources'][0]['entity']['info_url'] },
                           { :label => 'Service Plan Name',              :tag =>   'a', :value => cc_service_plans['resources'][0]['entity']['name'] },
                           { :label => 'Service Plan Created',           :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service_plans['resources'][0]['metadata']['created_at'] }\")") },
                           { :label => 'Service Plan Updated',           :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service_plans['resources'][0]['metadata']['updated_at'] }\")") },
                           { :label => 'Service Plan Public',            :tag =>   nil, :value => cc_service_plans['resources'][0]['entity']['public'].to_s },
                           { :label => 'Service Plan Description',       :tag =>   nil, :value => cc_service_plans['resources'][0]['entity']['description'] },
                           { :label => 'Service Plan Extra',             :tag =>   nil, :value => cc_service_plans['resources'][0]['entity']['extra'] },
                           { :label => 'Space',                          :tag =>   'a', :value => cc_spaces['resources'][0]['entity']['name'] },
                           { :label => 'Organization',                   :tag =>   'a', :value => cc_organizations['resources'][0]['entity']['name'] }
                          ])
          end
          it 'has bound applications' do
            expect(@driver.find_element(:id => 'ServiceInstancesApplicationsDetailsLabel').displayed?).to be_true
            check_table_headers(:columns         => @driver.find_elements(:xpath => "//div[@id='ServiceInstancesApplicationsTableContainer']/div[2]/div[5]/div[1]/div/table/thead/tr/th"),
                                :expected_length => 2,
                                :labels          => %w(Application Bound),
                                :colspans        => nil)
            check_table_data(@driver.find_elements(:xpath => "//table[@id='ServiceInstancesApplicationsTable']/tbody/tr/td"),
                             [
                               cc_started_apps['resources'][0]['entity']['name'],
                               @driver.execute_script("return Format.formatDateString(\"#{ cc_service_bindings['resources'][0]['metadata']['created_at'] }\")")
                             ])
          end
          it 'has service plan name link' do
            check_filter_link('ServiceInstances', 19, 'ServicePlans', "#{ cc_services['resources'][0]['entity']['provider'] }/#{ cc_services['resources'][0]['entity']['label'] }/#{ cc_service_plans['resources'][0]['entity']['name'] }")
          end
          it 'has space link' do
            check_filter_link('ServiceInstances', 25, 'Spaces', "#{ cc_organizations['resources'][0]['entity']['name'] }/#{ cc_spaces['resources'][0]['entity']['name'] }")
          end
          it 'has organization link' do
            check_filter_link('ServiceInstances', 26, 'Organizations', cc_organizations['resources'][0]['entity']['name'])
          end
        end
      end

      context 'Developers' do
        let(:tab_id) { 'Developers' }
        it 'has a table' do
          check_table_layout([{ :columns         => @driver.find_elements(:xpath => "//div[@id='DevelopersTableContainer']/div/div[6]/div[1]/div/table/thead/tr/th"),
                                :expected_length => 6,
                                :labels          => %w(Email Space Organization Target Created Updated),
                                :colspans        => nil
                               }
                             ])
          check_table_data(@driver.find_elements(:xpath => "//table[@id='DevelopersTable']/tbody/tr/td"),
                           [
                             "#{ uaa_users['resources'][0]['emails'][0]['value'] }",
                             cc_spaces['resources'][0]['entity']['name'],
                             cc_organizations['resources'][0]['entity']['name'],
                             "#{ cc_organizations['resources'][0]['entity']['name'] }/#{ cc_spaces['resources'][0]['entity']['name'] }",
                             @driver.execute_script("return Format.formatString(\"#{ DateTime.parse(uaa_users['resources'][0]['meta']['created']).rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ DateTime.parse(uaa_users['resources'][0]['meta']['lastModified']).rfc3339 }\")")
                           ])
        end
        context 'selectable' do
          before do
            select_first_row
          end
          it 'has details' do
            groups = []
            uaa_users['resources'][0]['groups'].each do |group|
              groups.push(group['display'])
            end
            groups.sort!
            index = 0
            groups_string = ''
            while index < groups.length
              groups_string += ', ' unless index == 0
              groups_string += groups[index]
              index += 1
            end
            check_details([{ :label => 'Email',        :tag => 'div', :value => "mailto:#{ uaa_users['resources'][0]['emails'][0]['value'] }" },
                           { :label => 'Created',      :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ uaa_users['resources'][0]['meta']['created'] }\")") },
                           { :label => 'Updated',      :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ uaa_users['resources'][0]['meta']['lastModified'] }\")") },
                           { :label => 'Authorities',  :tag =>   nil, :value => groups_string },
                           { :label => 'Space',        :tag =>   'a', :value => cc_spaces['resources'][0]['entity']['name'] },
                           { :label => 'Organization', :tag =>   'a', :value => cc_organizations['resources'][0]['entity']['name'] }
                          ])
          end
          it 'has space link' do
            check_filter_link('Developers', 4, 'Spaces', "#{ cc_organizations['resources'][0]['entity']['name'] }/#{ cc_spaces['resources'][0]['entity']['name'] }")
          end
          it 'has organization link' do
            check_filter_link('Developers', 5, 'Organizations', cc_organizations['resources'][0]['entity']['name'])
          end
        end
      end

      context 'Quotas' do
        let(:tab_id) { 'Quotas' }
        it 'has a table' do
          check_table_layout([{ :columns         => @driver.find_elements(:xpath => "//div[@id='QuotasTableContainer']/div/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                :expected_length => 9,
                                :labels          => ['Name', 'Created', 'Updated', 'Total Services', 'Total Routes', 'Memory Limit', 'Non-Basic Services Allowed', 'Trial-DB Allowed', 'Organizations'],
                                :colspans        => nil
                              }
                             ])
          check_table_data(@driver.find_elements(:xpath => "//table[@id='QuotasTable']/tbody/tr/td"),
                           [
                             cc_quota_definitions['resources'][0]['entity']['name'],
                             @driver.execute_script("return Format.formatString(\"#{ cc_quota_definitions['resources'][0]['metadata']['created_at'] }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_quota_definitions['resources'][0]['metadata']['updated_at'] }\")"),
                             @driver.execute_script("return Format.formatNumber(\"#{ cc_quota_definitions['resources'][0]['entity']['total_services'] }\")"),
                             @driver.execute_script("return Format.formatNumber(\"#{ cc_quota_definitions['resources'][0]['entity']['total_routes'] }\")"),
                             @driver.execute_script("return Format.formatNumber(\"#{ cc_quota_definitions['resources'][0]['entity']['memory_limit'] }\")"),
                             cc_quota_definitions['resources'][0]['entity']['non_basic_services_allowed'].to_s,
                             cc_quota_definitions['resources'][0]['entity']['trial_db_allowed'].to_s,
                             '1',

                             cc_quota_definitions['resources'][1]['entity']['name'],
                             @driver.execute_script("return Format.formatString(\"#{ cc_quota_definitions['resources'][1]['metadata']['created_at'] }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_quota_definitions['resources'][1]['metadata']['updated_at'] }\")"),
                             @driver.execute_script("return Format.formatNumber(\"#{ cc_quota_definitions['resources'][1]['entity']['total_services'] }\")"),
                             @driver.execute_script("return Format.formatNumber(\"#{ cc_quota_definitions['resources'][1]['entity']['total_routes'] }\")"),
                             @driver.execute_script("return Format.formatNumber(\"#{ cc_quota_definitions['resources'][1]['entity']['memory_limit'] }\")"),
                             cc_quota_definitions['resources'][1]['entity']['non_basic_services_allowed'].to_s,
                             cc_quota_definitions['resources'][1]['entity']['trial_db_allowed'].to_s,
                             '0'
                           ])
        end

        context 'selectable' do
          before do
            select_first_row
          end
          it 'has details' do
            check_details([{ :label => 'Name',                       :tag => 'div', :value => cc_quota_definitions['resources'][0]['entity']['name'] },
                           { :label => 'Created',                    :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_quota_definitions['resources'][0]['metadata']['created_at'] }\")") },
                           { :label => 'Updated',                    :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_quota_definitions['resources'][0]['metadata']['updated_at'] }\")") },
                           { :label => 'Total Services',             :tag =>   nil, :value => @driver.execute_script("return Format.formatNumber(\"#{ cc_quota_definitions['resources'][0]['entity']['total_services'] }\")") },
                           { :label => 'Total Routes',               :tag =>   nil, :value => @driver.execute_script("return Format.formatNumber(\"#{ cc_quota_definitions['resources'][0]['entity']['total_routes'] }\")") },
                           { :label => 'Memory Limit',               :tag =>   nil, :value => @driver.execute_script("return Format.formatNumber(\"#{ cc_quota_definitions['resources'][0]['entity']['memory_limit'] }\")") },
                           { :label => 'Non-Basic Services Allowed', :tag =>   nil, :value => cc_quota_definitions['resources'][0]['entity']['non_basic_services_allowed'].to_s },
                           { :label => 'Trial-DB Allowed',           :tag =>   nil, :value => cc_quota_definitions['resources'][0]['entity']['trial_db_allowed'].to_s },
                           { :label => 'Organizations',              :tag =>   'a', :value => '1' }
                          ])
          end
          it 'has organizations link' do
            check_filter_link('Quotas', 8, 'Organizations', "#{ cc_quota_definitions['resources'][0]['entity']['name'] }")
          end
        end
      end

      context 'Service Plans' do
        let(:tab_id) { 'ServicePlans' }
        it 'has a table' do
          check_table_layout([{ :columns         => @driver.find_elements(:xpath => "//div[@id='ServicePlansTable_wrapper']/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                :expected_length => 3,
                                :labels          => ['Service Plan', 'Service', 'Service Broker'],
                                :colspans        => %w(7 7 3)
                              },
                              {
                                :columns         => @driver.find_elements(:xpath => "//div[@id='ServicePlansTable_wrapper']/div[6]/div[1]/div/table/thead/tr[2]/th"),
                                :expected_length => 17,
                                :labels          => [' ', 'Name', 'Target', 'Created', 'Updated', 'Public', 'Service Instances', 'Provider', 'Label', 'Version', 'Created', 'Updated', 'Active', 'Bindable', 'Name', 'Created', 'Updated'],
                                :colspans        => nil
                              }
                             ])
          check_table_data(@driver.find_elements(:xpath => "//table[@id='ServicePlansTable']/tbody/tr/td"),
                           [
                             '',
                             cc_service_plans['resources'][0]['entity']['name'],
                             @driver.execute_script("return Format.formatTarget(\"#{ cc_services['resources'][0]['entity']['provider'] }/#{ cc_services['resources'][0]['entity']['label'] }/#{ cc_service_plans['resources'][0]['entity']['name'] }\")").gsub(/<\/?[^>]+>/, ''),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_plans['resources'][0]['metadata']['created_at'] }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_plans['resources'][0]['metadata']['updated_at'] }\")"),
                             cc_service_plans['resources'][0]['entity']['public'].to_s,
                             cc_service_instances['resources'].length.to_s,
                             cc_services['resources'][0]['entity']['provider'],
                             cc_services['resources'][0]['entity']['label'],
                             cc_services['resources'][0]['entity']['version'],
                             @driver.execute_script("return Format.formatString(\"#{ cc_services['resources'][0]['metadata']['created_at'] }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_services['resources'][0]['metadata']['updated_at'] }\")"),
                             cc_services['resources'][0]['entity']['active'].to_s,
                             cc_services['resources'][0]['entity']['bindable'].to_s,
                             cc_service_brokers['resources'][0]['entity']['name'],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_brokers['resources'][0]['metadata']['created_at'] }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_brokers['resources'][0]['metadata']['updated_at'] }\")")
                           ])
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            value_extra_json = JSON.parse(cc_services['resources'][0]['entity']['extra'])
            check_details([{ :label => 'Service Plan Name',              :tag => 'div', :value => cc_service_plans['resources'][0]['entity']['name'] },
                           { :label => 'Service Plan Created',           :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service_plans['resources'][0]['metadata']['created_at'] }\")") },
                           { :label => 'Service Plan Updated',           :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service_plans['resources'][0]['metadata']['updated_at'] }\")") },
                           { :label => 'Service Plan Public',            :tag =>   nil, :value => cc_service_plans['resources'][0]['entity']['public'].to_s },
                           { :label => 'Service Plan Description',       :tag =>   nil, :value => cc_service_plans['resources'][0]['entity']['description'] },
                           { :label => 'Service Instances',              :tag =>   'a', :value => cc_service_instances['resources'].length.to_s },
                           { :label => 'Service Broker Name',            :tag =>   nil, :value => cc_service_brokers['resources'][0]['entity']['name'] },
                           { :label => 'Service Broker Created',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service_brokers['resources'][0]['metadata']['created_at'] }\")") },
                           { :label => 'Service Broker Updated',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service_brokers['resources'][0]['metadata']['updated_at'] }\")") },
                           { :label => 'Service Provider',               :tag =>   nil, :value => cc_services['resources'][0]['entity']['provider'] },
                           { :label => 'Service Label',                  :tag =>   nil, :value => cc_services['resources'][0]['entity']['label'] },
                           { :label => 'Service Version',                :tag =>   nil, :value => cc_services['resources'][0]['entity']['version'] },
                           { :label => 'Service Created',                :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_services['resources'][0]['metadata']['created_at'] }\")") },
                           { :label => 'Service Updated',                :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_services['resources'][0]['metadata']['updated_at'] }\")") },
                           { :label => 'Service Active',                 :tag =>   nil, :value => cc_services['resources'][0]['entity']['active'].to_s },
                           { :label => 'Service Bindable',               :tag =>   nil, :value => cc_services['resources'][0]['entity']['bindable'].to_s },
                           { :label => 'Service Description',            :tag =>   nil, :value => cc_services['resources'][0]['entity']['description'] },
                           { :label => 'Service Display Name',           :tag =>   nil, :value => value_extra_json['displayName'] },
                           { :label => 'Service Provider Display Name',  :tag =>   nil, :value => value_extra_json['providerDisplayName'] },
                           { :label => 'Service Icon',                   :tag => 'img', :value => @driver.execute_script("return Format.formatIconImage(\"#{value_extra_json['imageUrl']}\", \"service icon\", \"flot:left;\")").gsub(/'/, "\"").gsub(/[ ]+/, ' ').gsub(/ >/, '>') },
                           { :label => 'Service Long Description',       :tag =>   nil, :value => value_extra_json['longDescription'] }
                          ])
          end

          it 'has a checkbox in the first column' do
            inputs = @driver.find_elements(:xpath => "//table[@id='ServicePlansTable']/tbody/tr/td[1]/input")
            expect(inputs.length).to eq(1)
            expect(inputs[0].attribute('value')).to eq("#{ cc_service_plans['resources'][0]['metadata']['guid'] }")
          end

          it 'has service instances link to service instances filtered by service plan target' do
            check_filter_link('ServicePlans', 5, 'ServiceInstances', "#{ cc_services['resources'][0]['entity']['provider'] }/#{ cc_services['resources'][0]['entity']['label'] }/#{ cc_service_plans['resources'][0]['entity']['name'] }")
          end

          context 'manage service plans' do
            def check_first_row
              @driver.find_elements(:xpath => "//table[@id='ServicePlansTable']/tbody/tr/td[1]/input")[0].click
            end

            def manage_service_plan(buttonIndex)
              check_first_row
              @driver.find_element(:id => "ToolTables_ServicePlansTable_#{buttonIndex}").click
              if buttonIndex == 0
                check_operation_result('public')
              else
                check_operation_result('private')
              end
            end

            def check_service_plan_state(expect_state)
              # As the UI table will be refreshed and recreated, add a try-catch block in case the selenium stale element
              # error happens.
              begin
                Selenium::WebDriver::Wait.new(:timeout => 20).until { @driver.find_element(:xpath => "//table[@id='ServicePlansTable']/tbody/tr/td[6]").text == expect_state }
              rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
              end
              expect(@driver.find_element(:xpath => "//table[@id='ServicePlansTable']/tbody/tr/td[6]").text).to eq(expect_state)
            end

            def check_operation_result(_visibility)
              alert = nil
              Selenium::WebDriver::Wait.new(:timeout => 100).until { alert = @driver.switch_to.alert }
              expect(alert.text.sub(/\n/, '')).to eq('The operation finished without error.Please refresh the page later for the updated result.')
              alert.dismiss
            end

            it 'has a Public button' do
              expect(@driver.find_element(:id => 'ToolTables_ServicePlansTable_0').text).to eq('Public')
            end

            it 'has a Private button' do
              expect(@driver.find_element(:id => 'ToolTables_ServicePlansTable_1').text).to eq('Private')
            end

            shared_examples 'click public or private button without selecting a single row' do
              it 'alerts the user to select at least one row when clicking the button' do
                @driver.find_element(:id => buttonId).click
                alert = @driver.switch_to.alert
                expect(alert.text).to eq('Please select at least one row!')
                alert.dismiss
              end
            end

            it_behaves_like('click public or private button without selecting a single row') do
              let(:buttonId) { 'ToolTables_ServicePlansTable_0' }
            end

            it_behaves_like('click public or private button without selecting a single row') do
              let(:buttonId) { 'ToolTables_ServicePlansTable_1' }
            end

            it 'make selected public service plans private and back to public' do
              check_service_plan_state('true')
              cc_service_plans_private_stub(AdminUI::Config.load(config))
              check_service_plan_state('true')
              manage_service_plan(1)
              check_service_plan_state('false')
            end
          end
        end
      end

      context 'DEAs' do
        let(:tab_id) { 'DEAs' }
        it 'has a table' do
          check_table_layout([{ :columns         => @driver.find_elements(:xpath => "//div[@id='DEAsTableContainer']/div/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                :expected_length => 2,
                                :labels          => ['', '% Free'],
                                :colspans        => %w(8 2)
                              },
                              { :columns         => @driver.find_elements(:xpath => "//div[@id='DEAsTableContainer']/div/div[6]/div[1]/div/table/thead/tr[2]/th"),
                                :expected_length => 10,
                                :labels          => %w(Name Index Status Started Stack CPU Memory Apps Memory Disk),
                                :colspans        => nil
                              }
                             ])
          check_table_data(@driver.find_elements(:xpath => "//table[@id='DEAsTable']/tbody/tr/td"),
                           [
                             varz_dea['host'],
                             varz_dea['index'].to_s,
                             @driver.execute_script('return Constants.STATUS__RUNNING'),
                             @driver.execute_script("return Format.formatString(\"#{ varz_dea['start'] }\")"),
                             varz_dea['stacks'][0],
                             varz_dea['cpu'].to_s,
                             varz_dea['mem'].to_s,
                             varz_dea['instance_registry'].length.to_s,
                             @driver.execute_script("return Format.formatNumber(#{ varz_dea['available_memory_ratio'].to_f * 100 })"),
                             @driver.execute_script("return Format.formatNumber(#{ varz_dea['available_disk_ratio'].to_f * 100 })")
                           ])
        end
        it 'has a create DEA button' do
          expect(@driver.find_element(:id => 'ToolTables_DEAsTable_0').text).to eq('Create new DEA')
        end
        context 'selectable' do
          before do
            select_first_row
          end
          it 'has details' do
            check_details([{ :label => 'Name',         :tag => nil, :value => varz_dea['host'] },
                           { :label => 'Index',        :tag => nil, :value => varz_dea['index'].to_s },
                           { :label => 'URI',          :tag => 'a', :value => nats_dea_varz },
                           { :label => 'Host',         :tag => nil, :value => varz_dea['host'] },
                           { :label => 'Started',      :tag => nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ varz_dea['start'] }\")") },
                           { :label => 'Uptime',       :tag => nil, :value => @driver.execute_script("return Format.formatUptime(\"#{ varz_dea['uptime'] }\")") },
                           { :label => 'Stack',        :tag => nil, :value => varz_dea['stacks'][0] },
                           { :label => 'Apps',         :tag => 'a', :value => varz_dea['instance_registry'].length.to_s },
                           { :label => 'Cores',        :tag => nil, :value => varz_dea['num_cores'].to_s },
                           { :label => 'CPU',          :tag => nil, :value => varz_dea['cpu'].to_s },
                           { :label => 'CPU Load Avg', :tag => nil, :value => "#{ @driver.execute_script("return Format.formatNumber(#{ varz_dea['cpu_load_avg'].to_f * 100 })") }%" },
                           { :label => 'Memory',       :tag => nil, :value => varz_dea['mem'].to_s },
                           { :label => 'Memory Free',  :tag => nil, :value => "#{ @driver.execute_script("return Format.formatNumber(#{ varz_dea['available_memory_ratio'].to_f * 100 })") }%" },
                           { :label => 'Disk Free',    :tag => nil, :value => "#{ @driver.execute_script("return Format.formatNumber(#{ varz_dea['available_disk_ratio'].to_f * 100 })") }%" }
                          ])
          end
          it 'has applications link' do
            check_filter_link('DEAs', 7, 'Applications', varz_dea['host'])
          end
        end
      end

      context 'Cloud Controllers' do
        let(:tab_id) { 'CloudControllers' }
        it 'has a table' do
          check_table_layout([{ :columns         => @driver.find_elements(:xpath => "//div[@id='CloudControllersTableContainer']/div/div[6]/div[1]/div/table/thead/tr/th"),
                                :expected_length => 7,
                                :labels          => %w(Name Index State Started Cores CPU Memory),
                                :colspans        => nil
                              }
                             ])
          check_table_data(@driver.find_elements(:xpath => "//table[@id='CloudControllersTable']/tbody/tr/td"),
                           [
                             nats_cloud_controller['host'],
                             varz_cloud_controller['index'].to_s,
                             @driver.execute_script('return Constants.STATUS__RUNNING'),
                             @driver.execute_script("return Format.formatString(\"#{ varz_cloud_controller['start'] }\")"),
                             varz_cloud_controller['num_cores'].to_s,
                             varz_cloud_controller['cpu'].to_s,
                             varz_cloud_controller['mem'].to_s
                           ])
        end
        context 'selectable' do
          it 'has details' do
            select_first_row
            check_details([{ :label => 'Name',             :tag => nil, :value => nats_cloud_controller['host'] },
                           { :label => 'Index',            :tag => nil, :value => varz_cloud_controller['index'].to_s },
                           { :label => 'URI',              :tag => 'a', :value => nats_cloud_controller_varz },
                           { :label => 'Started',          :tag => nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ varz_cloud_controller['start'] }\")") },
                           { :label => 'Uptime',           :tag => nil, :value => @driver.execute_script("return Format.formatUptime(\"#{ varz_cloud_controller['uptime'] }\")") },
                           { :label => 'Cores',            :tag => nil, :value => varz_cloud_controller['num_cores'].to_s },
                           { :label => 'CPU',              :tag => nil, :value => varz_cloud_controller['cpu'].to_s },
                           { :label => 'Memory',           :tag => nil, :value => varz_cloud_controller['mem'].to_s },
                           { :label => 'Requests',         :tag => nil, :value => varz_cloud_controller['vcap_sinatra']['requests']['completed'].to_s },
                           { :label => 'Pending Requests', :tag => nil, :value => varz_cloud_controller['vcap_sinatra']['requests']['outstanding'].to_s }
                          ])
          end
        end
      end

      context 'Health Managers' do
        let(:tab_id) { 'HealthManagers' }
        it 'has a table' do
          check_table_layout([{ :columns         => @driver.find_elements(:xpath => "//div[@id='HealthManagersTableContainer']/div/div[6]/div[1]/div/table/thead/tr/th"),
                                :expected_length => 10,
                                :labels          => %w(Name Index State Started Cores CPU Memory Users Applications Instances),
                                :colspans        => nil
                               }
                             ])
          check_table_data(@driver.find_elements(:xpath => "//table[@id='HealthManagersTable']/tbody/tr/td"),
                           [
                             nats_health_manager['host'],
                             varz_health_manager['index'].to_s,
                             @driver.execute_script('return Constants.STATUS__RUNNING'),
                             @driver.execute_script("return Format.formatString(\"#{ varz_health_manager['start'] }\")"),
                             varz_health_manager['num_cores'].to_s,
                             varz_health_manager['cpu'].to_s,
                             varz_health_manager['mem'].to_s,
                             varz_health_manager['total_users'].to_s,
                             varz_health_manager['total_apps'].to_s,
                             varz_health_manager['total_instances'].to_s
                           ])
        end
        context 'selectable' do
          it 'has details' do
            select_first_row
            check_details([{ :label => 'Name',              :tag => nil, :value => nats_health_manager['host'] },
                           { :label => 'Index',             :tag => nil, :value => varz_health_manager['index'].to_s },
                           { :label => 'URI',               :tag => 'a', :value => nats_health_manager_varz },
                           { :label => 'Started',           :tag => nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ varz_health_manager['start'] }\")") },
                           { :label => 'Uptime',            :tag => nil, :value => @driver.execute_script("return Format.formatUptime(\"#{ varz_health_manager['uptime'] }\")") },
                           { :label => 'Cores',             :tag => nil, :value => varz_health_manager['num_cores'].to_s },
                           { :label => 'CPU',               :tag => nil, :value => varz_health_manager['cpu'].to_s },
                           { :label => 'Memory',            :tag => nil, :value => varz_health_manager['mem'].to_s },
                           { :label => 'Users',             :tag => nil, :value => varz_health_manager['total_users'].to_s },
                           { :label => 'Applications',      :tag => nil, :value => varz_health_manager['total_apps'].to_s },
                           { :label => 'Instances',         :tag => nil, :value => varz_health_manager['total_instances'].to_s },
                           { :label => 'Running Instances', :tag => nil, :value => varz_health_manager['running_instances'].to_s },
                           { :label => 'Crashed Instances', :tag => nil, :value => varz_health_manager['crashed_instances'].to_s }
                          ])
          end
        end
      end

      context 'Service Gateways' do
        let(:tab_id) { 'Gateways' }
        before do
          @capacity = 0
          varz_provisioner['nodes'].each do |node|
            unless node[1]['available_capacity'].nil?
              @capacity += node[1]['available_capacity']
            end
          end
        end
        it 'has a table' do
          check_table_layout([{ :columns         => @driver.find_elements(:xpath => "//div[@id='GatewaysTableContainer']/div/div[6]/div[1]/div/table/thead/tr/th"),
                                :expected_length => 9,
                                :labels          => ['Name', 'Index', 'State', 'Started', 'Description', 'CPU', 'Memory', 'Nodes', "Available\nCapacity"],
                                :colspans        => nil
                               }
                             ])
          check_table_data(@driver.find_elements(:xpath => "//table[@id='GatewaysTable']/tbody/tr/td"),
                           [
                             nats_provisioner['type'][0..-13],
                             varz_provisioner['index'].to_s,
                             @driver.execute_script('return Constants.STATUS__RUNNING'),
                             @driver.execute_script("return Format.formatString(\"#{ varz_provisioner['start'] }\")"),
                             varz_provisioner['config']['service']['description'],
                             varz_provisioner['cpu'].to_s,
                             varz_provisioner['mem'].to_s,
                             varz_provisioner['nodes'].length.to_s,
                             @capacity.to_s
                           ])
        end
        context 'selectable' do
          before do
            select_first_row
          end
          it 'has details' do
            check_details([{ :label => 'Name',                 :tag => nil, :value => nats_provisioner['type'][0..-13] },
                           { :label => 'Index',                :tag => nil, :value => varz_provisioner['index'].to_s },
                           { :label => 'URI',                  :tag => nil, :value => nats_provisioner_varz },
                           { :label => 'Supported Versions',   :tag => nil, :value => varz_provisioner['config']['service']['supported_versions'][0] },
                           { :label => 'Description',          :tag => nil, :value => varz_provisioner['config']['service']['description'] },
                           { :label => 'Started',              :tag => nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ varz_provisioner['start'] }\")") },
                           { :label => 'Uptime',               :tag => nil, :value => @driver.execute_script("return Format.formatUptime(\"#{ varz_provisioner['uptime'] }\")") },
                           { :label => 'Cores',                :tag => nil, :value => varz_provisioner['num_cores'].to_s },
                           { :label => 'CPU',                  :tag => nil, :value => varz_provisioner['cpu'].to_s },
                           { :label => 'Memory',               :tag => nil, :value => varz_provisioner['mem'].to_s },
                           { :label => 'Available Capacity',   :tag => nil, :value => "#{ @capacity}" }
                          ])
          end
          it 'has nodes' do
            expect(@driver.find_element(:id => 'GatewaysNodesDetailsLabel').displayed?).to be_true
            check_table_headers(:columns         => @driver.find_elements(:xpath => "//div[@id='GatewaysNodesTableContainer']/div[2]/div[5]/div[1]/div/table/thead/tr/th"),
                                :expected_length => 2,
                                :labels          => ['Name', 'Available Capacity'],
                                :colspans        => nil)
            check_table_data(@driver.find_elements(:xpath => "//table[@id='GatewaysNodesTable']/tbody/tr/td"),
                             [
                               varz_provisioner['nodes'].keys[0],
                               varz_provisioner['nodes'][varz_provisioner['nodes'].keys[0]]['available_capacity'].to_s
                             ])
          end
        end
      end

      context 'Routers' do
        let(:tab_id) { 'Routers' }
        it 'has a table' do
          check_table_layout([{  :columns         => @driver.find_elements(:xpath => "//div[@id='RoutersTableContainer']/div/div[6]/div[1]/div/table/thead/tr/th"),
                                 :expected_length => 10,
                                 :labels          => ['Name', 'Index', 'State', 'Started', 'Cores', 'CPU', 'Memory', 'Droplets', 'Requests', 'Bad Requests'],
                                 :colspans        => nil
                               }
                             ])
          check_table_data(@driver.find_elements(:xpath => "//table[@id='RoutersTable']/tbody/tr/td"),
                           [
                             nats_router['host'],
                             varz_router['index'].to_s,
                             @driver.execute_script('return Constants.STATUS__RUNNING'),
                             @driver.execute_script("return Format.formatString(\"#{ varz_router['start'] }\")"),
                             varz_router['num_cores'].to_s,
                             varz_router['cpu'].to_s,
                             varz_router['mem'].to_s,
                             varz_router['droplets'].to_s,
                             varz_router['requests'].to_s,
                             varz_router['bad_requests'].to_s
                           ])
        end
        context 'selectable' do
          it 'has details' do
            select_first_row
            check_details([{ :label => 'Name',          :tag => nil, :value => nats_router['host'] },
                           { :label => 'Index',         :tag => nil, :value => varz_router['index'].to_s },
                           { :label => 'URI',           :tag => 'a', :value => nats_router_varz },
                           { :label => 'Started',       :tag => nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ varz_router['start'] }\")") },
                           { :label => 'Uptime',        :tag => nil, :value => @driver.execute_script("return Format.formatUptime(\"#{ varz_router['uptime'] }\")") },
                           { :label => 'Cores',         :tag => nil, :value => varz_router['num_cores'].to_s },
                           { :label => 'CPU',           :tag => nil, :value => varz_router['cpu'].to_s },
                           { :label => 'Memory',        :tag => nil, :value => varz_router['mem'].to_s },
                           { :label => 'Droplets',      :tag => nil, :value => varz_router['droplets'].to_s },
                           { :label => 'Requests',      :tag => nil, :value => varz_router['requests'].to_s },
                           { :label => 'Bad Requests',  :tag => nil, :value => varz_router['bad_requests'].to_s },
                           { :label => '2XX Responses', :tag => nil, :value => varz_router['responses_2xx'].to_s },
                           { :label => '3XX Responses', :tag => nil, :value => varz_router['responses_3xx'].to_s },
                           { :label => '4XX Responses', :tag => nil, :value => varz_router['responses_4xx'].to_s },
                           { :label => '5XX Responses', :tag => nil, :value => varz_router['responses_5xx'].to_s },
                           { :label => 'XXX Responses', :tag => nil, :value => varz_router['responses_xxx'].to_s }
                          ])
          end
        end
      end

      context 'Components' do
        let(:tab_id) { 'Components' }
        it 'has a table' do
          check_table_layout([{  :columns         => @driver.find_elements(:xpath => "//div[@id='ComponentsTableContainer']/div/div[6]/div[1]/div/table/thead/tr/th"),
                                 :expected_length => 5,
                                 :labels          => %w(Name Type Index State Started),
                                 :colspans        => nil
                               }
                             ])
          check_table_data(@driver.find_elements(:xpath => "//table[@id='ComponentsTable']/tbody/tr/td"),
                           [
                             nats_cloud_controller['host'],
                             nats_cloud_controller['type'],
                             varz_cloud_controller['index'].to_s,
                             @driver.execute_script('return Constants.STATUS__RUNNING'),
                             @driver.execute_script("return Format.formatString(\"#{ varz_cloud_controller['start'] }\")")
                           ])
        end
        it 'has a remove OFFLINE components button' do
          expect(@driver.find_element(:id => 'ToolTables_ComponentsTable_0').text).to eq('Remove OFFLINE')
        end
        context 'selectable' do
          it 'has details' do
            select_first_row
            check_details([{  :label => 'Name',    :tag => nil, :value => nats_cloud_controller['host'] },
                           {  :label => 'Type',    :tag => nil, :value => nats_cloud_controller['type'] },
                           {  :label => 'Index',   :tag => nil, :value => varz_cloud_controller['index'].to_s },
                           {  :label => 'Started', :tag => nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ varz_cloud_controller['start'] }\")") },
                           {  :label => 'URI',     :tag => 'a', :value => nats_cloud_controller_varz },
                           {  :label => 'State',   :tag => nil, :value => @driver.execute_script('return Constants.STATUS__RUNNING') }
                          ])
          end
        end
      end

      context 'Logs' do
        let(:tab_id) { 'Logs' }
        it 'has a table' do
          check_table_layout([{  :columns         => @driver.find_elements(:xpath => "//div[@id='LogsTableContainer']/div/div[6]/div[1]/div/table/thead/tr/th"),
                                 :expected_length => 3,
                                 :labels          => ['Path', 'Size', 'Last Modified'],
                                 :colspans        => nil
                               }
                             ])
        end
        it 'has contents' do
          row = first_row
          row.click
          columns = row.find_elements(:tag_name => 'td')
          expect(columns.length).to eq(3)
          expect(columns[0].text).to eq(log_file_displayed)
          expect(columns[1].text).to eq(log_file_displayed_contents_length.to_s)
          # TODO: Cannot check date due to web_helper stub for AdminUI::Utils.time_in_milliseconds
          # expect(columns[2].text).to eq(@driver.execute_script("return Format.formatString(\"#{ DateTime.parse(log_file_displayed_modified.utc.to_s).rfc3339 }\")"))
          expect(@driver.find_element(:id => 'LogContainer').displayed?).to be_true
          expect(@driver.find_element(:id => 'LogLink').text).to eq(columns[0].text)
          expect(@driver.find_element(:id => 'LogContents').text).to eq(log_file_displayed_contents)
        end
      end

      context 'Tasks' do
        let(:tab_id) { 'Tasks' }
        let(:table_has_data) { false }
        it 'has a table' do
          check_table_layout([{  :columns         => @driver.find_elements(:xpath => "//div[@id='TasksTableContainer']/div/div[6]/div[1]/div/table/thead/tr/th"),
                                 :expected_length => 3,
                                 :labels          => %w(Command State Started),
                                 :colspans        => nil
                               }
                             ])
        end
        it 'can show task output' do
          expect(@driver.find_element(:xpath => "//table[@id='TasksTable']/tbody/tr").text).to eq('No data available in table')
          @driver.find_element(:id => 'DEAs').click
          @driver.find_element(:id => 'ToolTables_DEAsTable_0').click
          @driver.find_element(:id => 'DialogOkayButton').click
          @driver.find_element(:id => 'Tasks').click

          # As the page refreshes, we need to catch the stale element error and re-find the element on the page
          begin
            Selenium::WebDriver::Wait.new(:timeout => 5).until { @driver.find_elements(:xpath => "//table[@id='TasksTable']/tbody/tr").length == 1 }
          rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
          end
          expect(@driver.find_elements(:xpath => "//table[@id='TasksTable']/tbody/tr").length).to eq(1)

          begin
            Selenium::WebDriver::Wait.new(:timeout => 5).until do
              cells = @driver.find_elements(:xpath => "//table[@id='TasksTable']/tbody/tr/td")
              cells[0].text == File.join(File.dirname(__FILE__)[0..-22], 'lib/admin/scripts', 'newDEA.sh') &&
              cells[1].text == @driver.execute_script('return Constants.STATUS__RUNNING')
            end
          rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
          end
          cells = @driver.find_elements(:xpath => "//table[@id='TasksTable']/tbody/tr/td")
          expect(cells[0].text).to eq(File.join(File.dirname(__FILE__)[0..-22], 'lib/admin/scripts', 'newDEA.sh'))
          expect(cells[1].text).to eq(@driver.execute_script('return Constants.STATUS__RUNNING'))

          @driver.find_elements(:xpath => "//table[@id='TasksTable']/tbody/tr")[0].click
          expect(@driver.find_element(:id => 'TaskContents').text.length > 0).to be_true
        end
      end

      context 'Stats' do
        let(:tab_id) { 'Stats' }
        context 'statistics' do
          before do
            @driver.find_element(:id => 'RefreshButton').click
          end
          it 'has a table' do
            check_stats_table('Stats')
          end
          it 'has a chart' do
            check_stats_chart('Stats')
          end
        end

        def check_default_stats_table
          check_table_data(@driver.find_elements(:xpath => "//table[@id='StatsTable']/tbody/tr/td"),
                           [
                             nil,
                             '1',
                             '1',
                             '1',
                             '1',
                             '1',
                             '1',
                             '1'
                           ])
        end

        it 'can show current stats' do
          check_default_stats_table
          @driver.find_element(:id => 'ToolTables_StatsTable_0').click
          expect(@driver.find_element(:xpath => "//span[@id='DialogText']/span").text.length > 0).to be_true
          rows = @driver.find_elements(:xpath => "//span[@id='DialogText']/div/table/tbody/tr")
          rows.each do |row|
            expect(row.find_element(:class_name => 'cellRightAlign').text).to eq('1')
          end
          @driver.find_element(:id => 'DialogCancelButton').click
          check_default_stats_table
        end
        it 'can create stats' do
          check_default_stats_table
          @driver.find_element(:id => 'ToolTables_StatsTable_0').click
          @driver.find_element(:id => 'DialogOkayButton').click

          # As the page refreshes, we need to catch the stale element error and re-find the element on the page
          begin
            Selenium::WebDriver::Wait.new(:timeout => 10).until do
              check_table_data(@driver.find_elements(:xpath => "//table[@id='StatsTable']/tbody/tr/td"), [nil, '1', '1', '1', '1', '1', '1', '1'])
              check_table_data(@driver.find_elements(:xpath => "//table[@id='StatsTable']/tbody/tr[2]/td"), [nil, '1', '1', '1', '1', '1', '1', '1'])
            end
        rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
          end
          check_table_data(@driver.find_elements(:xpath => "//table[@id='StatsTable']/tbody/tr/td"), [nil, '1', '1', '1', '1', '1', '1', '1'])
          check_table_data(@driver.find_elements(:xpath => "//table[@id='StatsTable']/tbody/tr[2]/td"), [nil, '1', '1', '1', '1', '1', '1', '1'])
        end
      end
    end
  end
end
