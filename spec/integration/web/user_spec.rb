require 'rubygems'
require_relative '../../spec_helper'
require_relative '../../support/web_helper'

describe AdminUI::Admin, :type => :integration, :firefox_available => true do
  include_context :server_context
  include_context :web_context

  context 'authenticated' do
    before do
      login(user, user_password, 'Administration')
    end

    it 'does not have a create DEA button' do
      # Need to wait until the page has been rendered.
      # Move the click operation into the wait block to ensure the action has been taken, this is used to fit Travis CI system.
      begin
        Selenium::WebDriver::Wait.new(:timeout => 5).until do
          @driver.find_element(:id => 'DEAs').click
          @driver.find_element(:class_name => 'menuItemSelected').attribute('id') == 'DEAs'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(:class_name => 'menuItemSelected').attribute('id')).to eq('DEAs')

      begin
        Selenium::WebDriver::Wait.new(:timeout => 5).until { @driver.find_element(:id => 'DEAsPage').displayed? && @driver.find_element(:id => 'ToolTables_DEAsTable_0').text == 'Copy' }
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(:id => 'DEAsPage').displayed?).to eq(true)
      expect(@driver.find_element(:id => 'ToolTables_DEAsTable_0').text).to eq('Copy')
    end

    it 'does not have a remove all components button' do
      begin
        Selenium::WebDriver::Wait.new(:timeout => 5).until do
          @driver.find_element(:id => 'Components').click
          @driver.find_element(:class_name => 'menuItemSelected').attribute('id') == 'Components'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(:class_name => 'menuItemSelected').attribute('id')).to eq('Components')

      begin
        Selenium::WebDriver::Wait.new(:timeout => 5).until do
          @driver.find_element(:id => 'ComponentsPage').displayed? &&
          @driver.find_element(:id => 'ToolTables_ComponentsTable_0').text == 'Copy'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(:id => 'ComponentsPage').displayed?).to eq(true)
      expect(@driver.find_element(:id => 'ToolTables_ComponentsTable_0').text).to eq('Copy')
    end

    it 'does not have a tasks tab' do
      expect(@driver.find_element(:id => 'Tasks').displayed?).to be_false
    end

    it 'does not have a create stats button' do
      begin
        Selenium::WebDriver::Wait.new(:timeout => 5).until do
          @driver.find_element(:id => 'Stats').click
          @driver.find_element(:class_name => 'menuItemSelected').attribute('id') == 'Stats'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(:class_name => 'menuItemSelected').attribute('id')).to eq('Stats')

      begin
        Selenium::WebDriver::Wait.new(:timeout => 5).until do
          @driver.find_element(:id => 'StatsPage').displayed? &&
          @driver.find_element(:id => 'ToolTables_StatsTable_0').text == 'Copy'
        end
      rescue Selenium::WebDriver::Error::TimeOutError
      end
      expect(@driver.find_element(:id => 'StatsPage').displayed?).to eq(true)
      expect(@driver.find_element(:id => 'ToolTables_StatsTable_0').text).to eq('Copy')
    end
  end
end
