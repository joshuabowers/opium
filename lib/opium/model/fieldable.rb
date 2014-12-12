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
        
        def fields_by_parse_name
          @fields_by_parse_name ||= fields.map {|name, field| [field.name_to_parse, field]}.to_h.with_indifferent_access
        end
        
        def default_attributes
          ActiveSupport::HashWithIndifferentAccess[ *fields.map {|key, field| [key, field.default]}.flatten ]
        end
      end
    end
  end
end