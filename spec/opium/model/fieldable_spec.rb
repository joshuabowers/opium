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
        field :name, type: String, default: "default"
        field :price, type: Float, default: -> { 5.0 * 2 }
        field :no_cast
      end
    end
  
    it { model.should respond_to( :field ).with(2).arguments }
  
    it { model.should respond_to( :fields ).with(0).arguments }
    
    it "should have #fields for every #field" do
      model.fields.should be_a_kind_of( Hash )
      model.fields.should_not be_empty
      model.fields.keys.should == %w[name price no_cast]
      model.fields.values.each do |f|
        f.should_not be_nil
        f.should be_a_kind_of( Opium::Model::Field )
      end 
    end
    
    it "each #fields should have a #name, #type, #default" do
      model.fields.values.each do |f|
        f.should respond_to(:name, :type, :default)
      end
    end
    
    it "each #fields should have the type they were defined with" do
      expected = {name: String, price: Float, no_cast: Object}
      model.fields.values.each do |f|
        f.type.should == expected[ f.name.to_sym ]
      end
    end
    
    it "each #fields should have the default they were defined with" do
      expected = {name: "default", price: 10.0, no_cast: nil}
      model.fields.values.each do |f|
        f.default.should == expected[ f.name.to_sym ]
      end
    end
    
    it { model.should respond_to( :default_attributes ) }
    
    it "default_attributes should return its #fields default" do
      expected = {"name" => "default", "price" => 10.0, "no_cast" => nil}
      model.default_attributes.should == expected
    end
  
    describe "instance" do
      subject { model.new }
      
      [:name, :price].each do |field_name|
        it "should have a getter and setter for its fields" do
          should respond_to( field_name ).with(0).arguments
          should respond_to( :"#{field_name}=" ).with(1).argument
        end
    
        it "should have a dirty tracking method for its fields" do
          should respond_to( :"#{field_name}_will_change!" )
        end
    
        it "should receive a dirty tracking update when the setter is called with a new value" do
          subject.should_receive :"#{field_name}_will_change!"
          subject.send(:"#{field_name}=", "changed!")
        end
    
        it "should not receive a dirty tracking update when the setter is called with the current value" do
          subject.send(:"#{field_name}=", "current")
          subject.should_not_receive :"#{field_name}_will_change!"
          subject.send(:"#{field_name}=", "current")
        end
      end
    end
  end
end