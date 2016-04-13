require 'logger'
require_relative '../spec_helper'

describe AdminUI::Doppler do
  include ConfigHelper

  let(:doppler_data_file) { '/tmp/admin_ui_doppler_data.json' }
  let(:log_file)          { '/tmp/admin_ui.log' }

  let(:config) do
    AdminUI::Config.load(doppler_data_file:       doppler_data_file,
                         doppler_rollup_interval: 1,
                         monitored_components:    [])
  end

  let(:client)             { AdminUI::CCRestClient.new(config, logger) }
  let(:doppler)            { AdminUI::Doppler.new(config, logger, client, email, true) }
  let(:email)              { AdminUI::EMail.new(config, logger) }
  let(:event_machine_loop) { AdminUI::EventMachineLoop.new(config, logger, true) }
  let(:logger)             { Logger.new(log_file) }

  before do
    config_stub
    event_machine_loop
  end

  after do
    doppler.shutdown
    event_machine_loop.shutdown

    doppler.join
    event_machine_loop.join

    Process.wait(Process.spawn({}, "rm -fr #{doppler_data_file} #{log_file}"))
  end

  context 'No backend connected' do
    it 'returns zero analyzers as expected' do
      expect(doppler.analyzers).to eq('connected' => false, 'items' => {})
    end

    it 'returns zero components as expected' do
      expect(doppler.components).to eq('connected' => false, 'items' => {})
    end

    it 'returns zero containers as expected' do
      expect(doppler.containers).to eq('connected' => false, 'items' => {})
    end

    it 'returns zero deas as expected' do
      expect(doppler.deas).to eq('connected' => false, 'items' => {})
    end

    it 'returns nil deas_count as expected' do
      expect(doppler.deas_count).to be_nil
    end

    it 'returns zero gorouters as expected' do
      expect(doppler.gorouters).to eq('connected' => false, 'items' => {})
    end

    it 'returns zero reps as expected' do
      expect(doppler.reps).to eq('connected' => false, 'items' => {})
    end

    it 'returns nil reps_count as expected' do
      expect(doppler.reps_count).to be_nil
    end
  end
end
