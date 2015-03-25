require 'date'
require 'rubygems'
require_relative '../../spec_helper'
require_relative '../../support/web_helper'

describe AdminUI::Admin, type: :integration, firefox_available: true do
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

    def check_allowscriptaccess_attribute(copy_node_id)
      expect(@driver.find_element(id: copy_node_id).text).to eq('Copy')
      expect(@driver.find_element(xpath: "//a[@id='#{ copy_node_id }']/div/embed").attribute('allowscriptaccess')).to eq('sameDomain')
    end

    def refresh_button
      @driver.find_element(id: 'MenuButtonRefresh').click
      true
    end

    it 'has a title' do
      # Need to wait until the page has been rendered
      begin
        Selenium::WebDriver::Wait.new(timeout: 60).until { @driver.find_element(class: 'cloudControllerText').text == cloud_controller_uri }
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(class: 'cloudControllerText').text).to eq(cloud_controller_uri)
    end

    it 'has tabs' do
      expect(scroll_tab_into_view('Organizations').displayed?).to be_true
      expect(scroll_tab_into_view('Spaces').displayed?).to be_true
      expect(scroll_tab_into_view('Applications').displayed?).to be_true
      expect(scroll_tab_into_view('ServiceInstances').displayed?).to be_true
      expect(scroll_tab_into_view('ServiceBindings').displayed?).to be_true
      expect(scroll_tab_into_view('OrganizationRoles').displayed?).to be_true
      expect(scroll_tab_into_view('SpaceRoles').displayed?).to be_true
      expect(scroll_tab_into_view('Clients').displayed?).to be_true
      expect(scroll_tab_into_view('Users').displayed?).to be_true
      expect(scroll_tab_into_view('Domains').displayed?).to be_true
      expect(scroll_tab_into_view('Quotas').displayed?).to be_true
      expect(scroll_tab_into_view('ServiceBrokers').displayed?).to be_true
      expect(scroll_tab_into_view('Services').displayed?).to be_true
      expect(scroll_tab_into_view('ServicePlans').displayed?).to be_true
      expect(scroll_tab_into_view('DEAs').displayed?).to be_true
      expect(scroll_tab_into_view('CloudControllers').displayed?).to be_true
      expect(scroll_tab_into_view('HealthManagers').displayed?).to be_true
      expect(scroll_tab_into_view('Gateways').displayed?).to be_true
      expect(scroll_tab_into_view('Routers').displayed?).to be_true
      expect(scroll_tab_into_view('Routes').displayed?).to be_true
      expect(scroll_tab_into_view('Components').displayed?).to be_true
      expect(scroll_tab_into_view('Logs').displayed?).to be_true
      expect(scroll_tab_into_view('Tasks').displayed?).to be_true
      expect(scroll_tab_into_view('Stats').displayed?).to be_true
    end

    it 'has a left scroll button' do
      expect(@driver.find_element(id: 'MenuButtonLeft').displayed?).to be_true
    end

    it 'has a right scroll button' do
      expect(@driver.find_element(id: 'MenuButtonRight').displayed?).to be_true
    end

    it 'has a refresh button' do
      expect(@driver.find_element(id: 'MenuButtonRefresh').displayed?).to be_true
    end

    it 'shows the logged in user' do
      expect(@driver.find_element(class: 'userContainer').displayed?).to be_true
      expect(@driver.find_element(class: 'user').text).to eq('admin')
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
          Selenium::WebDriver::Wait.new(timeout: 60).until do
            scroll_tab_into_view(tab_id).click
            @driver.find_element(class_name: 'menuItemSelected').attribute('id') == tab_id
          end
        rescue Selenium::WebDriver::Error::TimeOutError
        end
        expect(@driver.find_element(class_name: 'menuItemSelected').attribute('id')).to eq(tab_id)
        # Need to wait until the page has been rendered
        begin
          Selenium::WebDriver::Wait.new(timeout: 60).until { @driver.find_element(id: "#{ tab_id }Page").displayed? }
        rescue Selenium::WebDriver::Error::TimeOutError
        end
        expect(@driver.find_element(id: "#{ tab_id }Page").displayed?).to eq(true)

        if table_has_data
          # Need to wait until the table on the page has data
          begin
            Selenium::WebDriver::Wait.new(timeout: 360).until { @driver.find_element(xpath: "//table[@id='#{ tab_id }Table']/tbody/tr").text != 'No data available in table' }
          rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
          end
          expect(@driver.find_element(xpath: "//table[@id='#{ tab_id }Table']/tbody/tr").text).not_to eq('No data available in table')
        end
      end

      context 'Organizations' do
        let(:tab_id) { 'Organizations' }

        it 'has a table' do
          check_table_layout([{ columns:         @driver.find_elements(xpath: "//div[@id='OrganizationsTableContainer']/div/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                expected_length: 7,
                                labels:          ['', '', 'Routes', 'Used', 'Reserved', 'App States', 'App Package States'],
                                colspans:        %w(1 10 3 5 2 3 3)
                              },
                              { columns:         @driver.find_elements(xpath: "//div[@id='OrganizationsTableContainer']/div/div[6]/div[1]/div/table/thead/tr[2]/th"),
                                expected_length: 27,
                                labels:          [' ', 'Name', 'GUID', 'Status', 'Created', 'Updated', 'Spaces', 'Organization Roles', 'Space Roles', 'Quota', 'Domains', 'Total', 'Used', 'Unused', 'Instances', 'Services', 'Memory', 'Disk', '% CPU', 'Memory', 'Disk', 'Total', 'Started', 'Stopped', 'Pending', 'Staged', 'Failed'],
                                colspans:        nil
                              }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='OrganizationsTable']/tbody/tr/td"),
                           [
                             '',
                             cc_organization[:name],
                             cc_organization[:guid],
                             cc_organization[:status].upcase,
                             @driver.execute_script("return Format.formatString(\"#{ cc_organization[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_organization[:updated_at].to_datetime.rfc3339 }\")"),
                             '1',
                             '4',
                             '3',
                             cc_quota_definition[:name],
                             '1',
                             '1',
                             '1',
                             '0',
                             cc_app[:instances].to_s,
                             varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['services'].length.to_s,
                             @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_memory_in_bytes'] })").to_s,
                             @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_disk_in_bytes'] })").to_s,
                             @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['computed_pcpu'] * 100 })").to_s,
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
          check_allowscriptaccess_attribute('ToolTables_OrganizationsTable_5')
        end

        it 'has a checkbox in the first column' do
          inputs = @driver.find_elements(xpath: "//table[@id='OrganizationsTable']/tbody/tr/td[1]/input")
          expect(inputs.length).to eq(1)
          expect(inputs[0].attribute('value')).to eq(cc_organization[:guid])
        end

        context 'set quota' do
          let(:insert_second_quota_definition) { true }

          def check_first_row
            @driver.find_elements(xpath: "//table[@id='OrganizationsTable']/tbody/tr/td[1]/input")[0].click
          end

          def check_operation_result
            Selenium::WebDriver::Wait.new(timeout: 60).until { @driver.find_element(id: 'ModalDialogContents').displayed? }
            expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be_true
            expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Success')
            @driver.find_element(id: 'modalDialogButton0').click
          end

          it 'has a set quota button' do
            expect(@driver.find_element(id: 'ToolTables_OrganizationsTable_1').text).to eq('Set Quota')
          end

          it 'alerts the user to select at least one row when clicking the button without selecting a row' do
            @driver.find_element(id: 'ToolTables_OrganizationsTable_1').click

            expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be_true
            expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Error')
            expect(@driver.find_element(id: 'ModalDialogContents').text).to eq('Please select at least one row!')
            @driver.find_element(id: 'modalDialogButton0').click
          end

          it 'sets the specific quota for the organization' do
            check_first_row
            @driver.find_element(id: 'ToolTables_OrganizationsTable_1').click

            # Check whether the dialog is displayed
            expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be_true
            expect(@driver.find_element(id: 'quotaSelector').displayed?).to be_true
            expect(@driver.find_element(xpath: '//select[@id="quotaSelector"]/option[1]').text).to eq(cc_quota_definition[:name])
            expect(@driver.find_element(xpath: '//select[@id="quotaSelector"]/option[2]').text).to eq(cc_quota_definition2[:name])

            # Select another quota and click the set button
            @driver.find_element(xpath: '//select[@id="quotaSelector"]/option[2]').click
            @driver.find_element(id: 'modalDialogButton0').click
            check_operation_result

            begin
              Selenium::WebDriver::Wait.new(timeout: 460).until { refresh_button && @driver.find_element(xpath: "//table[@id='OrganizationsTable']/tbody/tr/td[10]").text == cc_quota_definition2[:name] }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='OrganizationsTable']/tbody/tr/td[10]").text).to eq(cc_quota_definition2[:name])
          end
        end

        context 'manage organization' do
          def check_first_row
            @driver.find_elements(xpath: "//table[@id='OrganizationsTable']/tbody/tr/td[1]/input")[0].click
          end

          it 'has a create button' do
            expect(@driver.find_element(id: 'ToolTables_OrganizationsTable_0').text).to eq('Create')
          end

          it 'has a delete button' do
            expect(@driver.find_element(id: 'ToolTables_OrganizationsTable_2').text).to eq('Delete')
          end

          it 'creates an organization' do
            @driver.find_element(id: 'ToolTables_OrganizationsTable_0').click

            # Check whether the dialog is displayed
            expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be_true
            expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Create Organization')
            expect(@driver.find_element(id: 'organizationName').displayed?).to be_true

            # Click the create button without input an organization name
            @driver.find_element(id: 'modalDialogButton0').click
            alert = @driver.switch_to.alert
            expect(alert.text).to eq('Please input the name of the organization first!')
            alert.dismiss

            # Input the name of the organization and click 'Create'
            @driver.find_element(id: 'organizationName').send_keys cc_organization2[:name]
            @driver.find_element(id: 'modalDialogButton0').click

            Selenium::WebDriver::Wait.new(timeout: 60).until { @driver.find_element(id: 'ModalDialogContents').displayed? }
            expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be_true
            expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Success')
            @driver.find_element(id: 'modalDialogButton0').click

            begin
              Selenium::WebDriver::Wait.new(timeout: 60).until { refresh_button && @driver.find_element(xpath: "//table[@id='OrganizationsTable']/tbody/tr[1]/td[2]").text == cc_organization2[:name] }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='OrganizationsTable']/tbody/tr[1]/td[2]").text).to eq(cc_organization2[:name])
          end

          it 'has an activate button' do
            expect(@driver.find_element(id: 'ToolTables_OrganizationsTable_3').text).to eq('Activate')
          end

          it 'has a suspend button' do
            expect(@driver.find_element(id: 'ToolTables_OrganizationsTable_4').text).to eq('Suspend')
          end

          shared_examples 'click button without selecting a single row' do
            it 'alerts the user to select at least one row when clicking the button' do
              @driver.find_element(id: buttonId).click
              expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be_true
              expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Error')
              expect(@driver.find_element(id: 'ModalDialogContents').text).to eq('Please select at least one row!')
              @driver.find_element(id: 'modalDialogButton0').click
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

            @driver.find_element(id: button_id).click

            expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be_true
            expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Confirmation')
            expect(@driver.find_element(id: 'ModalDialogContents').text).to eq(message)
            @driver.find_element(id: 'modalDialogButton0').click

            expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be_true
            expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Success')
            expect(@driver.find_element(id: 'ModalDialogContents').text).to eq(result_message)
            @driver.find_element(id: 'modalDialogButton0').click
          end

          def suspend_org
            manage_org('ToolTables_OrganizationsTable_4', 'Are you sure you want to suspend the selected organizations?', 'The operation finished without error. Please refresh the page later for the updated result.')
          end

          def activate_org
            manage_org('ToolTables_OrganizationsTable_3', 'Are you sure you want to activate the selected organizations?', 'The operation finished without error. Please refresh the page later for the updated result.')
          end

          def delete_org
            manage_org('ToolTables_OrganizationsTable_2', 'Are you sure you want to delete the selected organizations?', 'The operation finished without error. Please refresh the page later for the updated result.')
          end

          def check_organization_status(status)
            Selenium::WebDriver::Wait.new(timeout: 560).until { refresh_button && @driver.find_element(xpath: "//table[@id='OrganizationsTable']/tbody/tr/td[4]").text == status }
          rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            expect(Selenium::WebDriver::Wait.new(timeout: 360).until { refresh_button && @driver.find_element(xpath: "//table[@id='OrganizationsTable']/tbody/tr/td[4]").text }).to eq(status)
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
              Selenium::WebDriver::Wait.new(timeout: 60).until { refresh_button && @driver.find_element(xpath: "//table[@id='OrganizationsTable']/tbody/tr").text == 'No data available in table' }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='OrganizationsTable']/tbody/tr").text).to eq('No data available in table')
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([{ label: 'Name',               tag: 'div', value: cc_organization[:name] },
                           { label: 'GUID',               tag:   nil, value: cc_organization[:guid] },
                           { label: 'Status',             tag:   nil, value: cc_organization[:status].upcase },
                           { label: 'Created',            tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_organization[:created_at].to_datetime.rfc3339 }\")") },
                           { label: 'Updated',            tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_organization[:updated_at].to_datetime.rfc3339 }\")") },
                           { label: 'Billing Enabled',    tag:   nil, value: cc_organization[:billing_enabled].to_s },
                           { label: 'Spaces',             tag:   'a', value: '1' },
                           { label: 'Organization Roles', tag:   'a', value: '4' },
                           { label: 'Space Roles',        tag:   'a', value: '3' },
                           { label: 'Quota',              tag:   'a', value: cc_quota_definition[:name] },
                           { label: 'Domains',            tag:   'a', value: '1' },
                           { label: 'Total Routes',       tag:   'a', value: '1' },
                           { label: 'Used Routes',        tag:   nil, value: '1' },
                           { label: 'Unused Routes',      tag:   nil, value: '0' },
                           { label: 'Instances Used',     tag:   'a', value: cc_app[:instances].to_s },
                           { label: 'Services Used',      tag:   'a', value: varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['services'].length.to_s },
                           { label: 'Memory Used',        tag:   nil, value: @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_memory_in_bytes'] })").to_s },
                           { label: 'Disk Used',          tag:   nil, value: @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_disk_in_bytes'] })").to_s },
                           { label: 'CPU Used',           tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['computed_pcpu'] * 100 })").to_s },
                           { label: 'Memory Reserved',    tag:   nil, value: cc_app[:memory].to_s },
                           { label: 'Disk Reserved',      tag:   nil, value: cc_app[:disk_quota].to_s },
                           { label: 'Total Apps',         tag:   'a', value: '1' },
                           { label: 'Started Apps',       tag:   nil, value: cc_app[:state] == 'STARTED' ? '1' : '0' },
                           { label: 'Stopped Apps',       tag:   nil, value: cc_app[:state] == 'STOPPED' ? '1' : '0' },
                           { label: 'Pending Apps',       tag:   nil, value: cc_app[:package_state] == 'PENDING' ? '1' : '0' },
                           { label: 'Staged Apps',        tag:   nil, value: cc_app[:package_state] == 'STAGED'  ? '1' : '0' },
                           { label: 'Failed Apps',        tag:   nil, value: cc_app[:package_state] == 'FAILED'  ? '1' : '0' }
                          ])
          end

          it 'has spaces link' do
            check_filter_link('Organizations', 6, 'Spaces', "#{ cc_organization[:name] }/")
          end

          it 'has organization roles link' do
            check_filter_link('Organizations', 7, 'OrganizationRoles', cc_organization[:guid])
          end

          it 'has space roles link' do
            check_filter_link('Organizations', 8, 'SpaceRoles', "#{ cc_organization[:name] }/")
          end

          it 'has quotas link' do
            check_filter_link('Organizations', 9, 'Quotas', cc_quota_definition[:name])
          end

          it 'has domains link' do
            check_filter_link('Organizations', 10, 'Domains', cc_organization[:name])
          end

          it 'has routes link' do
            check_filter_link('Organizations', 11, 'Routes', "#{ cc_organization[:name] }/")
          end

          it 'has instances link' do
            check_filter_link('Organizations', 14, 'Applications', "#{ cc_organization[:name] }/")
          end

          it 'has services instances link' do
            check_filter_link('Organizations', 15, 'ServiceInstances', "#{ cc_organization[:name] }/")
          end

          it 'has applications link' do
            check_filter_link('Organizations', 21, 'Applications', "#{ cc_organization[:name] }/")
          end
        end
      end

      context 'Spaces' do
        let(:tab_id) { 'Spaces' }

        it 'has a table' do
          check_table_layout([{ columns:         @driver.find_elements(xpath: "//div[@id='SpacesTableContainer']/div/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                expected_length: 6,
                                labels:          ['', 'Routes', 'Used', 'Reserved', 'App States', 'App Package States'],
                                colspans:        %w(6 3 5 2 3 3)
                              },
                              {
                                columns:         @driver.find_elements(xpath: "//div[@id='SpacesTableContainer']/div/div[6]/div[1]/div/table/thead/tr[2]/th"),
                                expected_length: 22,
                                labels:          ['Name', 'GUID', 'Target', 'Created', 'Updated', 'Roles', 'Total', 'Used', 'Unused', 'Instances', 'Services', 'Memory', 'Disk', '% CPU', 'Memory', 'Disk', 'Total', 'Started', 'Stopped', 'Pending', 'Staged', 'Failed'],
                                colspans:        nil
                              }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='SpacesTable']/tbody/tr/td"),
                           [
                             cc_space[:name],
                             cc_space[:guid],
                             "#{ cc_organization[:name] }/#{ cc_space[:name] }",
                             @driver.execute_script("return Format.formatString(\"#{ cc_space[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_space[:updated_at].to_datetime.rfc3339 }\")"),
                             '3',
                             '1',
                             '1',
                             '0',
                             cc_app[:instances].to_s,
                             varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['services'].length.to_s,
                             @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_memory_in_bytes'] })").to_s,
                             @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_disk_in_bytes'] })").to_s,
                             @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['computed_pcpu'] * 100 })").to_s,
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
          check_allowscriptaccess_attribute('ToolTables_SpacesTable_0')
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([{ label: 'Name',            tag: 'div', value: cc_space[:name] },
                           { label: 'GUID',            tag:   nil, value: cc_space[:guid] },
                           { label: 'Organization',    tag:   'a', value: cc_organization[:name] },
                           { label: 'Created',         tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_space[:created_at].to_datetime.rfc3339 }\")") },
                           { label: 'Updated',         tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_space[:updated_at].to_datetime.rfc3339 }\")") },
                           { label: 'Roles',           tag:   'a', value: '3' },
                           { label: 'Total Routes',    tag:   nil, value: '1' },
                           { label: 'Used Routes',     tag:   nil, value: '1' },
                           { label: 'Unused Routes',   tag:   nil, value: '0' },
                           { label: 'Instances Used',  tag:   'a', value: cc_app[:instances].to_s },
                           { label: 'Services Used',   tag:   'a', value: varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['services'].length.to_s },
                           { label: 'Memory Used',     tag:   nil, value: @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_memory_in_bytes'] })").to_s },
                           { label: 'Disk Used',       tag:   nil, value: @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_disk_in_bytes'] })").to_s },
                           { label: 'CPU Used',        tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['computed_pcpu'] * 100 })").to_s },
                           { label: 'Memory Reserved', tag:   nil, value: cc_app[:memory].to_s },
                           { label: 'Disk Reserved',   tag:   nil, value: cc_app[:disk_quota].to_s },
                           { label: 'Total Apps',      tag:   'a', value: '1' },
                           { label: 'Started Apps',    tag:   nil, value: cc_app[:state] == 'STARTED' ? '1' : '0' },
                           { label: 'Stopped Apps',    tag:   nil, value: cc_app[:state] == 'STOPPED' ? '1' : '0' },
                           { label: 'Pending Apps',    tag:   nil, value: cc_app[:package_state] == 'PENDING' ? '1' : '0' },
                           { label: 'Staged Apps',     tag:   nil, value: cc_app[:package_state] == 'STAGED'  ? '1' : '0' },
                           { label: 'Failed Apps',     tag:   nil, value: cc_app[:package_state] == 'FAILED'  ? '1' : '0' }
                          ])
          end

          it 'has organizations link' do
            check_filter_link('Spaces', 2, 'Organizations', cc_organization[:guid])
          end

          it 'has space roles link' do
            check_filter_link('Spaces', 5, 'SpaceRoles', cc_space[:guid])
          end

          it 'has routes link' do
            check_filter_link('Spaces', 6, 'Routes', "#{ cc_organization[:name] }/#{ cc_space[:name] }")
          end

          it 'has instances link' do
            check_filter_link('Spaces', 9, 'Applications', "#{ cc_organization[:name] }/#{ cc_space[:name] }")
          end

          it 'has services link' do
            check_filter_link('Spaces', 10, 'ServiceInstances', "#{ cc_organization[:name] }/#{ cc_space[:name] }")
          end

          it 'has applications link' do
            check_filter_link('Spaces', 16, 'Applications', "#{ cc_organization[:name] }/#{ cc_space[:name] }")
          end
        end
      end

      context 'Applications' do
        let(:tab_id) { 'Applications' }

        it 'has a table' do
          check_table_layout([{ columns:         @driver.find_elements(xpath: "//div[@id='ApplicationsTableContainer']/div/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                expected_length: 5,
                                labels:          ['', '', 'Used', 'Reserved', ''],
                                colspans:        %w(1 11 4 2 2)
                              },
                              {
                                columns:         @driver.find_elements(xpath: "//div[@id='ApplicationsTableContainer']/div/div[6]/div[1]/div/table/thead/tr[2]/th"),
                                expected_length: 20,
                                labels:          [' ', 'Name', 'GUID', 'State', 'Package State', 'Instance State', 'Created', 'Updated', 'Started', 'URI', 'Buildpack', 'Instance', 'Services', 'Memory', 'Disk', '% CPU', 'Memory', 'Disk', 'Target', 'DEA'],
                                colspans:        nil
                              }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='ApplicationsTable']/tbody/tr/td"),
                           [
                             '',
                             cc_app[:name],
                             cc_app[:guid],
                             cc_app[:state],
                             @driver.execute_script('return Constants.STATUS__STAGED'),
                             varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['state'],
                             @driver.execute_script("return Format.formatString(\"#{ cc_app[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_app[:updated_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ Time.at(varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['state_running_timestamp']).to_datetime.rfc3339 }\")"),
                             "http://#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['application_uris'][0] }",
                             cc_app[:detected_buildpack],
                             varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['instance_index'].to_s,
                             varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['services'].length.to_s,
                             @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_memory_in_bytes'] })").to_s,
                             @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_disk_in_bytes'] })").to_s,
                             @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['computed_pcpu'] * 100 })").to_s,
                             cc_app[:memory].to_s,
                             cc_app[:disk_quota].to_s,
                             "#{ cc_organization[:name] }/#{ cc_space[:name] }",
                             nats_dea['host']
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_ApplicationsTable_4')
        end

        it 'has a checkbox in the first column' do
          inputs = @driver.find_elements(xpath: "//table[@id='ApplicationsTable']/tbody/tr/td[1]/input")
          expect(inputs.length).to eq(1)
          expect(inputs[0].attribute('value')).to eq(cc_app[:guid])
        end

        context 'manage application' do
          def manage_application(buttonIndex)
            check_first_row
            @driver.find_element(id: 'ToolTables_ApplicationsTable_' + buttonIndex.to_s).click
            check_operation_result
          end

          def check_first_row
            @driver.find_elements(xpath: "//table[@id='ApplicationsTable']/tbody/tr/td[1]/input")[0].click
          end

          def check_app_state(expect_state)
            # As the UI table will be refreshed and recreated, add a try-catch block in case the selenium stale element
            # error happens.
            Selenium::WebDriver::Wait.new(timeout: 560).until { refresh_button && @driver.find_element(xpath: "//table[@id='ApplicationsTable']/tbody/tr/td[4]").text == expect_state }
          rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            expect(@driver.find_element(xpath: "//table[@id='ApplicationsTable']/tbody/tr/td[4]").text).to eq(expect_state)
          end

          def check_operation_result
            Selenium::WebDriver::Wait.new(timeout: 60).until { @driver.find_element(id: 'ModalDialogContents').displayed? }
            expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be_true
            expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Success')
            @driver.find_element(id: 'modalDialogButton0').click
          end

          it 'has a start button' do
            expect(@driver.find_element(id: 'ToolTables_ApplicationsTable_0').text).to eq('Start')
          end

          it 'has a stop button' do
            expect(@driver.find_element(id: 'ToolTables_ApplicationsTable_1').text).to eq('Stop')
          end

          it 'has a restart button' do
            expect(@driver.find_element(id: 'ToolTables_ApplicationsTable_2').text).to eq('Restart')
          end

          it 'has a delete button' do
            expect(@driver.find_element(id: 'ToolTables_ApplicationsTable_3').text).to eq('Delete')
          end

          shared_examples 'click start button without selecting a single row' do
            it 'alerts the user to select at least one row when clicking the button' do
              @driver.find_element(id: buttonId).click

              expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be_true
              expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Error')
              expect(@driver.find_element(id: 'ModalDialogContents').text).to eq('Please select at least one row!')
              @driver.find_element(id: 'modalDialogButton0').click
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
            check_table_data(Selenium::WebDriver::Wait.new(timeout: 360).until { refresh_button && @driver.find_elements(xpath: "//table[@id='ApplicationsTable']/tbody/tr/td") },
                             [
                               '',
                               cc_app[:name],
                               cc_app[:guid],
                               '',
                               '',
                               varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['state'],
                               '',
                               '',
                               @driver.execute_script("return Format.formatString(\"#{ Time.at(varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['state_running_timestamp']).to_datetime.rfc3339 }\")"),
                               "http://#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['application_uris'][0] }",
                               '',
                               '0',
                               varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['services'].length.to_s,
                               @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_memory_in_bytes'] })").to_s,
                               @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_disk_in_bytes'] })").to_s,
                               @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['computed_pcpu'] * 100 })").to_s,
                               cc_app[:memory].to_s,
                               cc_app[:disk_quota].to_s,
                               '',
                               nats_dea['host']
                             ])
          end

          it 'deletes the selected application' do
            # delete the application
            check_first_row
            @driver.find_element(id: 'ToolTables_ApplicationsTable_3').click

            expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be_true
            expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Confirmation')
            expect(@driver.find_element(id: 'ModalDialogContents').text).to eq('Are you sure you want to delete the selected applications?')
            @driver.find_element(id: 'modalDialogButton0').click

            check_operation_result

            begin
              Selenium::WebDriver::Wait.new(timeout: 560).until do
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
            check_details([{ label: 'Name',            tag: 'div', value: cc_app[:name] },
                           { label: 'GUID',            tag:   nil, value: cc_app[:guid] },
                           { label: 'State',           tag:   nil, value: cc_app[:state] },
                           { label: 'Package State',   tag:   nil, value: cc_app[:package_state] },
                           { label: 'Instance State',  tag:   nil, value: varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['state'] },
                           { label: 'Created',         tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_app[:created_at].to_datetime.rfc3339 }\")") },
                           { label: 'Updated',         tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_app[:updated_at].to_datetime.rfc3339 }\")") },
                           { label: 'Started',         tag:   nil, value: @driver.execute_script("return Format.formatDateNumber(#{ (varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['state_running_timestamp'] * 1000) })") },
                           { label: 'URI',             tag:   'a', value: "http://#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['application_uris'][0] }" },
                           { label: 'Buildpack',       tag:   nil, value: cc_app[:detected_buildpack] },
                           { label: 'Command',         tag:   nil, value: cc_app[:command] },
                           { label: 'Instance Index',  tag:   nil, value: varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['instance_index'].to_s },
                           { label: 'Droplet Hash',    tag:   nil, value: varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['droplet_sha1'].to_s },
                           { label: 'Services Used',   tag:   nil, value: varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['services'].length.to_s },
                           { label: 'Memory Used',     tag:   nil, value: @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_memory_in_bytes'] })").to_s },
                           { label: 'Disk Used',       tag:   nil, value: @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_disk_in_bytes'] })").to_s },
                           { label: 'CPU Used',        tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['computed_pcpu'] * 100 })").to_s },
                           { label: 'Memory Reserved', tag:   nil, value: cc_app[:memory].to_s },
                           { label: 'Disk Reserved',   tag:   nil, value: cc_app[:disk_quota].to_s },
                           { label: 'Space',           tag:   'a', value: cc_space[:name] },
                           { label: 'Organization',    tag:   'a', value: cc_organization[:name] },
                           { label: 'DEA',             tag:   'a', value: nats_dea['host'] }
                          ])
          end

          it 'has services' do
            expect(@driver.find_element(id: 'ApplicationsServicesDetailsLabel').displayed?).to be_true

            check_table_headers(columns:         @driver.find_elements(xpath: "//div[@id='ApplicationsServicesTableContainer']/div[2]/div[5]/div[1]/div/table/thead/tr/th"),
                                expected_length: 5,
                                labels:          ['Instance Name', 'Provider', 'Service Name', 'Version', 'Plan Name'],
                                colspans:        nil)

            check_table_data(@driver.find_elements(xpath: "//table[@id='ApplicationsServicesTable']/tbody/tr/td"),
                             [
                               varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['services'][0]['name'],
                               varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['services'][0]['provider'],
                               varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['services'][0]['vendor'],
                               varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['services'][0]['version'],
                               varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['services'][0]['plan']
                             ])
          end

          it 'services subtable has allowscriptaccess property set to sameDomain' do
            check_allowscriptaccess_attribute('ToolTables_ApplicationsServicesTable_0')
          end

          it 'has spaces link' do
            check_filter_link('Applications', 19, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('Applications', 20, 'Organizations', cc_organization[:guid])
          end

          it 'has DEAs link' do
            check_filter_link('Applications', 21, 'DEAs', nats_dea['host'])
          end
        end
      end

      context 'Routes' do
        let(:tab_id) { 'Routes' }

        it 'has a table' do
          check_table_layout([{ columns:         @driver.find_elements(xpath: "//div[@id='RoutesTableContainer']/div/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                expected_length: 8,
                                labels:          [' ', 'Host', 'GUID', 'Domain', 'Created', 'Updated', 'Target', 'Application'],
                                colspans:        nil
                              }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='RoutesTable']/tbody/tr/td"),
                           [
                             '',
                             cc_route[:host],
                             cc_route[:guid],
                             cc_domain[:name],
                             @driver.execute_script("return Format.formatString(\"#{ cc_route[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_route[:updated_at].to_datetime.rfc3339 }\")"),
                             "#{ cc_organization[:name] }/#{ cc_space[:name] }",
                             cc_app[:name]
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_RoutesTable_1')
        end

        it 'has a checkbox in the first column' do
          inputs = @driver.find_elements(xpath: "//table[@id='RoutesTable']/tbody/tr/td[1]/input")
          expect(inputs.length).to eq(1)
          expect(inputs[0].attribute('value')).to eq(cc_route[:guid])
        end

        context 'manage routes' do
          def check_first_row
            @driver.find_elements(xpath: "//table[@id='RoutesTable']/tbody/tr/td[1]/input")[0].click
          end

          it 'has a delete button' do
            expect(@driver.find_element(id: 'ToolTables_RoutesTable_0').text).to eq('Delete')
          end

          it 'alerts the user to select at least one row when clicking the delete button' do
            @driver.find_element(id: 'ToolTables_RoutesTable_0').click

            expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be_true
            expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Error')
            expect(@driver.find_element(id: 'ModalDialogContents').text).to eq('Please select at least one row!')
            @driver.find_element(id: 'modalDialogButton0').click
          end

          it 'deletes the selected route' do
            # delete the route
            check_first_row
            @driver.find_element(id: 'ToolTables_RoutesTable_0').click

            expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be_true
            expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Confirmation')
            expect(@driver.find_element(id: 'ModalDialogContents').text).to eq('Are you sure you want to delete the selected routes?')
            @driver.find_element(id: 'modalDialogButton0').click

            Selenium::WebDriver::Wait.new(timeout: 60).until { @driver.find_element(id: 'ModalDialogContents').displayed? }
            expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be_true
            expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Success')
            @driver.find_element(id: 'modalDialogButton0').click

            begin
              Selenium::WebDriver::Wait.new(timeout: 240).until { refresh_button && @driver.find_element(xpath: "//table[@id='RoutesTable']/tbody/tr").text == 'No data available in table' }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='RoutesTable']/tbody/tr").text).to eq('No data available in table')
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([{ label: 'Host',         tag: nil, value: cc_route[:host] },
                           { label: 'GUID',         tag: nil, value: cc_route[:guid] },
                           { label: 'Domain',       tag: 'a', value: cc_domain[:name] },
                           { label: 'Created',      tag: nil, value: Selenium::WebDriver::Wait.new(timeout: 60).until { @driver.execute_script("return Format.formatDateString(\"#{ cc_route[:created_at].to_datetime.rfc3339 }\")") } },
                           { label: 'Updated',      tag: nil, value: Selenium::WebDriver::Wait.new(timeout: 60).until { @driver.execute_script("return Format.formatDateString(\"#{ cc_route[:updated_at].to_datetime.rfc3339 }\")") } },
                           { label: 'Applications', tag: 'a', value: '1' },
                           { label: 'Space',        tag: 'a', value: cc_space[:name] },
                           { label: 'Organization', tag: 'a', value: cc_organization[:name] }
                          ])
          end

          it 'has domains link' do
            check_filter_link('Routes', 2, 'Domains', cc_domain[:guid])
          end

          it 'has applications link' do
            check_filter_link('Routes', 5, 'Applications', "#{ cc_route[:host] }.#{ cc_domain[:name] }")
          end

          it 'has spaces link' do
            check_filter_link('Routes', 6, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('Routes', 7, 'Organizations', cc_organization[:guid])
          end
        end
      end

      context 'Service Instances' do
        let(:tab_id) { 'ServiceInstances' }

        it 'has a table' do
          check_table_layout([{ columns:         @driver.find_elements(xpath: "//div[@id='ServiceInstancesTableContainer']/div/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                expected_length: 5,
                                labels:          ['Service Instance', 'Service Plan', 'Service', 'Service Broker', ''],
                                colspans:        %w(5 7 8 4 1)
                              },
                              {
                                columns:         @driver.find_elements(xpath: "//div[@id='ServiceInstancesTableContainer']/div/div[6]/div[1]/div/table/thead/tr[2]/th"),
                                expected_length: 25,
                                labels:          %w(Name GUID Created Updated Bindings Name GUID Created Updated Active Public Free Provider Label GUID Version Created Updated Active Bindable Name GUID Created Updated Target),
                                colspans:        nil
                              }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='ServiceInstancesTable']/tbody/tr/td"),
                           [
                             cc_service_instance[:name],
                             cc_service_instance[:guid],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_instance[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_instance[:updated_at].to_datetime.rfc3339 }\")"),
                             '1',
                             cc_service_plan[:name],
                             cc_service_plan[:guid],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_plan[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_plan[:updated_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatBoolean(\"#{ cc_service_plan[:active] }\")"),
                             @driver.execute_script("return Format.formatBoolean(\"#{ cc_service_plan[:public] }\")"),
                             @driver.execute_script("return Format.formatBoolean(\"#{ cc_service_plan[:free] }\")"),
                             cc_service[:provider],
                             cc_service[:label],
                             cc_service[:guid],
                             cc_service[:version],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service[:updated_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatBoolean(\"#{ cc_service[:active] }\")"),
                             @driver.execute_script("return Format.formatBoolean(\"#{ cc_service[:bindable] }\")"),
                             cc_service_broker[:name],
                             cc_service_broker[:guid],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_broker[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_broker[:updated_at].to_datetime.rfc3339 }\")"),
                             "#{ cc_organization[:name] }/#{ cc_space[:name] }"
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_ServiceInstancesTable_0')
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([{ label: 'Service Instance Name',          tag: 'div', value: cc_service_instance[:name] },
                           { label: 'Service Instance GUID',          tag:   nil, value: cc_service_instance[:guid] },
                           { label: 'Service Instance Created',       tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service_instance[:created_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Instance Updated',       tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service_instance[:updated_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Instance Dashboard URL', tag:   nil, value: cc_service_instance[:dashboard_url] },
                           { label: 'Service Bindings',               tag:   'a', value: '1' },
                           { label: 'Service Plan Name',              tag:   'a', value: cc_service_plan[:name] },
                           { label: 'Service Plan GUID',              tag:   nil, value: cc_service_plan[:guid] },
                           { label: 'Service Plan Created',           tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service_plan[:created_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Plan Updated',           tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service_plan[:updated_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Plan Active',            tag:   nil, value: @driver.execute_script("return Format.formatBoolean(\"#{ cc_service_plan[:active] }\")") },
                           { label: 'Service Plan Public',            tag:   nil, value: @driver.execute_script("return Format.formatBoolean(\"#{ cc_service_plan[:public] }\")") },
                           { label: 'Service Plan Free',              tag:   nil, value: @driver.execute_script("return Format.formatBoolean(\"#{ cc_service_plan[:free] }\")") },
                           { label: 'Service Provider',               tag:   nil, value: cc_service[:provider] },
                           { label: 'Service Label',                  tag:   'a', value: cc_service[:label] },
                           { label: 'Service GUID',                   tag:   nil, value: cc_service[:guid] },
                           { label: 'Service Version',                tag:   nil, value: cc_service[:version] },
                           { label: 'Service Created',                tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service[:created_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Updated',                tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service[:updated_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Active',                 tag:   nil, value: @driver.execute_script("return Format.formatBoolean(\"#{ cc_service[:active] }\")") },
                           { label: 'Service Bindable',               tag:   nil, value: @driver.execute_script("return Format.formatBoolean(\"#{ cc_service[:bindable] }\")") },
                           { label: 'Service Broker Name',            tag:   'a', value: cc_service_broker[:name] },
                           { label: 'Service Broker GUID',            tag:   nil, value: cc_service_broker[:guid] },
                           { label: 'Service Broker Created',         tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service_broker[:created_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Broker Updated',         tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service_broker[:updated_at].to_datetime.rfc3339 }\")") },
                           { label: 'Space',                          tag:   'a', value: cc_space[:name] },
                           { label: 'Organization',                   tag:   'a', value: cc_organization[:name] }
                          ])
          end

          it 'has service bindings link' do
            check_filter_link('ServiceInstances', 5, 'ServiceBindings', cc_service_instance[:guid])
          end

          it 'has service plans link' do
            check_filter_link('ServiceInstances', 6, 'ServicePlans', cc_service_plan[:guid])
          end

          it 'has services link' do
            check_filter_link('ServiceInstances', 14, 'Services', cc_service[:guid])
          end

          it 'has service brokers link' do
            check_filter_link('ServiceInstances', 21, 'ServiceBrokers', cc_service_broker[:guid])
          end

          it 'has spaces link' do
            check_filter_link('ServiceInstances', 25, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('ServiceInstances', 26, 'Organizations', cc_organization[:guid])
          end
        end
      end

      context 'Service Bindings' do
        let(:tab_id) { 'ServiceBindings' }

        it 'has a table' do
          check_table_layout([{ columns:         @driver.find_elements(xpath: "//div[@id='ServiceBindingsTableContainer']/div/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                expected_length: 7,
                                labels:          ['Service Binding', 'Application', 'Service Instance', 'Service Plan', 'Service', 'Service Broker', ''],
                                colspans:        %w(3 2 4 7 7 4 1)
                              },
                              {
                                columns:         @driver.find_elements(xpath: "//div[@id='ServiceBindingsTableContainer']/div/div[6]/div[1]/div/table/thead/tr[2]/th"),
                                expected_length: 28,
                                labels:          %w(GUID Created Updated Name GUID Name GUID Created Updated Name GUID Created Updated Active Public Free Provider Label GUID Version Created Updated Active Name GUID Created Updated Target),
                                colspans:        nil
                              }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='ServiceBindingsTable']/tbody/tr/td"),
                           [
                             cc_service_binding[:guid],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_binding[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_binding[:updated_at].to_datetime.rfc3339 }\")"),
                             cc_app[:name],
                             cc_app[:guid],
                             cc_service_instance[:name],
                             cc_service_instance[:guid],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_instance[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_instance[:updated_at].to_datetime.rfc3339 }\")"),
                             cc_service_plan[:name],
                             cc_service_plan[:guid],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_plan[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_plan[:updated_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatBoolean(\"#{ cc_service_plan[:active] }\")"),
                             @driver.execute_script("return Format.formatBoolean(\"#{ cc_service_plan[:public] }\")"),
                             @driver.execute_script("return Format.formatBoolean(\"#{ cc_service_plan[:free] }\")"),
                             cc_service[:provider],
                             cc_service[:label],
                             cc_service[:guid],
                             cc_service[:version],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service[:updated_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatBoolean(\"#{ cc_service[:active] }\")"),
                             cc_service_broker[:name],
                             cc_service_broker[:guid],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_broker[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_broker[:updated_at].to_datetime.rfc3339 }\")"),
                             "#{ cc_organization[:name] }/#{ cc_space[:name] }"
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_ServiceBindingsTable_0')
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([{ label: 'Service Binding GUID',           tag: 'div', value: cc_service_binding[:guid] },
                           { label: 'Service Binding Created',        tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service_binding[:created_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Binding Updated',        tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service_binding[:updated_at].to_datetime.rfc3339 }\")") },
                           { label: 'Application Name',               tag:   'a', value: cc_app[:name] },
                           { label: 'Application GUID',               tag:   nil, value: cc_app[:guid] },
                           { label: 'Service Instance Name',          tag:   'a', value: cc_service_instance[:name] },
                           { label: 'Service Instance GUID',          tag:   nil, value: cc_service_instance[:guid] },
                           { label: 'Service Instance Created',       tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service_instance[:created_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Instance Updated',       tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service_instance[:updated_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Plan Name',              tag:   'a', value: cc_service_plan[:name] },
                           { label: 'Service Plan GUID',              tag:   nil, value: cc_service_plan[:guid] },
                           { label: 'Service Plan Created',           tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service_plan[:created_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Plan Updated',           tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service_plan[:updated_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Plan Active',            tag:   nil, value: @driver.execute_script("return Format.formatBoolean(\"#{ cc_service_plan[:active] }\")") },
                           { label: 'Service Plan Public',            tag:   nil, value: @driver.execute_script("return Format.formatBoolean(\"#{ cc_service_plan[:public] }\")") },
                           { label: 'Service Plan Free',              tag:   nil, value: @driver.execute_script("return Format.formatBoolean(\"#{ cc_service_plan[:free] }\")") },
                           { label: 'Service Provider',               tag:   nil, value: cc_service[:provider] },
                           { label: 'Service Label',                  tag:   'a', value: cc_service[:label] },
                           { label: 'Service GUID',                   tag:   nil, value: cc_service[:guid] },
                           { label: 'Service Version',                tag:   nil, value: cc_service[:version] },
                           { label: 'Service Created',                tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service[:created_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Updated',                tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service[:updated_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Active',                 tag:   nil, value: @driver.execute_script("return Format.formatBoolean(\"#{ cc_service[:active] }\")") },
                           { label: 'Service Broker Name',            tag:   'a', value: cc_service_broker[:name] },
                           { label: 'Service Broker GUID',            tag:   nil, value: cc_service_broker[:guid] },
                           { label: 'Service Broker Created',         tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service_broker[:created_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Broker Updated',         tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service_broker[:updated_at].to_datetime.rfc3339 }\")") },
                           { label: 'Space',                          tag:   'a', value: cc_space[:name] },
                           { label: 'Organization',                   tag:   'a', value: cc_organization[:name] }
                          ])
          end

          it 'has application link' do
            check_filter_link('ServiceBindings', 3, 'Applications', cc_app[:guid])
          end

          it 'has service instances link' do
            check_filter_link('ServiceBindings', 5, 'ServiceInstances', cc_service_instance[:guid])
          end

          it 'has service plans link' do
            check_filter_link('ServiceBindings', 9, 'ServicePlans', cc_service_plan[:guid])
          end

          it 'has services link' do
            check_filter_link('ServiceBindings', 17, 'Services', cc_service[:guid])
          end

          it 'has service brokers link' do
            check_filter_link('ServiceBindings', 23, 'ServiceBrokers', cc_service_broker[:guid])
          end

          it 'has spaces link' do
            check_filter_link('ServiceBindings', 27, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('ServiceBindings', 28, 'Organizations', cc_organization[:guid])
          end
        end
      end

      context 'Organization Roles' do
        let(:tab_id) { 'OrganizationRoles' }

        it 'has a table' do
          check_table_layout([{ columns:         @driver.find_elements(xpath: "//div[@id='OrganizationRolesTableContainer']/div/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                expected_length: 4,
                                labels:          ['', 'Organization', 'User', ''],
                                colspans:        %w(1 2 2 1)
                              },
                              { columns:         @driver.find_elements(xpath: "//div[@id='OrganizationRolesTableContainer']/div/div[6]/div[1]/div/table/thead/tr[2]/th"),
                                expected_length: 6,
                                labels:          [' ', 'Name', 'GUID', 'Name', 'GUID', 'Role'],
                                colspans:        nil
                              }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='OrganizationRolesTable']/tbody/tr/td"),
                           [
                             '',
                             cc_organization[:name],
                             cc_organization[:guid],
                             uaa_user[:username],
                             uaa_user[:id],
                             'Auditor'
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_OrganizationRolesTable_1')
        end

        context 'manage organization roles' do
          def check_first_row
            @driver.find_elements(xpath: "//table[@id='OrganizationRolesTable']/tbody/tr/td[1]/input")[0].click
          end

          it 'has a delete button' do
            expect(@driver.find_element(id: 'ToolTables_OrganizationRolesTable_0').text).to eq('Delete')
          end

          it 'alerts the user to select at least one row when clicking the delete button' do
            @driver.find_element(id: 'ToolTables_OrganizationRolesTable_0').click

            expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be_true
            expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Error')
            expect(@driver.find_element(id: 'ModalDialogContents').text).to eq('Please select at least one row!')
            @driver.find_element(id: 'modalDialogButton0').click
          end

          it 'deletes the selected organization role' do
            check_first_row
            @driver.find_element(id: 'ToolTables_OrganizationRolesTable_0').click

            expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be_true
            expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Confirmation')
            expect(@driver.find_element(id: 'ModalDialogContents').text).to eq('Are you sure you want to delete the selected organization roles?')
            @driver.find_element(id: 'modalDialogButton0').click

            Selenium::WebDriver::Wait.new(timeout: 60).until { @driver.find_element(id: 'ModalDialogContents').displayed? }
            expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be_true
            expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Success')
            @driver.find_element(id: 'modalDialogButton0').click
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([{ label: 'Organization',      tag: 'div', value: cc_organization[:name] },
                           { label: 'Organization GUID', tag:   nil, value: cc_organization[:guid] },
                           { label: 'User',              tag:   'a', value: uaa_user[:username] },
                           { label: 'User GUID',         tag:   nil, value: uaa_user[:id] },
                           { label: 'Role',              tag:   nil, value: 'Auditor' }
                          ])
          end

          it 'has organizations link' do
            check_filter_link('OrganizationRoles', 0, 'Organizations', cc_organization[:guid])
          end

          it 'has users link' do
            check_filter_link('OrganizationRoles', 2, 'Users', uaa_user[:id])
          end
        end
      end

      context 'Space Roles' do
        let(:tab_id) { 'SpaceRoles' }

        it 'has a table' do
          check_table_layout([{ columns:         @driver.find_elements(xpath: "//div[@id='SpaceRolesTableContainer']/div/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                expected_length: 4,
                                labels:          ['', 'Space', 'User', ''],
                                colspans:        %w(1 3 2 1)
                              },
                              { columns:         @driver.find_elements(xpath: "//div[@id='SpaceRolesTableContainer']/div/div[6]/div[1]/div/table/thead/tr[2]/th"),
                                expected_length: 7,
                                labels:          [' ', 'Name', 'GUID', 'Target', 'Name', 'GUID', 'Role'],
                                colspans:        nil
                                          }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='SpaceRolesTable']/tbody/tr/td"),
                           [
                             '',
                             cc_space[:name],
                             cc_space[:guid],
                             "#{ cc_organization[:name] }/#{ cc_space[:name] }",
                             uaa_user[:username],
                             uaa_user[:id],
                             'Auditor'
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_SpaceRolesTable_1')
        end

        context 'manage space roles' do
          def check_first_row
            @driver.find_elements(xpath: "//table[@id='SpaceRolesTable']/tbody/tr/td[1]/input")[0].click
          end

          it 'has a delete button' do
            expect(@driver.find_element(id: 'ToolTables_SpaceRolesTable_0').text).to eq('Delete')
          end

          it 'alerts the user to select at least one row when clicking the delete button' do
            @driver.find_element(id: 'ToolTables_SpaceRolesTable_0').click

            expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be_true
            expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Error')
            expect(@driver.find_element(id: 'ModalDialogContents').text).to eq('Please select at least one row!')
            @driver.find_element(id: 'modalDialogButton0').click
          end

          it 'deletes the selected space role' do
            check_first_row
            @driver.find_element(id: 'ToolTables_SpaceRolesTable_0').click

            expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be_true
            expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Confirmation')
            expect(@driver.find_element(id: 'ModalDialogContents').text).to eq('Are you sure you want to delete the selected space roles?')
            @driver.find_element(id: 'modalDialogButton0').click

            Selenium::WebDriver::Wait.new(timeout: 60).until { @driver.find_element(id: 'ModalDialogContents').displayed? }
            expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be_true
            expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Success')
            @driver.find_element(id: 'modalDialogButton0').click
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([{ label: 'Space',        tag: 'div', value: cc_space[:name] },
                           { label: 'Space GUID',   tag:   nil, value: cc_space[:guid] },
                           { label: 'Organization', tag:   'a', value: cc_organization[:name] },
                           { label: 'User',         tag:   'a', value: uaa_user[:username] },
                           { label: 'User GUID',    tag:   nil, value: uaa_user[:id] },
                           { label: 'Role',         tag:   nil, value: 'Auditor' }
                          ])
          end

          it 'has spaces link' do
            check_filter_link('SpaceRoles', 0, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('SpaceRoles', 2, 'Organizations', cc_organization[:guid])
          end

          it 'has users link' do
            check_filter_link('SpaceRoles', 3, 'Users', uaa_user[:id])
          end
        end
      end

      context 'Clients' do
        let(:tab_id) { 'Clients' }

        it 'has a table' do
          check_table_layout([{ columns:         @driver.find_elements(xpath: "//div[@id='ClientsTableContainer']/div/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                expected_length: 6,
                                labels:          ['Identifier', 'Scopes', 'Authorized Grant Types', "Redirect URI's", 'Authorities', 'Auto Approve'],
                                colspans:        nil
                              }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='ClientsTable']/tbody/tr/td"),
                           [
                             uaa_client[:client_id],
                             uaa_client[:scope],
                             uaa_client[:authorized_grant_types],
                             uaa_client[:web_server_redirect_uri],
                             uaa_client[:authorities],
                             uaa_client_autoapprove.to_s
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_ClientsTable_0')
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([{ label: 'Identifier',             tag: 'div', value: uaa_client[:client_id] },
                           { label: 'Scope',                  tag:   nil, value: uaa_client[:scope] },
                           { label: 'Authorized Grant Type',  tag:   nil, value: uaa_client[:authorized_grant_types] },
                           { label: 'Redirect URI',           tag:   nil, value: uaa_client[:web_server_redirect_uri] },
                           { label: 'Authority',              tag:   nil, value: uaa_client[:authorities] },
                           { label: 'Auto Approve',           tag:   nil, value: uaa_client_autoapprove.to_s },
                           { label: 'Additional Information', tag:   nil, value: uaa_client[:additional_information] }
                          ])
          end
        end
      end

      context 'Users' do
        let(:tab_id) { 'Users' }

        it 'has a table' do
          check_table_layout([{ columns:         @driver.find_elements(xpath: "//div[@id='UsersTableContainer']/div/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                expected_length: 3,
                                labels:          ['', 'Organization Roles', 'Space Roles', ''],
                                colspans:        %w(10 5 4)
                              },
                              {
                                columns:         @driver.find_elements(xpath: "//div[@id='UsersTableContainer']/div/div[6]/div[1]/div/table/thead/tr[2]/th"),
                                expected_length: 19,
                                labels:          ['Username', 'GUID', 'Created', 'Updated', 'Email', 'Family Name', 'Given Name', 'Active', 'Version', 'Groups', 'Total', 'Auditor', 'Billing Manager', 'Manager', 'User', 'Total', 'Auditor', 'Developer', 'Manager'],
                                colspans:        nil
                              }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='UsersTable']/tbody/tr/td"),
                           [
                             uaa_user[:username],
                             uaa_user[:id],
                             @driver.execute_script("return Format.formatString(\"#{ uaa_user[:created].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ uaa_user[:lastmodified].to_datetime.rfc3339 }\")"),
                             uaa_user[:email],
                             uaa_user[:familyname],
                             uaa_user[:givenname],
                             uaa_user[:active].to_s,
                             uaa_user[:version].to_s,
                             uaa_group[:displayname],
                             '4',
                             '1',
                             '1',
                             '1',
                             '1',
                             '3',
                             '1',
                             '1',
                             '1'
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_UsersTable_0')
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([{ label: 'Username',                           tag: 'div', value: uaa_user[:username] },
                           { label: 'GUID',                               tag:   nil, value: uaa_user[:id] },
                           { label: 'Created',                            tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ uaa_user[:created].to_datetime.rfc3339 }\")") },
                           { label: 'Updated',                            tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ uaa_user[:lastmodified].to_datetime.rfc3339 }\")") },
                           { label: 'Email',                              tag:   'a', value: "mailto:#{ uaa_user[:email] }" },
                           { label: 'Family Name',                        tag:   nil, value: uaa_user[:familyname] },
                           { label: 'Given Name',                         tag:   nil, value: uaa_user[:givenname] },
                           { label: 'Active',                             tag:   nil, value: uaa_user[:active].to_s },
                           { label: 'Version',                            tag:   nil, value: uaa_user[:version].to_s },
                           { label: 'Group',                              tag:   nil, value: uaa_group[:displayname] },
                           { label: 'Organization Total Roles',           tag:   'a', value: '4' },
                           { label: 'Organization Auditor Roles',         tag:   nil, value: '1' },
                           { label: 'Organization Billing Manager Roles', tag:   nil, value: '1' },
                           { label: 'Organization Manager Roles',         tag:   nil, value: '1' },
                           { label: 'Organization User Roles',            tag:   nil, value: '1' },
                           { label: 'Space Total Roles',                  tag:   'a', value: '3' },
                           { label: 'Space Auditor Roles',                tag:   nil, value: '1' },
                           { label: 'Space Developer Roles',              tag:   nil, value: '1' },
                           { label: 'Space Manager Roles',                tag:   nil, value: '1' }
                          ])
          end

          it 'has organization roles link' do
            check_filter_link('Users', 10, 'OrganizationRoles', uaa_user[:id])
          end

          it 'has space roles link' do
            check_filter_link('Users', 15, 'SpaceRoles', uaa_user[:id])
          end
        end
      end

      context 'Domains' do
        let(:tab_id) { 'Domains' }

        it 'has a table' do
          check_table_layout([{ columns:         @driver.find_elements(xpath: "//div[@id='DomainsTableContainer']/div/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                expected_length: 7,
                                labels:          ['Name', 'GUID', 'Created', 'Updated', 'Owning Organization', 'Private Shared Organizations', 'Routes'],
                                colspans:        nil
                              }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='DomainsTable']/tbody/tr/td"),
                           [
                             cc_domain[:name],
                             cc_domain[:guid],
                             @driver.execute_script("return Format.formatString(\"#{ cc_domain[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_domain[:updated_at].to_datetime.rfc3339 }\")"),
                             cc_organization[:name],
                             '1',
                             '1'
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_DomainsTable_0')
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([{ label: 'Name',                tag: 'div', value: cc_domain[:name] },
                           { label: 'GUID',                tag:   nil, value: cc_domain[:guid] },
                           { label: 'Created',             tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_domain[:created_at].to_datetime.rfc3339 }\")") },
                           { label: 'Updated',             tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_domain[:updated_at].to_datetime.rfc3339 }\")") },
                           { label: 'Owning Organization', tag:   'a', value: cc_organization[:name] },
                           { label: 'Routes',              tag:   'a', value: '1' }
                          ])
          end

          it 'has private shared organizations' do
            expect(@driver.find_element(id: 'DomainsOrganizationsDetailsLabel').displayed?).to be_true

            check_table_headers(columns:         @driver.find_elements(xpath: "//div[@id='DomainsOrganizationsTableContainer']/div[2]/div[5]/div[1]/div/table/thead/tr/th"),
                                expected_length: 2,
                                labels:          %w(Organization GUID),
                                colspans:        nil)

            check_table_data(@driver.find_elements(xpath: "//table[@id='DomainsOrganizationsTable']/tbody/tr/td"),
                             [
                               cc_organization[:name],
                               cc_organization[:guid]
                             ])
          end

          it 'private shared organizations subtable has allowscriptaccess property set to sameDomain' do
            check_allowscriptaccess_attribute('ToolTables_DomainsOrganizationsTable_0')
          end

          it 'has organizations link' do
            check_filter_link('Domains', 4, 'Organizations', cc_organization[:guid])
          end

          it 'has routes link' do
            check_filter_link('Domains', 5, 'Routes', cc_domain[:name])
          end
        end
      end

      context 'Quotas' do
        let(:tab_id) { 'Quotas' }

        it 'has a table' do
          check_table_layout([{ columns:         @driver.find_elements(xpath: "//div[@id='QuotasTableContainer']/div/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                expected_length: 10,
                                labels:          ['Name', 'GUID', 'Created', 'Updated', 'Total Services', 'Total Routes', 'Memory Limit', 'Instance Memory Limit', 'Non-Basic Services Allowed', 'Organizations'],
                                colspans:        nil
                              }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='QuotasTable']/tbody/tr/td"),
                           [
                             cc_quota_definition[:name],
                             cc_quota_definition[:guid],
                             @driver.execute_script("return Format.formatString(\"#{ cc_quota_definition[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_quota_definition[:updated_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatNumber(\"#{ cc_quota_definition[:total_services] }\")"),
                             @driver.execute_script("return Format.formatNumber(\"#{ cc_quota_definition[:total_routes] }\")"),
                             @driver.execute_script("return Format.formatNumber(\"#{ cc_quota_definition[:memory_limit] }\")"),
                             @driver.execute_script("return Format.formatNumber(\"#{ cc_quota_definition[:instance_memory_limit] }\")"),
                             cc_quota_definition[:non_basic_services_allowed].to_s,
                             '1'
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_QuotasTable_0')
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([{ label: 'Name',                       tag: 'div', value: cc_quota_definition[:name] },
                           { label: 'GUID',                       tag:   nil, value: cc_quota_definition[:guid] },
                           { label: 'Created',                    tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_quota_definition[:created_at].to_datetime.rfc3339 }\")") },
                           { label: 'Updated',                    tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_quota_definition[:updated_at].to_datetime.rfc3339 }\")") },
                           { label: 'Total Services',             tag:   nil, value: @driver.execute_script("return Format.formatNumber(\"#{ cc_quota_definition[:total_services] }\")") },
                           { label: 'Total Routes',               tag:   nil, value: @driver.execute_script("return Format.formatNumber(\"#{ cc_quota_definition[:total_routes] }\")") },
                           { label: 'Memory Limit',               tag:   nil, value: @driver.execute_script("return Format.formatNumber(\"#{ cc_quota_definition[:memory_limit] }\")") },
                           { label: 'Instance Memory Limit',      tag:   nil, value: @driver.execute_script("return Format.formatNumber(\"#{ cc_quota_definition[:instance_memory_limit] }\")") },
                           { label: 'Non-Basic Services Allowed', tag:   nil, value: cc_quota_definition[:non_basic_services_allowed].to_s },
                           { label: 'Organizations',              tag:   'a', value: '1' }
                          ])
          end

          it 'has organizations link' do
            check_filter_link('Quotas', 9, 'Organizations', cc_quota_definition[:name])
          end
        end
      end

      context 'Service Brokers' do
        let(:tab_id) { 'ServiceBrokers' }

        it 'has a table' do
          check_table_layout([{ columns:         @driver.find_elements(xpath: "//div[@id='ServiceBrokersTable_wrapper']/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                expected_length: 8,
                                labels:          ['Name', 'GUID', 'Created', 'Updated', 'Services', 'Service Plans', 'Service Instances', 'Service Bindings'],
                                colspans:        nil
                              }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='ServiceBrokersTable']/tbody/tr/td"),
                           [
                             cc_service_broker[:name],
                             cc_service_broker[:guid],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_broker[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_broker[:updated_at].to_datetime.rfc3339 }\")"),
                             '1',
                             '1',
                             '1',
                             '1'
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_ServiceBrokersTable_0')
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([{ label: 'Service Broker Name',          tag: 'div', value: cc_service_broker[:name] },
                           { label: 'Service Broker GUID',          tag:   nil, value: cc_service_broker[:guid] },
                           { label: 'Service Broker Created',       tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service_broker[:created_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Broker Updated',       tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service_broker[:updated_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Broker Auth Username', tag:   nil, value: cc_service_broker[:auth_username] },
                           { label: 'Service Broker Broker URL',    tag:   nil, value: cc_service_broker[:broker_url] },
                           { label: 'Services',                     tag:   'a', value: '1' },
                           { label: 'Service Plans',                tag:   'a', value: '1' },
                           { label: 'Service Instances',            tag:   'a', value: '1' },
                           { label: 'Service Bindings',             tag:   'a', value: '1' }
                          ])
          end

          it 'has services link' do
            check_filter_link('ServiceBrokers', 6, 'Services', cc_service_broker[:guid])
          end

          it 'has service plans link' do
            check_filter_link('ServiceBrokers', 7, 'ServicePlans', cc_service_broker[:guid])
          end

          it 'has service instances link' do
            check_filter_link('ServiceBrokers', 8, 'ServiceInstances', cc_service_broker[:guid])
          end

          it 'has service bindings link' do
            check_filter_link('ServiceBrokers', 9, 'ServiceBindings', cc_service_broker[:guid])
          end
        end
      end

      context 'Services' do
        let(:tab_id) { 'Services' }

        it 'has a table' do
          check_table_layout([{ columns:         @driver.find_elements(xpath: "//div[@id='ServicesTable_wrapper']/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                expected_length: 2,
                                labels:          ['Service', 'Service Broker'],
                                colspans:        %w(12 4)
                              },
                              {
                                columns:         @driver.find_elements(xpath: "//div[@id='ServicesTable_wrapper']/div[6]/div[1]/div/table/thead/tr[2]/th"),
                                expected_length: 16,
                                labels:          ['Provider', 'Label', 'GUID', 'Version', 'Created', 'Updated', 'Active', 'Bindable', 'Plan Updateable', 'Service Plans', 'Service Instances', 'Service Bindings', 'Name', 'GUID', 'Created', 'Updated'],
                                colspans:        nil
                              }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='ServicesTable']/tbody/tr/td"),
                           [
                             cc_service[:provider],
                             cc_service[:label],
                             cc_service[:guid],
                             cc_service[:version],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service[:updated_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatBoolean(\"#{ cc_service[:active] }\")"),
                             @driver.execute_script("return Format.formatBoolean(\"#{ cc_service[:bindable] }\")"),
                             @driver.execute_script("return Format.formatBoolean(\"#{ cc_service[:plan_updateable] }\")"),
                             '1',
                             '1',
                             '1',
                             cc_service_broker[:name],
                             cc_service_broker[:guid],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_broker[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_broker[:updated_at].to_datetime.rfc3339 }\")")
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_ServicesTable_0')
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            service_tags_json = JSON.parse(cc_service[:tags])
            service_extra_json = JSON.parse(cc_service[:extra])
            check_details([{ label: 'Service Provider',              tag:   nil, value: cc_service[:provider] },
                           { label: 'Service Label',                 tag: 'div', value: cc_service[:label] },
                           { label: 'Service GUID',                  tag:   nil, value: cc_service[:guid] },
                           { label: 'Service Version',               tag:   nil, value: cc_service[:version] },
                           { label: 'Service Created',               tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service[:created_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Updated',               tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service[:updated_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Active',                tag:   nil, value: @driver.execute_script("return Format.formatBoolean(\"#{ cc_service[:active] }\")") },
                           { label: 'Service Bindable',              tag:   nil, value: @driver.execute_script("return Format.formatBoolean(\"#{ cc_service[:bindable] }\")") },
                           { label: 'Service Plan Updateable',       tag:   nil, value: @driver.execute_script("return Format.formatBoolean(\"#{ cc_service[:plan_updateable] }\")") },
                           { label: 'Service Description',           tag:   nil, value: cc_service[:description] },
                           { label: 'Service Unique ID',             tag:   nil, value: cc_service[:unique_id] },
                           { label: 'Service Tag',                   tag:   nil, value: service_tags_json[0] },
                           { label: 'Service Tag',                   tag:   nil, value: service_tags_json[1] },
                           { label: 'Service Documentation URL',     tag:   'a', value: cc_service[:documentation_url] },
                           { label: 'Service Info URL',              tag:   'a', value: cc_service[:info_url] },
                           { label: 'Service Display Name',          tag:   nil, value: service_extra_json['displayName'] },
                           { label: 'Service Provider Display Name', tag:   nil, value: service_extra_json['providerDisplayName'] },
                           { label: 'Service Icon',                  tag: 'img', value: @driver.execute_script("return Format.formatIconImage(\"#{ service_extra_json['imageUrl'] }\", \"service icon\", \"flot:left;\")").gsub(/'/, "\"").gsub(/[ ]+/, ' ').gsub(/ >/, '>') },
                           { label: 'Service Long Description',      tag:   nil, value: service_extra_json['longDescription'] },
                           { label: 'Service Documentation URL',     tag:   'a', value: service_extra_json['documentationUrl'] },
                           { label: 'Service Support URL',           tag:   'a', value: service_extra_json['supportUrl'] },
                           { label: 'Service Plans',                 tag:   'a', value: '1' },
                           { label: 'Service Instances',             tag:   'a', value: '1' },
                           { label: 'Service Bindings',              tag:   'a', value: '1' },
                           { label: 'Service Broker Name',           tag:   'a', value: cc_service_broker[:name] },
                           { label: 'Service Broker GUID',           tag:   nil, value: cc_service_broker[:guid] },
                           { label: 'Service Broker Created',        tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service_broker[:created_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Broker Updated',        tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service_broker[:updated_at].to_datetime.rfc3339 }\")") }
                          ])
          end

          it 'has service plans link' do
            check_filter_link('Services', 21, 'ServicePlans', cc_service[:guid])
          end

          it 'has service instances link' do
            check_filter_link('Services', 22, 'ServiceInstances', cc_service[:guid])
          end

          it 'has service bindings link' do
            check_filter_link('Services', 23, 'ServiceBindings', cc_service[:guid])
          end

          it 'has service brokers link' do
            check_filter_link('Services', 24, 'ServiceBrokers', cc_service_broker[:guid])
          end
        end
      end

      context 'Service Plans' do
        let(:tab_id) { 'ServicePlans' }

        it 'has a table' do
          check_table_layout([{ columns:         @driver.find_elements(xpath: "//div[@id='ServicePlansTable_wrapper']/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                expected_length: 4,
                                labels:          ['', 'Service Plan', 'Service', 'Service Broker'],
                                colspans:        %w(1 10 8 4)
                              },
                              {
                                columns:         @driver.find_elements(xpath: "//div[@id='ServicePlansTable_wrapper']/div[6]/div[1]/div/table/thead/tr[2]/th"),
                                expected_length: 23,
                                labels:          [' ', 'Name', 'GUID', 'Created', 'Updated', 'Active', 'Public', 'Free', 'Visible Organizations', 'Service Instances', 'Service Bindings', 'Provider', 'Label', 'GUID', 'Version', 'Created', 'Updated', 'Active', 'Bindable', 'Name', 'GUID', 'Created', 'Updated'],
                                colspans:        nil
                              }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='ServicePlansTable']/tbody/tr/td"),
                           [
                             '',
                             cc_service_plan[:name],
                             cc_service_plan[:guid],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_plan[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_plan[:updated_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatBoolean(\"#{ cc_service_plan[:active] }\")"),
                             @driver.execute_script("return Format.formatBoolean(\"#{ cc_service_plan[:public] }\")"),
                             @driver.execute_script("return Format.formatBoolean(\"#{ cc_service_plan[:free] }\")"),
                             '1',
                             '1',
                             '1',
                             cc_service[:provider],
                             cc_service[:label],
                             cc_service[:guid],
                             cc_service[:version],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service[:updated_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatBoolean(\"#{ cc_service[:active] }\")"),
                             @driver.execute_script("return Format.formatBoolean(\"#{ cc_service[:bindable] }\")"),
                             cc_service_broker[:name],
                             cc_service_broker[:guid],
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_broker[:created_at].to_datetime.rfc3339 }\")"),
                             @driver.execute_script("return Format.formatString(\"#{ cc_service_broker[:updated_at].to_datetime.rfc3339 }\")")
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_ServicePlansTable_2')
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            service_plan_extra_json = JSON.parse(cc_service_plan[:extra])
            check_details([{ label: 'Service Plan Name',         tag: 'div', value: cc_service_plan[:name] },
                           { label: 'Service Plan GUID',         tag:   nil, value: cc_service_plan[:guid] },
                           { label: 'Service Plan Created',      tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service_plan[:created_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Plan Updated',      tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service_plan[:updated_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Plan Active',       tag:   nil, value: @driver.execute_script("return Format.formatBoolean(\"#{ cc_service_plan[:active] }\")") },
                           { label: 'Service Plan Public',       tag:   nil, value: @driver.execute_script("return Format.formatBoolean(\"#{ cc_service_plan[:public] }\")") },
                           { label: 'Service Plan Free',         tag:   nil, value: @driver.execute_script("return Format.formatBoolean(\"#{ cc_service_plan[:free] }\")") },
                           { label: 'Service Plan Description',  tag:   nil, value: cc_service_plan[:description] },
                           { label: 'Service Plan Unique ID',    tag:   nil, value: cc_service_plan[:unique_id] },
                           { label: 'Service Plan Display Name', tag:   nil, value: service_plan_extra_json['displayName'] },
                           { label: 'Service Plan Bullet',       tag:   nil, value: service_plan_extra_json['bullets'][0] },
                           { label: 'Service Plan Bullet',       tag:   nil, value: service_plan_extra_json['bullets'][1] },
                           { label: 'Service Instances',         tag:   'a', value: '1' },
                           { label: 'Service Bindings',          tag:   'a', value: '1' },
                           { label: 'Service Provider',          tag:   nil, value: cc_service[:provider] },
                           { label: 'Service Label',             tag:   'a', value: cc_service[:label] },
                           { label: 'Service GUID',              tag:   nil, value: cc_service[:guid] },
                           { label: 'Service Version',           tag:   nil, value: cc_service[:version] },
                           { label: 'Service Created',           tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service[:created_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Updated',           tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service[:updated_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Active',            tag:   nil, value: @driver.execute_script("return Format.formatBoolean(\"#{ cc_service[:active] }\")") },
                           { label: 'Service Bindable',          tag:   nil, value: @driver.execute_script("return Format.formatBoolean(\"#{ cc_service[:bindable] }\")") },
                           { label: 'Service Broker Name',       tag:   'a', value: cc_service_broker[:name] },
                           { label: 'Service Broker GUID',       tag:   nil, value: cc_service_broker[:guid] },
                           { label: 'Service Broker Created',    tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service_broker[:created_at].to_datetime.rfc3339 }\")") },
                           { label: 'Service Broker Updated',    tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{ cc_service_broker[:updated_at].to_datetime.rfc3339 }\")") }
                          ])
          end

          it 'has visible organizations' do
            expect(@driver.find_element(id: 'ServicePlansOrganizationsDetailsLabel').displayed?).to be_true

            check_table_headers(columns:         @driver.find_elements(xpath: "//div[@id='ServicePlansOrganizationsTableContainer']/div[2]/div[5]/div[1]/div/table/thead/tr/th"),
                                expected_length: 3,
                                labels:          %w(Organization GUID Created),
                                colspans:        nil)

            check_table_data(@driver.find_elements(xpath: "//table[@id='ServicePlansOrganizationsTable']/tbody/tr/td"),
                             [
                               cc_organization[:name],
                               cc_organization[:guid],
                               @driver.execute_script("return Format.formatDateString(\"#{ cc_service_plan_visibility[:created_at].to_datetime.rfc3339 }\")")
                             ])
          end

          it 'organizations subtable has allowscriptaccess property set to sameDomain' do
            check_allowscriptaccess_attribute('ToolTables_ServicePlansOrganizationsTable_0')
          end

          it 'has a checkbox in the first column' do
            inputs = @driver.find_elements(xpath: "//table[@id='ServicePlansTable']/tbody/tr/td[1]/input")
            expect(inputs.length).to eq(1)
            expect(inputs[0].attribute('value')).to eq(cc_service_plan[:guid])
          end

          it 'has service instances link' do
            check_filter_link('ServicePlans', 12, 'ServiceInstances', cc_service_plan[:guid])
          end

          it 'has service bindings link' do
            check_filter_link('ServicePlans', 13, 'ServiceBindings', cc_service_plan[:guid])
          end

          it 'has services link' do
            check_filter_link('ServicePlans', 15, 'Services', cc_service[:guid])
          end

          it 'has service brokers link' do
            check_filter_link('ServicePlans', 22, 'ServiceBrokers', cc_service_broker[:guid])
          end

          context 'manage service plans' do
            def check_first_row
              @driver.find_elements(xpath: "//table[@id='ServicePlansTable']/tbody/tr/td[1]/input")[0].click
            end

            def manage_service_plan(buttonIndex)
              check_first_row
              @driver.find_element(id: "ToolTables_ServicePlansTable_#{ buttonIndex }").click
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
                Selenium::WebDriver::Wait.new(timeout: 60).until { refresh_button && @driver.find_element(xpath: "//table[@id='ServicePlansTable']/tbody/tr/td[7]").text == expect_state }
              rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
              end
              expect(@driver.find_element(xpath: "//table[@id='ServicePlansTable']/tbody/tr/td[7]").text).to eq(expect_state)
            end

            def check_operation_result(_visibility)
              Selenium::WebDriver::Wait.new(timeout: 60).until { @driver.find_element(id: 'ModalDialogContents').displayed? }
              expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be_true
              expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Success')
              @driver.find_element(id: 'modalDialogButton0').click
            end

            it 'has a Public button' do
              expect(@driver.find_element(id: 'ToolTables_ServicePlansTable_0').text).to eq('Public')
            end

            it 'has a Private button' do
              expect(@driver.find_element(id: 'ToolTables_ServicePlansTable_1').text).to eq('Private')
            end

            shared_examples 'click public or private button without selecting a single row' do
              it 'alerts the user to select at least one row when clicking the button' do
                @driver.find_element(id: buttonId).click

                expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be_true
                expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Error')
                expect(@driver.find_element(id: 'ModalDialogContents').text).to eq('Please select at least one row!')
                @driver.find_element(id: 'modalDialogButton0').click
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
          check_table_layout([{ columns:         @driver.find_elements(xpath: "//div[@id='DEAsTableContainer']/div/div[6]/div[1]/div/table/thead/tr[1]/th"),
                                expected_length: 3,
                                labels:          ['', 'Instances', '% Free'],
                                colspans:        %w(8 4 2)
                              },
                              { columns:         @driver.find_elements(xpath: "//div[@id='DEAsTableContainer']/div/div[6]/div[1]/div/table/thead/tr[2]/th"),
                                expected_length: 14,
                                labels:          ['Name', 'Index', 'Status', 'Started', 'Stack', 'CPU', 'Memory', 'Apps', 'Running', 'Memory', 'Disk', '% CPU', 'Memory', 'Disk'],
                                colspans:        nil
                              }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='DEAsTable']/tbody/tr/td"),
                           [
                             nats_dea['host'],
                             nats_dea['index'].to_s,
                             @driver.execute_script('return Constants.STATUS__RUNNING'),
                             @driver.execute_script("return Format.formatString(\"#{ varz_dea['start'] }\")"),
                             varz_dea['stacks'][0],
                             varz_dea['cpu'].to_s,
                             varz_dea['mem'].to_s,
                             varz_dea['instance_registry'].length.to_s,
                             varz_dea['instance_registry'][cc_app[:guid]].length.to_s,
                             @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_memory_in_bytes'] })").to_s,
                             @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_disk_in_bytes'] })").to_s,
                             @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['computed_pcpu'] * 100 })").to_s,
                             @driver.execute_script("return Format.formatNumber(#{ varz_dea['available_memory_ratio'].to_f * 100 })"),
                             @driver.execute_script("return Format.formatNumber(#{ varz_dea['available_disk_ratio'].to_f * 100 })")
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_DEAsTable_1')
        end

        it 'has a create DEA button' do
          expect(@driver.find_element(id: 'ToolTables_DEAsTable_0').text).to eq('Create new DEA')
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([{ label: 'Name',                  tag: nil, value: nats_dea['host'] },
                           { label: 'Index',                 tag: nil, value: nats_dea['index'].to_s },
                           { label: 'URI',                   tag: 'a', value: nats_dea_varz },
                           { label: 'Started',               tag: nil, value: @driver.execute_script("return Format.formatDateString(\"#{ varz_dea['start'] }\")") },
                           { label: 'Uptime',                tag: nil, value: @driver.execute_script("return Format.formatUptime(\"#{ varz_dea['uptime'] }\")") },
                           { label: 'Stack',                 tag: nil, value: varz_dea['stacks'][0] },
                           { label: 'Apps',                  tag: 'a', value: varz_dea['instance_registry'].length.to_s },
                           { label: 'Cores',                 tag: nil, value: varz_dea['num_cores'].to_s },
                           { label: 'CPU',                   tag: nil, value: varz_dea['cpu'].to_s },
                           { label: 'CPU Load Avg',          tag: nil, value: "#{ @driver.execute_script("return Format.formatNumber(#{ varz_dea['cpu_load_avg'].to_f * 100 })") }%" },
                           { label: 'Memory',                tag: nil, value: varz_dea['mem'].to_s },
                           { label: 'Instances',             tag: nil, value: varz_dea['instance_registry'][cc_app[:guid]].length.to_s },
                           { label: 'Instances Memory Used', tag: nil, value: @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_memory_in_bytes'] })").to_s },
                           { label: 'Instances Disk Used',   tag: nil, value: @driver.execute_script("return Utilities.convertBytesToMega(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_disk_in_bytes'] })").to_s },
                           { label: 'Instances CPU Used',    tag: nil, value: @driver.execute_script("return Format.formatNumber(#{ varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['computed_pcpu'] * 100 })").to_s },
                           { label: 'Memory Free',           tag: nil, value: "#{ @driver.execute_script("return Format.formatNumber(#{ varz_dea['available_memory_ratio'].to_f * 100 })") }%" },
                           { label: 'Disk Free',             tag: nil, value: "#{ @driver.execute_script("return Format.formatNumber(#{ varz_dea['available_disk_ratio'].to_f * 100 })") }%" }
                          ])
          end

          it 'has applications link' do
            check_filter_link('DEAs', 6, 'Applications', nats_dea['host'])
          end
        end
      end

      context 'Cloud Controllers' do
        let(:tab_id) { 'CloudControllers' }

        it 'has a table' do
          check_table_layout([{ columns:         @driver.find_elements(xpath: "//div[@id='CloudControllersTableContainer']/div/div[6]/div[1]/div/table/thead/tr/th"),
                                expected_length: 7,
                                labels:          %w(Name Index State Started Cores CPU Memory),
                                colspans:        nil
                              }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='CloudControllersTable']/tbody/tr/td"),
                           [
                             nats_cloud_controller['host'],
                             nats_cloud_controller['index'].to_s,
                             @driver.execute_script('return Constants.STATUS__RUNNING'),
                             @driver.execute_script("return Format.formatString(\"#{ varz_cloud_controller['start'] }\")"),
                             varz_cloud_controller['num_cores'].to_s,
                             varz_cloud_controller['cpu'].to_s,
                             varz_cloud_controller['mem'].to_s
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_CloudControllersTable_0')
        end

        context 'selectable' do
          it 'has details' do
            select_first_row
            check_details([{ label: 'Name',             tag: nil, value: nats_cloud_controller['host'] },
                           { label: 'Index',            tag: nil, value: nats_cloud_controller['index'].to_s },
                           { label: 'URI',              tag: 'a', value: nats_cloud_controller_varz },
                           { label: 'Started',          tag: nil, value: @driver.execute_script("return Format.formatDateString(\"#{ varz_cloud_controller['start'] }\")") },
                           { label: 'Uptime',           tag: nil, value: @driver.execute_script("return Format.formatUptime(\"#{ varz_cloud_controller['uptime'] }\")") },
                           { label: 'Cores',            tag: nil, value: varz_cloud_controller['num_cores'].to_s },
                           { label: 'CPU',              tag: nil, value: varz_cloud_controller['cpu'].to_s },
                           { label: 'Memory',           tag: nil, value: varz_cloud_controller['mem'].to_s },
                           { label: 'Requests',         tag: nil, value: varz_cloud_controller['vcap_sinatra']['requests']['completed'].to_s },
                           { label: 'Pending Requests', tag: nil, value: varz_cloud_controller['vcap_sinatra']['requests']['outstanding'].to_s }
                          ])
          end
        end
      end

      context 'Health Managers' do
        let(:tab_id) { 'HealthManagers' }

        it 'has a table' do
          check_table_layout([{ columns:         @driver.find_elements(xpath: "//div[@id='HealthManagersTableContainer']/div/div[6]/div[1]/div/table/thead/tr/th"),
                                expected_length: 10,
                                labels:          %w(Name Index State Started Cores CPU Memory Users Applications Instances),
                                colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='HealthManagersTable']/tbody/tr/td"),
                           [
                             nats_health_manager['host'],
                             nats_health_manager['index'].to_s,
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
          check_allowscriptaccess_attribute('ToolTables_HealthManagersTable_0')
        end

        context 'selectable' do
          it 'has details' do
            select_first_row
            check_details([{ label: 'Name',              tag: nil, value: nats_health_manager['host'] },
                           { label: 'Index',             tag: nil, value: nats_health_manager['index'].to_s },
                           { label: 'URI',               tag: 'a', value: nats_health_manager_varz },
                           { label: 'Started',           tag: nil, value: @driver.execute_script("return Format.formatDateString(\"#{ varz_health_manager['start'] }\")") },
                           { label: 'Uptime',            tag: nil, value: @driver.execute_script("return Format.formatUptime(\"#{ varz_health_manager['uptime'] }\")") },
                           { label: 'Cores',             tag: nil, value: varz_health_manager['num_cores'].to_s },
                           { label: 'CPU',               tag: nil, value: varz_health_manager['cpu'].to_s },
                           { label: 'Memory',            tag: nil, value: varz_health_manager['mem'].to_s },
                           { label: 'Users',             tag: nil, value: varz_health_manager['total_users'].to_s },
                           { label: 'Applications',      tag: nil, value: varz_health_manager['total_apps'].to_s },
                           { label: 'Instances',         tag: nil, value: varz_health_manager['total_instances'].to_s },
                           { label: 'Running Instances', tag: nil, value: varz_health_manager['running_instances'].to_s },
                           { label: 'Crashed Instances', tag: nil, value: varz_health_manager['crashed_instances'].to_s }
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
          check_table_layout([{ columns:         @driver.find_elements(xpath: "//div[@id='GatewaysTableContainer']/div/div[6]/div[1]/div/table/thead/tr/th"),
                                expected_length: 9,
                                labels:          ['Name', 'Index', 'State', 'Started', 'Description', 'CPU', 'Memory', 'Nodes', 'Available Capacity'],
                                colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='GatewaysTable']/tbody/tr/td"),
                           [
                             nats_provisioner['type'][0..-13],
                             nats_provisioner['index'].to_s,
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
          check_allowscriptaccess_attribute('ToolTables_GatewaysTable_0')
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([{ label: 'Name',               tag: nil, value: nats_provisioner['type'][0..-13] },
                           { label: 'Index',              tag: nil, value: nats_provisioner['index'].to_s },
                           { label: 'URI',                tag: nil, value: nats_provisioner_varz },
                           { label: 'Supported Versions', tag: nil, value: varz_provisioner['config']['service']['supported_versions'][0] },
                           { label: 'Description',        tag: nil, value: varz_provisioner['config']['service']['description'] },
                           { label: 'Started',            tag: nil, value: @driver.execute_script("return Format.formatDateString(\"#{ varz_provisioner['start'] }\")") },
                           { label: 'Uptime',             tag: nil, value: @driver.execute_script("return Format.formatUptime(\"#{ varz_provisioner['uptime'] }\")") },
                           { label: 'Cores',              tag: nil, value: varz_provisioner['num_cores'].to_s },
                           { label: 'CPU',                tag: nil, value: varz_provisioner['cpu'].to_s },
                           { label: 'Memory',             tag: nil, value: varz_provisioner['mem'].to_s },
                           { label: 'Available Capacity', tag: nil, value: @capacity.to_s }
                          ])
          end

          it 'has nodes' do
            expect(@driver.find_element(id: 'GatewaysNodesDetailsLabel').displayed?).to be_true

            check_table_headers(columns:         @driver.find_elements(xpath: "//div[@id='GatewaysNodesTableContainer']/div[2]/div[5]/div[1]/div/table/thead/tr/th"),
                                expected_length: 2,
                                labels:          ['Name', 'Available Capacity'],
                                colspans:        nil)

            check_table_data(@driver.find_elements(xpath: "//table[@id='GatewaysNodesTable']/tbody/tr/td"),
                             [
                               varz_provisioner['nodes'].keys[0],
                               varz_provisioner['nodes'][varz_provisioner['nodes'].keys[0]]['available_capacity'].to_s
                             ])
          end

          it 'nodes subtable has allowscriptaccess property set to sameDomain' do
            check_allowscriptaccess_attribute('ToolTables_GatewaysNodesTable_0')
          end
        end
      end

      context 'Routers' do
        let(:tab_id) { 'Routers' }

        it 'has a table' do
          check_table_layout([{  columns:         @driver.find_elements(xpath: "//div[@id='RoutersTableContainer']/div/div[6]/div[1]/div/table/thead/tr/th"),
                                 expected_length: 10,
                                 labels:          ['Name', 'Index', 'State', 'Started', 'Cores', 'CPU', 'Memory', 'Droplets', 'Requests', 'Bad Requests'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='RoutersTable']/tbody/tr/td"),
                           [
                             nats_router['host'],
                             nats_router['index'].to_s,
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
          check_allowscriptaccess_attribute('ToolTables_RoutersTable_0')
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([{ label: 'Name',          tag: nil, value: nats_router['host'] },
                           { label: 'Index',         tag: nil, value: nats_router['index'].to_s },
                           { label: 'URI',           tag: 'a', value: nats_router_varz },
                           { label: 'Started',       tag: nil, value: @driver.execute_script("return Format.formatDateString(\"#{ varz_router['start'] }\")") },
                           { label: 'Uptime',        tag: nil, value: @driver.execute_script("return Format.formatUptime(\"#{ varz_router['uptime'] }\")") },
                           { label: 'Cores',         tag: nil, value: varz_router['num_cores'].to_s },
                           { label: 'CPU',           tag: nil, value: varz_router['cpu'].to_s },
                           { label: 'Memory',        tag: nil, value: varz_router['mem'].to_s },
                           { label: 'Droplets',      tag: nil, value: varz_router['droplets'].to_s },
                           { label: 'Requests',      tag: nil, value: varz_router['requests'].to_s },
                           { label: 'Bad Requests',  tag: nil, value: varz_router['bad_requests'].to_s },
                           { label: '2XX Responses', tag: nil, value: varz_router['responses_2xx'].to_s },
                           { label: '3XX Responses', tag: nil, value: varz_router['responses_3xx'].to_s },
                           { label: '4XX Responses', tag: nil, value: varz_router['responses_4xx'].to_s },
                           { label: '5XX Responses', tag: nil, value: varz_router['responses_5xx'].to_s },
                           { label: 'XXX Responses', tag: nil, value: varz_router['responses_xxx'].to_s }
                          ])
          end

          it 'has top10 applications' do
            expect(@driver.find_element(id: 'RoutersTop10ApplicationsDetailsLabel').displayed?).to be_true

            check_table_headers(columns:         @driver.find_elements(xpath: "//div[@id='RoutersTop10ApplicationsTableContainer']/div[2]/div[5]/div[1]/div/table/thead/tr/th"),
                                expected_length: 5,
                                labels:          %w(Name GUID RPM RPS Target),
                                colspans:        nil)

            check_table_data(@driver.find_elements(xpath: "//table[@id='RoutersTop10ApplicationsTable']/tbody/tr/td"),
                             [
                               cc_app[:name],
                               cc_app[:guid],
                               varz_router['top10_app_requests'][0]['rpm'].to_s,
                               varz_router['top10_app_requests'][0]['rps'].to_s,
                               "#{ cc_organization[:name] }/#{ cc_space[:name] }"
                             ])
          end

          it 'top10 subtable has allowscriptaccess property set to sameDomain' do
            check_allowscriptaccess_attribute('ToolTables_RoutersTop10ApplicationsTable_0')
          end
        end
      end

      context 'Components' do
        let(:tab_id) { 'Components' }

        it 'has a table' do
          check_table_layout([{  columns:         @driver.find_elements(xpath: "//div[@id='ComponentsTableContainer']/div/div[6]/div[1]/div/table/thead/tr/th"),
                                 expected_length: 5,
                                 labels:          %w(Name Type Index State Started),
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='ComponentsTable']/tbody/tr/td"),
                           [
                             nats_cloud_controller['host'],
                             nats_cloud_controller['type'],
                             nats_cloud_controller['index'].to_s,
                             @driver.execute_script('return Constants.STATUS__RUNNING'),
                             @driver.execute_script("return Format.formatString(\"#{ varz_cloud_controller['start'] }\")")
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_ComponentsTable_1')
        end

        it 'has a remove OFFLINE components button' do
          expect(@driver.find_element(id: 'ToolTables_ComponentsTable_0').text).to eq('Remove OFFLINE')
        end

        context 'selectable' do
          it 'has details' do
            select_first_row
            check_details([{  label: 'Name',    tag: nil, value: nats_cloud_controller['host'] },
                           {  label: 'Type',    tag: nil, value: nats_cloud_controller['type'] },
                           {  label: 'Index',   tag: nil, value: nats_cloud_controller['index'].to_s },
                           {  label: 'Started', tag: nil, value: @driver.execute_script("return Format.formatDateString(\"#{ varz_cloud_controller['start'] }\")") },
                           {  label: 'URI',     tag: 'a', value: nats_cloud_controller_varz },
                           {  label: 'State',   tag: nil, value: @driver.execute_script('return Constants.STATUS__RUNNING') }
                          ])
          end
        end
      end

      context 'Logs' do
        let(:tab_id) { 'Logs' }

        it 'has a table' do
          check_table_layout([{  columns:         @driver.find_elements(xpath: "//div[@id='LogsTableContainer']/div/div[6]/div[1]/div/table/thead/tr/th"),
                                 expected_length: 3,
                                 labels:          ['Path', 'Size', 'Last Modified'],
                                 colspans:        nil
                               }
                             ])
        end

        it 'has contents' do
          row = first_row
          row.click
          columns = row.find_elements(tag_name: 'td')
          expect(columns.length).to eq(3)
          expect(columns[0].text).to eq(log_file_displayed)
          expect(columns[1].text).to eq(log_file_displayed_contents_length.to_s)
          # TODO: Cannot check date due to web_helper stub for AdminUI::Utils.time_in_milliseconds
          # expect(columns[2].text).to eq(@driver.execute_script("return Format.formatString(\"#{ log_file_displayed_modified.utc.to_datetime.rfc3339 }\")"))
          expect(@driver.find_element(id: 'LogContainer').displayed?).to be_true
          expect(@driver.find_element(id: 'LogLink').text).to eq(columns[0].text)
          expect(@driver.find_element(id: 'LogContents').text).to eq(log_file_displayed_contents)
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_LogsTable_0')
        end
      end

      context 'Tasks' do
        let(:tab_id) { 'Tasks' }
        let(:table_has_data) { false }

        it 'has a table' do
          check_table_layout([{  columns:         @driver.find_elements(xpath: "//div[@id='TasksTableContainer']/div/div[6]/div[1]/div/table/thead/tr/th"),
                                 expected_length: 3,
                                 labels:          %w(Command State Started),
                                 colspans:        nil
                               }
                             ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('ToolTables_TasksTable_0')
        end

        it 'can show task output' do
          expect(@driver.find_element(xpath: "//table[@id='TasksTable']/tbody/tr").text).to eq('No data available in table')
          @driver.find_element(id: 'DEAs').click
          @driver.find_element(id: 'ToolTables_DEAsTable_0').click
          @driver.find_element(id: 'modalDialogButton0').click
          @driver.find_element(id: 'modalDialogButton0').click
          @driver.find_element(id: 'Tasks').click

          # As the page refreshes, we need to catch the stale element error and re-find the element on the page
          begin
            Selenium::WebDriver::Wait.new(timeout: 60).until { @driver.find_elements(xpath: "//table[@id='TasksTable']/tbody/tr").length == 1 }
          rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
          end
          expect(@driver.find_elements(xpath: "//table[@id='TasksTable']/tbody/tr").length).to eq(1)

          begin
            Selenium::WebDriver::Wait.new(timeout: 60).until do
              refresh_button
              cells = @driver.find_elements(xpath: "//table[@id='TasksTable']/tbody/tr/td")
              cells[0].text == File.join(File.dirname(__FILE__)[0..-22], 'lib/admin/scripts', 'newDEA.sh') &&
                cells[1].text == @driver.execute_script('return Constants.STATUS__RUNNING')
            end
          rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
          end
          cells = @driver.find_elements(xpath: "//table[@id='TasksTable']/tbody/tr/td")
          expect(cells[0].text).to eq(File.join(File.dirname(__FILE__)[0..-22], 'lib/admin/scripts', 'newDEA.sh'))
          expect(cells[1].text).to eq(@driver.execute_script('return Constants.STATUS__RUNNING'))

          @driver.find_elements(xpath: "//table[@id='TasksTable']/tbody/tr")[0].click
          expect(@driver.find_element(id: 'TaskContents').text.length > 0).to be_true
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
            check_allowscriptaccess_attribute('ToolTables_StatsTable_1')
          end

          it 'has a chart' do
            check_stats_chart('Stats')
          end
        end

        def check_default_stats_table
          check_table_data(@driver.find_elements(xpath: "//table[@id='StatsTable']/tbody/tr/td"),
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
          @driver.find_element(id: 'ToolTables_StatsTable_0').click
          Selenium::WebDriver::Wait.new(timeout: 60).until { @driver.find_element(id: 'ModalDialogContents').displayed? }
          expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be_true
          expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Confirmation')
          rows = @driver.find_elements(xpath: "//div[@id='ModalDialogContentsSimple']/div/table/tbody/tr")
          rows.each do |row|
            expect(row.find_element(class_name: 'cellRightAlign').text).to eq('1')
          end
          @driver.find_element(id: 'modalDialogButton1').click
          check_default_stats_table
        end

        it 'can create stats' do
          check_default_stats_table
          @driver.find_element(id: 'ToolTables_StatsTable_0').click
          @driver.find_element(id: 'modalDialogButton0').click

          # As the page refreshes, we need to catch the stale element error and re-find the element on the page
          begin
            check_table_data(Selenium::WebDriver::Wait.new(timeout: 360).until { refresh_button && @driver.find_elements(xpath: "//table[@id='StatsTable']/tbody/tr/td") }, [nil, '1', '1', '1', '1', '1', '1', '1'])
          rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError, Timeout::Error
          end
          check_table_data(@driver.find_elements(xpath: "//table[@id='StatsTable']/tbody/tr/td"), [nil, '1', '1', '1', '1', '1', '1', '1'])
        end
      end
    end
  end
end
