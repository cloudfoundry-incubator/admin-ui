require 'logger'
require_relative '../spec_helper'

describe AdminUI::Doppler, type: :integration do
  include CCHelper
  include ConfigHelper
  include DopplerHelper

  let(:ccdb_file)         { '/tmp/admin_ui_ccdb.db' }
  let(:ccdb_uri)          { "sqlite://#{ccdb_file}" }
  let(:db_file)           { '/tmp/admin_ui_store.db' }
  let(:db_uri)            { "sqlite://#{db_file}" }
  let(:doppler_data_file) { '/tmp/admin_ui_doppler_data.json' }
  let(:log_file)          { '/tmp/admin_ui.log' }
  let(:uaadb_file)        { '/tmp/admin_ui_uaadb.db' }
  let(:uaadb_uri)         { "sqlite://#{uaadb_file}" }

  let(:config) do
    AdminUI::Config.load(ccdb_uri:                ccdb_uri,
                         db_uri:                  db_uri,
                         doppler_data_file:       doppler_data_file,
                         doppler_rollup_interval: 1,
                         monitored_components:    [],
                         uaadb_uri:               uaadb_uri)
  end

  let(:client)             { AdminUI::CCRestClient.new(config, logger) }
  let(:doppler)            { AdminUI::Doppler.new(config, logger, client, email, true) }
  let(:email)              { AdminUI::EMail.new(config, logger) }
  let(:event_machine_loop) { AdminUI::EventMachineLoop.new(config, logger, true) }
  let(:logger)             { Logger.new(log_file) }

  def cleanup_files
    Process.wait(Process.spawn({}, "rm -fr #{ccdb_file} #{doppler_data_file} #{log_file} #{uaadb_file}"))
  end

  before do
    cleanup_files

    config_stub
    cc_stub(config)
    doppler_stub

    event_machine_loop
  end

  after do
    doppler.shutdown
    event_machine_loop.shutdown

    doppler.join
    event_machine_loop.join

    cleanup_files
  end

  def verify_rep(key, value)
    envelope = rep_envelope

    expect(key).to eq("#{envelope.origin}:#{envelope.index}:#{envelope.ip}")

    expect(value['connected']).to be(true)
    expect(value['index']).to eq(envelope.index)
    expect(value['ip']).to eq(envelope.ip)
    expect(value['origin']).to eq(envelope.origin)
    expect(value['timestamp']).to eq(envelope.timestamp)

    DopplerHelper::REP_VALUE_METRICS.each_pair do |value_metric_key, value_metric_value|
      expect(value).to include(value_metric_key => value_metric_value)
    end
  end

  it 'returns connected components' do
    components = doppler.components

    expect(components['connected']).to eq(true)
    items = components['items']

    expect(items.length).to be(1)

    verify_rep(items.keys[0], items.values[0])
  end

  it 'returns connected reps' do
    reps = doppler.reps

    expect(reps['connected']).to eq(true)
    items = reps['items']

    expect(items.length).to be(1)

    verify_rep(items.keys[0], items.values[0])
  end

  it 'returns reps_count' do
    expect(doppler.reps_count).to be(1)
  end
end
