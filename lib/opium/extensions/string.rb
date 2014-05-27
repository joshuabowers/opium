class ::String
  class << self
    def to_ruby(object)
      object.to_s
    end
    
    def to_parse(object)
      object.to_s
    end
  end
end