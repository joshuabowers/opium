require 'opium/model/field'

module Opium
  module Model
    module Fieldable
      extend ActiveSupport::Concern
      
      included do
        field :id, type: String, readonly: true, as: :object_id
        field :created_at, type: DateTime, readonly: true
        field :updated_at, type: DateTime, readonly: true
      end
      
      module ClassMethods
        def field( name, options = {} )
          create_field_from( name.to_sym, options ).tap do |field|
            create_field_getter_for( field )
            create_field_setter_for( field )
          end
        end
        
        def has_field?( field_name )
          fields.key? field_name
        end
        
        alias_method :field?, :has_field?
        
        def fields
          @fields ||= {}.with_indifferent_access
        end
        
        def ruby_canonical_field_names
          @ruby_canonical_field_names ||= {}.with_indifferent_access
        end
        
        def parse_canonical_field_names
          @parse_canonical_field_names ||= {}.with_indifferent_access
        end
        
        def default_attributes( context = nil )
          fields.transform_values {|field| field.contextual_default_value( context ) }.with_indifferent_access
        end
        
        private
        
        def create_field_from( name, options )
          field = Field.new( name, options[:type] || Object, options[:default], options[:readonly] || false, options[:as] )
          ruby_canonical_field_names[name] = ruby_canonical_field_names[field.name_to_parse] = name.to_s
          parse_canonical_field_names[name] = parse_canonical_field_names[field.name_to_parse] = field.name_to_parse.to_s
          fields[name] = field
        end
        
        def create_field_getter_for( field )
          class_eval do
            define_attribute_methods [field.name]
            define_method(field.name) do
              self.attributes[field.name]
            end
          end
        end
        
        def create_field_setter_for( field )
          class_eval do
            define_method("#{ field.name }=") do |value|
              converted = field.type.to_ruby(value)
              send( "#{ field.name }_will_change!" ) unless self.attributes[field.name] == converted
              if field.relation?
                converted = field.contextual_default_value( self ) unless converted
                converted.owner ||= self 
                converted.metadata ||= self.class.relations[field.name]
              end
              self.attributes[field.name] = converted
            end
            send(:private, "#{ field.name }=") if field.readonly?
          end
        end
      end
    end
  end
end