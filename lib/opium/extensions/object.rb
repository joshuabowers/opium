class Object
  def to_ruby
    self
  end
  
  alias_method :to_parse, :to_ruby
  
  class << self
    def to_ruby(other)
      other
    end
    
    alias_method :to_parse, :to_ruby
  end
end