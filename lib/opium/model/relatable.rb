require 'opium/model/relation'
require 'opium/model/reference'
require 'opium/model/relatable/metadata'

module Opium
  module Model
    module Relatable
      extend ActiveSupport::Concern
      
      module ClassMethods
        def relations
          @relations ||= {}.with_indifferent_access
        end
        
        def has_and_belongs_to_many( relation_name, options = {} )
          create_relation_metadata_from( :has_and_belongs_to_many, relation_name, options )
        end
        
        def has_many( relation_name, options = {} )
          create_relation_metadata_from( :has_many, relation_name, options )
          field relation_name, type: Relation, default: -> { relations[relation_name].target_class_name }
        end
        
        def has_one( relation_name, options = {} )
          create_relation_metadata_from( :has_one, relation_name, options )
        end
        
        def belongs_to( relation_name, options = {} )
          create_relation_metadata_from( :belongs_to, relation_name, options )
          field relation_name, type: Reference
        end
        
        private
        
        def create_relation_metadata_from( relation_type, relation_name, options )
          relations[relation_name] = Metadata.new( self, relation_type, relation_name, options )
        end
      end
    end
  end
end