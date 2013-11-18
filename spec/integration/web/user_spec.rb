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
      @driver.find_element(:id => 'DEAs').click
      expect(@driver.find_element(:class_name => 'menuItemSelected').attribute('id')).to eq('DEAs')
      expect(@driver.find_element(:id => 'DEAsPage').displayed?).to be_true
      expect(@driver.find_element(:id => 'ToolTables_DEAsTable_0').text).to eq('Copy')
    end

    it 'does not have a remove all components button' do
      @driver.find_element(:id => 'Components').click
      expect(@driver.find_element(:class_name => 'menuItemSelected').attribute('id')).to eq('Components')
      expect(@driver.find_element(:id => 'ComponentsPage').displayed?).to be_true
      expect(@driver.find_element(:id => 'ToolTables_ComponentsTable_0').text).to eq('Copy')
    end

    it 'does not have a tasks tab' do
      expect(@driver.find_element(:id => 'Tasks').displayed?).to be_false
    end

    it 'does not have a create stats button' do
      @driver.find_element(:id => 'Stats').click
      expect(@driver.find_element(:class_name => 'menuItemSelected').attribute('id')).to eq('Stats')
      expect(@driver.find_element(:id => 'StatsPage').displayed?).to be_true
      expect(@driver.find_element(:id => 'ToolTables_StatsTable_0').text).to eq('Copy')
    end
  end
end
