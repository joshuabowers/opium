module Opium
  module Model
    module Queryable
      extend ActiveSupport::Concern
      
      included do
      end
      
      module ClassMethods        
        def all( constraints )
          imbued_where( arrayize( constraints ), '$all' )
        end
        
        def between( constraints )
          gte( constraints.map {|key, range| [key, range.begin] } ).lte( constraints.map {|key, range| [key, range.end ] } )
        end
        
        def exists( constraints )
          imbued_where( constraints.map {|key, value| [key, value.to_bool] }, '$exists' )
        end
        
        def gt( constraints )
          imbued_where( constraints, '$gt' )
        end
        
        def gte( constraints )
          imbued_where( constraints, '$gte' )
        end
        
        def lt( constraints )
          imbued_where( constraints, '$lt' )
        end
        
        def lte( constraints )
          imbued_where( constraints, '$lte' )
        end
        
        def in( constraints )
          imbued_where( arrayize( constraints ), '$in' )
        end
        
        def nin( constraints )
          imbued_where( arrayize( constraints ), '$nin' )
        end
        
        def ne( constraints )
          imbued_where( constraints, '$ne' )
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
          validate_fields_exist( options )
          previous = criteria.constraints[:order]
          ordering = (
            [previous].compact + options.map {|key, value| (['-', 'desc', '-1'].include?( value.to_s ) ? '-' : '' ) + translate_name( key.to_s ) }
            ).join(',')
          criteria.update_constraint( :order, ordering )
        end
        
        def limit( value )
          criteria.update_constraint( :limit, value )
        end
        
        def skip( value )
          criteria.update_constraint( :skip, value )
        end
        
        def where( constraints )
          validate_fields_exist( constraints )
          criteria.update_constraint( :where, translate_to_parse( constraints ) )
        end
        
        alias_method :and, :where
        
        private
        
        def model
          self
        end
        
        def validate_fields_exist( constraints )
          unless constraints.keys.all? {|field_name| model.fields.key? field_name }
            not_fields = constraints.keys.reject {|field_name| model.fields.key? field_name }
            raise ArgumentError, "#{not_fields.join(', ')} #{not_fields.length > 1 ? 'are not fields' : 'is not a field'} on this model; fields = #{model.fields.keys.inspect}"
          end
        end
        
        def translate_name( field_name )
          model.parse_canonical_field_names[ field_name ]
        end
        
        def translate_to_parse( constraints )
          Hash[ *constraints.map {|key, value| [translate_name( key ), value.to_parse] }.flatten( 1 ) ]
        end
        
        def arrayize( constraints )
          constraints.map {|key, value| [key, value.to_a]}
        end
        
        def imbued_where( constraints, operator )
          where( imbue_field_constraints_with_operator( constraints, operator ) )
        end
        
        def imbue_field_constraints_with_operator( constraints, operator )
          Hash[ *constraints.map {|key, value| [key, { operator => value }] }.flatten( 1 ) ]
        end
      end
    end
  end
end