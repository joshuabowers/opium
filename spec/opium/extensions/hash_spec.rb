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
    
    describe "with __type key" do
      describe "of Date" do
        describe "with iso key" do
          subject { { '__type' => 'Date', 'iso' => DateTime.now.iso8601 } }
          
          describe ":to_datetime" do
            let(:result) { subject.to_datetime }
            it { result.should be_a_kind_of( DateTime ) }
          end
          
          describe ":to_date" do
            let(:result) { subject.to_date }
            it { result.should be_a_kind_of( Date ) }
          end
          
          describe ":to_time" do
            let(:result) { subject.to_time }
            it { result.should be_a_kind_of( Time ) }
          end
        end
        
        describe "without iso key" do
          subject { { '__type' => 'Date' } }

          describe ":to_datetime" do
            it { expect { subject.to_datetime }.to raise_exception }
          end
          
          describe ":to_date" do
            it { expect { subject.to_datetime }.to raise_exception }
          end
          
          describe ":to_time" do
            it { expect { subject.to_datetime }.to raise_exception }
          end
        end
      end
    end
  end
end