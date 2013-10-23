
require 'rubygems'
require 'selenium-webdriver'

describe 'AdminUI' do

  before(:all) do
    @driver = Selenium::WebDriver.for :firefox
    @driver.manage.timeouts.implicit_wait = 5
  end

  after(:all) do
    @driver.quit
  end

  context 'Login' do
    before(:each) do
      @driver.get 'http://localhost:8070/'
      @driver.find_element(:id => 'username').send_keys 'admin'
    end

    def wait_for_page
      @driver.find_element(:id => 'username').submit
      Selenium::WebDriver::Wait.new(:timeout => 5)
    end

    it 'Invalid Credentials' do
      @driver.find_element(:id => 'password').send_keys 'pass'
      wait_for_page.until { @driver.title == 'Login' }
    end

    it 'Valid Credentials' do
      @driver.find_element(:id => 'password').send_keys 'passw0rd'
      wait_for_page.until { @driver.title == 'Administration' }
    end
  end

  context 'Main' do
    it 'Title' do
      expect(@driver.find_element(:class => 'cloudControllerText').text.length).to be > 0
    end

    it 'Tabs' do
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

    it 'Refresh' do
      expect(@driver.find_element(:id => 'RefreshButton').displayed?).to be_true
    end

    it 'User' do
      expect(@driver.find_element(:class => 'userContainer').displayed?).to be_true
      expect(@driver.find_element(:class => 'user').text.length).to be > 0
    end
  end

  context 'Tabs' do
    def check_tab(id)
      @driver.find_element(:id => id).click
      expect(@driver.find_element(:class_name => 'menuItemSelected').attribute('id')).to eq(id)
      expect(@driver.find_element(:id => "#{ id }Page").displayed?).to be_true
    end

    def check_table(id, columns_array)
      expect(@driver.find_element(:id => "#{ id }Table").displayed?).to be_true
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

    def check_details(id, expected_properties)
      @driver.find_elements(:xpath => "//table[@id='#{ id }Table']/tbody/tr")[0].click
      expect(@driver.find_element(:id => "#{ id }DetailsLabel").displayed?).to be_true
      properties = @driver.find_elements(:xpath => "//div[@id='#{ id }PropertiesContainer']/table/tr[*]/td[1]")
      values     = @driver.find_elements(:xpath => "//div[@id='#{ id }PropertiesContainer']/table/tr[*]/td[2]")
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

    def check_filter_link(tab_id, link_index, target_tab_id, expected_filter)
      @driver.find_elements(:xpath => "//div[@id='#{ tab_id }PropertiesContainer']/table/tr[*]/td[2]")[link_index].find_element(:tag_name => 'a').click
      expect(@driver.find_element(:class_name => 'menuItemSelected').attribute('id')).to eq(target_tab_id)
      expect(@driver.find_element(:id => "#{ target_tab_id }Table_filter").find_element(:tag_name => 'input').attribute('value')).to eq(expected_filter)
      @driver.find_element(:id => "#{ target_tab_id }Table_filter").find_element(:tag_name => 'img').click
      @driver.find_element(:id => tab_id).click
    end

    def check_select_link(tab_id, link_index, target_tab_id, expected_name)
      @driver.find_elements(:xpath => "//div[@id='#{ tab_id }PropertiesContainer']/table/tr[*]/td[2]")[link_index].find_element(:tag_name => 'a').click
      expect(@driver.find_element(:class_name => 'menuItemSelected').attribute('id')).to eq(target_tab_id)
      expect(@driver.find_element(:xpath => "//table[@id='#{ target_tab_id }Table']/tbody/tr[contains(@class, 'DTTT_selected')]/td[1]").text).to eq(expected_name)
      expect(@driver.find_element(:id => "#{ target_tab_id }DetailsLabel").displayed?).to be_true
      expect(@driver.find_elements(:xpath => "//div[@id='#{ target_tab_id }PropertiesContainer']/table/tr[*]/td[2]")[0].text).to eq(expected_name)
      @driver.find_elements(:xpath => "//table[@id='#{ target_tab_id }Table']/tbody/tr")[0].click
      @driver.find_element(:id => tab_id).click
    end

    context 'Organizations' do
      it 'Tab' do
        check_tab('Organizations')
      end
      it 'Table' do
        check_table('Organizations',
                    [
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
      it 'Details' do
        check_details('Organizations',
                      [
                        { :label => 'Name',            :tag => 'div', :value => '' },
                        { :label => 'Status',          :tag =>   nil, :value => '' },
                        { :label => 'Created',         :tag =>   nil, :value => '' },
                        { :label => 'Billing Enabled', :tag =>   nil, :value => '' },
                        { :label => 'Spaces',          :tag =>   'a', :value => '' },
                        { :label => 'Developers',      :tag =>   'a', :value => '' },
                        { :label => 'Total Apps',      :tag =>   'a', :value => '' },
                        { :label => 'Started Apps',    :tag =>   nil, :value => '' },
                        { :label => 'Stopped Apps',    :tag =>   nil, :value => '' },
                        { :label => 'Pending Apps',    :tag =>   nil, :value => '' },
                        { :label => 'Staged Apps',     :tag =>   nil, :value => '' },
                        { :label => 'Failed Apps',     :tag =>   nil, :value => '' }
                      ])
      end
      it 'Links' do
        check_filter_link('Organizations', 4, 'Spaces',       '')
        check_filter_link('Organizations', 5, 'Developers',   '')
        check_filter_link('Organizations', 6, 'Applications', '')
      end
    end
    context 'Spaces' do
      it 'Tab' do
        check_tab('Spaces')
      end
      it 'Table' do
        check_table('Spaces',
                    [
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
      it 'Details' do
        check_details('Spaces',
                      [
                        { :label => 'Name',         :tag => 'div', :value => '' },
                        { :label => 'Organization', :tag =>   'a', :value => '' },
                        { :label => 'Created',      :tag =>   nil, :value => '' },
                        { :label => 'Developers',   :tag =>   'a', :value => '' },
                        { :label => 'Total Apps',   :tag =>   'a', :value => '' },
                        { :label => 'Started Apps', :tag =>   nil, :value => '' },
                        { :label => 'Stopped Apps', :tag =>   nil, :value => '' },
                        { :label => 'Pending Apps', :tag =>   nil, :value => '' },
                        { :label => 'Staged Apps',  :tag =>   nil, :value => '' },
                        { :label => 'Failed Apps',  :tag =>   nil, :value => '' }
                      ])
      end
      it 'Links' do
        check_select_link('Spaces', 1, 'Organizations', '')
        check_filter_link('Spaces', 3, 'Developers',    '')
        check_filter_link('Spaces', 4, 'Applications',  '')
      end
    end

    context 'Applications' do
      it 'Tab' do
        check_tab('Applications')
      end
      it 'Table' do
        check_table('Applications',
                    [
                      {
                        :columns         => @driver.find_elements(:xpath => "//div[@id='ApplicationsTableContainer']/div/div[5]/div[1]/div/table/thead/tr/th"),
                        :expected_length => 14,
                        :labels          => ['Name', 'State', "Package\nState", 'Started', 'URI', 'Buildpack', 'Memory', 'Disk', 'Instance', 'Services', 'Space', 'Organization', 'Target', 'DEA'],
                        :colspans        => nil
                      }
                    ])
      end
      it 'Details' do
        check_details('Applications',
                      [
                        { :label => 'Name',            :tag => 'div', :value => '' },
                        { :label => 'State',           :tag =>   nil, :value => '' },
                        { :label => 'Started',         :tag =>   nil, :value => '' },
                        { :label => 'URI',             :tag =>   'a', :value => '' },
                        { :label => 'Buildpack',       :tag =>   nil, :value => '' },
                        { :label => 'Memory Reserved', :tag =>   nil, :value => '' },
                        { :label => 'Disk Reserved',   :tag =>   nil, :value => '' },
                        { :label => 'Instance Index',  :tag =>   nil, :value => '' },
                        { :label => 'Instance State',  :tag =>   nil, :value => '' },
                        { :label => 'Services',        :tag =>   nil, :value => '' },
                        { :label => 'Droplet Hash',    :tag =>   nil, :value => '' },
                        { :label => 'Space',           :tag =>   'a', :value => '' },
                        { :label => 'Organization',    :tag =>   'a', :value => '' },
                        { :label => 'DEA',             :tag =>   'a', :value => '' }
                      ])
      end
      it 'Services' do
        expect(@driver.find_element(:id => 'ApplicationsServicesDetailsLabel').displayed?).to be_true
        check_table_headers(:columns         => @driver.find_elements(:xpath => "//div[@id='ApplicationsServicesTableContainer']/div[2]/div[5]/div[1]/div/table/thead/tr/th"),
                            :expected_length => 5,
                            :labels          => ['Instance Name', 'Provider', 'Service Name', 'Version', 'Plan Name'],
                            :colspans        => nil)
      end
      it 'Links' do
        check_select_link('Applications', 11, 'Spaces',        '')
        check_select_link('Applications', 12, 'Organizations', '')
        check_select_link('Applications', 13, 'DEAs',          '')
      end
    end

    context 'Developers' do
      it 'Tab' do
        check_tab('Developers')
      end
      it 'Table' do
        check_table('Developers',
                    [
                      {
                        :columns         => @driver.find_elements(:xpath => "//div[@id='DevelopersTableContainer']/div/div[5]/div[1]/div/table/thead/tr/th"),
                        :expected_length => 5,
                        :labels          => %w(Email Space Organization Target Created),
                        :colspans        => nil
                      }
                    ])
      end
      it 'Details' do
        check_details('Developers',
                      [
                        { :label => 'Email',        :tag => 'div', :value => '' },
                        { :label => 'Created',      :tag =>   nil, :value => '' },
                        { :label => 'Modified',     :tag =>   nil, :value => '' },
                        { :label => 'Authorities',  :tag =>   nil, :value => '' },
                        { :label => 'Space',        :tag =>   'a', :value => '' },
                        { :label => 'Organization', :tag =>   'a', :value => '' }
                      ])
      end
      it 'Links' do
        check_select_link('Developers', 4, 'Spaces',        '')
        check_select_link('Developers', 5, 'Organizations', '')
      end
    end

    context 'DEAs' do
      it 'Tab' do
        check_tab('DEAs')
      end
      it 'Table' do
        check_table('DEAs',
                    [
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
      it 'Details' do
        check_details('DEAs',
                      [
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
      it 'Links' do
        check_filter_link('DEAs', 5, 'Applications', '')
      end
    end

    context 'Cloud Controllers' do
      it 'Tab' do
        check_tab('CloudControllers')
      end
      it 'Table' do
        check_table('CloudControllers',
                    [
                      {
                        :columns         => @driver.find_elements(:xpath => "//div[@id='CloudControllersTableContainer']/div/div[5]/div[1]/div/table/thead/tr/th"),
                        :expected_length => 6,
                        :labels          => %w(Name State Started Cores CPU Memory),
                        :colspans        => nil
                      }
                    ])
      end
      it 'Details' do
        check_details('CloudControllers',
                      [
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

    context 'Health Managers' do
      it 'Tab' do
        check_tab('HealthManagers')
      end
      it 'Table' do
        check_table('HealthManagers',
                    [
                      {
                        :columns         => @driver.find_elements(:xpath => "//div[@id='HealthManagersTableContainer']/div/div[5]/div[1]/div/table/thead/tr/th"),
                        :expected_length => 9,
                        :labels          => %w(Name State Started Cores CPU Memory Users Applications Instances),
                        :colspans        => nil
                      }
                    ])
      end
      it 'Details' do
        check_details('HealthManagers',
                      [
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

    context 'Service Gateways' do
      it 'Tab' do
        check_tab('Gateways')
      end
      it 'Table' do
        check_table('Gateways',
                    [
                      {
                        :columns         => @driver.find_elements(:xpath => "//div[@id='GatewaysTableContainer']/div/div[5]/div[1]/div/table/thead/tr/th"),
                        :expected_length => 10,
                        :labels          => ['Name', 'State', 'Started', 'Description', 'CPU', 'Memory', 'Nodes', "Provisioned\nServices", "Available\nCapacity", "% Available\nCapacity"],
                        :colspans        => nil
                      }
                    ])
      end
      it 'Details' do
        check_details('Gateways',
                      [
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
      it 'Nodes' do
        expect(@driver.find_element(:id => 'GatewaysNodesDetailsLabel').displayed?).to be_true
        check_table_headers(:columns         => @driver.find_elements(:xpath => "//div[@id='GatewaysNodesTableContainer']/div[2]/div[5]/div[1]/div/table/thead/tr/th"),
                            :expected_length => 2,
                            :labels          => ['Name', 'Available Capacity'],
                            :colspans        => nil)
      end
    end

    context 'Routers' do
      it 'Tab' do
        check_tab('Routers')
      end
      it 'Table' do
        check_table('Routers',
                    [
                      {
                        :columns         => @driver.find_elements(:xpath => "//div[@id='RoutersTableContainer']/div/div[5]/div[1]/div/table/thead/tr/th"),
                        :expected_length => 9,
                        :labels          => ['Name', 'State', 'Started', 'Cores', 'CPU', 'Memory', 'Droplets', 'Requests', 'Bad Requests'],
                        :colspans        => nil
                      }
                    ])
      end
      it 'Details' do
        check_details('Routers',
                      [
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

    context 'Components' do
      it 'Tab' do
        check_tab('Components')
      end
      it 'Table' do
        check_table('Components',
                    [
                      {
                        :columns         => @driver.find_elements(:xpath => "//div[@id='ComponentsTableContainer']/div/div[5]/div[1]/div/table/thead/tr/th"),
                        :expected_length => 4,
                        :labels          => %w(Name Type State Started),
                        :colspans        => nil
                      }
                    ])
      end
      it 'Details' do
        check_details('Components',
                      [
                        { :label => 'Name',    :tag => nil, :value => '' },
                        { :label => 'Type',    :tag => nil, :value => '' },
                        { :label => 'Started', :tag => nil, :value => '' },
                        { :label => 'URI',     :tag => 'a', :value => '' },
                        { :label => 'State',   :tag => nil, :value => '' }
                      ])
      end
    end

    context 'Logs' do
      it 'Tab' do
        check_tab('Logs')
      end
      it 'Table' do
        check_table('Logs',
                    [
                      {
                        :columns         => @driver.find_elements(:xpath => "//div[@id='LogsTableContainer']/div/div[5]/div[1]/div/table/thead/tr/th"),
                        :expected_length => 3,
                        :labels          => ['Path', 'Size', 'Last Modified'],
                        :colspans        => nil
                      }
                    ])
      end
      it 'Log' do
        rows = @driver.find_elements(:xpath => "//table[@id='LogsTable']/tbody/tr")
        unless rows.nil? || (rows.length == 0)
          rows[0].click
          columns = rows[0].find_elements(:tag_name => 'td')
          expect(columns.length).to eq(3)
          expect(columns[0].text).to eq('')
          expect(columns[1].text).to eq('')
          expect(columns[2].text).to eq('')
          expect(@driver.find_element(:id => 'LogContainer').displayed?).to be_true
          expect(@driver.find_element(:id => 'LogLink').text).to eq(columns[0].text)
          expect(@driver.find_element(:id => 'LogContents').text).to eq('')
        end
      end
    end

    context 'Tasks' do
      it 'Tab' do
        check_tab('Tasks')
      end
      it 'Table' do
        check_table('Tasks',
                    [
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
      it 'Tab' do
        check_tab('Stats')
      end
      it 'Table' do
        check_table('Stats',
                    [
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
      it 'Chart' do
        expect(@driver.find_element(:id => 'StatsChart').displayed?).to be_true
      end
    end
  end
end
