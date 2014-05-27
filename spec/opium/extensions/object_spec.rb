require 'spec_helper'

describe Object do
  subject { Object }
  it { should respond_to(:to_parse).with(1).argument }
  it { should respond_to(:to_ruby).with(1).argument }
  
  it ":to_parse(object) should return the object" do
    object = subject.new
    subject.to_parse(object).should == object
  end

  it ":to_ruby(object) should return the object" do
    object = subject.new
    subject.to_ruby(object).should == object
  end
  
  describe "instance" do
    subject { Object.new }
    it { should respond_to(:to_parse, :to_ruby) }
    its(:to_parse) { should == subject }
    its(:to_ruby) { should == subject }
  end
end