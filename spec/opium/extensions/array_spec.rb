require 'spec_helper'

describe Array do
  subject { Array }
  
  describe "instance" do
    describe ":to_parse" do
      subject { [GeoPoint.new( latitude: 33.33, longitude: -117.117 )] }
      
      it "should call :to_parse on each element" do
        subject.to_parse.tap do |result|
          result.should =~ [ { '__type' => 'GeoPoint', 'latitude' => 33.33, 'longitude' => -117.117 } ]
        end
      end
    end
    
    describe "with two values" do
      describe ":to_geo_point" do
        subject { [33.33, -117.117] }
      
        it { subject.to_geo_point.should be_a_kind_of(GeoPoint) }
        it "should have the expected latitude and longitude" do
          subject.to_geo_point.latitude.should == 33.33
          subject.to_geo_point.longitude.should == -117.117
        end
      end
    end
    
    describe "with more or fewer than two values" do
      describe ":to_geo_point" do
        subject { [33.33] }
        
        it { expect { subject.to_geo_point }.to raise_exception }
      end
    end
  end
end