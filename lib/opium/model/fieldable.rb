require 'opium/model/field'

module Opium
  module Model
    module Fieldable
      extend ActiveSupport::Concern
      
      module ClassMethods
        def field( name, options = {} )
          name = name.to_sym
          fields[name] = Field.new( name, options[:type] || Object, options[:default], options[:readonly] || false )
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
        
        def default_attributes
          ActiveSupport::HashWithIndifferentAccess[ *fields.map {|key, field| [key, field.default]}.flatten ]
        end
      end
    end
  end
end