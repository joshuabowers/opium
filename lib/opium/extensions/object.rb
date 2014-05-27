class Object
  def to_parse
    self
  end
  
  def to_ruby
    self
  end
  
  class << self
    def to_parse(other)
      other
    end
    
    def to_ruby(other)
      other
    end
  end
end