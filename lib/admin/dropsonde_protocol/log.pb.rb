# encoding: utf-8

##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf'

module Events
  ::Protobuf::Optionable.inject(self) { ::Google::Protobuf::FileOptions }

  ##
  # Message Classes
  #
  class LogMessage < ::Protobuf::Message
    class MessageType < ::Protobuf::Enum
      define :OUT, 1
      define :ERR, 2
    end

  end



  ##
  # File Options
  #
  set_option :java_package, "org.cloudfoundry.dropsonde.events"
  set_option :java_outer_classname, "LogFactory"


  ##
  # Message Fields
  #
  class LogMessage
    required :bytes, :message, 1
    required ::Events::LogMessage::MessageType, :message_type, 2
    required :int64, :timestamp, 3
    optional :string, :app_id, 4
    optional :string, :source_type, 5
    optional :string, :source_instance, 6
  end

end

