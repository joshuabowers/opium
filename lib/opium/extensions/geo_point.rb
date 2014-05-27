class GeoPoint
  def initialize( value )
    case value
    when Hash
      self.latitude = value[:latitude] || value['latitude']
      self.longitude = value[:longitude] || value['longitude']
    when Array
      self.latitude = value.first
      self.longitude = value.last
    else
      raise ArgumentError.new( "invalid value for GeoPoint: \"#{value}\"" )
    end
  end
  
  attr_accessor :latitude, :longitude
  
  def to_geo_point
    self
  end
  
  def to_parse
    { "__type" => "GeoPoint", "latitude" => self.latitude, "longitude" => self.longitude }
  end

  class << self
    def to_ruby(object)
      object.to_geo_point unless object.nil?
    end
    
    def to_parse(object)
      object.to_geo_point.to_parse
    end
  end
end