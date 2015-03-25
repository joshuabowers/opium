require 'spec_helper.rb'

describe Opium::Model::Criteria do
  before do
    stub_const( 'Game', Class.new do |klass|
      include Opium::Model
      field :title, type: String
      field :price, type: Float
      
      stub('model_name').and_return(ActiveModel::Name.new(klass, nil, 'Game'))
    end )
    
    stub_request( :get, 'https://api.parse.com/1/classes/Game?count=1' ).with( body: {} ).
      to_return( status: 200, headers: { 'Content-Type' => 'application/json' }, body: {
        count: 10,
        results: [
          { objectId: 'abcd1234', createdAt: Time.now - 50000, title: 'Skyrim', price: 45.99 },
          { objectId: 'efgh5678', createdAt: Time.now - 10000, title: 'Terraria', price: 15.99 }
        ]
      }.to_json )
  end
  
  after do
    Opium::Model::Criteria.models.clear
  end
  
  subject { Opium::Model::Criteria.new( 'Object' ) }
  
  it { is_expected.to be_a( Opium::Model::Queryable::ClassMethods ) }
  it { is_expected.to respond_to( :chain ) }
  it { is_expected.to respond_to( :constraints, :variables ) }
  it { is_expected.to respond_to( :update_constraint, :update_variable ).with(2).arguments }
  it { is_expected.to respond_to( :constraints?, :variables? ) }
  it { is_expected.to respond_to( :model, :model_name ) }
  it { is_expected.to respond_to( :empty? ) }
  it { is_expected.to respond_to( :to_parse ) }
  it { is_expected.to respond_to( :each ) }
  it { is_expected.to respond_to( :to_a ) }
  it { is_expected.to respond_to( :count, :total_count ) }
  
  describe '#chain' do
    it 'returns a copy of the object' do
      result = subject.chain
      result.should be_a( Opium::Model::Criteria )
      result.should == subject
      result.should_not equal( subject )
    end
  end
  
  describe '#update_constraint' do    
    it 'chains the criteria and alter the specified constraint on the copy' do
      result = subject.update_constraint( :order, ['title', 1] )
      result.should be_a( Opium::Model::Criteria )
      result.should_not equal( subject )
      result.should_not == subject
      result.constraints.should have_key( :order )
      result.constraints[:order].should == ['title', 1]
    end
    
    it 'merges hash-valued constraints' do
      subject.constraints['where'] = { score: { '$lte' => 321 } }
      result = subject.update_constraint( 'where', price: { '$gte' => 123 } )
      result.constraints['where'].should =~ { 'score' => { '$lte' => 321 }, 'price' => { '$gte' => 123 } }
    end
    
    it 'deep merges hash-valued constraints' do
      subject.constraints['where'] = { score: { '$lte' => 321 } }
      result = subject.update_constraint( 'where', score: { '$gte' => 123 } )
      result.constraints['where'].should =~ { 'score' => { '$lte' => 321, '$gte' => 123 } }
    end
  end
  
  describe '#update_variable' do
    it 'chains the criteria and alter the specified instance variable on the copy' do
      result = subject.update_variable( :cache, true )
      result.should be_an( Opium::Model::Criteria )
      result.should_not equal( subject )
      result.should_not == subject
      result.constraints.should_not have_key( :cache )
      result.variables.should have_key( :cache )
      result.variables[:cache].should == true
    end
  end
  
  describe '#==' do
    let( :first ) { Opium::Model::Criteria.new( 'Object' ).update_constraint( :order, ['title', 1] ) }
    let( :second ) { Opium::Model::Criteria.new( 'Object' ).update_constraint( :order, ['title', 1] ) }
    
    it 'should not affect :equal?' do
      first.should_not equal( second )
    end
    
    it 'is based on the criteria constraints' do
      first.should == second
    end
    
    it 'is based on the criteria variables' do
      third = first.update_variable( :cache, true )
      second.should_not == third
    end
  end
  
  describe '#criteria' do
    subject { Opium::Model::Criteria.new( 'Object' ).update_constraint( :order, ['title', 1] ) }
    
    it 'is == to self' do
      subject.criteria.should == subject
    end
    
    it 'is not a duplicate of self' do
      subject.criteria.should equal( subject )
    end
  end
  
  describe '#model' do
    subject { Opium::Model::Criteria.new( 'Game' ) }
    
    it 'is the constantized version of :model_name' do
      subject.model_name.should == 'Game'
      subject.model.should == Game
    end
  end
  
  describe '#empty?' do
    before do
      stub_request(:get, "https://api.parse.com/1/classes/Game?count=1&where=%7B%22price%22:%7B%22$gte%22:9000.0%7D%7D").
        to_return(
          status: 200, 
          body: {
            count: 0,
            results: []
          }.to_json, 
          headers: { content_type: 'application/json' }
        )
    end
    
    subject { Game.criteria }
    
    it { expect { subject.empty? }.to_not raise_exception }
    it do
      expect( subject ).to receive(:count).once.and_call_original
      subject.empty?
    end
    
    it 'returns true if count is 0' do
      subject.gte( price: 9000.0 ).empty?.should == true
    end
    
    it 'returns false if count is not 0' do
      subject.criteria.empty? == false
    end
  end
  
  describe '#constraints?' do
    it 'returns true if count is not the only constraint' do
      Game.limit( 10 ).constraints?.should == true
    end
    
    it 'returns false if count is the only constraint' do
      Game.criteria.constraints?.should == false
    end
  end
  
  describe '#each' do
    subject { Game.criteria }
    
    context 'without a block' do
      it 'returns an Enumerator' do
        subject.each.should be_a( Enumerator )
      end
    end
    
    context 'with a block' do
      it "calls its :model's :http_get" do
        subject.model.should receive(:http_get).with(query: subject.constraints)
        subject.each {|model| }
      end
      
      it 'yields to its block any results it finds' do
        expect {|b| subject.each &b }.to yield_control.twice
      end
      
      it 'yields to its block Opium::Model objects (Game in context)' do
        expect {|b| subject.each &b }.to yield_successive_args(Opium::Model, Opium::Model)
        expect {|b| subject.each &b }.to yield_successive_args(Game, Game)
      end
      
      it "calls its :model's :http_get when counting" do
        subject.model.should receive(:http_get).with(query: subject.constraints).twice
        subject.each {|model| }
        subject.each.count
      end
    end
    
    context 'when #cached?' do
      subject { Game.criteria.cache }
      
      it 'calls its :model\'s :http_get only once' do
        subject.model.should receive(:http_get).with(query: subject.constraints).once
        subject.each {|model| }
        subject.each {|model| }
      end
      
      it 'yields to its block any results it finds' do
        expect {|b| subject.each &b }.to yield_control.twice
        expect {|b| subject.each &b }.to yield_control.twice
      end
      
      it 'yields to its block Opium::Model objects (Game in context)' do
        expect {|b| subject.each &b }.to yield_successive_args(Opium::Model, Opium::Model)
        expect {|b| subject.each &b }.to yield_successive_args(Game, Game)
      end
      
      it "does not call its :model's :http_get when counting" do
        subject.model.should receive(:http_get).with(query: subject.constraints).once
        subject.each {|model| }
        subject.each.count
      end
    end
  end
  
  describe '#uncache' do
    subject { Game.criteria.cache }
    
    it 'causes #each to call its :model\'s :http_get twice' do
      subject.model.should receive(:http_get).with(query: subject.constraints).twice
      subject.each {|model| }
      subject.uncache.each {|model| }
    end
    
    it 'deletes its @cache' do
      subject.each {|model| }
      subject.uncache.instance_variable_get(:@cache).should be_nil
    end
  end
  
  describe '#count' do
    subject { Game.criteria }
    
    it { expect { subject.count }.to_not raise_exception }
    it do
      expect( subject ).to receive(:each).twice.and_call_original
      subject.count
    end
    
    it 'equals the number of items from #each' do
      expect( subject.count ).to be == 2
    end
  end
  
  describe '#total_count' do
    subject { Game.criteria }
    
    it { expect { subject.total_count }.to_not raise_exception }
    it do
      expect( subject ).to receive(:each).twice.and_call_original
      subject.total_count
    end
    
    it "equals the 'count' result returned from parse" do
      expect( subject.total_count ).to be == 10
    end
  end
    
  describe '#to_parse' do
    subject { Game.criteria }
    
    it { expect( subject.to_parse ).to be_a( Hash ) }
    
    it 'has a "query" key, if a "where" constraint exists, containing a "where" and a "className"' do
      Game.between( price: 5..10 ).to_parse.tap do |criteria|
        criteria.should have_key( 'query' )
        criteria['query'].should =~ { 'where' => { 'price' => { '$gte' => 5, '$lte' => 10 } }, 'className' => 'Game' }
      end
    end
    
    it 'should have a "key" key, if a "keys" constraint exists' do
      Game.keys( :price ).to_parse.tap do |criteria|
        criteria.should have_key( 'key' )
        criteria['key'].should == 'price'
      end
    end
  end
end