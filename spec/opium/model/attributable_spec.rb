require 'spec_helper'

describe Opium::Model::Attributable do
  let( :model ) { Class.new { include Opium::Model::Attributable } }
  
  it { model.should respond_to( :attr_accessible, :attr_protected ) }
  
  describe "instance" do
    subject { model.new }
    
    it { should respond_to( :attributes, :attributes= ) }
  end
end