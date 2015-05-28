require 'active_support/concern'
require 'active_support/core_ext/string'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/hash/transform_values'
require 'active_support/inflector'
require 'opium/model/connectable'
require 'opium/model/persistable'
require 'opium/model/callbacks'
require 'opium/model/serialization'
require 'opium/model/dirty'
require 'opium/model/fieldable'
require 'opium/model/attributable'
require 'opium/model/queryable'
require 'opium/model/criteria'
require 'opium/model/scopable'
require 'opium/model/findable'
require 'opium/model/inheritable'
require 'opium/model/batchable'
require 'opium/model/relatable'
require 'opium/model/kaminari'

module Opium
  module Model
    extend ActiveSupport::Concern
        
    include ActiveModel::Model
    
    included do
      include Connectable
      include Persistable
      include Dirty
      include Fieldable
      include Serialization
      include Attributable
      include Queryable
      include Callbacks
      include Scopable
      include Findable
      include Inheritable
      include Batchable
      include Relatable
      include GlobalID if defined?( GlobalID )
    end
    
    def initialize( attributes = {} )
      self.attributes = attributes
    end
        
    def inspect
      inspected_fields = self.attributes.map {|k, v| [k, v.inspect].join(': ')}.join(', ')
      "#<#{self.class.model_name} #{inspected_fields}>"
    end
  end
end