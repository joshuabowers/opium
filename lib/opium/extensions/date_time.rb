class DateTime < Date
  def to_parse
    {
      '__type' => 'Date',
      'iso' => self.iso8601
    }
  end
  
  class << self
    def to_ruby(object)
      object.to_datetime if object
    end
    
    def to_parse(object)
      object.to_datetime.to_parse if object
    end
  end
end