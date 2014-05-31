class Time
  def to_parse
    {
      '__type' => 'Date',
      'iso' => self.iso8601
    }
  end
  
  class << self
    def to_ruby(object)
      object = object.utc if object.respond_to? :utc
      object.to_time if object
    end
    
    def to_parse(object)
      object.to_time.to_parse if object
    end
  end
end