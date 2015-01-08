module Opium
  module Model
    module Queryable
      extend ActiveSupport::Concern
      
      included do
      end
      
      module ClassMethods        
        def all( constraints = {} )
          # constraints.map do |key, value|
          #   where( key => { '$all' => value } )
          # end
        end
        
        def between
          
        end
        
        def exists
          
        end
        
        def gt( constraints )
          where( imbue_field_constraints_with_operator( constraints, '$gt' ) )          
        end
        
        def gte( constraints )
          where( imbue_field_constraints_with_operator( constraints, '$gte' ) )
        end
        
        def lt( constraints )
          where( imbue_field_constraints_with_operator( constraints, '$lt' ) )
        end
        
        def lte( constraints )
          where( imbue_field_constraints_with_operator( constraints, '$lte' ) )
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
        
        def order( options )
          previous = criteria.constraints[:order]
          ordering = ([previous].compact + options.map {|key, value| (['-', 'desc', '-1'].include?( value.to_s ) ? '-' : '' ) + key.to_s }).join(',')
          criteria.update_constraint( :order, ordering )
        end
        
        def limit( value )
          criteria.update_constraint( :limit, value )
        end
        
        def skip( value )
          criteria.update_constraint( :skip, value )
        end
        
        def where( constraints )
          criteria.update_constraint( :where, constraints )
        end
        
        alias_method :and, :where
        
        private
        
        def imbue_field_constraints_with_operator( constraints, operator )
          Hash[ *constraints.map {|key, value| [key, { operator => value }] }.flatten ]
        end
      end
    end
  end
end