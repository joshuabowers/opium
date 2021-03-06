class ::String
  def to_bool
    return true if self == true || self =~ (/^(true|t|yes|y|1)$/i)
    return false if self == false || self.blank? || self =~ (/^(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end
  
  def to_geo_point
    Opium::GeoPoint.new( self )
  end
  
  class << self
    def to_ruby(object)
      object.to_s if object
    end
    
    alias_method :to_parse, :to_ruby
  end
end