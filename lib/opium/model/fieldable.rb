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
          name = name.to_sym
          fields[name] = Field.new( name, options[:type] || Object, options[:default], options[:readonly] || false, options[:as] )
          ruby_canonical_field_names[name] = ruby_canonical_field_names[fields[name].name_to_parse] = name.to_s
          parse_canonical_field_names[name] = parse_canonical_field_names[fields[name].name_to_parse] = fields[name].name_to_parse.to_s
          class_eval do
            define_attribute_methods [name]
            define_method(name) do
              self.attributes[name]
            end
          end
          unless self.respond_to? "#{name}="
            class_eval do
              define_method("#{name}=") do |value|
                converted = self.class.fields[name].type.to_ruby(value)
                send( "#{name}_will_change!" ) unless self.attributes[name] == converted
                self.attributes[name] = converted
              end
              send(:private, "#{name}=") if options[:readonly]
            end
          end
          fields[name]
        end
        
        def fields
          @fields ||= ActiveSupport::HashWithIndifferentAccess.new
        end
        
        def ruby_canonical_field_names
          @ruby_canonical_field_names ||= ActiveSupport::HashWithIndifferentAccess.new
        end
        
        def parse_canonical_field_names
          @parse_canonical_field_names ||= ActiveSupport::HashWithIndifferentAccess.new
        end
        
        def default_attributes
          fields.transform_values {|field| field.type.to_ruby field.default}.with_indifferent_access
        end
      end
    end
  end
end