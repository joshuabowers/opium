module Opium
  module Model
    class Relation
      class << self
        def to_parse( object )
          class_name =
            case object
            when Hash
              fetch_hash_key_from( object, 'class_name' ) || fetch_hash_key_from( object, 'model_name' )
            when String, Symbol
              object
            when Opium::Model
              object.model_name
            when self
              object.class_name
            else
              fail ArgumentError, "could not convert #{ object.inspect } to a parse Relation hash"
            end
          fail ArgumentError, "could not determine class_name from #{ object.inspect }" unless class_name
          { __type: 'Relation', className: class_name }.with_indifferent_access
        end
        
        def to_ruby( object )
          return unless object.present?
          return object if object.is_a? self
          class_name = 
            case object
            when Hash
              fetch_hash_key_from( object, 'class_name' ) || fetch_hash_key_from( object, 'model_name' )
            when String, Symbol
              object
            when Opium::Model
              object.model_name
            else
              fail ArgumentError, "could not convert #{ object.inspect } to a Opium::Model::Relation"
            end
          new( class_name )
        end
        
        private 
        
        def fetch_hash_key_from( hash, key )
          snake_case_key = key.to_s.underscore
          lower_camel_key = key.to_s.camelcase(:lower)
          
          hash[ snake_case_key ] || hash[ snake_case_key.to_sym ] || hash[ lower_camel_key ] || hash[ lower_camel_key.to_sym ]
        end
      end
      
      def initialize( class_name )
        self.class_name = class_name.to_s
      end
      
      def to_parse
        self.class.to_parse self
      end
      
      attr_accessor :class_name
      
      alias_method :model_name, :class_name
      alias_method :model_name=, :class_name=
    end
  end
end