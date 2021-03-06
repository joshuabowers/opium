module Opium
  module Model
    module Queryable
      extend ActiveSupport::Concern

      module ClassMethods
        delegate :count, :total_count, to: :criteria

        def all( constraints = nil )
          constraints ? imbued_where( arrayize( constraints ), '$all' ) : criteria
        end

        alias_method :all_in, :all

        def between( constraints )
          start = constraints.map {|key, range| [key, range.begin]}
          inclusive = constraints.reject {|_, range| range.exclude_end?}.map {|key, range| [key, range.end]}
          exclusive = constraints.select {|_, range| range.exclude_end?}.map {|key, range| [key, range.end]}
          gte( start ).lte( inclusive ).lt( exclusive )
        end

        def exists( constraints )
          imbued_where( constraints.map {|key, value| [key, value.to_bool.freeze] }, '$exists' )
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

        alias_method :any_in, :in

        def nin( constraints )
          imbued_where( arrayize( constraints ), '$nin' )
        end

        def ne( constraints )
          imbued_where( constraints, '$ne' )
        end

        def or( *subqueries )
          where( '$or' => subqueries.map {|query| translate_to_parse( query )}.freeze )
        end

        def select( constraints )
          imbued_where( constraints, '$select' )
        end

        def dont_select( constraints )
          imbued_where( constraints, '$dontSelect' )
        end

        def keys( *field_names )
          validate_fields_exist( field_names )
          criteria.update_constraint( :keys, field_names.map(&method(:translate_name)).join(',') )
        end

        # Should be noted that pluck is an immediate query execution, so doesn't play well with further chainable criteria
        def pluck( field_name )

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

        def cache
          criteria.update_variable( :cache, true )
        end

        def uncache
          criteria.update_variable( :cache, false )
        end

        def cached?
          criteria.variables[:cache]
        end

        private

        def model
          self
        end

        def validate_fields_exist( field_names )
          field_names = field_names.keys if field_names.respond_to? :keys
          unless field_names.all? {|field_name| model.fields.key?( field_name ) || field_name =~ /^\$/ }
            not_fields = field_names.reject {|field_name| model.fields.key? field_name }
            raise ArgumentError, "#{not_fields.join(', ')} #{not_fields.length > 1 ? 'are not fields' : 'is not a field'} on this model"
          end
        end

        def translate_name( field_name )
          field_name =~ /^\$/ ? field_name : model.parse_canonical_field_names[ field_name ]
        end

        def translate_to_parse( constraints )
          Hash[ *constraints.flat_map {|key, value| [translate_name( key ), convert_to_field_type( key, value )]} ]
        end

        def convert_to_field_type( field_name, value )
          return value if value.frozen?
          case value
          when Array
            value.map {|i| convert_to_field_type( field_name, i)}
          when Hash
            Hash[ *value.flat_map {|k, v| [translate_name( k ), convert_to_field_type( field_name, v)]} ]
          when Criteria, Pointer, Model
            value.to_parse
          else
            model.fields[field_name].type.to_parse value
          end
        end

        def arrayize( constraints )
          constraints.map {|key, value| [key, value.to_a]}
        end

        def imbued_where( constraints, operator )
          where( imbue_field_constraints_with_operator( constraints, operator ) )
        end

        def imbue_field_constraints_with_operator( constraints, operator )
          Hash[ *constraints.flat_map {|key, value| [key, { operator => value }]} ]
        end
      end
    end
  end
end
