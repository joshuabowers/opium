require 'active_support/concern'
require 'active_support/core_ext/string'
require 'opium/model/naming'
require 'opium/model/persistable'
require 'opium/model/callbacks'
require 'opium/model/validations'
require 'opium/model/serialization'
require 'opium/model/dirty'
require 'opium/model/fieldable'
require 'opium/model/attributable'
require 'opium/model/queryable'

module Opium
  module Model
    extend ActiveSupport::Concern
            
    included do
    end
    
    include Naming
    include Persistable
    include Callbacks
    include Validations
    include Dirty
    include Fieldable
    include Serialization
    include Attributable
    include Queryable
    
    module ClassMethods
      
    end
    
    def initialize( attributes = {} )
      @attributes = ActiveSupport::HashWithIndifferentAccess.new
      self.attributes = self.class.default_attributes.merge( attributes )
    end
  end
end