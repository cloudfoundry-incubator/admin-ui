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

  let(:application_instance_source) { :doppler_cell }
  let(:client)                      { AdminUI::CCRestClient.new(config, logger) }
  let(:doppler)                     { AdminUI::Doppler.new(config, logger, client, email, true) }
  let(:email)                       { AdminUI::EMail.new(config, logger) }
  let(:event_machine_loop)          { AdminUI::EventMachineLoop.new(config, logger, true) }
  let(:logger)                      { Logger.new(log_file) }

  def cleanup_files
    Process.wait(Process.spawn({}, "rm -fr #{ccdb_file} #{doppler_data_file} #{log_file} #{uaadb_file}"))
  end

  before do
    cleanup_files

    config_stub
    cc_stub(config)
    doppler_stub(application_instance_source)

    event_machine_loop
  end

  after do
    doppler.shutdown
    event_machine_loop.shutdown

    doppler.join
    event_machine_loop.join

    cleanup_files
  end

  def verify_container(envelope, key, value)
    expect(key).to eq("#{envelope.containerMetric.applicationId}:#{envelope.containerMetric.instanceIndex}")

    expect(value[:application_id]).to eq(envelope.containerMetric.applicationId)
    expect(value[:cpu_percentage]).to eq(envelope.containerMetric.cpuPercentage)
    expect(value[:disk_bytes]).to eq(envelope.containerMetric.diskBytes)
    expect(value[:index]).to eq(envelope.index)
    expect(value[:ip]).to eq(envelope.ip)
    expect(value[:memory_bytes]).to eq(envelope.containerMetric.memoryBytes)
    expect(value[:origin]).to eq(envelope.origin)
    expect(value[:timestamp]).to eq(envelope.timestamp)
  end

  def verify_component(envelope, metrics, key, value)
    expect(key).to eq("#{envelope.origin}:#{envelope.index}:#{envelope.ip}")

    expect(value['connected']).to be(true)
    expect(value['index']).to eq(envelope.index)
    expect(value['ip']).to eq(envelope.ip)
    expect(value['origin']).to eq(envelope.origin)
    expect(value['timestamp']).to eq(envelope.timestamp)

    metrics.each_pair do |value_metric_key, value_metric_value|
      expect(value).to include(value_metric_key => value_metric_value)
    end
  end

  context 'doppler cell' do
    it 'returns connected components' do
      components = doppler.components

      expect(components['connected']).to eq(true)
      items = components['items']

      expect(items.length).to be(2)

      rep_index             = nil
      doppler_server_index  = nil

      index = 0
      while index < items.length
        key = items.keys[index]
        if key.include?('DopplerServer')
          doppler_server_index = index
        elsif key.include?('rep')
          rep_index = index
        end
        index += 1
      end

      expect(doppler_server_index).to_not be_nil
      expect(rep_index).to_not be_nil

      verify_component(doppler_server_envelope, DopplerHelper::DOPPLER_SERVER_VALUE_METRICS, items.keys[doppler_server_index], items.values[doppler_server_index])
      verify_component(rep_envelope, DopplerHelper::REP_VALUE_METRICS, items.keys[rep_index], items.values[rep_index])
    end

    it 'returns connected containers' do
      containers = doppler.containers

      expect(containers['connected']).to eq(true)
      items = containers['items']

      expect(items.length).to be(1)

      verify_container(rep_container_metric_envelope, items.keys[0], items.values[0])
    end

    it 'returns connected deas' do
      deas = doppler.deas

      expect(deas['connected']).to eq(true)
      expect(deas['items'].length).to be(0)
    end

    it 'returns connected analyzers' do
      analyzers = doppler.analyzers

      expect(analyzers['connected']).to eq(true)
      expect(analyzers['items'].length).to be(0)
    end

    it 'returns connected reps' do
      reps = doppler.reps

      expect(reps['connected']).to eq(true)
      items = reps['items']

      expect(items.length).to be(1)

      verify_component(rep_envelope, DopplerHelper::REP_VALUE_METRICS, items.keys[0], items.values[0])
    end

    it 'returns deas_count' do
      expect(doppler.deas_count).to be(0)
    end

    it 'returns reps_count' do
      expect(doppler.reps_count).to be(1)
    end
  end

  context 'doppler dea' do
    let(:application_instance_source) { :doppler_dea }
    it 'returns connected analyzers' do
      analyzers = doppler.analyzers

      expect(analyzers['connected']).to eq(true)
      items = analyzers['items']

      expect(items.length).to be(1)

      verify_component(analyzer_envelope, DopplerHelper::ANALYZER_VALUE_METRICS, items.keys[0], items.values[0])
    end

    it 'returns connected components' do
      components = doppler.components

      expect(components['connected']).to eq(true)
      items = components['items']

      expect(items.length).to be(3)

      dea_index             = nil
      doppler_server_index  = nil
      analyzer_index        = nil

      index = 0
      while index < items.length
        key = items.keys[index]
        if key.include?('DEA')
          dea_index = index
        elsif key.include?('DopplerServer')
          doppler_server_index = index
        elsif key.include?('analyzer')
          analyzer_index = index
        end
        index += 1
      end

      expect(dea_index).to_not be_nil
      expect(doppler_server_index).to_not be_nil
      expect(analyzer_index).to_not be_nil

      verify_component(dea_envelope, DopplerHelper::DEA_VALUE_METRICS, items.keys[dea_index], items.values[dea_index])
      verify_component(doppler_server_envelope, DopplerHelper::DOPPLER_SERVER_VALUE_METRICS, items.keys[doppler_server_index], items.values[doppler_server_index])
      verify_component(analyzer_envelope, DopplerHelper::ANALYZER_VALUE_METRICS, items.keys[analyzer_index], items.values[analyzer_index])
    end

    it 'returns connected containers' do
      containers = doppler.containers

      expect(containers['connected']).to eq(true)
      items = containers['items']

      expect(items.length).to be(1)

      verify_container(dea_container_metric_envelope, items.keys[0], items.values[0])
    end

    it 'returns connected deas' do
      deas = doppler.deas

      expect(deas['connected']).to eq(true)
      items = deas['items']

      expect(items.length).to be(1)

      verify_component(dea_envelope, DopplerHelper::DEA_VALUE_METRICS, items.keys[0], items.values[0])
    end

    it 'returns connected reps' do
      reps = doppler.reps

      expect(reps['connected']).to eq(true)
      expect(reps['items'].length).to be(0)
    end

    it 'returns deas_count' do
      expect(doppler.deas_count).to be(1)
    end

    it 'returns reps_count' do
      expect(doppler.reps_count).to be(0)
    end
  end
end
