module Opium
  module Model
    module Attributable
      extend ActiveSupport::Concern
      
      included do
        include ActiveModel::MassAssignmentSecurity
      end
      
      attr_reader :attributes
    
      def attributes=(values)
        sanitize_for_mass_assignment( values ).each do |k, v|
          send( "#{k}=", v )
        end
      end
    end
  end
end