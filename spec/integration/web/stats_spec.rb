require 'rubygems'
require_relative '../../spec_helper'
require_relative '../../support/web_helper'

describe AdminUI::Admin, type: :integration, firefox_available: true do
  include_context :server_context
  include_context :web_context

  let(:tab_id) { 'Statistics' }

  before do
    @driver.get "http://#{host}:#{port}/stats"
    Selenium::WebDriver::Wait.new(timeout: 5).until { @driver.title == 'Statistics' }
  end

  shared_examples 'it has a table' do
    it 'has a table' do
      check_stats_table('Statistics', application_instance_source)
    end
  end

  context 'doppler cell' do
    let(:application_instance_source) { :doppler_cell }
    it_behaves_like('it has a table')
  end

  context 'doppler dea' do
    it_behaves_like('it has a table')
  end

  it 'has a chart' do
    check_stats_chart('Statistics')
  end
end
