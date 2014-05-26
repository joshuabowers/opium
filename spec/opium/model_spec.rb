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
  
  describe "instance" do
    subject { model.new }
    
    it { should respond_to( :serializable_hash, :as_json, :from_json ) }
    it { should respond_to( :changes, :changed? ) }
  end
end