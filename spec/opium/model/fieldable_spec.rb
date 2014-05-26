require 'spec_helper'

describe Opium::Model::Fieldable do
  describe "in a model without fields" do
    let( :model ) { Class.new { include Opium::Model } }
    
    it { model.should respond_to( :fields ).with(0).arguments }
    it "should have no #fields" do
      model.fields.should be_a_kind_of( Hash )
      model.fields.should be_empty
    end
  end
  
  describe "in a model with fields" do
    let( :model ) do
      Class.new do
        include Opium::Model
        field :name
      end
    end
  
    it { model.should respond_to( :field ).with(2).arguments }
  
    it { model.should respond_to( :fields ).with(0).arguments }
    
    it "should have #fields for every #field" do
      model.fields.should be_a_kind_of( Hash )
      model.fields.should_not be_empty
      model.fields.keys.should == %w[name]
    end
  
    describe "instance" do
      subject { model.new }
    
      it "should have a getter and setter for its field" do
        should respond_to( :name ).with(0).arguments
        should respond_to( :name= ).with(1).argument
      end
    
      it "should have a dirty tracking method for its field" do
        should respond_to( :name_will_change! )
      end
    
      it "should receive a dirty tracking update when the setter is called with a new value" do
        subject.should_receive :name_will_change!
        subject.name = "changed!"
      end
    
      it "should not receive a dirty tracking update when the setter is called with the current value" do
        subject.name = "current"
        subject.should_not_receive :name_will_change!
        subject.name = "current"
      end
    end
  end
end