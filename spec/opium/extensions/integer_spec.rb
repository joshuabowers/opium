require 'spec_helper'

describe Integer do
  subject { Integer }
  it { should respond_to(:to_ruby).with(1).argument }
  it { should respond_to(:to_parse).with(1).argument }
  
  it ":to_ruby(object) should convert object to a integer" do
    {nil => nil, :foo => :foo.to_s.to_i}.each do |value, expected|
      subject.to_ruby(value).should be_a_kind_of(expected.class)
      subject.to_ruby(value).should == expected
    end
    ["foo", 42.0, 42, Time.now].each do |value|
      subject.to_ruby(value).should be_a_kind_of(Integer)
      subject.to_ruby(value).should == value.to_i
    end
  end
  
  it ":to_parse(object) should convert object to a integer" do
    {nil => nil, :foo => :foo.to_s.to_i}.each do |value, expected|
      subject.to_parse(value).should be_a_kind_of(expected.class)
      subject.to_parse(value).should == expected
    end
    ["foo", 42.0, 42, Time.now].each do |value|
      subject.to_parse(value).should be_a_kind_of(Integer)
      subject.to_parse(value).should == value.to_i
    end    
  end
  
  describe "instance" do
    subject { 42 }
    it { should respond_to(:to_ruby, :to_parse, :to_bool).with(0).arguments }
    its(:to_ruby) { should == subject }
    its(:to_parse) { should == subject }
    
    it "should convert 1 and 0 to true and false, all others raise" do
      1.to_bool.should == true
      0.to_bool.should == false
      expect { subject.to_bool }.to raise_exception
    end
  end
end