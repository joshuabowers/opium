require 'coveralls'
Coveralls.wear!

RSpec.configure do |config|
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

require 'pry'
require 'rspec/its'
require 'webmock/rspec'
require 'opium'