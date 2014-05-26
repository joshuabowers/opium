require 'spec_helper'

describe Opium::Model::Serialization do
  let( :model ) do
    Class.new do
      include Opium::Model
      field :name
      field :price
    end
  end
  
  it { model.should respond_to( :include_root_in_json ) }
  it "include_root_in_json should default to false" do
    model.include_root_in_json.should == false
  end
  
  describe "instance" do
    describe "with no data" do
      let( :params ) { { "name" => nil, "price" => nil } }
      subject { model.new }
      its(:as_json) { should == params }
      its(:to_json) { should == params.to_json }
    end
    
    describe "with partial data" do
      let( :params ) { { "name" => "test", "price" => nil } }
      subject { model.new( name: "test" ) }
      its(:as_json) { should == params }
      its(:to_json) { should == params.to_json }
    end
    
    describe "with full data" do
      let( :params ) { { "name" => "test", "price" => 75.0 } }
      subject { model.new( params ) }
      its(:as_json) { should == params }
      its(:to_json) { should == params.to_json }
    end
  end
end