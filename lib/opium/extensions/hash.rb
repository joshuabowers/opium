class Hash
  def to_geo_point
    return GeoPoint.new(self) if [:latitude, :longitude].all? {|required| self.key? required}
    raise ArgumentError.new( "invalid value for GeoPoint: \"#{self}\"" )
  end
  
  def to_datetime
    validates_keys_present( '__type', 'iso' )
    validate_key_equals( '__type', 'Date' )
    self['iso'].to_datetime
  end
  
  def to_date
    validates_keys_present( '__type', 'iso' )
    validate_key_equals( '__type', 'Date' )
    self['iso'].to_date
  end
  
  def to_time
    validates_keys_present( '__type', 'iso' )
    validate_key_equals( '__type', 'Date' )
    self['iso'].to_time
  end
  
  private
  
  def validates_keys_present(*expected_keys)
    result = expected_keys - self.keys
    raise ArgumentError, "expected key(s): #{result}" unless result.empty?
  end
  
  def validate_key_equals( key, value )
    raise ArgumentError, "conversion to Date/Time expectes a __type of Date" unless self[key] == value
  end
end