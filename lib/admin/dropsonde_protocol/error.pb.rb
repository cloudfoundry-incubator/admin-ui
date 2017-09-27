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
  class Error < ::Protobuf::Message; end


  ##
  # File Options
  #
  set_option :java_package, "org.cloudfoundry.dropsonde.events"
  set_option :java_outer_classname, "ErrorFactory"


  ##
  # Message Fields
  #
  class Error
    required :string, :source, 1
    required :int32, :code, 2
    required :string, :message, 3
  end

end

