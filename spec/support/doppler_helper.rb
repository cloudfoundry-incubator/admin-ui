require 'eventmachine'
require 'faye/websocket'
require 'time'
require_relative '../spec_helper'
require_relative 'cc_helper'

module DopplerHelper
  include CCHelper

  BILLION = 1000 * 1000 * 1000

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

  def doppler_stub(include_application_instance)
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
      REP_VALUE_METRICS.each_pair do |value_metric_key, value_metric_value|
        EventMachine.next_tick { blk.call(event(rep_value_metric_envelope(value_metric_key, value_metric_value))) }
      end

      if include_application_instance
        EventMachine.next_tick { blk.call(event(rep_container_metric_envelope)) }
      end
    end

    allow_any_instance_of(MockWebSocketClient).to receive(:on).with(:close) do |_event, &blk|
      @close_blk = blk
    end
  end

  def rep_envelope
    envelope           = Events::Envelope.new
    envelope.index     = '4'
    envelope.ip        = '10.10.10.10'
    envelope.origin    = 'rep'
    envelope.timestamp = @time.to_i * BILLION

    envelope
  end

  def rep_container_metric_envelope
    container_metric               = Events::ContainerMetric.new
    container_metric.applicationId = cc_app[:guid]
    container_metric.instanceIndex = cc_app_instance_index
    container_metric.cpuPercentage = 0.178232960961232
    container_metric.memoryBytes   = 75_057_856
    container_metric.diskBytes     = 34_292_160

    envelope                 = rep_envelope
    envelope.eventType       = Events::Envelope::EventType::ContainerMetric
    envelope.containerMetric = container_metric

    envelope
  end

  def rep_value_metric_envelope(key, value)
    value_metric       = Events::ValueMetric.new
    value_metric.name  = key
    value_metric.unit  = 'unit'
    value_metric.value = value

    envelope             = rep_envelope
    envelope.eventType   = Events::Envelope::EventType::ValueMetric
    envelope.valueMetric = value_metric

    envelope
  end

  def event(envelope)
    serialized_to_string = envelope.serialize_to_string

    chars = []
    serialized_to_string.each_char { |character| chars.push(character) }

    Faye::WebSocket::API::Event.create('message', data: chars)
  end
end
