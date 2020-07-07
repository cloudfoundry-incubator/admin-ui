require 'net/smtp'
require_relative '../spec_helper'

module SMTPHelper
  attr_reader :smtp_start,
              :smtp_send_message

  def smtp_stub(config, disconnected_components)
    @smtp_start              = false
    @smtp_send_message       = false
    @disconnected_components = disconnected_components

    allow(::Net::SMTP).to receive(:start) do |server, port, domain, account, secret, authtype, &blk|
      expect(server).to eq(config.sender_email_server)
      expect(port).to eq(config.sender_email_port)
      expect(domain).to eq(config.sender_email_domain)
      expect(account).to eq(config.sender_email_account)
      expect(secret).to eq(config.sender_email_secret)
      expect(authtype).to eq(config.sender_email_authtype)

      blk.call(::Net::SMTP.new(server, port))

      @smtp_start = true
    end

    allow_any_instance_of(::Net::SMTP).to receive(:send_message) do |_smtp, email, sender_email_account, receiver_emails|
      expect(sender_email_account).to eq(config.sender_email_account)
      expect(receiver_emails).to eq(config.receiver_emails)

      expect(email.include?(config.sender_email_account)).to be(true)

      config.receiver_emails.each do |receiver_email|
        expect(email.include?(receiver_email)).to be(true)
      end

      expect(email.include?(config.cloud_controller_uri)).to be(true)

      if @disconnected_components.length == 1
        expect(email.include?('is down')).to be(true)
        expect(email.include?('Multiple Cloud Foundry components are down')).to be(false)
      elsif @disconnected_components.length > 1
        expect(email.include?('is down')).to be(false)
        expect(email.include?('Multiple Cloud Foundry components are down')).to be(true)
      end

      @disconnected_components.each do |disconnected_component|
        expect(email.include?(disconnected_component['type'])).to be(true)
        expect(email.include?(disconnected_component['uri'])).to be(true)
      end

      @smtp_send_message = true
    end
  end
end
