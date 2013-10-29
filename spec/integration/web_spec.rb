require 'rubygems'
require 'selenium-webdriver'
require_relative '../spec_helper'

RSpec.configure do |config|
  firefox_exists = false
  begin
    firefox_exists = File.exists?(Selenium::WebDriver::Firefox::Binary.path)
  rescue
  end
  config.filter_run_excluding :firefox_available => true unless firefox_exists
end

describe IBM::AdminUI::Admin, :type => :integration, :firefox_available => true do
  include_context :server_context

  before do
    @driver = Selenium::WebDriver.for :firefox
    @driver.manage.timeouts.implicit_wait = 5
  end

  after do
    @driver.quit
  end

  def login(username, password, target_page)
    @driver.get 'http://localhost:8071/'
    @driver.find_element(:id => 'username').send_keys username
    @driver.find_element(:id => 'password').send_keys password
    @driver.find_element(:id => 'username').submit
    Selenium::WebDriver::Wait.new(:timeout => 5).until { @driver.title == target_page }
  end

  it 'requires valid credentials' do
    login('admin', 'bad_password', 'Login')
  end

  context 'authenticated' do
    before do
      login('admin', 'admin_passw0rd', 'Administration')
    end

    it 'has a title' do
      expect(@driver.find_element(:class => 'cloudControllerText').text).to eq(cloud_controller_uri)
    end

    it 'has tabs' do
      expect(@driver.find_element(:id => 'Organizations').displayed?).to    be_true
      expect(@driver.find_element(:id => 'Spaces').displayed?).to           be_true
      expect(@driver.find_element(:id => 'Applications').displayed?).to     be_true
      expect(@driver.find_element(:id => 'Developers').displayed?).to       be_true
      expect(@driver.find_element(:id => 'DEAs').displayed?).to             be_true
      expect(@driver.find_element(:id => 'CloudControllers').displayed?).to be_true
      expect(@driver.find_element(:id => 'HealthManagers').displayed?).to   be_true
      expect(@driver.find_element(:id => 'Gateways').displayed?).to         be_true
      expect(@driver.find_element(:id => 'Routers').displayed?).to          be_true
      expect(@driver.find_element(:id => 'Components').displayed?).to       be_true
      expect(@driver.find_element(:id => 'Logs').displayed?).to             be_true
      expect(@driver.find_element(:id => 'Tasks').displayed?).to            be_true
      expect(@driver.find_element(:id => 'Stats').displayed?).to            be_true
    end

    it 'has a refresh button' do
      expect(@driver.find_element(:id => 'RefreshButton').displayed?).to be_true
    end

    it 'shows the logged in user' do
      expect(@driver.find_element(:class => 'userContainer').displayed?).to be_true
      expect(@driver.find_element(:class => 'user').text).to eq(admin_user)
    end

    context 'tabs' do
      before do
        @driver.find_element(:id => tab_id).click
        expect(@driver.find_element(:class_name => 'menuItemSelected').attribute('id')).to eq(tab_id)
        expect(@driver.find_element(:id => "#{ tab_id }Page").displayed?).to be_true
      end

      def check_table(columns_array)
        expect(@driver.find_element(:id => "#{ tab_id }Table").displayed?).to be_true
        columns_array.each do |columns|
          check_table_headers(columns)
        end
      end

      def check_table_headers(headRow)
        expect(headRow[:columns]).to_not be_nil
        expect(headRow[:columns].length).to eq(headRow[:expected_length])
        column_index = 0
        while column_index < headRow[:expected_length]
          expect(headRow[:columns][column_index].text).to eq(headRow[:labels][column_index])
          unless headRow[:colspans].nil?
            expect(headRow[:columns][column_index].attribute('colspan')).to eq(headRow[:colspans][column_index])
          end
          column_index += 1
        end
      end

      def get_first_row
        @driver.find_elements(:xpath => "//table[@id='#{ tab_id }Table']/tbody/tr")[0]
      end

      def select_first_row
        get_first_row.click
      end

      def check_filter_link(tab_id, link_index, target_tab_id, expected_filter)
        @driver.find_elements(:xpath => "//div[@id='#{ tab_id }PropertiesContainer']/table/tr[*]/td[2]")[link_index].find_element(:tag_name => 'a').click
        expect(@driver.find_element(:class_name => 'menuItemSelected').attribute('id')).to eq(target_tab_id)
        expect(@driver.find_element(:id => "#{ target_tab_id }Table_filter").find_element(:tag_name => 'input').attribute('value')).to eq(expected_filter)
      end

      def check_select_link(tab_id, link_index, target_tab_id, expected_name)
        @driver.find_elements(:xpath => "//div[@id='#{ tab_id }PropertiesContainer']/table/tr[*]/td[2]")[link_index].find_element(:tag_name => 'a').click
        expect(@driver.find_element(:class_name => 'menuItemSelected').attribute('id')).to eq(target_tab_id)
        expect(@driver.find_element(:xpath => "//table[@id='#{ target_tab_id }Table']/tbody/tr[contains(@class, 'DTTT_selected')]/td[1]").text).to eq(expected_name)
        expect(@driver.find_element(:id => "#{ target_tab_id }DetailsLabel").displayed?).to be_true
        expect(@driver.find_elements(:xpath => "//div[@id='#{ target_tab_id }PropertiesContainer']/table/tr[*]/td[2]")[0].text).to eq(expected_name)
      end

      def check_details(expected_properties)
        expect(@driver.find_element(:id => "#{ tab_id }DetailsLabel").displayed?).to be_true
        properties = @driver.find_elements(:xpath => "//div[@id='#{ tab_id }PropertiesContainer']/table/tr[*]/td[1]")
        values     = @driver.find_elements(:xpath => "//div[@id='#{ tab_id }PropertiesContainer']/table/tr[*]/td[2]")
        property_index = 0
        expected_properties.each do |expected_property|
          expect(properties[property_index].text).to eq("#{ expected_property[:label] }:")
          if expected_property[:tag].nil?
            value = values[property_index].text
          else
            value = values[property_index].find_element(:tag_name => expected_property[:tag]).text
          end
            expect(value).to eq(expected_property[:value])
          property_index += 1
        end
      end

      context 'organizations' do
        let(:tab_id) { 'Organizations' }
        it 'has a table' do
          check_table([
                        {
                          :columns         => @driver.find_elements(:xpath => "//div[@id='OrganizationsTableContainer']/div/div[5]/div[1]/div/table/thead/tr[1]/th"),
                          :expected_length => 3,
                          :labels          => ['', 'App States', 'App Package States'],
                          :colspans        => %w(5 3 3)
                        },
                        {
                          :columns         => @driver.find_elements(:xpath => "//div[@id='OrganizationsTableContainer']/div/div[5]/div[1]/div/table/thead/tr[2]/th"),
                          :expected_length => 11,
                          :labels          => %w(Name Status Created Spaces Developers Total Started Stopped Pending Staged Failed),
                          :colspans        => nil
                        }
                      ])
        end
        context 'selectable' do
          before do
            select_first_row
          end
          it 'has details' do
            check_details([
                            { :label => 'Name',            :tag => 'div', :value => cc_organizations['resources'][0]['entity']['name'] },
                            { :label => 'Status',          :tag =>   nil, :value => cc_organizations['resources'][0]['entity']['status'].upcase },
                            { :label => 'Created',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_organizations['resources'][0]['metadata']['created_at'] }\")") },
                            { :label => 'Billing Enabled', :tag =>   nil, :value => cc_organizations['resources'][0]['entity']['billing_enabled'].to_s },
                            { :label => 'Spaces',          :tag =>   'a', :value => cc_spaces['resources'].length.to_s },
                            { :label => 'Developers',      :tag =>   'a', :value => cc_users_deep['resources'].length.to_s },
                            { :label => 'Total Apps',      :tag =>   'a', :value => cc_apps['resources'].length.to_s },
                            { :label => 'Started Apps',    :tag =>   nil, :value => cc_apps['resources'][0]['entity']['state'] == 'STARTED' ? '1' : '0' },
                            { :label => 'Stopped Apps',    :tag =>   nil, :value => cc_apps['resources'][0]['entity']['state'] == 'STOPPED' ? '1' : '0' },
                            { :label => 'Pending Apps',    :tag =>   nil, :value => cc_apps['resources'][0]['entity']['state'] == 'PENDING' ? '1' : '0' },
                            { :label => 'Staged Apps',     :tag =>   nil, :value => cc_apps['resources'][0]['entity']['state'] == 'STAGED'  ? '1' : '0' },
                            { :label => 'Failed Apps',     :tag =>   nil, :value => cc_apps['resources'][0]['entity']['state'] == 'FAILED'  ? '1' : '0' }
                          ])
          end
          it 'has spaces link' do
            check_filter_link('Organizations', 4, 'Spaces', "#{ cc_organizations['resources'][0]['entity']['name'] }/")
          end
          it 'has developers link' do
            check_filter_link('Organizations', 5, 'Developers', "#{ cc_organizations['resources'][0]['entity']['name'] }/")
          end
          it 'has applications link' do
            check_filter_link('Organizations', 6, 'Applications', "#{ cc_organizations['resources'][0]['entity']['name'] }/")
          end
        end
      end

      context 'Spaces' do
        let(:tab_id) { 'Spaces' }
        it 'has a table' do
          check_table([
                        {
                          :columns         => @driver.find_elements(:xpath => "//div[@id='SpacesTableContainer']/div/div[5]/div[1]/div/table/thead/tr[1]/th"),
                          :expected_length => 3,
                          :labels          => ['', 'App States', 'App Package States'],
                          :colspans        => %w(5 3 3)
                        },
                        {
                          :columns         => @driver.find_elements(:xpath => "//div[@id='SpacesTableContainer']/div/div[5]/div[1]/div/table/thead/tr[2]/th"),
                          :expected_length => 11,
                          :labels          => %w(Name Organization Target Created Developers Total Started Stopped Pending Staged Failed),
                          :colspans        => nil
                        }
                      ])
        end
        context 'selectable' do
          before do
            select_first_row
          end
          it 'has details' do
            check_details([
                            { :label => 'Name',         :tag => 'div', :value => cc_spaces['resources'][0]['entity']['name'] },
                            { :label => 'Organization', :tag =>   'a', :value => cc_organizations['resources'][0]['entity']['name'] },
                            { :label => 'Created',      :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ cc_spaces['resources'][0]['metadata']['created_at'] }\")") },
                            { :label => 'Developers',   :tag =>   'a', :value => cc_users_deep['resources'].length.to_s },
                            { :label => 'Total Apps',   :tag =>   'a', :value => cc_apps['resources'].length.to_s },
                            { :label => 'Started Apps', :tag =>   nil, :value => cc_apps['resources'][0]['entity']['state'] == 'STARTED' ? '1' : '0' },
                            { :label => 'Stopped Apps', :tag =>   nil, :value => cc_apps['resources'][0]['entity']['state'] == 'STOPPED' ? '1' : '0' },
                            { :label => 'Pending Apps', :tag =>   nil, :value => cc_apps['resources'][0]['entity']['state'] == 'PENDING' ? '1' : '0' },
                            { :label => 'Staged Apps',  :tag =>   nil, :value => cc_apps['resources'][0]['entity']['state'] == 'STAGED'  ? '1' : '0' },
                            { :label => 'Failed Apps',  :tag =>   nil, :value => cc_apps['resources'][0]['entity']['state'] == 'FAILED'  ? '1' : '0' }
                          ])
          end
          it 'has organization link' do
            check_select_link('Spaces', 1, 'Organizations', cc_organizations['resources'][0]['entity']['name'])
          end
          it 'has developers link' do
            check_filter_link('Spaces', 3, 'Developers', "#{ cc_organizations['resources'][0]['entity']['name'] }/#{ cc_spaces['resources'][0]['entity']['name'] }")
          end
          it 'has applications link' do
            check_filter_link('Spaces', 4, 'Applications', "#{ cc_organizations['resources'][0]['entity']['name'] }/#{ cc_spaces['resources'][0]['entity']['name'] }")
          end
        end
      end

      context 'Applications' do
        let(:tab_id) { 'Applications' }
        it 'has a table' do
          check_table([
                        {
                          :columns         => @driver.find_elements(:xpath => "//div[@id='ApplicationsTableContainer']/div/div[5]/div[1]/div/table/thead/tr/th"),
                          :expected_length => 14,
                          :labels          => ['Name', 'State', "Package\nState", 'Started', 'URI', 'Buildpack', 'Memory', 'Disk', 'Instance', 'Services', 'Space', 'Organization', 'Target', 'DEA'],
                          :colspans        => nil
                        }
                      ])
        end
        context 'selectable' do
          before do
            select_first_row
          end
          it 'has details' do
            check_details([
                            { :label => 'Name',            :tag => 'div', :value => cc_apps['resources'][0]['entity']['name'] },
                            { :label => 'State',           :tag =>   nil, :value => cc_apps['resources'][0]['entity']['state'] },
                            { :label => 'Started',         :tag =>   nil, :value => @driver.execute_script("return Format.formatDateNumber(#{ (varz_dea['instance_registry']['application1']['application1_instance1']['state_running_timestamp'] * 1000) })") },
                            { :label => 'URI',             :tag =>   'a', :value => "http://#{ varz_dea['instance_registry']['application1']['application1_instance1']['application_uris'][0] }" },
                            { :label => 'Buildpack',       :tag =>   nil, :value => cc_apps['resources'][0]['entity']['detected_buildpack'] },
                            { :label => 'Memory Reserved', :tag =>   nil, :value => cc_apps['resources'][0]['entity']['memory'].to_s },
                            { :label => 'Disk Reserved',   :tag =>   nil, :value => cc_apps['resources'][0]['entity']['disk_quota'].to_s },
                            { :label => 'Instance Index',  :tag =>   nil, :value => varz_dea['instance_registry']['application1']['application1_instance1']['instance_index'].to_s },
                            { :label => 'Instance State',  :tag =>   nil, :value => varz_dea['instance_registry']['application1']['application1_instance1']['state'] },
                            { :label => 'Services',        :tag =>   nil, :value => varz_dea['instance_registry']['application1']['application1_instance1']['services'].length.to_s },
                            { :label => 'Droplet Hash',    :tag =>   nil, :value => varz_dea['instance_registry']['application1']['application1_instance1']['droplet_sha1'].to_s },
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
          end
          it 'has space link' do
            check_select_link('Applications', 11, 'Spaces', cc_spaces['resources'][0]['entity']['name'])
          end
          it 'has organization link' do
            check_select_link('Applications', 12, 'Organizations', cc_organizations['resources'][0]['entity']['name'])
          end
          it 'has DEA link' do
            check_select_link('Applications', 13, 'DEAs', nats_dea['host'])
          end
        end
      end

      context 'Developers' do
        let(:tab_id) { 'Developers' }
        it 'has a table' do
          check_table([
                        {
                          :columns         => @driver.find_elements(:xpath => "//div[@id='DevelopersTableContainer']/div/div[5]/div[1]/div/table/thead/tr/th"),
                          :expected_length => 5,
                          :labels          => %w(Email Space Organization Target Created),
                          :colspans        => nil
                        }
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
            check_details([
                            { :label => 'Email',        :tag => 'div', :value => "mailto:#{ uaa_users['resources'][0]['emails'][0]['value'] }" },
                            { :label => 'Created',      :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ uaa_users['resources'][0]['meta']['created'] }\")") },
                            { :label => 'Modified',     :tag =>   nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ uaa_users['resources'][0]['meta']['lastModified'] }\")") },
                            { :label => 'Authorities',  :tag =>   nil, :value => groups_string },
                            { :label => 'Space',        :tag =>   'a', :value => cc_spaces['resources'][0]['entity']['name'] },
                            { :label => 'Organization', :tag =>   'a', :value => cc_organizations['resources'][0]['entity']['name'] }
                          ])
          end
          it 'has space link' do
            check_select_link('Developers', 4, 'Spaces', cc_spaces['resources'][0]['entity']['name'])
          end
          it 'has organization link' do
            check_select_link('Developers', 5, 'Organizations', cc_organizations['resources'][0]['entity']['name'])
          end
        end
      end

      context 'DEAs' do
        let(:tab_id) { 'DEAs' }
        it 'has a table' do
          check_table([
                        {
                          :columns         => @driver.find_elements(:xpath => "//div[@id='DEAsTableContainer']/div/div[5]/div[1]/div/table/thead/tr[1]/th"),
                          :expected_length => 2,
                          :labels          => ['', '% Free'],
                          :colspans        => %w(6 2)
                        },
                        {
                          :columns         => @driver.find_elements(:xpath => "//div[@id='DEAsTableContainer']/div/div[5]/div[1]/div/table/thead/tr[2]/th"),
                          :expected_length => 8,
                          :labels          => %w(Name Status Started CPU Memory Apps Memory Disk),
                          :colspans        => nil
                        }
                      ])
        end
        context 'selectable' do
          before do
            select_first_row
          end
          it 'has details' do
            check_details([
                            { :label => 'Name',         :tag => nil, :value => varz_dea['host'] },
                            { :label => 'URI',          :tag => 'a', :value => nats_dea_varz },
                            { :label => 'Host',         :tag => nil, :value => varz_dea['host'] },
                            { :label => 'Started',      :tag => nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ varz_dea['start'] }\")") },
                            { :label => 'Uptime',       :tag => nil, :value => @driver.execute_script("return Format.formatUptime(\"#{ varz_dea['uptime'] }\")") },
                            { :label => 'Apps',         :tag => 'a', :value => varz_dea['instance_registry'].length.to_s },
                            { :label => 'Cores',        :tag => nil, :value => varz_dea['num_cores'].to_s },
                            { :label => 'CPU',          :tag => nil, :value => varz_dea['cpu'].to_s },
                            { :label => 'CPU Load Avg', :tag => nil, :value => @driver.execute_script("return Format.formatNumber(#{ varz_dea['cpu_load_avg'].to_f * 100 })") + '%' },
                            { :label => 'Memory',       :tag => nil, :value => varz_dea['mem'].to_s },
                            { :label => 'Memory Free',  :tag => nil, :value => @driver.execute_script("return Format.formatNumber(#{ varz_dea['available_memory_ratio'].to_f * 100 })") + '%' },
                            { :label => 'Disk Free',    :tag => nil, :value => @driver.execute_script("return Format.formatNumber(#{ varz_dea['available_disk_ratio'].to_f * 100 })") + '%' }
                          ])
          end
          it 'has applications link' do
            check_filter_link('DEAs', 5, 'Applications', varz_dea['host'])
          end
        end
      end

      context 'Cloud Controllers' do
        let(:tab_id) { 'CloudControllers' }
        it 'has a table' do
          check_table([
                        {
                          :columns         => @driver.find_elements(:xpath => "//div[@id='CloudControllersTableContainer']/div/div[5]/div[1]/div/table/thead/tr/th"),
                          :expected_length => 6,
                          :labels          => %w(Name State Started Cores CPU Memory),
                          :colspans        => nil
                        }
                      ])
        end
        context 'selectable' do
          it 'has details' do
            select_first_row
            check_details([
                            { :label => 'Name',             :tag => nil, :value => nats_cloud_controller['host'] },
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
          check_table([
                        {
                          :columns         => @driver.find_elements(:xpath => "//div[@id='HealthManagersTableContainer']/div/div[5]/div[1]/div/table/thead/tr/th"),
                          :expected_length => 9,
                          :labels          => %w(Name State Started Cores CPU Memory Users Applications Instances),
                          :colspans        => nil
                        }
                      ])
        end
        context 'selectable' do
          it 'has details' do
            select_first_row
            check_details([
                            { :label => 'Name',              :tag => nil, :value => nats_health_manager['host'] },
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
        it 'has a table' do
          check_table([
                        {
                          :columns         => @driver.find_elements(:xpath => "//div[@id='GatewaysTableContainer']/div/div[5]/div[1]/div/table/thead/tr/th"),
                          :expected_length => 10,
                          :labels          => ['Name', 'State', 'Started', 'Description', 'CPU', 'Memory', 'Nodes', "Provisioned\nServices", "Available\nCapacity", "% Available\nCapacity"],
                          :colspans        => nil
                        }
                      ])
        end
        context 'selectable' do
          before do
            select_first_row
          end
          it 'has details' do
            capacity = 0
            varz_provisioner['nodes'].each do |node|
              unless node[1]['available_capacity'].nil?
                capacity += node[1]['available_capacity']
              end
            end
            services = 0
            varz_provisioner['prov_svcs'].each do |service|
              services += 1 if service[1]['configuration']['data'].nil?
            end
            percent_available_capacity = capacity > 0 ? ((capacity.to_f / (services + capacity).to_f) * 100).round.to_i : 0
            check_details([
                            { :label => 'Name',                 :tag => nil, :value => nats_provisioner['type'][0..-13] },
                            { :label => 'URI',                  :tag => nil, :value => nats_provisioner_varz },
                            { :label => 'Supported Versions',   :tag => nil, :value => varz_provisioner['config']['service']['supported_versions'][0] },
                            { :label => 'Description',          :tag => nil, :value => varz_provisioner['config']['service']['description'] },
                            { :label => 'Started',              :tag => nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ varz_provisioner['start'] }\")") },
                            { :label => 'Uptime',               :tag => nil, :value => @driver.execute_script("return Format.formatUptime(\"#{ varz_provisioner['uptime'] }\")") },
                            { :label => 'Cores',                :tag => nil, :value => varz_provisioner['num_cores'].to_s },
                            { :label => 'CPU',                  :tag => nil, :value => varz_provisioner['cpu'].to_s },
                            { :label => 'Memory',               :tag => nil, :value => varz_provisioner['mem'].to_s },
                            { :label => 'Provisioned Services', :tag => nil, :value => varz_provisioner['prov_svcs'].length.to_s },
                            { :label => 'Available Capacity',   :tag => nil, :value => "#{ capacity} (#{ percent_available_capacity }%)" }
                          ])
          end
          it 'has nodes' do
            expect(@driver.find_element(:id => 'GatewaysNodesDetailsLabel').displayed?).to be_true
            check_table_headers(:columns         => @driver.find_elements(:xpath => "//div[@id='GatewaysNodesTableContainer']/div[2]/div[5]/div[1]/div/table/thead/tr/th"),
                                :expected_length => 2,
                                :labels          => ['Name', 'Available Capacity'],
                                :colspans        => nil)
          end
        end
      end

      context 'Routers' do
        let(:tab_id) { 'Routers' }
        it 'has a table' do
          check_table([
                        {
                          :columns         => @driver.find_elements(:xpath => "//div[@id='RoutersTableContainer']/div/div[5]/div[1]/div/table/thead/tr/th"),
                          :expected_length => 9,
                          :labels          => ['Name', 'State', 'Started', 'Cores', 'CPU', 'Memory', 'Droplets', 'Requests', 'Bad Requests'],
                          :colspans        => nil
                        }
                      ])
        end
        context 'selectable' do
          it 'has details' do
            select_first_row
            check_details([
                            { :label => 'Name',          :tag => nil, :value => nats_router['host'] },
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
          check_table([
                        {
                          :columns         => @driver.find_elements(:xpath => "//div[@id='ComponentsTableContainer']/div/div[5]/div[1]/div/table/thead/tr/th"),
                          :expected_length => 4,
                          :labels          => %w(Name Type State Started),
                          :colspans        => nil
                        }
                      ])
        end
        context 'selectable' do
          it 'has details' do
            select_first_row
            check_details([
                            { :label => 'Name',    :tag => nil, :value => nats_cloud_controller['host'] },
                            { :label => 'Type',    :tag => nil, :value => nats_cloud_controller['type'] },
                            { :label => 'Started', :tag => nil, :value => @driver.execute_script("return Format.formatDateString(\"#{ varz_cloud_controller['start'] }\")") },
                            { :label => 'URI',     :tag => 'a', :value => nats_cloud_controller_varz },
                            { :label => 'State',   :tag => nil, :value => @driver.execute_script('return Constants.STATUS__RUNNING') }
                          ])
          end
        end
      end

      context 'Logs' do
        let(:tab_id) { 'Logs' }
        it 'has a table' do
          check_table([
                        {
                          :columns         => @driver.find_elements(:xpath => "//div[@id='LogsTableContainer']/div/div[5]/div[1]/div/table/thead/tr/th"),
                          :expected_length => 3,
                          :labels          => ['Path', 'Size', 'Last Modified'],
                          :colspans        => nil
                        }
                      ])
        end
#        it 'has contents' do
#          row = get_first_row
#          row.click
#          columns = row.find_elements(:tag_name => 'td')
#          expect(columns.length).to eq(3)
#          expect(columns[0].text).to eq('')
#          expect(columns[1].text).to eq('')
#          expect(columns[2].text).to eq('')
#          expect(@driver.find_element(:id => 'LogContainer').displayed?).to be_true
#          expect(@driver.find_element(:id => 'LogLink').text).to eq(columns[0].text)
#          expect(@driver.find_element(:id => 'LogContents').text).to eq('')
#        end
      end

      context 'Tasks' do
        let(:tab_id) { 'Tasks' }
        it 'has a table' do
          check_table([
                        {
                          :columns         => @driver.find_elements(:xpath => "//div[@id='TasksTableContainer']/div/div[5]/div[1]/div/table/thead/tr/th"),
                          :expected_length => 3,
                          :labels          => %w(Command State Started),
                          :colspans        => nil
                        }
                      ])
        end
      end

      context 'Stats' do
        let(:tab_id) { 'Stats' }
        it 'has a table' do
          check_table([
                        {
                          :columns         => @driver.find_elements(:xpath => "//div[@id='StatsTableContainer']/div/div[5]/div[1]/div/table/thead/tr[1]/th"),
                          :expected_length => 3,
                          :labels          => ['', 'Instances', ''],
                          :colspans        => %w(5 2 1)
                        },
                        {
                          :columns         => @driver.find_elements(:xpath => "//div[@id='StatsTableContainer']/div/div[5]/div[1]/div/table/thead/tr[2]/th"),
                          :expected_length => 8,
                          :labels          => %w(Date Organizations Spaces Users Apps Total Running DEAs),
                          :colspans        => nil
                        }
                      ])
        end
        it 'has a chart' do
          expect(@driver.find_element(:id => 'StatsChart').displayed?).to be_true
        end
      end
    end
  end
end
