module Opium
  module Model
    module Queryable
      extend ActiveSupport::Concern
      
      included do
      end
      
      module ClassMethods
        def find( id )
          new self.http_get( id: id )
        end
        
        def where( constraint )
          
        end
      end
    end
  end
end