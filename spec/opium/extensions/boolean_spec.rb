require 'spec_helper'

describe Boolean do
  subject { Boolean }
  it { should respond_to(:to_ruby).with(1).argument }
  it { should respond_to(:to_parse).with(1).argument }
  
  it ":to_ruby(object) should convert object to a boolean" do
    ["true", "false", true, false, 1.0, 1, 0.0, 0].each do |value|
      subject.to_ruby(value).should be_a_kind_of(Boolean)
      subject.to_ruby(value).should == value.to_bool
    end
  end
  
  it ":to_parse(object) should convert object to a boolean" do
    ["true", "false", true, false, 1.0, 1, 0.0, 0].each do |value|
      subject.to_parse(value).should be_a_kind_of(Boolean)
      subject.to_parse(value).should == value.to_bool
    end
  end
  
  describe "instance" do
    subject { Class.new { include Boolean }.new }
    it { should respond_to(:to_ruby, :to_parse).with(0).arguments }
    its(:to_ruby) { should == subject }
    its(:to_parse) { should == subject }
  end
end