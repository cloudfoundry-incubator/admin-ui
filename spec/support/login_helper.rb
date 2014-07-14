require_relative '../spec_helper'

module LoginHelper
  def login_stub_admin
    login_stub_common

    AdminUI::Login.any_instance.stub(:login_user) do
      ['admin', AdminUI::Login::LOGIN_ADMIN]
    end
  end

  def login_stub_user
    login_stub_common

    AdminUI::Login.any_instance.stub(:login_user) do
      ['user', AdminUI::Login::LOGIN_USER]
    end
  end

  def login_stub_fail
    login_stub_common

    AdminUI::Login.any_instance.stub(:login_user) do
      ['bogus', nil]
    end
  end

  private

  def login_stub_common
    AdminUI::Login.any_instance.stub(:logout) do |redirect_uri|
      redirect_uri
    end

    AdminUI::Login.any_instance.stub(:login_redirect_uri) do |redirect_uri|
      redirect_uri
    end
  end
end
