module Opium
  module Model
    class Criteria
      include Opium::Model::Queryable::ClassMethods
      
      def constraints
        @constraints ||= {}.with_indifferent_access
      end
      
      def update_constraint( constraint, value )
        self.tap do
          constraints[constraint] = value
        end
      end
      
      def criteria
        Marshal.load(Marshal.dump(self))
      end
    end
  end
end