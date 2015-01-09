module Opium
  class Pointer
    def initialize( attributes = {} )
      self.class_name = attributes[:class_name] || attributes[:model_name] || (attributes[:class] || attributes[:model]).model_name
      self.id = attributes[:id]
    end
    
    attr_reader :class_name, :id
    alias_method :model_name, :class_name
    
    def to_parse
      { __type: 'Pointer', className: class_name, objectId: id }.with_indifferent_access
    end
    
    private
    
    attr_writer :class_name, :id
    alias_method :model_name=, :class_name=
  end
end