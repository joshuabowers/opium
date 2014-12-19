require 'active_support/concern'
require 'active_support/core_ext/string'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/inflector'
require 'opium/model/naming'
require 'opium/model/connectable'
require 'opium/model/persistable'
require 'opium/model/callbacks'
require 'opium/model/validations'
require 'opium/model/serialization'
require 'opium/model/dirty'
require 'opium/model/fieldable'
require 'opium/model/attributable'
require 'opium/model/criteria'
require 'opium/model/queryable'
require 'opium/model/scopable'

module Opium
  module Model
    extend ActiveSupport::Concern
            
    def initialize( attributes = {} )
      self.attributes = attributes
      reset_changes
    end
        
    include Naming
    include Connectable
    include Persistable
    include Validations
    include Dirty
    include Fieldable
    include Serialization
    include Attributable
    include Queryable
    include Callbacks
    include Scopable
            
    def inspect
      inspected_fields = self.attributes.map {|k, v| [k, v.inspect].join(': ')}.join(', ')
      "#<#{self.class.model_name} #{inspected_fields}>"
    end
  end
end