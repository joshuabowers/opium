module Opium
  module Model
    module Queryable
      extend ActiveSupport::Concern
      
      included do
      end
      
      module ClassMethods        
        def all
          
        end
        
        def and
          
        end
        
        def between
          
        end
        
        def exists
          
        end
        
        def gt
          
        end
        
        def gte
          
        end
        
        def lt
          
        end
        
        def lte
          
        end
        
        def in
          
        end
        
        def nin
          
        end
        
        def ne
          
        end
        
        def or
          
        end
        
        def nor
          
        end
        
        def select
          
        end
        
        def dont_select
          
        end
        
        def criteria
          
        end
        
        def order( options = {} )
          
        end
        
        def limit
          
        end
        
        def where( *constraints )
          Criteria.new
        end
      end
    end
  end
end