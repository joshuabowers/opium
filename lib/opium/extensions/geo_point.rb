class GeoPoint
  def initialize( value )
    self.latitude, self.longitude = *
      case value
      when Hash
        [value[:latitude] || value['latitude'], value[:longitude] || value['longitude']]
      when Array
        [value.first, value.last]
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
  
  def to_s
    "#{self.latitude},#{self.longitude}"
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