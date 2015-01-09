module Opium
  module Model
    class Criteria
      include Opium::Model::Queryable::ClassMethods
      class_attribute :models
      self.models = {}.with_indifferent_access
      
      def initialize( model_name )
        @model_name = model_name
      end
      
      attr_reader :model_name
      
      def model
        models[model_name] ||= model_name.constantize
      end
      
      def chain
        Marshal.load( Marshal.dump( self ) )
      end
      
      def constraints
        @constraints ||= {}.with_indifferent_access
      end
      
      def update_constraint( constraint, value )
        chain.tap do |c|
          c.constraints[constraint] = value if c.constraints[constraint].nil? || !value.is_a?( Hash )
          if c.constraints[constraint].is_a?(Hash) || value.is_a?(Hash)
            c.constraints[constraint].deep_merge!( value )
          end
        end
      end
      
      def empty?
        constraints.empty?
      end
      
      def criteria
        self
      end
      
      def ==( other )
        other.is_a?( self.class ) && self.model_name == other.model_name && self.constraints == other.constraints
      end
      
      def to_parse
        {}.with_indifferent_access.tap do |result|
          result[:query] = { where: constraints[:where], className: model_name } if constraints[:where]
          result[:key] = constraints[:keys] if constraints[:keys]
        end
      end
    end
  end
end