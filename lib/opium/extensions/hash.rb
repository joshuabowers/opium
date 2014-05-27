class Hash
  def to_geo_point
    return GeoPoint.new(self) if [:latitude, :longitude].all? {|required| self.key? required}
    raise ArgumentError.new( "invalid value for GeoPoint: \"#{self}\"" )
  end
end