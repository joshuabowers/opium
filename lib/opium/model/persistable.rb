module Opium
  module Model
    module Persistable
      extend ActiveSupport::Concern
      
      included do
      end
      
      module ClassMethods
        def destroy_all( query = nil )
          
        end
        
        def delete_all( query = nil )
          
        end
      end
      
      def save( skip_validations = false )
        
      end
      
      def destroy
        
      end
      
      def delete
        
      end
    end
  end
end