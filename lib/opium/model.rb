require 'active_support/concern'
require 'opium/model/naming'
require 'opium/model/callbacks'
require 'opium/model/validations'
require 'opium/model/serialization'
require 'opium/model/dirty'
require 'opium/model/fieldable'

module Opium
  module Model
    extend ActiveSupport::Concern
            
    included do
    end
    
    include Naming
    include Callbacks
    include Validations
    include Dirty
    include Fieldable
    include Serialization
    
    module ClassMethods
      
    end
    
    def initialize( attributes = {} )
      self.attributes = attributes
    end
    
    def attributes
      @attributes
    end
    
    def attributes=(value)
      @attributes = self.class.default_attributes.merge( value )
    end
  end
end