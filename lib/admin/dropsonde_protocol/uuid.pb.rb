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
  class UUID < ::Protobuf::Message; end


  ##
  # File Options
  #
  set_option :java_package, "org.cloudfoundry.dropsonde.events"
  set_option :java_outer_classname, "UuidFactory"


  ##
  # Message Fields
  #
  class UUID
    required :uint64, :low, 1
    required :uint64, :high, 2
  end

end

