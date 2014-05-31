class Date
  def to_parse
    {
      '__type' => 'Date',
      'iso' => self.iso8601
    }
  end
  
  class << self
    def to_ruby(object)
      object.to_date
    end
    
    def to_parse(object)
      object.to_date.to_parse
    end
  end
end