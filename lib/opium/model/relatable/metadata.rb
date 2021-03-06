module Opium
  module Model
    module Relatable
      class Metadata
        attr_reader :relation_name, :inverse_relation_name, :target_class_name, :relation_type, :inverse_relation_type, :owning_class_name
        
        def initialize( klass, relation_type, relation_name, options = {} )
          self.owning_class_name = klass.model_name
          self.relation_type = relation_type
          self.relation_name = relation_name
          self.target_class_name = (options[:class_name] || relation_name).to_s.classify
          self.inverse_relation_name = (options[:inverse_of] || determine_inverse_relation_name).to_s
        end
        
        private
        
        attr_writer :relation_name, :inverse_relation_name, :target_class_name, :relation_type, :inverse_relation_type, :owning_class_name
        
        def determine_inverse_relation_name
          method =
            case relation_type
            when :belongs_to
              :plural
            else
              :singular
            end
          owning_class_name.send( method )
        end
      end
    end
  end
end