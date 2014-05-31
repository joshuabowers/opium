require 'spec_helper'

describe DateTime do
  subject { DateTime }
  it { should respond_to(:to_parse, :to_ruby).with(1).argument }
  
  describe ":to_ruby" do
    describe "with a Hash containing '__type: DateTime'" do
      let(:object) { { '__type' => 'Date', 'iso' => DateTime.now.iso8601 } }
      it { subject.to_ruby(object).should be_a_kind_of( DateTime ) }
    end
  
    describe "with a Hash without a '__type' key" do
      let(:object) { { 'iso' => DateTime.now.iso8601 } }
      it { expect { subject.to_ruby(object) }.to raise_exception }
    end
  
    describe "with an object which responds to :to_datetime" do
      let(:objects) { [ DateTime.now.iso8601, DateTime.now, Time.now, Date.today ] }
      it do
        objects.each do |object|
          subject.to_ruby(object).should be_a_kind_of( DateTime )
        end
      end
    end
  end
  
  describe ":to_parse(object)" do
    let(:objects) { [ DateTime.now.iso8601, DateTime.now, Time.now, Date.today ] }
    it "should ensure that the object is a datetime" do
      objects.each do |object|
        object.should_receive :to_datetime
        subject.to_parse(object)
      end
    end
    
    it "should make a parse object hash" do
      objects.each do |object|
        result = subject.to_parse(object)
        result.should be_a_kind_of(Hash)
        result.keys.should == ['__type', 'iso']
        result['__type'].should == 'Date'
      end
    end
  end
  
  describe "instance" do
    subject { DateTime.now }
    let(:result) { subject.to_parse }
    it { result.should be_a_kind_of(Hash) }
    it { result.keys.should == ['__type', 'iso'] }
    it { result['__type'].should == 'Date' }
    it { result['iso'].should == subject.iso8601 }
  end
end