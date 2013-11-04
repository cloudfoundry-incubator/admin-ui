require 'logger'
require_relative '../spec_helper'

describe AdminUI::EMail do
  include SMTPHelper

  let(:log_file) { '/tmp/admin_ui.log' }
  let(:logger) { Logger.new(log_file) }
  let(:disconnected_component) { [{ 'type' => 'DEA', 'uri' => 'http://bogus/dea' }] }
  let(:disconnected_components) do
    [
      { 'type' => 'CloudController', 'uri' => 'http://bogus/cloud_controller' },
      { 'type' => 'Router', 'uri' => 'http://bogus/router' }
    ]
  end

  before do
    AdminUI::Config.any_instance.stub(:validate)
  end

  after do
    Process.wait(Process.spawn({}, "rm -fr #{ log_file }"))
  end

  context 'Not configured' do
    let(:config) { AdminUI::Config.load({}) }
    let(:email) { AdminUI::EMail.new(config, logger) }

    before do
      smtp_stub(config, disconnected_components)
    end

    it 'is not configured' do
      expect(email.configured?).to be_false
    end

    it 'does not send email because not configured even though disconnected components present' do
      email.send_email(disconnected_components)
      expect(smtp_start).to be_false
      expect(smtp_send_message).to be_false
    end
  end

  context 'Configured' do
    let(:config) do
      AdminUI::Config.load(:cloud_controller_uri => 'http://api.bogus',
                           :receiver_emails      => ['receiver1@bogus.com', 'receiver2@foo.com'],
                           :sender_email         => { :account => 'bogus@bogus.com', :server => 'bogus.com' })

    end
    let(:email) { AdminUI::EMail.new(config, logger) }

    context 'No disconnected components' do
      before do
        smtp_stub(config, [])
      end

      it 'is configued' do
        expect(email.configured?).to be_true
      end

      it 'does not send email because no disconnected components' do
        email.send_email([])
        expect(smtp_start).to be_false
        expect(smtp_send_message).to be_false
      end
    end

    context 'Disconnected component present' do
      before do
        smtp_stub(config, disconnected_component)
      end

      it 'sends email because disconnected component present' do
        email.send_email(disconnected_component)
        expect(smtp_start).to be_true
        expect(smtp_send_message).to be_true
      end
    end

    context 'Disconnected components present' do
      before do
        smtp_stub(config, disconnected_components)
      end

      it 'sends email because disconnected components present' do
        email.send_email(disconnected_components)
        expect(smtp_start).to be_true
        expect(smtp_send_message).to be_true
      end
    end
  end
end
