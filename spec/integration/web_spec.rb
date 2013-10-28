require 'rubygems'
require 'selenium-webdriver'
require 'webrick'
require_relative '../spec_helper'

describe IBM::AdminUI::Admin, :type => :integration do
  include CCHelper
  include NATSHelper
  include VARZHelper

  let(:host) { 'localhost' }
  let(:port) { 8071 }

  let(:data_file) { '/tmp/admin_ui_data.json' }
  let(:log_file) { '/tmp/admin_ui.log' }
  let(:stats_file) { '/tmp/admin_ui_stats.json' }

  let(:admin_user) { 'admin' }
  let(:admin_password) { 'admin_passw0rd' }

  let(:user) { 'user' }
  let(:user_password) { 'user_passw0rd' }

  let(:cloud_controller_uri) { 'http://api.localhost' }
  let(:config) do
    {
      :cloud_controller_uri   => cloud_controller_uri,
      :data_file              => data_file,
      :log_file               => log_file,
      :log_files              => [],
      :mbus                   => 'nats://nats:c1oudc0w@localhost:14222',
      :monitored_components   => ['ALL'],
      :port                   => port,
      :receiver_emails        => [],
      :sender_email           => { :account => 'system@localhost', :server => 'localhost' },
      :stats_file             => stats_file,
      :uaa_admin_credentials  => { :password => 'c1oudc0w', :username => 'admin' },
      :ui_admin_credentials   => { :password => admin_password, :username => admin_user },
      :ui_credentials         => { :password => user_password, :username => user }
    }
  end

  before do
    cc_stub(IBM::AdminUI::Config.load(config))
    nats_stub
    varz_stub

    ::WEBrick::Log.any_instance.stub(:log)

    Thread.new do
      IBM::AdminUI::Admin.new(config).start
    end

    @driver = Selenium::WebDriver.for :firefox
    @driver.manage.timeouts.implicit_wait = 5
  end

  after do
    @driver.quit

    Rack::Handler::WEBrick.shutdown

    Thread.list.each do |thread|
      unless thread == Thread.main
        thread.kill
        thread.join
      end
    end
    Process.wait(Process.spawn({}, "rm -fr #{ data_file } #{ log_file } #{ stats_file }"))
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
                            { :label => 'Created',         :tag =>   nil, :value => 'Oct 16, 2013 8:55:46 AM' },  # TODO: fix this...
                            { :label => 'Billing Enabled', :tag =>   nil, :value => cc_organizations['resources'][0]['entity']['billing_enabled'].to_s },
                            { :label => 'Spaces',          :tag =>   'a', :value => '1' }, # TODO: fix this...
                            { :label => 'Developers',      :tag =>   'a', :value => '1' }, # TODO: fix this...
                            { :label => 'Total Apps',      :tag =>   'a', :value => '1' }, # TODO: fix this...
                            { :label => 'Started Apps',    :tag =>   nil, :value => '1' }, # TODO: fix this...
                            { :label => 'Stopped Apps',    :tag =>   nil, :value => '1' }, # TODO: fix this...
                            { :label => 'Pending Apps',    :tag =>   nil, :value => '1' }, # TODO: fix this...
                            { :label => 'Staged Apps',     :tag =>   nil, :value => '1' }, # TODO: fix this...
                            { :label => 'Failed Apps',     :tag =>   nil, :value => '1' }  # TODO: fix this...                    
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
                            { :label => 'Created',      :tag =>   nil, :value => 'Oct 16, 2013 8:55:54 AM' }, # TODO: fix this...
                            { :label => 'Developers',   :tag =>   'a', :value => '1' },                       # TODO: fix this...
                            { :label => 'Total Apps',   :tag =>   'a', :value => '1' },                       # TODO: fix this...
                            { :label => 'Started Apps', :tag =>   nil, :value => '1' },                       # TODO: fix this...
                            { :label => 'Stopped Apps', :tag =>   nil, :value => '1' },                       # TODO: fix this...
                            { :label => 'Pending Apps', :tag =>   nil, :value => '1' },                       # TODO: fix this...
                            { :label => 'Staged Apps',  :tag =>   nil, :value => '1' },                       # TODO: fix this...
                            { :label => 'Failed Apps',  :tag =>   nil, :value => '1' }                        # TODO: fix this...
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
                            { :label => 'Started',         :tag =>   nil, :value => 'Oct 22, 2013 8:20:59 AM' }, # TODO: fix this...
                            { :label => 'URI',             :tag =>   'a', :value => "http://#{ varz_dea['instance_registry']['application1']['application1_instance1']['application_uris'][0] }" },
                            { :label => 'Buildpack',       :tag =>   nil, :value => cc_apps['resources'][0]['entity']['detected_buildpack'] },
                            { :label => 'Memory Reserved', :tag =>   nil, :value => cc_apps['resources'][0]['entity']['memory'].to_s },
                            { :label => 'Disk Reserved',   :tag =>   nil, :value => cc_apps['resources'][0]['entity']['disk_quota'].to_s },
                            { :label => 'Instance Index',  :tag =>   nil, :value => varz_dea['instance_registry']['application1']['application1_instance1']['instance_index'].to_s },
                            { :label => 'Instance State',  :tag =>   nil, :value => varz_dea['instance_registry']['application1']['application1_instance1']['state'] },
                            { :label => 'Services',        :tag =>   nil, :value => varz_dea['instance_registry']['application1']['application1_instance1']['services'].length.to_s },
                            { :label => 'Droplet Hash',    :tag =>   nil, :value => varz_dea['instance_registry']['application1']['application1_instance1']['droplet_sha1'].to_s },
                            { :label => 'Space',           :tag =>   'a', :value => cc_spaces['resources'][0]['entity']['name'] },        # TODO: fix this...
                            { :label => 'Organization',    :tag =>   'a', :value => cc_organizations['resources'][0]['entity']['name'] }, # TODO: fix this...
                            { :label => 'DEA',             :tag =>   'a', :value => nats_dea['host'] }                                    # TODO: fix this...
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
            check_details([
                            { :label => 'Email',        :tag => 'div', :value => "mailto:#{ uaa_users['resources'][0]['emails'][0]['value'] }" },
                            { :label => 'Created',      :tag =>   nil, :value => 'Oct 16, 2013 3:55:27 AM' }, # TODO fix this...
                            { :label => 'Modified',     :tag =>   nil, :value => 'undefined' },               # TODO fix this...
                            { :label => 'Authorities',  :tag =>   nil, :value => 'approvals.me, cloud_controller.admin, cloud_controller.read, cloud_controller.write, openid, password.write, scim.me, scim.read, scim.userids, scim.write, uaa.user' }, # TODO fix this...
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

=begin
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
                            { :label => 'Name',         :tag => nil, :value => '' },
                            { :label => 'URI',          :tag => 'a', :value => '' },
                            { :label => 'Host',         :tag => nil, :value => '' },
                            { :label => 'Started',      :tag => nil, :value => '' },
                            { :label => 'Uptime',       :tag => nil, :value => '' },
                            { :label => 'Apps',         :tag => 'a', :value => '' },
                            { :label => 'Cores',        :tag => nil, :value => '' },
                            { :label => 'CPU',          :tag => nil, :value => '' },
                            { :label => 'CPU Load Avg', :tag => nil, :value => '' },
                            { :label => 'Memory',       :tag => nil, :value => '' },
                            { :label => 'Memory Free',  :tag => nil, :value => '' },
                            { :label => 'Disk Free',    :tag => nil, :value => '' }
                          ])
          end
          it 'has applications link' do
            check_filter_link('DEAs', 5, 'Applications', '9.53.21.188:36364')
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
                            { :label => 'Name',             :tag => nil, :value => '' },
                            { :label => 'URI',              :tag => 'a', :value => '' },
                            { :label => 'Started',          :tag => nil, :value => '' },
                            { :label => 'Uptime',           :tag => nil, :value => '' },
                            { :label => 'Cores',            :tag => nil, :value => '' },
                            { :label => 'CPU',              :tag => nil, :value => '' },
                            { :label => 'Memory',           :tag => nil, :value => '' },
                            { :label => 'Requests',         :tag => nil, :value => '' },
                            { :label => 'Pending Requests', :tag => nil, :value => '' }
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
                            { :label => 'Name',              :tag => nil, :value => '' },
                            { :label => 'URI',               :tag => 'a', :value => '' },
                            { :label => 'Started',           :tag => nil, :value => '' },
                            { :label => 'Uptime',            :tag => nil, :value => '' },
                            { :label => 'Cores',             :tag => nil, :value => '' },
                            { :label => 'CPU',               :tag => nil, :value => '' },
                            { :label => 'Memory',            :tag => nil, :value => '' },
                            { :label => 'Users',             :tag => nil, :value => '' },
                            { :label => 'Applications',      :tag => nil, :value => '' },
                            { :label => 'Instances',         :tag => nil, :value => '' },
                            { :label => 'Running Instances', :tag => nil, :value => '' },
                            { :label => 'Crashed Instances', :tag => nil, :value => '' }
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
            check_details([
                            { :label => 'Name',                 :tag => nil, :value => '' },
                            { :label => 'URI',                  :tag => nil, :value => '' },
                            { :label => 'Supported Versions',   :tag => nil, :value => '' },
                            { :label => 'Description',          :tag => nil, :value => '' },
                            { :label => 'Started',              :tag => nil, :value => '' },
                            { :label => 'Uptime',               :tag => nil, :value => '' },
                            { :label => 'Cores',                :tag => nil, :value => '' },
                            { :label => 'CPU',                  :tag => nil, :value => '' },
                            { :label => 'Memory',               :tag => nil, :value => '' },
                            { :label => 'Provisioned Services', :tag => nil, :value => '' },
                            { :label => 'Available Capacity',   :tag => nil, :value => '' }
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
                            { :label => 'Name',          :tag => nil, :value => '' },
                            { :label => 'URI',           :tag => 'a', :value => '' },
                            { :label => 'Started',       :tag => nil, :value => '' },
                            { :label => 'Uptime',        :tag => nil, :value => '' },
                            { :label => 'Cores',         :tag => nil, :value => '' },
                            { :label => 'CPU',           :tag => nil, :value => '' },
                            { :label => 'Memory',        :tag => nil, :value => '' },
                            { :label => 'Droplets',      :tag => nil, :value => '' },
                            { :label => 'Requests',      :tag => nil, :value => '' },
                            { :label => 'Bad Requests',  :tag => nil, :value => '' },
                            { :label => '2XX Responses', :tag => nil, :value => '' },
                            { :label => '3XX Responses', :tag => nil, :value => '' },
                            { :label => '4XX Responses', :tag => nil, :value => '' },
                            { :label => '5XX Responses', :tag => nil, :value => '' },
                            { :label => 'XXX Responses', :tag => nil, :value => '' }
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
                            { :label => 'Name',    :tag => nil, :value => '' },
                            { :label => 'Type',    :tag => nil, :value => '' },
                            { :label => 'Started', :tag => nil, :value => '' },
                            { :label => 'URI',     :tag => 'a', :value => '' },
                            { :label => 'State',   :tag => nil, :value => '' }
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
        it 'has contents' do
          row = get_first_row
          row.click
          columns = row.find_elements(:tag_name => 'td')
          expect(columns.length).to eq(3)
#          expect(columns[0].text).to eq('')
#          expect(columns[1].text).to eq('')
#          expect(columns[2].text).to eq('')
          expect(@driver.find_element(:id => 'LogContainer').displayed?).to be_true
          expect(@driver.find_element(:id => 'LogLink').text).to eq(columns[0].text)
#          expect(@driver.find_element(:id => 'LogContents').text).to eq('')
        end
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
=end
    end
  end
end
