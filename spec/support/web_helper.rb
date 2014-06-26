require 'selenium-webdriver'

RSpec.configure do |config|
  firefox_exists = false
  begin
    firefox_exists = File.exist?(Selenium::WebDriver::Firefox::Binary.path)
  rescue
  end
  config.filter_run_excluding :firefox_available => true unless firefox_exists
end

shared_context :web_context do
  let(:stat_date) { 1_383_238_113_597 }
  let(:current_date) { (Time.now.to_f * 1000).to_i }
  let(:stat_count) { 1 }

  before do
    @driver = selenium_web_driver
    @driver.manage.timeouts.implicit_wait = 360

    AdminUI::Utils.stub(:time_in_milliseconds) do
      current_date
    end
  end

  after do
    @driver.quit
  end

  def selenium_web_driver
    return  Selenium::WebDriver.for(:firefox) unless ENV['TRAVIS']

    access_key        = ENV['SAUCE_ACCESS_KEY']
    build_number      = ENV['TRAVIS_BUILD_NUMBER']
    tunnel_identifier = ENV['TRAVIS_JOB_NUMBER']
    username          = ENV['SAUCE_USERNAME']

    caps = Selenium::WebDriver::Remote::Capabilities.new(
        :browser_name       => 'firefox',
        :build              => build_number,
        'tunnel-identifier' => tunnel_identifier)

    url = "http://#{ username }:#{ access_key }@localhost:4445/wd/hub"
    client = Selenium::WebDriver::Remote::Http::Default.new
    client.timeout = 600
    Selenium::WebDriver.for(:remote,
                            :http_client => client,
                            :desired_capabilities => caps,
                            :url => url)
  rescue => error
    unless url.nil?
      puts "Trying to connect to: #{ url.gsub(access_key, '<access_key>') }"
      puts "Caps : #{ caps.inspect }"
    end
    puts "Error: #{ error.inspect }"
    puts error.backtrace.join("\n")
    raise error
  end

  def check_details(expected_properties)
    expect(Selenium::WebDriver::Wait.new(:timeout => 360).until { @driver.find_element(:id => "#{ tab_id }DetailsLabel").displayed? }).to be_true
    properties = Selenium::WebDriver::Wait.new(:timeout => 360).until { @driver.find_elements(:xpath => "//div[@id='#{ tab_id }PropertiesContainer']/table/tr[*]/td[1]") }
    values     = Selenium::WebDriver::Wait.new(:timeout => 360).until { @driver.find_elements(:xpath => "//div[@id='#{ tab_id }PropertiesContainer']/table/tr[*]/td[2]") }
    property_index = 0
    expected_properties.each do |expected_property|
      expect(properties[property_index].text).to eq("#{ expected_property[:label] }:")
      if expected_property[:tag].nil?
        value = values[property_index].text
      elsif  expected_property[:tag] == 'img'
        value = values[property_index].find_element(:tag_name => 'div').attribute('innerHTML')
      else
        value = values[property_index].find_element(:tag_name => expected_property[:tag]).text
      end
      expect(value).to eq(expected_property[:value])
      property_index += 1
    end
  end

  def check_filter_link(tab_id, link_index, target_tab_id, expected_filter)
    Selenium::WebDriver::Wait.new(:timeout => 360).until { @driver.find_elements(:xpath => "//div[@id='#{ tab_id }PropertiesContainer']/table/tr[*]/td[2]")[link_index].find_element(:tag_name => 'a').click }
    expect(Selenium::WebDriver::Wait.new(:timeout => 360).until { @driver.find_element(:class_name => 'menuItemSelected').attribute('id') }).to eq(target_tab_id)
    expect(Selenium::WebDriver::Wait.new(:timeout => 360).until { @driver.find_element(:id => "#{ target_tab_id }Table_filter").find_element(:tag_name => 'input').attribute('value') }).to eq(expected_filter)
  end

  def check_stats_chart(id)
    # As the page refreshes, we need to catch the stale element error and re-find the element on the page
    begin
      Selenium::WebDriver::Wait.new(:timeout => 10).until { @driver.find_element(:id => "#{ id }Chart").displayed? }
    rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::StaleElementReferenceError
    end
    chart = @driver.find_element(:id => "#{ id }Chart")
    expect(chart.displayed?).to be_true
    rows = chart.find_elements(:xpath => "//table[@class='jqplot-table-legend']/tbody/tr")
    expect(rows[0].text).to eq('Organizations')
    expect(rows[1].text).to eq('Spaces')
    expect(rows[2].text).to eq('Users')
    expect(rows[3].text).to eq('Apps')
    expect(rows[4].text).to eq('Total Instances')
    expect(rows[5].text).to eq('Running Instances')
    expect(chart.find_elements(:class_name => 'jqplot-series-canvas').length).to eq(6)
  end

  def check_stats_table(id)
    check_table_layout([{ :columns         => @driver.find_elements(:xpath => "//div[@id='#{ id }TableContainer']/div/div[6]/div[1]/div/table/thead/tr[1]/th"),
                          :expected_length => 3,
                          :labels          => ['', 'Instances', ''],
                          :colspans        => %w(5 2 1)
                        },
                        {
                          :columns         => @driver.find_elements(:xpath => "//div[@id='#{ id }TableContainer']/div/div[6]/div[1]/div/table/thead/tr[2]/th"),
                          :expected_length => 8,
                          :labels          => %w(Date Organizations Spaces Users Apps Total Running DEAs),
                          :colspans        => nil
                        }
                       ])
    stat_count_string = stat_count.to_s
    check_table_data(@driver.find_elements(:xpath => "//table[@id='#{ id }Table']/tbody/tr/td"),
                     [
                       nil,
                       stat_count_string,
                       stat_count_string,
                       stat_count_string,
                       stat_count_string,
                       stat_count_string,
                       stat_count_string,
                       stat_count_string
                     ])
  end

  def check_table_data(cells, expected_values)
    index = 0
    while index < expected_values.length
      # Cannot check all values due to date-related stubbing order dependencies for logs/stats
      expect(cells[index].text).to eq(expected_values[index]) if expected_values[index]
      index += 1
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

  def check_table_layout(columns_array)
    expect(@driver.find_element(:id => "#{ tab_id }Table").displayed?).to be_true
    columns_array.each do |columns|
      check_table_headers(columns)
    end
  end

  def first_row
    @driver.find_elements(:xpath => "//table[@id='#{ tab_id }Table']/tbody/tr")[0]
  end

  def login(username, password, target_page)
    @driver.get "http://#{ host }:#{ port }"
    @driver.find_element(:id => 'username').send_keys username
    @driver.find_element(:id => 'password').send_keys password
    @driver.find_element(:id => 'username').submit
    Selenium::WebDriver::Wait.new(:timeout => 5).until { @driver.title == target_page }
  end

  def select_first_row
    first_row.click
  end
end
