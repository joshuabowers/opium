require 'spec_helper'

describe Opium::Model::Findable do
  before do
    stub_const( 'Model', Class.new do
      include Opium::Model::Findable
    end )
    stub_const( 'Game', Class.new do
      include Opium::Model
      field :title, type: String
      field :release_price, type: Float
    end )
  end
  
  describe 'the module' do
    subject { Model }
    
    it { is_expected.to respond_to( :find ).with(1).argument }
    it { is_expected.to respond_to( :first, :each, :each_with_index ) }
    it { is_expected.to respond_to( :map ) }
  end
  
  describe '.find' do
    before do
      stub_request( :get, 'https://api.parse.com/1/classes/Game/abcd1234' ).to_return(
        body: { objectId: 'abcd1234', title: 'Skyrim', releasePrice: 59.99, createdAt: '2011-11-11T12:00:00Z', updatedAt: '2014-11-11T15:13:47Z' }.to_json,
        status: 200,
        headers: { content_type: 'application/json' }
      )
      
      stub_request( :get, 'https://api.parse.com/1/classes/Game/deadbeef' ).to_return(
        body: { code: 404, error: 'Could not locate a "Game" with id "deadbeef"' }.to_json,
        status: 404,
        headers: { content_type: 'application/json' }
      )
    end
    
    let(:result) { Game.find( id ) }
    
    context 'when a model exists' do
      let(:id) { 'abcd1234' }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_an( Opium::Model ) }
      it { expect( result ).to be_a( Game ) }
      it 'has the proper model attributes' do
        expect( result.attributes ).to include( title: 'Skyrim', release_price: 59.99 ) 
      end
    end
    
    context 'when a model does not exist' do
      let(:id) { 'deadbeef' }
      
      it { expect { result }.to raise_exception }
    end
  end
end