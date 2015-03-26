require 'spec_helper'

describe Opium::Model::Inheritable do
  before do
    stub_const( 'Model', Class.new do
      include Opium::Model::Inheritable
    end )
  end
  
  subject { Model }
  
  it { expect( subject ).to respond_to( :inherited ).with(1).argument }
  
  context 'within a subclass' do
    before do
      stub_const( 'Game', Class.new do
        include Opium::Model
        field :title, type: String
        field :price, type: Float
      end )
      stub_const( 'MobileGame', Class.new( Game ) do
        field :device, type: String
      end )
    end
    
    subject { MobileGame }
    
    it { is_expected.to be <= Game }
    
    it { expect( subject ).to respond_to( :field, :fields ) }
    
    it "inherits its parent's fields" do
      expect( subject.fields.keys ).to include( 'title', 'price' ) 
    end
    
    it 'has its own defined fields' do
      expect( subject.fields.keys ).to include( 'device' ) 
    end
    
    it "does not alter its parent's fields" do
      expect( Game.fields.keys ).to_not include( 'device' )
    end
    
    it 'has accessors and mutators for its fields' do
      expect( subject.new ).to respond_to( :title, :title=, :price, :price=, :device, :device= ) 
    end
  end
end