class TrueClass
  include Boolean
  
  def to_bool
    self
  end
  
  class << self
    def to_ruby(object)
      
    end
    
    def to_parse(object)
      
    end
  end
end