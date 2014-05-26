require 'spec_helper'

describe Opium::Model::Dirty do
  let( :model ) { Class.new { include Opium::Model::Dirty } }
  
  describe "instance" do
    subject { model.new }
    
    it { should respond_to( :changes_applied, :reset_changes ) }
  end
end