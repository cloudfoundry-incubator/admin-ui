require 'date'
require 'rubygems'
require_relative '../../spec_helper'
require_relative '../../support/web_helper'

describe AdminUI::Admin, :type => :integration, :firefox_available => true do
  include_context :server_context
  include_context :web_context

  context 'unauthenticated' do
    before do
      login_stub_fail
    end
    it 'requires valid credentials' do
      login('Scope Error')
    end
  end

  context 'authenticated' do
    before do
      login('Administration')
    end

    let(:allowscriptaccess) { 'sameDomain' }

    def check_allowscriptaccess_attribute(copy_node_id, flash_node_id)
      expect(@driver.find_element(:id => copy_node_id).text).to eq('Copy')
      el = @driver.find_element(:id => flash_node_id)
      expect(el.attribute('allowscriptaccess')).to eq(allowscriptaccess)
    end

    def refresh_button
      @driver.find_element(:id => 'RefreshButton').click
      true
    end

    it 'has a title' do
      # Need to wait until the page has been rendered
      begin
        Selenium::WebDriver::Wait.new(:timeout => 60).until { @driver.find_element(:class => 'cloudControllerText').text == cloud_controller_uri }
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
      expect(@driver.find_element(:class => 'user').text).to eq('admin')
    end

    context 'formatStringCleansed' do
      it 'removes html tags for iframe' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<iframe src=javascript:alert(1208)></iframe>\")")).to eq('hello')
      end

      it 'removes html tags for iframe short form' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<iframe src=javascript:alert(1208)/>\")")).to eq('hello')
      end

      it 'removes html tags for img' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<img src=javascript:alert(1208)></img>\")")).to eq('hello')
      end

      it 'removes html tags for img short form' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<img src=javascript:alert(1208)>\")")).to eq('hello')
      end

      it 'removes html tags for img forward slash' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<img/src='' onerror=alert(9)>\")")).to eq('hello')
      end

      it 'removes html tags for img dangling quoted string' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<a'' href'' onclick=alert(9)>foo</a>\")")).to eq('hellofoo')
      end

      it 'removes html tags for CRLF instead of space' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<img%0d%0asrc=''%0d%0aonerror=alert(9)>\")")).to eq('hello')
      end

      it 'removes html tags for javaScript scheme' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<a href='java&#115;cript:alert(9)'>foo</a>\")")).to eq('hellofoo')
      end

      it 'removes html tags for unquoted' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<input type=text name=foo value=a%20onchange=alert(9)>\")")).to eq('hello')
      end

      it 'removes html tags for double-quoted' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<input type='text' name='foo' value='\'onclick=alert(9)//'>\")")).to eq('hello')
      end

      it 'removes html tags for HTML5 autofocus' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<input type='text' name='foo' value=''onclick=alert(9)//'>\")")).to eq('hello')
      end

      it 'removes html tags for src & href attributes' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<script src='data:,alert(9)'></script>\")")).to eq('hello')
      end

      it 'removes html tags for src & href attributes 2' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<script src='data:text/javascript,alert(9)'></script>\")")).to eq('hello')
      end

      it 'removes html tags for Base64 data' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<a href='data:text/html;base64,PHNjcmlwdD5hbGVydCg5KTwvc2NyaXB0Pg'>foo</a>\")")).to eq('hellofoo')
      end

      it 'removes html tags for alternate character sets' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<a href=data:text/html;charset=utf-16,%ff%fe%3c%00s%00c%00r%00i%00p%00t%00%3e%00a%00l%00e%00r%00t%00(%009%00)%00/%00s%00c%00r%00i%00p%00t%00'>foo</a>\")")).to eq('hellofoo')
      end

      it 'removes html tags for SVG 1' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<svg onload='javascript:alert(9)' xmlns='http://www.w3.org/2000/svg'></svg>\")")).to eq('hello')
      end

      it 'removes html tags for SVG 2' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<g onload='javascript:alert(9)'></g></svg>\")")).to eq('hello')
      end

      it 'removes html tags for SVG 3' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<a xmlns:xlink='http://www.w3.org/1999/xlink' xlink:href='javascript:alert(9)'>\")")).to eq('hello')
      end

      it 'removes html tags for SVG 4' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<rect width='1000' height='1000' fill='white'/></a></svg>\")")).to eq('hello')
      end

      it 'removes html tags for missing greater-than sign' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<script%0d%0aalert(9)</script>\")")).to eq('hello')
      end

      it 'removes html tags for uncommon syntax' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<a''id=a href=''onclick=alert(9)>foo</a>\")")).to eq('hellofoo')
      end

      it 'removes html tags for orphan entity' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<a href=''&amp;/onclick=alert(9)>foo</a>\")")).to eq('hellofoo')
      end

      it 'removes any html tags' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<xyz src=javascript:alert(1208)></xzy>\")")).to eq('hello')
      end

      it 'removes any html tags shorm form 1' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<xyz src=javascript:alert(1208) />\")")).to eq('hello')
      end

      it 'removes any html tags shorm form 2' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<xyz src=javascript:alert(1208) >\")")).to eq('hello')
      end
    end

    context 'tabs' do
      let(:table_has_data) { true }
      before do
        # Move click action into the wait blog to ensure relevant tab has been clicked and rendered
        # This part is modified to fit Travis CI system.
        begin
          Selenium::WebDriver::Wait.new(:timeout => 60).until do
            @driver.find_element(:id => tab_id).click
            @driver.find_element(:class_name => 'menuItemSelected').attribute('id') == tab_id
          end
        rescue Selenium::WebDriver::Error::TimeOutError
        end
        expect(@driver.find_element(:class_name => 'menuItemSelected').attribute('id')).to eq(tab_id)
        # Need to wait until the page has been rendered
        begin
          Selenium::WebDriver::Wait.new(:timeout => 60).until { @driver.find_element(:id => "#{ tab_id }Page").displayed? }
        rescue Selenium::WebDriver::Error::TimeOutError
        end
        expect(@driver.find_element(:id => "#{ tab_id }Page").displayed?).to eq(true)

        if table_has_data
          # Need to wait until the table on the page has data
          begin
            Selenium::WebDriver::Wait.new(:timeout => 360).until { @driver.find_element(:xpath => "//table[@id='#{ tab_id }Table']/tbody/tr").text != 'No data available in table' }
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
                             cc_organization[:name],
                             cc_organization[:status].upcase,
                             @driver.execute_script("return Format.formatString(\"#{ cc_organization[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_organization[:updated_at].to_datetime.rfc3339 }\")"),
                             '1',
                             '1',
                             cc_quota_definition[:name],
                             '1',
                             '1',
                             '0',
                             cc_app[:instances].to_s,
                             varz_dea['instance_registry']['application1']['application1_instance1']['services'].length.to_s,
                             @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_memory_in_bytes'] })").to_s,
                             @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_disk_in_bytes'] })").to_s,
                             @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry']['application1']['application1_instance1']['computed_pcpu'] * 100 })").to_s,
                             cc_app[:memory].to_s,
                             cc_app[:disk_quota].to_s,
                             '1',
                             cc_app[:state] == 'STARTED' ? '1' : '0',
                             cc_app[:state] == 'STOPPED' ? '1' : '0',
                             cc_app[:package_state] == 'PENDING' ? '1' : '0',
                             cc_app[:package_state] == 'STAGED'  ? '1' : '0',
                             cc_app[:package_state] == 'FAILED'  ? '1' : '0'
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_OrganizationsTable_5', 'ZeroClipboard_TableToolsMovie_1')
        end

        it 'has a checkbox in the first column' do
          inputs = @driver.find_elements(:xpath => "//table[@id='OrganizationsTable']/tbody/tr/td[1]/input")
          expect(inputs.length).to eq(1)
          expect(inputs[0].attribute('value')).to eq("#{ cc_organization[:guid] }")
        end

        context 'set quota' do
          let(:insert_second_quota_definition) { true }
          def check_first_row
            @driver.find_elements(:xpath => "//table[@id='OrganizationsTable']/tbody/tr/td[1]/input")[0].click
          end

          def check_operation_result
            alert = nil
            Selenium::WebDriver::Wait.new(:timeout => 60).until { alert = @driver.switch_to.alert }
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
              Selenium::WebDriver::Wait.new(:timeout => 460).until { refresh_button && @driver.find_element(:xpath => "//table[@id='OrganizationsTable']/tbody/tr/td[8]").text == 'test_quota_2' }
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
            @driver.find_element(:id => 'organizationName').send_keys cc_organization2[:name]
            @driver.find_element(:id => 'modalDialogButton0').click

            alert = nil
            Selenium::WebDriver::Wait.new(:timeout => 60).until { alert = @driver.switch_to.alert }
            expect(alert.text).to eq("The operation finished without error.\nPlease refresh the page later for the updated result.")
            alert.dismiss

            begin
              Selenium::WebDriver::Wait.new(:timeout => 60).until { @driver.find_element(:xpath => "//table[@id='OrganizationsTable']/tbody/tr[2]/td[2]").text == cc_organization2[:name] }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(:xpath => "//table[@id='OrganizationsTable']/tbody/tr[2]/td[2]").text).to eq(cc_organization2[:name])
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
            Selenium::WebDriver::Wait.new(:timeout => 360).until { alert = @driver.switch_to.alert }
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
            Selenium::WebDriver::Wait.new(:timeout => 560).until { refresh_button && @driver.find_element(:xpath => "//table[@id='OrganizationsTable']/tbody/tr/td[3]").text == status }
          rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            expect(Selenium::WebDriver::Wait.new(:timeout => 360).until { refresh_button && @driver.find_element(:xpath => "//table[@id='OrganizationsTable']/tbody/tr/td[3]").text }).to eq(status)
          end

          it 'activates the selected organization' do
            suspend_org
            check_organization_status('SUSPENDED')

            activate_org
            check_organization_status('ACTIVE')
          end

          it 'suspends the selected organization' do
            suspend_org
            check_organization_status('SUSPENDED')
          end

          it 'deletes the selected organization' do
            delete_org

            begin
              Selenium::WebDriver::Wait.new(:timeout => 60).until { refresh_button && @driver.find_element(:xpath => "//table[@id='OrganizationsTable']/tbody/tr").text == 'No data available in table' }
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
            check_details([{ :label => 'Name',            :tag => 'div', :value => cc_organization[:name] },
                           { :label => 'Status',          :tag =>   nil, :value => cc_organization[:status].upcase },
                           { :label => 'Created',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_organization[:created_at].to_datetime.rfc3339 }\")") },
                           { :label => 'Updated',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_organization[:updated_at].to_datetime.rfc3339 }\")") },
                           { :label => 'Billing Enabled', :tag =>   nil, :value => cc_organization[:billing_enabled].to_s },
                           { :label => 'Spaces',          :tag =>   'a', :value => '1' },
                           { :label => 'Developers',      :tag =>   'a', :value => '1' },
                           { :label => 'Quota',           :tag =>   nil, :value => cc_quota_definition[:name] },
                           { :label => 'Total Routes',    :tag =>   'a', :value => '1' },
                           { :label => 'Used Routes',     :tag =>   nil, :value => '1' },
                           { :label => 'Unused Routes',   :tag =>   nil, :value => '0' },
                           { :label => 'Instances Used',  :tag =>   'a', :value => cc_app[:instances].to_s },
                           { :label => 'Services Used',   :tag =>   'a', :value => varz_dea['instance_registry']['application1']['application1_instance1']['services'].length.to_s },
                           { :label => 'Memory Used',     :tag =>   nil, :value => @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_memory_in_bytes'] })").to_s },
                           { :label => 'Disk Used',       :tag =>   nil, :value => @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_disk_in_bytes'] })").to_s },
                           { :label => 'CPU Used',        :tag =>   nil, :value => @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry']['application1']['application1_instance1']['computed_pcpu'] * 100 })").to_s },
                           { :label => 'Memory Reserved', :tag =>   nil, :value => cc_app[:memory].to_s },
                           { :label => 'Disk Reserved',   :tag =>   nil, :value => cc_app[:disk_quota].to_s },
                           { :label => 'Total Apps',      :tag =>   'a', :value => '1' },
                           { :label => 'Started Apps',    :tag =>   nil, :value => cc_app[:state] == 'STARTED' ? '1' : '0' },
                           { :label => 'Stopped Apps',    :tag =>   nil, :value => cc_app[:state] == 'STOPPED' ? '1' : '0' },
                           { :label => 'Pending Apps',    :tag =>   nil, :value => cc_app[:package_state] == 'PENDING' ? '1' : '0' },
                           { :label => 'Staged Apps',     :tag =>   nil, :value => cc_app[:package_state] == 'STAGED'  ? '1' : '0' },
                           { :label => 'Failed Apps',     :tag =>   nil, :value => cc_app[:package_state] == 'FAILED'  ? '1' : '0' }
                          ])
          end
          it 'has spaces link' do
            check_filter_link('Organizations', 5, 'Spaces', "#{ cc_organization[:name] }/")
          end
          it 'has developers link' do
            check_filter_link('Organizations', 6, 'Developers', "#{ cc_organization[:name] }/")
          end
          it 'has quota link' do
            check_filter_link('Organizations', 7, 'Quotas', "#{ cc_quota_definition[:name] }")
          end
          it 'has routes link' do
            check_filter_link('Organizations', 8, 'Routes', "#{ cc_organization[:name] }/")
          end
          it 'has instances link' do
            check_filter_link('Organizations', 11, 'Applications', "#{ cc_organization[:name] }/")
          end
          it 'has services link' do
            check_filter_link('Organizations', 12, 'ServiceInstances', "#{ cc_organization[:name] }/")
          end
          it 'has applications link' do
            check_filter_link('Organizations', 18, 'Applications', "#{ cc_organization[:name] }/")
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
                             cc_space[:name],
                             "#{ cc_organization[:name] }/#{ cc_space[:name] }",
                             @driver.execute_script("return Format.formatString(\"#{ cc_space[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_space[:updated_at].to_datetime.rfc3339 }\")"),
                             '1',
                             '1',
                             '1',
                             '0',
                             cc_app[:instances].to_s,
                             varz_dea['instance_registry']['application1']['application1_instance1']['services'].length.to_s,
                             @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_memory_in_bytes'] })").to_s,
                             @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_disk_in_bytes'] })").to_s,
                             @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry']['application1']['application1_instance1']['computed_pcpu'] * 100 })").to_s,
                             cc_app[:memory].to_s,
                             cc_app[:disk_quota].to_s,
                             '1',
                             cc_app[:state] == 'STARTED' ? '1' : '0',
                             cc_app[:state] == 'STOPPED' ? '1' : '0',
                             cc_app[:package_state] == 'PENDING' ? '1' : '0',
                             cc_app[:package_state] == 'STAGED'  ? '1' : '0',
                             cc_app[:package_state] == 'FAILED'  ? '1' : '0'
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_SpacesTable_0', 'ZeroClipboard_TableToolsMovie_5')
        end

        context 'selectable' do
          before do
            select_first_row
          end
          it 'has details' do
            check_details([{ :label => 'Name',            :tag => 'div', :value => cc_space[:name] },
                           { :label => 'Organization',    :tag =>   'a', :value => cc_organization[:name] },
                           { :label => 'Created',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_space[:created_at].to_datetime.rfc3339 }\")") },
                           { :label => 'Updated',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_space[:updated_at].to_datetime.rfc3339 }\")") },
                           { :label => 'Developers',      :tag =>   'a', :value => '1' },
                           { :label => 'Total Routes',    :tag =>   nil, :value => '1' },
                           { :label => 'Used Routes',     :tag =>   nil, :value => '1' },
                           { :label => 'Unused Routes',   :tag =>   nil, :value => '0' },
                           { :label => 'Instances Used',  :tag =>   'a', :value => cc_app[:instances].to_s },
                           { :label => 'Services Used',   :tag =>   'a', :value => varz_dea['instance_registry']['application1']['application1_instance1']['services'].length.to_s },
                           { :label => 'Memory Used',     :tag =>   nil, :value => @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_memory_in_bytes'] })").to_s },
                           { :label => 'Disk Used',       :tag =>   nil, :value => @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_disk_in_bytes'] })").to_s },
                           { :label => 'CPU Used',        :tag =>   nil, :value => @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry']['application1']['application1_instance1']['computed_pcpu'] * 100 })").to_s },
                           { :label => 'Memory Reserved', :tag =>   nil, :value => cc_app[:memory].to_s },
                           { :label => 'Disk Reserved',   :tag =>   nil, :value => cc_app[:disk_quota].to_s },
                           { :label => 'Total Apps',      :tag =>   'a', :value => '1' },
                           { :label => 'Started Apps',    :tag =>   nil, :value => cc_app[:state] == 'STARTED' ? '1' : '0' },
                           { :label => 'Stopped Apps',    :tag =>   nil, :value => cc_app[:state] == 'STOPPED' ? '1' : '0' },
                           { :label => 'Pending Apps',    :tag =>   nil, :value => cc_app[:package_state] == 'PENDING' ? '1' : '0' },
                           { :label => 'Staged Apps',     :tag =>   nil, :value => cc_app[:package_state] == 'STAGED'  ? '1' : '0' },
                           { :label => 'Failed Apps',     :tag =>   nil, :value => cc_app[:package_state] == 'FAILED'  ? '1' : '0' }
                          ])
          end
          it 'has organization link' do
            check_filter_link('Spaces', 1, 'Organizations', cc_organization[:name])
          end
          it 'has developers link' do
            check_filter_link('Spaces', 4, 'Developers', "#{ cc_organization[:name] }/#{ cc_space[:name] }")
          end
          it 'has routes link' do
            check_filter_link('Spaces', 5, 'Routes', "#{ cc_organization[:name] }/#{ cc_space[:name] }")
          end
          it 'has instances link' do
            check_filter_link('Spaces', 8, 'Applications', "#{ cc_organization[:name] }/#{ cc_space[:name] }")
          end
          it 'has services link' do
            check_filter_link('Spaces', 9, 'ServiceInstances', "#{ cc_organization[:name] }/#{ cc_space[:name] }")
          end
          it 'has applications link' do
            check_filter_link('Spaces', 15, 'Applications', "#{ cc_organization[:name] }/#{ cc_space[:name] }")
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
                             cc_app[:name],
                             cc_app[:state],
                             @driver.execute_script('return Constants.STATUS__STAGED'),
                             varz_dea['instance_registry']['application1']['application1_instance1']['state'],
                             @driver.execute_script("return Format.formatString(\"#{ cc_app[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_app[:updated_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ Time.at(varz_dea['instance_registry']['application1']['application1_instance1']['state_running_timestamp']).to_datetime.rfc3339 }\")"),
                             "http://#{ varz_dea['instance_registry']['application1']['application1_instance1']['application_uris'][0] }",
                             cc_app[:detected_buildpack],
                             varz_dea['instance_registry']['application1']['application1_instance1']['instance_index'].to_s,
                             varz_dea['instance_registry']['application1']['application1_instance1']['services'].length.to_s,
                             @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_memory_in_bytes'] })").to_s,
                             @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_disk_in_bytes'] })").to_s,
                             @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry']['application1']['application1_instance1']['computed_pcpu'] * 100 })").to_s,
                             cc_app[:memory].to_s,
                             cc_app[:disk_quota].to_s,
                             "#{ cc_organization[:name] }/#{ cc_space[:name] }",
                             nats_dea['host']
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_ApplicationsTable_4', 'ZeroClipboard_TableToolsMovie_9')
        end

        it 'has a checkbox in the first column' do
          inputs = @driver.find_elements(:xpath => "//table[@id='ApplicationsTable']/tbody/tr/td[1]/input")
          expect(inputs.length).to eq(1)
          expect(inputs[0].attribute('value')).to eq("#{ cc_app[:guid] }")
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
            Selenium::WebDriver::Wait.new(:timeout => 560).until { refresh_button && @driver.find_element(:xpath => "//table[@id='ApplicationsTable']/tbody/tr/td[3]").text == expect_state }
          rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            expect(@driver.find_element(:xpath => "//table[@id='ApplicationsTable']/tbody/tr/td[3]").text).to eq(expect_state)
          end

          def check_operation_result
            alert = nil
            Selenium::WebDriver::Wait.new(:timeout => 60).until { alert = @driver.switch_to.alert }
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
            # stop the app
            manage_application(1)
            check_app_state('STOPPED')
          end
          it 'starts the selected application' do
            # let app in stopped state first
            manage_application(1)
            check_app_state('STOPPED')

            # start the app
            manage_application(0)
            check_app_state('STARTED')
          end
          it 'restart the selected application' do
            # let app in stopped state first
            manage_application(1)
            check_app_state('STOPPED')

            # restart the app
            manage_application(2)
            check_app_state('STARTED')
          end

          def check_deleted_app_table_data
            check_table_data(Selenium::WebDriver::Wait.new(:timeout => 360).until { refresh_button && @driver.find_elements(:xpath => "//table[@id='ApplicationsTable']/tbody/tr/td") },
                             [
                               '',
                               cc_app[:name],
                               '',
                               '',
                               varz_dea['instance_registry']['application1']['application1_instance1']['state'],
                               '',
                               '',
                               @driver.execute_script("return Format.formatString(\"#{ Time.at(varz_dea['instance_registry']['application1']['application1_instance1']['state_running_timestamp']).to_datetime.rfc3339 }\")"),
                               "http://#{ varz_dea['instance_registry']['application1']['application1_instance1']['application_uris'][0] }",
                               '',
                               '0',
                               varz_dea['instance_registry']['application1']['application1_instance1']['services'].length.to_s,
                               @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_memory_in_bytes'] })").to_s,
                               @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_disk_in_bytes'] })").to_s,
                               @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry']['application1']['application1_instance1']['computed_pcpu'] * 100 })").to_s,
                               cc_app[:memory].to_s,
                               cc_app[:disk_quota].to_s,
                               '',
                               nats_dea['host']
                             ])
          end

          it 'deletes the selected application' do
            # delete the application
            check_first_row
            @driver.find_element(:id => 'ToolTables_ApplicationsTable_3').click
            confirm = @driver.switch_to.alert
            expect(confirm.text).to eq('Are you sure you want to delete the selected applications?')
            confirm.accept

            check_operation_result

            begin
              Selenium::WebDriver::Wait.new(:timeout => 560).until do
                begin
                  check_deleted_app_table_data
                  # If this works, no reason to continue in this loop
                  break
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
            check_details([{ :label => 'Name',            :tag => 'div', :value => cc_app[:name] },
                           { :label => 'State',           :tag =>   nil, :value => cc_app[:state] },
                           { :label => 'Package State',   :tag =>   nil, :value => cc_app[:package_state] },
                           { :label => 'Instance State',  :tag =>   nil, :value => varz_dea['instance_registry']['application1']['application1_instance1']['state'] },
                           { :label => 'Created',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_app[:created_at].to_datetime.rfc3339 }\")") },
                           { :label => 'Updated',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_app[:updated_at].to_datetime.rfc3339 }\")") },
                           { :label => 'Started',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateNumber(#{ (varz_dea['instance_registry']['application1']['application1_instance1']['state_running_timestamp'] * 1000) })") },
                           { :label => 'URI',             :tag =>   'a', :value => "http://#{ varz_dea['instance_registry']['application1']['application1_instance1']['application_uris'][0] }" },
                           { :label => 'Buildpack',       :tag =>   nil, :value => cc_app[:detected_buildpack] },
                           { :label => 'Instance Index',  :tag =>   nil, :value => varz_dea['instance_registry']['application1']['application1_instance1']['instance_index'].to_s },
                           { :label => 'Droplet Hash',    :tag =>   nil, :value => varz_dea['instance_registry']['application1']['application1_instance1']['droplet_sha1'].to_s },
                           { :label => 'Services Used',   :tag =>   nil, :value => varz_dea['instance_registry']['application1']['application1_instance1']['services'].length.to_s },
                           { :label => 'Memory Used',     :tag =>   nil, :value => @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_memory_in_bytes'] })").to_s },
                           { :label => 'Disk Used',       :tag =>   nil, :value => @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_disk_in_bytes'] })").to_s },
                           { :label => 'CPU Used',        :tag =>   nil, :value => @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry']['application1']['application1_instance1']['computed_pcpu'] * 100 })").to_s },
                           { :label => 'Memory Reserved', :tag =>   nil, :value => cc_app[:memory].to_s },
                           { :label => 'Disk Reserved',   :tag =>   nil, :value => cc_app[:disk_quota].to_s },
                           { :label => 'Space',           :tag =>   'a', :value => cc_space[:name] },
                           { :label => 'Organization',    :tag =>   'a', :value => cc_organization[:name] },
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
            check_filter_link('Applications', 17, 'Spaces', "#{ cc_organization[:name] }/#{ cc_space[:name] }")
          end
          it 'has organization link' do
            check_filter_link('Applications', 18, 'Organizations', cc_organization[:name])
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
          check_table_data(@driver.find_elements(:xpath => "//table[@id='RoutesTable']/tbody/tr/td"),
                           [
                             '',
                             cc_route[:host],
                             cc_domain[:name],
                             @driver.execute_script("return Format.formatString(\"#{ cc_route[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_route[:updated_at].to_datetime.rfc3339 }\")"),
                             "#{ cc_organization[:name] }/#{ cc_space[:name] }",
                             cc_app[:name]
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_RoutesTable_1', 'ZeroClipboard_TableToolsMovie_17')
        end

        it 'has a checkbox in the first column' do
          inputs = @driver.find_elements(:xpath => "//table[@id='RoutesTable']/tbody/tr/td[1]/input")
          expect(inputs.length).to eq(1)
          expect(inputs[0].attribute('value')).to eq("#{ cc_route[:guid]}")
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
            # delete the route
            check_first_row
            @driver.find_element(:id => 'ToolTables_RoutesTable_0').click
            confirm = @driver.switch_to.alert
            expect(confirm.text).to eq('Are you sure you want to delete the selected routes?')
            confirm.accept

            alert = nil
            Selenium::WebDriver::Wait.new(:timeout => 60).until { alert = @driver.switch_to.alert }
            expect(alert.text).to eq('Routes successfully deleted.')
            alert.dismiss

            begin
              Selenium::WebDriver::Wait.new(:timeout => 240).until { refresh_button && @driver.find_element(:xpath => "//table[@id='RoutesTable']/tbody/tr").text == 'No data available in table' }
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
            check_details([{ :label => 'Host',          :tag => nil, :value => cc_route[:host] },
                           { :label => 'Domain',        :tag => nil, :value => cc_domain[:name] },
                           { :label => 'Created',       :tag => nil, :value => Selenium::WebDriver::Wait.new(:timeout => 60).until { @driver.execute_script("return Format.formatDateString(\"#{ cc_route[:created_at].to_datetime.rfc3339 }\")") } },
                           { :label => 'Updated',       :tag => nil, :value => Selenium::WebDriver::Wait.new(:timeout => 60).until { @driver.execute_script("return Format.formatDateString(\"#{ cc_route[:updated_at].to_datetime.rfc3339 }\")") } },
                           { :label => 'Applications',  :tag => 'a', :value => '1' },
                           { :label => 'Space',         :tag => 'a', :value => cc_space[:name] },
                           { :label => 'Organization',  :tag => 'a', :value => cc_organization[:name] }
                          ])
          end

          it 'has applications link' do
            check_filter_link('Routes', 4, 'Applications', "#{ cc_route[:host] }.#{ cc_domain[:name] }")
          end
          it 'has space link' do
            check_filter_link('Routes', 5, 'Spaces', "#{ cc_organization[:name] }/#{ cc_space[:name]}")
          end
          it 'has organization link' do
            check_filter_link('Routes', 6, 'Organizations', "#{ cc_organization[:name] }")
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
                             cc_service_broker[:name],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_broker[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_broker[:updated_at].to_datetime.rfc3339 }\")"),
                             cc_service[:provider],
                             cc_service[:label],
                             cc_service[:version],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service[:updated_at].to_datetime.rfc3339 }\")"),
                             cc_service_plan[:name],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_plan[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_plan[:updated_at].to_datetime.rfc3339 }\")"),
                             cc_service_plan[:public].to_s,
                             @driver.execute_script("return Format.formatTarget(\"#{ cc_service[:provider] }/#{ cc_service[:label] }/#{ cc_service_plan[:name] }\")").gsub(/<\/?[^>]+>/, ''),
                             cc_service_instance[:name],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_instance[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_instance[:updated_at].to_datetime.rfc3339 }\")"),
                             '1',
                             "#{ cc_organization[:name] }/#{ cc_space[:name] }"
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_ServiceInstancesTable_0', 'ZeroClipboard_TableToolsMovie_21')
        end

        context 'selectable' do
          before do
            select_first_row
          end
          it 'has details' do
            tags = JSON.parse(cc_service[:tags])
            check_details([{ :label => 'Service Instance Name',          :tag => 'div', :value => cc_service_instance[:name] },
                           { :label => 'Service Instance Created',       :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service_instance[:created_at].to_datetime.rfc3339 }\")") },
                           { :label => 'Service Instance Updated',       :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service_instance[:updated_at].to_datetime.rfc3339 }\")") },
                           { :label => 'Service Instance Dashboard URL', :tag =>   nil, :value => cc_service_instance[:dashboard_url] },
                           { :label => 'Service Broker Name',            :tag =>   nil, :value => cc_service_broker[:name] },
                           { :label => 'Service Broker Created',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service_broker[:created_at].to_datetime.rfc3339 }\")") },
                           { :label => 'Service Broker Updated',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service_broker[:updated_at].to_datetime.rfc3339 }\")") },
                           { :label => 'Service Provider',               :tag =>   nil, :value => cc_service[:provider] },
                           { :label => 'Service Label',                  :tag =>   nil, :value => cc_service[:label] },
                           { :label => 'Service Version',                :tag =>   nil, :value => cc_service[:version] },
                           { :label => 'Service Created',                :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service[:created_at].to_datetime.rfc3339 }\")") },
                           { :label => 'Service Updated',                :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service[:updated_at].to_datetime.rfc3339 }\")") },
                           { :label => 'Service Description',            :tag =>   nil, :value => cc_service[:description] },
                           { :label => 'Service Bindable',               :tag =>   nil, :value => cc_service[:bindable].to_s },
                           { :label => 'Service Extra',                  :tag =>   nil, :value => cc_service[:extra] },
                           { :label => 'Service Tag',                    :tag =>   nil, :value => tags[0] },
                           { :label => 'Service Tag',                    :tag =>   nil, :value => tags[1] },
                           { :label => 'Service Documentation URL',      :tag =>   nil, :value => cc_service[:documentation_url] },
                           { :label => 'Service Info URL',               :tag =>   nil, :value => cc_service[:info_url] },
                           { :label => 'Service Plan Name',              :tag =>   'a', :value => cc_service_plan[:name] },
                           { :label => 'Service Plan Created',           :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service_plan[:created_at].to_datetime.rfc3339 }\")") },
                           { :label => 'Service Plan Updated',           :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service_plan[:updated_at].to_datetime.rfc3339 }\")") },
                           { :label => 'Service Plan Public',            :tag =>   nil, :value => cc_service_plan[:public].to_s },
                           { :label => 'Service Plan Description',       :tag =>   nil, :value => cc_service_plan[:description] },
                           { :label => 'Service Plan Extra',             :tag =>   nil, :value => cc_service_plan[:extra] },
                           { :label => 'Space',                          :tag =>   'a', :value => cc_space[:name] },
                           { :label => 'Organization',                   :tag =>   'a', :value => cc_organization[:name] }
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
                               cc_app[:name],
                               @driver.execute_script("return Format.formatDateString(\"#{ cc_service_binding[:created_at].to_datetime.rfc3339 }\")")
                             ])
          end
          it 'has service plan name link' do
            check_filter_link('ServiceInstances', 19, 'ServicePlans', "#{ cc_service[:provider] }/#{ cc_service[:label] }/#{ cc_service_plan[:name] }")
          end
          it 'has space link' do
            check_filter_link('ServiceInstances', 25, 'Spaces', "#{ cc_organization[:name] }/#{ cc_space[:name] }")
          end
          it 'has organization link' do
            check_filter_link('ServiceInstances', 26, 'Organizations', cc_organization[:name])
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
                             "#{ uaa_user[:email] }",
                             cc_space[:name],
                             cc_organization[:name],
                             "#{ cc_organization[:name] }/#{ cc_space[:name] }",
                             @driver.execute_script("return Format.formatString(\"#{ uaa_user[:created].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ uaa_user[:lastmodified].to_datetime.rfc3339 }\")")
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_DevelopersTable_0', 'ZeroClipboard_TableToolsMovie_29')
        end

        context 'selectable' do
          before do
            select_first_row
          end
          it 'has details' do
            check_details([{ :label => 'Email',        :tag => 'div', :value => "mailto:#{ uaa_user[:email] }" },
                           { :label => 'Created',      :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ uaa_user[:created] }\")") },
                           { :label => 'Updated',      :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ uaa_user[:lastmodified] }\")") },
                           { :label => 'Authorities',  :tag =>   nil, :value => uaa_group[:displayname] },
                           { :label => 'Space',        :tag =>   'a', :value => cc_space[:name] },
                           { :label => 'Organization', :tag =>   'a', :value => cc_organization[:name] }
                          ])
          end
          it 'has space link' do
            check_filter_link('Developers', 4, 'Spaces', "#{ cc_organization[:name] }/#{ cc_space[:name] }")
          end
          it 'has organization link' do
            check_filter_link('Developers', 5, 'Organizations', cc_organization[:name])
          end
        end
      end

      context 'Quotas' do
        let(:tab_id) { 'Quotas' }
        it 'has a table' do
          check_table_layout([{ :columns         => @driver.find_elements(:xpath => "//div[@id='QuotasTableContainer']/div/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                :expected_length => 8,
                                :labels          => ['Name', 'Created', 'Updated', 'Total Services', 'Total Routes', 'Memory Limit', 'Non-Basic Services Allowed', 'Organizations'],
                                :colspans        => nil
                              }
                             ])
          check_table_data(@driver.find_elements(:xpath => "//table[@id='QuotasTable']/tbody/tr/td"),
                           [
                             cc_quota_definition[:name],
                             @driver.execute_script("return Format.formatString(\"#{ cc_quota_definition[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_quota_definition[:updated_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatNumber(\"#{ cc_quota_definition[:total_services] }\")"),
                             @driver.execute_script("return Format.formatNumber(\"#{ cc_quota_definition[:total_routes] }\")"),
                             @driver.execute_script("return Format.formatNumber(\"#{ cc_quota_definition[:memory_limit] }\")"),
                             cc_quota_definition[:non_basic_services_allowed].to_s,
                             '1'
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_QuotasTable_0', 'ZeroClipboard_TableToolsMovie_33')
        end

        context 'selectable' do
          before do
            select_first_row
          end
          it 'has details' do
            check_details([{ :label => 'Name',                       :tag => 'div', :value => cc_quota_definition[:name] },
                           { :label => 'Created',                    :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_quota_definition[:created_at].to_datetime.rfc3339 }\")") },
                           { :label => 'Updated',                    :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_quota_definition[:updated_at].to_datetime.rfc3339 }\")") },
                           { :label => 'Total Services',             :tag =>   nil, :value => @driver.execute_script("return Format.formatNumber(\"#{ cc_quota_definition[:total_services] }\")") },
                           { :label => 'Total Routes',               :tag =>   nil, :value => @driver.execute_script("return Format.formatNumber(\"#{ cc_quota_definition[:total_routes] }\")") },
                           { :label => 'Memory Limit',               :tag =>   nil, :value => @driver.execute_script("return Format.formatNumber(\"#{ cc_quota_definition[:memory_limit] }\")") },
                           { :label => 'Non-Basic Services Allowed', :tag =>   nil, :value => cc_quota_definition[:non_basic_services_allowed].to_s },
                           { :label => 'Organizations',              :tag =>   'a', :value => '1' }
                          ])
          end
          it 'has organizations link' do
            check_filter_link('Quotas', 7, 'Organizations', "#{ cc_quota_definition[:name] }")
          end
        end
      end

      context 'Service Plans' do
        let(:tab_id) { 'ServicePlans' }
        it 'has a table' do
          check_table_layout([{ :columns         => @driver.find_elements(:xpath => "//div[@id='ServicePlansTable_wrapper']/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                :expected_length => 3,
                                :labels          => ['Service Plan', 'Service', 'Service Broker'],
                                :colspans        => %w(8 7 3)
                              },
                              {
                                :columns         => @driver.find_elements(:xpath => "//div[@id='ServicePlansTable_wrapper']/div[6]/div[1]/div/table/thead/tr[2]/th"),
                                :expected_length => 18,
                                :labels          => [' ', 'Name', 'Target', 'Created', 'Updated', 'Public', 'Visible Organizations', 'Service Instances', 'Provider', 'Label', 'Version', 'Created', 'Updated', 'Active', 'Bindable', 'Name', 'Created', 'Updated'],
                                :colspans        => nil
                              }
                             ])
          check_table_data(@driver.find_elements(:xpath => "//table[@id='ServicePlansTable']/tbody/tr/td"),
                           [
                             '',
                             cc_service_plan[:name],
                             @driver.execute_script("return Format.formatTarget(\"#{ cc_service[:provider] }/#{ cc_service[:label] }/#{ cc_service_plan[:name] }\")").gsub(/<\/?[^>]+>/, ''),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_plan[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_plan[:updated_at].to_datetime.rfc3339 }\")"),
                             cc_service_plan[:public].to_s,
                             '1',
                             '1',
                             cc_service[:provider],
                             cc_service[:label],
                             cc_service[:version],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service[:updated_at].to_datetime.rfc3339 }\")"),
                             cc_service[:active].to_s,
                             cc_service[:bindable].to_s,
                             cc_service_broker[:name],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_broker[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_broker[:updated_at].to_datetime.rfc3339 }\")")
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_ServicePlansTable_2', 'ZeroClipboard_TableToolsMovie_37')
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            value_extra_json = JSON.parse(cc_service[:extra])
            check_details([{ :label => 'Service Plan Name',              :tag => 'div', :value => cc_service_plan[:name] },
                           { :label => 'Service Plan Created',           :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service_plan[:created_at].to_datetime.rfc3339 }\")") },
                           { :label => 'Service Plan Updated',           :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service_plan[:updated_at].to_datetime.rfc3339 }\")") },
                           { :label => 'Service Plan Public',            :tag =>   nil, :value => cc_service_plan[:public].to_s },
                           { :label => 'Service Plan Description',       :tag =>   nil, :value => cc_service_plan[:description] },
                           { :label => 'Service Instances',              :tag =>   'a', :value => '1' },
                           { :label => 'Service Broker Name',            :tag =>   nil, :value => cc_service_broker[:name] },
                           { :label => 'Service Broker Created',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service_broker[:created_at].to_datetime.rfc3339 }\")") },
                           { :label => 'Service Broker Updated',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service_broker[:updated_at].to_datetime.rfc3339 }\")") },
                           { :label => 'Service Provider',               :tag =>   nil, :value => cc_service[:provider] },
                           { :label => 'Service Label',                  :tag =>   nil, :value => cc_service[:label] },
                           { :label => 'Service Version',                :tag =>   nil, :value => cc_service[:version] },
                           { :label => 'Service Created',                :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service[:created_at].to_datetime.rfc3339 }\")") },
                           { :label => 'Service Updated',                :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_service[:updated_at].to_datetime.rfc3339 }\")") },
                           { :label => 'Service Active',                 :tag =>   nil, :value => cc_service[:active].to_s },
                           { :label => 'Service Bindable',               :tag =>   nil, :value => cc_service[:bindable].to_s },
                           { :label => 'Service Description',            :tag =>   nil, :value => cc_service[:description] },
                           { :label => 'Service Display Name',           :tag =>   nil, :value => value_extra_json['displayName'] },
                           { :label => 'Service Provider Display Name',  :tag =>   nil, :value => value_extra_json['providerDisplayName'] },
                           { :label => 'Service Icon',                   :tag => 'img', :value => @driver.execute_script("return Format.formatIconImage(\"#{ value_extra_json['imageUrl'] }\", \"service icon\", \"flot:left;\")").gsub(/'/, "\"").gsub(/[ ]+/, ' ').gsub(/ >/, '>') },
                           { :label => 'Service Long Description',       :tag =>   nil, :value => value_extra_json['longDescription'] }
                          ])
          end
          it 'has visible organizations' do
            expect(@driver.find_element(:id => 'ServicePlansOrganizationsDetailsLabel').displayed?).to be_true
            check_table_headers(:columns         => @driver.find_elements(:xpath => "//div[@id='ServicePlansOrganizationsTableContainer']/div[2]/div[5]/div[1]/div/table/thead/tr/th"),
                                :expected_length => 2,
                                :labels          => %w(Organization Created),
                                :colspans        => nil)
            check_table_data(@driver.find_elements(:xpath => "//table[@id='ServicePlansOrganizationsTable']/tbody/tr/td"),
                             [
                               cc_organization[:name],
                               @driver.execute_script("return Format.formatDateString(\"#{ cc_service_plan_visibility[:created_at].to_datetime.rfc3339 }\")")
                             ])
          end

          it 'has a checkbox in the first column' do
            inputs = @driver.find_elements(:xpath => "//table[@id='ServicePlansTable']/tbody/tr/td[1]/input")
            expect(inputs.length).to eq(1)
            expect(inputs[0].attribute('value')).to eq("#{ cc_service_plan[:guid] }")
          end

          it 'has service instances link to service instances filtered by service plan target' do
            check_filter_link('ServicePlans', 5, 'ServiceInstances', "#{ cc_service[:provider] }/#{ cc_service[:label] }/#{ cc_service_plan[:name] }")
          end

          context 'manage service plans' do
            def check_first_row
              @driver.find_elements(:xpath => "//table[@id='ServicePlansTable']/tbody/tr/td[1]/input")[0].click
            end

            def manage_service_plan(buttonIndex)
              check_first_row
              @driver.find_element(:id => "ToolTables_ServicePlansTable_#{ buttonIndex }").click
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
                Selenium::WebDriver::Wait.new(:timeout => 60).until { refresh_button && @driver.find_element(:xpath => "//table[@id='ServicePlansTable']/tbody/tr/td[6]").text == expect_state }
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
                                :expected_length => 3,
                                :labels          => ['', 'Instances', '% Free'],
                                :colspans        => %w(8 4 2)
                              },
                              { :columns         => @driver.find_elements(:xpath => "//div[@id='DEAsTableContainer']/div/div[6]/div[1]/div/table/thead/tr[2]/th"),
                                :expected_length => 14,
                                :labels          => ['Name', 'Index', 'Status', 'Started', 'Stack', 'CPU', 'Memory', 'Apps', 'Running', 'Memory', 'Disk', '% CPU', 'Memory', 'Disk'],
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
                             varz_dea['instance_registry']['application1'].length.to_s,
                             @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_memory_in_bytes'] })").to_s,
                             @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_disk_in_bytes'] })").to_s,
                             @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry']['application1']['application1_instance1']['computed_pcpu'] * 100 })").to_s,
                             @driver.execute_script("return Format.formatNumber(#{ varz_dea['available_memory_ratio'].to_f * 100 })"),
                             @driver.execute_script("return Format.formatNumber(#{ varz_dea['available_disk_ratio'].to_f * 100 })")
                           ])
        end
        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_DEAsTable_1', 'ZeroClipboard_TableToolsMovie_41')
        end
        it 'has a create DEA button' do
          expect(@driver.find_element(:id => 'ToolTables_DEAsTable_0').text).to eq('Create new DEA')
        end
        context 'selectable' do
          before do
            select_first_row
          end
          it 'has details' do
            check_details([{ :label => 'Name',                  :tag => nil, :value => varz_dea['host'] },
                           { :label => 'Index',                 :tag => nil, :value => varz_dea['index'].to_s },
                           { :label => 'URI',                   :tag => 'a', :value => nats_dea_varz },
                           { :label => 'Host',                  :tag => nil, :value => varz_dea['host'] },
                           { :label => 'Started',               :tag => nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ varz_dea['start'] }\")") },
                           { :label => 'Uptime',                :tag => nil, :value => @driver.execute_script("return Format.formatUptime(\"#{ varz_dea['uptime'] }\")") },
                           { :label => 'Stack',                 :tag => nil, :value => varz_dea['stacks'][0] },
                           { :label => 'Apps',                  :tag => 'a', :value => varz_dea['instance_registry'].length.to_s },
                           { :label => 'Cores',                 :tag => nil, :value => varz_dea['num_cores'].to_s },
                           { :label => 'CPU',                   :tag => nil, :value => varz_dea['cpu'].to_s },
                           { :label => 'CPU Load Avg',          :tag => nil, :value => "#{ @driver.execute_script("return Format.formatNumber(#{ varz_dea['cpu_load_avg'].to_f * 100 })") }%" },
                           { :label => 'Memory',                :tag => nil, :value => varz_dea['mem'].to_s },
                           { :label => 'Instances',             :tag => nil, :value => varz_dea['instance_registry']['application1'].length.to_s },
                           { :label => 'Instances Memory Used', :tag =>   nil, :value => @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_memory_in_bytes'] })").to_s },
                           { :label => 'Instances Disk Used',   :tag =>   nil, :value => @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry']['application1']['application1_instance1']['used_disk_in_bytes'] })").to_s },
                           { :label => 'Instances CPU Used',    :tag =>   nil, :value => @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry']['application1']['application1_instance1']['computed_pcpu'] * 100 })").to_s },
                           { :label => 'Memory Free',           :tag => nil, :value => "#{ @driver.execute_script("return Format.formatNumber(#{ varz_dea['available_memory_ratio'].to_f * 100 })") }%" },
                           { :label => 'Disk Free',             :tag => nil, :value => "#{ @driver.execute_script("return Format.formatNumber(#{ varz_dea['available_disk_ratio'].to_f * 100 })") }%" }
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

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_CloudControllersTable_0', 'ZeroClipboard_TableToolsMovie_45')
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

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_HealthManagersTable_0', 'ZeroClipboard_TableToolsMovie_49')
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
                             varz_provisioner['config']['service'][:description],
                             varz_provisioner['cpu'].to_s,
                             varz_provisioner['mem'].to_s,
                             varz_provisioner['nodes'].length.to_s,
                             @capacity.to_s
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_GatewaysTable_0', 'ZeroClipboard_TableToolsMovie_53')
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

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_RoutersTable_0', 'ZeroClipboard_TableToolsMovie_61')
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

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_ComponentsTable_1', 'ZeroClipboard_TableToolsMovie_65')
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
          # expect(columns[2].text).to eq(@driver.execute_script("return Format.formatString(\"#{ log_file_displayed_modified.utc.to_datetime.rfc3339 }\")"))
          expect(@driver.find_element(:id => 'LogContainer').displayed?).to be_true
          expect(@driver.find_element(:id => 'LogLink').text).to eq(columns[0].text)
          expect(@driver.find_element(:id => 'LogContents').text).to eq(log_file_displayed_contents)
        end
        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_LogsTable_0', 'ZeroClipboard_TableToolsMovie_69')
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

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_TasksTable_0', 'ZeroClipboard_TableToolsMovie_73')
        end

        it 'can show task output' do
          expect(@driver.find_element(:xpath => "//table[@id='TasksTable']/tbody/tr").text).to eq('No data available in table')
          @driver.find_element(:id => 'DEAs').click
          @driver.find_element(:id => 'ToolTables_DEAsTable_0').click
          @driver.find_element(:id => 'DialogOkayButton').click
          @driver.find_element(:id => 'Tasks').click

          # As the page refreshes, we need to catch the stale element error and re-find the element on the page
          begin
            Selenium::WebDriver::Wait.new(:timeout => 60).until { @driver.find_elements(:xpath => "//table[@id='TasksTable']/tbody/tr").length == 1 }
          rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
          end
          expect(@driver.find_elements(:xpath => "//table[@id='TasksTable']/tbody/tr").length).to eq(1)

          begin
            Selenium::WebDriver::Wait.new(:timeout => 60).until do
              refresh_button
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
            refresh_button
          end
          it 'has a table' do
            check_stats_table('Stats')
          end
          it 'has allowscriptaccess property set to sameDomain' do
            check_allowscriptaccess_attribute('ToolTables_StatsTable_1', 'ZeroClipboard_TableToolsMovie_77')
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
            check_table_data(Selenium::WebDriver::Wait.new(:timeout => 360).until { refresh_button && @driver.find_elements(:xpath => "//table[@id='StatsTable']/tbody/tr/td") }, [nil, '1', '1', '1', '1', '1', '1', '1'])
          rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError, Timeout::Error
          end
          check_table_data(@driver.find_elements(:xpath => "//table[@id='StatsTable']/tbody/tr/td"), [nil, '1', '1', '1', '1', '1', '1', '1'])
        end
      end
    end
  end
end
