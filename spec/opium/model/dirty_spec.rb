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
    
    it "when instantiated, should not be changed" do
      subject.should_not be_changed
    end
  end
  
  describe 'when included in a model' do
    before do
      stub_const( 'Game', Class.new do
        include Opium::Model
        field :title, type: String
      end )
    end
    
    subject { Game.new( title: 'Skyrim' ) }
    
    it 'when instantiated, should not be changed' do
      subject.should_not be_changed
    end
  end
end