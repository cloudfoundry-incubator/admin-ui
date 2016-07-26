require 'date'
require 'rubygems'
require 'yajl'
require_relative '../../spec_helper'
require_relative '../../support/web_helper'

describe AdminUI::Admin, type: :integration, firefox_available: true do
  include_context :server_context
  include_context :web_context

  BILLION = 1000 * 1000 * 1000

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

    def check_allowscriptaccess_attribute(copy_node_id)
      expect(@driver.find_element(id: copy_node_id).text).to eq('Copy')
      expect(@driver.find_element(xpath: "//a[@id='#{copy_node_id}']/div/embed").attribute('allowscriptaccess')).to eq('sameDomain')
    end

    def refresh_button
      # TODO: Bug in selenium-webdriver.  Entire item must be displayed for it to click.  Workaround following after commented out code
      # @driver.find_element(id: 'MenuButtonRefresh').click
      @driver.execute_script('arguments[0].click();', @driver.find_element(id: 'MenuButtonRefresh'))

      true
    end

    it 'has a title' do
      # Need to wait until the page has been rendered
      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.find_element(class_name: 'cloudControllerText').text == cloud_controller_uri }
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(class_name: 'cloudControllerText').text).to eq(cloud_controller_uri)
      expect(@driver.find_element(class_name: 'build').text).to eq("Build #{cc_info['build']}")
    end

    it 'has tabs' do
      expect(scroll_tab_into_view('Organizations', true).displayed?).to be(true)
      expect(scroll_tab_into_view('Spaces').displayed?).to be(true)
      expect(scroll_tab_into_view('Applications').displayed?).to be(true)
      expect(scroll_tab_into_view('ApplicationInstances').displayed?).to be(true)
      expect(scroll_tab_into_view('ServiceInstances').displayed?).to be(true)
      expect(scroll_tab_into_view('ServiceBindings').displayed?).to be(true)
      expect(scroll_tab_into_view('ServiceKeys').displayed?).to be(true)
      expect(scroll_tab_into_view('OrganizationRoles').displayed?).to be(true)
      expect(scroll_tab_into_view('SpaceRoles').displayed?).to be(true)
      expect(scroll_tab_into_view('Clients').displayed?).to be(true)
      expect(scroll_tab_into_view('Users').displayed?).to be(true)
      expect(scroll_tab_into_view('Groups').displayed?).to be(true)
      expect(scroll_tab_into_view('Buildpacks').displayed?).to be(true)
      expect(scroll_tab_into_view('Domains').displayed?).to be(true)
      expect(scroll_tab_into_view('FeatureFlags').displayed?).to be(true)
      expect(scroll_tab_into_view('Quotas').displayed?).to be(true)
      expect(scroll_tab_into_view('SpaceQuotas').displayed?).to be(true)
      expect(scroll_tab_into_view('Events').displayed?).to be(true)
      expect(scroll_tab_into_view('ServiceBrokers').displayed?).to be(true)
      expect(scroll_tab_into_view('Services').displayed?).to be(true)
      expect(scroll_tab_into_view('ServicePlans').displayed?).to be(true)
      expect(scroll_tab_into_view('ServicePlanVisibilities').displayed?).to be(true)
      expect(scroll_tab_into_view('IdentityZones').displayed?).to be(true)
      expect(scroll_tab_into_view('IdentityProviders').displayed?).to be(true)
      expect(scroll_tab_into_view('SecurityGroups').displayed?).to be(true)
      expect(scroll_tab_into_view('SecurityGroupsSpaces').displayed?).to be(true)
      expect(scroll_tab_into_view('DEAs').displayed?).to be(true)
      expect(scroll_tab_into_view('Cells').displayed?).to be(true)
      expect(scroll_tab_into_view('CloudControllers').displayed?).to be(true)
      expect(scroll_tab_into_view('HealthManagers').displayed?).to be(true)
      expect(scroll_tab_into_view('Gateways').displayed?).to be(true)
      expect(scroll_tab_into_view('Routers').displayed?).to be(true)
      expect(scroll_tab_into_view('Routes').displayed?).to be(true)
      expect(scroll_tab_into_view('Components').displayed?).to be(true)
      expect(scroll_tab_into_view('Logs').displayed?).to be(true)
      expect(scroll_tab_into_view('Stats').displayed?).to be(true)
    end

    it 'has a left scroll button' do
      expect(@driver.find_element(id: 'MenuButtonLeft').displayed?).to be(true)
    end

    it 'has a right scroll button' do
      expect(@driver.find_element(id: 'MenuButtonRight').displayed?).to be(true)
    end

    it 'has a refresh button' do
      expect(@driver.find_element(id: 'MenuButtonRefresh').displayed?).to be(true)
    end

    it 'shows the logged in user' do
      expect(@driver.find_element(class_name: 'userContainer').displayed?).to be(true)
      expect(@driver.find_element(class_name: 'user').text).to eq(LoginHelper::LOGIN_ADMIN)
    end

    context 'formatStringCleansed' do
      it 'removes html tags for iframe' do
        expect(@driver.execute_script('return Format.formatStringCleansed("hello<iframe src=javascript:alert(1208)></iframe>")')).to eq('hello')
      end

      it 'removes html tags for iframe short form' do
        expect(@driver.execute_script('return Format.formatStringCleansed("hello<iframe src=javascript:alert(1208)/>")')).to eq('hello')
      end

      it 'removes html tags for img' do
        expect(@driver.execute_script('return Format.formatStringCleansed("hello<img src=javascript:alert(1208)></img>")')).to eq('hello')
      end

      it 'removes html tags for img short form' do
        expect(@driver.execute_script('return Format.formatStringCleansed("hello<img src=javascript:alert(1208)>")')).to eq('hello')
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
        expect(@driver.execute_script('return Format.formatStringCleansed("hello<input type=text name=foo value=a%20onchange=alert(9)>")')).to eq('hello')
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
        expect(@driver.execute_script('return Format.formatStringCleansed("hello<script%0d%0aalert(9)</script>")')).to eq('hello')
      end

      it 'removes html tags for uncommon syntax' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<a''id=a href=''onclick=alert(9)>foo</a>\")")).to eq('hellofoo')
      end

      it 'removes html tags for orphan entity' do
        expect(@driver.execute_script("return Format.formatStringCleansed(\"hello<a href=''&amp;/onclick=alert(9)>foo</a>\")")).to eq('hellofoo')
      end

      it 'removes any html tags' do
        expect(@driver.execute_script('return Format.formatStringCleansed("hello<xyz src=javascript:alert(1208)></xzy>")')).to eq('hello')
      end

      it 'removes any html tags shorm form 1' do
        expect(@driver.execute_script('return Format.formatStringCleansed("hello<xyz src=javascript:alert(1208) />")')).to eq('hello')
      end

      it 'removes any html tags shorm form 2' do
        expect(@driver.execute_script('return Format.formatStringCleansed("hello<xyz src=javascript:alert(1208) >")')).to eq('hello')
      end
    end

    context 'tabs' do
      let(:table_has_data) { true }

      before do
        # First, make sure the DEA tab shows
        # Second select the desired tab via scrolling
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

        # Third, wait until the desired page has been rendered
        begin
          Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.find_element(id: "#{tab_id}Page").displayed? }
        rescue Selenium::WebDriver::Error::TimeOutError
        end
        expect(@driver.find_element(id: "#{tab_id}Page").displayed?).to eq(true)

        if table_has_data
          # Fourth, wait until the table on the desired page has data
          begin
            Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.find_element(xpath: "//table[@id='#{tab_id}Table']/tbody/tr").text != 'No data available in table' }
          rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
          end
          expect(@driver.find_element(xpath: "//table[@id='#{tab_id}Table']/tbody/tr").text).not_to eq('No data available in table')
        end
      end

      def check_checkbox_guid(table_id, guid)
        inputs = @driver.find_elements(xpath: "//table[@id='#{table_id}']/tbody/tr/td[1]/input")
        expect(inputs.length).to eq(1)
        expect(inputs[0].attribute('value')).to eq(guid)
      end

      def check_first_row(table_id)
        # TODO: Bug in selenium-webdriver.  Entire item must be displayed for it to click.  Workaround following after commented out code
        # @driver.find_elements(xpath: "//table[@id='#{table_id}']/tbody/tr/td[1]/input")[0].click
        @driver.execute_script('arguments[0].click();', @driver.find_elements(xpath: "//table[@id='#{table_id}']/tbody/tr/td[1]/input")[0])
      end

      def confirm(message)
        expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be(true)
        expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Confirmation')
        expect(@driver.find_element(id: 'ModalDialogContents').text).to eq(message)
        @driver.find_element(id: 'modalDialogButton0').click
      end

      def check_operation_result
        Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.find_element(id: 'ModalDialogContents').displayed? }
        expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be(true)
        Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.find_element(id: 'ModalDialogTitle').text == 'Success' }
        @driver.find_element(id: 'modalDialogButton0').click
      end

      shared_examples 'click button without selecting any rows' do
        it 'alerts the user to select at least one row when clicking the button' do
          @driver.find_element(id: button_id).click
          expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be(true)
          expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Error')
          expect(@driver.find_element(id: 'ModalDialogContents').text).to eq('Please select at least one row!')
          @driver.find_element(id: 'modalDialogButton0').click
        end
      end

      shared_examples 'click button without selecting exactly one row' do
        it 'alerts the user to select exactly one row when clicking the button' do
          @driver.find_element(id: button_id).click
          expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be(true)
          expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Error')
          expect(@driver.find_element(id: 'ModalDialogContents').text).to eq('Please select exactly one row!')
          @driver.find_element(id: 'modalDialogButton0').click
        end
      end

      shared_examples 'rename first row' do
        it 'renames the first row of the table' do
          check_first_row(table_id)
          @driver.find_element(id: button_id).click

          # Check whether the dialog is displayed
          expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be(true)
          expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq(title_text)
          expect(@driver.find_element(id: 'objectName').displayed?).to be(true)

          # Click the rename button without input
          @driver.find_element(id: 'objectName').clear
          @driver.find_element(id: 'modalDialogButton0').click
          alert = @driver.switch_to.alert
          expect(alert.text).to eq('Please input the name first!')
          alert.dismiss

          # Input the name of the object and click 'Rename'
          @driver.find_element(id: 'objectName').send_keys(object_rename)
          @driver.find_element(id: 'modalDialogButton0').click

          check_operation_result

          begin
            Selenium::WebDriver::Wait.new(timeout: 5).until { refresh_button && @driver.find_element(xpath: "//table[@id='#{table_id}']/tbody/tr/td[2]").text == object_rename }
          rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
          end
          expect(@driver.find_element(xpath: "//table[@id='#{table_id}']/tbody/tr/td[2]").text).to eq(object_rename)
        end
      end

      shared_examples 'delete first row' do
        let(:check_no_data_available) { true }
        it 'deletes the first row of the table and confirms table empty' do
          check_first_row(table_id)
          @driver.find_element(id: button_id).click

          confirm(confirm_message)

          check_operation_result

          if check_no_data_available
            begin
              Selenium::WebDriver::Wait.new(timeout: 5).until { refresh_button && @driver.find_element(xpath: "//table[@id='#{table_id}']/tbody/tr").text == 'No data available in table' }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='#{table_id}']/tbody/tr").text).to eq('No data available in table')
          end
        end
      end

      context 'Organizations' do
        let(:tab_id)   { 'Organizations' }
        let(:table_id) { 'OrganizationsTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='OrganizationsTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 7,
                                 labels:          ['', '', 'Routes', 'Used', 'Reserved', 'App States', 'App Package States'],
                                 colspans:        %w(1 15 3 5 2 3 3)
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='OrganizationsTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 32,
                                 labels:          ['', 'Name', 'GUID', 'Status', 'Created', 'Updated', 'Events Target', 'Spaces', 'Organization Roles', 'Space Roles', 'Quota', 'Space Quotas', 'Domains', 'Private Service Brokers', 'Service Plan Visibilities', 'Security Groups', 'Total', 'Used', 'Unused', 'Instances', 'Services', 'Memory', 'Disk', '% CPU', 'Memory', 'Disk', 'Total', 'Started', 'Stopped', 'Pending', 'Staged', 'Failed'],
                                 colspans:        nil
                               }
                             ])
        end

        shared_examples 'has organizations table data' do
          it 'has table data' do
            check_table_data(@driver.find_elements(xpath: "//table[@id='OrganizationsTable']/tbody/tr/td"),
                             [
                               '',
                               cc_organization[:name],
                               cc_organization[:guid],
                               cc_organization[:status].upcase,
                               cc_organization[:created_at].to_datetime.rfc3339,
                               cc_organization[:updated_at].to_datetime.rfc3339,
                               '1',
                               '1',
                               '4',
                               '3',
                               cc_quota_definition[:name],
                               '1',
                               '1',
                               '1',
                               '1',
                               '1',
                               '1',
                               '1',
                               '0',
                               @driver.execute_script("return Format.formatNumber(#{cc_app[:instances]})"),
                               '1',
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_memory)})"),
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_disk)})"),
                               @driver.execute_script("return Format.formatNumber(#{used_cpu})"),
                               @driver.execute_script("return Format.formatNumber(#{cc_app[:memory]})"),
                               @driver.execute_script("return Format.formatNumber(#{cc_app[:disk_quota]})"),
                               '1',
                               cc_app[:state] == 'STARTED' ? '1' : '0',
                               cc_app[:state] == 'STOPPED' ? '1' : '0',
                               cc_app[:package_state] == 'PENDING' ? '1' : '0',
                               cc_app[:package_state] == 'STAGED' ? '1' : '0',
                               cc_app[:package_state] == 'FAILED' ? '1' : '0'
                             ])
          end
        end

        context 'varz dea' do
          it_behaves_like('has organizations table data')
        end

        context 'doppler cell' do
          let(:application_instance_source) { :doppler_cell }
          it_behaves_like('has organizations table data')
        end

        context 'doppler dea' do
          let(:application_instance_source) { :doppler_dea }
          it_behaves_like('has organizations table data')
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_OrganizationsTable_7')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('OrganizationsTable', cc_organization[:guid])
        end

        context 'manage organization' do
          it 'has a Create button' do
            expect(@driver.find_element(id: 'Buttons_OrganizationsTable_0').text).to eq('Create')
          end

          it 'has a Rename button' do
            expect(@driver.find_element(id: 'Buttons_OrganizationsTable_1').text).to eq('Rename')
          end

          it 'has a Set Quota button' do
            expect(@driver.find_element(id: 'Buttons_OrganizationsTable_2').text).to eq('Set Quota')
          end

          it 'has an Activate button' do
            expect(@driver.find_element(id: 'Buttons_OrganizationsTable_3').text).to eq('Activate')
          end

          it 'has a Suspend button' do
            expect(@driver.find_element(id: 'Buttons_OrganizationsTable_4').text).to eq('Suspend')
          end

          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_OrganizationsTable_5').text).to eq('Delete')
          end

          it 'has a Delete Recursive button' do
            expect(@driver.find_element(id: 'Buttons_OrganizationsTable_6').text).to eq('Delete Recursive')
          end

          it 'creates an organization' do
            @driver.find_element(id: 'Buttons_OrganizationsTable_0').click

            # Check whether the dialog is displayed
            expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be(true)
            expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Create Organization')
            expect(@driver.find_element(id: 'organizationName').displayed?).to be(true)

            # Click the create button without input an organization name
            @driver.find_element(id: 'modalDialogButton0').click
            alert = @driver.switch_to.alert
            expect(alert.text).to eq('Please input the name first!')
            alert.dismiss

            # Input the name of the organization and click 'Create'
            @driver.find_element(id: 'organizationName').send_keys(cc_organization2[:name])
            @driver.find_element(id: 'modalDialogButton0').click

            check_operation_result

            begin
              Selenium::WebDriver::Wait.new(timeout: 5).until { refresh_button && @driver.find_element(xpath: "//table[@id='OrganizationsTable']/tbody/tr[1]/td[2]").text == cc_organization2[:name] }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='OrganizationsTable']/tbody/tr[1]/td[2]").text).to eq(cc_organization2[:name])
          end

          context 'Rename button' do
            it_behaves_like('click button without selecting exactly one row') do
              let(:button_id) { 'Buttons_OrganizationsTable_1' }
            end
          end

          context 'Set Quota button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_OrganizationsTable_2' }
            end
          end

          context 'Activate button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_OrganizationsTable_3' }
            end
          end

          context 'Suspend button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_OrganizationsTable_4' }
            end
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_OrganizationsTable_5' }
            end
          end

          context 'Delete Recursive button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_OrganizationsTable_6' }
            end
          end

          context 'Rename button' do
            it_behaves_like('rename first row') do
              let(:button_id)     { 'Buttons_OrganizationsTable_1' }
              let(:title_text)    { 'Rename Organization' }
              let(:object_rename) { cc_organization_rename }
            end
          end

          context 'set quota' do
            let(:insert_second_quota_definition) { true }

            it 'sets the quota for the organization' do
              check_first_row('OrganizationsTable')
              @driver.find_element(id: 'Buttons_OrganizationsTable_2').click

              # Check whether the dialog is displayed
              expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be(true)
              expect(@driver.find_element(id: 'quotaSelector').displayed?).to be(true)
              expect(@driver.find_element(xpath: '//select[@id="quotaSelector"]/option[1]').text).to eq(cc_quota_definition[:name])
              expect(@driver.find_element(xpath: '//select[@id="quotaSelector"]/option[2]').text).to eq(cc_quota_definition2[:name])

              # Select another quota and click the set button
              @driver.find_element(xpath: '//select[@id="quotaSelector"]/option[2]').click

              # TODO: Bug in selenium-webdriver.  Entire item must be displayed for it to click.  Workaround following after commented out code
              # @driver.find_element(id: 'modalDialogButton0').click
              @driver.execute_script('arguments[0].click();', @driver.find_element(id: 'modalDialogButton0'))

              check_operation_result

              begin
                Selenium::WebDriver::Wait.new(timeout: 5).until { refresh_button && @driver.find_element(xpath: "//table[@id='OrganizationsTable']/tbody/tr/td[11]").text == cc_quota_definition2[:name] }
              rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
              end
              expect(@driver.find_element(xpath: "//table[@id='OrganizationsTable']/tbody/tr/td[11]").text).to eq(cc_quota_definition2[:name])
            end
          end

          def manage_organization(button_id)
            check_first_row('OrganizationsTable')

            # TODO: Bug in selenium-webdriver.  Entire item must be displayed for it to click.  Workaround following after commented out code
            # @driver.find_element(id: button_id).click
            @driver.execute_script('arguments[0].click();', @driver.find_element(id: button_id))

            check_operation_result
          end

          def activate_organization
            manage_organization('Buttons_OrganizationsTable_3')
          end

          def suspend_organization
            manage_organization('Buttons_OrganizationsTable_4')
          end

          def check_organization_status(status)
            begin
              Selenium::WebDriver::Wait.new(timeout: 10).until { refresh_button && @driver.find_element(xpath: "//table[@id='OrganizationsTable']/tbody/tr/td[4]").text == status }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='OrganizationsTable']/tbody/tr/td[4]").text).to eq(status)
          end

          it 'activates the selected organization' do
            suspend_organization
            check_organization_status('SUSPENDED')

            activate_organization
            check_organization_status('ACTIVE')
          end

          it 'suspends the selected organization' do
            suspend_organization
            check_organization_status('SUSPENDED')
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_OrganizationsTable_5' }
              let(:confirm_message) { 'Are you sure you want to delete the selected organizations?' }
            end
          end

          context 'Delete Recursive button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_OrganizationsTable_6' }
              let(:confirm_message) { 'Are you sure you want to delete the selected organizations and their contained spaces, space quotas, applications, routes, private service brokers, service instances, service bindings, service keys and route bindings?' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          shared_examples 'has organization details' do
            it 'has details' do
              check_details([
                              { label: 'Name',                      tag: 'div', value: cc_organization[:name] },
                              { label: 'GUID',                      tag:   nil, value: cc_organization[:guid] },
                              { label: 'Status',                    tag:   nil, value: cc_organization[:status].upcase },
                              { label: 'Created',                   tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_organization[:created_at].to_datetime.rfc3339}\")") },
                              { label: 'Updated',                   tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_organization[:updated_at].to_datetime.rfc3339}\")") },
                              { label: 'Billing Enabled',           tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_organization[:billing_enabled]})") },
                              { label: 'Events Target',             tag:   'a', value: '1' },
                              { label: 'Spaces',                    tag:   'a', value: '1' },
                              { label: 'Organization Roles',        tag:   'a', value: '4' },
                              { label: 'Space Roles',               tag:   'a', value: '3' },
                              { label: 'Quota',                     tag:   'a', value: cc_quota_definition[:name] },
                              { label: 'Space Quotas',              tag:   'a', value: '1' },
                              { label: 'Domains',                   tag:   'a', value: '1' },
                              { label: 'Private Service Brokers',   tag:   'a', value: '1' },
                              { label: 'Service Plan Visibilities', tag:   'a', value: '1' },
                              { label: 'Security Groups',           tag:   'a', value: '1' },
                              { label: 'Total Routes',              tag:   'a', value: '1' },
                              { label: 'Used Routes',               tag:   nil, value: '1' },
                              { label: 'Unused Routes',             tag:   nil, value: '0' },
                              { label: 'Instances Used',            tag:   'a', value: @driver.execute_script("return Format.formatNumber(#{cc_app[:instances]})") },
                              { label: 'Services Used',             tag:   'a', value: '1' },
                              { label: 'Memory Used',               tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_memory)})") },
                              { label: 'Disk Used',                 tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_disk)})") },
                              { label: 'CPU Used',                  tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{used_cpu})") },
                              { label: 'Memory Reserved',           tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_app[:memory]})") },
                              { label: 'Disk Reserved',             tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_app[:disk_quota]})") },
                              { label: 'Total Apps',                tag:   'a', value: '1' },
                              { label: 'Started Apps',              tag:   nil, value: cc_app[:state] == 'STARTED' ? '1' : '0' },
                              { label: 'Stopped Apps',              tag:   nil, value: cc_app[:state] == 'STOPPED' ? '1' : '0' },
                              { label: 'Pending Apps',              tag:   nil, value: cc_app[:package_state] == 'PENDING' ? '1' : '0' },
                              { label: 'Staged Apps',               tag:   nil, value: cc_app[:package_state] == 'STAGED' ? '1' : '0' },
                              { label: 'Failed Apps',               tag:   nil, value: cc_app[:package_state] == 'FAILED' ? '1' : '0' }
                            ])
            end
          end

          context 'varz dea' do
            it_behaves_like('has organization details')
          end

          context 'doppler cell' do
            let(:application_instance_source) { :doppler_cell }
            it_behaves_like('has organization details')
          end

          context 'doppler dea' do
            let(:application_instance_source) { :doppler_dea }
            it_behaves_like('has organization details')
          end

          it 'has events target link' do
            check_filter_link('Organizations', 6, 'Events', "#{cc_organization[:name]}/")
          end

          it 'has spaces link' do
            check_filter_link('Organizations', 7, 'Spaces', "#{cc_organization[:name]}/")
          end

          it 'has organization roles link' do
            check_filter_link('Organizations', 8, 'OrganizationRoles', cc_organization[:guid])
          end

          it 'has space roles link' do
            check_filter_link('Organizations', 9, 'SpaceRoles', "#{cc_organization[:name]}/")
          end

          it 'has quotas link' do
            check_filter_link('Organizations', 10, 'Quotas', cc_quota_definition[:guid])
          end

          it 'has space quotas link' do
            check_filter_link('Organizations', 11, 'SpaceQuotas', cc_organization[:guid])
          end

          it 'has domains link' do
            check_filter_link('Organizations', 12, 'Domains', cc_organization[:name])
          end

          it 'has service brokers link' do
            check_filter_link('Organizations', 13, 'ServiceBrokers', "#{cc_organization[:name]}/")
          end

          it 'has service plan visibilities link' do
            check_filter_link('Organizations', 14, 'ServicePlanVisibilities', cc_organization[:guid])
          end

          it 'has security groups spaces link' do
            check_filter_link('Organizations', 15, 'SecurityGroupsSpaces', "#{cc_organization[:name]}/")
          end

          it 'has routes link' do
            check_filter_link('Organizations', 16, 'Routes', "#{cc_organization[:name]}/")
          end

          it 'has application instances link' do
            check_filter_link('Organizations', 19, 'ApplicationInstances', "#{cc_organization[:name]}/")
          end

          it 'has services instances link' do
            check_filter_link('Organizations', 20, 'ServiceInstances', "#{cc_organization[:name]}/")
          end

          it 'has applications link' do
            check_filter_link('Organizations', 26, 'Applications', "#{cc_organization[:name]}/")
          end
        end
      end

      context 'Spaces' do
        let(:tab_id)   { 'Spaces' }
        let(:table_id) { 'SpacesTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='SpacesTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 7,
                                 labels:          ['', '', 'Routes', 'Used', 'Reserved', 'App States', 'App Package States'],
                                 colspans:        %w(1 11 3 5 2 3 3)
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='SpacesTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 28,
                                 labels:          ['', 'Name', 'GUID', 'Target', 'Created', 'Updated', 'Events', 'Events Target', 'Roles', 'Space Quota', 'Private Service Brokers', 'Security Groups', 'Total', 'Used', 'Unused', 'Instances', 'Services', 'Memory', 'Disk', '% CPU', 'Memory', 'Disk', 'Total', 'Started', 'Stopped', 'Pending', 'Staged', 'Failed'],
                                 colspans:        nil
                               }
                             ])
        end

        shared_examples 'has spaces table data' do
          it 'has table data' do
            check_table_data(@driver.find_elements(xpath: "//table[@id='SpacesTable']/tbody/tr/td"),
                             [
                               '',
                               cc_space[:name],
                               cc_space[:guid],
                               "#{cc_organization[:name]}/#{cc_space[:name]}",
                               cc_space[:created_at].to_datetime.rfc3339,
                               cc_space[:updated_at].to_datetime.rfc3339,
                               '1',
                               '1',
                               '3',
                               cc_space_quota_definition[:name],
                               '1',
                               '1',
                               '1',
                               '1',
                               '0',
                               @driver.execute_script("return Format.formatNumber(#{cc_app[:instances]})"),
                               '1',
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_memory)})"),
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_disk)})"),
                               @driver.execute_script("return Format.formatNumber(#{used_cpu})"),
                               @driver.execute_script("return Format.formatNumber(#{cc_app[:memory]})"),
                               @driver.execute_script("return Format.formatNumber(#{cc_app[:disk_quota]})"),
                               '1',
                               cc_app[:state] == 'STARTED' ? '1' : '0',
                               cc_app[:state] == 'STOPPED' ? '1' : '0',
                               cc_app[:package_state] == 'PENDING' ? '1' : '0',
                               cc_app[:package_state] == 'STAGED' ? '1' : '0',
                               cc_app[:package_state] == 'FAILED' ? '1' : '0'
                             ])
          end
        end

        context 'varz dea' do
          it_behaves_like 'has spaces table data'
        end

        context 'doppler cell' do
          let(:application_instance_source) { :doppler_cell }
          it_behaves_like 'has spaces table data'
        end

        context 'doppler dea' do
          let(:application_instance_source) { :doppler_dea }
          it_behaves_like 'has spaces table data'
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_SpacesTable_3')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('SpacesTable', cc_space[:guid])
        end

        context 'manage spaces' do
          it 'has a Rename button' do
            expect(@driver.find_element(id: 'Buttons_SpacesTable_0').text).to eq('Rename')
          end

          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_SpacesTable_1').text).to eq('Delete')
          end

          it 'has a Delete Recursive button' do
            expect(@driver.find_element(id: 'Buttons_SpacesTable_2').text).to eq('Delete Recursive')
          end

          context 'Rename button' do
            it_behaves_like('click button without selecting exactly one row') do
              let(:button_id) { 'Buttons_SpacesTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_SpacesTable_1' }
            end
          end

          context 'Delete Recursive button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_SpacesTable_2' }
            end
          end

          context 'Rename button' do
            it_behaves_like('rename first row') do
              let(:button_id)     { 'Buttons_SpacesTable_0' }
              let(:title_text)    { 'Rename Space' }
              let(:object_rename) { cc_space_rename }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_SpacesTable_1' }
              let(:confirm_message) { 'Are you sure you want to delete the selected spaces?' }
            end
          end

          context 'Delete Recursive button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_SpacesTable_2' }
              let(:confirm_message) { 'Are you sure you want to delete the selected spaces and their contained applications, routes, private service brokers, service instances, service bindings, service keys and route bindings?' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          shared_examples 'has space details' do
            it 'has details' do
              check_details([
                              { label: 'Name',                    tag: 'div', value: cc_space[:name] },
                              { label: 'GUID',                    tag:   nil, value: cc_space[:guid] },
                              { label: 'Organization',            tag:   'a', value: cc_organization[:name] },
                              { label: 'Created',                 tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_space[:created_at].to_datetime.rfc3339}\")") },
                              { label: 'Updated',                 tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_space[:updated_at].to_datetime.rfc3339}\")") },
                              { label: 'Events',                  tag:   'a', value: '1' },
                              { label: 'Events Target',           tag:   'a', value: '1' },
                              { label: 'Roles',                   tag:   'a', value: '3' },
                              { label: 'Space Quota',             tag:   'a', value: cc_space_quota_definition[:name] },
                              { label: 'Private Service Brokers', tag:   'a', value: '1' },
                              { label: 'Security Groups',         tag:   'a', value: '1' },
                              { label: 'Total Routes',            tag:   'a', value: '1' },
                              { label: 'Used Routes',             tag:   nil, value: '1' },
                              { label: 'Unused Routes',           tag:   nil, value: '0' },
                              { label: 'Instances Used',          tag:   'a', value: @driver.execute_script("return Format.formatNumber(#{cc_app[:instances]})") },
                              { label: 'Services Used',           tag:   'a', value: '1' },
                              { label: 'Memory Used',             tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_memory)})") },
                              { label: 'Disk Used',               tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_disk)})") },
                              { label: 'CPU Used',                tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{used_cpu})") },
                              { label: 'Memory Reserved',         tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_app[:memory]})") },
                              { label: 'Disk Reserved',           tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_app[:disk_quota]})") },
                              { label: 'Total Apps',              tag:   'a', value: '1' },
                              { label: 'Started Apps',            tag:   nil, value: cc_app[:state] == 'STARTED' ? '1' : '0' },
                              { label: 'Stopped Apps',            tag:   nil, value: cc_app[:state] == 'STOPPED' ? '1' : '0' },
                              { label: 'Pending Apps',            tag:   nil, value: cc_app[:package_state] == 'PENDING' ? '1' : '0' },
                              { label: 'Staged Apps',             tag:   nil, value: cc_app[:package_state] == 'STAGED' ? '1' : '0' },
                              { label: 'Failed Apps',             tag:   nil, value: cc_app[:package_state] == 'FAILED' ? '1' : '0' }
                            ])
            end
          end

          context 'varz dea' do
            it_behaves_like('has space details')
          end

          context 'doppler cell' do
            let(:application_instance_source) { :doppler_cell }
            it_behaves_like('has space details')
          end

          context 'doppler dea' do
            let(:application_instance_source) { :doppler_dea }
            it_behaves_like('has space details')
          end

          it 'has organizations link' do
            check_filter_link('Spaces', 2, 'Organizations', cc_organization[:guid])
          end

          it 'has events link' do
            check_filter_link('Spaces', 5, 'Events', cc_space[:guid])
          end

          it 'has events target link' do
            check_filter_link('Spaces', 6, 'Events', "#{cc_organization[:name]}/#{cc_space[:name]}")
          end

          it 'has space roles link' do
            check_filter_link('Spaces', 7, 'SpaceRoles', cc_space[:guid])
          end

          it 'has space quotas link' do
            check_filter_link('Spaces', 8, 'SpaceQuotas', cc_space_quota_definition[:guid])
          end

          it 'has service brokers link' do
            check_filter_link('Spaces', 9, 'ServiceBrokers', "#{cc_organization[:name]}/#{cc_space[:name]}")
          end

          it 'has security groups spaces link' do
            check_filter_link('Spaces', 10, 'SecurityGroupsSpaces', cc_space[:guid])
          end

          it 'has routes link' do
            check_filter_link('Spaces', 11, 'Routes', "#{cc_organization[:name]}/#{cc_space[:name]}")
          end

          it 'has application instances link' do
            check_filter_link('Spaces', 14, 'ApplicationInstances', "#{cc_organization[:name]}/#{cc_space[:name]}")
          end

          it 'has services link' do
            check_filter_link('Spaces', 15, 'ServiceInstances', "#{cc_organization[:name]}/#{cc_space[:name]}")
          end

          it 'has applications link' do
            check_filter_link('Spaces', 21, 'Applications', "#{cc_organization[:name]}/#{cc_space[:name]}")
          end
        end
      end

      context 'Applications' do
        let(:tab_id)     { 'Applications' }
        let(:table_id)   { 'ApplicationsTable' }
        let(:event_type) { 'app' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ApplicationsTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 5,
                                 labels:          ['', '', 'Used', 'Reserved', ''],
                                 colspans:        %w(1 14 3 2 1)
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ApplicationsTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 21,
                                 labels:          ['', 'Name', 'GUID', 'State', 'Package State', 'Staging Failed Reason', 'Created', 'Updated', 'URIs', 'Diego', 'Stack', 'Buildpacks', 'Events', 'Instances', 'Service Bindings', 'Memory', 'Disk', '% CPU', 'Memory', 'Disk', 'Target'],
                                 colspans:        nil
                               }
                             ])
        end

        shared_examples 'has applications table data' do
          it 'has table data' do
            check_table_data(@driver.find_elements(xpath: "//table[@id='ApplicationsTable']/tbody/tr/td"),
                             [
                               '',
                               cc_app[:name],
                               cc_app[:guid],
                               cc_app[:state],
                               @driver.execute_script('return Constants.STATUS__STAGED'),
                               cc_app[:staging_failed_reason],
                               cc_app[:created_at].to_datetime.rfc3339,
                               cc_app[:updated_at].to_datetime.rfc3339,
                               "http://#{cc_route[:host]}.#{cc_domain[:name]}#{cc_route[:path]}",
                               @driver.execute_script("return Format.formatBoolean(#{cc_app[:diego]})"),
                               cc_stack[:name],
                               cc_app[:detected_buildpack],
                               '1',
                               '1',
                               '1',
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_memory)})"),
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_disk)})"),
                               @driver.execute_script("return Format.formatNumber(#{used_cpu})"),
                               @driver.execute_script("return Format.formatNumber(#{cc_app[:memory]})"),
                               @driver.execute_script("return Format.formatNumber(#{cc_app[:disk_quota]})"),
                               "#{cc_organization[:name]}/#{cc_space[:name]}"
                             ])
          end
        end

        context 'varz dea' do
          it_behaves_like('has applications table data')
        end

        context 'doppler cell' do
          let(:application_instance_source) { :doppler_cell }
          it_behaves_like('has applications table data')
        end

        context 'doppler dea' do
          let(:application_instance_source) { :doppler_dea }
          it_behaves_like('has applications table data')
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_ApplicationsTable_6')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('ApplicationsTable', cc_app[:guid])
        end

        context 'manage application' do
          def manage_application(button_index)
            check_first_row('ApplicationsTable')

            # TODO: Bug in selenium-webdriver.  Entire item must be displayed for it to click.  Workaround following after commented out code
            # @driver.find_element(id: 'Buttons_ApplicationsTable_' + button_index.to_s).click
            @driver.execute_script('arguments[0].click();', @driver.find_element(id: 'Buttons_ApplicationsTable_' + button_index.to_s))

            check_operation_result
          end

          def check_app_state(expect_state)
            begin
              Selenium::WebDriver::Wait.new(timeout: 20).until { refresh_button && @driver.find_element(xpath: "//table[@id='ApplicationsTable']/tbody/tr/td[4]").text == expect_state }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='ApplicationsTable']/tbody/tr/td[4]").text).to eq(expect_state)
          end

          it 'has a Rename button' do
            expect(@driver.find_element(id: 'Buttons_ApplicationsTable_0').text).to eq('Rename')
          end

          it 'has a Start button' do
            expect(@driver.find_element(id: 'Buttons_ApplicationsTable_1').text).to eq('Start')
          end

          it 'has a Stop button' do
            expect(@driver.find_element(id: 'Buttons_ApplicationsTable_2').text).to eq('Stop')
          end

          it 'has a Restage button' do
            expect(@driver.find_element(id: 'Buttons_ApplicationsTable_3').text).to eq('Restage')
          end

          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_ApplicationsTable_4').text).to eq('Delete')
          end

          it 'has a Delete Recursive button' do
            expect(@driver.find_element(id: 'Buttons_ApplicationsTable_5').text).to eq('Delete Recursive')
          end

          context 'Rename button' do
            it_behaves_like('click button without selecting exactly one row') do
              let(:button_id) { 'Buttons_ApplicationsTable_0' }
            end
          end

          context 'Start button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ApplicationsTable_1' }
            end
          end

          context 'Stop button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ApplicationsTable_2' }
            end
          end

          context 'Restage button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ApplicationsTable_3' }
            end
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ApplicationsTable_4' }
            end
          end

          context 'Delete Recursive button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ApplicationsTable_5' }
            end
          end

          context 'Rename button' do
            it_behaves_like('rename first row') do
              let(:button_id)     { 'Buttons_ApplicationsTable_0' }
              let(:title_text)    { 'Rename Application' }
              let(:object_rename) { cc_app_rename }
            end
          end

          it 'stops the selected application' do
            # stop the app
            manage_application(2)
            check_app_state('STOPPED')
          end

          it 'starts the selected application' do
            # let app in stopped state first
            manage_application(2)
            check_app_state('STOPPED')

            # start the app
            manage_application(1)
            check_app_state('STARTED')
          end

          it 'restages the selected application' do
            manage_application(3)
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_ApplicationsTable_4' }
              let(:confirm_message) { 'Are you sure you want to delete the selected applications?' }
            end
          end

          context 'Delete Recursive button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_ApplicationsTable_5' }
              let(:confirm_message) { 'Are you sure you want to delete the selected applications and their associated service bindings?' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          shared_examples 'has application details' do
            it 'has details' do
              check_details([
                              { label: 'Name',                       tag: 'div', value: cc_app[:name] },
                              { label: 'GUID',                       tag:   nil, value: cc_app[:guid] },
                              { label: 'State',                      tag:   nil, value: cc_app[:state] },
                              { label: 'Package State',              tag:   nil, value: cc_app[:package_state] },
                              { label: 'Staging Failed Reason',      tag:   nil, value: cc_app[:staging_failed_reason] },
                              { label: 'Staging Failed Description', tag:   nil, value: cc_app[:staging_failed_description] },
                              { label: 'Created',                    tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_app[:created_at].to_datetime.rfc3339}\")") },
                              { label: 'Updated',                    tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_app[:updated_at].to_datetime.rfc3339}\")") },
                              { label: 'URI',                        tag:   nil, value: "http://#{cc_route[:host]}.#{cc_domain[:name]}#{cc_route[:path]}" },
                              { label: 'Diego',                      tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_app[:diego]})") },
                              { label: 'Stack',                      tag:   'a', value: cc_stack[:name] },
                              { label: 'Buildpack',                  tag:   nil, value: cc_app[:detected_buildpack] },
                              { label: 'Command',                    tag:   nil, value: cc_app[:command] },
                              { label: 'Detected Start Command',     tag:   nil, value: cc_droplet[:detected_start_command] },
                              { label: 'Droplet Hash',               tag:   nil, value: cc_app[:droplet_hash] },
                              { label: 'Events',                     tag:   'a', value: '1' },
                              { label: 'Instances',                  tag:   'a', value: '1' },
                              { label: 'Service Bindings',           tag:   'a', value: '1' },
                              { label: 'Memory Used',                tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_memory)})") },
                              { label: 'Disk Used',                  tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_disk)})") },
                              { label: 'CPU Used',                   tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{used_cpu})") },
                              { label: 'Memory Reserved',            tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_app[:memory]})") },
                              { label: 'Disk Reserved',              tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_app[:disk_quota]})") },
                              { label: 'Space',                      tag:   'a', value: cc_space[:name] },
                              { label: 'Organization',               tag:   'a', value: cc_organization[:name] }
                            ])
            end
          end

          context 'varz dea' do
            it_behaves_like('has application details')
          end

          context 'doppler cell' do
            let(:application_instance_source) { :doppler_cell }
            it_behaves_like('has application details')
          end

          context 'doppler dea' do
            let(:application_instance_source) { :doppler_dea }
            it_behaves_like('has application details')
          end

          it 'has stacks link' do
            check_filter_link('Applications', 10, 'Stacks', cc_stack[:guid])
          end

          it 'has events link' do
            check_filter_link('Applications', 15, 'Events', cc_app[:guid])
          end

          it 'has application instances link' do
            check_filter_link('Applications', 16, 'ApplicationInstances', cc_app[:guid])
          end

          it 'has service bindings link' do
            check_filter_link('Applications', 17, 'ServiceBindings', cc_app[:guid])
          end

          it 'has spaces link' do
            check_filter_link('Applications', 23, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('Applications', 24, 'Organizations', cc_organization[:guid])
          end
        end
      end

      context 'Application Instances' do
        let(:tab_id)   { 'ApplicationInstances' }
        let(:table_id) { 'ApplicationInstancesTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ApplicationInstancesTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 5,
                                 labels:          ['', '', 'Used', 'Reserved', ''],
                                 colspans:        %w(1 9 3 2 3)
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ApplicationInstancesTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 18,
                                 labels:          ['', 'Name', 'Application GUID', 'Index', 'Instance ID', 'State', 'Started', 'Metrics', 'Diego', 'Stack', 'Memory', 'Disk', '% CPU', 'Memory', 'Disk', 'Target', 'DEA', 'Cell'],
                                 colspans:        nil
                               }
                             ])
        end

        context 'varz dea' do
          it 'has table data' do
            check_table_data(@driver.find_elements(xpath: "//table[@id='ApplicationInstancesTable']/tbody/tr/td"),
                             [
                               '',
                               cc_app[:name],
                               cc_app[:guid],
                               @driver.execute_script("return Format.formatNumber(#{cc_app_instance_index})"),
                               varz_dea_app_instance,
                               varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['state'],
                               Time.at(varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['state_running_timestamp']).to_datetime.rfc3339,
                               '',
                               @driver.execute_script("return Format.formatBoolean(#{cc_app[:diego]})"),
                               cc_stack[:name],
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_memory_in_bytes'])})"),
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_disk_in_bytes'])})"),
                               @driver.execute_script("return Format.formatNumber(#{varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['computed_pcpu']} * 100)"),
                               @driver.execute_script("return Format.formatNumber(#{cc_app[:memory]})"),
                               @driver.execute_script("return Format.formatNumber(#{cc_app[:disk_quota]})"),
                               "#{cc_organization[:name]}/#{cc_space[:name]}",
                               nats_dea['host'],
                               nil
                             ])
          end
        end

        context 'doppler cell' do
          let(:application_instance_source) { :doppler_cell }

          it 'has table data' do
            check_table_data(@driver.find_elements(xpath: "//table[@id='ApplicationInstancesTable']/tbody/tr/td"),
                             [
                               '',
                               cc_app[:name],
                               cc_app[:guid],
                               @driver.execute_script("return Format.formatNumber(#{cc_app_instance_index})"),
                               nil,
                               nil,
                               nil,
                               Time.at(rep_envelope.timestamp / BILLION).to_datetime.rfc3339,
                               @driver.execute_script('return Format.formatBoolean(true)'),
                               cc_stack[:name],
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(rep_container_metric_envelope.containerMetric.memoryBytes)})"),
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(rep_container_metric_envelope.containerMetric.diskBytes)})"),
                               @driver.execute_script("return Format.formatNumber(#{rep_container_metric_envelope.containerMetric.cpuPercentage})"),
                               @driver.execute_script("return Format.formatNumber(#{cc_app[:memory]})"),
                               @driver.execute_script("return Format.formatNumber(#{cc_app[:disk_quota]})"),
                               "#{cc_organization[:name]}/#{cc_space[:name]}",
                               nil,
                               "#{rep_envelope.ip}:#{rep_envelope.index}"
                             ])
          end
        end

        context 'doppler dea' do
          let(:application_instance_source) { :doppler_dea }

          it 'has table data' do
            check_table_data(@driver.find_elements(xpath: "//table[@id='ApplicationInstancesTable']/tbody/tr/td"),
                             [
                               '',
                               cc_app[:name],
                               cc_app[:guid],
                               @driver.execute_script("return Format.formatNumber(#{cc_app_instance_index})"),
                               nil,
                               nil,
                               nil,
                               Time.at(dea_envelope.timestamp / BILLION).to_datetime.rfc3339,
                               @driver.execute_script('return Format.formatBoolean(false)'),
                               cc_stack[:name],
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(dea_container_metric_envelope.containerMetric.memoryBytes)})"),
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(dea_container_metric_envelope.containerMetric.diskBytes)})"),
                               @driver.execute_script("return Format.formatNumber(#{dea_container_metric_envelope.containerMetric.cpuPercentage})"),
                               @driver.execute_script("return Format.formatNumber(#{cc_app[:memory]})"),
                               @driver.execute_script("return Format.formatNumber(#{cc_app[:disk_quota]})"),
                               "#{cc_organization[:name]}/#{cc_space[:name]}",
                               "#{dea_envelope.ip}:#{dea_envelope.index}",
                               nil
                             ])
          end
        end
        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_ApplicationInstancesTable_1')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('ApplicationInstancesTable', "#{cc_app[:guid]}/#{cc_app_instance_index}")
        end

        context 'manage application instances' do
          it 'has a restart button' do
            expect(@driver.find_element(id: 'Buttons_ApplicationInstancesTable_0').text).to eq('Restart')
          end

          context 'Restart button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ApplicationInstancesTable_0' }
            end
          end

          context 'Restart button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_ApplicationInstancesTable_0' }
              let(:confirm_message) { 'Are you sure you want to restart the selected application instances?' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          context 'varz dea' do
            it 'has details' do
              check_details([
                              { label: 'Name',             tag:   nil, value: cc_app[:name] },
                              { label: 'Application GUID', tag: 'div', value: cc_app[:guid] },
                              { label: 'Index',            tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_app_instance_index})") },
                              { label: 'Instance ID',      tag:   nil, value: varz_dea_app_instance },
                              { label: 'State',            tag:   nil, value: varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['state'] },
                              { label: 'Started',          tag:   nil, value: @driver.execute_script("return Format.formatDateNumber(#{varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['state_running_timestamp']} * 1000)") },
                              { label: 'Diego',            tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_app[:diego]})") },
                              { label: 'Stack',            tag:   'a', value: cc_stack[:name] },
                              { label: 'Droplet Hash',     tag:   nil, value: cc_app[:droplet_hash] },
                              { label: 'Memory Used',      tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_memory_in_bytes'])})") },
                              { label: 'Disk Used',        tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['used_disk_in_bytes'])})") },
                              { label: 'CPU Used',         tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{varz_dea['instance_registry'][cc_app[:guid]][varz_dea_app_instance]['computed_pcpu']} * 100)") },
                              { label: 'Memory Reserved',  tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_app[:memory]})") },
                              { label: 'Disk Reserved',    tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_app[:disk_quota]})") },
                              { label: 'Space',            tag:   'a', value: cc_space[:name] },
                              { label: 'Organization',     tag:   'a', value: cc_organization[:name] },
                              { label: 'DEA',              tag:   'a', value: nats_dea['host'] }
                            ])
            end
          end

          context 'doppler cell' do
            let(:application_instance_source) { :doppler_cell }

            it 'has details' do
              check_details([
                              { label: 'Name',             tag:   nil, value: cc_app[:name] },
                              { label: 'Application GUID', tag: 'div', value: cc_app[:guid] },
                              { label: 'Index',            tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_app_instance_index})") },
                              { label: 'Metrics',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{Time.at(rep_envelope.timestamp / BILLION).to_datetime.rfc3339}\")") },
                              { label: 'Diego',            tag:   nil, value: @driver.execute_script('return Format.formatBoolean(true)') },
                              { label: 'Stack',            tag:   'a', value: cc_stack[:name] },
                              { label: 'Memory Used',      tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(rep_container_metric_envelope.containerMetric.memoryBytes)})") },
                              { label: 'Disk Used',        tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(rep_container_metric_envelope.containerMetric.diskBytes)})") },
                              { label: 'CPU Used',         tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{rep_container_metric_envelope.containerMetric.cpuPercentage})") },
                              { label: 'Memory Reserved',  tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_app[:memory]})") },
                              { label: 'Disk Reserved',    tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_app[:disk_quota]})") },
                              { label: 'Space',            tag:   'a', value: cc_space[:name] },
                              { label: 'Organization',     tag:   'a', value: cc_organization[:name] },
                              { label: 'Cell',             tag:   'a', value: "#{rep_envelope.ip}:#{rep_envelope.index}" }
                            ])
            end
          end

          context 'doppler dea' do
            let(:application_instance_source) { :doppler_dea }

            it 'has details' do
              check_details([
                              { label: 'Name',             tag:   nil, value: cc_app[:name] },
                              { label: 'Application GUID', tag: 'div', value: cc_app[:guid] },
                              { label: 'Index',            tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_app_instance_index})") },
                              { label: 'Metrics',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{Time.at(dea_envelope.timestamp / BILLION).to_datetime.rfc3339}\")") },
                              { label: 'Diego',            tag:   nil, value: @driver.execute_script('return Format.formatBoolean(false)') },
                              { label: 'Stack',            tag:   'a', value: cc_stack[:name] },
                              { label: 'Memory Used',      tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(dea_container_metric_envelope.containerMetric.memoryBytes)})") },
                              { label: 'Disk Used',        tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(dea_container_metric_envelope.containerMetric.diskBytes)})") },
                              { label: 'CPU Used',         tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{dea_container_metric_envelope.containerMetric.cpuPercentage})") },
                              { label: 'Memory Reserved',  tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_app[:memory]})") },
                              { label: 'Disk Reserved',    tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_app[:disk_quota]})") },
                              { label: 'Space',            tag:   'a', value: cc_space[:name] },
                              { label: 'Organization',     tag:   'a', value: cc_organization[:name] },
                              { label: 'DEA',              tag:   'a', value: "#{dea_envelope.ip}:#{dea_envelope.index}" }
                            ])
            end
          end
          it 'has applications link' do
            check_filter_link('ApplicationInstances', 1, 'Applications', cc_app[:guid])
          end

          it 'has stacks link' do
            check_filter_link('ApplicationInstances', 7, 'Stacks', cc_stack[:guid])
          end

          it 'has spaces link' do
            check_filter_link('ApplicationInstances', 14, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('ApplicationInstances', 15, 'Organizations', cc_organization[:guid])
          end

          context 'varz dea' do
            it 'has DEAs link' do
              check_filter_link('ApplicationInstances', 16, 'DEAs', nats_dea['host'])
            end
          end

          context 'doppler cell' do
            let(:application_instance_source) { :doppler_cell }

            it 'has Cells link' do
              check_filter_link('ApplicationInstances', 13, 'Cells', "#{rep_envelope.ip}:#{rep_envelope.index}")
            end
          end

          context 'doppler dea' do
            let(:application_instance_source) { :doppler_dea }

            it 'has DEAs link' do
              check_filter_link('ApplicationInstances', 13, 'DEAs', "#{dea_envelope.ip}:#{dea_envelope.index}")
            end
          end
        end
      end

      context 'Routes' do
        let(:tab_id)     { 'Routes' }
        let(:table_id)   { 'RoutesTable' }
        let(:event_type) { 'route' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='RoutesTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 10,
                                 labels:          ['', 'Host', 'Path', 'GUID', 'Domain', 'Created', 'Updated', 'Events', 'Applications', 'Target'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='RoutesTable']/tbody/tr/td"),
                           [
                             '',
                             cc_route[:host],
                             cc_route[:path],
                             cc_route[:guid],
                             cc_domain[:name],
                             cc_route[:created_at].to_datetime.rfc3339,
                             cc_route[:updated_at].to_datetime.rfc3339,
                             '1',
                             '1',
                             "#{cc_organization[:name]}/#{cc_space[:name]}"
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_RoutesTable_2')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('RoutesTable', cc_route[:guid])
        end

        context 'manage routes' do
          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_RoutesTable_0').text).to eq('Delete')
          end

          it 'has a Delete Recursive button' do
            expect(@driver.find_element(id: 'Buttons_RoutesTable_1').text).to eq('Delete Recursive')
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_RoutesTable_0' }
            end
          end

          context 'Delete Recursive button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_RoutesTable_1' }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_RoutesTable_0' }
              let(:confirm_message) { 'Are you sure you want to delete the selected routes?' }
            end
          end

          context 'Delete Recursive button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_RoutesTable_1' }
              let(:confirm_message) { 'Are you sure you want to delete the selected routes and their associated route bindings?' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Host',         tag:   nil, value: cc_route[:host] },
                            { label: 'Path',         tag:   nil, value: cc_route[:path] },
                            { label: 'GUID',         tag: 'div', value: cc_route[:guid] },
                            { label: 'Domain',       tag:   'a', value: cc_domain[:name] },
                            { label: 'Created',      tag:   nil, value: Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.execute_script("return Format.formatDateString(\"#{cc_route[:created_at].to_datetime.rfc3339}\")") } },
                            { label: 'Updated',      tag:   nil, value: Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.execute_script("return Format.formatDateString(\"#{cc_route[:updated_at].to_datetime.rfc3339}\")") } },
                            { label: 'Events',       tag:   'a', value: '1' },
                            { label: 'Applications', tag:   'a', value: '1' },
                            { label: 'Space',        tag:   'a', value: cc_space[:name] },
                            { label: 'Organization', tag:   'a', value: cc_organization[:name] }
                          ])
          end

          it 'has domains link' do
            check_filter_link('Routes', 3, 'Domains', cc_domain[:guid])
          end

          it 'has events link' do
            check_filter_link('Routes', 6, 'Events', cc_route[:guid])
          end

          it 'has applications link' do
            check_filter_link('Routes', 7, 'Applications', "#{cc_route[:host]}.#{cc_domain[:name]}#{cc_route[:path]}")
          end

          it 'has spaces link' do
            check_filter_link('Routes', 8, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('Routes', 9, 'Organizations', cc_organization[:guid])
          end
        end
      end

      context 'Service Instances' do
        let(:tab_id)     { 'ServiceInstances' }
        let(:table_id)   { 'ServiceInstancesTable' }
        let(:event_type) { 'service_instance' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ServiceInstancesTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 7,
                                 labels:          ['', 'Service Instance', 'Service Instance Last Operation', 'Service Plan', 'Service', 'Service Broker', ''],
                                 colspans:        %w(1 8 4 8 9 4 1)
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ServiceInstancesTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 35,
                                 labels:          ['', 'Name', 'GUID', 'Created', 'Updated', 'User Provided', 'Events', 'Service Bindings', 'Service Keys', 'Type', 'State', 'Created', 'Updated', 'Name', 'GUID', 'Unique ID', 'Created', 'Updated', 'Active', 'Public', 'Free', 'Provider', 'Label', 'GUID', 'Unique ID', 'Version', 'Created', 'Updated', 'Active', 'Bindable', 'Name', 'GUID', 'Created', 'Updated', 'Target'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='ServiceInstancesTable']/tbody/tr/td"),
                           [
                             '',
                             cc_service_instance[:name],
                             cc_service_instance[:guid],
                             cc_service_instance[:created_at].to_datetime.rfc3339,
                             cc_service_instance[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{!cc_service_instance[:is_gateway_service]})"),
                             '1',
                             '1',
                             '1',
                             cc_service_instance_operation[:type],
                             cc_service_instance_operation[:state],
                             cc_service_instance_operation[:created_at].to_datetime.rfc3339,
                             cc_service_instance_operation[:updated_at].to_datetime.rfc3339,
                             cc_service_plan[:name],
                             cc_service_plan[:guid],
                             cc_service_plan[:unique_id],
                             cc_service_plan[:created_at].to_datetime.rfc3339,
                             cc_service_plan[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})"),
                             cc_service[:provider],
                             cc_service[:label],
                             cc_service[:guid],
                             cc_service[:unique_id],
                             cc_service[:version],
                             cc_service[:created_at].to_datetime.rfc3339,
                             cc_service[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service[:bindable]})"),
                             cc_service_broker[:name],
                             cc_service_broker[:guid],
                             cc_service_broker[:created_at].to_datetime.rfc3339,
                             cc_service_broker[:updated_at].to_datetime.rfc3339,
                             "#{cc_organization[:name]}/#{cc_space[:name]}"
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_ServiceInstancesTable_4')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('ServiceInstancesTable', "#{cc_service_instance[:guid]}/#{cc_service_instance[:is_gateway_service]}")
        end

        context 'manage service instances' do
          it 'has a Rename button' do
            expect(@driver.find_element(id: 'Buttons_ServiceInstancesTable_0').text).to eq('Rename')
          end

          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_ServiceInstancesTable_1').text).to eq('Delete')
          end

          it 'has a Delete Recursive button' do
            expect(@driver.find_element(id: 'Buttons_ServiceInstancesTable_2').text).to eq('Delete Recursive')
          end

          it 'has a Purge button' do
            expect(@driver.find_element(id: 'Buttons_ServiceInstancesTable_3').text).to eq('Purge')
          end

          context 'Rename button' do
            it_behaves_like('click button without selecting exactly one row') do
              let(:button_id) { 'Buttons_ServiceInstancesTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ServiceInstancesTable_1' }
            end
          end

          context 'Delete Recursive button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ServiceInstancesTable_2' }
            end
          end

          context 'Purge button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ServiceInstancesTable_3' }
            end
          end

          context 'Rename button' do
            it_behaves_like('rename first row') do
              let(:button_id)     { 'Buttons_ServiceInstancesTable_0' }
              let(:title_text)    { 'Rename Service Instance' }
              let(:object_rename) { cc_service_instance_rename }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_ServiceInstancesTable_1' }
              let(:confirm_message) { 'Are you sure you want to delete the selected service instances?' }
            end
          end

          context 'Delete Recursive button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_ServiceInstancesTable_2' }
              let(:confirm_message) { 'Are you sure you want to delete the selected service instances and their associated service bindings, service keys and route bindings?' }
            end
          end

          context 'Purge button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_ServiceInstancesTable_3' }
              let(:confirm_message) { 'Are you sure you want to purge the selected service instances?' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            service_instance_tags_json = Yajl::Parser.parse(cc_service_instance[:tags])
            check_details([
                            { label: 'Service Instance Name',                       tag: 'div', value: cc_service_instance[:name] },
                            { label: 'Service Instance GUID',                       tag:   nil, value: cc_service_instance[:guid] },
                            { label: 'Service Instance Created',                    tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_instance[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Instance Updated',                    tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_instance[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Instance User Provided',              tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{!cc_service_instance[:is_gateway_service]})") },
                            { label: 'Service Instance Dashboard URL',              tag:   nil, value: cc_service_instance[:dashboard_url] },
                            { label: 'Service Instance Events',                     tag:   'a', value: '1' },
                            { label: 'Service Bindings',                            tag:   'a', value: '1' },
                            { label: 'Service Keys',                                tag:   'a', value: '1' },
                            { label: 'Service Instance Last Operation Type',        tag:  nil, value: cc_service_instance_operation[:type] },
                            { label: 'Service Instance Last Operation State',       tag:  nil, value: cc_service_instance_operation[:state] },
                            { label: 'Service Instance Last Operation Created',     tag:  nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_instance_operation[:created_at]}\")") },
                            { label: 'Service Instance Last Operation Updated',     tag:  nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_instance_operation[:updated_at]}\")") },
                            { label: 'Service Instance Last Operation Description', tag:  nil, value: cc_service_instance_operation[:description] },
                            { label: 'Service Instance Tag',                        tag:   nil, value: service_instance_tags_json[0] },
                            { label: 'Service Instance Tag',                        tag:   nil, value: service_instance_tags_json[1] },
                            { label: 'Service Plan Name',                           tag:   'a', value: cc_service_plan[:name] },
                            { label: 'Service Plan GUID',                           tag:   nil, value: cc_service_plan[:guid] },
                            { label: 'Service Plan Unique ID',                      tag:   nil, value: cc_service_plan[:unique_id] },
                            { label: 'Service Plan Created',                        tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_plan[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Updated',                        tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_plan[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Active',                         tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})") },
                            { label: 'Service Plan Public',                         tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})") },
                            { label: 'Service Plan Free',                           tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})") },
                            { label: 'Service Provider',                            tag:   nil, value: cc_service[:provider] },
                            { label: 'Service Label',                               tag:   'a', value: cc_service[:label] },
                            { label: 'Service GUID',                                tag:   nil, value: cc_service[:guid] },
                            { label: 'Service Unique ID',                           tag:   nil, value: cc_service[:unique_id] },
                            { label: 'Service Version',                             tag:   nil, value: cc_service[:version] },
                            { label: 'Service Created',                             tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Updated',                             tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Active',                              tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})") },
                            { label: 'Service Bindable',                            tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:bindable]})") },
                            { label: 'Service Broker Name',                         tag:   'a', value: cc_service_broker[:name] },
                            { label: 'Service Broker GUID',                         tag:   nil, value: cc_service_broker[:guid] },
                            { label: 'Service Broker Created',                      tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Broker Updated',                      tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Space',                                       tag:   'a', value: cc_space[:name] },
                            { label: 'Organization',                                tag:   'a', value: cc_organization[:name] }
                          ])
          end

          it 'has events link' do
            check_filter_link('ServiceInstances', 6, 'Events', cc_service_instance[:guid])
          end

          it 'has service bindings link' do
            check_filter_link('ServiceInstances', 7, 'ServiceBindings', cc_service_instance[:guid])
          end

          it 'has service keys link' do
            check_filter_link('ServiceInstances', 8, 'ServiceKeys', cc_service_instance[:guid])
          end

          it 'has service plans link' do
            check_filter_link('ServiceInstances', 16, 'ServicePlans', cc_service_plan[:guid])
          end

          it 'has services link' do
            check_filter_link('ServiceInstances', 25, 'Services', cc_service[:guid])
          end

          it 'has service brokers link' do
            check_filter_link('ServiceInstances', 33, 'ServiceBrokers', cc_service_broker[:guid])
          end

          it 'has spaces link' do
            check_filter_link('ServiceInstances', 37, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('ServiceInstances', 38, 'Organizations', cc_organization[:guid])
          end
        end
      end

      context 'Service Bindings' do
        let(:tab_id)     { 'ServiceBindings' }
        let(:table_id)   { 'ServiceBindingsTable' }
        let(:event_type) { 'service_binding' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ServiceBindingsTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 8,
                                 labels:          ['', 'Service Binding', 'Application', 'Service Instance', 'Service Plan', 'Service', 'Service Broker', ''],
                                 colspans:        %w(1 4 2 4 8 8 4 1)
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ServiceBindingsTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 32,
                                 labels:          ['', 'GUID', 'Created', 'Updated', 'Events', 'Name', 'GUID', 'Name', 'GUID', 'Created', 'Updated', 'Name', 'GUID', 'Unique ID', 'Created', 'Updated', 'Active', 'Public', 'Free', 'Provider', 'Label', 'GUID', 'Unique ID', 'Version', 'Created', 'Updated', 'Active', 'Name', 'GUID', 'Created', 'Updated', 'Target'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='ServiceBindingsTable']/tbody/tr/td"),
                           [
                             '',
                             cc_service_binding[:guid],
                             cc_service_binding[:created_at].to_datetime.rfc3339,
                             cc_service_binding[:updated_at].to_datetime.rfc3339,
                             '1',
                             cc_app[:name],
                             cc_app[:guid],
                             cc_service_instance[:name],
                             cc_service_instance[:guid],
                             cc_service_instance[:created_at].to_datetime.rfc3339,
                             cc_service_instance[:updated_at].to_datetime.rfc3339,
                             cc_service_plan[:name],
                             cc_service_plan[:guid],
                             cc_service_plan[:unique_id],
                             cc_service_plan[:created_at].to_datetime.rfc3339,
                             cc_service_plan[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})"),
                             cc_service[:provider],
                             cc_service[:label],
                             cc_service[:guid],
                             cc_service[:unique_id],
                             cc_service[:version],
                             cc_service[:created_at].to_datetime.rfc3339,
                             cc_service[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})"),
                             cc_service_broker[:name],
                             cc_service_broker[:guid],
                             cc_service_broker[:created_at].to_datetime.rfc3339,
                             cc_service_broker[:updated_at].to_datetime.rfc3339,
                             "#{cc_organization[:name]}/#{cc_space[:name]}"
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_ServiceBindingsTable_1')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('ServiceBindingsTable', cc_service_binding[:guid])
        end

        context 'manage service bindings' do
          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_ServiceBindingsTable_0').text).to eq('Delete')
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ServiceBindingsTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_ServiceBindingsTable_0' }
              let(:confirm_message) { 'Are you sure you want to delete the selected service bindings?' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Service Binding GUID',     tag: 'div', value: cc_service_binding[:guid] },
                            { label: 'Service Binding Created',  tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_binding[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Binding Updated',  tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_binding[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Binding Events',   tag:   'a', value: '1' },
                            { label: 'Application Name',         tag:   'a', value: cc_app[:name] },
                            { label: 'Application GUID',         tag:   nil, value: cc_app[:guid] },
                            { label: 'Service Instance Name',    tag:   'a', value: cc_service_instance[:name] },
                            { label: 'Service Instance GUID',    tag:   nil, value: cc_service_instance[:guid] },
                            { label: 'Service Instance Created', tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_instance[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Instance Updated', tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_instance[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Name',        tag:   'a', value: cc_service_plan[:name] },
                            { label: 'Service Plan GUID',        tag:   nil, value: cc_service_plan[:guid] },
                            { label: 'Service Plan Unique ID',   tag:   nil, value: cc_service_plan[:unique_id] },
                            { label: 'Service Plan Created',     tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_plan[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Updated',     tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_plan[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Active',      tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})") },
                            { label: 'Service Plan Public',      tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})") },
                            { label: 'Service Plan Free',        tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})") },
                            { label: 'Service Provider',         tag:   nil, value: cc_service[:provider] },
                            { label: 'Service Label',            tag:   'a', value: cc_service[:label] },
                            { label: 'Service GUID',             tag:   nil, value: cc_service[:guid] },
                            { label: 'Service Unique ID',        tag:   nil, value: cc_service[:unique_id] },
                            { label: 'Service Version',          tag:   nil, value: cc_service[:version] },
                            { label: 'Service Created',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Updated',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Active',           tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})") },
                            { label: 'Service Broker Name',      tag:   'a', value: cc_service_broker[:name] },
                            { label: 'Service Broker GUID',      tag:   nil, value: cc_service_broker[:guid] },
                            { label: 'Service Broker Created',   tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Broker Updated',   tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Space',                    tag:   'a', value: cc_space[:name] },
                            { label: 'Organization',             tag:   'a', value: cc_organization[:name] }
                          ])
          end

          it 'has events' do
            check_filter_link('ServiceBindings', 3, 'Events', cc_service_binding[:guid])
          end

          it 'has applications link' do
            check_filter_link('ServiceBindings', 4, 'Applications', cc_app[:guid])
          end

          it 'has service instances link' do
            check_filter_link('ServiceBindings', 6, 'ServiceInstances', cc_service_instance[:guid])
          end

          it 'has service plans link' do
            check_filter_link('ServiceBindings', 10, 'ServicePlans', cc_service_plan[:guid])
          end

          it 'has services link' do
            check_filter_link('ServiceBindings', 19, 'Services', cc_service[:guid])
          end

          it 'has service brokers link' do
            check_filter_link('ServiceBindings', 26, 'ServiceBrokers', cc_service_broker[:guid])
          end

          it 'has spaces link' do
            check_filter_link('ServiceBindings', 30, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('ServiceBindings', 31, 'Organizations', cc_organization[:guid])
          end
        end
      end

      context 'Service Keys' do
        let(:tab_id)     { 'ServiceKeys' }
        let(:table_id)   { 'ServiceKeysTable' }
        let(:event_type) { 'service_key' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ServiceKeysTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 7,
                                 labels:          ['', 'Service Key', 'Service Instance', 'Service Plan', 'Service', 'Service Broker', ''],
                                 colspans:        %w(1 5 4 8 8 4 1)
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ServiceKeysTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 31,
                                 labels:          ['', 'Name', 'GUID', 'Created', 'Updated', 'Events', 'Name', 'GUID', 'Created', 'Updated', 'Name', 'GUID', 'Unique ID', 'Created', 'Updated', 'Active', 'Public', 'Free', 'Provider', 'Label', 'GUID', 'Unique ID', 'Version', 'Created', 'Updated', 'Active', 'Name', 'GUID', 'Created', 'Updated', 'Target'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='ServiceKeysTable']/tbody/tr/td"),
                           [
                             '',
                             cc_service_key[:name],
                             cc_service_key[:guid],
                             cc_service_key[:created_at].to_datetime.rfc3339,
                             cc_service_key[:updated_at].to_datetime.rfc3339,
                             '1',
                             cc_service_instance[:name],
                             cc_service_instance[:guid],
                             cc_service_instance[:created_at].to_datetime.rfc3339,
                             cc_service_instance[:updated_at].to_datetime.rfc3339,
                             cc_service_plan[:name],
                             cc_service_plan[:guid],
                             cc_service_plan[:unique_id],
                             cc_service_plan[:created_at].to_datetime.rfc3339,
                             cc_service_plan[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})"),
                             cc_service[:provider],
                             cc_service[:label],
                             cc_service[:guid],
                             cc_service[:unique_id],
                             cc_service[:version],
                             cc_service[:created_at].to_datetime.rfc3339,
                             cc_service[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})"),
                             cc_service_broker[:name],
                             cc_service_broker[:guid],
                             cc_service_broker[:created_at].to_datetime.rfc3339,
                             cc_service_broker[:updated_at].to_datetime.rfc3339,
                             "#{cc_organization[:name]}/#{cc_space[:name]}"
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_ServiceKeysTable_1')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('ServiceKeysTable', cc_service_key[:guid])
        end

        context 'manage service keys' do
          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_ServiceKeysTable_0').text).to eq('Delete')
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ServiceKeysTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_ServiceKeysTable_0' }
              let(:confirm_message) { 'Are you sure you want to delete the selected service keys?' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Service Key Name',         tag: 'div', value: cc_service_key[:name] },
                            { label: 'Service Key GUID',         tag:   nil, value: cc_service_key[:guid] },
                            { label: 'Service Key Created',      tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_key[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Key Updated',      tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_key[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Key Events',       tag:   'a', value: '1' },
                            { label: 'Service Instance Name',    tag:   'a', value: cc_service_instance[:name] },
                            { label: 'Service Instance GUID',    tag:   nil, value: cc_service_instance[:guid] },
                            { label: 'Service Instance Created', tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_instance[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Instance Updated', tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_instance[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Name',        tag:   'a', value: cc_service_plan[:name] },
                            { label: 'Service Plan GUID',        tag:   nil, value: cc_service_plan[:guid] },
                            { label: 'Service Plan Unique ID',   tag:   nil, value: cc_service_plan[:unique_id] },
                            { label: 'Service Plan Created',     tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_plan[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Updated',     tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_plan[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Active',      tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})") },
                            { label: 'Service Plan Public',      tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})") },
                            { label: 'Service Plan Free',        tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})") },
                            { label: 'Service Provider',         tag:   nil, value: cc_service[:provider] },
                            { label: 'Service Label',            tag:   'a', value: cc_service[:label] },
                            { label: 'Service GUID',             tag:   nil, value: cc_service[:guid] },
                            { label: 'Service Unique ID',        tag:   nil, value: cc_service[:unique_id] },
                            { label: 'Service Version',          tag:   nil, value: cc_service[:version] },
                            { label: 'Service Created',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Updated',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Active',           tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})") },
                            { label: 'Service Broker Name',      tag:   'a', value: cc_service_broker[:name] },
                            { label: 'Service Broker GUID',      tag:   nil, value: cc_service_broker[:guid] },
                            { label: 'Service Broker Created',   tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Broker Updated',   tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Space',                    tag:   'a', value: cc_space[:name] },
                            { label: 'Organization',             tag:   'a', value: cc_organization[:name] }
                          ])
          end

          it 'has events' do
            check_filter_link('ServiceKeys', 4, 'Events', cc_service_key[:guid])
          end

          it 'has service instances link' do
            check_filter_link('ServiceKeys', 5, 'ServiceInstances', cc_service_instance[:guid])
          end

          it 'has service plans link' do
            check_filter_link('ServiceKeys', 9, 'ServicePlans', cc_service_plan[:guid])
          end

          it 'has services link' do
            check_filter_link('ServiceKeys', 18, 'Services', cc_service[:guid])
          end

          it 'has service brokers link' do
            check_filter_link('ServiceKeys', 25, 'ServiceBrokers', cc_service_broker[:guid])
          end

          it 'has spaces link' do
            check_filter_link('ServiceKeys', 29, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('ServiceKeys', 30, 'Organizations', cc_organization[:guid])
          end
        end
      end

      context 'Organization Roles' do
        let(:tab_id)   { 'OrganizationRoles' }
        let(:table_id) { 'OrganizationRolesTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='OrganizationRolesTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 4,
                                 labels:          ['', 'Organization', 'User', ''],
                                 colspans:        %w(1 2 2 1)
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='OrganizationRolesTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 6,
                                 labels:          ['', 'Name', 'GUID', 'Name', 'GUID', 'Role'],
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
          check_allowscriptaccess_attribute('Buttons_OrganizationRolesTable_1')
        end

        context 'manage organization roles' do
          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_OrganizationRolesTable_0').text).to eq('Delete')
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_OrganizationRolesTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)               { 'Buttons_OrganizationRolesTable_0' }
              let(:check_no_data_available) { false }
              let(:confirm_message)         { 'Are you sure you want to delete the selected organization roles?' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Organization',      tag: 'div', value: cc_organization[:name] },
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
        let(:tab_id)   { 'SpaceRoles' }
        let(:table_id) { 'SpaceRolesTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='SpaceRolesTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 4,
                                 labels:          ['', 'Space', 'User', ''],
                                 colspans:        %w(1 3 2 1)
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='SpaceRolesTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 7,
                                 labels:          ['', 'Name', 'GUID', 'Target', 'Name', 'GUID', 'Role'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='SpaceRolesTable']/tbody/tr/td"),
                           [
                             '',
                             cc_space[:name],
                             cc_space[:guid],
                             "#{cc_organization[:name]}/#{cc_space[:name]}",
                             uaa_user[:username],
                             uaa_user[:id],
                             'Auditor'
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_SpaceRolesTable_1')
        end

        context 'manage space roles' do
          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_SpaceRolesTable_0').text).to eq('Delete')
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_SpaceRolesTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)               { 'Buttons_SpaceRolesTable_0' }
              let(:check_no_data_available) { false }
              let(:confirm_message)         { 'Are you sure you want to delete the selected space roles?' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Space',        tag: 'div', value: cc_space[:name] },
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
        let(:tab_id)     { 'Clients' }
        let(:table_id)   { 'ClientsTable' }
        let(:event_type) { 'service_dashboard_client' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ClientsTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 10,
                                 labels:          ['', 'Identity Zone', 'Identifier', 'Scopes', 'Authorized Grant Types', 'Redirect URIs', 'Authorities', 'Auto Approve', 'Events', 'Service Broker'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='ClientsTable']/tbody/tr/td"),
                           [
                             '',
                             uaa_identity_zone[:name],
                             uaa_client[:client_id],
                             uaa_client[:scope],
                             uaa_client[:authorized_grant_types],
                             uaa_client[:web_server_redirect_uri],
                             uaa_client[:authorities],
                             uaa_client_autoapprove.to_s,
                             '1',
                             cc_service_broker[:name]
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_ClientsTable_1')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('ClientsTable', uaa_client[:client_id])
        end

        context 'manage clients' do
          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_ClientsTable_0').text).to eq('Delete')
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ClientsTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_ClientsTable_0' }
              let(:confirm_message) { 'Are you sure you want to delete the selected clients?' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Identity Zone',          tag:   'a', value: uaa_identity_zone[:name] },
                            { label: 'Identifier',             tag: 'div', value: uaa_client[:client_id] },
                            { label: 'Scope',                  tag:   nil, value: uaa_client[:scope] },
                            { label: 'Authorized Grant Type',  tag:   nil, value: uaa_client[:authorized_grant_types] },
                            { label: 'Redirect URI',           tag:   nil, value: uaa_client[:web_server_redirect_uri] },
                            { label: 'Authority',              tag:   nil, value: uaa_client[:authorities] },
                            { label: 'Auto Approve',           tag:   nil, value: uaa_client_autoapprove.to_s },
                            { label: 'Show on Home Page',      tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{uaa_client[:show_on_home_page]})") },
                            { label: 'App Launch URL',         tag:   'a', value: uaa_client[:app_launch_url] },
                            { label: 'Events',                 tag:   'a', value: '1' },
                            { label: 'Additional Information', tag:   nil, value: uaa_client[:additional_information] },
                            { label: 'Service Broker',         tag:   'a', value: cc_service_broker[:name] }
                          ])
          end

          it 'has identity zones link' do
            check_filter_link('Clients', 0, 'IdentityZones', uaa_identity_zone[:id])
          end

          it 'has events link' do
            check_filter_link('Clients', 9, 'Events', uaa_client[:client_id])
          end

          it 'has service brokers link' do
            check_filter_link('Clients', 11, 'ServiceBrokers', cc_service_broker[:guid])
          end
        end
      end

      context 'Users' do
        let(:tab_id)   { 'Users' }
        let(:table_id) { 'UsersTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='UsersTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 4,
                                 labels:          ['', '', 'Organization Roles', 'Space Roles', ''],
                                 colspans:        %w(1 13 5 4)
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='UsersTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 23,
                                 labels:          ['', 'Identity Zone', 'Username', 'GUID', 'Created', 'Updated', 'Password Updated', 'Email', 'Family Name', 'Given Name', 'Active', 'Version', 'Groups', 'Events', 'Total', 'Auditor', 'Billing Manager', 'Manager', 'User', 'Total', 'Auditor', 'Developer', 'Manager'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='UsersTable']/tbody/tr/td"),
                           [
                             '',
                             uaa_identity_zone[:name],
                             uaa_user[:username],
                             uaa_user[:id],
                             uaa_user[:created].to_datetime.rfc3339,
                             uaa_user[:lastmodified].to_datetime.rfc3339,
                             uaa_user[:passwd_lastmodified].to_datetime.rfc3339,
                             uaa_user[:email],
                             uaa_user[:familyname],
                             uaa_user[:givenname],
                             @driver.execute_script("return Format.formatBoolean(#{uaa_user[:active]})"),
                             @driver.execute_script("return Format.formatNumber(#{uaa_user[:version]})"),
                             uaa_group[:displayname],
                             '1',
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
          check_allowscriptaccess_attribute('Buttons_UsersTable_1')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('UsersTable', uaa_user[:id])
        end

        context 'manage users' do
          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_UsersTable_0').text).to eq('Delete')
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_UsersTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_UsersTable_0' }
              let(:confirm_message) { 'Are you sure you want to delete the selected users?' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Identity Zone',                      tag:   'a', value: uaa_identity_zone[:name] },
                            { label: 'Username',                           tag: 'div', value: uaa_user[:username] },
                            { label: 'GUID',                               tag:   nil, value: uaa_user[:id] },
                            { label: 'Created',                            tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_user[:created].to_datetime.rfc3339}\")") },
                            { label: 'Updated',                            tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_user[:lastmodified].to_datetime.rfc3339}\")") },
                            { label: 'Password Updated',                   tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_user[:passwd_lastmodified].to_datetime.rfc3339}\")") },
                            { label: 'Email',                              tag:   'a', value: "mailto:#{uaa_user[:email]}" },
                            { label: 'Family Name',                        tag:   nil, value: uaa_user[:familyname] },
                            { label: 'Given Name',                         tag:   nil, value: uaa_user[:givenname] },
                            { label: 'Active',                             tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{uaa_user[:active]})") },
                            { label: 'Version',                            tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{uaa_user[:version]})") },
                            { label: 'Group',                              tag:   'a', value: uaa_group[:displayname] },
                            { label: 'Events',                             tag:   'a', value: '1' },
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

          it 'has identity zones link' do
            check_filter_link('Users', 0, 'IdentityZones', uaa_identity_zone[:id])
          end

          it 'has groups link' do
            check_filter_link('Users', 11, 'Groups', uaa_group[:displayname])
          end

          it 'has events link' do
            check_filter_link('Users', 12, 'Events', uaa_user[:id])
          end

          it 'has organization roles link' do
            check_filter_link('Users', 13, 'OrganizationRoles', uaa_user[:id])
          end

          it 'has space roles link' do
            check_filter_link('Users', 18, 'SpaceRoles', uaa_user[:id])
          end
        end
      end

      context 'Groups' do
        let(:tab_id)   { 'Groups' }
        let(:table_id) { 'GroupsTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='GroupsTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 8,
                                 labels:          ['', 'Identity Zone', 'Name', 'GUID', 'Created', 'Updated', 'Version', 'Members'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='GroupsTable']/tbody/tr/td"),
                           [
                             '',
                             uaa_identity_zone[:name],
                             uaa_group[:name],
                             uaa_group[:id],
                             uaa_group[:created].to_datetime.rfc3339,
                             uaa_group[:lastmodified].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatNumber(#{uaa_group[:version]})"),
                             '1'
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_GroupsTable_1')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('GroupsTable', uaa_group[:id])
        end

        context 'manage groups' do
          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_GroupsTable_0').text).to eq('Delete')
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_GroupsTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_GroupsTable_0' }
              let(:confirm_message) { 'Are you sure you want to delete the selected groups?' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Identity Zone', tag:   'a', value: uaa_identity_zone[:name] },
                            { label: 'Name',          tag: 'div', value: uaa_group[:displayname] },
                            { label: 'GUID',          tag:   nil, value: uaa_group[:id] },
                            { label: 'Created',       tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_group[:created].to_datetime.rfc3339}\")") },
                            { label: 'Updated',       tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_group[:lastmodified].to_datetime.rfc3339}\")") },
                            { label: 'Version',       tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{uaa_group[:version]})") },
                            { label: 'Description',   tag:   nil, value: uaa_group[:description] },
                            { label: 'Members',       tag:   'a', value: '1' }
                          ])
          end

          it 'has identity zones link' do
            check_filter_link('Groups', 0, 'IdentityZones', uaa_identity_zone[:id])
          end

          it 'has userslink' do
            check_filter_link('Groups', 7, 'Users', uaa_group[:displayname])
          end
        end
      end

      context 'Buildpacks' do
        let(:tab_id)   { 'Buildpacks' }
        let(:table_id) { 'BuildpacksTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='BuildpacksTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 8,
                                 labels:          ['', 'Name', 'GUID', 'Created', 'Updated', 'Position', 'Enabled', 'Locked'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='BuildpacksTable']/tbody/tr/td"),
                           [
                             '',
                             cc_buildpack[:name],
                             cc_buildpack[:guid],
                             cc_buildpack[:created_at].to_datetime.rfc3339,
                             cc_buildpack[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatNumber(#{cc_buildpack[:position]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_buildpack[:enabled]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_buildpack[:locked]})")
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_BuildpacksTable_6')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('BuildpacksTable', cc_buildpack[:guid])
        end

        context 'manage buildpack' do
          def manage_buildpack(button_index)
            check_first_row('BuildpacksTable')

            # TODO: Bug in selenium-webdriver.  Entire item must be displayed for it to click.  Workaround following after commented out code
            # @driver.find_element(id: 'Buttons_BuildpacksTable_' + button_index.to_s).click
            @driver.execute_script('arguments[0].click();', @driver.find_element(id: 'Buttons_BuildpacksTable_' + button_index.to_s))

            check_operation_result
          end

          def check_buildpack_enabled(enabled)
            begin
              Selenium::WebDriver::Wait.new(timeout: 5).until { refresh_button && @driver.find_element(xpath: "//table[@id='BuildpacksTable']/tbody/tr/td[7]").text == enabled }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='BuildpacksTable']/tbody/tr/td[7]").text).to eq(enabled)
          end

          def check_buildpack_locked(locked)
            begin
              Selenium::WebDriver::Wait.new(timeout: 5).until { refresh_button && @driver.find_element(xpath: "//table[@id='BuildpacksTable']/tbody/tr/td[8]").text == locked }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='BuildpacksTable']/tbody/tr/td[8]").text).to eq(locked)
          end

          it 'has a Rename button' do
            expect(@driver.find_element(id: 'Buttons_BuildpacksTable_0').text).to eq('Rename')
          end

          it 'has an Enable button' do
            expect(@driver.find_element(id: 'Buttons_BuildpacksTable_1').text).to eq('Enable')
          end

          it 'has a Disable button' do
            expect(@driver.find_element(id: 'Buttons_BuildpacksTable_2').text).to eq('Disable')
          end

          it 'has a Lock button' do
            expect(@driver.find_element(id: 'Buttons_BuildpacksTable_3').text).to eq('Lock')
          end

          it 'has an Unlock button' do
            expect(@driver.find_element(id: 'Buttons_BuildpacksTable_4').text).to eq('Unlock')
          end

          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_BuildpacksTable_5').text).to eq('Delete')
          end

          context 'Rename button' do
            it_behaves_like('click button without selecting exactly one row') do
              let(:button_id) { 'Buttons_BuildpacksTable_0' }
            end
          end

          context 'Enable button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_BuildpacksTable_1' }
            end
          end

          context 'Disable button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_BuildpacksTable_2' }
            end
          end

          context 'Lock button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_BuildpacksTable_3' }
            end
          end

          context 'Unlock button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_BuildpacksTable_4' }
            end
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_BuildpacksTable_5' }
            end
          end

          context 'Rename button' do
            it_behaves_like('rename first row') do
              let(:button_id)     { 'Buttons_BuildpacksTable_0' }
              let(:title_text)    { 'Rename Buildpack' }
              let(:object_rename) { cc_buildpack_rename }
            end
          end

          it 'disables the selected buildpack' do
            manage_buildpack(2)
            check_buildpack_enabled('false')
          end

          it 'enables the selected buildpack' do
            manage_buildpack(2)
            check_buildpack_enabled('false')
            manage_buildpack(1)
            check_buildpack_enabled('true')
          end

          it 'locks the selected buildpack' do
            manage_buildpack(3)
            check_buildpack_locked('true')
          end

          it 'unlocks the selected buildpack' do
            manage_buildpack(3)
            check_buildpack_locked('true')
            manage_buildpack(4)
            check_buildpack_locked('false')
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_BuildpacksTable_5' }
              let(:confirm_message) { 'Are you sure you want to delete the selected buildpacks?' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Name',     tag: 'div', value: cc_buildpack[:name] },
                            { label: 'GUID',     tag:   nil, value: cc_buildpack[:guid] },
                            { label: 'Created',  tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_buildpack[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Updated',  tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_buildpack[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Position', tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_buildpack[:position]})") },
                            { label: 'Enabled',  tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_buildpack[:enabled]})") },
                            { label: 'Locked',   tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_buildpack[:locked]})") },
                            { label: 'Key',      tag:   nil, value: cc_buildpack[:key] },
                            { label: 'Filename', tag:   nil, value: cc_buildpack[:filename] }
                          ])
          end
        end
      end

      context 'Domains' do
        let(:tab_id)   { 'Domains' }
        let(:table_id) { 'DomainsTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='DomainsTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 8,
                                 labels:          ['', 'Name', 'GUID', 'Created', 'Updated', 'Owning Organization', 'Private Shared Organizations', 'Routes'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='DomainsTable']/tbody/tr/td"),
                           [
                             '',
                             cc_domain[:name],
                             cc_domain[:guid],
                             cc_domain[:created_at].to_datetime.rfc3339,
                             cc_domain[:updated_at].to_datetime.rfc3339,
                             cc_organization[:name],
                             '1',
                             '1'
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_DomainsTable_2')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('DomainsTable', cc_domain[:guid])
        end

        context 'manage domains' do
          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_DomainsTable_0').text).to eq('Delete')
          end

          it 'has a Delete Recursive button' do
            expect(@driver.find_element(id: 'Buttons_DomainsTable_1').text).to eq('Delete Recursive')
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_DomainsTable_0' }
            end
          end

          context 'Delete Recursive button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_DomainsTable_1' }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_DomainsTable_0' }
              let(:confirm_message) { 'Are you sure you want to delete the selected domains?' }
            end
          end

          context 'Delete Recursive button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_DomainsTable_1' }
              let(:confirm_message) { 'Are you sure you want to delete the selected domains and their associated routes and route bindings?' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Name',                tag: 'div', value: cc_domain[:name] },
                            { label: 'GUID',                tag:   nil, value: cc_domain[:guid] },
                            { label: 'Created',             tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_domain[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Updated',             tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_domain[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Owning Organization', tag:   'a', value: cc_organization[:name] },
                            { label: 'Routes',              tag:   'a', value: '1' }
                          ])
          end

          it 'has private shared organizations' do
            expect(@driver.find_element(id: 'DomainsOrganizationsDetailsLabel').displayed?).to be(true)

            check_table_headers(columns:         @driver.find_elements(xpath: "//div[@id='DomainsOrganizationsTableContainer']/div[2]/div[4]/div/div/table/thead/tr/th"),
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
            check_allowscriptaccess_attribute('Buttons_DomainsOrganizationsTable_0')
          end

          it 'has organizations link' do
            check_filter_link('Domains', 4, 'Organizations', cc_organization[:guid])
          end

          it 'has routes link' do
            check_filter_link('Domains', 5, 'Routes', cc_domain[:name])
          end
        end
      end

      context 'Feature Flags' do
        let(:tab_id)   { 'FeatureFlags' }
        let(:table_id) { 'FeatureFlagsTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='FeatureFlagsTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 6,
                                 labels:          ['', 'Name', 'GUID', 'Created', 'Updated', 'Enabled'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='FeatureFlagsTable']/tbody/tr/td"),
                           [
                             '',
                             cc_feature_flag[:name],
                             cc_feature_flag[:guid],
                             cc_feature_flag[:created_at].to_datetime.rfc3339,
                             cc_feature_flag[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{cc_feature_flag[:enabled]})")
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_FeatureFlagsTable_2')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('FeatureFlagsTable', cc_feature_flag[:name])
        end

        context 'manage feature flag' do
          def manage_feature_flag(button_index)
            check_first_row('FeatureFlagsTable')

            # TODO: Bug in selenium-webdriver.  Entire item must be displayed for it to click.  Workaround following after commented out code
            # @driver.find_element(id: 'Buttons_FeatureFlagsTable_' + button_index.to_s).click
            @driver.execute_script('arguments[0].click();', @driver.find_element(id: 'Buttons_FeatureFlagsTable_' + button_index.to_s))

            check_operation_result
          end

          def check_feature_flag_enabled(enabled)
            begin
              Selenium::WebDriver::Wait.new(timeout: 5).until { refresh_button && @driver.find_element(xpath: "//table[@id='FeatureFlagsTable']/tbody/tr/td[6]").text == enabled }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='FeatureFlagsTable']/tbody/tr/td[6]").text).to eq(enabled)
          end

          it 'has an Enable button' do
            expect(@driver.find_element(id: 'Buttons_FeatureFlagsTable_0').text).to eq('Enable')
          end

          it 'has a Disable button' do
            expect(@driver.find_element(id: 'Buttons_FeatureFlagsTable_1').text).to eq('Disable')
          end

          context 'Enable button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_FeatureFlagsTable_0' }
            end
          end

          context 'Disable button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_FeatureFlagsTable_1' }
            end
          end

          it 'disables the selected feature flag' do
            manage_feature_flag(1)
            check_feature_flag_enabled('false')
          end

          it 'enables the selected feature flag' do
            manage_feature_flag(1)
            check_feature_flag_enabled('false')
            manage_feature_flag(0)
            check_feature_flag_enabled('true')
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Name',          tag: 'div', value: cc_feature_flag[:name] },
                            { label: 'GUID',          tag:   nil, value: cc_feature_flag[:guid] },
                            { label: 'Created',       tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_feature_flag[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Updated',       tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_feature_flag[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Enabled',       tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_feature_flag[:enabled]})") },
                            { label: 'Error Message', tag:   nil, value: cc_feature_flag[:error_message] }
                          ])
          end
        end
      end

      context 'Quotas' do
        let(:tab_id)   { 'Quotas' }
        let(:table_id) { 'QuotasTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='QuotasTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 16,
                                 labels:          ['', 'Name', 'GUID', 'Created', 'Updated', 'Total Private Domains', 'Total Services', 'Total Service Keys', 'Total Routes', 'Total Reserved Route Ports', 'Application Instance Limit', 'Application Task Limit', 'Memory Limit', 'Instance Memory Limit', 'Non-Basic Services Allowed', 'Organizations'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='QuotasTable']/tbody/tr/td"),
                           [
                             '',
                             cc_quota_definition[:name],
                             cc_quota_definition[:guid],
                             cc_quota_definition[:created_at].to_datetime.rfc3339,
                             cc_quota_definition[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatNumber(#{cc_quota_definition[:total_private_domains]})"),
                             @driver.execute_script("return Format.formatNumber(#{cc_quota_definition[:total_services]})"),
                             @driver.execute_script("return Format.formatNumber(#{cc_quota_definition[:total_service_keys]})"),
                             @driver.execute_script("return Format.formatNumber(#{cc_quota_definition[:total_routes]})"),
                             @driver.execute_script("return Format.formatNumber(#{cc_quota_definition[:total_reserved_route_ports]})"),
                             @driver.execute_script("return Format.formatNumber(#{cc_quota_definition[:app_instance_limit]})"),
                             @driver.execute_script("return Format.formatNumber(#{cc_quota_definition[:app_task_limit]})"),
                             @driver.execute_script("return Format.formatNumber(#{cc_quota_definition[:memory_limit]})"),
                             @driver.execute_script("return Format.formatNumber(#{cc_quota_definition[:instance_memory_limit]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_quota_definition[:non_basic_services_allowed]})"),
                             '1'
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_QuotasTable_2')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('QuotasTable', cc_quota_definition[:guid])
        end

        context 'manage quotas' do
          it 'has a Rename button' do
            expect(@driver.find_element(id: 'Buttons_QuotasTable_0').text).to eq('Rename')
          end

          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_QuotasTable_1').text).to eq('Delete')
          end

          context 'Rename button' do
            it_behaves_like('click button without selecting exactly one row') do
              let(:button_id) { 'Buttons_QuotasTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_QuotasTable_1' }
            end
          end

          context 'Rename button' do
            it_behaves_like('rename first row') do
              let(:button_id)     { 'Buttons_QuotasTable_0' }
              let(:title_text)    { 'Rename Quota Definition' }
              let(:object_rename) { cc_quota_definition_rename }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_QuotasTable_1' }
              let(:confirm_message) { 'Are you sure you want to delete the selected quota definitions?' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Name',                       tag: 'div', value: cc_quota_definition[:name] },
                            { label: 'GUID',                       tag:   nil, value: cc_quota_definition[:guid] },
                            { label: 'Created',                    tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_quota_definition[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Updated',                    tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_quota_definition[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Total Private Domains',      tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_quota_definition[:total_private_domains]})") },
                            { label: 'Total Services',             tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_quota_definition[:total_services]})") },
                            { label: 'Total Service Keys',         tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_quota_definition[:total_service_keys]})") },
                            { label: 'Total Routes',               tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_quota_definition[:total_routes]})") },
                            { label: 'Total Reserved Route Ports', tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_quota_definition[:total_reserved_route_ports]})") },
                            { label: 'Application Instance Limit', tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_quota_definition[:app_instance_limit]})") },
                            { label: 'Application Task Limit',     tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_quota_definition[:app_task_limit]})") },
                            { label: 'Memory Limit',               tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_quota_definition[:memory_limit]})") },
                            { label: 'Instance Memory Limit',      tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_quota_definition[:instance_memory_limit]})") },
                            { label: 'Non-Basic Services Allowed', tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_quota_definition[:non_basic_services_allowed]})") },
                            { label: 'Organizations',              tag:   'a', value: '1' }
                          ])
          end

          it 'has organizations link' do
            check_filter_link('Quotas', 14, 'Organizations', cc_quota_definition[:name])
          end
        end
      end

      context 'Space Quotas' do
        let(:tab_id)   { 'SpaceQuotas' }
        let(:table_id) { 'SpaceQuotasTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='SpaceQuotasTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 3,
                                 labels:          ['', '', 'Organization'],
                                 colspans:        %w(1 14 2)
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='SpaceQuotasTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 17,
                                 labels:          ['', 'Name', 'GUID', 'Created', 'Updated', 'Total Services', 'Total Service Keys', 'Total Routes', 'Total Reserved Route Ports', 'Application Instance Limit', 'Application Task Limit', 'Memory Limit', 'Instance Memory Limit', 'Non-Basic Services Allowed', 'Spaces', 'Name', 'GUID'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='SpaceQuotasTable']/tbody/tr/td"),
                           [
                             '',
                             cc_space_quota_definition[:name],
                             cc_space_quota_definition[:guid],
                             cc_space_quota_definition[:created_at].to_datetime.rfc3339,
                             cc_space_quota_definition[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatNumber(#{cc_space_quota_definition[:total_services]})"),
                             @driver.execute_script("return Format.formatNumber(#{cc_space_quota_definition[:total_service_keys]})"),
                             @driver.execute_script("return Format.formatNumber(#{cc_space_quota_definition[:total_routes]})"),
                             @driver.execute_script("return Format.formatNumber(#{cc_space_quota_definition[:total_reserved_route_ports]})"),
                             @driver.execute_script("return Format.formatNumber(#{cc_space_quota_definition[:app_instance_limit]})"),
                             @driver.execute_script("return Format.formatNumber(#{cc_space_quota_definition[:app_task_limit]})"),
                             @driver.execute_script("return Format.formatNumber(#{cc_space_quota_definition[:memory_limit]})"),
                             @driver.execute_script("return Format.formatNumber(#{cc_space_quota_definition[:instance_memory_limit]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_space_quota_definition[:non_basic_services_allowed]})"),
                             '1',
                             cc_organization[:name],
                             cc_organization[:guid]
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_SpaceQuotasTable_2')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('SpaceQuotasTable', cc_space_quota_definition[:guid])
        end

        context 'manage space quotas' do
          it 'has a Rename button' do
            expect(@driver.find_element(id: 'Buttons_SpaceQuotasTable_0').text).to eq('Rename')
          end

          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_SpaceQuotasTable_1').text).to eq('Delete')
          end

          context 'Rename button' do
            it_behaves_like('click button without selecting exactly one row') do
              let(:button_id) { 'Buttons_SpaceQuotasTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_SpaceQuotasTable_1' }
            end
          end

          context 'Rename button' do
            it_behaves_like('rename first row') do
              let(:button_id)     { 'Buttons_SpaceQuotasTable_0' }
              let(:title_text)    { 'Rename Space Quota Definition' }
              let(:object_rename) { cc_space_quota_definition_rename }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_SpaceQuotasTable_1' }
              let(:confirm_message) { 'Are you sure you want to delete the selected space quota definitions?' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Name',                       tag: 'div', value: cc_space_quota_definition[:name] },
                            { label: 'GUID',                       tag:   nil, value: cc_space_quota_definition[:guid] },
                            { label: 'Created',                    tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_space_quota_definition[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Updated',                    tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_space_quota_definition[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Total Services',             tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_space_quota_definition[:total_services]})") },
                            { label: 'Total Service Keys',         tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_space_quota_definition[:total_service_keys]})") },
                            { label: 'Total Routes',               tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_space_quota_definition[:total_routes]})") },
                            { label: 'Total Reserved Route Ports', tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_space_quota_definition[:total_reserved_route_ports]})") },
                            { label: 'Application Instance Limit', tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_space_quota_definition[:app_instance_limit]})") },
                            { label: 'Application Task Limit',     tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_space_quota_definition[:app_task_limit]})") },
                            { label: 'Memory Limit',               tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_space_quota_definition[:memory_limit]})") },
                            { label: 'Instance Memory Limit',      tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_space_quota_definition[:instance_memory_limit]})") },
                            { label: 'Non-Basic Services Allowed', tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_space_quota_definition[:non_basic_services_allowed]})") },
                            { label: 'Spaces',                     tag:   'a', value: '1' },
                            { label: 'Organization',               tag:   'a', value: cc_organization[:name] }
                          ])
          end

          it 'has spaces link' do
            check_filter_link('SpaceQuotas', 13, 'Spaces', cc_space_quota_definition[:name])
          end

          it 'has organizations link' do
            check_filter_link('SpaceQuotas', 14, 'Organizations', cc_organization[:guid])
          end
        end
      end

      context 'Stacks' do
        let(:tab_id) { 'Stacks' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='StacksTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 7,
                                 labels:          ['Name', 'GUID', 'Created', 'Updated', 'Applications', 'Application Instances', 'Description'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='StacksTable']/tbody/tr/td"),
                           [
                             cc_stack[:name],
                             cc_stack[:guid],
                             cc_stack[:created_at].to_datetime.rfc3339,
                             cc_stack[:updated_at].to_datetime.rfc3339,
                             '1',
                             @driver.execute_script("return Format.formatNumber(#{cc_app[:instances]})"),
                             cc_stack[:description]
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_StacksTable_0')
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Name',                  tag: 'div', value: cc_stack[:name] },
                            { label: 'GUID',                  tag:   nil, value: cc_stack[:guid] },
                            { label: 'Created',               tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_quota_definition[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Updated',               tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_quota_definition[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Description',           tag:   nil, value: cc_stack[:description] },
                            { label: 'Applications',          tag:   'a', value: '1' },
                            { label: 'Application Instances', tag:   'a', value: @driver.execute_script("return Format.formatNumber(#{cc_app[:instances]})") }
                          ])
          end

          it 'has applications link' do
            check_filter_link('Stacks', 5, 'Applications', cc_stack[:name])
          end

          it 'has application instances link' do
            check_filter_link('Stacks', 6, 'ApplicationInstances', cc_stack[:name])
          end
        end
      end

      context 'Events' do
        let(:tab_id) { 'Events' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='EventsTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 4,
                                 labels:          ['', 'Actee', 'Actor', ''],
                                 colspans:        %w(3 3 3 1)
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='EventsTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 10,
                                 labels:          %w(Timestamp GUID Type Type Name GUID Type Name GUID Target),
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='EventsTable']/tbody/tr/td"),
                           [
                             cc_event_space[:timestamp].to_datetime.rfc3339,
                             cc_event_space[:guid],
                             cc_event_space[:type],
                             cc_event_space[:actee_type],
                             cc_event_space[:actee_name],
                             cc_event_space[:actee],
                             cc_event_space[:actor_type],
                             cc_event_space[:actor_name],
                             cc_event_space[:actor],
                             "#{cc_organization[:name]}/#{cc_space[:name]}"
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_EventsTable_0')
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Event Timestamp', tag: 'div', value: @driver.execute_script("return Format.formatDateString(\"#{cc_event_space[:timestamp].to_datetime.rfc3339}\")") },
                            { label: 'Event GUID',      tag:   nil, value: cc_event_space[:guid] },
                            { label: 'Event Type',      tag:   nil, value: cc_event_space[:type] },
                            { label: 'Actee Type',      tag:   nil, value: cc_event_space[:actee_type] },
                            { label: 'Actee',           tag:   nil, value: cc_event_space[:actee_name] },
                            { label: 'Actee GUID',      tag:   'a', value: cc_event_space[:actee] },
                            { label: 'Actor Type',      tag:   nil, value: cc_event_space[:actor_type] },
                            { label: 'Actor',           tag:   nil, value: cc_event_space[:actor_name] },
                            { label: 'Actor GUID',      tag:   'a', value: cc_event_space[:actor] },
                            { label: 'Space',           tag:   'a', value: cc_space[:name] },
                            { label: 'Organization',    tag:   'a', value: cc_organization[:name] }
                          ])
          end

          it 'has spaces actee link' do
            check_filter_link('Events', 5, 'Spaces', cc_event_space[:actee])
          end

          it 'has users actor link' do
            check_filter_link('Events', 8, 'Users', cc_event_space[:actor])
          end

          it 'has spaces link' do
            check_filter_link('Events', 9, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('Events', 10, 'Organizations', cc_organization[:guid])
          end

          context 'app event' do
            let(:event_type) { 'app' }

            it 'has applications actee link' do
              check_filter_link('Events', 5, 'Applications', cc_event_app[:actee])
            end

            it 'has users actor link' do
              check_filter_link('Events', 8, 'Users', cc_event_app[:actor])
            end

            it 'has spaces link' do
              check_filter_link('Events', 9, 'Spaces', cc_space[:guid])
            end

            it 'has organizations link' do
              check_filter_link('Events', 10, 'Organizations', cc_organization[:guid])
            end
          end

          context 'client event' do
            let(:event_type) { 'service_dashboard_client' }

            it 'has clients actee link' do
              check_filter_link('Events', 5, 'Clients', cc_event_service_dashboard_client[:actee])
            end

            it 'has service brokers actor link' do
              check_filter_link('Events', 8, 'ServiceBrokers', cc_event_service_dashboard_client[:actor])
            end
          end

          context 'route event' do
            let(:event_type) { 'route' }

            it 'has route link' do
              check_filter_link('Events', 5, 'Routes', cc_event_route[:actee])
            end

            it 'has users actor link' do
              check_filter_link('Events', 8, 'Users', cc_event_route[:actor])
            end

            it 'has spaces link' do
              check_filter_link('Events', 9, 'Spaces', cc_space[:guid])
            end

            it 'has organizations link' do
              check_filter_link('Events', 10, 'Organizations', cc_organization[:guid])
            end
          end

          context 'service instance event' do
            let(:event_type) { 'service_instance' }

            it 'has service instances actee link' do
              check_filter_link('Events', 5, 'ServiceInstances', cc_event_service_instance[:actee])
            end

            it 'has users actor link' do
              check_filter_link('Events', 8, 'Users', cc_event_service_instance[:actor])
            end

            it 'has spaces link' do
              check_filter_link('Events', 9, 'Spaces', cc_space[:guid])
            end

            it 'has organizations link' do
              check_filter_link('Events', 10, 'Organizations', cc_organization[:guid])
            end
          end

          context 'service binding event' do
            let(:event_type) { 'service_binding' }

            it 'has service bindings actee link' do
              check_filter_link('Events', 4, 'ServiceBindings', cc_event_service_binding[:actee])
            end

            it 'has users actor link' do
              check_filter_link('Events', 7, 'Users', cc_event_service_binding[:actor])
            end

            it 'has spaces link' do
              check_filter_link('Events', 8, 'Spaces', cc_space[:guid])
            end

            it 'has organizations link' do
              check_filter_link('Events', 9, 'Organizations', cc_organization[:guid])
            end
          end

          context 'service broker event' do
            let(:event_type) { 'service_broker' }

            it 'has service brokers actee link' do
              check_filter_link('Events', 5, 'ServiceBrokers', cc_event_service_broker[:actee])
            end

            it 'has users actor link' do
              check_filter_link('Events', 8, 'Users', cc_event_service_broker[:actor])
            end
          end

          context 'service event' do
            let(:event_type) { 'service' }

            it 'has services actee link' do
              check_filter_link('Events', 5, 'Services', cc_event_service[:actee])
            end

            it 'has service brokers actor link' do
              check_filter_link('Events', 8, 'ServiceBrokers', cc_event_service[:actor])
            end
          end

          context 'service key event' do
            let(:event_type) { 'service_key' }

            it 'has service keys actee link' do
              check_filter_link('Events', 5, 'ServiceKeys', cc_event_service_key[:actee])
            end

            it 'has users actor link' do
              check_filter_link('Events', 8, 'Users', cc_event_service_key[:actor])
            end

            it 'has spaces link' do
              check_filter_link('Events', 9, 'Spaces', cc_space[:guid])
            end

            it 'has organizations link' do
              check_filter_link('Events', 10, 'Organizations', cc_organization[:guid])
            end
          end

          context 'service plan event' do
            let(:event_type) { 'service_plan' }

            it 'has service plans actee link' do
              check_filter_link('Events', 5, 'ServicePlans', cc_event_service_plan[:actee])
            end

            it 'has service brokers actor link' do
              check_filter_link('Events', 8, 'ServiceBrokers', cc_event_service_plan[:actor])
            end
          end

          context 'service plan visibility event' do
            let(:event_type) { 'service_plan_visibility' }

            it 'has service plan visibilities actee link' do
              check_filter_link('Events', 4, 'ServicePlanVisibilities', cc_event_service_plan_visibility[:actee])
            end

            it 'has users actor link' do
              check_filter_link('Events', 7, 'Users', cc_event_service_plan_visibility[:actor])
            end

            it 'has organizations link' do
              check_filter_link('Events', 8, 'Organizations', cc_organization[:guid])
            end
          end
        end
      end

      context 'Service Brokers' do
        let(:tab_id)     { 'ServiceBrokers' }
        let(:table_id)   { 'ServiceBrokersTable' }
        let(:event_type) { 'service_broker' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ServiceBrokersTable_wrapper']/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 15,
                                 labels:          ['', 'Name', 'GUID', 'Created', 'Updated', 'Events', 'Service Dashboard Client', 'Services', 'Service Plans', 'Public Active Service Plans', 'Service Plan Visibilities', 'Service Instances', 'Service Bindings', 'Service Keys', 'Target'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='ServiceBrokersTable']/tbody/tr/td"),
                           [
                             '',
                             cc_service_broker[:name],
                             cc_service_broker[:guid],
                             cc_service_broker[:created_at].to_datetime.rfc3339,
                             cc_service_broker[:updated_at].to_datetime.rfc3339,
                             '1',
                             uaa_client[:client_id],
                             '1',
                             '1',
                             '1',
                             '1',
                             '1',
                             '1',
                             '1',
                             "#{cc_organization[:name]}/#{cc_space[:name]}"
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_ServiceBrokersTable_2')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('ServiceBrokersTable', cc_service_broker[:guid])
        end

        context 'manage service brokers' do
          it 'has a Rename button' do
            expect(@driver.find_element(id: 'Buttons_ServiceBrokersTable_0').text).to eq('Rename')
          end

          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_ServiceBrokersTable_1').text).to eq('Delete')
          end

          context 'Rename button' do
            it_behaves_like('click button without selecting exactly one row') do
              let(:button_id) { 'Buttons_ServiceBrokersTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ServiceBrokersTable_1' }
            end
          end

          context 'Rename button' do
            it_behaves_like('rename first row') do
              let(:button_id)     { 'Buttons_ServiceBrokersTable_0' }
              let(:title_text)    { 'Rename Service Broker' }
              let(:object_rename) { cc_service_broker_rename }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_ServiceBrokersTable_1' }
              let(:confirm_message) { 'Are you sure you want to delete the selected service brokers?' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Service Broker Name',          tag: 'div', value: cc_service_broker[:name] },
                            { label: 'Service Broker GUID',          tag:   nil, value: cc_service_broker[:guid] },
                            { label: 'Service Broker Created',       tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Broker Updated',       tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Broker Auth Username', tag:   nil, value: cc_service_broker[:auth_username] },
                            { label: 'Service Broker Broker URL',    tag:   nil, value: cc_service_broker[:broker_url] },
                            { label: 'Service Broker Events',        tag:   'a', value: '1' },
                            { label: 'Service Dashboard Client',     tag:   'a', value: uaa_client[:client_id] },
                            { label: 'Services',                     tag:   'a', value: '1' },
                            { label: 'Service Plans',                tag:   'a', value: '1' },
                            { label: 'Public Active Service Plans',  tag:   nil, value: '1' },
                            { label: 'Service Plan Visibilities',    tag:   'a', value: '1' },
                            { label: 'Service Instances',            tag:   'a', value: '1' },
                            { label: 'Service Bindings',             tag:   'a', value: '1' },
                            { label: 'Service Keys',                 tag:   'a', value: '1' },
                            { label: 'Space',                        tag:   'a', value: cc_space[:name] },
                            { label: 'Organization',                 tag:   'a', value: cc_organization[:name] }
                          ])
          end

          it 'has events link' do
            check_filter_link('ServiceBrokers', 6, 'Events', cc_service_broker[:guid])
          end

          it 'has clients link' do
            check_filter_link('ServiceBrokers', 7, 'Clients', uaa_client[:client_id])
          end

          it 'has services link' do
            check_filter_link('ServiceBrokers', 8, 'Services', cc_service_broker[:guid])
          end

          it 'has service plans link' do
            check_filter_link('ServiceBrokers', 9, 'ServicePlans', cc_service_broker[:guid])
          end

          it 'has service plan visibilities link' do
            check_filter_link('ServiceBrokers', 11, 'ServicePlanVisibilities', cc_service_broker[:guid])
          end

          it 'has service instances link' do
            check_filter_link('ServiceBrokers', 12, 'ServiceInstances', cc_service_broker[:guid])
          end

          it 'has service bindings link' do
            check_filter_link('ServiceBrokers', 13, 'ServiceBindings', cc_service_broker[:guid])
          end

          it 'has service keys link' do
            check_filter_link('ServiceBrokers', 14, 'ServiceKeys', cc_service_broker[:guid])
          end

          it 'has spaces link' do
            check_filter_link('ServiceBrokers', 15, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('ServiceBrokers', 16, 'Organizations', cc_organization[:guid])
          end
        end
      end

      context 'Services' do
        let(:tab_id)     { 'Services' }
        let(:table_id)   { 'ServicesTable' }
        let(:event_type) { 'service' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ServicesTable_wrapper']/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 3,
                                 labels:          ['', 'Service', 'Service Broker'],
                                 colspans:        %w(1 17 4)
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ServicesTable_wrapper']/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 22,
                                 labels:          ['', 'Provider', 'Label', 'GUID', 'Unique ID', 'Version', 'Created', 'Updated', 'Active', 'Bindable', 'Plan Updateable', 'Events', 'Service Plans', 'Public Active Service Plans', 'Service Plan Visibilities', 'Service Instances', 'Service Bindings', 'Service Keys', 'Name', 'GUID', 'Created', 'Updated'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='ServicesTable']/tbody/tr/td"),
                           [
                             '',
                             cc_service[:provider],
                             cc_service[:label],
                             cc_service[:guid],
                             cc_service[:unique_id],
                             cc_service[:version],
                             cc_service[:created_at].to_datetime.rfc3339,
                             cc_service[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service[:bindable]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service[:plan_updateable]})"),
                             '1',
                             '1',
                             '1',
                             '1',
                             '1',
                             '1',
                             '1',
                             cc_service_broker[:name],
                             cc_service_broker[:guid],
                             cc_service_broker[:created_at].to_datetime.rfc3339,
                             cc_service_broker[:updated_at].to_datetime.rfc3339
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_ServicesTable_2')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('ServicesTable', cc_service[:guid])
        end

        context 'manage services' do
          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_ServicesTable_0').text).to eq('Delete')
          end

          it 'has a Purge button' do
            expect(@driver.find_element(id: 'Buttons_ServicesTable_1').text).to eq('Purge')
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ServicesTable_0' }
            end
          end

          context 'Purge button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ServicesTable_1' }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_ServicesTable_0' }
              let(:confirm_message) { 'Are you sure you want to delete the selected services?' }
            end
          end

          context 'Purge button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_ServicesTable_1' }
              let(:confirm_message) { 'Are you sure you want to purge the selected services?' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            service_tags_json = Yajl::Parser.parse(cc_service[:tags])
            service_extra_json = Yajl::Parser.parse(cc_service[:extra])
            check_details([
                            { label: 'Service Provider',              tag:   nil, value: cc_service[:provider] },
                            { label: 'Service Label',                 tag: 'div', value: cc_service[:label] },
                            { label: 'Service GUID',                  tag:   nil, value: cc_service[:guid] },
                            { label: 'Service Unique ID',             tag:   nil, value: cc_service[:unique_id] },
                            { label: 'Service Version',               tag:   nil, value: cc_service[:version] },
                            { label: 'Service Created',               tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Updated',               tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Active',                tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})") },
                            { label: 'Service Bindable',              tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:bindable]})") },
                            { label: 'Service Plan Updateable',       tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:plan_updateable]})") },
                            { label: 'Service Description',           tag:   nil, value: cc_service[:description] },
                            { label: 'Service Tag',                   tag:   nil, value: service_tags_json[0] },
                            { label: 'Service Tag',                   tag:   nil, value: service_tags_json[1] },
                            { label: 'Service Documentation URL',     tag:   'a', value: cc_service[:documentation_url] },
                            { label: 'Service Info URL',              tag:   'a', value: cc_service[:info_url] },
                            { label: 'Service Display Name',          tag:   nil, value: service_extra_json['displayName'] },
                            { label: 'Service Provider Display Name', tag:   nil, value: service_extra_json['providerDisplayName'] },
                            { label: 'Service Icon',                  tag: 'img', value: @driver.execute_script("return Format.formatIconImage(\"#{service_extra_json['imageUrl']}\", \"service icon\", \"flot:left;\")").tr("'", '"') },
                            { label: 'Service Long Description',      tag:   nil, value: service_extra_json['longDescription'] },
                            { label: 'Service Documentation URL',     tag:   'a', value: service_extra_json['documentationUrl'] },
                            { label: 'Service Support URL',           tag:   'a', value: service_extra_json['supportUrl'] },
                            { label: 'Service Events',                tag:   'a', value: '1' },
                            { label: 'Service Plans',                 tag:   'a', value: '1' },
                            { label: 'Public Active Service Plans',   tag:   nil, value: '1' },
                            { label: 'Service Plan Visibilities',     tag:   'a', value: '1' },
                            { label: 'Service Instances',             tag:   'a', value: '1' },
                            { label: 'Service Bindings',              tag:   'a', value: '1' },
                            { label: 'Service Keys',                  tag:   'a', value: '1' },
                            { label: 'Service Broker Name',           tag:   'a', value: cc_service_broker[:name] },
                            { label: 'Service Broker GUID',           tag:   nil, value: cc_service_broker[:guid] },
                            { label: 'Service Broker Created',        tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Broker Updated',        tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:updated_at].to_datetime.rfc3339}\")") }
                          ])
          end

          it 'has events link' do
            check_filter_link('Services', 21, 'Events', cc_service[:guid])
          end

          it 'has service plans link' do
            check_filter_link('Services', 22, 'ServicePlans', cc_service[:guid])
          end

          it 'has service plan visibilities link' do
            check_filter_link('Services', 24, 'ServicePlanVisibilities', cc_service[:guid])
          end

          it 'has service instances link' do
            check_filter_link('Services', 25, 'ServiceInstances', cc_service[:guid])
          end

          it 'has service bindings link' do
            check_filter_link('Services', 26, 'ServiceBindings', cc_service[:guid])
          end

          it 'has service keys link' do
            check_filter_link('Services', 27, 'ServiceKeys', cc_service[:guid])
          end

          it 'has service brokers link' do
            check_filter_link('Services', 28, 'ServiceBrokers', cc_service_broker[:guid])
          end
        end
      end

      context 'Service Plans' do
        let(:tab_id)     { 'ServicePlans' }
        let(:table_id)   { 'ServicePlansTable' }
        let(:event_type) { 'service_plan' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ServicePlansTable_wrapper']/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 4,
                                 labels:          ['', 'Service Plan', 'Service', 'Service Broker'],
                                 colspans:        %w(1 13 9 4)
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ServicePlansTable_wrapper']/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 27,
                                 labels:          ['', 'Name', 'GUID', 'Unique ID', 'Created', 'Updated', 'Active', 'Public', 'Free', 'Events', 'Visible Organizations', 'Service Instances', 'Service Bindings', 'Service Keys', 'Provider', 'Label', 'GUID', 'Unique ID', 'Version', 'Created', 'Updated', 'Active', 'Bindable', 'Name', 'GUID', 'Created', 'Updated'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='ServicePlansTable']/tbody/tr/td"),
                           [
                             '',
                             cc_service_plan[:name],
                             cc_service_plan[:guid],
                             cc_service_plan[:unique_id],
                             cc_service_plan[:created_at].to_datetime.rfc3339,
                             cc_service_plan[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})"),
                             '1',
                             '1',
                             '1',
                             '1',
                             '1',
                             cc_service[:provider],
                             cc_service[:label],
                             cc_service[:guid],
                             cc_service[:unique_id],
                             cc_service[:version],
                             cc_service[:created_at].to_datetime.rfc3339,
                             cc_service[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service[:bindable]})"),
                             cc_service_broker[:name],
                             cc_service_broker[:guid],
                             cc_service_broker[:created_at].to_datetime.rfc3339,
                             cc_service_broker[:updated_at].to_datetime.rfc3339
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_ServicePlansTable_3')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('ServicePlansTable', cc_service_plan[:guid])
        end

        context 'manage service plans' do
          def manage_service_plan(button_index)
            check_first_row('ServicePlansTable')
            @driver.find_element(id: "Buttons_ServicePlansTable_#{button_index}").click
            check_operation_result
          end

          def check_service_plan_state(expect_state)
            begin
              Selenium::WebDriver::Wait.new(timeout: 5).until { refresh_button && @driver.find_element(xpath: "//table[@id='ServicePlansTable']/tbody/tr/td[8]").text == expect_state }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='ServicePlansTable']/tbody/tr/td[8]").text).to eq(expect_state)
          end

          it 'has a Public button' do
            expect(@driver.find_element(id: 'Buttons_ServicePlansTable_0').text).to eq('Public')
          end

          it 'has a Private button' do
            expect(@driver.find_element(id: 'Buttons_ServicePlansTable_1').text).to eq('Private')
          end

          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_ServicePlansTable_2').text).to eq('Delete')
          end

          context 'Public button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ServicePlansTable_0' }
            end
          end

          context 'Private button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ServicePlansTable_1' }
            end
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ServicePlansTable_2' }
            end
          end

          it 'make selected public service plans private and back to public' do
            check_service_plan_state('true')
            manage_service_plan(1)
            check_service_plan_state('false')
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_ServicePlansTable_2' }
              let(:confirm_message) { 'Are you sure you want to delete the selected service plans?' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            service_plan_extra_json = Yajl::Parser.parse(cc_service_plan[:extra])
            check_details([
                            { label: 'Service Plan Name',         tag: 'div', value: cc_service_plan[:name] },
                            { label: 'Service Plan GUID',         tag:   nil, value: cc_service_plan[:guid] },
                            { label: 'Service Plan Unique ID',    tag:   nil, value: cc_service_plan[:unique_id] },
                            { label: 'Service Plan Created',      tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_plan[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Updated',      tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_plan[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Active',       tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})") },
                            { label: 'Service Plan Public',       tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})") },
                            { label: 'Service Plan Free',         tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})") },
                            { label: 'Service Plan Description',  tag:   nil, value: cc_service_plan[:description] },
                            { label: 'Service Plan Display Name', tag:   nil, value: service_plan_extra_json['displayName'] },
                            { label: 'Service Plan Bullet',       tag:   nil, value: service_plan_extra_json['bullets'][0] },
                            { label: 'Service Plan Bullet',       tag:   nil, value: service_plan_extra_json['bullets'][1] },
                            { label: 'Service Plan Events',       tag:   'a', value: '1' },
                            { label: 'Service Plan Visibilities', tag:   'a', value: '1' },
                            { label: 'Service Instances',         tag:   'a', value: '1' },
                            { label: 'Service Bindings',          tag:   'a', value: '1' },
                            { label: 'Service Keys',              tag:   'a', value: '1' },
                            { label: 'Service Provider',          tag:   nil, value: cc_service[:provider] },
                            { label: 'Service Label',             tag:   'a', value: cc_service[:label] },
                            { label: 'Service GUID',              tag:   nil, value: cc_service[:guid] },
                            { label: 'Service Unique ID',         tag:   nil, value: cc_service[:unique_id] },
                            { label: 'Service Version',           tag:   nil, value: cc_service[:version] },
                            { label: 'Service Created',           tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Updated',           tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Active',            tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})") },
                            { label: 'Service Bindable',          tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:bindable]})") },
                            { label: 'Service Broker Name',       tag:   'a', value: cc_service_broker[:name] },
                            { label: 'Service Broker GUID',       tag:   nil, value: cc_service_broker[:guid] },
                            { label: 'Service Broker Created',    tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Broker Updated',    tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:updated_at].to_datetime.rfc3339}\")") }
                          ])
          end

          it 'has events link' do
            check_filter_link('ServicePlans', 12, 'Events', cc_service_plan[:guid])
          end

          it 'has service plan visibilities link' do
            check_filter_link('ServicePlans', 13, 'ServicePlanVisibilities', cc_service_plan[:guid])
          end

          it 'has service instances link' do
            check_filter_link('ServicePlans', 14, 'ServiceInstances', cc_service_plan[:guid])
          end

          it 'has service bindings link' do
            check_filter_link('ServicePlans', 15, 'ServiceBindings', cc_service_plan[:guid])
          end

          it 'has service keys link' do
            check_filter_link('ServicePlans', 16, 'ServiceKeys', cc_service_plan[:guid])
          end

          it 'has services link' do
            check_filter_link('ServicePlans', 18, 'Services', cc_service[:guid])
          end

          it 'has service brokers link' do
            check_filter_link('ServicePlans', 26, 'ServiceBrokers', cc_service_broker[:guid])
          end
        end
      end

      context 'Service Plan Visibilities' do
        let(:tab_id)     { 'ServicePlanVisibilities' }
        let(:table_id)   { 'ServicePlanVisibilitiesTable' }
        let(:event_type) { 'service_plan_visibility' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ServicePlanVisibilitiesTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 6,
                                 labels:          ['', 'Service Plan Visibility', 'Service Plan', 'Service', 'Service Broker', 'Organization'],
                                 colspans:        %w(1 4 8 9 4 4)
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ServicePlanVisibilitiesTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 30,
                                 labels:          ['', 'GUID', 'Created', 'Updated', 'Events', 'Name', 'GUID', 'Unique ID', 'Created', 'Updated', 'Active', 'Public', 'Free', 'Provider', 'Label', 'GUID', 'Unique ID', 'Version', 'Created', 'Updated', 'Active', 'Bindable', 'Name', 'GUID', 'Created', 'Updated', 'Name', 'GUID', 'Created', 'Updated'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='ServicePlanVisibilitiesTable']/tbody/tr/td"),
                           [
                             '',
                             cc_service_plan_visibility[:guid],
                             cc_service_plan_visibility[:created_at].to_datetime.rfc3339,
                             cc_service_plan_visibility[:updated_at].to_datetime.rfc3339,
                             '1',
                             cc_service_plan[:name],
                             cc_service_plan[:guid],
                             cc_service_plan[:unique_id],
                             cc_service_plan[:created_at].to_datetime.rfc3339,
                             cc_service_plan[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})"),
                             cc_service[:provider],
                             cc_service[:label],
                             cc_service[:guid],
                             cc_service[:unique_id],
                             cc_service[:version],
                             cc_service[:created_at].to_datetime.rfc3339,
                             cc_service[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service[:bindable]})"),
                             cc_service_broker[:name],
                             cc_service_broker[:guid],
                             cc_service_broker[:created_at].to_datetime.rfc3339,
                             cc_service_broker[:updated_at].to_datetime.rfc3339,
                             cc_organization[:name],
                             cc_organization[:guid],
                             cc_organization[:created_at].to_datetime.rfc3339,
                             cc_organization[:updated_at].to_datetime.rfc3339
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_ServicePlanVisibilitiesTable_1')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('ServicePlanVisibilitiesTable', cc_service_plan_visibility[:guid])
        end

        context 'manage service plan visibilities' do
          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_ServicePlanVisibilitiesTable_0').text).to eq('Delete')
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ServicePlanVisibilitiesTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_ServicePlanVisibilitiesTable_0' }
              let(:confirm_message) { 'Are you sure you want to delete the selected service plan visibilities?' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Service Plan Visibility GUID',    tag: 'div', value: cc_service_plan_visibility[:guid] },
                            { label: 'Service Plan Visibility Created', tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_plan_visibility[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Visibility Updated', tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_plan_visibility[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Visibility Events',  tag:   'a', value: '1' },
                            { label: 'Service Plan Name',               tag:   'a', value: cc_service_plan[:name] },
                            { label: 'Service Plan GUID',               tag:   nil, value: cc_service_plan[:guid] },
                            { label: 'Service Plan Unique ID',          tag:   nil, value: cc_service_plan[:unique_id] },
                            { label: 'Service Plan Created',            tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_plan[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Updated',            tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_plan[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Active',             tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})") },
                            { label: 'Service Plan Public',             tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})") },
                            { label: 'Service Plan Free',               tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})") },
                            { label: 'Service Provider',                tag:   nil, value: cc_service[:provider] },
                            { label: 'Service Label',                   tag:   'a', value: cc_service[:label] },
                            { label: 'Service GUID',                    tag:   nil, value: cc_service[:guid] },
                            { label: 'Service Unique ID',               tag:   nil, value: cc_service[:unique_id] },
                            { label: 'Service Version',                 tag:   nil, value: cc_service[:version] },
                            { label: 'Service Created',                 tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Updated',                 tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Active',                  tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})") },
                            { label: 'Service Bindable',                tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:bindable]})") },
                            { label: 'Service Broker Name',             tag:   'a', value: cc_service_broker[:name] },
                            { label: 'Service Broker GUID',             tag:   nil, value: cc_service_broker[:guid] },
                            { label: 'Service Broker Created',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Broker Updated',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Organization Name',               tag:   'a', value: cc_organization[:name] },
                            { label: 'Organization GUID',               tag:   nil, value: cc_organization[:guid] },
                            { label: 'Organization Created',            tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_organization[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Organization Updated',            tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_organization[:updated_at].to_datetime.rfc3339}\")") }
                          ])
          end

          it 'has events link' do
            check_filter_link('ServicePlanVisibilities', 3, 'Events', cc_service_plan_visibility[:guid])
          end

          it 'has service plans link' do
            check_filter_link('ServicePlanVisibilities', 4, 'ServicePlans', cc_service_plan[:guid])
          end

          it 'has services link' do
            check_filter_link('ServicePlanVisibilities', 13, 'Services', cc_service[:guid])
          end

          it 'has service brokers link' do
            check_filter_link('ServicePlanVisibilities', 21, 'ServiceBrokers', cc_service_broker[:guid])
          end

          it 'has organizations link' do
            check_filter_link('ServicePlanVisibilities', 25, 'Organizations', cc_organization[:guid])
          end
        end
      end

      context 'Identity Zones' do
        let(:tab_id) { 'IdentityZones' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='IdentityZonesTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 10,
                                 labels:          ['Name', 'ID', 'Created', 'Updated', 'Subdomain', 'Version', 'Identity Providers', 'Clients', 'Users', 'Description'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='IdentityZonesTable']/tbody/tr/td"),
                           [
                             uaa_identity_zone[:name],
                             uaa_identity_zone[:id],
                             uaa_identity_zone[:created].to_datetime.rfc3339,
                             uaa_identity_zone[:lastmodified].to_datetime.rfc3339,
                             uaa_identity_zone[:subdomain],
                             @driver.execute_script("return Format.formatNumber(#{uaa_identity_zone[:version]})"),
                             '1',
                             '1',
                             '1',
                             uaa_identity_zone[:description]
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_IdentityZonesTable_0')
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Name',               tag: 'div', value: uaa_identity_zone[:name] },
                            { label: 'ID',                 tag:   nil, value: uaa_identity_zone[:id] },
                            { label: 'Created',            tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_identity_zone[:created].to_datetime.rfc3339}\")") },
                            { label: 'Updated',            tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_identity_zone[:lastmodified].to_datetime.rfc3339}\")") },
                            { label: 'Subdomain',          tag:   nil, value: uaa_identity_zone[:subdomain] },
                            { label: 'Version',            tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{uaa_identity_zone[:version]})") },
                            { label: 'Description',        tag:   nil, value: uaa_identity_zone[:description] },
                            { label: 'Identity Providers', tag:   'a', value: '1' },
                            { label: 'Clients',            tag:   'a', value: '1' },
                            { label: 'Users',              tag:   'a', value: '1' }
                          ])
          end

          it 'has identity providers link' do
            check_filter_link('IdentityZones', 7, 'IdentityProviders', uaa_identity_zone[:id])
          end

          it 'has clients link' do
            check_filter_link('IdentityZones', 8, 'Clients', uaa_identity_zone[:id])
          end

          it 'has users link' do
            check_filter_link('IdentityZones', 9, 'Users', uaa_identity_zone[:id])
          end
        end
      end

      context 'Identity Providers' do
        let(:tab_id) { 'IdentityProviders' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='IdentityProvidersTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 9,
                                 labels:          ['Identity Zone', 'Name', 'GUID', 'Created', 'Updated', 'Origin Key', 'Type', 'Active', 'Version'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='IdentityProvidersTable']/tbody/tr/td"),
                           [
                             uaa_identity_zone[:name],
                             uaa_identity_provider[:name],
                             uaa_identity_provider[:id],
                             uaa_identity_provider[:created].to_datetime.rfc3339,
                             uaa_identity_provider[:lastmodified].to_datetime.rfc3339,
                             uaa_identity_provider[:origin_key],
                             uaa_identity_provider[:type],
                             @driver.execute_script("return Format.formatBoolean(#{uaa_identity_provider[:active]})"),
                             @driver.execute_script("return Format.formatNumber(#{uaa_identity_provider[:version]})")
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_IdentityProvidersTable_0')
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Identity Zone', tag:   'a', value: uaa_identity_zone[:name] },
                            { label: 'Name',          tag: 'div', value: uaa_identity_provider[:name] },
                            { label: 'GUID',          tag:   nil, value: uaa_identity_provider[:id] },
                            { label: 'Created',       tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_identity_provider[:created].to_datetime.rfc3339}\")") },
                            { label: 'Updated',       tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_identity_provider[:lastmodified].to_datetime.rfc3339}\")") },
                            { label: 'Origin Key',    tag:   nil, value: uaa_identity_provider[:origin_key] },
                            { label: 'Type',          tag:   nil, value: uaa_identity_provider[:type] },
                            { label: 'Active',        tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{uaa_identity_provider[:active]})") },
                            { label: 'Version',       tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{uaa_identity_provider[:version]})") }
                          ])
          end

          it 'has identity zones link' do
            check_filter_link('IdentityProviders', 0, 'IdentityZones', uaa_identity_zone[:id])
          end
        end
      end

      context 'Security Groups' do
        let(:tab_id)   { 'SecurityGroups' }
        let(:table_id) { 'SecurityGroupsTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='SecurityGroupsTableContainer']/div/div[4]/div/div/table/thead/tr/th"),
                                 expected_length: 8,
                                 labels:          ['', 'Name', 'GUID', 'Created', 'Updated', 'Staging Default', 'Running Default', 'Spaces'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='SecurityGroupsTable']/tbody/tr/td"),
                           [
                             '',
                             cc_security_group[:name],
                             cc_security_group[:guid],
                             cc_security_group[:created_at].to_datetime.rfc3339,
                             cc_security_group[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{cc_security_group[:staging_default]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_security_group[:running_default]})"),
                             '1'
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_SecurityGroupsTable_1')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('SecurityGroupsTable', cc_security_group[:guid])
        end

        context 'manage security groups' do
          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_SecurityGroupsTable_0').text).to eq('Delete')
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_SecurityGroupsTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_SecurityGroupsTable_0' }
              let(:confirm_message) { 'Are you sure you want to delete the selected security groups?' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Name',            tag: 'div', value: cc_security_group[:name] },
                            { label: 'GUID',            tag:   nil, value: cc_security_group[:guid] },
                            { label: 'Created',         tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_security_group[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Updated',         tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_security_group[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Staging Default', tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_security_group[:staging_default]})") },
                            { label: 'Running Default', tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_security_group[:running_default]})") },
                            { label: 'Spaces',          tag:   'a', value: '1' }
                          ])
          end

          it 'has rules' do
            expect(@driver.find_element(id: 'SecurityGroupsRulesDetailsLabel').displayed?).to be(true)

            check_table_headers(columns:         @driver.find_elements(xpath: "//div[@id='SecurityGroupsRulesTableContainer']/div[2]/div[4]/div/div/table/thead/tr/th"),
                                expected_length: 6,
                                labels:          %w(Protocol Destination Log Ports Type Code),
                                colspans:        nil)

            rules_json = Yajl::Parser.parse(cc_security_group[:rules])
            rule       = rules_json[0]

            check_table_data(@driver.find_elements(xpath: "//table[@id='SecurityGroupsRulesTable']/tbody/tr/td"),
                             [
                               rule['protocol'],
                               rule['destination'],
                               @driver.execute_script("return Format.formatBoolean(#{rule['log']})"),
                               rule['ports'],
                               @driver.execute_script("return Format.formatNumber(#{rule['type']})"),
                               @driver.execute_script("return Format.formatNumber(#{rule['code']})")
                             ])
          end

          it 'rules subtable has allowscriptaccess property set to sameDomain' do
            check_allowscriptaccess_attribute('Buttons_SecurityGroupsRulesTable_0')
          end

          it 'has security groups spaces link' do
            check_filter_link('SecurityGroups', 6, 'SecurityGroupsSpaces', cc_security_group[:guid])
          end
        end
      end

      context 'Security Groups Spaces' do
        let(:tab_id)   { 'SecurityGroupsSpaces' }
        let(:table_id) { 'SecurityGroupsSpacesTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='SecurityGroupsSpacesTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 4,
                                 labels:          ['', 'Security Group', 'Space', ''],
                                 colspans:        %w(1 4 4 1)
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='SecurityGroupsSpacesTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 10,
                                 labels:          ['', 'Name', 'GUID', 'Created', 'Updated', 'Name', 'GUID', 'Created', 'Updated', 'Target'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='SecurityGroupsSpacesTable']/tbody/tr/td"),
                           [
                             '',
                             cc_security_group[:name],
                             cc_security_group[:guid],
                             cc_security_group[:created_at].to_datetime.rfc3339,
                             cc_security_group[:updated_at].to_datetime.rfc3339,
                             cc_space[:name],
                             cc_space[:guid],
                             cc_space[:created_at].to_datetime.rfc3339,
                             cc_space[:updated_at].to_datetime.rfc3339,
                             "#{cc_organization[:name]}/#{cc_space[:name]}"
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_SecurityGroupsSpacesTable_1')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('SecurityGroupsSpacesTable', "#{cc_security_group[:guid]}/#{cc_space[:guid]}")
        end

        context 'manage security group spaces' do
          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_SecurityGroupsSpacesTable_0').text).to eq('Delete')
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_SecurityGroupsSpacesTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_SecurityGroupsSpacesTable_0' }
              let(:confirm_message) { 'Are you sure you want to delete the selected security groups spaces?' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Security Group',         tag: 'div', value: cc_security_group[:name] },
                            { label: 'Security Group GUID',    tag:   nil, value: cc_security_group[:guid] },
                            { label: 'Security Group Created', tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_security_group[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Security Group Updated', tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_security_group[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Space',                  tag:   'a', value: cc_space[:name] },
                            { label: 'Space GUID',             tag:   nil, value: cc_space[:guid] },
                            { label: 'Space Created',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_space[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Space Updated',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_space[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Organization',           tag:   'a', value: cc_organization[:name] }
                          ])
          end

          it 'has security groups link' do
            check_filter_link('SecurityGroupsSpaces', 0, 'SecurityGroups', cc_security_group[:guid])
          end

          it 'has spaces link' do
            check_filter_link('SecurityGroupsSpaces', 4, 'Spaces', cc_space[:guid])
          end

          it 'has organization link' do
            check_filter_link('SecurityGroupsSpaces', 8, 'Organizations', cc_organization[:guid])
          end
        end
      end

      context 'DEAs' do
        let(:tab_id) { 'DEAs' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='DEAsTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 4,
                                 labels:          ['', 'Instances', '% Free', 'Remaining'],
                                 colspans:        %w(9 5 2 2)
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='DEAsTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 18,
                                 labels:          ['Name', 'Index', 'Source', 'Metrics', 'State', 'Started', 'Stacks', 'CPU', 'Memory', 'Total', 'Running', 'Memory', 'Disk', '% CPU', 'Memory', 'Disk', 'Memory', 'Disk'],
                                 colspans:        nil
                               }
                             ])
        end

        context 'varz dea' do
          it 'has table data' do
            check_table_data(@driver.find_elements(xpath: "//table[@id='DEAsTable']/tbody/tr/td"),
                             [
                               nats_dea['host'],
                               @driver.execute_script("return Format.formatNumber(#{nats_dea['index']})"),
                               'varz',
                               nil,
                               @driver.execute_script('return Constants.STATUS__RUNNING'),
                               varz_dea['start'],
                               varz_dea['stacks'][0],
                               @driver.execute_script("return Format.formatNumber(#{varz_dea['cpu']})"),
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_kilobytes_to_megabytes(varz_dea['mem'])})"),
                               @driver.execute_script("return Format.formatNumber(#{varz_dea['instance_registry'][cc_app[:guid]].length})"),
                               @driver.execute_script("return Format.formatNumber(#{varz_dea['instance_registry'][cc_app[:guid]].length})"),
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_memory)})"),
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_disk)})"),
                               @driver.execute_script("return Format.formatNumber(#{used_cpu})"),
                               @driver.execute_script("return Format.formatNumber(#{varz_dea['available_memory_ratio'].to_f} * 100)"),
                               @driver.execute_script("return Format.formatNumber(#{varz_dea['available_disk_ratio'].to_f} * 100)"),
                               nil,
                               nil
                             ])
          end
        end

        context 'doppler dea' do
          let(:application_instance_source) { :doppler_dea }
          it 'has table data' do
            check_table_data(@driver.find_elements(xpath: "//table[@id='DEAsTable']/tbody/tr/td"),
                             [
                               "#{dea_envelope.ip}:#{dea_envelope.index}",
                               @driver.execute_script("return Format.formatNumber(#{dea_envelope.index})"),
                               'doppler',
                               Time.at(dea_envelope.timestamp / BILLION).to_datetime.rfc3339,
                               @driver.execute_script('return Constants.STATUS__RUNNING'),
                               nil,
                               nil,
                               nil,
                               nil,
                               @driver.execute_script("return Format.formatNumber(#{DopplerHelper::DEA_VALUE_METRICS['instances']})"),
                               @driver.execute_script("return Format.formatNumber(#{cc_app[:instances]})"),
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_memory)})"),
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_disk)})"),
                               @driver.execute_script("return Format.formatNumber(#{used_cpu})"),
                               @driver.execute_script("return Format.formatNumber(#{DopplerHelper::DEA_VALUE_METRICS['available_memory_ratio'].to_f} * 100)"),
                               @driver.execute_script("return Format.formatNumber(#{DopplerHelper::DEA_VALUE_METRICS['available_disk_ratio'].to_f} * 100)"),
                               @driver.execute_script("return Format.formatNumber(#{DopplerHelper::DEA_VALUE_METRICS['remaining_memory']})"),
                               @driver.execute_script("return Format.formatNumber(#{DopplerHelper::DEA_VALUE_METRICS['remaining_disk']})")
                             ])
          end
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_DEAsTable_0')
        end

        context 'selectable' do
          before do
            select_first_row
          end

          context 'varz dea' do
            it 'has details' do
              check_details([
                              { label: 'Name',                  tag: nil, value: nats_dea['host'] },
                              { label: 'Index',                 tag: nil, value: @driver.execute_script("return Format.formatNumber(#{nats_dea['index']})") },
                              { label: 'Source',                tag: nil, value: 'varz' },
                              { label: 'URI',                   tag: 'a', value: nats_dea_varz },
                              { label: 'Started',               tag: nil, value: @driver.execute_script("return Format.formatDateString(\"#{varz_dea['start']}\")") },
                              { label: 'Uptime',                tag: nil, value: @driver.execute_script("return Format.formatUptime(\"#{varz_dea['uptime']}\")") },
                              { label: 'Stack',                 tag: 'a', value: varz_dea['stacks'][0] },
                              { label: 'Cores',                 tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_dea['num_cores']})") },
                              { label: 'CPU',                   tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_dea['cpu']})") },
                              { label: 'CPU Load Avg',          tag: nil, value: "#{@driver.execute_script("return Format.formatNumber(#{varz_dea['cpu_load_avg'].to_f} * 100)")}%" },
                              { label: 'Memory',                tag: nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_kilobytes_to_megabytes(varz_dea['mem'])})") },
                              { label: 'Total Instances',       tag: 'a', value: @driver.execute_script("return Format.formatNumber(#{varz_dea['instance_registry'].length})") },
                              { label: 'Running Instances',     tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_dea['instance_registry'].length})") },
                              { label: 'Instances Memory Used', tag: nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_memory)})") },
                              { label: 'Instances Disk Used',   tag: nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_disk)})") },
                              { label: 'Instances CPU Used',    tag: nil, value: @driver.execute_script("return Format.formatNumber(#{used_cpu})") },
                              { label: 'Memory Free',           tag: nil, value: "#{@driver.execute_script("return Format.formatNumber(#{varz_dea['available_memory_ratio'].to_f} * 100)")}%" },
                              { label: 'Disk Free',             tag: nil, value: "#{@driver.execute_script("return Format.formatNumber(#{varz_dea['available_disk_ratio'].to_f} * 100)")}%" }
                            ])
            end

            it 'has stacks link' do
              check_filter_link('DEAs', 6, 'Stacks', varz_dea['stacks'][0])
            end

            it 'has application instances link' do
              check_filter_link('DEAs', 11, 'ApplicationInstances', nats_dea['host'])
            end
          end

          context 'doppler dea' do
            let(:application_instance_source) { :doppler_dea }
            it 'has details' do
              check_details([
                              { label: 'Name',                  tag: 'div', value: "#{dea_envelope.ip}:#{dea_envelope.index}" },
                              { label: 'IP',                    tag:   nil, value: dea_envelope.ip },
                              { label: 'Index',                 tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{dea_envelope.index})") },
                              { label: 'Source',                tag:   nil, value: 'doppler' },
                              { label: 'Metrics',               tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{Time.at(dea_envelope.timestamp / BILLION).to_datetime.rfc3339}\")") },
                              { label: 'CPU Load Avg',          tag:   nil, value: "#{@driver.execute_script("return Format.formatNumber(#{DopplerHelper::DEA_VALUE_METRICS['avg_cpu_load'].to_f} * 100)")}%" },
                              { label: 'Total Instances',       tag:   'a', value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::DEA_VALUE_METRICS['instances']})") },
                              { label: 'Running Instances',     tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_app[:instances]})") },
                              { label: 'Instances Memory Used', tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_memory)})") },
                              { label: 'Instances Disk Used',   tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_disk)})") },
                              { label: 'Instances CPU Used',    tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{used_cpu})") },
                              { label: 'Memory Free',           tag:   nil, value: "#{@driver.execute_script("return Format.formatNumber(#{DopplerHelper::DEA_VALUE_METRICS['available_memory_ratio'].to_f} * 100)")}%" },
                              { label: 'Disk Free',             tag:   nil, value: "#{@driver.execute_script("return Format.formatNumber(#{DopplerHelper::DEA_VALUE_METRICS['available_disk_ratio'].to_f} * 100)")}%" },
                              { label: 'Remaining Memory',      tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::DEA_VALUE_METRICS['remaining_memory']})") },
                              { label: 'Remaining Disk',        tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::DEA_VALUE_METRICS['remaining_disk']})") }
                            ])
            end

            it 'has application instances link' do
              check_filter_link('DEAs', 6, 'ApplicationInstances', "#{dea_envelope.ip}:#{dea_envelope.index}")
            end
          end
        end
      end

      context 'Cells' do
        let(:application_instance_source) { :doppler_cell }
        let(:tab_id)                      { 'Cells' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='CellsTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 4,
                                 labels:          ['', 'Containers', 'Memory', 'Disk'],
                                 colspans:        %w(10 3 2 2)
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='CellsTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 17,
                                 labels:          ['Name', 'IP', 'Index', 'Source', 'Metrics', 'State', 'Cores', 'Memory', 'Memory Heap', 'Memory Stack', 'Total', 'Remaining', 'Used', 'Capacity', 'Remaining', 'Capacity', 'Remaining'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='CellsTable']/tbody/tr/td"),
                           [
                             "#{rep_envelope.ip}:#{rep_envelope.index}",
                             rep_envelope.ip,
                             @driver.execute_script("return Format.formatNumber(#{rep_envelope.index})"),
                             'doppler',
                             Time.at(rep_envelope.timestamp / BILLION).to_datetime.rfc3339,
                             @driver.execute_script('return Constants.STATUS__RUNNING'),
                             @driver.execute_script("return Format.formatNumber(#{DopplerHelper::REP_VALUE_METRICS['numCPUS']})"),
                             @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(DopplerHelper::REP_VALUE_METRICS['memoryStats.numBytesAllocated'])})"),
                             @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(DopplerHelper::REP_VALUE_METRICS['memoryStats.numBytesAllocatedHeap'])})"),
                             @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(DopplerHelper::REP_VALUE_METRICS['memoryStats.numBytesAllocatedStack'])})"),
                             @driver.execute_script("return Format.formatNumber(#{DopplerHelper::REP_VALUE_METRICS['CapacityTotalContainers']})"),
                             @driver.execute_script("return Format.formatNumber(#{DopplerHelper::REP_VALUE_METRICS['CapacityRemainingContainers']})"),
                             @driver.execute_script("return Format.formatNumber(#{DopplerHelper::REP_VALUE_METRICS['ContainerCount']})"),
                             @driver.execute_script("return Format.formatNumber(#{DopplerHelper::REP_VALUE_METRICS['CapacityTotalMemory']})"),
                             @driver.execute_script("return Format.formatNumber(#{DopplerHelper::REP_VALUE_METRICS['CapacityRemainingMemory']})"),
                             @driver.execute_script("return Format.formatNumber(#{DopplerHelper::REP_VALUE_METRICS['CapacityTotalDisk']})"),
                             @driver.execute_script("return Format.formatNumber(#{DopplerHelper::REP_VALUE_METRICS['CapacityRemainingDisk']})")
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_CellsTable_0')
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Name',                           tag: 'div', value: "#{rep_envelope.ip}:#{rep_envelope.index}" },
                            { label: 'IP',                             tag:   nil, value: rep_envelope.ip },
                            { label: 'Index',                          tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{rep_envelope.index})") },
                            { label: 'Source',                         tag:   nil, value: 'doppler' },
                            { label: 'Metrics',                        tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{Time.at(rep_envelope.timestamp / BILLION).to_datetime.rfc3339}\")") },
                            { label: 'Cores',                          tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::REP_VALUE_METRICS['numCPUS']})") },
                            { label: 'Memory MB',                      tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(DopplerHelper::REP_VALUE_METRICS['memoryStats.numBytesAllocated'])})") },
                            { label: 'Memory Heap MB',                 tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(DopplerHelper::REP_VALUE_METRICS['memoryStats.numBytesAllocatedHeap'])})") },
                            { label: 'Memory Stack MB',                tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(DopplerHelper::REP_VALUE_METRICS['memoryStats.numBytesAllocatedStack'])})") },
                            { label: 'Total Containers',               tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::REP_VALUE_METRICS['CapacityTotalContainers']})") },
                            { label: 'Remaining Containers',           tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::REP_VALUE_METRICS['CapacityRemainingContainers']})") },
                            { label: 'Used Containers',                tag:   'a', value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::REP_VALUE_METRICS['ContainerCount']})") },
                            { label: 'Memory Capacity MB',             tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::REP_VALUE_METRICS['CapacityTotalMemory']})") },
                            { label: 'Memory Remaining MB',            tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::REP_VALUE_METRICS['CapacityRemainingMemory']})") },
                            { label: 'Disk Capacity MB',               tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::REP_VALUE_METRICS['CapacityTotalDisk']})") },
                            { label: 'Disk Remaining MB',              tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::REP_VALUE_METRICS['CapacityRemainingDisk']})") },
                            { label: 'Log Sender Total Messages Read', tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::REP_VALUE_METRICS['logSenderTotalMessagesRead']})") },
                            { label: 'Number Go Routines',             tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::REP_VALUE_METRICS['numGoRoutines']})") },
                            { label: 'Number Mallocs',                 tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::REP_VALUE_METRICS['memoryStats.numMallocs']})") },
                            { label: 'Number Frees',                   tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::REP_VALUE_METRICS['memoryStats.numFrees']})") }
                          ])
          end

          it 'has application instances link' do
            check_filter_link('Cells', 11, 'ApplicationInstances', "#{rep_envelope.ip}:#{rep_envelope.index}")
          end
        end
      end

      context 'Cloud Controllers' do
        let(:tab_id) { 'CloudControllers' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='CloudControllersTableContainer']/div/div[4]/div/div/table/thead/tr/th"),
                                 expected_length: 8,
                                 labels:          %w(Name Index Source State Started Cores CPU Memory),
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='CloudControllersTable']/tbody/tr/td"),
                           [
                             nats_cloud_controller['host'],
                             @driver.execute_script("return Format.formatNumber(#{nats_cloud_controller['index']})"),
                             'varz',
                             @driver.execute_script('return Constants.STATUS__RUNNING'),
                             varz_cloud_controller['start'],
                             @driver.execute_script("return Format.formatNumber(#{varz_cloud_controller['num_cores']})"),
                             @driver.execute_script("return Format.formatNumber(#{varz_cloud_controller['cpu']})"),
                             @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_kilobytes_to_megabytes(varz_cloud_controller['mem'])})")
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_CloudControllersTable_0')
        end

        context 'selectable' do
          it 'has details' do
            select_first_row
            check_details([
                            { label: 'Name',             tag: nil, value: nats_cloud_controller['host'] },
                            { label: 'Index',            tag: nil, value: @driver.execute_script("return Format.formatNumber(#{nats_cloud_controller['index']})") },
                            { label: 'Source',           tag: nil, value: 'varz' },
                            { label: 'URI',              tag: 'a', value: nats_cloud_controller_varz },
                            { label: 'Started',          tag: nil, value: @driver.execute_script("return Format.formatDateString(\"#{varz_cloud_controller['start']}\")") },
                            { label: 'Uptime',           tag: nil, value: @driver.execute_script("return Format.formatUptime(\"#{varz_cloud_controller['uptime']}\")") },
                            { label: 'Cores',            tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_cloud_controller['num_cores']})") },
                            { label: 'CPU',              tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_cloud_controller['cpu']})") },
                            { label: 'Memory',           tag: nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_kilobytes_to_megabytes(varz_cloud_controller['mem'])})") },
                            { label: 'Requests',         tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_cloud_controller['vcap_sinatra']['requests']['completed']})") },
                            { label: 'Pending Requests', tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_cloud_controller['vcap_sinatra']['requests']['outstanding']})") }
                          ])
          end
        end
      end

      context 'Health Managers' do
        let(:tab_id) { 'HealthManagers' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='HealthManagersTableContainer']/div/div[4]/div/div/table/thead/tr/th"),
                                 expected_length: 7,
                                 labels:          %w(Name Index Source Metrics State Cores Memory),
                                 colspans:        nil
                               }
                             ])
        end

        context 'varz dea' do
          it 'has table data' do
            check_table_data(@driver.find_elements(xpath: "//table[@id='HealthManagersTable']/tbody/tr/td"),
                             [
                               nats_health_manager['host'],
                               @driver.execute_script("return Format.formatNumber(#{nats_health_manager['index']})"),
                               'varz',
                               nil,
                               @driver.execute_script('return Constants.STATUS__RUNNING'),
                               @driver.execute_script("return Format.formatNumber(#{varz_health_manager['numCPUS']})"),
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(varz_health_manager['memoryStats']['numBytesAllocated'])})")
                             ])
          end
        end

        context 'doppler dea' do
          let(:application_instance_source) { :doppler_dea }
          it 'has table data' do
            check_table_data(@driver.find_elements(xpath: "//table[@id='HealthManagersTable']/tbody/tr/td"),
                             [
                               "#{analyzer_envelope.ip}:#{analyzer_envelope.index}",
                               @driver.execute_script("return Format.formatNumber(#{analyzer_envelope.index})"),
                               'doppler',
                               Time.at(analyzer_envelope.timestamp / BILLION).to_datetime.rfc3339,
                               @driver.execute_script('return Constants.STATUS__RUNNING'),
                               @driver.execute_script("return Format.formatNumber(#{DopplerHelper::ANALYZER_VALUE_METRICS['numCPUS']})"),
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(DopplerHelper::ANALYZER_VALUE_METRICS['memoryStats.numBytesAllocated'])})")
                             ])
          end
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_HealthManagersTable_0')
        end

        context 'selectable' do
          before do
            select_first_row
          end

          context 'varz dea' do
            it 'has details' do
              check_details([
                              { label: 'Name',                                         tag: nil, value: nats_health_manager['host'] },
                              { label: 'Index',                                        tag: nil, value: @driver.execute_script("return Format.formatNumber(#{nats_health_manager['index']})") },
                              { label: 'Source',                                       tag: nil, value: 'varz' },
                              { label: 'URI',                                          tag: 'a', value: nats_health_manager_varz },
                              { label: 'Cores',                                        tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_health_manager['numCPUS']})") },
                              { label: 'Memory',                                       tag: nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(varz_health_manager['memoryStats']['numBytesAllocated'])})") },
                              { label: 'Actual State Listener Store Usage Percentage', tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_health_manager_metric('ActualStateListenerStoreUsagePercentage')})") },
                              { label: 'Desired Apps',                                 tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_health_manager_metric('NumberOfDesiredApps')})") },
                              { label: 'Desired Apps Pending Staging',                 tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_health_manager_metric('NumberOfDesiredAppsPendingStaging')})") },
                              { label: 'Undesired Running Apps',                       tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_health_manager_metric('NumberOfUndesiredRunningApps')})") },
                              { label: 'Apps With All Instances Reporting',            tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_health_manager_metric('NumberOfAppsWithAllInstancesReporting')})") },
                              { label: 'Apps With Missing Instances',                  tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_health_manager_metric('NumberOfAppsWithMissingInstances')})") },
                              { label: 'Desired Instances',                            tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_health_manager_metric('NumberOfDesiredInstances')})") },
                              { label: 'Running Instances',                            tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_health_manager_metric('NumberOfRunningInstances')})") },
                              { label: 'Crashed Instances',                            tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_health_manager_metric('NumberOfCrashedInstances')})") },
                              { label: 'Desired State Sync Time in Milliseconds',      tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_health_manager_metric('DesiredStateSyncTimeInMilliseconds')})") },
                              { label: 'Received Heartbeats',                          tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_health_manager_metric('ReceivedHeartbeats')})") },
                              { label: 'Saved Heartbeats',                             tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_health_manager_metric('SavedHeartbeats')})") },
                              { label: 'Start Crashed',                                tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_health_manager_metric('StartCrashed')})") },
                              { label: 'Start Evacuating',                             tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_health_manager_metric('StartEvacuating')})") },
                              { label: 'Start Missing',                                tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_health_manager_metric('StartMissing')})") },
                              { label: 'Stop Duplicate',                               tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_health_manager_metric('StopDuplicate')})") },
                              { label: 'Stop Extra',                                   tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_health_manager_metric('StopExtra')})") },
                              { label: 'Stop Evacuation Complete',                     tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_health_manager_metric('StopEvacuationComplete')})") }
                            ])
            end
          end

          context 'doppler dea' do
            let(:application_instance_source) { :doppler_dea }
            it 'has details' do
              check_details([
                              { label: 'Name',                              tag: 'div', value: "#{analyzer_envelope.ip}:#{analyzer_envelope.index}" },
                              { label: 'IP',                                tag:   nil, value: analyzer_envelope.ip },
                              { label: 'Index',                             tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{analyzer_envelope.index})") },
                              { label: 'Source',                            tag:   nil, value: 'doppler' },
                              { label: 'Metrics',                           tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{Time.at(analyzer_envelope.timestamp / BILLION).to_datetime.rfc3339}\")") },
                              { label: 'Cores',                             tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::ANALYZER_VALUE_METRICS['numCPUS']})") },
                              { label: 'Memory',                            tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(DopplerHelper::ANALYZER_VALUE_METRICS['memoryStats.numBytesAllocated'])})") },
                              { label: 'Desired Apps',                      tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::ANALYZER_VALUE_METRICS['NumberOfDesiredApps']})") },
                              { label: 'Desired Apps Pending Staging',      tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::ANALYZER_VALUE_METRICS['NumberOfDesiredAppsPendingStaging']})") },
                              { label: 'Undesired Running Apps',            tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::ANALYZER_VALUE_METRICS['NumberOfUndesiredRunningApps']})") },
                              { label: 'Apps With All Instances Reporting', tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::ANALYZER_VALUE_METRICS['NumberOfAppsWithAllInstancesReporting']})") },
                              { label: 'Apps With Missing Instances',       tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::ANALYZER_VALUE_METRICS['NumberOfAppsWithMissingInstances']})") },
                              { label: 'Desired Instances',                 tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::ANALYZER_VALUE_METRICS['NumberOfDesiredInstances']})") },
                              { label: 'Running Instances',                 tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::ANALYZER_VALUE_METRICS['NumberOfRunningInstances']})") },
                              { label: 'Crashed Instances',                 tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::ANALYZER_VALUE_METRICS['NumberOfCrashedInstances']})") }
                            ])
            end
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
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='GatewaysTableContainer']/div/div[4]/div/div/table/thead/tr/th"),
                                 expected_length: 10,
                                 labels:          ['Name', 'Index', 'Source', 'State', 'Started', 'Description', 'CPU', 'Memory', 'Nodes', 'Available Capacity'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='GatewaysTable']/tbody/tr/td"),
                           [
                             nats_provisioner['type'][0..-13],
                             @driver.execute_script("return Format.formatNumber(#{nats_provisioner['index']})"),
                             'varz',
                             @driver.execute_script('return Constants.STATUS__RUNNING'),
                             varz_provisioner['start'],
                             varz_provisioner['config']['service'][:description],
                             @driver.execute_script("return Format.formatNumber(#{varz_provisioner['cpu']})"),
                             @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_kilobytes_to_megabytes(varz_provisioner['mem'])})"),
                             @driver.execute_script("return Format.formatNumber(#{varz_provisioner['nodes'].length})"),
                             @driver.execute_script("return Format.formatNumber(#{@capacity})")
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_GatewaysTable_0')
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Name',               tag: nil, value: nats_provisioner['type'][0..-13] },
                            { label: 'Index',              tag: nil, value: @driver.execute_script("return Format.formatNumber(#{nats_provisioner['index']})") },
                            { label: 'Source',             tag: nil, value: 'varz' },
                            { label: 'URI',                tag: 'a', value: nats_provisioner_varz },
                            { label: 'Supported Versions', tag: nil, value: varz_provisioner['config']['service']['supported_versions'][0] },
                            { label: 'Description',        tag: nil, value: varz_provisioner['config']['service']['description'] },
                            { label: 'Started',            tag: nil, value: @driver.execute_script("return Format.formatDateString(\"#{varz_provisioner['start']}\")") },
                            { label: 'Uptime',             tag: nil, value: @driver.execute_script("return Format.formatUptime(\"#{varz_provisioner['uptime']}\")") },
                            { label: 'Cores',              tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_provisioner['num_cores']})") },
                            { label: 'CPU',                tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_provisioner['cpu']})") },
                            { label: 'Memory',             tag: nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_kilobytes_to_megabytes(varz_provisioner['mem'])})") },
                            { label: 'Available Capacity', tag: nil, value: @driver.execute_script("return Format.formatNumber(#{@capacity})") }
                          ])
          end

          it 'has nodes' do
            expect(@driver.find_element(id: 'GatewaysNodesDetailsLabel').displayed?).to be(true)

            check_table_headers(columns:         @driver.find_elements(xpath: "//div[@id='GatewaysNodesTableContainer']/div[2]/div[4]/div/div/table/thead/tr/th"),
                                expected_length: 2,
                                labels:          ['Name', 'Available Capacity'],
                                colspans:        nil)

            check_table_data(@driver.find_elements(xpath: "//table[@id='GatewaysNodesTable']/tbody/tr/td"),
                             [
                               varz_provisioner['nodes'].keys[0],
                               @driver.execute_script("return Format.formatNumber(#{varz_provisioner['nodes'][varz_provisioner['nodes'].keys[0]]['available_capacity']})")
                             ])
          end

          it 'nodes subtable has allowscriptaccess property set to sameDomain' do
            check_allowscriptaccess_attribute('Buttons_GatewaysNodesTable_0')
          end
        end
      end

      context 'Routers' do
        let(:tab_id) { 'Routers' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='RoutersTableContainer']/div/div[4]/div/div/table/thead/tr/th"),
                                 expected_length: 12,
                                 labels:          ['Name', 'Index', 'Source', 'Metrics', 'State', 'Started', 'Cores', 'CPU', 'Memory', 'Droplets', 'Requests', 'Bad Requests'],
                                 colspans:        nil
                               }
                             ])
        end

        context 'varz dea' do
          it 'has table data' do
            check_table_data(@driver.find_elements(xpath: "//table[@id='RoutersTable']/tbody/tr/td"),
                             [
                               nats_router['host'],
                               @driver.execute_script("return Format.formatNumber(#{nats_router['index']})"),
                               'varz',
                               nil,
                               @driver.execute_script('return Constants.STATUS__RUNNING'),
                               varz_router['start'],
                               @driver.execute_script("return Format.formatNumber(#{varz_router['num_cores']})"),
                               @driver.execute_script("return Format.formatNumber(#{varz_router['cpu']})"),
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_kilobytes_to_megabytes(varz_router['mem'])})"),
                               @driver.execute_script("return Format.formatNumber(#{varz_router['droplets']})"),
                               @driver.execute_script("return Format.formatNumber(#{varz_router['requests']})"),
                               @driver.execute_script("return Format.formatNumber(#{varz_router['bad_requests']})")
                             ])
          end
        end

        context 'doppler dea' do
          let(:application_instance_source) { :doppler_dea }
          it 'has table data' do
            check_table_data(@driver.find_elements(xpath: "//table[@id='RoutersTable']/tbody/tr/td"),
                             [
                               "#{gorouter_envelope.ip}:#{gorouter_envelope.index}",
                               @driver.execute_script("return Format.formatNumber(#{gorouter_envelope.index})"),
                               'doppler',
                               Time.at(gorouter_envelope.timestamp / BILLION).to_datetime.rfc3339,
                               @driver.execute_script('return Constants.STATUS__RUNNING'),
                               nil,
                               @driver.execute_script("return Format.formatNumber(#{DopplerHelper::GOROUTER_VALUE_METRICS['numCPUS']})"),
                               nil,
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(DopplerHelper::GOROUTER_VALUE_METRICS['memoryStats.numBytesAllocated'])})"),
                               nil,
                               nil,
                               nil
                             ])
          end
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_RoutersTable_0')
        end

        context 'selectable' do
          before do
            select_first_row
          end

          context 'varz dea' do
            it 'has details' do
              check_details([
                              { label: 'Name',          tag: nil, value: nats_router['host'] },
                              { label: 'Index',         tag: nil, value: @driver.execute_script("return Format.formatNumber(#{nats_router['index']})") },
                              { label: 'Source',        tag: nil, value: 'varz' },
                              { label: 'URI',           tag: 'a', value: nats_router_varz },
                              { label: 'Started',       tag: nil, value: @driver.execute_script("return Format.formatDateString(\"#{varz_router['start']}\")") },
                              { label: 'Uptime',        tag: nil, value: @driver.execute_script("return Format.formatUptime(\"#{varz_router['uptime']}\")") },
                              { label: 'Cores',         tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_router['num_cores']})") },
                              { label: 'CPU',           tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_router['cpu']})") },
                              { label: 'Memory',        tag: nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_kilobytes_to_megabytes(varz_router['mem'])})") },
                              { label: 'Droplets',      tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_router['droplets']})") },
                              { label: 'Requests',      tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_router['requests']})") },
                              { label: 'Bad Requests',  tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_router['bad_requests']})") },
                              { label: '2XX Responses', tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_router['responses_2xx']})") },
                              { label: '3XX Responses', tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_router['responses_3xx']})") },
                              { label: '4XX Responses', tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_router['responses_4xx']})") },
                              { label: '5XX Responses', tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_router['responses_5xx']})") },
                              { label: 'XXX Responses', tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_router['responses_xxx']})") }
                            ])
            end

            it 'has top10 applications' do
              expect(@driver.find_element(id: 'RoutersTop10ApplicationsDetailsLabel').displayed?).to be(true)

              check_table_headers(columns:         @driver.find_elements(xpath: "//div[@id='RoutersTop10ApplicationsTableContainer']/div[2]/div[4]/div/div/table/thead/tr/th"),
                                  expected_length: 5,
                                  labels:          %w(Name GUID RPM RPS Target),
                                  colspans:        nil)

              check_table_data(@driver.find_elements(xpath: "//table[@id='RoutersTop10ApplicationsTable']/tbody/tr/td"),
                               [
                                 cc_app[:name],
                                 cc_app[:guid],
                                 @driver.execute_script("return Format.formatNumber(#{varz_router['top10_app_requests'][0]['rpm']})"),
                                 @driver.execute_script("return Format.formatNumber(#{varz_router['top10_app_requests'][0]['rps']})"),
                                 "#{cc_organization[:name]}/#{cc_space[:name]}"
                               ])
            end

            it 'top10 subtable has allowscriptaccess property set to sameDomain' do
              check_allowscriptaccess_attribute('Buttons_RoutersTop10ApplicationsTable_0')
            end
          end

          context 'doppler dea' do
            let(:application_instance_source) { :doppler_dea }
            it 'has details' do
              check_details([
                              { label: 'Name',    tag: 'div', value: "#{gorouter_envelope.ip}:#{gorouter_envelope.index}" },
                              { label: 'IP',      tag:   nil, value: gorouter_envelope.ip },
                              { label: 'Index',   tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{gorouter_envelope.index})") },
                              { label: 'Source',  tag:   nil, value: 'doppler' },
                              { label: 'Metrics', tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{Time.at(gorouter_envelope.timestamp / BILLION).to_datetime.rfc3339}\")") },
                              { label: 'Cores',   tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::GOROUTER_VALUE_METRICS['numCPUS']})") },
                              { label: 'Memory',  tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(DopplerHelper::GOROUTER_VALUE_METRICS['memoryStats.numBytesAllocated'])})") }
                            ])
            end
          end
        end
      end

      context 'Components' do
        let(:tab_id) { 'Components' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ComponentsTableContainer']/div/div[4]/div/div/table/thead/tr/th"),
                                 expected_length: 7,
                                 labels:          %w(Name Type Index Source Metrics State Started),
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='ComponentsTable']/tbody/tr/td"),
                           [
                             nats_cloud_controller['host'],
                             nats_cloud_controller['type'],
                             @driver.execute_script("return Format.formatNumber(#{nats_cloud_controller['index']})"),
                             'varz',
                             nil,
                             @driver.execute_script('return Constants.STATUS__RUNNING'),
                             varz_cloud_controller['start']
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_ComponentsTable_2')
        end

        it 'has a Remove OFFLINE Doppler button' do
          expect(@driver.find_element(id: 'Buttons_ComponentsTable_0').text).to eq('Remove OFFLINE Doppler')
        end

        it 'has a Remove OFFLINE Varz button' do
          expect(@driver.find_element(id: 'Buttons_ComponentsTable_1').text).to eq('Remove OFFLINE Varz')
        end

        it 'removes the OFFLINE Doppler components' do
          @driver.find_element(id: 'Buttons_ComponentsTable_0').click
          confirm('Are you sure you want to remove all OFFLINE doppler components?')
          check_operation_result
        end

        it 'removes the OFFLINE Varz components' do
          @driver.find_element(id: 'Buttons_ComponentsTable_1').click
          confirm('Are you sure you want to remove all OFFLINE varz components?')
          check_operation_result
        end

        context 'selectable' do
          it 'has details' do
            select_first_row
            check_details([
                            { label: 'Name',    tag: nil, value: nats_cloud_controller['host'] },
                            { label: 'Type',    tag: nil, value: nats_cloud_controller['type'] },
                            { label: 'Index',   tag: nil, value: @driver.execute_script("return Format.formatNumber(#{nats_cloud_controller['index']})") },
                            { label: 'Source',  tag: nil, value: 'varz' },
                            { label: 'URI',     tag: 'a', value: nats_cloud_controller_varz },
                            { label: 'State',   tag: nil, value: @driver.execute_script('return Constants.STATUS__RUNNING') },
                            { label: 'Started', tag: nil, value: @driver.execute_script("return Format.formatDateString(\"#{varz_cloud_controller['start']}\")") }
                          ])
          end
        end
      end

      context 'Logs' do
        let(:tab_id) { 'Logs' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='LogsTableContainer']/div/div[4]/div/div/table/thead/tr/th"),
                                 expected_length: 3,
                                 labels:          ['Path', 'Size', 'Last Modified'],
                                 colspans:        nil
                               }
                             ])
        end

        it 'has contents' do
          select_first_row
          row = @driver.find_elements(xpath: "//table[@id='LogsTable']/tbody/tr")[0]
          columns = row.find_elements(tag_name: 'td')
          expect(columns.length).to eq(3)
          expect(columns[0].text).to eq(log_file_displayed)
          expect(columns[1].text).to eq(@driver.execute_script("return Format.formatNumber(#{log_file_displayed_contents_length})"))
          # TODO: Cannot check date due to web_helper stub for AdminUI::Utils.time_in_milliseconds
          # expect(columns[2].text).to eq(@driver.execute_script("return Format.formatString(\"#{log_file_displayed_modified.utc.to_datetime.rfc3339}\")"))
          expect(@driver.find_element(id: 'LogContainer').displayed?).to be(true)
          expect(@driver.find_element(id: 'LogLink').text).to eq(columns[0].text)
          expect(@driver.find_element(id: 'LogContents').text).to eq(log_file_displayed_contents)
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_LogsTable_0')
        end
      end

      context 'Stats' do
        let(:tab_id) { 'Stats' }

        context 'statistics' do
          before do
            refresh_button
          end

          shared_examples 'it has a table' do
            it 'has a table' do
              check_stats_table('Stats', application_instance_source)
            end
          end

          context 'varz dea' do
            it_behaves_like('it has a table')
          end

          context 'doppler cell' do
            let(:application_instance_source) { :doppler_cell }
            it_behaves_like('it has a table')
          end

          context 'doppler dea' do
            let(:application_instance_source) { :doppler_dea }
            it_behaves_like('it has a table')
          end

          it 'has allowscriptaccess property set to sameDomain' do
            check_allowscriptaccess_attribute('Buttons_StatsTable_1')
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
                             application_instance_source == :doppler_cell ? '0' : '1',
                             application_instance_source == :doppler_cell ? '1' : '0'
                           ])
        end

        shared_examples 'can show current stats' do
          it 'can show current stats' do
            check_default_stats_table
            @driver.find_element(id: 'Buttons_StatsTable_0').click
            Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.find_element(id: 'ModalDialogContents').displayed? }
            expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be(true)
            expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Confirmation')
            rows = @driver.find_elements(xpath: "//div[@id='ModalDialogContentsSimple']/div/table/tbody/tr")
            expect(rows.length).to eq(8)
            index = 0
            while index <= 5
              expect(rows[index].find_element(class_name: 'cellRightAlign').text).to eq('1')
              index += 1
            end
            expect(rows[6].find_element(class_name: 'cellRightAlign').text).to eq(application_instance_source == :doppler_cell ? '0' : '1')
            expect(rows[7].find_element(class_name: 'cellRightAlign').text).to eq(application_instance_source == :doppler_cell ? '1' : '0')
            @driver.find_element(id: 'modalDialogButton1').click
            check_default_stats_table
          end
        end

        context 'varz dea' do
          it_behaves_like('can show current stats')
        end

        context 'doppler cell' do
          let(:application_instance_source) { :doppler_cell }
          it_behaves_like('can show current stats')
        end

        context 'doppler dea' do
          let(:application_instance_source) { :doppler_dea }
          it_behaves_like('can show current stats')
        end

        def stats_table_data
          [
            nil,
            '1',
            '1',
            '1',
            '1',
            '1',
            '1',
            application_instance_source == :doppler_cell ? '0' : '1',
            application_instance_source == :doppler_cell ? '1' : '0'
          ]
        end

        shared_examples 'can create stats' do
          it 'can create stats' do
            check_default_stats_table
            @driver.find_element(id: 'Buttons_StatsTable_0').click
            @driver.find_element(id: 'modalDialogButton0').click

            begin
              check_table_data(Selenium::WebDriver::Wait.new(timeout: 5).until { refresh_button && @driver.find_elements(xpath: "//table[@id='StatsTable']/tbody/tr/td") }, stats_table_data)
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError, Timeout::Error
            end
            check_table_data(@driver.find_elements(xpath: "//table[@id='StatsTable']/tbody/tr/td"), stats_table_data)
          end
        end

        context 'varz dea' do
          it_behaves_like('can create stats')
        end

        context 'doppler cell' do
          let(:application_instance_source) { :doppler_cell }
          it_behaves_like('can create stats')
        end

        context 'doppler dea' do
          let(:application_instance_source) { :doppler_dea }
          it_behaves_like('can create stats')
        end
      end
    end
  end
end
