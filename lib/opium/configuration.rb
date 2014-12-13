require 'gem_config'

module Opium
  include GemConfig::Base
  
  with_configuration do
    has :app_id, classes: String, default: 'abc123'
    has :api_key, classes: String, default: 'abc123'
    has :log_network_responses, default: false
  end
end