module Opium
  module Model
    module Fieldable
      extend ActiveSupport::Concern
      
      module ClassMethods
        def field( name, options = {} )
          name = name.to_sym
          class_eval do
            define_attribute_methods [name]
            define_method(name) do
              self.attributes[name]
            end
          end
          unless self.respond_to? "#{name}="
            class_eval do
              define_method("#{name}=") do |value|
                send( "#{name}_will_change!" ) unless self.attributes[name] == value
                self.attributes[name] = value
              end
            end
          end
        end
      end
    end
  end
end