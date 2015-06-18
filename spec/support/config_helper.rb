require_relative '../spec_helper'

module ConfigHelper
  def config_stub
    allow_any_instance_of(AdminUI::Config).to receive(:validate)
  end
end
