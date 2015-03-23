class Array
  def to_parse
    map {|value| value.to_parse}
  end
  
  def to_geo_point
    return GeoPoint.new(self) if self.size == 2
    fail ArgumentError, %(invalid value for GeoPoint: "#{ self.inspect }"), caller
  end
end