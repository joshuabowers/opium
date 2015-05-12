module Opium
  module Model
    class Criteria
      include Opium::Model::Queryable::ClassMethods
      include Enumerable
      
      class_attribute :models
      self.models = {}.with_indifferent_access
      
      def initialize( model_name )
        @model_name = model_name.respond_to?(:name) ? model_name.name : model_name
        constraints[:count] = 1
      end
      
      attr_reader :model_name
      
      def to_partial_path
        model._to_partial_path
      end
      
      def model
        models[model_name] ||= model_name.constantize
      end
      
      def chain
        Marshal.load( Marshal.dump( self ) ).tap {|m| m.instance_variable_set( :@cache, nil )}
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
      
      def constraints?
        !constraints.except(:count).empty?
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
      
      def variables?
        !variables.empty?
      end
      
      def empty?
        count == 0
      end
      
      def criteria
        self
      end
      
      def ==( other )
        other.is_a?( self.class ) && self.model_name == other.model_name && self.constraints == other.constraints && self.variables == other.variables
      end
      
      def each(&block)
        if !block_given?
          to_enum(:each)
        elsif cached? && @cache
          @cache.each(&block)
        else
          response = self.model.http_get( query: self.constraints )
          @cache = []
          if response && response['results']
            variables[:total_count] = response['count']
            response['results'].each do |attributes|
              model = self.model.new( attributes )
              @cache << model if cached?
              block.call model
            end
          end
        end
      end
            
      def inspect
        inspected_constraints = constraints.map {|k, v| [k, v.inspect].join(': ')}.join(', ')
        inspected_constraints.prepend ' ' if inspected_constraints.size > 0
        "#<#{ self.class.name }<#{ model_name }>#{ inspected_constraints }>"
      end
      
      def to_parse
        {}.with_indifferent_access.tap do |result|
          result[:query] = { where: constraints[:where], className: model_name } if constraints[:where]
          result[:key] = constraints[:keys] if constraints[:keys]
        end
      end
      
      def uncache
        super.tap do |criteria|
          criteria.instance_variable_set(:@cache, nil)
        end
      end
      
      def total_count
        count && variables[:total_count]
      end
      
      alias_method :to_ary, :to_a
      
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