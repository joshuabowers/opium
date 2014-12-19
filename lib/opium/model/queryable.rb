module Opium
  module Model
    module Queryable
      extend ActiveSupport::Concern
      
      included do
      end
      
      module ClassMethods        
        def all( constraints = {} )
          constraints.map do |key, value|
            where( key => { '$all' => value } )
          end
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
          Marshal.load( Marshal.dump( default_scope ) )
        end
        
        def order( options = {} )
          
        end
        
        def limit( value )
          criteria.update_constraint( :limit, value )
        end
        
        def skip( value )
          criteria.update_constraint( :skip, value )
        end
        
        def where( *constraints )
          criteria
        end
        
        alias_method :and, :where
      end
    end
  end
end