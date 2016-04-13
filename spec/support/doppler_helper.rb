require 'eventmachine'
require 'faye/websocket'
require 'time'
require_relative '../spec_helper'
require_relative 'cc_helper'

module DopplerHelper
  include CCHelper

  BILLION = 1000 * 1000 * 1000

  ANALYZER_VALUE_METRICS =
    {
      'memoryStats.lastGCPauseTimeNS'         => 2_189_668.0,
      'memoryStats.numBytesAllocated'         => 548_968.0,
      'memoryStats.numBytesAllocatedHeap'     => 548_968.0,
      'memoryStats.numBytesAllocatedStack'    => 655_360.0,
      'memoryStats.numFrees'                  => 131_746.0,
      'memoryStats.numMallocs'                => 134_926.0,
      'NumberOfAppsWithAllInstancesReporting' => 1.0,
      'NumberOfAppsWithMissingInstances'      => 0.0,
      'NumberOfCrashedIndices'                => 0.0,
      'NumberOfCrashedInstances'              => 0.0,
      'NumberOfDesiredApps'                   => 1.0,
      'NumberOfDesiredAppsPendingStaging'     => 0.0,
      'NumberOfDesiredInstances'              => 1.0,
      'NumberOfMissingIndices'                => 0.0,
      'NumberOfRunningInstances'              => 1.0,
      'NumberOfUndesiredRunningApps'          => 0.0,
      'numCPUS'                               => 4.0,
      'numGoRoutines'                         => 56.0
    }.freeze

  DEA_VALUE_METRICS =
    {
      'instances'        => 1.0,
      'remaining_disk'   => 30_904.0,
      'remaining_memory' => 7_208.0
    }.freeze

  DOPPLER_SERVER_VALUE_METRICS =
    {
      'memoryStats.lastGCPauseTimeNS'       => 3_553_637.0,
      'memoryStats.numBytesAllocated'       => 2_052_480.0,
      'memoryStats.numBytesAllocatedHeap'   => 2_052_480.0,
      'memoryStats.numBytesAllocatedStack'  => 720_896.0,
      'memoryStats.numFrees'                => 1_225_251.0,
      'memoryStats.numMallocs'              => 1_268_441.0,
      'messageRouter.numberOfFirehoseSinks' => 1.0,
      'numCPUS'                             => 4.0,
      'numGoRoutines'                       => 58.0,
      'Uptime'                              => 1_080.0
    }.freeze

  GOROUTER_VALUE_METRICS =
    {
      'latency'                            => 15.0,
      'memoryStats.lastGCPauseTimeNS'      => 2_446_180.0,
      'memoryStats.numBytesAllocated'      => 2_779_272.0,
      'memoryStats.numBytesAllocatedHeap'  => 2_779_272.0,
      'memoryStats.numBytesAllocatedStack' => 589_824.0,
      'memoryStats.numFrees'               => 58_275.0,
      'memoryStats.numMallocs'             => 61_227.0,
      'ms_since_last_registry_update'      => 14_011.0,
      'numCPUS'                            => 4.0,
      'numGoRoutines'                      => 44.0,
      'total_routes'                       => 11.0
    }.freeze

  REP_VALUE_METRICS =
    {
      'CapacityRemainingContainers'        => 252.0,
      'CapacityRemainingDisk'              => 298_155.0,
      'CapacityRemainingMemory'            => 31_152.0,
      'CapacityTotalContainers'            => 256.0,
      'CapacityTotalDisk'                  => 302_251.0,
      'CapacityTotalMemory'                => 32_112.0,
      'ContainerCount'                     => 4.0,
      'logSenderTotalMessagesRead'         => 681_827.0,
      'memoryStats.lastGCPauseTimeNS'      => 1_998_215.0,
      'memoryStats.numBytesAllocated'      => 1_828_904.0,
      'memoryStats.numBytesAllocatedHeap'  => 1_828_904.0,
      'memoryStats.numBytesAllocatedStack' => 2_113_536.0,
      'memoryStats.numFrees'               => 1_027_475_681.0,
      'memoryStats.numMallocs'             => 1_027_488_288.0,
      'numCPUS'                            => 4.0,
      'numGoRoutines'                      => 345.0,
      'RepBulkSyncDuration'                => 4_595_018.0
    }.freeze

  class MockWebSocketClient < Faye::WebSocket::Client
    def initialize
      # Don't call super
    end
  end

  def doppler_stub(application_instance_source)
    @close_blk = nil

    @time = Time.now

    allow(Faye::WebSocket::Client).to receive(:new).and_return(MockWebSocketClient.new)

    allow_any_instance_of(MockWebSocketClient).to receive(:close) do
      return unless @close_blk
      EventMachine.next_tick { @close_blk.call(Faye::WebSocket::API::Event.create('close', code: 1006, reason: 'no reason')) }
    end

    allow_any_instance_of(MockWebSocketClient).to receive(:on).with(:open) do |_event, &blk|
      EventMachine.next_tick { blk.call(Faye::WebSocket::API::Event.create('open')) }
    end

    allow_any_instance_of(MockWebSocketClient).to receive(:on).with(:error)

    allow_any_instance_of(MockWebSocketClient).to receive(:on).with(:message) do |_event, &blk|
      if application_instance_source == :doppler_cell
        REP_VALUE_METRICS.each_pair do |value_metric_key, value_metric_value|
          EventMachine.next_tick { blk.call(event(rep_value_metric_envelope(value_metric_key, value_metric_value))) }
        end

        EventMachine.next_tick { blk.call(event(rep_container_metric_envelope)) }
      elsif application_instance_source == :doppler_dea
        ANALYZER_VALUE_METRICS.each_pair do |value_metric_key, value_metric_value|
          EventMachine.next_tick { blk.call(event(analyzer_value_metric_envelope(value_metric_key, value_metric_value))) }
        end

        DEA_VALUE_METRICS.each_pair do |value_metric_key, value_metric_value|
          EventMachine.next_tick { blk.call(event(dea_value_metric_envelope(value_metric_key, value_metric_value))) }
        end

        GOROUTER_VALUE_METRICS.each_pair do |value_metric_key, value_metric_value|
          EventMachine.next_tick { blk.call(event(gorouter_value_metric_envelope(value_metric_key, value_metric_value))) }
        end

        EventMachine.next_tick { blk.call(event(dea_container_metric_envelope)) }
      end

      # We need at least one value metric for the doppler-retrieving code to be considered working
      DOPPLER_SERVER_VALUE_METRICS.each_pair do |value_metric_key, value_metric_value|
        EventMachine.next_tick { blk.call(event(doppler_server_value_metric_envelope(value_metric_key, value_metric_value))) }
      end
    end

    allow_any_instance_of(MockWebSocketClient).to receive(:on).with(:close) do |_event, &blk|
      @close_blk = blk
    end
  end

  def analyzer_envelope
    envelope           = Events::Envelope.new
    envelope.index     = '1'
    envelope.ip        = '10.10.10.10'
    envelope.origin    = 'analyzer'
    envelope.timestamp = @time.to_i * BILLION

    envelope
  end

  def dea_envelope
    envelope           = Events::Envelope.new
    envelope.index     = '2'
    envelope.ip        = '10.10.10.11'
    envelope.origin    = 'DEA'
    envelope.timestamp = @time.to_i * BILLION

    envelope
  end

  def doppler_server_envelope
    envelope           = Events::Envelope.new
    envelope.index     = '3'
    envelope.ip        = '10.10.10.12'
    envelope.origin    = 'DopplerServer'
    envelope.timestamp = @time.to_i * BILLION

    envelope
  end

  def gorouter_envelope
    envelope           = Events::Envelope.new
    envelope.index     = '4'
    envelope.ip        = '10.10.10.13'
    envelope.origin    = 'gorouter'
    envelope.timestamp = @time.to_i * BILLION

    envelope
  end

  def rep_envelope
    envelope           = Events::Envelope.new
    envelope.index     = '5'
    envelope.ip        = '10.10.10.14'
    envelope.origin    = 'rep'
    envelope.timestamp = @time.to_i * BILLION

    envelope
  end

  def dea_container_metric_envelope
    envelope                 = dea_envelope
    envelope.eventType       = Events::Envelope::EventType::ContainerMetric
    envelope.containerMetric = container_metric(0.0018560986278165663, 178_135_040, 134_434_816)

    envelope
  end

  def rep_container_metric_envelope
    envelope                 = rep_envelope
    envelope.eventType       = Events::Envelope::EventType::ContainerMetric
    envelope.containerMetric = container_metric(0.178232960961232, 75_057_856, 34_292_160)

    envelope
  end

  def analyzer_value_metric_envelope(key, value)
    envelope             = analyzer_envelope
    envelope.eventType   = Events::Envelope::EventType::ValueMetric
    envelope.valueMetric = value_metric(key, value)

    envelope
  end

  def dea_value_metric_envelope(key, value)
    envelope             = dea_envelope
    envelope.eventType   = Events::Envelope::EventType::ValueMetric
    envelope.valueMetric = value_metric(key, value)

    envelope
  end

  def doppler_server_value_metric_envelope(key, value)
    envelope             = doppler_server_envelope
    envelope.eventType   = Events::Envelope::EventType::ValueMetric
    envelope.valueMetric = value_metric(key, value)

    envelope
  end

  def gorouter_value_metric_envelope(key, value)
    envelope             = gorouter_envelope
    envelope.eventType   = Events::Envelope::EventType::ValueMetric
    envelope.valueMetric = value_metric(key, value)

    envelope
  end

  def rep_value_metric_envelope(key, value)
    envelope             = rep_envelope
    envelope.eventType   = Events::Envelope::EventType::ValueMetric
    envelope.valueMetric = value_metric(key, value)

    envelope
  end

  def container_metric(cpu_percentage, memory_bytes, disk_bytes)
    container_metric               = Events::ContainerMetric.new
    container_metric.applicationId = cc_app[:guid]
    container_metric.instanceIndex = cc_app_instance_index
    container_metric.cpuPercentage = cpu_percentage
    container_metric.memoryBytes   = memory_bytes
    container_metric.diskBytes     = disk_bytes

    container_metric
  end

  def value_metric(key, value)
    value_metric       = Events::ValueMetric.new
    value_metric.name  = key
    value_metric.unit  = 'unit'
    value_metric.value = value

    value_metric
  end

  def event(envelope)
    serialized_to_string = envelope.serialize_to_string

    chars = []
    serialized_to_string.each_char { |character| chars.push(character) }

    Faye::WebSocket::API::Event.create('message', data: chars)
  end
end
