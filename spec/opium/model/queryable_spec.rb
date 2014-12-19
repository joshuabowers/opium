require 'spec_helper.rb'

describe Opium::Model::Queryable do
  let( :model ) { Class.new { include Opium::Model::Queryable } }

  describe 'in a model' do
    subject { model }
    
    it { should respond_to( :find ).with(1).argument }
    it { should respond_to( :where ).with(1).argument }
  end
  
  describe 'within a model' do
    before do
      stub_const( 'Game', Class.new do 
        include Opium::Model
        field :title, type: String
        field :release_price, type: Float
      end )
    end
    
    describe ':find' do
      before do
        stub_request( :get, 'https://api.parse.com/1/classes/Game/abcd1234' ).to_return(
          body: { objectId: 'abcd1234', title: 'Skyrim', releasePrice: 59.99, createdAt: '2011-11-11T12:00:00Z', updatedAt: '2014-11-11T15:13:47Z' }.to_json,
          status: 200,
          headers: { 'Content-Type' => 'application/json' }
        )
        
        stub_request( :get, 'https://api.parse.com/1/classes/Game/deadbeef' ).to_return(
          body: { code: 404, error: 'Could not locate a "Game" with id "deadbeef"' }.to_json,
          status: 404,
          headers: { 'Content-Type' => 'application/json' }
        )
      end
      
      it 'should return a model if it exists' do
        result = Game.find( 'abcd1234' )
        result.should be_an( Opium::Model )
        result.should be_a( Game )
        result.attributes.should include( title: 'Skyrim', release_price: 59.99 )
      end
      
      it 'should raise an error if an id does not exist' do
        expect { Game.find( 'deadbeef' ) }.to raise_exception
      end
    end
  end
end