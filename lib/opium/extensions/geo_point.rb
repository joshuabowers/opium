module Opium
  class GeoPoint
    include Comparable

    def initialize( value )
      self.latitude, self.longitude = *
        case value
        when Hash
          [value[:latitude] || value['latitude'], value[:longitude] || value['longitude']]
        when Array
          [value.first, value.last]
        when /^[+-]?\d+(\.\d+)?\s*,\s*[+-]?\d+(\.\d+)?$/
          value.split(',').map {|c| c.to_f}
        else
          raise ArgumentError.new( "invalid value for GeoPoint: \"#{ value }\"" )
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
      "#{ self.latitude },#{ self.longitude }"
    end

    def <=>( geo_point )
      return nil unless geo_point.is_a?( self.class )
      [self.latitude, self.longitude] <=> [geo_point.latitude, geo_point.longitude]
    end

    def ===( other )
      if other.is_a? self.class
        self == other
      elsif other <= self.class
        self != NULL_ISLAND
      else
        nil
      end
    end

    NULL_ISLAND = new( [0, 0] ).freeze

    class << self
      def ===( other )
        other != NULL_ISLAND && super
      end

      def to_ruby(object)
        object.to_geo_point unless object.nil?
      end

      def to_parse(object)
        object.to_geo_point.to_parse
      end
    end
  end
end
