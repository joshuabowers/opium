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

begin
  require 'kaminari'
  puts 'loaded kaminari'
rescue LoadError
end

require 'pry'
require 'rspec/its'
require 'webmock/rspec'
require 'opium'

I18n.config.enforce_available_locales = true