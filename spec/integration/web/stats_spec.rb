require 'rubygems'
require_relative '../../spec_helper'
require_relative '../../support/web_helper'

describe AdminUI::Admin, :type => :integration, :firefox_available => true do
  include_context :server_context
  include_context :web_context

  let(:tab_id) { 'Statistics' }

  before do
    add_stats
    @driver.get "http://#{ host }:#{ port }/stats"
    Selenium::WebDriver::Wait.new(:timeout => 5).until { @driver.title == 'Statistics' }
  end

  it 'has a table' do
    check_stats_table('Statistics')
  end

  it 'has a chart' do
    check_stats_chart('Statistics')
  end
end
