require 'active_support/concern'
require 'opium/model/naming'
require 'opium/model/callbacks'
require 'opium/model/validations'

module Opium
  module Model
    extend ActiveSupport::Concern
            
    included do
    end
    
    include Naming
    include Callbacks
    include Validations
    
    def ClassMethods
      
    end
  end
end