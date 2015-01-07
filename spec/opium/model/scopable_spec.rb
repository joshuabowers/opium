require 'spec_helper.rb'

describe Opium::Model::Scopable do
  let( :model ) { Class.new { include Opium::Model::Scopable } }
  
  describe 'the class' do
    subject { model }
    
    it { should respond_to( :find ).with(1).argument }
    it { should respond_to( :scope ).with(2).arguments }
    it { should respond_to( :default_scope ).with(1).argument }
    it { should respond_to( :scoped ) }
    it { should respond_to( :unscoped ) }
  end
  
  describe 'within a model' do
    before do
      stub_const( 'Game', Class.new do 
        include Opium::Model
        field :title, type: String
        field :release_price, type: Float
        
        scope :under_10, where( release_price: { '$lte' => 10.0 } )
        scope :recent, -> { where( created_at: { '$gte' => Time.now - 3600 } ) }
        scope :under do |limit|
          where( release_price: { '$lte' => limit } )
        end
        
        default_scope order( title: :asc )
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
    
    describe ':scope' do
      it 'should create a method for each scope' do
        Game.should respond_to( :under_10, :recent )
        Game.should respond_to( :under ).with(1).argument 
      end
      
      it 'each scope should be a criteria' do
        Game.under_10.should be_a( Opium::Model::Criteria )
        Game.recent.should be_a( Opium::Model::Criteria )
        Game.under( 20 ).should be_a( Opium::Model::Criteria )
      end
      
      it 'should not allow scopes without a criteria or block' do
        expect { Game.scope :no_criteria_or_block }.to raise_exception(ArgumentError)
      end
    end
    
    describe ':default_scope' do
      it 'should return a criteria if not given a parameter' do
        Game.default_scope.should be_a( Opium::Model::Criteria )
      end
      
      it 'should set a criteria if passed one' do
        criteria = Opium::Model::Criteria.new
        Game.default_scope( criteria ).should == criteria
      end
      
      it 'should accept procs, which yield a criteria' do
        Game.default_scope( -> { Opium::Model::Criteria.new } ).should be_a( Opium::Model::Criteria )
      end
      
      it 'should accept a block, which yields a criteria' do
        Game.default_scope { Opium::Model::Criteria.new }.should be_a( Opium::Model::Criteria )
      end
    end
  end
end