require 'spec_helper'

describe String do
  subject { String }
  it { should respond_to(:to_ruby).with(1).argument }
  it { should respond_to(:to_parse).with(1).argument }
  
  it ":to_ruby(object) should convert object to a string" do
    {nil => nil}.each do |value, expected|
      subject.to_ruby(value).should be_a_kind_of(expected.class)
      subject.to_ruby(value).should == expected
    end
    [:foo, "foo", 42.0, 42, Time.now].each do |value|
      subject.to_ruby(value).should be_a_kind_of(String)
      subject.to_ruby(value).should == value.to_s
    end
  end
  
  it ":to_parse(object) should convert object to a string" do
    {nil => nil}.each do |value, expected|
      subject.to_parse(value).should be_a_kind_of(expected.class)
      subject.to_parse(value).should == expected
    end
    [:foo, "foo", 42.0, 42, Time.now].each do |value|
      subject.to_parse(value).should be_a_kind_of(String)
      subject.to_parse(value).should == value.to_s
    end    
  end
  
  describe "instance" do
    subject { "instance" }
    it { should respond_to(:to_ruby, :to_parse, :to_bool, :to_geo_point).with(0).arguments }
    its(:to_ruby) { should == subject }
    its(:to_parse) { should == subject }
    
    it "should be able to convert various values to true" do
      %w[true t yes y 1].each do |value|
        value.to_bool.should be_a_kind_of( Boolean )
        value.to_bool.should == true
      end
    end
    
    it "should be able to convert various values to false" do
      [""] + %w[false f no n 0].each do |value|
        value.to_bool.should be_a_kind_of( Boolean )
        value.to_bool.should == false
      end
    end
    
    it "any non-boolean string should raise on :to_bool" do
      expect { subject.to_bool }.to raise_exception 
    end
    
    it ":to_geo_point should be able to convert a 'lat, lng' value" do
      result = "33.33, -117.117".to_geo_point
      result.should be_a_kind_of(GeoPoint)
      result.latitude.should == 33.33
      result.longitude.should == -117.117
    end
    
    it ":to_geo_point should raise exception if invalid" do
      expect { "malformed".to_geo_point }.to raise_exception
    end
  end
end