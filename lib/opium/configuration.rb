require 'gem_config'

module Opium
  include GemConfig::Base
  
  with_configuration do
    has :app_id, classes: String
    has :api_key, classes: String
  end
end