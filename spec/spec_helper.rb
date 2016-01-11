require_relative '../lib/admin'
require_relative '../lib/admin/cc'
require_relative '../lib/admin/cc_rest_client'
require_relative '../lib/admin/cc_rest_client_response_error'
require_relative '../lib/admin/config'
require_relative '../lib/admin/login'
require_relative '../lib/admin/nats'
require_relative '../lib/admin/operation'
require_relative '../lib/admin/utils'
require_relative '../lib/admin/varz'

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |file| require file }

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib', 'admin', 'dropsonde_protocol')
require 'envelope.pb.rb'

RSpec.configure do |rspec|
  rspec.raise_errors_for_deprecations!

  # TODO: This block is needed to set rspec v3 compatibility.  Not needed when move is made to rspec v3
  rspec.mock_with :rspec do |mocks|
    mocks.yield_receiver_to_any_instance_implementation_blocks = true
  end
end
