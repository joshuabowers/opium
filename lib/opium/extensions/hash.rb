class Hash
  def to_geo_point
    return GeoPoint.new(self) if [:latitude, :longitude].all? {|required| self.key? required}
    raise ArgumentError.new( "invalid value for GeoPoint: \"#{self}\"" )
  end
  
  def to_datetime
    retrieve_iso_key.to_datetime
  end
  
  def to_date
    retrieve_iso_key.to_date
  end
  
  def to_time
    retrieve_iso_key.to_time
  end
  
  def to_parse
    Hash[ *self.map {|key, value| [key, value.to_parse] }.flatten ]
  end
  
  private
  
  def retrieve_iso_key
    validates_keys_present( '__type', 'iso' )
    validate_key_equals( '__type', 'Date' )
    value_for_indifferent_key('iso')
  end
  
  def validates_keys_present(*expected_keys)
    result = expected_keys - self.keys.map(&:to_s)
    raise ArgumentError, "expected key(s): #{result}" unless result.empty?
  end
  
  def validate_key_equals( key, value )
    raise ArgumentError, "conversion to Date/Time expectes a #{key} of #{value}" unless self[key] == value || self[key.to_sym] == value
  end
  
  def value_for_indifferent_key( key )
    self[key] || self[key.to_sym]
  end
end