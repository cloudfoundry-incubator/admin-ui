# encoding: utf-8

##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf'


##
# Imports
#
require 'http.pb'
require 'log.pb'
require 'metric.pb'
require 'error.pb'

module Events
  ::Protobuf::Optionable.inject(self) { ::Google::Protobuf::FileOptions }

  ##
  # Message Classes
  #
  class Envelope < ::Protobuf::Message
    class EventType < ::Protobuf::Enum
      define :HttpStartStop, 4
      define :LogMessage, 5
      define :ValueMetric, 6
      define :CounterEvent, 7
      define :Error, 8
      define :ContainerMetric, 9
    end

  end



  ##
  # File Options
  #
  set_option :java_package, "org.cloudfoundry.dropsonde.events"
  set_option :java_outer_classname, "EventFactory"


  ##
  # Message Fields
  #
  class Envelope
    required :string, :origin, 1
    required ::Events::Envelope::EventType, :eventType, 2
    optional :int64, :timestamp, 6
    optional :string, :deployment, 13
    optional :string, :job, 14
    optional :string, :index, 15
    optional :string, :ip, 16
    optional ::Events::HttpStartStop, :httpStartStop, 7
    optional ::Events::LogMessage, :logMessage, 8
    optional ::Events::ValueMetric, :valueMetric, 9
    optional ::Events::CounterEvent, :counterEvent, 10
    optional ::Events::Error, :error, 11
    optional ::Events::ContainerMetric, :containerMetric, 12
  end

end

