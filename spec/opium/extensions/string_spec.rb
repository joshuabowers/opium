require 'spec_helper'

describe String do
  subject { String }
  it { should respond_to(:to_ruby).with(1).argument }
  it { should respond_to(:to_parse).with(1).argument }
  
  it ":to_ruby(object) should convert object to a string" do
    [nil, :foo, "foo", 42.0, 42, Time.now].each do |value|
      subject.to_ruby(value).should be_a_kind_of(String)
      subject.to_ruby(value).should == value.to_s
    end
  end
  
  it ":to_parse(object) should convert object to a string" do
    [nil, :foo, "foo", 42.0, 42, Time.now].each do |value|
      subject.to_parse(value).should be_a_kind_of(String)
      subject.to_parse(value).should == value.to_s
    end    
  end
  
  describe "instance" do
    subject { "" }
    it { should respond_to(:to_ruby, :to_parse).with(0).arguments }
    its(:to_ruby) { should == subject }
    its(:to_parse) { should == subject }
  end
end