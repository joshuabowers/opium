module Opium
  module Model
    class Criteria
      include Opium::Model::Queryable::ClassMethods
      
      def initialize( model_name )
        @model_name = model_name
      end
      
      attr_reader :model_name
      
      def model
        @model ||= @model_name.constantize
      end
      
      def constraints
        @constraints ||= {}.with_indifferent_access
      end
      
      def update_constraint( constraint, value )
        self.tap do
          constraints[constraint] = value if constraints[constraint].nil? || !value.is_a?( Hash )
          if constraints[constraint].is_a?(Hash) || value.is_a?(Hash)
            constraints[constraint].deep_merge!( value )
          end
        end
      end
      
      def empty?
        constraints.empty?
      end
      
      def criteria
        Marshal.load(Marshal.dump(self))
      end
      
      def ==( other )
        other.is_a?( self.class ) && self.constraints == other.constraints
      end
    end
  end
end