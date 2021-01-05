require 'fileutils'
require 'selenium-webdriver'

RSpec.configure do |config|
  firefox_exists = false
  begin
    firefox_exists = File.exist?(Selenium::WebDriver::Firefox::Binary.path)
  rescue
  end
  config.filter_run_excluding firefox_available: true unless firefox_exists
end

shared_context :web_context do
  let(:current_date)  { (Time.now.to_f * 1000).to_i }
  let(:directory)     { '/tmp/admin_ui_directory' }
  let(:implicit_wait) { 5 }
  let(:stat_count)    { 1 }
  let(:stat_date)     { 1_383_238_113_597 }

  def cleanup_web_helper_files
    Process.wait(Process.spawn({}, "rm -fr #{directory}"))
  end

  before do
    cleanup_web_helper_files
    FileUtils.mkdir_p(directory)

    @driver = selenium_web_driver
    @driver.manage.timeouts.implicit_wait = implicit_wait

    allow(AdminUI::Utils).to receive(:time_in_milliseconds) do
      current_date
    end
  end

  after do
    @driver.quit

    cleanup_web_helper_files
  end

  def selenium_web_driver
    if ENV['TRAVIS']
      access_key        = ENV['SAUCE_ACCESS_KEY']
      build_number      = ENV['TRAVIS_BUILD_NUMBER']
      tunnel_identifier = ENV['TRAVIS_JOB_NUMBER']
      username          = ENV['SAUCE_USERNAME']

      caps = Selenium::WebDriver::Remote::Capabilities.firefox(marionette: true,
                                                               build: build_number,
                                                               'tunnel-identifier' => tunnel_identifier)

      url = "http://#{username}:#{access_key}@localhost:4445/wd/hub"
      client = Selenium::WebDriver::Remote::Http::Default.new
      client.timeout = 600
      Selenium::WebDriver.for(:remote,
                              http_client:          client,
                              desired_capabilities: caps,
                              url:                  url)
    else
      profile = Selenium::WebDriver::Firefox::Profile.new
      profile['browser.download.dir']                     = directory
      profile['browser.download.folderList']              = 2
      profile['browser.helperApps.neverAsk.saveToDisk']   = 'application/pdf, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, text/csv'
      profile['pdfjs.disabled']                           = true
      profile['browser.startup.homepage_override.mstone'] = 'ignore'
      profile['startup.homepage_welcome_url.additional']  = 'about:blank'

      options = Selenium::WebDriver::Firefox::Options.new
      options.profile = profile
      options.headless!

      # TODO: Temporary workaround for ruby 3.0.0
      # Selenium::WebDriver.for(:firefox, marionette: true, options: options)
      Selenium::WebDriver::Firefox::Driver.new(marionette: true, options: options)
    end
  rescue => error
    unless url.nil?
      puts "Trying to connect to: #{url.gsub(access_key, '<access_key>')}"
      puts "Caps : #{caps.inspect}"
    end
    puts "Error: #{error.inspect}"
    puts error.backtrace.join("\n")
    raise error
  end

  def check_details(expected_properties)
    expect(Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.find_element(id: "#{tab_id}DetailsLabel").displayed? }).to be(true)
    properties = Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.find_elements(xpath: "//div[@id='#{tab_id}PropertiesContainer']/table/tr[*]/td[1]") }
    values     = Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.find_elements(xpath: "//div[@id='#{tab_id}PropertiesContainer']/table/tr[*]/td[2]") }
    property_index = 0
    expected_properties.each do |expected_property|
      expect(properties[property_index].text).to eq("#{expected_property[:label]}:")
      value = if expected_property[:tag].nil?
                values[property_index].text
              elsif expected_property[:tag] == 'img'
                values[property_index].find_element(tag_name: 'div').attribute('innerHTML')
              else
                values[property_index].find_element(tag_name: expected_property[:tag]).text
              end
      expect(value).to eq(expected_property[:value])
      property_index += 1
    end
  end

  def check_filter_link(tab_id, link_index, target_tab_id, expected_filter)
    # TODO: Behavior of selenium-webdriver. Entire item must be displayed for it to click. Workaround following two lines after commented out code
    # Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.find_elements(xpath: "//div[@id='#{tab_id}PropertiesContainer']/table/tr[*]/td[2]")[link_index].find_element(tag_name: 'a').click }
    element = @driver.find_elements(xpath: "//div[@id='#{tab_id}PropertiesContainer']/table/tr[*]/td[2]")[link_index].find_element(tag_name: 'a')
    @driver.execute_script('arguments[0].click();', element)

    expect(Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.find_element(class_name: 'menuItemSelected').attribute('id') }).to eq(target_tab_id)
    expect(Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.find_element(id: target_tab_id).displayed? }).to eq(true)
    expect(Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.find_element(id: "#{target_tab_id}Table_filter").find_element(tag_name: 'input').attribute('value') }).to eq(expected_filter)
  end

  def check_stats_chart(id)
    begin
      Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.find_element(id: "#{id}Chart").displayed? }
    rescue Selenium::WebDriver::Error::TimeoutError, Selenium::WebDriver::Error::StaleElementReferenceError
    end
    chart = @driver.find_element(id: "#{id}Chart")
    expect(chart.displayed?).to be(true)
    rows = chart.find_elements(xpath: "//table[@class='jqplot-table-legend']/tr")
    expect(rows[0].text).to eq('Organizations')
    expect(rows[1].text).to eq('Spaces')
    expect(rows[2].text).to eq('Users')
    expect(rows[3].text).to eq('Apps')
    expect(rows[4].text).to eq('Total Instances')
    expect(rows[5].text).to eq('Running Instances')
    expect(chart.find_elements(class_name: 'jqplot-series-canvas').length).to eq(6)
  end

  def check_stats_table(id, application_instance_source)
    check_table_layout([
                         {
                           columns:         @driver.find_elements(xpath: "//div[@id='#{id}TableContainer']/div/div[4]/div/div/table/thead/tr[1]/th"),
                           expected_length: 3,
                           labels:          ['', 'Instances', ''],
                           colspans:        %w[5 2 2]
                         },
                         {
                           columns:         @driver.find_elements(xpath: "//div[@id='#{id}TableContainer']/div/div[4]/div/div/table/thead/tr[2]/th"),
                           expected_length: 9,
                           labels:          %w[Date Organizations Spaces Users Apps Total Running DEAs Cells],
                           colspans:        nil
                         }
                       ])
    stat_count_string = stat_count.to_s
    check_table_data(@driver.find_elements(xpath: "//table[@id='#{id}Table']/tbody/tr/td"),
                     [
                       nil,
                       stat_count_string,
                       stat_count_string,
                       stat_count_string,
                       stat_count_string,
                       stat_count_string,
                       stat_count_string,
                       application_instance_source == :doppler_dea ? stat_count_string : nil,
                       application_instance_source == :doppler_cell ? stat_count_string : nil
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

  def check_table_headers(head_row)
    expect(head_row[:columns]).to_not be_nil
    expect(head_row[:columns].length).to eq(head_row[:expected_length])
    column_index = 0
    while column_index < head_row[:expected_length]
      expect(head_row[:columns][column_index].text).to eq(head_row[:labels][column_index])
      expect(head_row[:columns][column_index].attribute('colspan')).to eq(head_row[:colspans][column_index]) unless head_row[:colspans].nil?
      column_index += 1
    end
  end

  def check_table_layout(columns_array)
    expect(@driver.find_element(id: "#{tab_id}Table").displayed?).to be(true)
    columns_array.each do |columns|
      check_table_headers(columns)
    end
  end

  def login(title)
    @driver.get "http://#{host}:#{port}"
    Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.title == title }
  end

  def select_first_row
    @driver.find_elements(xpath: "//table[@id='#{tab_id}Table']/tbody/tr/td")[0].click
  end

  def scroll_tab_into_view(id, verify_deas_tab_selected = false)
    if verify_deas_tab_selected
      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          @driver.find_element(class_name: 'menuItemSelected').attribute('id') == 'DEAs'
        end
      rescue Selenium::WebDriver::Error::TimeoutError
      end
      expect(@driver.find_element(class_name: 'menuItemSelected').attribute('id')).to eq('DEAs')
    end

    element = @driver.find_element(id: id)
    expect(element).to_not be_nil
    return element if element.displayed?

    left = @driver.find_element(id: 'MenuButtonLeft')
    10.times do
      left.click
      return element if element.displayed?
    end
    right = @driver.find_element(id: 'MenuButtonRight')
    10.times do
      right.click
      return element if element.displayed?
    end
    element
  end

  def click_tab(id, verify_deas_tab_selected = false)
    if verify_deas_tab_selected
      begin
        Selenium::WebDriver::Wait.new(timeout: 5).until do
          @driver.find_element(class_name: 'menuItemSelected').attribute('id') == 'DEAs'
        end
      rescue Selenium::WebDriver::Error::TimeoutError
      end
      expect(@driver.find_element(class_name: 'menuItemSelected').attribute('id')).to eq('DEAs')
    end

    element = @driver.find_element(id: id)
    expect(element).to_not be_nil

    # TODO: Behavior of selenium-webdriver. Entire item must be displayed for it to click. Workaround following after commented out code
    # element.click
    @driver.execute_script('arguments[0].click();', element)

    begin
      Selenium::WebDriver::Wait.new(timeout: 5).until do
        @driver.find_element(class_name: 'menuItemSelected').attribute('id') == tab_id
      end
    rescue Selenium::WebDriver::Error::TimeoutError
    end
    expect(@driver.find_element(class_name: 'menuItemSelected').attribute('id')).to eq(tab_id)
  end
end
