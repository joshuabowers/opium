require 'spec_helper'

describe Hash do
  subject { Hash }
  
  describe "instance" do
    describe "with latitude and longitude keys" do
      describe ":to_geo_point" do
        subject { { latitude: 33.33, longitude: -117.117 } }
      
        it { subject.to_geo_point.should be_a_kind_of(GeoPoint) }
        it "should have the expected latitude and longitude" do
          subject.to_geo_point.latitude.should == 33.33
          subject.to_geo_point.longitude.should == -117.117
        end
      end
    end
    
    describe "without latitude or longitude keys" do
      describe ":to_geo_point" do
        subject { { latitude: 33.33 } }
        
        it { expect { subject.to_geo_point }.to raise_exception }
      end
    end
  end
end