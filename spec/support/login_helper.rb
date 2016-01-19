require_relative '../spec_helper'

module LoginHelper
  LOGIN_ADMIN = 'admin'.freeze
  LOGIN_USER  = 'user'.freeze

  def login_stub_admin
    login_stub_common
    allow_any_instance_of(AdminUI::Login).to receive(:login_user) do
      [LOGIN_ADMIN, AdminUI::Login::LOGIN_ADMIN]
    end
  end

  def login_stub_user
    login_stub_common

    allow_any_instance_of(AdminUI::Login).to receive(:login_user) do
      [LOGIN_USER, AdminUI::Login::LOGIN_USER]
    end
  end

  def login_stub_fail
    login_stub_common

    allow_any_instance_of(AdminUI::Login).to receive(:login_user) do
      ['bogus', nil]
    end
  end

  private

  def login_stub_common
    allow_any_instance_of(AdminUI::Login).to receive(:logout) do |_login, redirect_uri|
      redirect_uri
    end

    allow_any_instance_of(AdminUI::Login).to receive(:login_redirect_uri) do |_login, redirect_uri|
      redirect_uri
    end
  end
end
