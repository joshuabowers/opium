class Float
  class << self
    def to_ruby(object)
      if object.is_a? Symbol
        object.to_s.to_f
      elsif object
        object.to_f
      end
    end
    
    def to_parse(object)
      if object.is_a? Symbol
        object.to_s.to_f
      elsif object
        object.to_f
      end
    end
  end
end