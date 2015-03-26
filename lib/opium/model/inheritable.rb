module Opium
  module Model
    module Inheritable
      extend ActiveSupport::Concern
      
      module ClassMethods
        def inherited( subclass )
          self.resource_name
          
          [
            :@ruby_canonical_field_names, 
            :@parse_canonical_field_names, 
            :@object_prefix, 
            :@added_headers, 
            :@requires_heightened_privileges,
            :@fields,
            :@resource_name
          ].each do |iv|
            origin = self.instance_variable_get( iv )
            can_copy = ![TrueClass, FalseClass, NilClass].include?( origin.class )
            subclass.instance_variable_set( iv, can_copy ? origin.dup : origin )
          end
        end
      end
    end
  end
end