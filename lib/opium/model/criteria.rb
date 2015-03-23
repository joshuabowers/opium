module Opium
  module Model
    class Criteria
      include Opium::Model::Queryable::ClassMethods
      class_attribute :models
      self.models = {}.with_indifferent_access
      
      def initialize( model_name )
        @model_name = model_name.respond_to?(:name) ? model_name.name : model_name
      end
      
      attr_reader :model_name
      
      def model
        models[model_name] ||= model_name.constantize
      end
      
      def chain
        Marshal.load( Marshal.dump( self ) )
      end
      
      def constraints
        @constraints ||= {}.with_indifferent_access
      end
      
      def update_constraint( constraint, value )
        chain.tap {|c| c.update_constraint!( constraint, value )}
      end
      
      def update_constraint!( constraint, value )
        update_hash_value :constraints, constraint, value
      end
      
      def variables
        @variables ||= {}.with_indifferent_access
      end
      
      def update_variable( variable, value )
        chain.tap {|c| c.update_variable!( variable, value )}
      end
      
      def update_variable!( variable, value )
        update_hash_value :variables, variable, value
      end
      
      def empty?
        constraints.empty?
      end
      
      def criteria
        self
      end
      
      def ==( other )
        other.is_a?( self.class ) && self.model_name == other.model_name && self.constraints == other.constraints && self.variables == other.variables
      end
      
      def each
        unless block_given?
          to_enum(:each)
        else
          response = self.model.http_get( query: self.constraints )
          if response && response['results']
            response['results'].each do |attributes|
              yield self.model.new( attributes )
            end
          end
        end
      end
      
      def to_a
        each.to_a
      end
      
      def to_parse
        {}.with_indifferent_access.tap do |result|
          result[:query] = { where: constraints[:where], className: model_name } if constraints[:where]
          result[:key] = constraints[:keys] if constraints[:keys]
        end
      end
      
      private
      
      def update_hash_value( hash_name, key, value )
        hash = self.send( hash_name )
        if hash[key].nil? || !value.is_a?(Hash)
          hash[key] = value
        elsif hash[key].is_a?(Hash) || value.is_a?(Hash)
          hash[key].deep_merge!( value )
        end
      end
    end
  end
end