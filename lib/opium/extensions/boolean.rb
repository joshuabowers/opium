module Boolean
  extend ActiveSupport::Concern

  module ClassMethods
    def to_ruby(object)
      object.to_bool if object.respond_to?( :to_bool )
    end
    
    alias_method :to_parse, :to_ruby
  end

  extend ClassMethods
end