require 'spec_helper'

describe Opium::Model::Dirty do
  let( :model ) { Class.new { include Opium::Model::Dirty; } }
  
  describe "instance" do
    subject { model.new }
    
    it { should respond_to( :changes_applied, :reset_changes ) }
    
    it "when saved, should receive #changes_applied" do
      subject.should receive(:changes_applied)
      subject.save
    end
  end
end