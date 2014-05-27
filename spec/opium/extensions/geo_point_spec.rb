require 'spec_helper'

describe GeoPoint do
  subject { GeoPoint }
  
  it { should respond_to(:to_ruby, :to_parse).with(1).argument }
  
  it ":to_ruby(object) should create a GeoPoint" do
    [ "33.33, -117.117", {latitude: 33.33, longitude: -117.117}, [33.33, -117.117], GeoPoint.new( [33.33, -117.117] ) ].each do |value|
      result = subject.to_ruby( value )
      result.should be_a_kind_of(GeoPoint)
      result.latitude.should == 33.33
      result.longitude.should == -117.117
    end
  end
  
  it ":to_ruby(bad_data) should raise exception" do
    [ "malformed", {latitude: 0, bad_key: :unknown}, [0], 1, 1.0, true, false ].each do |value|
      expect { subject.to_ruby( value ) }.to raise_exception
    end
  end
  
  it ":to_parse(object) should ensure a geo_point and make into parse object" do
    [ "33.33, -117.117", {latitude: 33.33, longitude: -117.117}, [33.33, -117.117], GeoPoint.new( [33.33, -117.117] ) ].each do |value|
      result = subject.to_parse( value )
      result.should == { "__type" => "GeoPoint", "latitude" => 33.33, "longitude" => -117.117 }
    end    
  end
  
  describe "instance" do
    describe "with an array value" do
      subject { GeoPoint.new [33.33, -117.117] }
      it { should respond_to(:latitude, :longitude, :to_geo_point, :to_parse).with(0).arguments }
      it { should respond_to(:latitude=, :longitude=).with(1).argument }
    
      its(:latitude) { should == 33.33 }
      its(:longitude) { should == -117.117 }
      its(:to_geo_point) { should == subject }
      its(:to_parse) { should == { "__type" => "GeoPoint", "latitude" => 33.33, "longitude" => -117.117 } }
      its(:to_s) { should == "33.33,-117.117" }
    end

    describe "with a hash value" do
      subject { GeoPoint.new latitude: 33.33, longitude: -117.117 }
      it { should respond_to(:latitude, :longitude, :to_geo_point, :to_parse).with(0).arguments }
      it { should respond_to(:latitude=, :longitude=).with(1).argument }

      its(:latitude) { should == 33.33 }
      its(:longitude) { should == -117.117 }
      its(:to_geo_point) { should == subject }
      its(:to_parse) { should == { "__type" => "GeoPoint", "latitude" => 33.33, "longitude" => -117.117 } }
      its(:to_s) { should == "33.33,-117.117" }
    end
  end
end