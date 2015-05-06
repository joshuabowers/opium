require 'opium/model/relation'

module Opium
  module Model
    module Relatable
      extend ActiveSupport::Concern
      
      module ClassMethods
        def relations
          @relations ||= {}.with_indifferent_access
        end
        
        def has_and_belongs_to_many( relation_name, options = {} )
          relations[relation_name] = nil
        end
        
        def has_many( relation_name, options = {} )
          relations[relation_name] = nil
          field relation_name, type: Relation
        end
        
        def has_one( relation_name, options = {} )
          relations[relation_name] = nil
        end
        
        def belongs_to( relation_name, options = {} )
          relations[relation_name] = nil
        end
      end
    end
  end
end