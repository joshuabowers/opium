class ::Symbol
  class << self
    def to_ruby( other )
      other.to_sym
    end
    
    def to_parse( other )
      other.to_parse
    end
  end
  
  alias_method :to_parse, :to_s
end