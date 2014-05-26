require 'active_support/concern'
require 'opium/model/naming'
require 'opium/model/callbacks'
require 'opium/model/validations'
require 'opium/model/serialization'
require 'opium/model/dirty'

module Opium
  module Model
    extend ActiveSupport::Concern
            
    included do
    end
    
    include Naming
    include Callbacks
    include Validations
    include Serialization
    include Dirty
    
    module ClassMethods
      
    end
    
    def initialize( attributes = {} )
      self.attributes = attributes
    end
    
    def attributes
      @attributes
    end
    
    def attributes=(value)
      @attributes = ActiveSupport::HashWithIndifferentAccess.new value
    end
  end
end