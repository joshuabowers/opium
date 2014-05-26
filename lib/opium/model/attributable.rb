module Opium
  module Model
    module Attributable
      extend ActiveSupport::Concern
      
      attr_reader :attributes
    
      def attributes=(values)
        @attributes = self.class.default_attributes.merge( values )
      end
    end
  end
end