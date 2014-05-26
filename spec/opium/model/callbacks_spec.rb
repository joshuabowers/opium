require 'spec_helper'

describe Opium::Model::Callbacks do
  let( :model ) { Class.new { include Opium::Model::Callbacks } }
  
  its( :constants ) { should include(:CALLBACKS) }
  
  it do
    subject::CALLBACKS.should_not be_nil
    subject::CALLBACKS.should_not be_empty
  end
  
  it "should respond to each of its CALLBACKS" do
    subject::CALLBACKS.each do |callback|
      model.should respond_to(callback)
    end
  end
end