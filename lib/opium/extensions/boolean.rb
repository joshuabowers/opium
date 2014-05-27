module Boolean
  extend ActiveSupport::Concern
  
  module ClassMethods
    def to_ruby(object)
      object.to_bool if object.respond_to?( :to_bool )
    end
    
    def to_parse(object)
      object.to_bool if object.respond_to?( :to_bool )      
    end
  end
  
  extend ClassMethods
end