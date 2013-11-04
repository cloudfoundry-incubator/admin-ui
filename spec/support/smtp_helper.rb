require 'net/smtp'
require_relative '../spec_helper'

module SMTPHelper
  attr_reader :smtp_start
  attr_reader :smtp_send_message

  def smtp_stub(config, disconnected_components)
    @smtp_start              = false
    @smtp_send_message       = false
    @disconnected_components = disconnected_components

    ::Net::SMTP.stub(:start) do |server, &blk|
      expect(server).to eq(config.sender_email_server)

      blk.call(::Net::SMTP.new(server))

      @smtp_start = true
    end

    ::Net::SMTP.any_instance.stub(:send_message) do |email, sender_email_account, receiver_emails|
      expect(sender_email_account).to eq(config.sender_email_account)
      expect(receiver_emails).to eq(config.receiver_emails)

      expect(email.include?(config.sender_email_account)).to be_true

      config.receiver_emails.each do |receiver_email|
        expect(email.include?(receiver_email)).to be_true
      end

      expect(email.include?(config.cloud_controller_uri)).to be_true

      if @disconnected_components.length == 1
        expect(email.include?('is down')).to be_true
        expect(email.include?('Multiple Cloud Foundry components are down')).to be_false
      elsif @disconnected_components.length > 1
        expect(email.include?('is down')).to be_false
        expect(email.include?('Multiple Cloud Foundry components are down')).to be_true
      end

      @disconnected_components.each do |disconnected_component|
        expect(email.include?(disconnected_component['type'])).to be_true
        expect(email.include?(disconnected_component['uri'])).to be_true
      end

      @smtp_send_message = true
    end
  end
end
