class Integer
  class << self
    def to_ruby(object)
      if object.is_a? Symbol
        object.to_s.to_i
      elsif object
        object.to_i
      end
    end
    
    alias_method :to_parse, :to_ruby
  end
end