class Array
  def to_parse
    map {|value| value.to_parse}
  end
  
  def to_geo_point
    return GeoPoint.new(self) if self.length == 2
    raise ArgumentError.new( "invalid value for GeoPoint: \"#{self}\"" )
  end
end