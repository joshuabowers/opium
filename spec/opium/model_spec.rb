require 'spec_helper'

describe Opium::Model do
  let( :model ) { Class.new { include Opium::Model } }
  
  it "should respond_to :model_name" do
    model.should respond_to( :model_name )
  end
  
  it "should respond_to :validates" do
    model.should respond_to( :validates )
  end
  
  it "should respond_to :define_model_callbacks" do
    model.should respond_to( :define_model_callbacks )
  end
  
  it "should respond_to :field" do
    model.should respond_to( :field ).with(2).arguments
  end
  
  describe "instance" do
    subject { model.new }
    
    it { should respond_to( :attributes ) }
    it { should respond_to( :serializable_hash, :as_json, :from_json ) }
    it { should respond_to( :changes, :changed? ) }
    
    its(:attributes) do
      should_not be_nil
      should be_a_kind_of( Hash )
    end
  end
end