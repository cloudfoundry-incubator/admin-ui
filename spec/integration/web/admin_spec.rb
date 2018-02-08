require 'date'
require 'fileutils'
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

      # Optionally test allowscriptaccess field, but only if flash-based buttons, not if html5 buttons
      @driver.manage.timeouts.implicit_wait = 0.1
      begin
        divs = @driver.find_elements(xpath: "//a[@id='#{copy_node_id}']/div")
        expect(@driver.find_element(xpath: "//a[@id='#{copy_node_id}']/div/embed").attribute('allowscriptaccess')).to eq('sameDomain') unless divs.empty?
      ensure
        @driver.manage.timeouts.implicit_wait = implicit_wait
      end
    end

    def refresh_button
      # TODO: Behavior of selenium-webdriver. Entire item must be displayed for it to click. Workaround following after commented out code
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
      expect(@driver.find_element(class_name: 'build').text).to eq("Build #{cc_info_build}")
      expect(@driver.find_element(class_name: 'apiVersion').text).to eq("API Version #{cc_info_api_version}")
    end

    it 'has tabs' do
      expect(scroll_tab_into_view('Organizations', true).displayed?).to be(true)
      expect(scroll_tab_into_view('Spaces').displayed?).to be(true)
      expect(scroll_tab_into_view('Applications').displayed?).to be(true)
      expect(scroll_tab_into_view('ApplicationInstances').displayed?).to be(true)
      expect(scroll_tab_into_view('Routes').displayed?).to be(true)
      expect(scroll_tab_into_view('RouteMappings').displayed?).to be(true)
      expect(scroll_tab_into_view('ServiceInstances').displayed?).to be(true)
      expect(scroll_tab_into_view('SharedServiceInstances').displayed?).to be(true)
      expect(scroll_tab_into_view('ServiceBindings').displayed?).to be(true)
      expect(scroll_tab_into_view('ServiceKeys').displayed?).to be(true)
      expect(scroll_tab_into_view('RouteBindings').displayed?).to be(true)
      expect(scroll_tab_into_view('Tasks').displayed?).to be(true)
      expect(scroll_tab_into_view('OrganizationRoles').displayed?).to be(true)
      expect(scroll_tab_into_view('SpaceRoles').displayed?).to be(true)
      expect(scroll_tab_into_view('Clients').displayed?).to be(true)
      expect(scroll_tab_into_view('Users').displayed?).to be(true)
      expect(scroll_tab_into_view('Groups').displayed?).to be(true)
      expect(scroll_tab_into_view('GroupMembers').displayed?).to be(true)
      expect(scroll_tab_into_view('Approvals').displayed?).to be(true)
      expect(scroll_tab_into_view('RevocableTokens').displayed?).to be(true)
      expect(scroll_tab_into_view('Buildpacks').displayed?).to be(true)
      expect(scroll_tab_into_view('Domains').displayed?).to be(true)
      expect(scroll_tab_into_view('FeatureFlags').displayed?).to be(true)
      expect(scroll_tab_into_view('Quotas').displayed?).to be(true)
      expect(scroll_tab_into_view('SpaceQuotas').displayed?).to be(true)
      expect(scroll_tab_into_view('Stacks').displayed?).to be(true)
      expect(scroll_tab_into_view('Events').displayed?).to be(true)
      expect(scroll_tab_into_view('ServiceBrokers').displayed?).to be(true)
      expect(scroll_tab_into_view('Services').displayed?).to be(true)
      expect(scroll_tab_into_view('ServicePlans').displayed?).to be(true)
      expect(scroll_tab_into_view('ServicePlanVisibilities').displayed?).to be(true)
      expect(scroll_tab_into_view('IdentityZones').displayed?).to be(true)
      expect(scroll_tab_into_view('IdentityProviders').displayed?).to be(true)
      expect(scroll_tab_into_view('ServiceProviders').displayed?).to be(true)
      expect(scroll_tab_into_view('MFAProviders').displayed?).to be(true)
      expect(scroll_tab_into_view('SecurityGroups').displayed?).to be(true)
      expect(scroll_tab_into_view('SecurityGroupsSpaces').displayed?).to be(true)
      expect(scroll_tab_into_view('StagingSecurityGroupsSpaces').displayed?).to be(true)
      expect(scroll_tab_into_view('IsolationSegments').displayed?).to be(true)
      expect(scroll_tab_into_view('OrganizationsIsolationSegments').displayed?).to be(true)
      expect(scroll_tab_into_view('EnvironmentGroups').displayed?).to be(true)
      expect(scroll_tab_into_view('DEAs').displayed?).to be(true)
      expect(scroll_tab_into_view('Cells').displayed?).to be(true)
      expect(scroll_tab_into_view('CloudControllers').displayed?).to be(true)
      expect(scroll_tab_into_view('HealthManagers').displayed?).to be(true)
      expect(scroll_tab_into_view('Gateways').displayed?).to be(true)
      expect(scroll_tab_into_view('Routers').displayed?).to be(true)
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
      before do
        # First, make sure the DEA tab shows
        # Second select the desired tab via scrolling
        click_tab(tab_id, true) # Not scrolling tab into view here since tested above in 'has tabs'

        # Third, wait until the desired page has been rendered
        begin
          Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.find_element(id: "#{tab_id}Page").displayed? }
        rescue Selenium::WebDriver::Error::TimeOutError
        end
        expect(@driver.find_element(id: "#{tab_id}Page").displayed?).to eq(true)

        # Fourth, wait until the table on the desired page has data
        begin
          Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.find_element(xpath: "//table[@id='#{tab_id}Table']/tbody/tr").text != 'No data available in table' }
        rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
        end
        expect(@driver.find_element(xpath: "//table[@id='#{tab_id}Table']/tbody/tr").text).not_to eq('No data available in table')
      end

      def check_checkbox_guid(table_id, guid)
        inputs = @driver.find_elements(xpath: "//table[@id='#{table_id}']/tbody/tr/td[1]/input")
        expect(inputs.length).to be > 0
        expect(inputs[0].attribute('value')).to eq(guid)
      end

      def check_first_row(table_id)
        # TODO: Behavior of selenium-webdriver. Entire item must be displayed for it to click. Workaround following after commented out code
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

      shared_examples 'save button' do
        it 'saves the data in the table' do
          # TODO: Behavior of selenium-webdriver. Entire item must be displayed for it to click. Workaround following after commented out code
          # @driver.find_element(id: save_button_id).click
          @driver.execute_script('arguments[0].click();', @driver.find_element(id: save_button_id))

          Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.find_element(id: specific_save_button_id).displayed? }
          expect(@driver.find_element(id: specific_save_button_id).displayed?).to be(true)
          expect(@driver.find_element(id: specific_save_button_id).text).to eq(save_button_text)

          # TODO: Behavior of selenium-webdriver. Entire item must be displayed for it to click. Workaround following after commented out code
          # @driver.find_element(id: specific_save_button_id).click
          @driver.execute_script('arguments[0].click();', @driver.find_element(id: specific_save_button_id))

          begin
            Selenium::WebDriver::Wait.new(timeout: 10).until do
              files = Dir.glob("#{directory}/*")
              files.empty? == false && File.size(files.first) > 0
            end
          rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
          end

          files = Dir.glob("#{directory}/*")
          expect(files.empty?).to be(false)
          first = files.first
          basename = File.basename(first)
          expect(basename).to eq("#{filename}.#{extension}")
          expect(File.size(first)).to be > 0
        end
      end

      shared_examples 'standard buttons' do
        it 'has a Copy button' do
          expect(@driver.find_element(id: copy_button_id).text).to eq('Copy')
        end

        it 'has a Print button' do
          expect(@driver.find_element(id: print_button_id).text).to eq('Print')
        end

        it 'has a Save button' do
          expect(@driver.find_element(id: save_button_id).text).to eq('Save')
        end

        it 'copies the data in the table' do
          @driver.find_element(id: copy_button_id).click

          begin
            Selenium::WebDriver::Wait.new(timeout: 5).until do
              element = @driver.find_element(id: 'datatables_buttons_info')
              !element.nil? && element.displayed?
            end
          rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
          end

          element = @driver.find_element(id: 'datatables_buttons_info')
          expect(element).to_not be_nil
          expect(element.displayed?).to be(true)
        end

        context 'CSV button' do
          it_behaves_like('save button') do
            let(:extension)               { 'csv' }
            let(:save_button_text)        { 'CSV' }
            let(:specific_save_button_id) { csv_button_id }
          end
        end

        context 'Excel button' do
          it_behaves_like('save button') do
            let(:extension)               { 'xlsx' }
            let(:save_button_text)        { 'Excel' }
            let(:specific_save_button_id) { excel_button_id }
          end
        end

        context 'PDF button' do
          it_behaves_like('save button') do
            let(:extension)               { 'pdf' }
            let(:save_button_text)        { 'PDF' }
            let(:specific_save_button_id) { pdf_button_id }
          end
        end
      end

      shared_examples 'download button' do
        it 'has a Download button' do
          expect(@driver.find_element(id: download_button_id).text).to eq('Download')
        end

        context 'Download button' do
          it 'downloads the data in the table' do
            @driver.find_element(id: download_button_id).click

            begin
              Selenium::WebDriver::Wait.new(timeout: 5).until do
                files = Dir.glob("#{directory}/*")
                files.empty? == false && File.size(files.first) > 0
              end
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end

            files = Dir.glob("#{directory}/*")
            expect(files.empty?).to be(false)
            first = files.first
            basename = File.basename(first)
            expect(basename).to eq("#{filename}.csv")
            expect(File.size(first)).to be > 0
          end
        end
      end

      context 'Organizations' do
        let(:tab_id)     { 'Organizations' }
        let(:table_id)   { 'OrganizationsTable' }
        let(:event_type) { 'organization' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='OrganizationsTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 9,
                                 labels:          ['', '', 'Routes', 'Used', 'Reserved', 'Desired App States', 'App States', 'App Package States', 'Isolation Segments'],
                                 colspans:        %w[1 18 3 7 2 2 2 3 3]
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='OrganizationsTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 41,
                                 labels:          ['', 'Name', 'GUID', 'Status', 'Created', 'Updated', 'Events', 'Events Target', 'Spaces', 'Organization Roles', 'Space Roles', 'Default Users', 'Quota', 'Space Quotas', 'Domains', 'Private Service Brokers', 'Service Plan Visibilities', 'Security Groups', 'Staging Security Groups', 'Total', 'Used', 'Unused', 'Apps', 'Instances', 'Services', 'Tasks', 'Memory', 'Disk', '% CPU', 'Memory', 'Disk', 'Started', 'Stopped', 'Started', 'Stopped', 'Pending', 'Staged', 'Failed', 'Default Name', 'Default GUID', 'Related'],
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
                               '1',
                               '4',
                               '3',
                               '1',
                               cc_quota_definition[:name],
                               '1',
                               '1',
                               '1',
                               '1',
                               '1',
                               '1',
                               '1',
                               '1',
                               '0',
                               '1',
                               @driver.execute_script("return Format.formatNumber(#{cc_process[:instances]})"),
                               '1',
                               '1',
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_memory)})"),
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_disk)})"),
                               @driver.execute_script("return Format.formatNumber(#{used_cpu})"),
                               @driver.execute_script("return Format.formatNumber(#{cc_process[:memory]})"),
                               @driver.execute_script("return Format.formatNumber(#{cc_process[:disk_quota]})"),
                               cc_app[:desired_state] == 'STARTED' ? '1' : '0',
                               cc_app[:desired_state] == 'STOPPED' ? '1' : '0',
                               cc_process[:state] == 'STARTED' ? '1' : '0',
                               cc_process[:state] == 'STOPPED' ? '1' : '0',
                               cc_droplet[:state] == 'PENDING' ? '1' : '0',
                               cc_droplet[:state] == 'STAGED' ? '1' : '0',
                               cc_droplet[:state] == 'FAILED' ? '1' : '0',
                               cc_isolation_segment[:name],
                               cc_isolation_segment[:guid],
                               '1'
                             ])
          end
        end

        context 'doppler cell' do
          let(:application_instance_source) { :doppler_cell }
          it_behaves_like('has organizations table data')
        end

        context 'doppler dea' do
          it_behaves_like('has organizations table data')
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_OrganizationsTable_8')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('OrganizationsTable', cc_organization[:guid])
        end

        context 'manage organizations' do
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

          it 'has a Remove Default Isolation Segment button' do
            expect(@driver.find_element(id: 'Buttons_OrganizationsTable_5').text).to eq('Remove Default Isolation Segment')
          end

          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_OrganizationsTable_6').text).to eq('Delete')
          end

          it 'has a Delete Recursive button' do
            expect(@driver.find_element(id: 'Buttons_OrganizationsTable_7').text).to eq('Delete Recursive')
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

          context 'Remove Default Isolation Segment button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_OrganizationsTable_5' }
            end
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_OrganizationsTable_6' }
            end
          end

          context 'Delete Recursive button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_OrganizationsTable_7' }
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
              begin
                Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.find_element(id: 'ModalDialogContents').displayed? }
              rescue
              end
              expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be(true)

              expect(@driver.find_element(id: 'quotaSelector').displayed?).to be(true)
              expect(@driver.find_element(xpath: '//select[@id="quotaSelector"]/option[1]').text).to eq(cc_quota_definition[:name])
              expect(@driver.find_element(xpath: '//select[@id="quotaSelector"]/option[2]').text).to eq(cc_quota_definition2[:name])

              # Select another quota and click the set button
              @driver.find_element(xpath: '//select[@id="quotaSelector"]/option[2]').click

              # TODO: Behavior of selenium-webdriver. Entire item must be displayed for it to click. Workaround following after commented out code
              # @driver.find_element(id: 'modalDialogButton0').click
              @driver.execute_script('arguments[0].click();', @driver.find_element(id: 'modalDialogButton0'))

              check_operation_result

              begin
                Selenium::WebDriver::Wait.new(timeout: 5).until { refresh_button && @driver.find_element(xpath: "//table[@id='OrganizationsTable']/tbody/tr/td[13]").text == cc_quota_definition2[:name] }
              rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
              end
              expect(@driver.find_element(xpath: "//table[@id='OrganizationsTable']/tbody/tr/td[13]").text).to eq(cc_quota_definition2[:name])
            end
          end

          def manage_organization(button_index)
            check_first_row('OrganizationsTable')

            # TODO: Behavior of selenium-webdriver. Entire item must be displayed for it to click. Workaround following after commented out code
            # @driver.find_element(id: button_id).click
            @driver.execute_script('arguments[0].click();', @driver.find_element(id: 'Buttons_OrganizationsTable_' + button_index.to_s))

            check_operation_result
          end

          def activate_organization
            manage_organization(3)
          end

          def suspend_organization
            manage_organization(4)
          end

          def check_organization_status(status)
            begin
              Selenium::WebDriver::Wait.new(timeout: 10).until { refresh_button && @driver.find_element(xpath: "//table[@id='OrganizationsTable']/tbody/tr/td[4]").text == status }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='OrganizationsTable']/tbody/tr/td[4]").text).to eq(status)
          end

          def check_organization_default_isolation_segment
            begin
              Selenium::WebDriver::Wait.new(timeout: 10).until { refresh_button && @driver.find_element(xpath: "//table[@id='OrganizationsTable']/tbody/tr/td[39]").text == '' }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='OrganizationsTable']/tbody/tr/td[39]").text).to eq('')
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

          it 'removes the default isolation segment from the organization' do
            check_first_row('OrganizationsTable')
            @driver.find_element(id: 'Buttons_OrganizationsTable_5').click

            confirm("Are you sure you want to remove the selected organizations' default isolation segments?")

            check_operation_result

            check_organization_default_isolation_segment
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_OrganizationsTable_6' }
              let(:confirm_message) { 'Are you sure you want to delete the selected organizations?' }
            end
          end

          context 'Delete Recursive button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_OrganizationsTable_7' }
              let(:confirm_message) { 'Are you sure you want to delete the selected organizations and their contained spaces, space quotas, applications, routes, route mappings, private domains, private service brokers, service instances, service instance shares, service bindings, service keys and route bindings?' }
            end
          end

          context 'Standard buttons' do
            let(:filename) { 'organizations' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)     { 'Buttons_OrganizationsTable_8' }
              let(:print_button_id)    { 'Buttons_OrganizationsTable_9' }
              let(:save_button_id)     { 'Buttons_OrganizationsTable_10' }
              let(:csv_button_id)      { 'Buttons_OrganizationsTable_11' }
              let(:excel_button_id)    { 'Buttons_OrganizationsTable_12' }
              let(:pdf_button_id)      { 'Buttons_OrganizationsTable_13' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_OrganizationsTable_14' }
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
                              { label: 'Name',                           tag: 'div', value: cc_organization[:name] },
                              { label: 'GUID',                           tag:   nil, value: cc_organization[:guid] },
                              { label: 'Status',                         tag:   nil, value: cc_organization[:status].upcase },
                              { label: 'Created',                        tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_organization[:created_at].to_datetime.rfc3339}\")") },
                              { label: 'Updated',                        tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_organization[:updated_at].to_datetime.rfc3339}\")") },
                              { label: 'Billing Enabled',                tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_organization[:billing_enabled]})") },
                              { label: 'Events',                         tag:   'a', value: '1' },
                              { label: 'Events Target',                  tag:   'a', value: '1' },
                              { label: 'Spaces',                         tag:   'a', value: '1' },
                              { label: 'Organization Roles',             tag:   'a', value: '4' },
                              { label: 'Space Roles',                    tag:   'a', value: '3' },
                              { label: 'Default Users',                  tag:   'a', value: '1' },
                              { label: 'Quota',                          tag:   'a', value: cc_quota_definition[:name] },
                              { label: 'Quota GUID',                     tag:   nil, value: cc_quota_definition[:guid] },
                              { label: 'Space Quotas',                   tag:   'a', value: '1' },
                              { label: 'Domains',                        tag:   'a', value: '1' },
                              { label: 'Private Service Brokers',        tag:   'a', value: '1' },
                              { label: 'Service Plan Visibilities',      tag:   'a', value: '1' },
                              { label: 'Security Groups',                tag:   'a', value: '1' },
                              { label: 'Staging Security Groups',        tag:   'a', value: '1' },
                              { label: 'Total Routes',                   tag:   'a', value: '1' },
                              { label: 'Used Routes',                    tag:   nil, value: '1' },
                              { label: 'Unused Routes',                  tag:   nil, value: '0' },
                              { label: 'Total Apps',                     tag:   'a', value: '1' },
                              { label: 'Instances Used',                 tag:   'a', value: @driver.execute_script("return Format.formatNumber(#{cc_process[:instances]})") },
                              { label: 'Services Used',                  tag:   'a', value: '1' },
                              { label: 'Tasks Used',                     tag:   'a', value: '1' },
                              { label: 'Memory Used',                    tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_memory)})") },
                              { label: 'Disk Used',                      tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_disk)})") },
                              { label: 'CPU Used',                       tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{used_cpu})") },
                              { label: 'Memory Reserved',                tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_process[:memory]})") },
                              { label: 'Disk Reserved',                  tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_process[:disk_quota]})") },
                              { label: 'Desired Started Apps',           tag:   nil, value: cc_app[:desired_state] == 'STARTED' ? '1' : '0' },
                              { label: 'Desired Stopped Apps',           tag:   nil, value: cc_app[:_desired_state] == 'STOPPED' ? '1' : '0' },
                              { label: 'Started Apps',                   tag:   nil, value: cc_process[:state] == 'STARTED' ? '1' : '0' },
                              { label: 'Stopped Apps',                   tag:   nil, value: cc_process[:state] == 'STOPPED' ? '1' : '0' },
                              { label: 'Pending Apps',                   tag:   nil, value: cc_droplet[:state] == 'PENDING' ? '1' : '0' },
                              { label: 'Staged Apps',                    tag:   nil, value: cc_droplet[:state] == 'STAGED' ? '1' : '0' },
                              { label: 'Failed Apps',                    tag:   nil, value: cc_droplet[:state] == 'FAILED' ? '1' : '0' },
                              { label: 'Default Isolation Segment',      tag:   'a', value: cc_isolation_segment[:name] },
                              { label: 'Default Isolation Segment GUID', tag:   nil, value: cc_isolation_segment[:guid] },
                              { label: 'Related Isolation Segments',     tag:   'a', value: '1' }
                            ])
            end
          end

          context 'doppler cell' do
            let(:application_instance_source) { :doppler_cell }
            it_behaves_like('has organization details')
          end

          context 'doppler dea' do
            it_behaves_like('has organization details')
          end

          it 'has events link' do
            check_filter_link('Organizations', 6, 'Events', cc_organization[:guid])
          end

          it 'has events target link' do
            check_filter_link('Organizations', 7, 'Events', "#{cc_organization[:name]}/")
          end

          it 'has spaces link' do
            check_filter_link('Organizations', 8, 'Spaces', "#{cc_organization[:name]}/")
          end

          it 'has organization roles link' do
            check_filter_link('Organizations', 9, 'OrganizationRoles', cc_organization[:guid])
          end

          it 'has space roles link' do
            check_filter_link('Organizations', 10, 'SpaceRoles', "#{cc_organization[:name]}/")
          end

          it 'has users link' do
            check_filter_link('Organizations', 11, 'Users', "#{cc_organization[:name]}/")
          end

          it 'has quotas link' do
            check_filter_link('Organizations', 12, 'Quotas', cc_quota_definition[:guid])
          end

          it 'has space quotas link' do
            check_filter_link('Organizations', 14, 'SpaceQuotas', cc_organization[:guid])
          end

          it 'has domains link' do
            check_filter_link('Organizations', 15, 'Domains', cc_organization[:name])
          end

          it 'has service brokers link' do
            check_filter_link('Organizations', 16, 'ServiceBrokers', "#{cc_organization[:name]}/")
          end

          it 'has service plan visibilities link' do
            check_filter_link('Organizations', 17, 'ServicePlanVisibilities', cc_organization[:guid])
          end

          it 'has security groups spaces link' do
            check_filter_link('Organizations', 18, 'SecurityGroupsSpaces', "#{cc_organization[:name]}/")
          end

          it 'has staging security groups spaces link' do
            check_filter_link('Organizations', 19, 'StagingSecurityGroupsSpaces', "#{cc_organization[:name]}/")
          end

          it 'has routes link' do
            check_filter_link('Organizations', 20, 'Routes', "#{cc_organization[:name]}/")
          end

          it 'has applications link' do
            check_filter_link('Organizations', 23, 'Applications', "#{cc_organization[:name]}/")
          end

          it 'has application instances link' do
            check_filter_link('Organizations', 24, 'ApplicationInstances', "#{cc_organization[:name]}/")
          end

          it 'has services instances link' do
            check_filter_link('Organizations', 25, 'ServiceInstances', "#{cc_organization[:name]}/")
          end

          it 'has tasks link' do
            check_filter_link('Organizations', 26, 'Tasks', "#{cc_organization[:name]}/")
          end

          it 'has default isolation segments link' do
            check_filter_link('Organizations', 39, 'IsolationSegments', cc_organization[:default_isolation_segment_guid])
          end

          it 'has organizations isolation segments link' do
            check_filter_link('Organizations', 41, 'OrganizationsIsolationSegments', cc_organization[:guid])
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
                                 expected_length: 9,
                                 labels:          ['', '', 'Routes', 'Used', 'Reserved', 'Desired App States', 'App States', 'App Package States', 'Isolation Segment'],
                                 colspans:        %w[1 14 3 7 2 2 2 3 2]
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='SpacesTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 36,
                                 labels:          ['', 'Name', 'GUID', 'Target', 'Created', 'Updated', 'SSH Allowed', 'Events', 'Events Target', 'Roles', 'Default Users', 'Space Quota', 'Private Service Brokers', 'Security Groups', 'Staging Security Groups', 'Total', 'Used', 'Unused', 'Apps', 'Instances', 'Services', 'Tasks', 'Memory', 'Disk', '% CPU', 'Memory', 'Disk', 'Started', 'Stopped', 'Started', 'Stopped', 'Pending', 'Staged', 'Failed', 'Name', 'GUID'],
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
                               @driver.execute_script("return Format.formatBoolean(#{cc_space[:allow_ssh]})"),
                               '1',
                               '1',
                               '3',
                               '1',
                               cc_space_quota_definition[:name],
                               '1',
                               '1',
                               '1',
                               '1',
                               '1',
                               '0',
                               '1',
                               @driver.execute_script("return Format.formatNumber(#{cc_process[:instances]})"),
                               '1',
                               '1',
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_memory)})"),
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_disk)})"),
                               @driver.execute_script("return Format.formatNumber(#{used_cpu})"),
                               @driver.execute_script("return Format.formatNumber(#{cc_process[:memory]})"),
                               @driver.execute_script("return Format.formatNumber(#{cc_process[:disk_quota]})"),
                               cc_app[:desired_state] == 'STARTED' ? '1' : '0',
                               cc_app[:desired_state] == 'STOPPED' ? '1' : '0',
                               cc_process[:state] == 'STARTED' ? '1' : '0',
                               cc_process[:state] == 'STOPPED' ? '1' : '0',
                               cc_droplet[:state] == 'PENDING' ? '1' : '0',
                               cc_droplet[:state] == 'STAGED' ? '1' : '0',
                               cc_droplet[:state] == 'FAILED' ? '1' : '0',
                               cc_isolation_segment[:name],
                               cc_isolation_segment[:guid]
                             ])
          end
        end

        context 'doppler cell' do
          let(:application_instance_source) { :doppler_cell }
          it_behaves_like 'has spaces table data'
        end

        context 'doppler dea' do
          it_behaves_like 'has spaces table data'
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_SpacesTable_7')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('SpacesTable', cc_space[:guid])
        end

        context 'manage spaces' do
          it 'has a Rename button' do
            expect(@driver.find_element(id: 'Buttons_SpacesTable_0').text).to eq('Rename')
          end

          it 'has an Allow SSH button' do
            expect(@driver.find_element(id: 'Buttons_SpacesTable_1').text).to eq('Allow SSH')
          end

          it 'has a Disallow SSH button' do
            expect(@driver.find_element(id: 'Buttons_SpacesTable_2').text).to eq('Disallow SSH')
          end

          it 'has a Remove Isolation Segment button' do
            expect(@driver.find_element(id: 'Buttons_SpacesTable_3').text).to eq('Remove Isolation Segment')
          end

          it 'has a Delete Unmapped Routes button' do
            expect(@driver.find_element(id: 'Buttons_SpacesTable_4').text).to eq('Delete Unmapped Routes')
          end

          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_SpacesTable_5').text).to eq('Delete')
          end

          it 'has a Delete Recursive button' do
            expect(@driver.find_element(id: 'Buttons_SpacesTable_6').text).to eq('Delete Recursive')
          end

          context 'Rename button' do
            it_behaves_like('click button without selecting exactly one row') do
              let(:button_id) { 'Buttons_SpacesTable_0' }
            end
          end

          context 'Allow SSH button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_SpacesTable_1' }
            end
          end

          context 'Disallow SSH button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_SpacesTable_2' }
            end
          end

          context 'Remove Isolation Segment button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_SpacesTable_3' }
            end
          end

          context 'Delete Unmapped Routes button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_SpacesTable_4' }
            end
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_SpacesTable_5' }
            end
          end

          context 'Delete Recursive button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_SpacesTable_6' }
            end
          end

          context 'Rename button' do
            it_behaves_like('rename first row') do
              let(:button_id)     { 'Buttons_SpacesTable_0' }
              let(:title_text)    { 'Rename Space' }
              let(:object_rename) { cc_space_rename }
            end
          end

          def manage_space(button_index)
            check_first_row('SpacesTable')

            # TODO: Behavior of selenium-webdriver. Entire item must be displayed for it to click. Workaround following after commented out code
            # @driver.find_element(id: button_id).click
            @driver.execute_script('arguments[0].click();', @driver.find_element(id: 'Buttons_SpacesTable_' + button_index.to_s))

            check_operation_result
          end

          def allow_ssh_space
            manage_space(1)
          end

          def disallow_ssh_space
            manage_space(2)
          end

          def remove_isolation_segment_space
            manage_space(3)
          end

          def check_space_ssh(ssh)
            begin
              Selenium::WebDriver::Wait.new(timeout: 10).until { refresh_button && @driver.find_element(xpath: "//table[@id='SpacesTable']/tbody/tr/td[7]").text == ssh }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='SpacesTable']/tbody/tr/td[7]").text).to eq(ssh)
          end

          def check_space_isolation_segment
            begin
              Selenium::WebDriver::Wait.new(timeout: 10).until { refresh_button && @driver.find_element(xpath: "//table[@id='SpacesTable']/tbody/tr/td[35]").text == '' }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='SpacesTable']/tbody/tr/td[35]").text).to eq('')
          end

          def check_space_unused_routes(expected_value)
            begin
              Selenium::WebDriver::Wait.new(timeout: 10).until { refresh_button && @driver.find_element(xpath: "//table[@id='SpacesTable']/tbody/tr/td[18]").text == expected_value }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='SpacesTable']/tbody/tr/td[18]").text).to eq(expected_value)
          end

          it 'SSH allows the selected space' do
            disallow_ssh_space
            check_space_ssh('false')

            allow_ssh_space
            check_space_ssh('true')
          end

          it 'SSH disallows the selected space' do
            disallow_ssh_space
            check_space_ssh('false')
          end

          it 'removes the isolation segment from the space' do
            check_first_row('SpacesTable')
            @driver.find_element(id: 'Buttons_SpacesTable_3').click

            confirm("Are you sure you want to remove the selected spaces' isolation segments?")

            check_operation_result

            check_space_isolation_segment
          end

          context 'deletes the unmapped routes from the space' do
            let(:use_route) { false }

            it 'deletes the unmapped routes from the space' do
              check_space_unused_routes('1')
              expect(@driver.find_element(xpath: "//table[@id='SpacesTable']/tbody/tr/td[18]").text).to eq('1')
              check_first_row('SpacesTable')
              @driver.find_element(id: 'Buttons_SpacesTable_4').click

              confirm("Are you sure you want to delete the selected spaces' unmapped routes?")

              check_operation_result

              check_space_unused_routes('0')
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_SpacesTable_5' }
              let(:confirm_message) { 'Are you sure you want to delete the selected spaces?' }
            end
          end

          context 'Delete Recursive button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_SpacesTable_6' }
              let(:confirm_message) { 'Are you sure you want to delete the selected spaces and their contained applications, routes, route mappings, private service brokers, service instances, service instance shares, service bindings, service keys and route bindings?' }
            end
          end

          context 'Standard buttons' do
            let(:filename) { 'spaces' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_SpacesTable_7' }
              let(:print_button_id) { 'Buttons_SpacesTable_8' }
              let(:save_button_id)  { 'Buttons_SpacesTable_9' }
              let(:csv_button_id)   { 'Buttons_SpacesTable_10' }
              let(:excel_button_id) { 'Buttons_SpacesTable_11' }
              let(:pdf_button_id)   { 'Buttons_SpacesTable_12' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_SpacesTable_13' }
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
                              { label: 'Organization GUID',       tag:   nil, value: cc_organization[:guid] },
                              { label: 'Created',                 tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_space[:created_at].to_datetime.rfc3339}\")") },
                              { label: 'Updated',                 tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_space[:updated_at].to_datetime.rfc3339}\")") },
                              { label: 'SSH Allowed',             tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_space[:allow_ssh]})") },
                              { label: 'Events',                  tag:   'a', value: '1' },
                              { label: 'Events Target',           tag:   'a', value: '1' },
                              { label: 'Roles',                   tag:   'a', value: '3' },
                              { label: 'Default Users',           tag:   'a', value: '1' },
                              { label: 'Space Quota',             tag:   'a', value: cc_space_quota_definition[:name] },
                              { label: 'Space Quota GUID',        tag:   nil, value: cc_space_quota_definition[:guid] },
                              { label: 'Private Service Brokers', tag:   'a', value: '1' },
                              { label: 'Security Groups',         tag:   'a', value: '1' },
                              { label: 'Staging Security Groups', tag:   'a', value: '1' },
                              { label: 'Total Routes',            tag:   'a', value: '1' },
                              { label: 'Used Routes',             tag:   nil, value: '1' },
                              { label: 'Unused Routes',           tag:   nil, value: '0' },
                              { label: 'Total Apps',              tag:   'a', value: '1' },
                              { label: 'Instances Used',          tag:   'a', value: @driver.execute_script("return Format.formatNumber(#{cc_process[:instances]})") },
                              { label: 'Services Used',           tag:   'a', value: '1' },
                              { label: 'Tasks Used',              tag:   'a', value: '1' },
                              { label: 'Memory Used',             tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_memory)})") },
                              { label: 'Disk Used',               tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_disk)})") },
                              { label: 'CPU Used',                tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{used_cpu})") },
                              { label: 'Memory Reserved',         tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_process[:memory]})") },
                              { label: 'Disk Reserved',           tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_process[:disk_quota]})") },
                              { label: 'Desired Started Apps',    tag:   nil, value: cc_app[:desired_state] == 'STARTED' ? '1' : '0' },
                              { label: 'Desired Stopped Apps',    tag:   nil, value: cc_app[:desired_state] == 'STOPPED' ? '1' : '0' },
                              { label: 'Started Apps',            tag:   nil, value: cc_process[:state] == 'STARTED' ? '1' : '0' },
                              { label: 'Stopped Apps',            tag:   nil, value: cc_process[:state] == 'STOPPED' ? '1' : '0' },
                              { label: 'Pending Apps',            tag:   nil, value: cc_droplet[:state] == 'PENDING' ? '1' : '0' },
                              { label: 'Staged Apps',             tag:   nil, value: cc_droplet[:state] == 'STAGED' ? '1' : '0' },
                              { label: 'Failed Apps',             tag:   nil, value: cc_droplet[:state] == 'FAILED' ? '1' : '0' },
                              { label: 'Isolation Segment',       tag:   'a', value: cc_isolation_segment[:name] },
                              { label: 'Isolation Segment GUID',  tag:   nil, value: cc_isolation_segment[:guid] }
                            ])
            end
          end

          context 'doppler cell' do
            let(:application_instance_source) { :doppler_cell }
            it_behaves_like('has space details')
          end

          context 'doppler dea' do
            it_behaves_like('has space details')
          end

          it 'has organizations link' do
            check_filter_link('Spaces', 2, 'Organizations', cc_organization[:guid])
          end

          it 'has events link' do
            check_filter_link('Spaces', 7, 'Events', cc_space[:guid])
          end

          it 'has events target link' do
            check_filter_link('Spaces', 8, 'Events', "#{cc_organization[:name]}/#{cc_space[:name]}")
          end

          it 'has space roles link' do
            check_filter_link('Spaces', 9, 'SpaceRoles', cc_space[:guid])
          end

          it 'has users link' do
            check_filter_link('Spaces', 10, 'Users', "#{cc_organization[:name]}/#{cc_space[:name]}")
          end

          it 'has space quotas link' do
            check_filter_link('Spaces', 11, 'SpaceQuotas', cc_space_quota_definition[:guid])
          end

          it 'has service brokers link' do
            check_filter_link('Spaces', 13, 'ServiceBrokers', "#{cc_organization[:name]}/#{cc_space[:name]}")
          end

          it 'has security groups spaces link' do
            check_filter_link('Spaces', 14, 'SecurityGroupsSpaces', cc_space[:guid])
          end

          it 'has staging security groups spaces link' do
            check_filter_link('Spaces', 15, 'StagingSecurityGroupsSpaces', cc_space[:guid])
          end

          it 'has routes link' do
            check_filter_link('Spaces', 16, 'Routes', "#{cc_organization[:name]}/#{cc_space[:name]}")
          end

          it 'has applications link' do
            check_filter_link('Spaces', 19, 'Applications', "#{cc_organization[:name]}/#{cc_space[:name]}")
          end

          it 'has application instances link' do
            check_filter_link('Spaces', 20, 'ApplicationInstances', "#{cc_organization[:name]}/#{cc_space[:name]}")
          end

          it 'has service instances link' do
            check_filter_link('Spaces', 21, 'ServiceInstances', "#{cc_organization[:name]}/#{cc_space[:name]}")
          end

          it 'has tasks link' do
            check_filter_link('Spaces', 22, 'Tasks', "#{cc_organization[:name]}/#{cc_space[:name]}")
          end

          it 'has isolation segments link' do
            check_filter_link('Spaces', 35, 'IsolationSegments', cc_isolation_segment[:guid])
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
                                 colspans:        %w[1 18 4 2 1]
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ApplicationsTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 26,
                                 labels:          ['', 'Name', 'GUID', 'Desired State', 'State', 'Package State', 'Staging Failed Reason', 'Created', 'Updated', 'Diego', 'SSH Enabled', 'Docker Image', 'Stack', 'Buildpack', 'Buildpack GUID', 'Events', 'Instances', 'Route Mappings', 'Service Bindings', 'Tasks', 'Memory', 'Disk', '% CPU', 'Memory', 'Disk', 'Target'],
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
                               cc_app[:desired_state],
                               cc_process[:state],
                               @driver.execute_script('return Constants.STATUS__STAGED'),
                               cc_droplet[:error_id],
                               cc_app[:created_at].to_datetime.rfc3339,
                               cc_app[:updated_at].to_datetime.rfc3339,
                               @driver.execute_script("return Format.formatBoolean(#{cc_process[:diego]})"),
                               @driver.execute_script("return Format.formatBoolean(#{cc_app[:enable_ssh]})"),
                               @driver.execute_script("return Format.formatBoolean(#{!cc_package[:docker_image].nil?})"),
                               cc_stack[:name],
                               cc_buildpack[:name],
                               cc_buildpack[:guid],
                               '1',
                               '1',
                               '1',
                               '1',
                               '1',
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_memory)})"),
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_disk)})"),
                               @driver.execute_script("return Format.formatNumber(#{used_cpu})"),
                               @driver.execute_script("return Format.formatNumber(#{cc_process[:memory]})"),
                               @driver.execute_script("return Format.formatNumber(#{cc_process[:disk_quota]})"),
                               "#{cc_organization[:name]}/#{cc_space[:name]}"
                             ])
          end
        end

        context 'doppler cell' do
          let(:application_instance_source) { :doppler_cell }
          it_behaves_like('has applications table data')
        end

        context 'doppler dea' do
          it_behaves_like('has applications table data')
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_ApplicationsTable_10')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('ApplicationsTable', cc_app[:guid])
        end

        context 'manage applications' do
          def manage_application(button_index)
            check_first_row('ApplicationsTable')

            # TODO: Behavior of selenium-webdriver. Entire item must be displayed for it to click. Workaround following after commented out code
            # @driver.find_element(id: 'Buttons_ApplicationsTable_' + button_index.to_s).click
            @driver.execute_script('arguments[0].click();', @driver.find_element(id: 'Buttons_ApplicationsTable_' + button_index.to_s))

            check_operation_result
          end

          def check_app_state(expect_state)
            begin
              Selenium::WebDriver::Wait.new(timeout: 20).until { refresh_button && @driver.find_element(xpath: "//table[@id='ApplicationsTable']/tbody/tr/td[5]").text == expect_state }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='ApplicationsTable']/tbody/tr/td[5]").text).to eq(expect_state)
          end

          def check_app_diego(diego)
            begin
              Selenium::WebDriver::Wait.new(timeout: 20).until { refresh_button && @driver.find_element(xpath: "//table[@id='ApplicationsTable']/tbody/tr/td[10]").text == diego }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='ApplicationsTable']/tbody/tr/td[10]").text).to eq(diego)
          end

          def check_app_ssh(ssh)
            begin
              Selenium::WebDriver::Wait.new(timeout: 20).until { refresh_button && @driver.find_element(xpath: "//table[@id='ApplicationsTable']/tbody/tr/td[11]").text == ssh }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='ApplicationsTable']/tbody/tr/td[11]").text).to eq(ssh)
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

          it 'has an Enable Diego button' do
            expect(@driver.find_element(id: 'Buttons_ApplicationsTable_4').text).to eq('Enable Diego')
          end

          it 'has a Disable Diego button' do
            expect(@driver.find_element(id: 'Buttons_ApplicationsTable_5').text).to eq('Disable Diego')
          end

          it 'has an Enable SSH button' do
            expect(@driver.find_element(id: 'Buttons_ApplicationsTable_6').text).to eq('Enable SSH')
          end

          it 'has a Disable SSH button' do
            expect(@driver.find_element(id: 'Buttons_ApplicationsTable_7').text).to eq('Disable SSH')
          end

          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_ApplicationsTable_8').text).to eq('Delete')
          end

          it 'has a Delete Recursive button' do
            expect(@driver.find_element(id: 'Buttons_ApplicationsTable_9').text).to eq('Delete Recursive')
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

          context 'Enable Diego button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ApplicationsTable_4' }
            end
          end

          context 'Disable Diego button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ApplicationsTable_5' }
            end
          end

          context 'Enable SSH button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ApplicationsTable_6' }
            end
          end

          context 'Disable SSH button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ApplicationsTable_7' }
            end
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ApplicationsTable_8' }
            end
          end

          context 'Delete Recursive button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ApplicationsTable_9' }
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

          it 'diego enables the selected application' do
            # let app with diego disabled first
            manage_application(5)
            check_app_diego('false')

            # diego enable the app
            manage_application(4)
            check_app_diego('true')
          end

          it 'diego disables the selected application' do
            # let app with diego enabled first
            manage_application(4)
            check_app_diego('true')

            # diego disable the app
            manage_application(5)
            check_app_diego('false')
          end

          it 'SSH enables the selected application' do
            # let app with SSH disabled first
            manage_application(7)
            check_app_ssh('false')

            # SSH enable the app
            manage_application(6)
            check_app_ssh('true')
          end

          it 'SSH disables the selected application' do
            # let app with SSH enabled first
            manage_application(6)
            check_app_ssh('true')

            # SSH disable the app
            manage_application(7)
            check_app_ssh('false')
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_ApplicationsTable_8' }
              let(:confirm_message) { 'Are you sure you want to delete the selected applications?' }
            end
          end

          context 'Delete Recursive button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_ApplicationsTable_9' }
              let(:confirm_message) { 'Are you sure you want to delete the selected applications and their associated service bindings?' }
            end
          end

          context 'Standard buttons' do
            let(:filename) { 'applications' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_ApplicationsTable_10' }
              let(:print_button_id) { 'Buttons_ApplicationsTable_11' }
              let(:save_button_id)  { 'Buttons_ApplicationsTable_12' }
              let(:csv_button_id)   { 'Buttons_ApplicationsTable_13' }
              let(:excel_button_id) { 'Buttons_ApplicationsTable_14' }
              let(:pdf_button_id)   { 'Buttons_ApplicationsTable_15' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_ApplicationsTable_16' }
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
                              { label: 'Desired State',              tag:   nil, value: cc_app[:desired_state] },
                              { label: 'State',                      tag:   nil, value: cc_process[:state] },
                              { label: 'Package State',              tag:   nil, value: cc_droplet[:state] },
                              { label: 'Staging Failed Reason',      tag:   nil, value: cc_droplet[:error_id] },
                              { label: 'Staging Failed Description', tag:   nil, value: cc_droplet[:error_description] },
                              { label: 'Created',                    tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_app[:created_at].to_datetime.rfc3339}\")") },
                              { label: 'Updated',                    tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_app[:updated_at].to_datetime.rfc3339}\")") },
                              { label: 'Diego',                      tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_process[:diego]})") },
                              { label: 'SSH Enabled',                tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_app[:enable_ssh]})") },
                              { label: 'Docker Image',               tag:   nil, value: cc_package[:docker_image] },
                              { label: 'Stack',                      tag:   'a', value: cc_stack[:name] },
                              { label: 'Stack GUID',                 tag:   nil, value: cc_stack[:guid] },
                              { label: 'Buildpack',                  tag:   'a', value: cc_buildpack[:name] },
                              { label: 'Buildpack GUID',             tag:   nil, value: cc_buildpack[:guid] },
                              { label: 'Detected Buildpack',         tag:   nil, value: cc_droplet[:buildpack_receipt_detect_output] },
                              { label: 'Command',                    tag:   nil, value: cc_process[:command] },
                              { label: 'Detected Start Command',     tag:   nil, value: cc_process[:command] },
                              { label: 'File Descriptors',           tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_process[:file_descriptors]})") },
                              { label: 'Events',                     tag:   'a', value: '1' },
                              { label: 'Instances',                  tag:   'a', value: '1' },
                              { label: 'Route Mappings',             tag:   'a', value: '1' },
                              { label: 'Service Bindings',           tag:   'a', value: '1' },
                              { label: 'Tasks',                      tag:   'a', value: '1' },
                              { label: 'Memory Used',                tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_memory)})") },
                              { label: 'Disk Used',                  tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_disk)})") },
                              { label: 'CPU Used',                   tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{used_cpu})") },
                              { label: 'Memory Reserved',            tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_process[:memory]})") },
                              { label: 'Disk Reserved',              tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_process[:disk_quota]})") },
                              { label: 'Space',                      tag:   'a', value: cc_space[:name] },
                              { label: 'Space GUID',                 tag:   nil, value: cc_space[:guid] },
                              { label: 'Organization',               tag:   'a', value: cc_organization[:name] },
                              { label: 'Organization GUID',          tag:   nil, value: cc_organization[:guid] }
                            ])
            end
          end

          context 'doppler cell' do
            let(:application_instance_source) { :doppler_cell }
            it_behaves_like('has application details')
          end

          context 'doppler dea' do
            it_behaves_like('has application details')
          end

          it 'has environment variables' do
            expect(@driver.find_element(id: 'ApplicationsEnvironmentVariablesDetailsLabel').displayed?).to be(true)

            check_table_headers(columns:         @driver.find_elements(xpath: "//div[@id='ApplicationsEnvironmentVariablesTableContainer']/div[2]/div[4]/div/div/table/thead/tr/th"),
                                expected_length: 3,
                                labels:          ['', 'Key', 'Value'],
                                colspans:        nil)

            check_table_data(@driver.find_elements(xpath: "//table[@id='ApplicationsEnvironmentVariablesTable']/tbody/tr/td"),
                             [
                               '',
                               cc_app_environment_variable.keys.first,
                               "\"#{cc_app_environment_variable.values.first}\""
                             ])
          end

          it 'environment variables subtable has allowscriptaccess property set to sameDomain' do
            check_allowscriptaccess_attribute('Buttons_ApplicationsEnvironmentVariablesTable_1')
          end

          it 'has a checkbox in the first column' do
            check_checkbox_guid('ApplicationsEnvironmentVariablesTable', "#{cc_app[:guid]}/environment_variables/#{cc_app_environment_variable_name}")
          end

          context 'manage environment variables subtable' do
            it 'has a Delete button' do
              expect(@driver.find_element(id: 'Buttons_ApplicationsEnvironmentVariablesTable_0').text).to eq('Delete')
            end

            context 'Delete button' do
              it_behaves_like('click button without selecting any rows') do
                let(:button_id) { 'Buttons_ApplicationsEnvironmentVariablesTable_0' }
              end
            end

            context 'Delete button' do
              it_behaves_like('delete first row') do
                let(:table_id)                { 'ApplicationsEnvironmentVariablesTable' }
                let(:button_id)               { 'Buttons_ApplicationsEnvironmentVariablesTable_0' }
                let(:check_no_data_available) { false }
                let(:confirm_message)         { "Are you sure you want to delete the application's selected environment variables?" }
              end
            end

            context 'Standard buttons' do
              let(:filename) { 'application_environment_variables' }

              it_behaves_like('standard buttons') do
                let(:copy_button_id)  { 'Buttons_ApplicationsEnvironmentVariablesTable_1' }
                let(:print_button_id) { 'Buttons_ApplicationsEnvironmentVariablesTable_2' }
                let(:save_button_id)  { 'Buttons_ApplicationsEnvironmentVariablesTable_3' }
                let(:csv_button_id)   { 'Buttons_ApplicationsEnvironmentVariablesTable_4' }
                let(:excel_button_id) { 'Buttons_ApplicationsEnvironmentVariablesTable_5' }
                let(:pdf_button_id)   { 'Buttons_ApplicationsEnvironmentVariablesTable_6' }
              end
            end
          end

          it 'has stacks link' do
            check_filter_link('Applications', 12, 'Stacks', cc_stack[:name])
          end

          it 'has buildpacks link' do
            check_filter_link('Applications', 14, 'Buildpacks', cc_buildpack[:guid])
          end

          it 'has events link' do
            check_filter_link('Applications', 20, 'Events', cc_app[:guid])
          end

          it 'has application instances link' do
            check_filter_link('Applications', 21, 'ApplicationInstances', cc_app[:guid])
          end

          it 'has route mappings link' do
            check_filter_link('Applications', 22, 'RouteMappings', cc_app[:guid])
          end

          it 'has service bindings link' do
            check_filter_link('Applications', 23, 'ServiceBindings', cc_app[:guid])
          end

          it 'has tasks link' do
            check_filter_link('Applications', 24, 'Tasks', cc_app[:guid])
          end

          it 'has spaces link' do
            check_filter_link('Applications', 30, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('Applications', 32, 'Organizations', cc_organization[:guid])
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
                                 colspans:        %w[1 6 3 2 3]
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ApplicationInstancesTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 15,
                                 labels:          ['', 'Name', 'Application GUID', 'Index', 'Metrics', 'Diego', 'Stack', 'Memory', 'Disk', '% CPU', 'Memory', 'Disk', 'Target', 'DEA', 'Cell'],
                                 colspans:        nil
                               }
                             ])
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
                               Time.at(rep_envelope.timestamp / BILLION).to_datetime.rfc3339,
                               @driver.execute_script('return Format.formatBoolean(true)'),
                               cc_stack[:name],
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(rep_container_metric_envelope.containerMetric.memoryBytes)})"),
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(rep_container_metric_envelope.containerMetric.diskBytes)})"),
                               @driver.execute_script("return Format.formatNumber(#{rep_container_metric_envelope.containerMetric.cpuPercentage})"),
                               @driver.execute_script("return Format.formatNumber(#{cc_process[:memory]})"),
                               @driver.execute_script("return Format.formatNumber(#{cc_process[:disk_quota]})"),
                               "#{cc_organization[:name]}/#{cc_space[:name]}",
                               nil,
                               "#{rep_envelope.ip}:#{rep_envelope.index}"
                             ])
          end
        end

        context 'doppler dea' do
          it 'has table data' do
            check_table_data(@driver.find_elements(xpath: "//table[@id='ApplicationInstancesTable']/tbody/tr/td"),
                             [
                               '',
                               cc_app[:name],
                               cc_app[:guid],
                               @driver.execute_script("return Format.formatNumber(#{cc_app_instance_index})"),
                               Time.at(dea_envelope.timestamp / BILLION).to_datetime.rfc3339,
                               @driver.execute_script('return Format.formatBoolean(false)'),
                               cc_stack[:name],
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(dea_container_metric_envelope.containerMetric.memoryBytes)})"),
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(dea_container_metric_envelope.containerMetric.diskBytes)})"),
                               @driver.execute_script("return Format.formatNumber(#{dea_container_metric_envelope.containerMetric.cpuPercentage})"),
                               @driver.execute_script("return Format.formatNumber(#{cc_process[:memory]})"),
                               @driver.execute_script("return Format.formatNumber(#{cc_process[:disk_quota]})"),
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

          context 'Standard buttons' do
            let(:filename) { 'application_instances' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_ApplicationInstancesTable_1' }
              let(:print_button_id) { 'Buttons_ApplicationInstancesTable_2' }
              let(:save_button_id)  { 'Buttons_ApplicationInstancesTable_3' }
              let(:csv_button_id)   { 'Buttons_ApplicationInstancesTable_4' }
              let(:excel_button_id) { 'Buttons_ApplicationInstancesTable_5' }
              let(:pdf_button_id)   { 'Buttons_ApplicationInstancesTable_6' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_ApplicationInstancesTable_7' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          context 'doppler cell' do
            let(:application_instance_source) { :doppler_cell }

            it 'has details' do
              check_details([
                              # rubocop:disable Layout/ExtraSpacing
                              { label: 'Name',              tag:   nil, value: cc_app[:name] },
                              # rubocop:enable Layout/ExtraSpacing
                              { label: 'Application GUID',  tag: 'div', value: cc_app[:guid] },
                              { label: 'Index',             tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_app_instance_index})") },
                              { label: 'Metrics',           tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{Time.at(rep_envelope.timestamp / BILLION).to_datetime.rfc3339}\")") },
                              { label: 'Diego',             tag:   nil, value: @driver.execute_script('return Format.formatBoolean(true)') },
                              { label: 'Stack',             tag:   'a', value: cc_stack[:name] },
                              { label: 'Stack GUID',        tag:   nil, value: cc_stack[:guid] },
                              { label: 'Memory Used',       tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(rep_container_metric_envelope.containerMetric.memoryBytes)})") },
                              { label: 'Disk Used',         tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(rep_container_metric_envelope.containerMetric.diskBytes)})") },
                              { label: 'CPU Used',          tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{rep_container_metric_envelope.containerMetric.cpuPercentage})") },
                              { label: 'Memory Reserved',   tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_process[:memory]})") },
                              { label: 'Disk Reserved',     tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_process[:disk_quota]})") },
                              { label: 'Space',             tag:   'a', value: cc_space[:name] },
                              { label: 'Space GUID',        tag:   nil, value: cc_space[:guid] },
                              { label: 'Organization',      tag:   'a', value: cc_organization[:name] },
                              { label: 'Organization GUID', tag:   nil, value: cc_organization[:guid] },
                              { label: 'Cell',              tag:   'a', value: "#{rep_envelope.ip}:#{rep_envelope.index}" }
                            ])
            end
          end

          context 'doppler dea' do
            it 'has details' do
              check_details([
                              { label: 'Name',              tag:   nil, value: cc_app[:name] },
                              { label: 'Application GUID',  tag: 'div', value: cc_app[:guid] },
                              { label: 'Index',             tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_app_instance_index})") },
                              { label: 'Metrics',           tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{Time.at(dea_envelope.timestamp / BILLION).to_datetime.rfc3339}\")") },
                              { label: 'Diego',             tag:   nil, value: @driver.execute_script('return Format.formatBoolean(false)') },
                              { label: 'Stack',             tag:   'a', value: cc_stack[:name] },
                              { label: 'Stack GUID',        tag:   nil, value: cc_stack[:guid] },
                              { label: 'Memory Used',       tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(dea_container_metric_envelope.containerMetric.memoryBytes)})") },
                              { label: 'Disk Used',         tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(dea_container_metric_envelope.containerMetric.diskBytes)})") },
                              { label: 'CPU Used',          tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{dea_container_metric_envelope.containerMetric.cpuPercentage})") },
                              { label: 'Memory Reserved',   tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_process[:memory]})") },
                              { label: 'Disk Reserved',     tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_process[:disk_quota]})") },
                              { label: 'Space',             tag:   'a', value: cc_space[:name] },
                              { label: 'Space GUID',        tag:   nil, value: cc_space[:guid] },
                              { label: 'Organization',      tag:   'a', value: cc_organization[:name] },
                              { label: 'Organization GUID', tag:   nil, value: cc_organization[:guid] },
                              { label: 'DEA',               tag:   'a', value: "#{dea_envelope.ip}:#{dea_envelope.index}" }
                            ])
            end
          end

          it 'has applications link' do
            check_filter_link('ApplicationInstances', 1, 'Applications', cc_app[:guid])
          end

          it 'has stacks link' do
            check_filter_link('ApplicationInstances', 5, 'Stacks', cc_stack[:guid])
          end

          it 'has spaces link' do
            check_filter_link('ApplicationInstances', 12, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('ApplicationInstances', 14, 'Organizations', cc_organization[:guid])
          end

          context 'doppler cell' do
            let(:application_instance_source) { :doppler_cell }

            it 'has Cells link' do
              check_filter_link('ApplicationInstances', 16, 'Cells', "#{rep_envelope.ip}:#{rep_envelope.index}")
            end
          end

          context 'doppler dea' do
            it 'has DEAs link' do
              check_filter_link('ApplicationInstances', 16, 'DEAs', "#{dea_envelope.ip}:#{dea_envelope.index}")
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
                                 expected_length: 13,
                                 labels:          ['', 'URI', 'Host', 'Domain', 'Port', 'Path', 'GUID', 'Created', 'Updated', 'Events', 'Route Mappings', 'Route Bindings', 'Target'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='RoutesTable']/tbody/tr/td"),
                           [
                             '',
                             "http://#{cc_route[:host]}.#{cc_domain[:name]}#{cc_route[:path]}",
                             cc_route[:host],
                             cc_domain[:name],
                             '',
                             cc_route[:path],
                             cc_route[:guid],
                             cc_route[:created_at].to_datetime.rfc3339,
                             cc_route[:updated_at].to_datetime.rfc3339,
                             '1',
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
              let(:confirm_message) { 'Are you sure you want to delete the selected routes and their associated route mappings and route bindings?' }
            end
          end

          context 'Standard buttons' do
            let(:filename) { 'routes' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_RoutesTable_2' }
              let(:print_button_id) { 'Buttons_RoutesTable_3' }
              let(:save_button_id)  { 'Buttons_RoutesTable_4' }
              let(:csv_button_id)   { 'Buttons_RoutesTable_5' }
              let(:excel_button_id) { 'Buttons_RoutesTable_6' }
              let(:pdf_button_id)   { 'Buttons_RoutesTable_7' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_RoutesTable_8' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'URI',               tag:   'a', value: "http://#{cc_route[:host]}.#{cc_domain[:name]}#{cc_route[:path]}" },
                            { label: 'Host',              tag:   nil, value: cc_route[:host] },
                            { label: 'Domain',            tag:   'a', value: cc_domain[:name] },
                            { label: 'Domain GUID',       tag:   nil, value: cc_domain[:guid] },
                            { label: 'Path',              tag:   nil, value: cc_route[:path] },
                            { label: 'GUID',              tag: 'div', value: cc_route[:guid] },
                            { label: 'Created',           tag:   nil, value: Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.execute_script("return Format.formatDateString(\"#{cc_route[:created_at].to_datetime.rfc3339}\")") } },
                            { label: 'Updated',           tag:   nil, value: Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.execute_script("return Format.formatDateString(\"#{cc_route[:updated_at].to_datetime.rfc3339}\")") } },
                            { label: 'Events',            tag:   'a', value: '1' },
                            { label: 'Route Mappings',    tag:   'a', value: '1' },
                            { label: 'Route Bindings',    tag:   'a', value: '1' },
                            { label: 'Space',             tag:   'a', value: cc_space[:name] },
                            { label: 'Space GUID',        tag:   nil, value: cc_space[:guid] },
                            { label: 'Organization',      tag:   'a', value: cc_organization[:name] },
                            { label: 'Organization GUID', tag:   nil, value: cc_organization[:guid] }
                          ])
          end

          it 'has domains link' do
            check_filter_link('Routes', 2, 'Domains', cc_domain[:guid])
          end

          it 'has events link' do
            check_filter_link('Routes', 8, 'Events', cc_route[:guid])
          end

          it 'has route mappings link' do
            check_filter_link('Routes', 9, 'RouteMappings', cc_route[:guid])
          end

          it 'has route bindings link' do
            check_filter_link('Routes', 10, 'RouteBindings', cc_route[:guid])
          end

          it 'has spaces link' do
            check_filter_link('Routes', 11, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('Routes', 13, 'Organizations', cc_organization[:guid])
          end
        end
      end

      context 'Routes Mappings' do
        let(:tab_id)     { 'RouteMappings' }
        let(:table_id)   { 'RouteMappingsTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='RouteMappingsTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 5,
                                 labels:          ['', '', 'Application', 'Route', ''],
                                 colspans:        %w[1 3 2 2 1]
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='RouteMappingsTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 9,
                                 labels:          ['', 'GUID', 'Created', 'Updated', 'Name', 'GUID', 'URI', 'GUID', 'Target'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='RouteMappingsTable']/tbody/tr/td"),
                           [
                             '',
                             cc_route_mapping[:guid],
                             cc_route_mapping[:created_at].to_datetime.rfc3339,
                             cc_route_mapping[:updated_at].to_datetime.rfc3339,
                             cc_app[:name],
                             cc_app[:guid],
                             "http://#{cc_route[:host]}.#{cc_domain[:name]}#{cc_route[:path]}",
                             cc_route[:guid],
                             "#{cc_organization[:name]}/#{cc_space[:name]}"
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_RouteMappingsTable_1')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('RouteMappingsTable', cc_route_mapping[:guid])
        end

        context 'manage route mappings' do
          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_RouteMappingsTable_0').text).to eq('Delete')
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_RouteMappingsTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_RouteMappingsTable_0' }
              let(:confirm_message) { 'Are you sure you want to delete the selected route mappings?' }
            end
          end

          context 'Standard buttons' do
            let(:filename) { 'route_mappings' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_RouteMappingsTable_1' }
              let(:print_button_id) { 'Buttons_RouteMappingsTable_2' }
              let(:save_button_id)  { 'Buttons_RouteMappingsTable_3' }
              let(:csv_button_id)   { 'Buttons_RouteMappingsTable_4' }
              let(:excel_button_id) { 'Buttons_RouteMappingsTable_5' }
              let(:pdf_button_id)   { 'Buttons_RouteMappingsTable_6' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_RouteMappingsTable_7' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'GUID',              tag: 'div', value: cc_route_mapping[:guid] },
                            { label: 'Created',           tag:   nil, value: Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.execute_script("return Format.formatDateString(\"#{cc_route_mapping[:created_at].to_datetime.rfc3339}\")") } },
                            { label: 'Updated',           tag:   nil, value: Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.execute_script("return Format.formatDateString(\"#{cc_route_mapping[:updated_at].to_datetime.rfc3339}\")") } },
                            { label: 'URI',               tag:   'a', value: "http://#{cc_route[:host]}.#{cc_domain[:name]}#{cc_route[:path]}" },
                            { label: 'Application',       tag:   'a', value: cc_app[:name] },
                            { label: 'Application GUID',  tag:   nil, value: cc_app[:guid] },
                            { label: 'Route GUID',        tag:   'a', value: cc_route[:guid] },
                            { label: 'Domain',            tag:   'a', value: cc_domain[:name] },
                            { label: 'Domain GUID',       tag:   nil, value: cc_domain[:guid] },
                            { label: 'Space',             tag:   'a', value: cc_space[:name] },
                            { label: 'Space GUID',        tag:   nil, value: cc_space[:guid] },
                            { label: 'Organization',      tag:   'a', value: cc_organization[:name] },
                            { label: 'Organization GUID', tag:   nil, value: cc_organization[:guid] }
                          ])
          end

          it 'has applications link' do
            check_filter_link('RouteMappings', 4, 'Applications', cc_app[:guid])
          end

          it 'has routes link' do
            check_filter_link('RouteMappings', 6, 'Routes', cc_route[:guid])
          end

          it 'has domains link' do
            check_filter_link('RouteMappings', 7, 'Domains', cc_domain[:guid])
          end

          it 'has spaces link' do
            check_filter_link('RouteMappings', 9, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('RouteMappings', 11, 'Organizations', cc_organization[:guid])
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
                                 colspans:        %w[1 11 4 9 7 4 1]
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ServiceInstancesTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 37,
                                 labels:          ['', 'Name', 'GUID', 'Created', 'Updated', 'User Provided', 'Drain', 'Events', 'Shares', 'Service Bindings', 'Service Keys', 'Route Bindings', 'Type', 'State', 'Created', 'Updated', 'Name', 'GUID', 'Unique ID', 'Created', 'Updated', 'Bindable', 'Free', 'Active', 'Public', 'Label', 'GUID', 'Unique ID', 'Created', 'Updated', 'Bindable', 'Active', 'Name', 'GUID', 'Created', 'Updated', 'Target'],
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
                             @driver.execute_script("return Format.formatBoolean(#{!cc_service_instance[:syslog_drain_url].nil? && cc_service_instance[:syslog_drain_url].length.positive?})"),
                             '1',
                             '1',
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
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:bindable]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})"),
                             cc_service[:label],
                             cc_service[:guid],
                             cc_service[:unique_id],
                             cc_service[:created_at].to_datetime.rfc3339,
                             cc_service[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{cc_service[:bindable]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})"),
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
              let(:confirm_message) { 'Are you sure you want to delete the selected service instances and their associated shares, service bindings, service keys and route bindings?' }
            end
          end

          context 'Purge button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_ServiceInstancesTable_3' }
              let(:confirm_message) { 'Are you sure you want to purge the selected service instances?' }
            end
          end

          context 'Standard buttons' do
            let(:filename) { 'service_instances' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_ServiceInstancesTable_4' }
              let(:print_button_id) { 'Buttons_ServiceInstancesTable_5' }
              let(:save_button_id)  { 'Buttons_ServiceInstancesTable_6' }
              let(:csv_button_id)   { 'Buttons_ServiceInstancesTable_7' }
              let(:excel_button_id) { 'Buttons_ServiceInstancesTable_8' }
              let(:pdf_button_id)   { 'Buttons_ServiceInstancesTable_9' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_ServiceInstancesTable_10' }
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
                            { label: 'Service Instance Name',                                     tag: 'div', value: cc_service_instance[:name] },
                            { label: 'Service Instance GUID',                                     tag:   nil, value: cc_service_instance[:guid] },
                            { label: 'Service Instance Created',                                  tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_instance[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Instance Updated',                                  tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_instance[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Instance User Provided',                            tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{!cc_service_instance[:is_gateway_service]})") },
                            { label: 'Service Instance Route Service URL',                        tag:   nil, value: cc_service_instance[:route_service_url] },
                            { label: 'Service Instance Syslog Drain URL',                         tag:   nil, value: cc_service_instance[:syslog_drain_url] },
                            { label: 'Service Instance Dashboard URL',                            tag:   'a', value: cc_service_instance[:dashboard_url] },
                            { label: 'Service Instance Events',                                   tag:   'a', value: '1' },
                            { label: 'Service Instance Shares',                                   tag:   'a', value: '1' },
                            { label: 'Service Bindings',                                          tag:   'a', value: '1' },
                            { label: 'Service Keys',                                              tag:   'a', value: '1' },
                            { label: 'Route Bindings',                                            tag:   'a', value: '1' },
                            { label: 'Service Instance Last Operation Type',                      tag:  nil, value: cc_service_instance_operation[:type] },
                            { label: 'Service Instance Last Operation State',                     tag:  nil, value: cc_service_instance_operation[:state] },
                            { label: 'Service Instance Last Operation Created',                   tag:  nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_instance_operation[:created_at]}\")") },
                            { label: 'Service Instance Last Operation Updated',                   tag:  nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_instance_operation[:updated_at]}\")") },
                            { label: 'Service Instance Last Operation Broker-Provided Operation', tag:  nil, value: cc_service_instance_operation[:broker_provided_operation] },
                            { label: 'Service Instance Last Operation Description',               tag:  nil, value: cc_service_instance_operation[:description] },
                            { label: 'Service Instance Tag',                                      tag:   nil, value: service_instance_tags_json[0] },
                            { label: 'Service Instance Tag',                                      tag:   nil, value: service_instance_tags_json[1] },
                            { label: 'Service Plan Name',                                         tag:   'a', value: cc_service_plan[:name] },
                            { label: 'Service Plan GUID',                                         tag:   nil, value: cc_service_plan[:guid] },
                            { label: 'Service Plan Unique ID',                                    tag:   nil, value: cc_service_plan[:unique_id] },
                            { label: 'Service Plan Created',                                      tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_plan[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Updated',                                      tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_plan[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Bindable',                                     tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:bindable]})") },
                            { label: 'Service Plan Free',                                         tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})") },
                            { label: 'Service Plan Active',                                       tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})") },
                            { label: 'Service Plan Public',                                       tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})") },
                            { label: 'Service Label',                                             tag:   'a', value: cc_service[:label] },
                            { label: 'Service GUID',                                              tag:   nil, value: cc_service[:guid] },
                            { label: 'Service Unique ID',                                         tag:   nil, value: cc_service[:unique_id] },
                            { label: 'Service Created',                                           tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Updated',                                           tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Bindable',                                          tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:bindable]})") },
                            { label: 'Service Active',                                            tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})") },
                            { label: 'Service Broker Name',                                       tag:   'a', value: cc_service_broker[:name] },
                            { label: 'Service Broker GUID',                                       tag:   nil, value: cc_service_broker[:guid] },
                            { label: 'Service Broker Created',                                    tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Broker Updated',                                    tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Space',                                                     tag:   'a', value: cc_space[:name] },
                            { label: 'Space GUID',                                                tag:   nil, value: cc_space[:guid] },
                            { label: 'Organization',                                              tag:   'a', value: cc_organization[:name] },
                            { label: 'Organization GUID',                                         tag:   nil, value: cc_organization[:guid] }
                          ])
          end

          it 'has credentials' do
            expect(@driver.find_element(id: 'ServiceInstancesCredentialsDetailsLabel').displayed?).to be(true)

            check_table_headers(columns:         @driver.find_elements(xpath: "//div[@id='ServiceInstancesCredentialsTableContainer']/div[2]/div[4]/div/div/table/thead/tr/th"),
                                expected_length: 2,
                                labels:          %w[Key Value],
                                colspans:        nil)

            check_table_data(@driver.find_elements(xpath: "//table[@id='ServiceInstancesCredentialsTable']/tbody/tr/td"),
                             [
                               cc_service_instance_credential.keys.first,
                               "\"#{cc_service_instance_credential.values.first}\""
                             ])
          end

          it 'credentials subtable has allowscriptaccess property set to sameDomain' do
            check_allowscriptaccess_attribute('Buttons_ServiceInstancesCredentialsTable_0')
          end

          context 'manage credentials subtable' do
            context 'Standard buttons' do
              let(:filename) { 'service_instance_credentials' }

              it_behaves_like('standard buttons') do
                let(:copy_button_id)  { 'Buttons_ServiceInstancesCredentialsTable_0' }
                let(:print_button_id) { 'Buttons_ServiceInstancesCredentialsTable_1' }
                let(:save_button_id)  { 'Buttons_ServiceInstancesCredentialsTable_2' }
                let(:csv_button_id)   { 'Buttons_ServiceInstancesCredentialsTable_3' }
                let(:excel_button_id) { 'Buttons_ServiceInstancesCredentialsTable_4' }
                let(:pdf_button_id)   { 'Buttons_ServiceInstancesCredentialsTable_5' }
              end
            end
          end

          it 'has events link' do
            check_filter_link('ServiceInstances', 8, 'Events', cc_service_instance[:guid])
          end

          it 'has shared service instances link' do
            check_filter_link('ServiceInstances', 9, 'SharedServiceInstances', cc_service_instance[:guid])
          end

          it 'has service bindings link' do
            check_filter_link('ServiceInstances', 10, 'ServiceBindings', cc_service_instance[:guid])
          end

          it 'has service keys link' do
            check_filter_link('ServiceInstances', 11, 'ServiceKeys', cc_service_instance[:guid])
          end

          it 'has route bindings link' do
            check_filter_link('ServiceInstances', 12, 'RouteBindings', cc_service_instance[:guid])
          end

          it 'has service plans link' do
            check_filter_link('ServiceInstances', 21, 'ServicePlans', cc_service_plan[:guid])
          end

          it 'has services link' do
            check_filter_link('ServiceInstances', 30, 'Services', cc_service[:guid])
          end

          it 'has service brokers link' do
            check_filter_link('ServiceInstances', 37, 'ServiceBrokers', cc_service_broker[:guid])
          end

          it 'has spaces link' do
            check_filter_link('ServiceInstances', 41, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('ServiceInstances', 43, 'Organizations', cc_organization[:guid])
          end
        end
      end

      context 'Shared Service Instances' do
        let(:tab_id)     { 'SharedServiceInstances' }
        let(:table_id)   { 'SharedServiceInstancesTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='SharedServiceInstancesTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 6,
                                 labels:          ['', 'Service Instance', 'Service Plan', 'Service', 'Service Broker', ''],
                                 colspans:        %w[1 4 9 7 4 2]
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='SharedServiceInstancesTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 27,
                                 labels:          ['', 'Name', 'GUID', 'Created', 'Updated', 'Name', 'GUID', 'Unique ID', 'Created', 'Updated', 'Bindable', 'Free', 'Active', 'Public', 'Label', 'GUID', 'Unique ID', 'Created', 'Updated', 'Bindable', 'Active', 'Name', 'GUID', 'Created', 'Updated', 'Source', 'Target'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='SharedServiceInstancesTable']/tbody/tr/td"),
                           [
                             '',
                             cc_service_instance[:name],
                             cc_service_instance[:guid],
                             cc_service_instance[:created_at].to_datetime.rfc3339,
                             cc_service_instance[:updated_at].to_datetime.rfc3339,
                             cc_service_plan[:name],
                             cc_service_plan[:guid],
                             cc_service_plan[:unique_id],
                             cc_service_plan[:created_at].to_datetime.rfc3339,
                             cc_service_plan[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:bindable]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})"),
                             cc_service[:label],
                             cc_service[:guid],
                             cc_service[:unique_id],
                             cc_service[:created_at].to_datetime.rfc3339,
                             cc_service[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{cc_service[:bindable]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})"),
                             cc_service_broker[:name],
                             cc_service_broker[:guid],
                             cc_service_broker[:created_at].to_datetime.rfc3339,
                             cc_service_broker[:updated_at].to_datetime.rfc3339,
                             "#{cc_organization[:name]}/#{cc_space[:name]}",
                             "#{cc_organization[:name]}/#{cc_space[:name]}"
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_SharedServiceInstancesTable_1')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('SharedServiceInstancesTable', "#{cc_service_instance[:guid]}/#{cc_space[:guid]}")
        end

        context 'manage shared service instances' do
          it 'has an Unshare button' do
            expect(@driver.find_element(id: 'Buttons_SharedServiceInstancesTable_0').text).to eq('Unshare')
          end

          context 'Unshare button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_SharedServiceInstancesTable_0' }
            end
          end

          context 'Unshare button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_SharedServiceInstancesTable_0' }
              let(:confirm_message) { 'Are you sure you want to unshare the selected service instance shares?' }
            end
          end

          context 'Standard buttons' do
            let(:filename) { 'shared_service_instances' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_SharedServiceInstancesTable_1' }
              let(:print_button_id) { 'Buttons_SharedServiceInstancesTable_2' }
              let(:save_button_id)  { 'Buttons_SharedServiceInstancesTable_3' }
              let(:csv_button_id)   { 'Buttons_SharedServiceInstancesTable_4' }
              let(:excel_button_id) { 'Buttons_SharedServiceInstancesTable_5' }
              let(:pdf_button_id)   { 'Buttons_SharedServiceInstancesTable_6' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_SharedServiceInstancesTable_7' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            # rubocop:disable Layout/ExtraSpacing
                            { label: 'Service Instance Name',    tag:   nil, value: cc_service_instance[:name] },
                            # rubocop:enable Layout/ExtraSpacing
                            { label: 'Service Instance GUID',    tag: 'div', value: cc_service_instance[:guid] },
                            { label: 'Service Instance Created', tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_instance[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Instance Updated', tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_instance[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Name',        tag:   'a', value: cc_service_plan[:name] },
                            { label: 'Service Plan GUID',        tag:   nil, value: cc_service_plan[:guid] },
                            { label: 'Service Plan Unique ID',   tag:   nil, value: cc_service_plan[:unique_id] },
                            { label: 'Service Plan Created',     tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_plan[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Updated',     tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_plan[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Bindable',    tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:bindable]})") },
                            { label: 'Service Plan Free',        tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})") },
                            { label: 'Service Plan Active',      tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})") },
                            { label: 'Service Plan Public',      tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})") },
                            { label: 'Service Label',            tag:   'a', value: cc_service[:label] },
                            { label: 'Service GUID',             tag:   nil, value: cc_service[:guid] },
                            { label: 'Service Unique ID',        tag:   nil, value: cc_service[:unique_id] },
                            { label: 'Service Created',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Updated',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Bindable',         tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:bindable]})") },
                            { label: 'Service Active',           tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})") },
                            { label: 'Service Broker Name',      tag:   'a', value: cc_service_broker[:name] },
                            { label: 'Service Broker GUID',      tag:   nil, value: cc_service_broker[:guid] },
                            { label: 'Service Broker Created',   tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Broker Updated',   tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Source Space',             tag:   'a', value: cc_space[:name] },
                            { label: 'Source Space GUID',        tag:   nil, value: cc_space[:guid] },
                            { label: 'Source Organization',      tag:   'a', value: cc_organization[:name] },
                            { label: 'Source Organization GUID', tag:   nil, value: cc_organization[:guid] },
                            { label: 'Target Space',             tag:   'a', value: cc_space[:name] },
                            { label: 'Target Space GUID',        tag:   nil, value: cc_space[:guid] },
                            { label: 'Target Organization',      tag:   'a', value: cc_organization[:name] },
                            { label: 'Target Organization GUID', tag:   nil, value: cc_organization[:guid] }
                          ])
          end

          it 'has service instances link' do
            check_filter_link('SharedServiceInstances', 1, 'ServiceInstances', cc_service_instance[:guid])
          end

          it 'has service plans link' do
            check_filter_link('SharedServiceInstances', 4, 'ServicePlans', cc_service_plan[:guid])
          end

          it 'has services link' do
            check_filter_link('SharedServiceInstances', 13, 'Services', cc_service[:guid])
          end

          it 'has service brokers link' do
            check_filter_link('SharedServiceInstances', 20, 'ServiceBrokers', cc_service_broker[:guid])
          end

          it 'has source spaces link' do
            check_filter_link('SharedServiceInstances', 24, 'Spaces', cc_space[:guid])
          end

          it 'has source organizations link' do
            check_filter_link('SharedServiceInstances', 26, 'Organizations', cc_organization[:guid])
          end

          it 'has target spaces link' do
            check_filter_link('SharedServiceInstances', 28, 'Spaces', cc_space[:guid])
          end

          it 'has target organizations link' do
            check_filter_link('SharedServiceInstances', 30, 'Organizations', cc_organization[:guid])
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
                                 colspans:        %w[1 7 2 4 8 6 4 1]
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ServiceBindingsTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 33,
                                 labels:          ['', 'Name', 'GUID', 'Created', 'Updated', 'Drain', 'Volume Mounts', 'Events', 'Name', 'GUID', 'Name', 'GUID', 'Created', 'Updated', 'Name', 'GUID', 'Unique ID', 'Created', 'Updated', 'Free', 'Active', 'Public', 'Label', 'GUID', 'Unique ID', 'Created', 'Updated', 'Active', 'Name', 'GUID', 'Created', 'Updated', 'Target'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='ServiceBindingsTable']/tbody/tr/td"),
                           [
                             '',
                             cc_service_binding[:name],
                             cc_service_binding[:guid],
                             cc_service_binding[:created_at].to_datetime.rfc3339,
                             cc_service_binding[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{!cc_service_binding[:syslog_drain_url].nil? && cc_service_binding[:syslog_drain_url].length.positive?})"),
                             @driver.execute_script("return Format.formatBoolean(#{!cc_service_binding[:volume_mounts_salt].nil?})"),
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
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})"),
                             cc_service[:label],
                             cc_service[:guid],
                             cc_service[:unique_id],
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

          context 'Standard buttons' do
            let(:filename) { 'service_bindings' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_ServiceBindingsTable_1' }
              let(:print_button_id) { 'Buttons_ServiceBindingsTable_2' }
              let(:save_button_id)  { 'Buttons_ServiceBindingsTable_3' }
              let(:csv_button_id)   { 'Buttons_ServiceBindingsTable_4' }
              let(:excel_button_id) { 'Buttons_ServiceBindingsTable_5' }
              let(:pdf_button_id)   { 'Buttons_ServiceBindingsTable_6' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_ServiceBindingsTable_7' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            # rubocop:disable Layout/ExtraSpacing
                            { label: 'Service Binding Name',             tag:   nil, value: cc_service_binding[:name] },
                            # rubocop:enable Layout/ExtraSpacing
                            { label: 'Service Binding GUID',             tag: 'div', value: cc_service_binding[:guid] },
                            { label: 'Service Binding Created',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_binding[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Binding Updated',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_binding[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Binding Syslog Drain URL', tag:   nil, value: cc_service_binding[:syslog_drain_url] },
                            { label: 'Service Binding Events',           tag:   'a', value: '1' },
                            { label: 'Application Name',                 tag:   'a', value: cc_app[:name] },
                            { label: 'Application GUID',                 tag:   nil, value: cc_app[:guid] },
                            { label: 'Service Instance Name',            tag:   'a', value: cc_service_instance[:name] },
                            { label: 'Service Instance GUID',            tag:   nil, value: cc_service_instance[:guid] },
                            { label: 'Service Instance Created',         tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_instance[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Instance Updated',         tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_instance[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Name',                tag:   'a', value: cc_service_plan[:name] },
                            { label: 'Service Plan GUID',                tag:   nil, value: cc_service_plan[:guid] },
                            { label: 'Service Plan Unique ID',           tag:   nil, value: cc_service_plan[:unique_id] },
                            { label: 'Service Plan Created',             tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_plan[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Updated',             tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_plan[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Free',                tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})") },
                            { label: 'Service Plan Active',              tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})") },
                            { label: 'Service Plan Public',              tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})") },
                            { label: 'Service Label',                    tag:   'a', value: cc_service[:label] },
                            { label: 'Service GUID',                     tag:   nil, value: cc_service[:guid] },
                            { label: 'Service Unique ID',                tag:   nil, value: cc_service[:unique_id] },
                            { label: 'Service Created',                  tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Updated',                  tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Active',                   tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})") },
                            { label: 'Service Broker Name',              tag:   'a', value: cc_service_broker[:name] },
                            { label: 'Service Broker GUID',              tag:   nil, value: cc_service_broker[:guid] },
                            { label: 'Service Broker Created',           tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Broker Updated',           tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Space',                            tag:   'a', value: cc_space[:name] },
                            { label: 'Space GUID',                       tag:   nil, value: cc_space[:guid] },
                            { label: 'Organization',                     tag:   'a', value: cc_organization[:name] },
                            { label: 'Organization GUID',                tag:   nil, value: cc_organization[:guid] }
                          ])
          end

          it 'has credentials' do
            expect(@driver.find_element(id: 'ServiceBindingsCredentialsDetailsLabel').displayed?).to be(true)

            check_table_headers(columns:         @driver.find_elements(xpath: "//div[@id='ServiceBindingsCredentialsTableContainer']/div[2]/div[4]/div/div/table/thead/tr/th"),
                                expected_length: 2,
                                labels:          %w[Key Value],
                                colspans:        nil)

            check_table_data(@driver.find_elements(xpath: "//table[@id='ServiceBindingsCredentialsTable']/tbody/tr/td"),
                             [
                               cc_service_binding_credential.keys.first,
                               "\"#{cc_service_binding_credential.values.first}\""
                             ])
          end

          it 'credentials subtable has allowscriptaccess property set to sameDomain' do
            check_allowscriptaccess_attribute('Buttons_ServiceBindingsCredentialsTable_0')
          end

          context 'manage credentials subtable' do
            context 'Standard buttons' do
              let(:filename) { 'service_binding_credentials' }

              it_behaves_like('standard buttons') do
                let(:copy_button_id)  { 'Buttons_ServiceBindingsCredentialsTable_0' }
                let(:print_button_id) { 'Buttons_ServiceBindingsCredentialsTable_1' }
                let(:save_button_id)  { 'Buttons_ServiceBindingsCredentialsTable_2' }
                let(:csv_button_id)   { 'Buttons_ServiceBindingsCredentialsTable_3' }
                let(:excel_button_id) { 'Buttons_ServiceBindingsCredentialsTable_4' }
                let(:pdf_button_id)   { 'Buttons_ServiceBindingsCredentialsTable_5' }
              end
            end
          end

          it 'has volume mounts' do
            expect(@driver.find_element(id: 'ServiceBindingsVolumeMountsDetailsLabel').displayed?).to be(true)

            check_table_headers(columns:         @driver.find_elements(xpath: "//div[@id='ServiceBindingsVolumeMountsTableContainer']/div[2]/div[4]/div/div/table/thead/tr/th"),
                                expected_length: 3,
                                labels:          ['Container Directory', 'Device Type', 'Mode'],
                                colspans:        nil)

            check_table_data(@driver.find_elements(xpath: "//table[@id='ServiceBindingsVolumeMountsTable']/tbody/tr/td"),
                             [
                               cc_service_binding_volume_mounts[0]['container_dir'],
                               cc_service_binding_volume_mounts[0]['device_type'],
                               cc_service_binding_volume_mounts[0]['mode']
                             ])
          end

          it 'volume mounts subtable has allowscriptaccess property set to sameDomain' do
            check_allowscriptaccess_attribute('Buttons_ServiceBindingsVolumeMountsTable_0')
          end

          context 'manage volume mounts subtable' do
            context 'Standard buttons' do
              let(:filename) { 'service_binding_volume_mounts' }

              it_behaves_like('standard buttons') do
                let(:copy_button_id)  { 'Buttons_ServiceBindingsVolumeMountsTable_0' }
                let(:print_button_id) { 'Buttons_ServiceBindingsVolumeMountsTable_1' }
                let(:save_button_id)  { 'Buttons_ServiceBindingsVolumeMountsTable_2' }
                let(:csv_button_id)   { 'Buttons_ServiceBindingsVolumeMountsTable_3' }
                let(:excel_button_id) { 'Buttons_ServiceBindingsVolumeMountsTable_4' }
                let(:pdf_button_id)   { 'Buttons_ServiceBindingsVolumeMountsTable_5' }
              end
            end
          end

          it 'has events' do
            check_filter_link('ServiceBindings', 5, 'Events', cc_service_binding[:guid])
          end

          it 'has applications link' do
            check_filter_link('ServiceBindings', 6, 'Applications', cc_app[:guid])
          end

          it 'has service instances link' do
            check_filter_link('ServiceBindings', 8, 'ServiceInstances', cc_service_instance[:guid])
          end

          it 'has service plans link' do
            check_filter_link('ServiceBindings', 12, 'ServicePlans', cc_service_plan[:guid])
          end

          it 'has services link' do
            check_filter_link('ServiceBindings', 20, 'Services', cc_service[:guid])
          end

          it 'has service brokers link' do
            check_filter_link('ServiceBindings', 26, 'ServiceBrokers', cc_service_broker[:guid])
          end

          it 'has spaces link' do
            check_filter_link('ServiceBindings', 30, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('ServiceBindings', 32, 'Organizations', cc_organization[:guid])
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
                                 colspans:        %w[1 5 4 8 6 4 1]
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ServiceKeysTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 29,
                                 labels:          ['', 'Name', 'GUID', 'Created', 'Updated', 'Events', 'Name', 'GUID', 'Created', 'Updated', 'Name', 'GUID', 'Unique ID', 'Created', 'Updated', 'Free', 'Active', 'Public', 'Label', 'GUID', 'Unique ID', 'Created', 'Updated', 'Active', 'Name', 'GUID', 'Created', 'Updated', 'Target'],
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
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})"),
                             cc_service[:label],
                             cc_service[:guid],
                             cc_service[:unique_id],
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

          context 'Standard buttons' do
            let(:filename) { 'service_keys' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_ServiceKeysTable_1' }
              let(:print_button_id) { 'Buttons_ServiceKeysTable_2' }
              let(:save_button_id)  { 'Buttons_ServiceKeysTable_3' }
              let(:csv_button_id)   { 'Buttons_ServiceKeysTable_4' }
              let(:excel_button_id) { 'Buttons_ServiceKeysTable_5' }
              let(:pdf_button_id)   { 'Buttons_ServiceKeysTable_6' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_ServiceKeysTable_7' }
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
                            { label: 'Service Plan Free',        tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})") },
                            { label: 'Service Plan Active',      tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})") },
                            { label: 'Service Plan Public',      tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})") },
                            { label: 'Service Label',            tag:   'a', value: cc_service[:label] },
                            { label: 'Service GUID',             tag:   nil, value: cc_service[:guid] },
                            { label: 'Service Unique ID',        tag:   nil, value: cc_service[:unique_id] },
                            { label: 'Service Created',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Updated',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Active',           tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})") },
                            { label: 'Service Broker Name',      tag:   'a', value: cc_service_broker[:name] },
                            { label: 'Service Broker GUID',      tag:   nil, value: cc_service_broker[:guid] },
                            { label: 'Service Broker Created',   tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Broker Updated',   tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Space',                    tag:   'a', value: cc_space[:name] },
                            { label: 'Space GUID',               tag:   nil, value: cc_space[:guid] },
                            { label: 'Organization',             tag:   'a', value: cc_organization[:name] },
                            { label: 'Organization GUID',        tag:   nil, value: cc_organization[:guid] }
                          ])
          end

          it 'has credentials' do
            expect(@driver.find_element(id: 'ServiceKeysCredentialsDetailsLabel').displayed?).to be(true)

            check_table_headers(columns:         @driver.find_elements(xpath: "//div[@id='ServiceKeysCredentialsTableContainer']/div[2]/div[4]/div/div/table/thead/tr/th"),
                                expected_length: 2,
                                labels:          %w[Key Value],
                                colspans:        nil)

            check_table_data(@driver.find_elements(xpath: "//table[@id='ServiceKeysCredentialsTable']/tbody/tr/td"),
                             [
                               cc_service_key_credential.keys.first,
                               "\"#{cc_service_key_credential.values.first}\""
                             ])
          end

          it 'credentials subtable has allowscriptaccess property set to sameDomain' do
            check_allowscriptaccess_attribute('Buttons_ServiceKeysCredentialsTable_0')
          end

          context 'manage credentials subtable' do
            context 'Standard buttons' do
              let(:filename) { 'service_key_credentials' }

              it_behaves_like('standard buttons') do
                let(:copy_button_id)  { 'Buttons_ServiceKeysCredentialsTable_0' }
                let(:print_button_id) { 'Buttons_ServiceKeysCredentialsTable_1' }
                let(:save_button_id)  { 'Buttons_ServiceKeysCredentialsTable_2' }
                let(:csv_button_id)   { 'Buttons_ServiceKeysCredentialsTable_3' }
                let(:excel_button_id) { 'Buttons_ServiceKeysCredentialsTable_4' }
                let(:pdf_button_id)   { 'Buttons_ServiceKeysCredentialsTable_5' }
              end
            end
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
            check_filter_link('ServiceKeys', 17, 'Services', cc_service[:guid])
          end

          it 'has service brokers link' do
            check_filter_link('ServiceKeys', 23, 'ServiceBrokers', cc_service_broker[:guid])
          end

          it 'has spaces link' do
            check_filter_link('ServiceKeys', 27, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('ServiceKeys', 29, 'Organizations', cc_organization[:guid])
          end
        end
      end

      context 'Route Bindings' do
        let(:tab_id)     { 'RouteBindings' }
        let(:table_id)   { 'RouteBindingsTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='RouteBindingsTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 8,
                                 labels:          ['', 'Route Binding', 'Route', 'Service Instance', 'Service Plan', 'Service', 'Service Broker', ''],
                                 colspans:        %w[1 3 2 4 8 6 4 1]
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='RouteBindingsTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 29,
                                 labels:          ['', 'GUID', 'Created', 'Updated', 'URI', 'GUID', 'Name', 'GUID', 'Created', 'Updated', 'Name', 'GUID', 'Unique ID', 'Created', 'Updated', 'Free', 'Active', 'Public', 'Label', 'GUID', 'Unique ID', 'Created', 'Updated', 'Active', 'Name', 'GUID', 'Created', 'Updated', 'Target'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='RouteBindingsTable']/tbody/tr/td"),
                           [
                             '',
                             cc_route_binding[:guid],
                             cc_route_binding[:created_at].to_datetime.rfc3339,
                             cc_route_binding[:updated_at].to_datetime.rfc3339,
                             "http://#{cc_route[:host]}.#{cc_domain[:name]}#{cc_route[:path]}",
                             cc_route[:guid],
                             cc_service_instance[:name],
                             cc_service_instance[:guid],
                             cc_service_instance[:created_at].to_datetime.rfc3339,
                             cc_service_instance[:updated_at].to_datetime.rfc3339,
                             cc_service_plan[:name],
                             cc_service_plan[:guid],
                             cc_service_plan[:unique_id],
                             cc_service_plan[:created_at].to_datetime.rfc3339,
                             cc_service_plan[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})"),
                             cc_service[:label],
                             cc_service[:guid],
                             cc_service[:unique_id],
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
          check_allowscriptaccess_attribute('Buttons_RouteBindingsTable_1')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('RouteBindingsTable', "#{cc_service_instance[:guid]}/#{cc_route[:guid]}/#{cc_service_instance[:is_gateway_service]}")
        end

        context 'manage route bindings' do
          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_RouteBindingsTable_0').text).to eq('Delete')
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_RouteBindingsTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_RouteBindingsTable_0' }
              let(:confirm_message) { 'Are you sure you want to delete the selected route bindings?' }
            end
          end

          context 'Standard buttons' do
            let(:filename) { 'route_bindings' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_RouteBindingsTable_1' }
              let(:print_button_id) { 'Buttons_RouteBindingsTable_2' }
              let(:save_button_id)  { 'Buttons_RouteBindingsTable_3' }
              let(:csv_button_id)   { 'Buttons_RouteBindingsTable_4' }
              let(:excel_button_id) { 'Buttons_RouteBindingsTable_5' }
              let(:pdf_button_id)   { 'Buttons_RouteBindingsTable_6' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_RouteBindingsTable_7' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Route Binding GUID',        tag: 'div', value: cc_route_binding[:guid] },
                            { label: 'Route Binding Created',     tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_route_binding[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Route Binding Updated',     tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_route_binding[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Route Binding Service URL', tag:   nil, value: cc_route_binding[:route_service_url] },
                            { label: 'Route URI',                 tag:   'a', value: "http://#{cc_route[:host]}.#{cc_domain[:name]}#{cc_route[:path]}" },
                            { label: 'Route GUID',                tag:   'a', value: cc_route[:guid] },
                            { label: 'Domain',                    tag:   'a', value: cc_domain[:name] },
                            { label: 'Domain GUID',               tag:   nil, value: cc_domain[:guid] },
                            { label: 'Service Instance Name',     tag:   'a', value: cc_service_instance[:name] },
                            { label: 'Service Instance GUID',     tag:   nil, value: cc_service_instance[:guid] },
                            { label: 'Service Instance Created',  tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_instance[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Instance Updated',  tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_instance[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Name',         tag:   'a', value: cc_service_plan[:name] },
                            { label: 'Service Plan GUID',         tag:   nil, value: cc_service_plan[:guid] },
                            { label: 'Service Plan Unique ID',    tag:   nil, value: cc_service_plan[:unique_id] },
                            { label: 'Service Plan Created',      tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_plan[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Updated',      tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_plan[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Free',         tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})") },
                            { label: 'Service Plan Active',       tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})") },
                            { label: 'Service Plan Public',       tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})") },
                            { label: 'Service Label',             tag:   'a', value: cc_service[:label] },
                            { label: 'Service GUID',              tag:   nil, value: cc_service[:guid] },
                            { label: 'Service Unique ID',         tag:   nil, value: cc_service[:unique_id] },
                            { label: 'Service Created',           tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Updated',           tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Active',            tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})") },
                            { label: 'Service Broker Name',       tag:   'a', value: cc_service_broker[:name] },
                            { label: 'Service Broker GUID',       tag:   nil, value: cc_service_broker[:guid] },
                            { label: 'Service Broker Created',    tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Broker Updated',    tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Space',                     tag:   'a', value: cc_space[:name] },
                            { label: 'Space GUID',                tag:   nil, value: cc_space[:guid] },
                            { label: 'Organization',              tag:   'a', value: cc_organization[:name] },
                            { label: 'Organization GUID',         tag:   nil, value: cc_organization[:guid] }
                          ])
          end

          it 'has routes link' do
            check_filter_link('RouteBindings', 5, 'Routes', cc_route[:guid])
          end

          it 'has domains link' do
            check_filter_link('RouteBindings', 6, 'Domains', cc_domain[:guid])
          end

          it 'has service instances link' do
            check_filter_link('RouteBindings', 8, 'ServiceInstances', cc_service_instance[:guid])
          end

          it 'has service plans link' do
            check_filter_link('RouteBindings', 12, 'ServicePlans', cc_service_plan[:guid])
          end

          it 'has services link' do
            check_filter_link('RouteBindings', 20, 'Services', cc_service[:guid])
          end

          it 'has service brokers link' do
            check_filter_link('RouteBindings', 26, 'ServiceBrokers', cc_service_broker[:guid])
          end

          it 'has spaces link' do
            check_filter_link('RouteBindings', 30, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('RouteBindings', 32, 'Organizations', cc_organization[:guid])
          end
        end
      end

      context 'Tasks' do
        let(:tab_id)   { 'Tasks' }
        let(:table_id) { 'TasksTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='TasksTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 4,
                                 labels:          ['', '', 'Application', ''],
                                 colspans:        %w[1 7 3 1]
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='TasksTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 12,
                                 labels:          ['', 'Name', 'GUID', 'State', 'Created', 'Updated', 'Memory', 'Disk', 'Name', 'GUID', 'Task Sequence', 'Target'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='TasksTable']/tbody/tr/td"),
                           [
                             '',
                             cc_task[:name],
                             cc_task[:guid],
                             cc_task[:state],
                             cc_task[:created_at].to_datetime.rfc3339,
                             cc_task[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatNumber(#{cc_task[:memory_in_mb]})"),
                             @driver.execute_script("return Format.formatNumber(#{cc_task[:disk_in_mb]})"),
                             cc_app[:name],
                             cc_app[:guid],
                             @driver.execute_script("return Format.formatNumber(#{cc_task[:sequence_id]})"),
                             "#{cc_organization[:name]}/#{cc_space[:name]}"
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_TasksTable_1')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('TasksTable', cc_task[:guid])
        end

        context 'manage tasks' do
          def check_task_canceled
            begin
              Selenium::WebDriver::Wait.new(timeout: 10).until { refresh_button && @driver.find_element(xpath: "//table[@id='TasksTable']/tbody/tr/td[4]").text == 'FAILED' }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='TasksTable']/tbody/tr/td[4]").text).to eq('FAILED')
          end

          it 'has a Stop button' do
            expect(@driver.find_element(id: 'Buttons_TasksTable_0').text).to eq('Stop')
          end

          context 'Stop button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_TasksTable_0' }
            end
          end

          it 'stops the task' do
            check_first_row('TasksTable')
            @driver.find_element(id: 'Buttons_TasksTable_0').click

            confirm('Are you sure you want to stop the selected tasks?')

            check_operation_result
            check_task_canceled
          end

          context 'Standard buttons' do
            let(:filename) { 'tasks' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_TasksTable_1' }
              let(:print_button_id) { 'Buttons_TasksTable_2' }
              let(:save_button_id)  { 'Buttons_TasksTable_3' }
              let(:csv_button_id)   { 'Buttons_TasksTable_4' }
              let(:excel_button_id) { 'Buttons_TasksTable_5' }
              let(:pdf_button_id)   { 'Buttons_TasksTable_6' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_TasksTable_7' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Name',                      tag: 'div', value: cc_task[:name] },
                            { label: 'GUID',                      tag:   nil, value: cc_task[:guid] },
                            { label: 'State',                     tag:   nil, value: cc_task[:state] },
                            { label: 'Created',                   tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_task[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Updated',                   tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_task[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Memory',                    tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_task[:memory_in_mb]})") },
                            { label: 'Disk',                      tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_task[:disk_in_mb]})") },
                            { label: 'Command',                   tag:   nil, value: cc_task[:command] },
                            { label: 'Failure Reason',            tag:   nil, value: cc_task[:failure_reason] },
                            { label: 'Application',               tag:   'a', value: cc_app[:name] },
                            { label: 'Application GUID',          tag:   nil, value: cc_app[:guid] },
                            { label: 'Application Task Sequence', tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_task[:sequence_id]})") },
                            { label: 'Space',                     tag:   'a', value: cc_space[:name] },
                            { label: 'Space GUID',                tag:   nil, value: cc_space[:guid] },
                            { label: 'Organization',              tag:   'a', value: cc_organization[:name] },
                            { label: 'Organization GUID',         tag:   nil, value: cc_organization[:guid] }
                          ])
          end

          it 'has applications link' do
            check_filter_link('Tasks', 9, 'Applications', cc_task[:app_guid])
          end

          it 'has spaces link' do
            check_filter_link('Tasks', 12, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('Tasks', 14, 'Organizations', cc_organization[:guid])
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
                                 colspans:        %w[1 2 2 1]
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

        it 'has a checkbox in the first column' do
          check_checkbox_guid('OrganizationRolesTable', "#{cc_organization[:guid]}/auditors/#{uaa_user[:id]}")
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

          context 'Standard buttons' do
            let(:filename) { 'organization_roles' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_OrganizationRolesTable_1' }
              let(:print_button_id) { 'Buttons_OrganizationRolesTable_2' }
              let(:save_button_id)  { 'Buttons_OrganizationRolesTable_3' }
              let(:csv_button_id)   { 'Buttons_OrganizationRolesTable_4' }
              let(:excel_button_id) { 'Buttons_OrganizationRolesTable_5' }
              let(:pdf_button_id)   { 'Buttons_OrganizationRolesTable_6' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_OrganizationRolesTable_7' }
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
                                 colspans:        %w[1 3 2 1]
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

        it 'has a checkbox in the first column' do
          check_checkbox_guid('SpaceRolesTable', "#{cc_space[:guid]}/auditors/#{uaa_user[:id]}")
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

          context 'Standard buttons' do
            let(:filename) { 'space_roles' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_SpaceRolesTable_1' }
              let(:print_button_id) { 'Buttons_SpaceRolesTable_2' }
              let(:save_button_id)  { 'Buttons_SpaceRolesTable_3' }
              let(:csv_button_id)   { 'Buttons_SpaceRolesTable_4' }
              let(:excel_button_id) { 'Buttons_SpaceRolesTable_5' }
              let(:pdf_button_id)   { 'Buttons_SpaceRolesTable_6' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_SpaceRolesTable_7' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Space',             tag: 'div', value: cc_space[:name] },
                            { label: 'Space GUID',        tag:   nil, value: cc_space[:guid] },
                            { label: 'Organization',      tag:   'a', value: cc_organization[:name] },
                            { label: 'Organization GUID', tag:   nil, value: cc_organization[:guid] },
                            { label: 'User',              tag:   'a', value: uaa_user[:username] },
                            { label: 'User GUID',         tag:   nil, value: uaa_user[:id] },
                            { label: 'Role',              tag:   nil, value: 'Auditor' }
                          ])
          end

          it 'has spaces link' do
            check_filter_link('SpaceRoles', 0, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('SpaceRoles', 2, 'Organizations', cc_organization[:guid])
          end

          it 'has users link' do
            check_filter_link('SpaceRoles', 4, 'Users', uaa_user[:id])
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
                                 expected_length: 16,
                                 labels:          ['', 'Identity Zone', 'Identifier', 'Updated', 'Scopes', 'Authorized Grant Types', 'Redirect URIs', 'Authorities', 'Auto Approve', 'Required User Groups', 'Access Token Validity', 'Refresh Token Validity', 'Events', 'Approvals', 'Revocable Tokens', 'Service Broker'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='ClientsTable']/tbody/tr/td"),
                           [
                             '',
                             uaa_identity_zone[:name],
                             uaa_client[:client_id],
                             uaa_client[:lastmodified].to_datetime.rfc3339,
                             uaa_client[:scope],
                             uaa_client[:authorized_grant_types],
                             uaa_client[:web_server_redirect_uri],
                             uaa_client[:authorities],
                             uaa_client_autoapprove.to_s,
                             uaa_client[:required_user_groups],
                             @driver.execute_script("return Format.formatNumber(#{uaa_client[:access_token_validity]})"),
                             @driver.execute_script("return Format.formatNumber(#{uaa_client[:refresh_token_validity]})"),
                             '1',
                             '1',
                             '1',
                             cc_service_broker[:name]
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_ClientsTable_2')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('ClientsTable', uaa_client[:client_id])
        end

        context 'manage clients' do
          it 'has a Revoke Tokens button' do
            expect(@driver.find_element(id: 'Buttons_ClientsTable_0').text).to eq('Revoke Tokens')
          end

          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_ClientsTable_1').text).to eq('Delete')
          end

          context 'Revoke Tokens button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ClientsTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ClientsTable_1' }
            end
          end

          context 'Revoke Tokens button' do
            it_behaves_like('delete first row') do
              let(:button_id)               { 'Buttons_ClientsTable_0' }
              let(:check_no_data_available) { false }
              let(:confirm_message)         { "Are you sure you want to revoke the selected clients' tokens?" }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_ClientsTable_1' }
              let(:confirm_message) { 'Are you sure you want to delete the selected clients?' }
            end
          end

          context 'Standard buttons' do
            let(:filename) { 'clients' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_ClientsTable_2' }
              let(:print_button_id) { 'Buttons_ClientsTable_3' }
              let(:save_button_id)  { 'Buttons_ClientsTable_4' }
              let(:csv_button_id)   { 'Buttons_ClientsTable_5' }
              let(:excel_button_id) { 'Buttons_ClientsTable_6' }
              let(:pdf_button_id)   { 'Buttons_ClientsTable_7' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_ClientsTable_8' }
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
                            { label: 'Identity Zone ID',       tag:   nil, value: uaa_identity_zone[:id] },
                            { label: 'Identifier',             tag: 'div', value: uaa_client[:client_id] },
                            { label: 'Updated',                tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_client[:lastmodified].to_datetime.rfc3339}\")") },
                            { label: 'Scope',                  tag:   nil, value: uaa_client[:scope] },
                            { label: 'Authorized Grant Type',  tag:   nil, value: uaa_client[:authorized_grant_types] },
                            { label: 'Redirect URI',           tag:   nil, value: uaa_client[:web_server_redirect_uri] },
                            { label: 'Authority',              tag:   nil, value: uaa_client[:authorities] },
                            { label: 'Auto Approve',           tag:   nil, value: uaa_client_autoapprove.to_s },
                            { label: 'Required User Group',    tag:   nil, value: uaa_client[:required_user_groups] },
                            { label: 'Access Token Validity',  tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{uaa_client[:access_token_validity]})") },
                            { label: 'Refresh Token Validity', tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{uaa_client[:refresh_token_validity]})") },
                            { label: 'Show on Home Page',      tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{uaa_client[:show_on_home_page]})") },
                            { label: 'App Launch URL',         tag:   'a', value: uaa_client[:app_launch_url] },
                            { label: 'Events',                 tag:   'a', value: '1' },
                            { label: 'Approvals',              tag:   'a', value: '1' },
                            { label: 'Revocable Tokens',       tag:   'a', value: '1' },
                            { label: 'Additional Information', tag:   nil, value: uaa_client[:additional_information] },
                            { label: 'Service Broker',         tag:   'a', value: cc_service_broker[:name] },
                            { label: 'Service Broker GUID',    tag:   nil, value: cc_service_broker[:guid] }
                          ])
          end

          it 'has identity zones link' do
            check_filter_link('Clients', 0, 'IdentityZones', uaa_identity_zone[:id])
          end

          it 'has events link' do
            check_filter_link('Clients', 14, 'Events', uaa_client[:client_id])
          end

          it 'has approvals link' do
            check_filter_link('Clients', 15, 'Approvals', uaa_client[:client_id])
          end

          it 'has revocable tokens link' do
            check_filter_link('Clients', 16, 'RevocableTokens', uaa_client[:client_id])
          end

          it 'has service brokers link' do
            check_filter_link('Clients', 18, 'ServiceBrokers', cc_service_broker[:guid])
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
                                 expected_length: 6,
                                 labels:          ['', '', 'Requests', 'Organization Roles', 'Space Roles', ''],
                                 colspans:        %w[1 20 2 5 4 1]
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='UsersTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 33,
                                 labels:          ['', 'Identity Zone', 'Username', 'GUID', 'Created', 'Updated', 'Last Successful Logon', 'Previous Successful Logon', 'Password Updated', 'Password Change Required', 'Email', 'Family Name', 'Given Name', 'Phone Number', 'Active', 'Verified', 'Version', 'Events', 'Groups', 'Approvals', 'Revocable Tokens', 'Count', 'Valid Until', 'Total', 'Auditor', 'Billing Manager', 'Manager', 'User', 'Total', 'Auditor', 'Developer', 'Manager', 'Default Target'],
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
                             Time.at(uaa_user[:last_logon_success_time] / 1000.0).to_datetime.rfc3339,
                             Time.at(uaa_user[:previous_logon_success_time] / 1000.0).to_datetime.rfc3339,
                             uaa_user[:passwd_lastmodified].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{uaa_user[:passwd_change_required]})"),
                             uaa_user[:email],
                             uaa_user[:familyname],
                             uaa_user[:givenname],
                             uaa_user[:phonenumber],
                             @driver.execute_script("return Format.formatBoolean(#{uaa_user[:active]})"),
                             @driver.execute_script("return Format.formatBoolean(#{uaa_user[:verified]})"),
                             @driver.execute_script("return Format.formatNumber(#{uaa_user[:version]})"),
                             '1',
                             '1',
                             '1',
                             '1',
                             @driver.execute_script("return Format.formatNumber(#{cc_request_count[:count]})"),
                             cc_request_count[:valid_until].to_datetime.rfc3339,
                             '4',
                             '1',
                             '1',
                             '1',
                             '1',
                             '3',
                             '1',
                             '1',
                             '1',
                             "#{cc_organization[:name]}/#{cc_space[:name]}"
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_UsersTable_8')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('UsersTable', uaa_user[:id])
        end

        context 'manage users' do
          it 'has an Activate button' do
            expect(@driver.find_element(id: 'Buttons_UsersTable_0').text).to eq('Activate')
          end

          it 'has a Deactivate button' do
            expect(@driver.find_element(id: 'Buttons_UsersTable_1').text).to eq('Deactivate')
          end

          it 'has a Verify button' do
            expect(@driver.find_element(id: 'Buttons_UsersTable_2').text).to eq('Verify')
          end

          it 'has an Unverify button' do
            expect(@driver.find_element(id: 'Buttons_UsersTable_3').text).to eq('Unverify')
          end

          it 'has an Unlock button' do
            expect(@driver.find_element(id: 'Buttons_UsersTable_4').text).to eq('Unlock')
          end

          it 'has a Require Password Change button' do
            expect(@driver.find_element(id: 'Buttons_UsersTable_5').text).to eq('Require Password Change')
          end

          it 'has a Revoke Tokens button' do
            expect(@driver.find_element(id: 'Buttons_UsersTable_6').text).to eq('Revoke Tokens')
          end

          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_UsersTable_7').text).to eq('Delete')
          end

          context 'Activate button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_UsersTable_0' }
            end
          end

          context 'Deactivate button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_UsersTable_1' }
            end
          end

          context 'Verify button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_UsersTable_2' }
            end
          end

          context 'Unverify button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_UsersTable_3' }
            end
          end

          context 'Unlock button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_UsersTable_4' }
            end
          end

          context 'Require Password Change button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_UsersTable_5' }
            end
          end

          context 'Revoke Tokens button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_UsersTable_6' }
            end
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_UsersTable_7' }
            end
          end

          def manage_user(button_index)
            check_first_row('UsersTable')

            # TODO: Behavior of selenium-webdriver. Entire item must be displayed for it to click. Workaround following after commented out code
            # @driver.find_element(id: button_id).click
            @driver.execute_script('arguments[0].click();', @driver.find_element(id: 'Buttons_UsersTable_' + button_index.to_s))

            check_operation_result
          end

          def activate_user
            manage_user(0)
          end

          def deactivate_user
            manage_user(1)
          end

          def check_user_active(active)
            begin
              Selenium::WebDriver::Wait.new(timeout: 10).until { refresh_button && @driver.find_element(xpath: "//table[@id='UsersTable']/tbody/tr/td[15]").text == active }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='UsersTable']/tbody/tr/td[15]").text).to eq(active)
          end

          it 'Activates the selected user' do
            deactivate_user
            check_user_active('false')

            activate_user
            check_user_active('true')
          end

          it 'Deactivates the selected user' do
            deactivate_user
            check_user_active('false')
          end

          def verify_user
            manage_user(2)
          end

          def unverify_user
            manage_user(3)
          end

          def check_user_verified(verified)
            begin
              Selenium::WebDriver::Wait.new(timeout: 10).until { refresh_button && @driver.find_element(xpath: "//table[@id='UsersTable']/tbody/tr/td[16]").text == verified }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='UsersTable']/tbody/tr/td[16]").text).to eq(verified)
          end

          it 'Verifies the selected user' do
            unverify_user
            check_user_verified('false')

            verify_user
            check_user_verified('true')
          end

          it 'Unverifies the selected user' do
            unverify_user
            check_user_verified('false')
          end

          def unlock_user
            manage_user(4)
          end

          it 'Unlocks the selected user' do
            unlock_user
          end

          def require_password_change_user
            manage_user(5)
          end

          def check_require_password_change_user(require_password_change)
            begin
              Selenium::WebDriver::Wait.new(timeout: 10).until { refresh_button && @driver.find_element(xpath: "//table[@id='UsersTable']/tbody/tr/td[10]").text == require_password_change }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='UsersTable']/tbody/tr/td[10]").text).to eq(require_password_change)
          end

          it 'Requires password change of the selected user' do
            check_require_password_change_user('false')

            require_password_change_user
            check_require_password_change_user('true')
          end

          context 'Revoke Tokens button' do
            it_behaves_like('delete first row') do
              let(:button_id)               { 'Buttons_UsersTable_6' }
              let(:check_no_data_available) { false }
              let(:confirm_message)         { "Are you sure you want to revoke the selected users' tokens?" }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_UsersTable_7' }
              let(:confirm_message) { 'Are you sure you want to delete the selected users?' }
            end
          end

          context 'Standard buttons' do
            let(:filename) { 'users' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_UsersTable_8' }
              let(:print_button_id) { 'Buttons_UsersTable_9' }
              let(:save_button_id)  { 'Buttons_UsersTable_10' }
              let(:csv_button_id)   { 'Buttons_UsersTable_11' }
              let(:excel_button_id) { 'Buttons_UsersTable_12' }
              let(:pdf_button_id)   { 'Buttons_UsersTable_13' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_UsersTable_14' }
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
                            { label: 'Identity Zone ID',                   tag:   nil, value: uaa_identity_zone[:id] },
                            { label: 'Username',                           tag: 'div', value: uaa_user[:username] },
                            { label: 'GUID',                               tag:   nil, value: uaa_user[:id] },
                            { label: 'Created',                            tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_user[:created].to_datetime.rfc3339}\")") },
                            { label: 'Updated',                            tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_user[:lastmodified].to_datetime.rfc3339}\")") },
                            { label: 'Last Successful Logon',              tag:   nil, value: @driver.execute_script("return Format.formatDateNumber(#{uaa_user[:last_logon_success_time]})") },
                            { label: 'Previous Successful Logon',          tag:   nil, value: @driver.execute_script("return Format.formatDateNumber(#{uaa_user[:previous_logon_success_time]})") },
                            { label: 'Password Updated',                   tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_user[:passwd_lastmodified].to_datetime.rfc3339}\")") },
                            { label: 'Password Change Required',           tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{uaa_user[:passwd_change_required]})") },
                            { label: 'Email',                              tag:   'a', value: "mailto:#{uaa_user[:email]}" },
                            { label: 'Family Name',                        tag:   nil, value: uaa_user[:familyname] },
                            { label: 'Given Name',                         tag:   nil, value: uaa_user[:givenname] },
                            { label: 'Phone Number',                       tag:   nil, value: uaa_user[:phonenumber] },
                            { label: 'Active',                             tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{uaa_user[:active]})") },
                            { label: 'Verified',                           tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{uaa_user[:verified]})") },
                            { label: 'Version',                            tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{uaa_user[:version]})") },
                            { label: 'Events',                             tag:   'a', value: '1' },
                            { label: 'Groups',                             tag:   'a', value: '1' },
                            { label: 'Approvals',                          tag:   'a', value: '1' },
                            { label: 'Revocable Tokens',                   tag:   'a', value: '1' },
                            { label: 'Requests Count',                     tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_request_count[:count]})") },
                            { label: 'Requests Count Valid Until',         tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_request_count[:valid_until].to_datetime.rfc3339}\")") },
                            { label: 'Organization Total Roles',           tag:   'a', value: '4' },
                            { label: 'Organization Auditor Roles',         tag:   nil, value: '1' },
                            { label: 'Organization Billing Manager Roles', tag:   nil, value: '1' },
                            { label: 'Organization Manager Roles',         tag:   nil, value: '1' },
                            { label: 'Organization User Roles',            tag:   nil, value: '1' },
                            { label: 'Space Total Roles',                  tag:   'a', value: '3' },
                            { label: 'Space Auditor Roles',                tag:   nil, value: '1' },
                            { label: 'Space Developer Roles',              tag:   nil, value: '1' },
                            { label: 'Space Manager Roles',                tag:   nil, value: '1' },
                            { label: 'Space',                              tag:   'a', value: cc_space[:name] },
                            { label: 'Space GUID',                         tag:   nil, value: cc_space[:guid] },
                            { label: 'Organization',                       tag:   'a', value: cc_organization[:name] },
                            { label: 'Organization GUID',                  tag:   nil, value: cc_organization[:guid] }
                          ])
          end

          it 'has identity zones link' do
            check_filter_link('Users', 0, 'IdentityZones', uaa_identity_zone[:id])
          end

          it 'has events link' do
            check_filter_link('Users', 17, 'Events', uaa_user[:id])
          end

          it 'has group members link' do
            check_filter_link('Users', 18, 'GroupMembers', uaa_user[:id])
          end

          it 'has approvals link' do
            check_filter_link('Users', 19, 'Approvals', uaa_user[:id])
          end

          it 'has revocable tokens link' do
            check_filter_link('Users', 20, 'RevocableTokens', uaa_user[:id])
          end

          it 'has organization roles link' do
            check_filter_link('Users', 23, 'OrganizationRoles', uaa_user[:id])
          end

          it 'has space roles link' do
            check_filter_link('Users', 28, 'SpaceRoles', uaa_user[:id])
          end

          it 'has spaces link' do
            check_filter_link('Users', 32, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('Users', 34, 'Organizations', cc_organization[:guid])
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

          context 'Standard buttons' do
            let(:filename) { 'groups' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_GroupsTable_1' }
              let(:print_button_id) { 'Buttons_GroupsTable_2' }
              let(:save_button_id)  { 'Buttons_GroupsTable_3' }
              let(:csv_button_id)   { 'Buttons_GroupsTable_4' }
              let(:excel_button_id) { 'Buttons_GroupsTable_5' }
              let(:pdf_button_id)   { 'Buttons_GroupsTable_6' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_GroupsTable_7' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Identity Zone',    tag:   'a', value: uaa_identity_zone[:name] },
                            { label: 'Identity Zone ID', tag:   nil, value: uaa_identity_zone[:id] },
                            { label: 'Name',             tag: 'div', value: uaa_group[:displayname] },
                            { label: 'GUID',             tag:   nil, value: uaa_group[:id] },
                            { label: 'Created',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_group[:created].to_datetime.rfc3339}\")") },
                            { label: 'Updated',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_group[:lastmodified].to_datetime.rfc3339}\")") },
                            { label: 'Version',          tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{uaa_group[:version]})") },
                            { label: 'Description',      tag:   nil, value: uaa_group[:description] },
                            { label: 'Members',          tag:   'a', value: '1' }
                          ])
          end

          it 'has identity zones link' do
            check_filter_link('Groups', 0, 'IdentityZones', uaa_identity_zone[:id])
          end

          it 'has group members link' do
            check_filter_link('Groups', 8, 'GroupMembers', uaa_group[:id])
          end
        end
      end

      context 'Group Members' do
        let(:tab_id)   { 'GroupMembers' }
        let(:table_id) { 'GroupMembersTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='GroupMembersTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 5,
                                 labels:          ['', '', 'Group', 'User', ''],
                                 colspans:        %w[1 1 2 2 1]
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='GroupMembersTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 7,
                                 labels:          ['', 'Identity Zone', 'Name', 'GUID', 'Name', 'GUID', 'Created'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='GroupMembersTable']/tbody/tr/td"),
                           [
                             '',
                             uaa_identity_zone[:name],
                             uaa_group[:displayname],
                             uaa_group[:id],
                             uaa_user[:username],
                             uaa_user[:id],
                             uaa_group_membership[:added].to_datetime.rfc3339
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_GroupMembersTable_1')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('GroupMembersTable', "#{uaa_group[:id]}/#{uaa_user[:id]}")
        end

        context 'manage group members' do
          it 'has a Remove button' do
            expect(@driver.find_element(id: 'Buttons_GroupMembersTable_0').text).to eq('Remove')
          end

          context 'Remove button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_GroupMembersTable_0' }
            end
          end

          context 'Remove button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_GroupMembersTable_0' }
              let(:confirm_message) { 'Are you sure you want to remove the selected group members?' }
            end
          end

          context 'Standard buttons' do
            let(:filename) { 'group_members' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_GroupMembersTable_1' }
              let(:print_button_id) { 'Buttons_GroupMembersTable_2' }
              let(:save_button_id)  { 'Buttons_GroupMembersTable_3' }
              let(:csv_button_id)   { 'Buttons_GroupMembersTable_4' }
              let(:excel_button_id) { 'Buttons_GroupMembersTable_5' }
              let(:pdf_button_id)   { 'Buttons_GroupMembersTable_6' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_GroupMembersTable_7' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Identity Zone',    tag:   'a', value: uaa_identity_zone[:name] },
                            { label: 'Identity Zone ID', tag:   nil, value: uaa_identity_zone[:id] },
                            { label: 'Group',            tag: 'div', value: uaa_group[:displayname] },
                            # rubocop:disable Layout/ExtraSpacing
                            { label: 'Group GUID',       tag:   nil, value: uaa_group[:id] },
                            { label: 'User',             tag:    'a', value: uaa_user[:username] },
                            # rubocop:enable Layout/ExtraSpacing
                            { label: 'User GUID',        tag:   nil, value: uaa_user[:id] },
                            { label: 'Created',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_group_membership[:added].to_datetime.rfc3339}\")") }
                          ])
          end

          it 'has identity zones link' do
            check_filter_link('GroupMembers', 0, 'IdentityZones', uaa_identity_zone[:id])
          end

          it 'has groups link' do
            check_filter_link('GroupMembers', 2, 'Groups', uaa_group[:id])
          end

          it 'has users link' do
            check_filter_link('GroupMembers', 4, 'Users', uaa_user[:id])
          end
        end
      end

      context 'Approvals' do
        let(:tab_id)   { 'Approvals' }
        let(:table_id) { 'ApprovalsTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ApprovalsTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 3,
                                 labels:          ['', 'User', ''],
                                 colspans:        %w[1 2 5]
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ApprovalsTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 8,
                                 labels:          ['Identity Zone', 'Name', 'GUID', 'Client', 'Scope', 'Status', 'Updated', 'Expires'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='ApprovalsTable']/tbody/tr/td"),
                           [
                             uaa_identity_zone[:name],
                             uaa_user[:username],
                             uaa_approval[:user_id],
                             uaa_approval[:client_id],
                             uaa_approval[:scope],
                             uaa_approval[:status],
                             uaa_approval[:lastmodifiedat].to_datetime.rfc3339,
                             uaa_approval[:expiresat].to_datetime.rfc3339
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_ApprovalsTable_0')
        end

        context 'manage approvals' do
          context 'Standard buttons' do
            let(:filename) { 'approvals' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_ApprovalsTable_0' }
              let(:print_button_id) { 'Buttons_ApprovalsTable_1' }
              let(:save_button_id)  { 'Buttons_ApprovalsTable_2' }
              let(:csv_button_id)   { 'Buttons_ApprovalsTable_3' }
              let(:excel_button_id) { 'Buttons_ApprovalsTable_4' }
              let(:pdf_button_id)   { 'Buttons_ApprovalsTable_5' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_ApprovalsTable_6' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Identity Zone',    tag:   'a', value: uaa_identity_zone[:name] },
                            { label: 'Identity Zone ID', tag:   nil, value: uaa_identity_zone[:id] },
                            { label: 'User',             tag: 'div', value: uaa_user[:username] },
                            { label: 'User GUID',        tag:   nil, value: uaa_approval[:user_id] },
                            { label: 'Client',           tag:   'a', value: uaa_approval[:client_id] },
                            { label: 'Scope',            tag:   nil, value: uaa_approval[:scope] },
                            { label: 'Status',           tag:   nil, value: uaa_approval[:status] },
                            { label: 'Updated',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_approval[:lastmodifiedat].to_datetime.rfc3339}\")") },
                            { label: 'Expires',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_approval[:expiresat].to_datetime.rfc3339}\")") }
                          ])
          end

          it 'has identity zones link' do
            check_filter_link('Approvals', 0, 'IdentityZones', uaa_identity_zone[:id])
          end

          it 'has users link' do
            check_filter_link('Approvals', 2, 'Users', uaa_approval[:user_id])
          end

          it 'has clients link' do
            check_filter_link('Approvals', 4, 'Clients', uaa_approval[:client_id])
          end
        end
      end

      context 'Revocable Tokens' do
        let(:tab_id)     { 'RevocableTokens' }
        let(:table_id)   { 'RevocableTokensTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='RevocableTokensTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 4,
                                 labels:          ['', '', '', 'User'],
                                 colspans:        %w[1 1 7 2]
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='RevocableTokensTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 11,
                                 labels:          ['', 'Identity Zone', 'GUID', 'Issued', 'Expires', 'Format', 'Response Type', 'Scopes', 'Client', 'Name', 'GUID'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='RevocableTokensTable']/tbody/tr/td"),
                           [
                             '',
                             uaa_identity_zone[:name],
                             uaa_revocable_token[:token_id],
                             Time.at(uaa_revocable_token[:issued_at] / 1000.0).to_datetime.rfc3339,
                             Time.at(uaa_revocable_token[:expires_at] / 1000.0).to_datetime.rfc3339,
                             uaa_revocable_token[:format],
                             uaa_revocable_token[:response_type],
                             uaa_revocable_token[:scope][1...-1],
                             uaa_revocable_token[:client_id],
                             uaa_user[:username],
                             uaa_revocable_token[:user_id]
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_RevocableTokensTable_1')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('RevocableTokensTable', uaa_revocable_token[:token_id])
        end

        context 'manage clients' do
          it 'has a Revoke button' do
            expect(@driver.find_element(id: 'Buttons_RevocableTokensTable_0').text).to eq('Revoke')
          end

          context 'Revoke button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_RevocableTokensTable_0' }
            end
          end

          context 'Revoke button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_RevocableTokensTable_0' }
              let(:confirm_message) { 'Are you sure you want to revoke the selected tokens?' }
            end
          end

          context 'Standard buttons' do
            let(:filename) { 'revocable_tokens' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_RevocableTokensTable_1' }
              let(:print_button_id) { 'Buttons_RevocableTokensTable_2' }
              let(:save_button_id)  { 'Buttons_RevocableTokensTable_3' }
              let(:csv_button_id)   { 'Buttons_RevocableTokensTable_4' }
              let(:excel_button_id) { 'Buttons_RevocableTokensTable_5' }
              let(:pdf_button_id)   { 'Buttons_RevocableTokensTable_6' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_RevocableTokensTable_7' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Identity Zone',    tag:   'a', value: uaa_identity_zone[:name] },
                            { label: 'Identity Zone ID', tag:   nil, value: uaa_revocable_token[:identity_zone_id] },
                            { label: 'GUID',             tag: 'div', value: uaa_revocable_token[:token_id] },
                            { label: 'Issued',           tag:   nil, value: @driver.execute_script("return Format.formatDateNumber(#{uaa_revocable_token[:issued_at]})") },
                            { label: 'Expires',          tag:   nil, value: @driver.execute_script("return Format.formatDateNumber(#{uaa_revocable_token[:expires_at]})") },
                            { label: 'Format',           tag:   nil, value: uaa_revocable_token[:format] },
                            { label: 'Response Type',    tag:   nil, value: uaa_revocable_token[:response_type] },
                            { label: 'Scope',            tag:   nil, value: uaa_revocable_token[:scope][1...-1] },
                            { label: 'Client',           tag:   'a', value: uaa_revocable_token[:client_id] },
                            { label: 'User',             tag:   'a', value: uaa_user[:username] },
                            { label: 'User GUID',        tag:   nil, value: uaa_revocable_token[:user_id] }
                          ])
          end

          it 'has identity zones link' do
            check_filter_link('RevocableTokens', 0, 'IdentityZones', uaa_identity_zone[:id])
          end

          it 'has clients link' do
            check_filter_link('RevocableTokens', 8, 'Clients', uaa_revocable_token[:client_id])
          end

          it 'has users link' do
            check_filter_link('RevocableTokens', 9, 'Users', uaa_revocable_token[:user_id])
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
                                 expected_length: 9,
                                 labels:          ['', 'Name', 'GUID', 'Created', 'Updated', 'Position', 'Enabled', 'Locked', 'Applications'],
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
                             @driver.execute_script("return Format.formatBoolean(#{cc_buildpack[:locked]})"),
                             '1'
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

            # TODO: Behavior of selenium-webdriver. Entire item must be displayed for it to click. Workaround following after commented out code
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

          context 'Standard buttons' do
            let(:filename) { 'buildpacks' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_BuildpacksTable_6' }
              let(:print_button_id) { 'Buttons_BuildpacksTable_7' }
              let(:save_button_id)  { 'Buttons_BuildpacksTable_8' }
              let(:csv_button_id)   { 'Buttons_BuildpacksTable_9' }
              let(:excel_button_id) { 'Buttons_BuildpacksTable_10' }
              let(:pdf_button_id)   { 'Buttons_BuildpacksTable_11' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_BuildpacksTable_12' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Name',         tag: 'div', value: cc_buildpack[:name] },
                            { label: 'GUID',         tag:   nil, value: cc_buildpack[:guid] },
                            { label: 'Created',      tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_buildpack[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Updated',      tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_buildpack[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Position',     tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_buildpack[:position]})") },
                            { label: 'Enabled',      tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_buildpack[:enabled]})") },
                            { label: 'Locked',       tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_buildpack[:locked]})") },
                            { label: 'Key',          tag:   nil, value: cc_buildpack[:key] },
                            { label: 'Filename',     tag:   nil, value: cc_buildpack[:filename] },
                            { label: 'Applications', tag:   'a', value: '1' }
                          ])
          end

          it 'has applications link' do
            check_filter_link('Buildpacks', 9, 'Applications', cc_buildpack[:guid])
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
                                 expected_length: 10,
                                 labels:          ['', 'Name', 'GUID', 'Created', 'Updated', 'Internal', 'Shared', 'Owning Organization', 'Private Shared Organizations', 'Routes'],
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
                             @driver.execute_script("return Format.formatBoolean(#{cc_domain[:internal]})"),
                             @driver.execute_script('return Format.formatBoolean(false)'),
                             cc_organization[:name],
                             '1',
                             '1'
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_DomainsTable_2')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('DomainsTable', "#{cc_domain[:guid]}/false")
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
              let(:confirm_message) { 'Are you sure you want to delete the selected domains and their associated routes, route mappings and route bindings?' }
            end
          end

          context 'Standard buttons' do
            let(:filename) { 'domains' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_DomainsTable_2' }
              let(:print_button_id) { 'Buttons_DomainsTable_3' }
              let(:save_button_id)  { 'Buttons_DomainsTable_4' }
              let(:csv_button_id)   { 'Buttons_DomainsTable_5' }
              let(:excel_button_id) { 'Buttons_DomainsTable_6' }
              let(:pdf_button_id)   { 'Buttons_DomainsTable_7' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_DomainsTable_8' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Name',                     tag: 'div', value: cc_domain[:name] },
                            { label: 'GUID',                     tag:   nil, value: cc_domain[:guid] },
                            { label: 'Created',                  tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_domain[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Updated',                  tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_domain[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Internal',                 tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_domain[:internal]})") },
                            { label: 'Shared',                   tag:   nil, value: @driver.execute_script('return Format.formatBoolean(false)') },
                            { label: 'Owning Organization',      tag:   'a', value: cc_organization[:name] },
                            { label: 'Owning Organization GUID', tag:   nil, value: cc_organization[:guid] },
                            { label: 'Routes',                   tag:   'a', value: '1' }
                          ])
          end

          context 'private shared organizations' do
            it 'has a table' do
              expect(@driver.find_element(id: 'DomainsOrganizationsDetailsLabel').displayed?).to be(true)

              check_table_headers(columns:         @driver.find_elements(xpath: "//div[@id='DomainsOrganizationsTableContainer']/div[2]/div[4]/div/div/table/thead/tr/th"),
                                  expected_length: 3,
                                  labels:          ['', 'Organization', 'GUID'],
                                  colspans:        nil)

              check_table_data(@driver.find_elements(xpath: "//table[@id='DomainsOrganizationsTable']/tbody/tr/td"),
                               [
                                 '',
                                 cc_organization[:name],
                                 cc_organization[:guid]
                               ])
            end

            it 'has allowscriptaccess property set to sameDomain' do
              check_allowscriptaccess_attribute('Buttons_DomainsOrganizationsTable_1')
            end

            it 'has a checkbox in the first column' do
              check_checkbox_guid('DomainsOrganizationsTable', "#{cc_domain[:guid]}/false/#{cc_organization[:guid]}")
            end

            context 'manage private shared organizations' do
              it 'has an Unshare button' do
                expect(@driver.find_element(id: 'Buttons_DomainsOrganizationsTable_0').text).to eq('Unshare')
              end

              context 'Unshare button' do
                it_behaves_like('click button without selecting any rows') do
                  let(:button_id) { 'Buttons_DomainsOrganizationsTable_0' }
                end
              end

              context 'Unshare button' do
                it_behaves_like('delete first row') do
                  let(:table_id)                { 'DomainsOrganizationsTable' }
                  let(:button_id)               { 'Buttons_DomainsOrganizationsTable_0' }
                  let(:check_no_data_available) { false }
                  let(:confirm_message)         { 'Are you sure you want to unshare the domain from the selected organizations?' }
                end
              end

              context 'Standard buttons' do
                let(:filename) { 'domain_organizations' }

                it_behaves_like('standard buttons') do
                  let(:copy_button_id)  { 'Buttons_DomainsOrganizationsTable_1' }
                  let(:print_button_id) { 'Buttons_DomainsOrganizationsTable_2' }
                  let(:save_button_id)  { 'Buttons_DomainsOrganizationsTable_3' }
                  let(:csv_button_id)   { 'Buttons_DomainsOrganizationsTable_4' }
                  let(:excel_button_id) { 'Buttons_DomainsOrganizationsTable_5' }
                  let(:pdf_button_id)   { 'Buttons_DomainsOrganizationsTable_6' }
                end
              end
            end
          end

          it 'has organizations link' do
            check_filter_link('Domains', 6, 'Organizations', cc_organization[:guid])
          end

          it 'has routes link' do
            check_filter_link('Domains', 8, 'Routes', cc_domain[:name])
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

            # TODO: Behavior of selenium-webdriver. Entire item must be displayed for it to click. Workaround following after commented out code
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

          context 'Standard buttons' do
            let(:filename) { 'feature_flags' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_FeatureFlagsTable_2' }
              let(:print_button_id) { 'Buttons_FeatureFlagsTable_3' }
              let(:save_button_id)  { 'Buttons_FeatureFlagsTable_4' }
              let(:csv_button_id)   { 'Buttons_FeatureFlagsTable_5' }
              let(:excel_button_id) { 'Buttons_FeatureFlagsTable_6' }
              let(:pdf_button_id)   { 'Buttons_FeatureFlagsTable_7' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_FeatureFlagsTable_8' }
            end
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

          context 'Standard buttons' do
            let(:filename) { 'quotas' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_QuotasTable_2' }
              let(:print_button_id) { 'Buttons_QuotasTable_3' }
              let(:save_button_id)  { 'Buttons_QuotasTable_4' }
              let(:csv_button_id)   { 'Buttons_QuotasTable_5' }
              let(:excel_button_id) { 'Buttons_QuotasTable_6' }
              let(:pdf_button_id)   { 'Buttons_QuotasTable_7' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_QuotasTable_8' }
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
                                 colspans:        %w[1 14 2]
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

          context 'Standard buttons' do
            let(:filename) { 'space_quotas' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_SpaceQuotasTable_2' }
              let(:print_button_id) { 'Buttons_SpaceQuotasTable_3' }
              let(:save_button_id)  { 'Buttons_SpaceQuotasTable_4' }
              let(:csv_button_id)   { 'Buttons_SpaceQuotasTable_5' }
              let(:excel_button_id) { 'Buttons_SpaceQuotasTable_6' }
              let(:pdf_button_id)   { 'Buttons_SpaceQuotasTable_7' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_SpaceQuotasTable_8' }
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
                            { label: 'Organization',               tag:   'a', value: cc_organization[:name] },
                            { label: 'Organization GUID',          tag:   nil, value: cc_organization[:guid] }
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
        let(:tab_id)   { 'Stacks' }
        let(:table_id) { 'StacksTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='StacksTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 8,
                                 labels:          ['', 'Name', 'GUID', 'Created', 'Updated', 'Applications', 'Application Instances', 'Description'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='StacksTable']/tbody/tr/td"),
                           [
                             '',
                             cc_stack[:name],
                             cc_stack[:guid],
                             cc_stack[:created_at].to_datetime.rfc3339,
                             cc_stack[:updated_at].to_datetime.rfc3339,
                             '1',
                             @driver.execute_script("return Format.formatNumber(#{cc_process[:instances]})"),
                             cc_stack[:description]
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_StacksTable_1')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('StacksTable', cc_stack[:guid])
        end

        context 'manage stacks' do
          it 'has a delete button' do
            expect(@driver.find_element(id: 'Buttons_StacksTable_0').text).to eq('Delete')
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_StacksTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_StacksTable_0' }
              let(:confirm_message) { 'Are you sure you want to delete the selected stacks?' }
            end
          end

          context 'Standard buttons' do
            let(:filename) { 'stacks' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_StacksTable_1' }
              let(:print_button_id) { 'Buttons_StacksTable_2' }
              let(:save_button_id)  { 'Buttons_StacksTable_3' }
              let(:csv_button_id)   { 'Buttons_StacksTable_4' }
              let(:excel_button_id) { 'Buttons_StacksTable_5' }
              let(:pdf_button_id)   { 'Buttons_StacksTable_6' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_StacksTable_7' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Name',                  tag: 'div', value: cc_stack[:name] },
                            { label: 'GUID',                  tag:   nil, value: cc_stack[:guid] },
                            { label: 'Created',               tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_stack[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Updated',               tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_stack[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Description',           tag:   nil, value: cc_stack[:description] },
                            { label: 'Applications',          tag:   'a', value: '1' },
                            { label: 'Application Instances', tag:   'a', value: @driver.execute_script("return Format.formatNumber(#{cc_process[:instances]})") }
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
                                 colspans:        %w[3 3 4 1]
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='EventsTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 11,
                                 labels:          %w[Timestamp GUID Type Type Name GUID Type Username Name GUID Target],
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
                             cc_event_space[:actor_username],
                             cc_event_space[:actor_name],
                             cc_event_space[:actor],
                             "#{cc_organization[:name]}/#{cc_space[:name]}"
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_EventsTable_0')
        end

        context 'manage events' do
          context 'Standard buttons' do
            let(:filename) { 'events' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_EventsTable_0' }
              let(:print_button_id) { 'Buttons_EventsTable_1' }
              let(:save_button_id)  { 'Buttons_EventsTable_2' }
              let(:csv_button_id)   { 'Buttons_EventsTable_3' }
              let(:excel_button_id) { 'Buttons_EventsTable_4' }
              let(:pdf_button_id)   { 'Buttons_EventsTable_5' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_EventsTable_6' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Event Timestamp',   tag: 'div', value: @driver.execute_script("return Format.formatDateString(\"#{cc_event_space[:timestamp].to_datetime.rfc3339}\")") },
                            { label: 'Event GUID',        tag:   nil, value: cc_event_space[:guid] },
                            { label: 'Event Type',        tag:   nil, value: cc_event_space[:type] },
                            { label: 'Actee Type',        tag:   nil, value: cc_event_space[:actee_type] },
                            { label: 'Actee',             tag:   nil, value: cc_event_space[:actee_name] },
                            { label: 'Actee GUID',        tag:   'a', value: cc_event_space[:actee] },
                            { label: 'Actor Type',        tag:   nil, value: cc_event_space[:actor_type] },
                            { label: 'Actor Username',    tag:   nil, value: cc_event_space[:actor_username] },
                            { label: 'Actor',             tag:   nil, value: cc_event_space[:actor_name] },
                            { label: 'Actor GUID',        tag:   'a', value: cc_event_space[:actor] },
                            { label: 'Space',             tag:   'a', value: cc_space[:name] },
                            { label: 'Space GUID',        tag:   nil, value: cc_space[:guid] },
                            { label: 'Organization',      tag:   'a', value: cc_organization[:name] },
                            { label: 'Organization GUID', tag:   nil, value: cc_organization[:guid] }
                          ])
          end

          it 'has spaces actee link' do
            check_filter_link('Events', 5, 'Spaces', cc_event_space[:actee])
          end

          it 'has users actor link' do
            check_filter_link('Events', 9, 'Users', cc_event_space[:actor])
          end

          it 'has spaces link' do
            check_filter_link('Events', 10, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('Events', 12, 'Organizations', cc_organization[:guid])
          end

          context 'app event' do
            let(:event_type) { 'app' }

            it 'has applications actee link' do
              check_filter_link('Events', 5, 'Applications', cc_event_app[:actee])
            end

            it 'has users actor link' do
              check_filter_link('Events', 9, 'Users', cc_event_app[:actor])
            end

            it 'has spaces link' do
              check_filter_link('Events', 10, 'Spaces', cc_space[:guid])
            end

            it 'has organizations link' do
              check_filter_link('Events', 12, 'Organizations', cc_organization[:guid])
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

          context 'organization event' do
            let(:event_type) { 'organization' }

            it 'has organizations actee link' do
              check_filter_link('Events', 5, 'Organizations', cc_event_organization[:actee])
            end

            it 'has users actor link' do
              check_filter_link('Events', 9, 'Users', cc_event_organization[:actor])
            end

            it 'has organizations link' do
              check_filter_link('Events', 10, 'Organizations', cc_organization[:guid])
            end
          end

          context 'route event' do
            let(:event_type) { 'route' }

            it 'has route link' do
              check_filter_link('Events', 5, 'Routes', cc_event_route[:actee])
            end

            it 'has users actor link' do
              check_filter_link('Events', 9, 'Users', cc_event_route[:actor])
            end

            it 'has spaces link' do
              check_filter_link('Events', 10, 'Spaces', cc_space[:guid])
            end

            it 'has organizations link' do
              check_filter_link('Events', 12, 'Organizations', cc_organization[:guid])
            end
          end

          context 'service instance event' do
            let(:event_type) { 'service_instance' }

            it 'has service instances actee link' do
              check_filter_link('Events', 5, 'ServiceInstances', cc_event_service_instance[:actee])
            end

            it 'has users actor link' do
              check_filter_link('Events', 9, 'Users', cc_event_service_instance[:actor])
            end

            it 'has spaces link' do
              check_filter_link('Events', 10, 'Spaces', cc_space[:guid])
            end

            it 'has organizations link' do
              check_filter_link('Events', 12, 'Organizations', cc_organization[:guid])
            end
          end

          context 'service binding event' do
            let(:event_type) { 'service_binding' }

            it 'has service bindings actee link' do
              check_filter_link('Events', 4, 'ServiceBindings', cc_event_service_binding[:actee])
            end

            it 'has users actor link' do
              check_filter_link('Events', 8, 'Users', cc_event_service_binding[:actor])
            end

            it 'has spaces link' do
              check_filter_link('Events', 9, 'Spaces', cc_space[:guid])
            end

            it 'has organizations link' do
              check_filter_link('Events', 11, 'Organizations', cc_organization[:guid])
            end
          end

          context 'service broker event' do
            let(:event_type) { 'service_broker' }

            it 'has service brokers actee link' do
              check_filter_link('Events', 5, 'ServiceBrokers', cc_event_service_broker[:actee])
            end

            it 'has users actor link' do
              check_filter_link('Events', 9, 'Users', cc_event_service_broker[:actor])
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
              check_filter_link('Events', 9, 'Users', cc_event_service_key[:actor])
            end

            it 'has spaces link' do
              check_filter_link('Events', 10, 'Spaces', cc_space[:guid])
            end

            it 'has organizations link' do
              check_filter_link('Events', 12, 'Organizations', cc_organization[:guid])
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
              check_filter_link('Events', 8, 'Users', cc_event_service_plan_visibility[:actor])
            end

            it 'has organizations link' do
              check_filter_link('Events', 9, 'Organizations', cc_organization[:guid])
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
                                 expected_length: 17,
                                 labels:          ['', 'Name', 'GUID', 'Created', 'Updated', 'Events', 'Service Dashboard Client', 'Services', 'Service Plans', 'Public Active Service Plans', 'Service Plan Visibilities', 'Service Instances', 'Service Instance Shares', 'Service Bindings', 'Service Keys', 'Route Bindings', 'Target'],
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

          context 'Standard buttons' do
            let(:filename) { 'service_brokers' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_ServiceBrokersTable_2' }
              let(:print_button_id) { 'Buttons_ServiceBrokersTable_3' }
              let(:save_button_id)  { 'Buttons_ServiceBrokersTable_4' }
              let(:csv_button_id)   { 'Buttons_ServiceBrokersTable_5' }
              let(:excel_button_id) { 'Buttons_ServiceBrokersTable_6' }
              let(:pdf_button_id)   { 'Buttons_ServiceBrokersTable_7' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_ServiceBrokersTable_8' }
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
                            { label: 'Service Instance Shares',      tag:   'a', value: '1' },
                            { label: 'Service Bindings',             tag:   'a', value: '1' },
                            { label: 'Service Keys',                 tag:   'a', value: '1' },
                            { label: 'Route Bindings',               tag:   'a', value: '1' },
                            { label: 'Space',                        tag:   'a', value: cc_space[:name] },
                            { label: 'Space GUID',                   tag:   nil, value: cc_space[:guid] },
                            { label: 'Organization',                 tag:   'a', value: cc_organization[:name] },
                            { label: 'Organization GUID',            tag:   nil, value: cc_organization[:guid] }
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

          it 'has shared service instances link' do
            check_filter_link('ServiceBrokers', 13, 'SharedServiceInstances', cc_service_broker[:guid])
          end

          it 'has service bindings link' do
            check_filter_link('ServiceBrokers', 14, 'ServiceBindings', cc_service_broker[:guid])
          end

          it 'has service keys link' do
            check_filter_link('ServiceBrokers', 15, 'ServiceKeys', cc_service_broker[:guid])
          end

          it 'has route bindings link' do
            check_filter_link('ServiceBrokers', 16, 'RouteBindings', cc_service_broker[:guid])
          end

          it 'has spaces link' do
            check_filter_link('ServiceBrokers', 17, 'Spaces', cc_space[:guid])
          end

          it 'has organizations link' do
            check_filter_link('ServiceBrokers', 19, 'Organizations', cc_organization[:guid])
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
                                 colspans:        %w[1 21 4]
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ServicesTable_wrapper']/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 26,
                                 labels:          ['', 'Label', 'GUID', 'Unique ID', 'Created', 'Updated', 'Bindable', 'Plan Updateable', 'Shareable', 'Active', 'Provider Display Name', 'Display Name', 'Requires', 'Events', 'Service Plans', 'Public Active Service Plans', 'Service Plan Visibilities', 'Service Instances', 'Service Instance Shares', 'Service Bindings', 'Service Keys', 'Route Bindings', 'Name', 'GUID', 'Created', 'Updated'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='ServicesTable']/tbody/tr/td"),
                           [
                             '',
                             cc_service[:label],
                             cc_service[:guid],
                             cc_service[:unique_id],
                             cc_service[:created_at].to_datetime.rfc3339,
                             cc_service[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{cc_service[:bindable]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service[:plan_updateable]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_shareable})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})"),
                             cc_service_provider_display_name,
                             cc_service_display_name,
                             Yajl::Parser.parse(cc_service[:requires]).sort.join("\n"),
                             '1',
                             '1',
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

          context 'Standard buttons' do
            let(:filename) { 'services' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_ServicesTable_2' }
              let(:print_button_id) { 'Buttons_ServicesTable_3' }
              let(:save_button_id)  { 'Buttons_ServicesTable_4' }
              let(:csv_button_id)   { 'Buttons_ServicesTable_5' }
              let(:excel_button_id) { 'Buttons_ServicesTable_6' }
              let(:pdf_button_id)   { 'Buttons_ServicesTable_7' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_ServicesTable_8' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            service_requires_json = Yajl::Parser.parse(cc_service[:requires]).sort
            service_tags_json = Yajl::Parser.parse(cc_service[:tags])
            service_extra_json = Yajl::Parser.parse(cc_service[:extra])
            check_details([
                            { label: 'Service Label',                 tag: 'div', value: cc_service[:label] },
                            { label: 'Service GUID',                  tag:   nil, value: cc_service[:guid] },
                            { label: 'Service Unique ID',             tag:   nil, value: cc_service[:unique_id] },
                            { label: 'Service Created',               tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Updated',               tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Bindable',              tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:bindable]})") },
                            { label: 'Service Plan Updateable',       tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:plan_updateable]})") },
                            { label: 'Service Shareable',             tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_shareable})") },
                            { label: 'Service Active',                tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})") },
                            { label: 'Service Description',           tag:   nil, value: cc_service[:description] },
                            { label: 'Service Requires',              tag:   nil, value: service_requires_json[0] },
                            { label: 'Service Requires',              tag:   nil, value: service_requires_json[1] },
                            { label: 'Service Requires',              tag:   nil, value: service_requires_json[2] },
                            { label: 'Service Tag',                   tag:   nil, value: service_tags_json[0] },
                            { label: 'Service Tag',                   tag:   nil, value: service_tags_json[1] },
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
                            { label: 'Service Instance Shares',       tag:   'a', value: '1' },
                            { label: 'Service Bindings',              tag:   'a', value: '1' },
                            { label: 'Service Keys',                  tag:   'a', value: '1' },
                            { label: 'Route Bindings',                tag:   'a', value: '1' },
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

          it 'has shared service instances link' do
            check_filter_link('Services', 26, 'SharedServiceInstances', cc_service[:guid])
          end

          it 'has service bindings link' do
            check_filter_link('Services', 27, 'ServiceBindings', cc_service[:guid])
          end

          it 'has service keys link' do
            check_filter_link('Services', 28, 'ServiceKeys', cc_service[:guid])
          end

          it 'has route bindings link' do
            check_filter_link('Services', 29, 'RouteBindings', cc_service[:guid])
          end

          it 'has service brokers link' do
            check_filter_link('Services', 30, 'ServiceBrokers', cc_service_broker[:guid])
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
                                 colspans:        %w[1 17 7 4]
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ServicePlansTable_wrapper']/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 29,
                                 labels:          ['', 'Name', 'GUID', 'Unique ID', 'Created', 'Updated', 'Bindable', 'Free', 'Active', 'Public', 'Display Name', 'Events', 'Visible Organizations', 'Service Instances', 'Service Instance Shares', 'Service Bindings', 'Service Keys', 'Route Bindings', 'Label', 'GUID', 'Unique ID', 'Created', 'Updated', 'Bindable', 'Active', 'Name', 'GUID', 'Created', 'Updated'],
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
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:bindable]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})"),
                             cc_service_plan_display_name,
                             '1',
                             '1',
                             '1',
                             '1',
                             '1',
                             '1',
                             '1',
                             cc_service[:label],
                             cc_service[:guid],
                             cc_service[:unique_id],
                             cc_service[:created_at].to_datetime.rfc3339,
                             cc_service[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{cc_service[:bindable]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})"),
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
            expect(@driver.find_element(xpath: "//table[@id='ServicePlansTable']/tbody/tr/td[10]").text).to eq(expect_state)
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

          context 'Standard buttons' do
            let(:filename) { 'service_plans' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_ServicePlansTable_3' }
              let(:print_button_id) { 'Buttons_ServicePlansTable_4' }
              let(:save_button_id)  { 'Buttons_ServicePlansTable_5' }
              let(:csv_button_id)   { 'Buttons_ServicePlansTable_6' }
              let(:excel_button_id) { 'Buttons_ServicePlansTable_7' }
              let(:pdf_button_id)   { 'Buttons_ServicePlansTable_8' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_ServicePlansTable_9' }
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
                            { label: 'Service Plan Name',                   tag: 'div', value: cc_service_plan[:name] },
                            { label: 'Service Plan GUID',                   tag:   nil, value: cc_service_plan[:guid] },
                            { label: 'Service Plan Unique ID',              tag:   nil, value: cc_service_plan[:unique_id] },
                            { label: 'Service Plan Created',                tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_plan[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Updated',                tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_plan[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Plan Bindable',               tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:bindable]})") },
                            { label: 'Service Plan Free',                   tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})") },
                            { label: 'Service Plan Active',                 tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})") },
                            { label: 'Service Plan Public',                 tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})") },
                            { label: 'Service Plan Description',            tag:   nil, value: cc_service_plan[:description] },
                            { label: 'Service Plan Display Name',           tag:   nil, value: service_plan_extra_json['displayName'] },
                            { label: 'Service Plan Bullet',                 tag:   nil, value: service_plan_extra_json['bullets'][0] },
                            { label: 'Service Plan Bullet',                 tag:   nil, value: service_plan_extra_json['bullets'][1] },
                            { label: 'Service Plan Create Instance Schema', tag: 'div', value: cc_service_plan[:create_instance_schema] },
                            { label: 'Service Plan Update Instance Schema', tag: 'div', value: cc_service_plan[:update_instance_schema] },
                            { label: 'Service Plan Create Binding Schema',  tag: 'div', value: cc_service_plan[:create_binding_schema] },
                            { label: 'Service Plan Events',                 tag:   'a', value: '1' },
                            { label: 'Service Plan Visibilities',           tag:   'a', value: '1' },
                            { label: 'Service Instances',                   tag:   'a', value: '1' },
                            { label: 'Service Instance Shares',             tag:   'a', value: '1' },
                            { label: 'Service Bindings',                    tag:   'a', value: '1' },
                            { label: 'Service Keys',                        tag:   'a', value: '1' },
                            { label: 'Route Bindings',                      tag:   'a', value: '1' },
                            { label: 'Service Label',                       tag:   'a', value: cc_service[:label] },
                            { label: 'Service GUID',                        tag:   nil, value: cc_service[:guid] },
                            { label: 'Service Unique ID',                   tag:   nil, value: cc_service[:unique_id] },
                            { label: 'Service Created',                     tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Updated',                     tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Bindable',                    tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:bindable]})") },
                            { label: 'Service Active',                      tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})") },
                            { label: 'Service Broker Name',                 tag:   'a', value: cc_service_broker[:name] },
                            { label: 'Service Broker GUID',                 tag:   nil, value: cc_service_broker[:guid] },
                            { label: 'Service Broker Created',              tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Broker Updated',              tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service_broker[:updated_at].to_datetime.rfc3339}\")") }
                          ])
          end

          it 'has events link' do
            check_filter_link('ServicePlans', 16, 'Events', cc_service_plan[:guid])
          end

          it 'has service plan visibilities link' do
            check_filter_link('ServicePlans', 17, 'ServicePlanVisibilities', cc_service_plan[:guid])
          end

          it 'has service instances link' do
            check_filter_link('ServicePlans', 18, 'ServiceInstances', cc_service_plan[:guid])
          end

          it 'has shared service instances link' do
            check_filter_link('ServicePlans', 19, 'SharedServiceInstances', cc_service_plan[:guid])
          end

          it 'has service bindings link' do
            check_filter_link('ServicePlans', 20, 'ServiceBindings', cc_service_plan[:guid])
          end

          it 'has service keys link' do
            check_filter_link('ServicePlans', 21, 'ServiceKeys', cc_service_plan[:guid])
          end

          it 'has route bindings link' do
            check_filter_link('ServicePlans', 22, 'RouteBindings', cc_service_plan[:guid])
          end

          it 'has services link' do
            check_filter_link('ServicePlans', 23, 'Services', cc_service[:guid])
          end

          it 'has service brokers link' do
            check_filter_link('ServicePlans', 30, 'ServiceBrokers', cc_service_broker[:guid])
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
                                 colspans:        %w[1 4 9 7 4 4]
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ServicePlanVisibilitiesTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 29,
                                 labels:          ['', 'GUID', 'Created', 'Updated', 'Events', 'Name', 'GUID', 'Unique ID', 'Created', 'Updated', 'Bindable', 'Free', 'Active', 'Public', 'Label', 'GUID', 'Unique ID', 'Created', 'Updated', 'Bindable', 'Active', 'Name', 'GUID', 'Created', 'Updated', 'Name', 'GUID', 'Created', 'Updated'],
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
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:bindable]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})"),
                             cc_service[:label],
                             cc_service[:guid],
                             cc_service[:unique_id],
                             cc_service[:created_at].to_datetime.rfc3339,
                             cc_service[:updated_at].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{cc_service[:bindable]})"),
                             @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})"),
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

          context 'Standard buttons' do
            let(:filename) { 'service_plan_visibilities' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_ServicePlanVisibilitiesTable_1' }
              let(:print_button_id) { 'Buttons_ServicePlanVisibilitiesTable_2' }
              let(:save_button_id)  { 'Buttons_ServicePlanVisibilitiesTable_3' }
              let(:csv_button_id)   { 'Buttons_ServicePlanVisibilitiesTable_4' }
              let(:excel_button_id) { 'Buttons_ServicePlanVisibilitiesTable_5' }
              let(:pdf_button_id)   { 'Buttons_ServicePlanVisibilitiesTable_6' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_ServicePlanVisibilitiesTable_7' }
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
                            { label: 'Service Plan Bindable',           tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:bindable]})") },
                            { label: 'Service Plan Free',               tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:free]})") },
                            { label: 'Service Plan Active',             tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:active]})") },
                            { label: 'Service Plan Public',             tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service_plan[:public]})") },
                            { label: 'Service Label',                   tag:   'a', value: cc_service[:label] },
                            { label: 'Service GUID',                    tag:   nil, value: cc_service[:guid] },
                            { label: 'Service Unique ID',               tag:   nil, value: cc_service[:unique_id] },
                            { label: 'Service Created',                 tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Updated',                 tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_service[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Service Bindable',                tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:bindable]})") },
                            { label: 'Service Active',                  tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{cc_service[:active]})") },
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
            check_filter_link('ServicePlanVisibilities', 20, 'ServiceBrokers', cc_service_broker[:guid])
          end

          it 'has organizations link' do
            check_filter_link('ServicePlanVisibilities', 24, 'Organizations', cc_organization[:guid])
          end
        end
      end

      context 'Identity Zones' do
        let(:tab_id)   { 'IdentityZones' }
        let(:table_id) { 'IdentityZonesTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='IdentityZonesTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 16,
                                 labels:          ['', 'Name', 'ID', 'Created', 'Updated', 'Subdomain', 'Version', 'Identity Providers', 'SAML Providers', 'MFA Providers', 'Clients', 'Users', 'Groups', 'Group Members', 'Approvals', 'Description'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='IdentityZonesTable']/tbody/tr/td"),
                           [
                             '',
                             uaa_identity_zone[:name],
                             uaa_identity_zone[:id],
                             uaa_identity_zone[:created].to_datetime.rfc3339,
                             uaa_identity_zone[:lastmodified].to_datetime.rfc3339,
                             uaa_identity_zone[:subdomain],
                             @driver.execute_script("return Format.formatNumber(#{uaa_identity_zone[:version]})"),
                             '1',
                             '1',
                             '1',
                             '1',
                             '1',
                             '1',
                             '1',
                             '1',
                             uaa_identity_zone[:description]
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_IdentityZonesTable_1')
        end

        context 'manage identity zones' do
          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_IdentityZonesTable_0').text).to eq('Delete')
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_IdentityZonesTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_IdentityZonesTable_0' }
              let(:confirm_message) { 'Are you sure you want to delete the selected identity zones?' }
            end
          end

          context 'Standard buttons' do
            let(:filename) { 'identity_zones' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_IdentityZonesTable_1' }
              let(:print_button_id) { 'Buttons_IdentityZonesTable_2' }
              let(:save_button_id)  { 'Buttons_IdentityZonesTable_3' }
              let(:csv_button_id)   { 'Buttons_IdentityZonesTable_4' }
              let(:excel_button_id) { 'Buttons_IdentityZonesTable_5' }
              let(:pdf_button_id)   { 'Buttons_IdentityZonesTable_6' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_IdentityZonesTable_7' }
            end
          end
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
                            { label: 'SAML Providers',     tag:   'a', value: '1' },
                            { label: 'MFA Providers',      tag:   'a', value: '1' },
                            { label: 'Clients',            tag:   'a', value: '1' },
                            { label: 'Users',              tag:   'a', value: '1' },
                            { label: 'Groups',             tag:   'a', value: '1' },
                            { label: 'Group Members',      tag:   'a', value: '1' },
                            { label: 'Approvals',          tag:   'a', value: '1' }
                          ])
          end

          it 'has identity providers link' do
            check_filter_link('IdentityZones', 7, 'IdentityProviders', uaa_identity_zone[:id])
          end

          it 'has service providers link' do
            check_filter_link('IdentityZones', 8, 'ServiceProviders', uaa_identity_zone[:id])
          end

          it 'has MFA providers link' do
            check_filter_link('IdentityZones', 9, 'MFAProviders', uaa_identity_zone[:id])
          end

          it 'has clients link' do
            check_filter_link('IdentityZones', 10, 'Clients', uaa_identity_zone[:id])
          end

          it 'has users link' do
            check_filter_link('IdentityZones', 11, 'Users', uaa_identity_zone[:id])
          end

          it 'has groups link' do
            check_filter_link('IdentityZones', 12, 'Groups', uaa_identity_zone[:id])
          end

          it 'has group members link' do
            check_filter_link('IdentityZones', 13, 'GroupMembers', uaa_identity_zone[:id])
          end

          it 'has approvals link' do
            check_filter_link('IdentityZones', 14, 'Approvals', uaa_identity_zone[:id])
          end
        end
      end

      context 'Identity Providers' do
        let(:tab_id)   { 'IdentityProviders' }
        let(:table_id) { 'IdentityProvidersTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='IdentityProvidersTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 10,
                                 labels:          ['', 'Identity Zone', 'Name', 'GUID', 'Created', 'Updated', 'Origin Key', 'Type', 'Active', 'Version'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='IdentityProvidersTable']/tbody/tr/td"),
                           [
                             '',
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
          check_allowscriptaccess_attribute('Buttons_IdentityProvidersTable_2')
        end

        context 'manage identity providers' do
          it 'has a Require Password Change for Users button' do
            expect(@driver.find_element(id: 'Buttons_IdentityProvidersTable_0').text).to eq('Require Password Change for Users')
          end

          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_IdentityProvidersTable_1').text).to eq('Delete')
          end

          context 'Require Password Change for Users button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_IdentityProvidersTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_IdentityProvidersTable_1' }
            end
          end

          def manage_identity_provider(button_index)
            check_first_row('IdentityProvidersTable')

            # TODO: Behavior of selenium-webdriver. Entire item must be displayed for it to click. Workaround following after commented out code
            # @driver.find_element(id: button_id).click
            @driver.execute_script('arguments[0].click();', @driver.find_element(id: 'Buttons_IdentityProvidersTable_' + button_index.to_s))

            check_operation_result
          end

          def require_password_change_identity_provider
            manage_identity_provider(0)
          end

          it 'Requires password change of the selected identity provider' do
            require_password_change_identity_provider
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_IdentityProvidersTable_1' }
              let(:confirm_message) { 'Are you sure you want to delete the selected identity providers?' }
            end
          end

          context 'Standard buttons' do
            let(:filename) { 'identity_providers' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_IdentityProvidersTable_2' }
              let(:print_button_id) { 'Buttons_IdentityProvidersTable_3' }
              let(:save_button_id)  { 'Buttons_IdentityProvidersTable_4' }
              let(:csv_button_id)   { 'Buttons_IdentityProvidersTable_5' }
              let(:excel_button_id) { 'Buttons_IdentityProvidersTable_6' }
              let(:pdf_button_id)   { 'Buttons_IdentityProvidersTable_7' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_IdentityProvidersTable_8' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Identity Zone',    tag:   'a', value: uaa_identity_zone[:name] },
                            { label: 'Identity Zone ID', tag:   nil, value: uaa_identity_zone[:id] },
                            { label: 'Name',             tag: 'div', value: uaa_identity_provider[:name] },
                            { label: 'GUID',             tag:   nil, value: uaa_identity_provider[:id] },
                            { label: 'Created',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_identity_provider[:created].to_datetime.rfc3339}\")") },
                            { label: 'Updated',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_identity_provider[:lastmodified].to_datetime.rfc3339}\")") },
                            { label: 'Origin Key',       tag:   nil, value: uaa_identity_provider[:origin_key] },
                            { label: 'Type',             tag:   nil, value: uaa_identity_provider[:type] },
                            { label: 'Active',           tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{uaa_identity_provider[:active]})") },
                            { label: 'Version',          tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{uaa_identity_provider[:version]})") }
                          ])
          end

          it 'has identity zones link' do
            check_filter_link('IdentityProviders', 0, 'IdentityZones', uaa_identity_zone[:id])
          end
        end
      end

      context 'ServiceProviders' do
        let(:tab_id)   { 'ServiceProviders' }
        let(:table_id) { 'ServiceProvidersTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='ServiceProvidersTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 9,
                                 labels:          ['', 'Identity Zone', 'Name', 'GUID', 'Entity ID', 'Created', 'Updated', 'Active', 'Version'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='ServiceProvidersTable']/tbody/tr/td"),
                           [
                             '',
                             uaa_identity_zone[:name],
                             uaa_service_provider[:name],
                             uaa_service_provider[:id],
                             uaa_service_provider[:entity_id],
                             uaa_service_provider[:created].to_datetime.rfc3339,
                             uaa_service_provider[:lastmodified].to_datetime.rfc3339,
                             @driver.execute_script("return Format.formatBoolean(#{uaa_service_provider[:active]})"),
                             @driver.execute_script("return Format.formatNumber(#{uaa_service_provider[:version]})")
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_ServiceProvidersTable_1')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('ServiceProvidersTable', uaa_service_provider[:id])
        end

        context 'manage service providers' do
          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_ServiceProvidersTable_0').text).to eq('Delete')
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_ServiceProvidersTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_ServiceProvidersTable_0' }
              let(:confirm_message) { 'Are you sure you want to delete the selected SAML providers?' }
            end
          end

          context 'Standard buttons' do
            let(:filename) { 'service_providers' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_ServiceProvidersTable_1' }
              let(:print_button_id) { 'Buttons_ServiceProvidersTable_2' }
              let(:save_button_id)  { 'Buttons_ServiceProvidersTable_3' }
              let(:csv_button_id)   { 'Buttons_ServiceProvidersTable_4' }
              let(:excel_button_id) { 'Buttons_ServiceProvidersTable_5' }
              let(:pdf_button_id)   { 'Buttons_ServiceProvidersTable_6' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_ServiceProvidersTable_7' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Identity Zone',    tag:   'a', value: uaa_identity_zone[:name] },
                            { label: 'Identity Zone ID', tag:   nil, value: uaa_identity_zone[:id] },
                            { label: 'Name',             tag: 'div', value: uaa_service_provider[:name] },
                            { label: 'GUID',             tag:   nil, value: uaa_service_provider[:id] },
                            { label: 'Entity ID',        tag:   nil, value: uaa_service_provider[:entity_id] },
                            { label: 'Created',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_service_provider[:created].to_datetime.rfc3339}\")") },
                            { label: 'Updated',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_service_provider[:lastmodified].to_datetime.rfc3339}\")") },
                            { label: 'Active',           tag:   nil, value: @driver.execute_script("return Format.formatBoolean(#{uaa_service_provider[:active]})") },
                            { label: 'Version',          tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{uaa_service_provider[:version]})") }
                          ])
          end

          it 'has identity zones link' do
            check_filter_link('ServiceProviders', 0, 'IdentityZones', uaa_identity_zone[:id])
          end
        end
      end

      context 'MFA Providers' do
        let(:tab_id)   { 'MFAProviders' }
        let(:table_id) { 'MFAProvidersTable' }

        it 'has a table' do
          config = Yajl::Parser.parse(uaa_mfa_provider[:config])
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='MFAProvidersTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 11,
                                 labels:          ['', 'Identity Zone', 'Type', 'Name', 'GUID', 'Created', 'Updated', 'Issuer', 'Algorithm', 'Digits', 'Duration'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='MFAProvidersTable']/tbody/tr/td"),
                           [
                             '',
                             uaa_identity_zone[:name],
                             uaa_mfa_provider[:type],
                             uaa_mfa_provider[:name],
                             uaa_mfa_provider[:id],
                             uaa_mfa_provider[:created].to_datetime.rfc3339,
                             uaa_mfa_provider[:lastmodified].to_datetime.rfc3339,
                             config['issuer'],
                             config['algorithm'],
                             @driver.execute_script("return Format.formatNumber(#{config['digits']})"),
                             @driver.execute_script("return Format.formatNumber(#{config['duration']})")
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_MFAProvidersTable_1')
        end

        context 'manage MFA providers' do
          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_MFAProvidersTable_0').text).to eq('Delete')
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_MFAProvidersTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_MFAProvidersTable_0' }
              let(:confirm_message) { 'Are you sure you want to delete the selected MFA providers?' }
            end
          end

          context 'Standard buttons' do
            let(:filename) { 'mfa_providers' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_MFAProvidersTable_1' }
              let(:print_button_id) { 'Buttons_MFAProvidersTable_2' }
              let(:save_button_id)  { 'Buttons_MFAProvidersTable_3' }
              let(:csv_button_id)   { 'Buttons_MFAProvidersTable_4' }
              let(:excel_button_id) { 'Buttons_MFAProvidersTable_5' }
              let(:pdf_button_id)   { 'Buttons_MFAProvidersTable_6' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_MFAProvidersTable_7' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            config = Yajl::Parser.parse(uaa_mfa_provider[:config])
            check_details([
                            { label: 'Identity Zone',    tag:   'a', value: uaa_identity_zone[:name] },
                            { label: 'Identity Zone ID', tag:   nil, value: uaa_identity_zone[:id] },
                            { label: 'Type',             tag:   nil, value: uaa_mfa_provider[:type] },
                            { label: 'Name',             tag: 'div', value: uaa_mfa_provider[:name] },
                            { label: 'GUID',             tag:   nil, value: uaa_mfa_provider[:id] },
                            { label: 'Created',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_mfa_provider[:created].to_datetime.rfc3339}\")") },
                            { label: 'Updated',          tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{uaa_mfa_provider[:lastmodified].to_datetime.rfc3339}\")") },
                            { label: 'Issuer',           tag:   nil, value: config['issuer'] },
                            { label: 'Algorithm',        tag:   nil, value: config['algorithm'] },
                            { label: 'Digits',           tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{config['digits']})") },
                            { label: 'Duration',         tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{config['duration']})") },
                            { label: 'Description',      tag:   nil, value: config['providerDescription'] }
                          ])
          end

          it 'has identity zones link' do
            check_filter_link('MFAProviders', 0, 'IdentityZones', uaa_identity_zone[:id])
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
                                 expected_length: 9,
                                 labels:          ['', 'Name', 'GUID', 'Created', 'Updated', 'Staging Default', 'Running Default', 'Spaces', 'Staging Spaces'],
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
                             '1',
                             '1'
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_SecurityGroupsTable_6')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('SecurityGroupsTable', cc_security_group[:guid])
        end

        context 'manage security groups' do
          def manage_security_group(button_index)
            check_first_row('SecurityGroupsTable')

            # TODO: Behavior of selenium-webdriver. Entire item must be displayed for it to click. Workaround following after commented out code
            # @driver.find_element(id: 'Buttons_SecurityGroupsTable_' + button_index.to_s).click
            @driver.execute_script('arguments[0].click();', @driver.find_element(id: 'Buttons_SecurityGroupsTable_' + button_index.to_s))

            check_operation_result
          end

          def check_running_default(running)
            begin
              Selenium::WebDriver::Wait.new(timeout: 20).until { refresh_button && @driver.find_element(xpath: "//table[@id='SecurityGroupsTable']/tbody/tr/td[7]").text == running }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='SecurityGroupsTable']/tbody/tr/td[7]").text).to eq(running)
          end

          def check_staging_default(staging)
            begin
              Selenium::WebDriver::Wait.new(timeout: 20).until { refresh_button && @driver.find_element(xpath: "//table[@id='SecurityGroupsTable']/tbody/tr/td[6]").text == staging }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='SecurityGroupsTable']/tbody/tr/td[6]").text).to eq(staging)
          end

          it 'has a Rename button' do
            expect(@driver.find_element(id: 'Buttons_SecurityGroupsTable_0').text).to eq('Rename')
          end

          it 'has an Enable Staging button' do
            expect(@driver.find_element(id: 'Buttons_SecurityGroupsTable_1').text).to eq('Enable Staging')
          end

          it 'has a Disable Staging button' do
            expect(@driver.find_element(id: 'Buttons_SecurityGroupsTable_2').text).to eq('Disable Staging')
          end

          it 'has an Enable Running button' do
            expect(@driver.find_element(id: 'Buttons_SecurityGroupsTable_3').text).to eq('Enable Running')
          end

          it 'has a Disable Running button' do
            expect(@driver.find_element(id: 'Buttons_SecurityGroupsTable_4').text).to eq('Disable Running')
          end

          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_SecurityGroupsTable_5').text).to eq('Delete')
          end

          context 'Rename button' do
            it_behaves_like('click button without selecting exactly one row') do
              let(:button_id) { 'Buttons_SecurityGroupsTable_0' }
            end
          end

          context 'Enable Staging button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_SecurityGroupsTable_5' }
            end
          end

          context 'Disable Staging button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_SecurityGroupsTable_5' }
            end
          end

          context 'Enable Running button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_SecurityGroupsTable_5' }
            end
          end

          context 'Disable Running button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_SecurityGroupsTable_5' }
            end
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_SecurityGroupsTable_5' }
            end
          end

          context 'Rename button' do
            it_behaves_like('rename first row') do
              let(:button_id)     { 'Buttons_SecurityGroupsTable_0' }
              let(:title_text)    { 'Rename Security Group' }
              let(:object_rename) { cc_security_group_rename }
            end
          end

          it 'enables the selected security group staging default' do
            # let security group with staging default disabled
            manage_security_group(2)
            check_staging_default('false')

            # enable the security group staging default
            manage_security_group(1)
            check_staging_default('true')
          end

          it 'disables the selected security group staging default' do
            # let security group with staging default enabled
            manage_security_group(1)
            check_staging_default('true')

            # disable the security group staging default
            manage_security_group(2)
            check_staging_default('false')
          end

          it 'enables the selected security group running default' do
            # let security group with running default disabled
            manage_security_group(4)
            check_running_default('false')

            # enable the security group running default
            manage_security_group(3)
            check_running_default('true')
          end

          it 'disables the selected security group running default' do
            # let security group with running default enabled
            manage_security_group(3)
            check_running_default('true')

            # disable the security group running default
            manage_security_group(4)
            check_running_default('false')
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_SecurityGroupsTable_5' }
              let(:confirm_message) { 'Are you sure you want to delete the selected security groups?' }
            end
          end

          context 'Standard buttons' do
            let(:filename) { 'security_groups' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_SecurityGroupsTable_6' }
              let(:print_button_id) { 'Buttons_SecurityGroupsTable_7' }
              let(:save_button_id)  { 'Buttons_SecurityGroupsTable_8' }
              let(:csv_button_id)   { 'Buttons_SecurityGroupsTable_9' }
              let(:excel_button_id) { 'Buttons_SecurityGroupsTable_10' }
              let(:pdf_button_id)   { 'Buttons_SecurityGroupsTable_11' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_SecurityGroupsTable_12' }
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
                            { label: 'Spaces',          tag:   'a', value: '1' },
                            { label: 'Staging Spaces',  tag:   'a', value: '1' }
                          ])
          end

          it 'has rules' do
            expect(@driver.find_element(id: 'SecurityGroupsRulesDetailsLabel').displayed?).to be(true)

            check_table_headers(columns:         @driver.find_elements(xpath: "//div[@id='SecurityGroupsRulesTableContainer']/div[2]/div[4]/div/div/table/thead/tr/th"),
                                expected_length: 6,
                                labels:          %w[Protocol Destination Log Ports Type Code],
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

          context 'manage rules subtable' do
            context 'Standard buttons' do
              let(:filename) { 'security_group_rules' }

              it_behaves_like('standard buttons') do
                let(:copy_button_id)  { 'Buttons_SecurityGroupsRulesTable_0' }
                let(:print_button_id) { 'Buttons_SecurityGroupsRulesTable_1' }
                let(:save_button_id)  { 'Buttons_SecurityGroupsRulesTable_2' }
                let(:csv_button_id)   { 'Buttons_SecurityGroupsRulesTable_3' }
                let(:excel_button_id) { 'Buttons_SecurityGroupsRulesTable_4' }
                let(:pdf_button_id)   { 'Buttons_SecurityGroupsRulesTable_5' }
              end
            end
          end

          it 'has security groups spaces link' do
            check_filter_link('SecurityGroups', 6, 'SecurityGroupsSpaces', cc_security_group[:guid])
          end

          it 'has staging security groups spaces link' do
            check_filter_link('SecurityGroups', 7, 'StagingSecurityGroupsSpaces', cc_security_group[:guid])
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
                                 colspans:        %w[1 4 4 1]
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

          context 'Standard buttons' do
            let(:filename) { 'security_groups_spaces' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_SecurityGroupsSpacesTable_1' }
              let(:print_button_id) { 'Buttons_SecurityGroupsSpacesTable_2' }
              let(:save_button_id)  { 'Buttons_SecurityGroupsSpacesTable_3' }
              let(:csv_button_id)   { 'Buttons_SecurityGroupsSpacesTable_4' }
              let(:excel_button_id) { 'Buttons_SecurityGroupsSpacesTable_5' }
              let(:pdf_button_id)   { 'Buttons_SecurityGroupsSpacesTable_6' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_SecurityGroupsSpacesTable_7' }
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
                            { label: 'Organization',           tag:   'a', value: cc_organization[:name] },
                            { label: 'Organization GUID',      tag:   nil, value: cc_organization[:guid] }
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

      context 'Staging Security Groups Spaces' do
        let(:tab_id)   { 'StagingSecurityGroupsSpaces' }
        let(:table_id) { 'StagingSecurityGroupsSpacesTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='StagingSecurityGroupsSpacesTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 4,
                                 labels:          ['', 'Security Group', 'Space', ''],
                                 colspans:        %w[1 4 4 1]
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='StagingSecurityGroupsSpacesTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 10,
                                 labels:          ['', 'Name', 'GUID', 'Created', 'Updated', 'Name', 'GUID', 'Created', 'Updated', 'Target'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='StagingSecurityGroupsSpacesTable']/tbody/tr/td"),
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
          check_allowscriptaccess_attribute('Buttons_StagingSecurityGroupsSpacesTable_1')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('StagingSecurityGroupsSpacesTable', "#{cc_security_group[:guid]}/#{cc_space[:guid]}")
        end

        context 'manage staging security group spaces' do
          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_StagingSecurityGroupsSpacesTable_0').text).to eq('Delete')
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_StagingSecurityGroupsSpacesTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_StagingSecurityGroupsSpacesTable_0' }
              let(:confirm_message) { 'Are you sure you want to delete the selected staging security groups spaces?' }
            end
          end

          context 'Standard buttons' do
            let(:filename) { 'staging_security_groups_spaces' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_StagingSecurityGroupsSpacesTable_1' }
              let(:print_button_id) { 'Buttons_StagingSecurityGroupsSpacesTable_2' }
              let(:save_button_id)  { 'Buttons_StagingSecurityGroupsSpacesTable_3' }
              let(:csv_button_id)   { 'Buttons_StagingSecurityGroupsSpacesTable_4' }
              let(:excel_button_id) { 'Buttons_StagingSecurityGroupsSpacesTable_5' }
              let(:pdf_button_id)   { 'Buttons_StagingSecurityGroupsSpacesTable_6' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_StagingSecurityGroupsSpacesTable_7' }
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
                            { label: 'Organization',           tag:   'a', value: cc_organization[:name] },
                            { label: 'Organization GUID',      tag:   nil, value: cc_organization[:guid] }
                          ])
          end

          it 'has security groups link' do
            check_filter_link('StagingSecurityGroupsSpaces', 0, 'SecurityGroups', cc_security_group[:guid])
          end

          it 'has spaces link' do
            check_filter_link('StagingSecurityGroupsSpaces', 4, 'Spaces', cc_space[:guid])
          end

          it 'has organization link' do
            check_filter_link('StagingSecurityGroupsSpaces', 8, 'Organizations', cc_organization[:guid])
          end
        end
      end

      context 'Isolation Segments' do
        let(:tab_id)   { 'IsolationSegments' }
        let(:table_id) { 'IsolationSegmentsTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='IsolationSegmentsTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 8,
                                 labels:          ['', 'Name', 'GUID', 'Created', 'Updated', 'Related Organizations', 'Default Organizations', 'Spaces'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='IsolationSegmentsTable']/tbody/tr/td"),
                           [
                             '',
                             cc_isolation_segment[:name],
                             cc_isolation_segment[:guid],
                             cc_isolation_segment[:created_at].to_datetime.rfc3339,
                             cc_isolation_segment[:updated_at].to_datetime.rfc3339,
                             '1',
                             '1',
                             '1'
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_IsolationSegmentsTable_3')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('IsolationSegmentsTable', cc_isolation_segment[:guid])
        end

        context 'manage isolation segments' do
          it 'has a Create button' do
            expect(@driver.find_element(id: 'Buttons_IsolationSegmentsTable_0').text).to eq('Create')
          end

          it 'has a Rename button' do
            expect(@driver.find_element(id: 'Buttons_IsolationSegmentsTable_1').text).to eq('Rename')
          end

          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_IsolationSegmentsTable_2').text).to eq('Delete')
          end

          it 'creates an isolation segment' do
            @driver.find_element(id: 'Buttons_IsolationSegmentsTable_0').click

            # Check whether the dialog is displayed
            expect(@driver.find_element(id: 'ModalDialogContents').displayed?).to be(true)
            expect(@driver.find_element(id: 'ModalDialogTitle').text).to eq('Create Isolation Segment')
            expect(@driver.find_element(id: 'isolationSegmentName').displayed?).to be(true)

            # Click the create button without input an isolation segment name
            @driver.find_element(id: 'modalDialogButton0').click
            alert = @driver.switch_to.alert
            expect(alert.text).to eq('Please input the name first!')
            alert.dismiss

            # Input the name of the isolation segment and click 'Create'
            @driver.find_element(id: 'isolationSegmentName').send_keys(cc_isolation_segment2[:name])
            @driver.find_element(id: 'modalDialogButton0').click

            check_operation_result

            begin
              Selenium::WebDriver::Wait.new(timeout: 5).until { refresh_button && @driver.find_element(xpath: "//table[@id='IsolationSegmentsTable']/tbody/tr[1]/td[2]").text == cc_isolation_segment2[:name] }
            rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
            end
            expect(@driver.find_element(xpath: "//table[@id='IsolationSegmentsTable']/tbody/tr[1]/td[2]").text).to eq(cc_isolation_segment2[:name])
          end

          context 'Rename button' do
            it_behaves_like('click button without selecting exactly one row') do
              let(:button_id) { 'Buttons_IsolationSegmentsTable_1' }
            end
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_IsolationSegmentsTable_2' }
            end
          end

          context 'Rename button' do
            it_behaves_like('rename first row') do
              let(:button_id)     { 'Buttons_IsolationSegmentsTable_1' }
              let(:title_text)    { 'Rename Isolation Segment' }
              let(:object_rename) { cc_isolation_segment_rename }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_IsolationSegmentsTable_2' }
              let(:confirm_message) { 'Are you sure you want to delete the selected isolation segments?' }
            end
          end

          context 'Standard buttons' do
            let(:filename) { 'isolation_segments' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_IsolationSegmentsTable_3' }
              let(:print_button_id) { 'Buttons_IsolationSegmentsTable_4' }
              let(:save_button_id)  { 'Buttons_IsolationSegmentsTable_5' }
              let(:csv_button_id)   { 'Buttons_IsolationSegmentsTable_6' }
              let(:excel_button_id) { 'Buttons_IsolationSegmentsTable_7' }
              let(:pdf_button_id)   { 'Buttons_IsolationSegmentsTable_8' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_IsolationSegmentsTable_9' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Name',                  tag: 'div', value: cc_isolation_segment[:name] },
                            { label: 'GUID',                  tag:   nil, value: cc_isolation_segment[:guid] },
                            { label: 'Created',               tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_isolation_segment[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Updated',               tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_isolation_segment[:updated_at].to_datetime.rfc3339}\")") },
                            { label: 'Related Organizations', tag:   'a', value: '1' },
                            { label: 'Default Organizations', tag:   nil, value: '1' },
                            { label: 'Spaces',                tag:   'a', value: '1' }
                          ])
          end

          it 'has organizations isolation segments link' do
            check_filter_link('IsolationSegments', 4, 'OrganizationsIsolationSegments', cc_isolation_segment[:guid])
          end

          it 'has organizations link' do
            check_filter_link('IsolationSegments', 5, 'Organizations', cc_isolation_segment[:guid])
          end

          it 'has spaces link' do
            check_filter_link('IsolationSegments', 6, 'Spaces', cc_isolation_segment[:guid])
          end
        end
      end

      context 'OrganizationsIsolationSegments' do
        let(:tab_id)     { 'OrganizationsIsolationSegments' }
        let(:table_id)   { 'OrganizationsIsolationSegmentsTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='OrganizationsIsolationSegmentsTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 3,
                                 labels:          ['', 'Organization', 'Isolation Segment'],
                                 colspans:        %w[1 2 2]
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='OrganizationsIsolationSegmentsTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 5,
                                 labels:          ['', 'Name', 'GUID', 'Name', 'GUID'],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='OrganizationsIsolationSegmentsTable']/tbody/tr/td"),
                           [
                             '',
                             cc_organization[:name],
                             cc_organization[:guid],
                             cc_isolation_segment[:name],
                             cc_isolation_segment[:guid]
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_OrganizationsIsolationSegmentsTable_1')
        end

        it 'has a checkbox in the first column' do
          check_checkbox_guid('OrganizationsIsolationSegmentsTable', "#{cc_organization[:guid]}/#{cc_isolation_segment[:guid]}")
        end

        context 'manage organization isolation segments' do
          it 'has a Delete button' do
            expect(@driver.find_element(id: 'Buttons_OrganizationsIsolationSegmentsTable_0').text).to eq('Delete')
          end

          context 'Delete button' do
            it_behaves_like('click button without selecting any rows') do
              let(:button_id) { 'Buttons_OrganizationsIsolationSegmentsTable_0' }
            end
          end

          context 'Delete button' do
            it_behaves_like('delete first row') do
              let(:button_id)       { 'Buttons_OrganizationsIsolationSegmentsTable_0' }
              let(:confirm_message) { 'Are you sure you want to delete the selected organization isolation segments?' }
            end
          end

          context 'Standard buttons' do
            let(:filename) { 'organizations_isolation_segments' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_OrganizationsIsolationSegmentsTable_1' }
              let(:print_button_id) { 'Buttons_OrganizationsIsolationSegmentsTable_2' }
              let(:save_button_id)  { 'Buttons_OrganizationsIsolationSegmentsTable_3' }
              let(:csv_button_id)   { 'Buttons_OrganizationsIsolationSegmentsTable_4' }
              let(:excel_button_id) { 'Buttons_OrganizationsIsolationSegmentsTable_5' }
              let(:pdf_button_id)   { 'Buttons_OrganizationsIsolationSegmentsTable_6' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_OrganizationsIsolationSegmentsTable_7' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Organization',           tag: 'div', value: cc_organization[:name] },
                            { label: 'Organization GUID',      tag:   nil, value: cc_organization[:guid] },
                            { label: 'Isolation Segment',      tag:   'a', value: cc_isolation_segment[:name] },
                            { label: 'Isolation Segment GUID', tag:   nil, value: cc_isolation_segment[:guid] }
                          ])
          end

          it 'has organizations link' do
            check_filter_link('OrganizationsIsolationSegments', 0, 'Organizations', cc_organization[:guid])
          end

          it 'has isolation segments link' do
            check_filter_link('OrganizationsIsolationSegments', 2, 'IsolationSegments', cc_isolation_segment[:guid])
          end
        end
      end

      context 'Environment Groups' do
        let(:tab_id)   { 'EnvironmentGroups' }
        let(:table_id) { 'EnvironmentGroupsTable' }

        it 'has a table' do
          check_table_layout([
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='EnvironmentGroupsTableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                                 expected_length: 4,
                                 labels:          %w[Name GUID Created Updated],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='EnvironmentGroupsTable']/tbody/tr/td"),
                           [
                             cc_env_group[:name],
                             cc_env_group[:guid],
                             cc_env_group[:created_at].to_datetime.rfc3339,
                             cc_env_group[:updated_at].to_datetime.rfc3339
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_EnvironmentGroupsTable_0')
        end

        context 'manage environment groups' do
          context 'Standard buttons' do
            let(:filename) { 'environment_groups' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_EnvironmentGroupsTable_0' }
              let(:print_button_id) { 'Buttons_EnvironmentGroupsTable_1' }
              let(:save_button_id)  { 'Buttons_EnvironmentGroupsTable_2' }
              let(:csv_button_id)   { 'Buttons_EnvironmentGroupsTable_3' }
              let(:excel_button_id) { 'Buttons_EnvironmentGroupsTable_4' }
              let(:pdf_button_id)   { 'Buttons_EnvironmentGroupsTable_5' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_EnvironmentGroupsTable_6' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Name',    tag: 'div', value: cc_env_group[:name] },
                            { label: 'GUID',    tag:   nil, value: cc_env_group[:guid] },
                            { label: 'Created', tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_env_group[:created_at].to_datetime.rfc3339}\")") },
                            { label: 'Updated', tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{cc_env_group[:updated_at].to_datetime.rfc3339}\")") }
                          ])
          end

          it 'has variables' do
            expect(@driver.find_element(id: 'EnvironmentGroupsVariablesDetailsLabel').displayed?).to be(true)

            check_table_headers(columns:         @driver.find_elements(xpath: "//div[@id='EnvironmentGroupsVariablesTableContainer']/div[2]/div[4]/div/div/table/thead/tr/th"),
                                expected_length: 2,
                                labels:          %w[Key Value],
                                colspans:        nil)

            check_table_data(@driver.find_elements(xpath: "//table[@id='EnvironmentGroupsVariablesTable']/tbody/tr/td"),
                             [
                               cc_env_group_variable.keys.first,
                               "\"#{cc_env_group_variable.values.first}\""
                             ])
          end

          it 'variables subtable has allowscriptaccess property set to sameDomain' do
            check_allowscriptaccess_attribute('Buttons_EnvironmentGroupsVariablesTable_0')
          end

          context 'manage variables subtable' do
            context 'Standard buttons' do
              let(:filename) { 'environment_group_variables' }

              it_behaves_like('standard buttons') do
                let(:copy_button_id)  { 'Buttons_EnvironmentGroupsVariablesTable_0' }
                let(:print_button_id) { 'Buttons_EnvironmentGroupsVariablesTable_1' }
                let(:save_button_id)  { 'Buttons_EnvironmentGroupsVariablesTable_2' }
                let(:csv_button_id)   { 'Buttons_EnvironmentGroupsVariablesTable_3' }
                let(:excel_button_id) { 'Buttons_EnvironmentGroupsVariablesTable_4' }
                let(:pdf_button_id)   { 'Buttons_EnvironmentGroupsVariablesTable_5' }
              end
            end
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
                                 colspans:        %w[5 5 2 2]
                               },
                               {
                                 columns:         @driver.find_elements(xpath: "//div[@id='DEAsTableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                                 expected_length: 14,
                                 labels:          ['Name', 'Index', 'Source', 'Metrics', 'State', 'Total', 'Running', 'Memory', 'Disk', '% CPU', 'Memory', 'Disk', 'Memory', 'Disk'],
                                 colspans:        nil
                               }
                             ])
        end

        it 'has table data' do
          check_table_data(@driver.find_elements(xpath: "//table[@id='DEAsTable']/tbody/tr/td"),
                           [
                             "#{dea_envelope.ip}:#{dea_envelope.index}",
                             dea_envelope.index,
                             'doppler',
                             Time.at(dea_envelope.timestamp / BILLION).to_datetime.rfc3339,
                             @driver.execute_script('return Constants.STATUS__RUNNING'),
                             @driver.execute_script("return Format.formatNumber(#{DopplerHelper::DEA_VALUE_METRICS['instances']})"),
                             @driver.execute_script("return Format.formatNumber(#{cc_process[:instances]})"),
                             @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_memory)})"),
                             @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(used_disk)})"),
                             @driver.execute_script("return Format.formatNumber(#{used_cpu})"),
                             @driver.execute_script("return Format.formatNumber(#{DopplerHelper::DEA_VALUE_METRICS['available_memory_ratio'].to_f} * 100)"),
                             @driver.execute_script("return Format.formatNumber(#{DopplerHelper::DEA_VALUE_METRICS['available_disk_ratio'].to_f} * 100)"),
                             @driver.execute_script("return Format.formatNumber(#{DopplerHelper::DEA_VALUE_METRICS['remaining_memory']})"),
                             @driver.execute_script("return Format.formatNumber(#{DopplerHelper::DEA_VALUE_METRICS['remaining_disk']})")
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_DEAsTable_0')
        end

        context 'manage DEAs' do
          context 'Standard buttons' do
            let(:filename) { 'deas' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_DEAsTable_0' }
              let(:print_button_id) { 'Buttons_DEAsTable_1' }
              let(:save_button_id)  { 'Buttons_DEAsTable_2' }
              let(:csv_button_id)   { 'Buttons_DEAsTable_3' }
              let(:excel_button_id) { 'Buttons_DEAsTable_4' }
              let(:pdf_button_id)   { 'Buttons_DEAsTable_5' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_DEAsTable_6' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Name',                  tag: 'div', value: "#{dea_envelope.ip}:#{dea_envelope.index}" },
                            { label: 'IP',                    tag:   nil, value: dea_envelope.ip },
                            { label: 'Index',                 tag:   nil, value: dea_envelope.index },
                            { label: 'Source',                tag:   nil, value: 'doppler' },
                            { label: 'Metrics',               tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{Time.at(dea_envelope.timestamp / BILLION).to_datetime.rfc3339}\")") },
                            { label: 'Uptime',                tag:   nil, value: @driver.execute_script("return Format.formatDopplerUptime(#{DopplerHelper::DEA_VALUE_METRICS['uptime']})") },
                            { label: 'CPU Load Avg',          tag:   nil, value: "#{@driver.execute_script("return Format.formatNumber(#{DopplerHelper::DEA_VALUE_METRICS['avg_cpu_load'].to_f} * 100)")}%" },
                            { label: 'Total Instances',       tag:   'a', value: @driver.execute_script("return Format.formatNumber(#{DopplerHelper::DEA_VALUE_METRICS['instances']})") },
                            { label: 'Running Instances',     tag:   nil, value: @driver.execute_script("return Format.formatNumber(#{cc_process[:instances]})") },
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
            check_filter_link('DEAs', 7, 'ApplicationInstances', "#{dea_envelope.ip}:#{dea_envelope.index}")
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
                                 colspans:        %w[10 3 2 2]
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
                             rep_envelope.index,
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

        context 'manage cells' do
          context 'Standard buttons' do
            let(:filename) { 'cells' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_CellsTable_0' }
              let(:print_button_id) { 'Buttons_CellsTable_1' }
              let(:save_button_id)  { 'Buttons_CellsTable_2' }
              let(:csv_button_id)   { 'Buttons_CellsTable_3' }
              let(:excel_button_id) { 'Buttons_CellsTable_4' }
              let(:pdf_button_id)   { 'Buttons_CellsTable_5' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_CellsTable_6' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Name',                           tag: 'div', value: "#{rep_envelope.ip}:#{rep_envelope.index}" },
                            { label: 'IP',                             tag:   nil, value: rep_envelope.ip },
                            { label: 'Index',                          tag:   nil, value: rep_envelope.index },
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
                                 labels:          %w[Name Index Source State Started Cores CPU Memory],
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
                             @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_kilobytes_to_megabytes(varz_cloud_controller['mem_bytes'])})")
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_CloudControllersTable_0')
        end

        context 'manage cloud controllers' do
          context 'Standard buttons' do
            let(:filename) { 'cloud_controllers' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_CloudControllersTable_0' }
              let(:print_button_id) { 'Buttons_CloudControllersTable_1' }
              let(:save_button_id)  { 'Buttons_CloudControllersTable_2' }
              let(:csv_button_id)   { 'Buttons_CloudControllersTable_3' }
              let(:excel_button_id) { 'Buttons_CloudControllersTable_4' }
              let(:pdf_button_id)   { 'Buttons_CloudControllersTable_5' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_CloudControllersTable_6' }
            end
          end
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
                            { label: 'Memory',           tag: nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_kilobytes_to_megabytes(varz_cloud_controller['mem_bytes'])})") },
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
                                 labels:          %w[Name Index Source Metrics State Cores Memory],
                                 colspans:        nil
                               }
                             ])
        end

        it 'has table data' do
          check_table_data(@driver.find_elements(xpath: "//table[@id='HealthManagersTable']/tbody/tr/td"),
                           [
                             "#{analyzer_envelope.ip}:#{analyzer_envelope.index}",
                             analyzer_envelope.index,
                             'doppler',
                             Time.at(analyzer_envelope.timestamp / BILLION).to_datetime.rfc3339,
                             @driver.execute_script('return Constants.STATUS__RUNNING'),
                             @driver.execute_script("return Format.formatNumber(#{DopplerHelper::ANALYZER_VALUE_METRICS['numCPUS']})"),
                             @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_bytes_to_megabytes(DopplerHelper::ANALYZER_VALUE_METRICS['memoryStats.numBytesAllocated'])})")
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_HealthManagersTable_0')
        end

        context 'manage health managers' do
          context 'Standard buttons' do
            let(:filename) { 'health_managers' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_HealthManagersTable_0' }
              let(:print_button_id) { 'Buttons_HealthManagersTable_1' }
              let(:save_button_id)  { 'Buttons_HealthManagersTable_2' }
              let(:csv_button_id)   { 'Buttons_HealthManagersTable_3' }
              let(:excel_button_id) { 'Buttons_HealthManagersTable_4' }
              let(:pdf_button_id)   { 'Buttons_HealthManagersTable_5' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_HealthManagersTable_6' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          it 'has details' do
            check_details([
                            { label: 'Name',                              tag: 'div', value: "#{analyzer_envelope.ip}:#{analyzer_envelope.index}" },
                            { label: 'IP',                                tag:   nil, value: analyzer_envelope.ip },
                            { label: 'Index',                             tag:   nil, value: analyzer_envelope.index },
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

        context 'manage service gateways' do
          context 'Standard buttons' do
            let(:filename) { 'gateways' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_GatewaysTable_0' }
              let(:print_button_id) { 'Buttons_GatewaysTable_1' }
              let(:save_button_id)  { 'Buttons_GatewaysTable_2' }
              let(:csv_button_id)   { 'Buttons_GatewaysTable_3' }
              let(:excel_button_id) { 'Buttons_GatewaysTable_4' }
              let(:pdf_button_id)   { 'Buttons_GatewaysTable_5' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_GatewaysTable_6' }
            end
          end
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

          context 'manage nodes subtable' do
            context 'Standard buttons' do
              let(:filename) { 'gateway_nodes' }

              it_behaves_like('standard buttons') do
                let(:copy_button_id)  { 'Buttons_GatewaysNodesTable_0' }
                let(:print_button_id) { 'Buttons_GatewaysNodesTable_1' }
                let(:save_button_id)  { 'Buttons_GatewaysNodesTable_2' }
                let(:csv_button_id)   { 'Buttons_GatewaysNodesTable_3' }
                let(:excel_button_id) { 'Buttons_GatewaysNodesTable_4' }
                let(:pdf_button_id)   { 'Buttons_GatewaysNodesTable_5' }
              end
            end
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

        context 'varz router' do
          it 'has table data' do
            check_table_data(@driver.find_elements(xpath: "//table[@id='RoutersTable']/tbody/tr/td"),
                             [
                               nats_router['host'],
                               nats_router['index'].to_s,
                               'varz',
                               nil,
                               @driver.execute_script('return Constants.STATUS__RUNNING'),
                               varz_router['start'],
                               @driver.execute_script("return Format.formatNumber(#{varz_router['num_cores']})"),
                               @driver.execute_script("return Format.formatNumber(#{varz_router['cpu']})"),
                               @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_kilobytes_to_megabytes(varz_router['mem_bytes'])})"),
                               @driver.execute_script("return Format.formatNumber(#{varz_router['droplets']})"),
                               @driver.execute_script("return Format.formatNumber(#{varz_router['requests']})"),
                               @driver.execute_script("return Format.formatNumber(#{varz_router['bad_requests']})")
                             ])
          end
        end

        context 'doppler router' do
          let(:router_source) { :doppler_router }
          it 'has table data' do
            check_table_data(@driver.find_elements(xpath: "//table[@id='RoutersTable']/tbody/tr/td"),
                             [
                               "#{gorouter_envelope.ip}:#{gorouter_envelope.index}",
                               gorouter_envelope.index,
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

        context 'manage routers' do
          context 'Standard buttons' do
            let(:filename) { 'routers' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_RoutersTable_0' }
              let(:print_button_id) { 'Buttons_RoutersTable_1' }
              let(:save_button_id)  { 'Buttons_RoutersTable_2' }
              let(:csv_button_id)   { 'Buttons_RoutersTable_3' }
              let(:excel_button_id) { 'Buttons_RoutersTable_4' }
              let(:pdf_button_id)   { 'Buttons_RoutersTable_5' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_RoutersTable_6' }
            end
          end
        end

        context 'selectable' do
          before do
            select_first_row
          end

          context 'varz router' do
            it 'has details' do
              check_details([
                              { label: 'Name',          tag: nil, value: nats_router['host'] },
                              { label: 'Index',         tag: nil, value: nats_router['index'].to_s },
                              { label: 'Source',        tag: nil, value: 'varz' },
                              { label: 'URI',           tag: 'a', value: nats_router_varz },
                              { label: 'Started',       tag: nil, value: @driver.execute_script("return Format.formatDateString(\"#{varz_router['start']}\")") },
                              { label: 'Uptime',        tag: nil, value: @driver.execute_script("return Format.formatUptime(\"#{varz_router['uptime']}\")") },
                              { label: 'Cores',         tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_router['num_cores']})") },
                              { label: 'CPU',           tag: nil, value: @driver.execute_script("return Format.formatNumber(#{varz_router['cpu']})") },
                              { label: 'Memory',        tag: nil, value: @driver.execute_script("return Format.formatNumber(#{AdminUI::Utils.convert_kilobytes_to_megabytes(varz_router['mem_bytes'])})") },
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
                                  labels:          %w[Name GUID RPM RPS Target],
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

            context 'manage top10 applications subtable' do
              context 'Standard buttons' do
                let(:filename) { 'router_applications' }

                it_behaves_like('standard buttons') do
                  let(:copy_button_id)  { 'Buttons_RoutersTop10ApplicationsTable_0' }
                  let(:print_button_id) { 'Buttons_RoutersTop10ApplicationsTable_1' }
                  let(:save_button_id)  { 'Buttons_RoutersTop10ApplicationsTable_2' }
                  let(:csv_button_id)   { 'Buttons_RoutersTop10ApplicationsTable_3' }
                  let(:excel_button_id) { 'Buttons_RoutersTop10ApplicationsTable_4' }
                  let(:pdf_button_id)   { 'Buttons_RoutersTop10ApplicationsTable_5' }
                end
              end
            end
          end

          context 'doppler router' do
            let(:router_source) { :doppler_router }
            it 'has details' do
              check_details([
                              { label: 'Name',    tag: 'div', value: "#{gorouter_envelope.ip}:#{gorouter_envelope.index}" },
                              { label: 'IP',      tag:   nil, value: gorouter_envelope.ip },
                              { label: 'Index',   tag:   nil, value: gorouter_envelope.index },
                              { label: 'Source',  tag:   nil, value: 'doppler' },
                              { label: 'Metrics', tag:   nil, value: @driver.execute_script("return Format.formatDateString(\"#{Time.at(gorouter_envelope.timestamp / BILLION).to_datetime.rfc3339}\")") },
                              { label: 'Uptime',  tag:   nil, value: @driver.execute_script("return Format.formatDopplerUptime(#{DopplerHelper::GOROUTER_VALUE_METRICS['uptime']})") },
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
                                 labels:          %w[Name Type Index Source Metrics State Started],
                                 colspans:        nil
                               }
                             ])

          check_table_data(@driver.find_elements(xpath: "//table[@id='ComponentsTable']/tbody/tr/td"),
                           [
                             nats_cloud_controller['host'],
                             nats_cloud_controller['type'],
                             nats_cloud_controller['index'].to_s,
                             'varz',
                             nil,
                             @driver.execute_script('return Constants.STATUS__RUNNING'),
                             varz_cloud_controller['start']
                           ])
        end

        it 'has allowscriptaccess property set to sameDomain' do
          check_allowscriptaccess_attribute('Buttons_ComponentsTable_2')
        end

        context 'manage components' do
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

          context 'Standard buttons' do
            let(:filename) { 'components' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_ComponentsTable_2' }
              let(:print_button_id) { 'Buttons_ComponentsTable_3' }
              let(:save_button_id)  { 'Buttons_ComponentsTable_4' }
              let(:csv_button_id)   { 'Buttons_ComponentsTable_5' }
              let(:excel_button_id) { 'Buttons_ComponentsTable_6' }
              let(:pdf_button_id)   { 'Buttons_ComponentsTable_7' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_ComponentsTable_8' }
            end
          end
        end

        context 'selectable' do
          it 'has details' do
            select_first_row
            check_details([
                            { label: 'Name',    tag: nil, value: nats_cloud_controller['host'] },
                            { label: 'Type',    tag: nil, value: nats_cloud_controller['type'] },
                            { label: 'Index',   tag: nil, value: nats_cloud_controller['index'].to_s },
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

        context 'manage logs' do
          context 'Standard buttons' do
            let(:filename) { 'logs' }

            it_behaves_like('standard buttons') do
              let(:copy_button_id)  { 'Buttons_LogsTable_0' }
              let(:print_button_id) { 'Buttons_LogsTable_1' }
              let(:save_button_id)  { 'Buttons_LogsTable_2' }
              let(:csv_button_id)   { 'Buttons_LogsTable_3' }
              let(:excel_button_id) { 'Buttons_LogsTable_4' }
              let(:pdf_button_id)   { 'Buttons_LogsTable_5' }
            end

            it_behaves_like('download button') do
              let(:download_button_id) { 'Buttons_LogsTable_6' }
            end
          end
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

          context 'doppler cell' do
            let(:application_instance_source) { :doppler_cell }
            it_behaves_like('it has a table')
          end

          context 'doppler dea' do
            it_behaves_like('it has a table')
          end

          it 'has allowscriptaccess property set to sameDomain' do
            check_allowscriptaccess_attribute('Buttons_StatsTable_1')
          end

          context 'manage stats' do
            context 'Standard buttons' do
              let(:filename) { 'stats' }

              it_behaves_like('standard buttons') do
                let(:copy_button_id)  { 'Buttons_StatsTable_1' }
                let(:print_button_id) { 'Buttons_StatsTable_2' }
                let(:save_button_id)  { 'Buttons_StatsTable_3' }
                let(:csv_button_id)   { 'Buttons_StatsTable_4' }
                let(:excel_button_id) { 'Buttons_StatsTable_5' }
                let(:pdf_button_id)   { 'Buttons_StatsTable_6' }
              end

              it_behaves_like('download button') do
                let(:download_button_id) { 'Buttons_StatsTable_7' }
              end
            end
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

        context 'doppler cell' do
          let(:application_instance_source) { :doppler_cell }
          it_behaves_like('can show current stats')
        end

        context 'doppler dea' do
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
            application_instance_source == :doppler_dea ? '1' : '0',
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

        context 'doppler cell' do
          let(:application_instance_source) { :doppler_cell }
          it_behaves_like('can create stats')
        end

        context 'doppler dea' do
          it_behaves_like('can create stats')
        end
      end
    end
  end
end
