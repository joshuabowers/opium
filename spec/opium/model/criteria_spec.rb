require 'spec_helper.rb'

describe Opium::Model::Criteria do
  before do
    stub_const( 'Game', Class.new do |klass|
      include Opium::Model
      field :title, type: String
      field :price, type: Float
      
      stub('model_name').and_return(ActiveModel::Name.new(klass, nil, 'Game'))
    end )
    
    stub_request( :get, 'https://api.parse.com/1/classes/Game' ).with( body: {} ).
      to_return( status: 200, headers: { 'Content-Type' => 'application/json' }, body: {
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
  
  it { should be_a( Opium::Model::Queryable::ClassMethods ) }
  it { should respond_to( :chain ) }
  it { should respond_to( :constraints, :variables ) }
  it { should respond_to( :update_constraint, :update_variable ).with(2).arguments }
  it { should respond_to( :model, :model_name ) }
  it { should respond_to( :empty? ) }
  it { should respond_to( :to_parse ) }
  it { should respond_to( :each ) }
  it { should respond_to( :to_a ) }
  
  describe ':chain' do
    it 'should return a copy of the object' do
      result = subject.chain
      result.should be_a( Opium::Model::Criteria )
      result.should == subject
      result.should_not equal( subject )
    end
  end
  
  describe ':update_constraint' do    
    it 'should chain the criteria and alter the specified constraint on the copy' do
      result = subject.update_constraint( :order, ['title', 1] )
      result.should be_a( Opium::Model::Criteria )
      result.should_not equal( subject )
      result.should_not == subject
      result.constraints.should have_key( :order )
      result.constraints[:order].should == ['title', 1]
    end
    
    it 'should merge hash-valued constraints' do
      subject.constraints['where'] = { score: { '$lte' => 321 } }
      result = subject.update_constraint( 'where', price: { '$gte' => 123 } )
      result.constraints['where'].should =~ { 'score' => { '$lte' => 321 }, 'price' => { '$gte' => 123 } }
    end
    
    it 'should deep merge hash-valued constraints' do
      subject.constraints['where'] = { score: { '$lte' => 321 } }
      result = subject.update_constraint( 'where', score: { '$gte' => 123 } )
      result.constraints['where'].should =~ { 'score' => { '$lte' => 321, '$gte' => 123 } }
    end
  end
  
  describe ':update_variable' do
    it 'should chain the criteria and alter the specified instance variable on the copy' do
      result = subject.update_variable( :cache, true )
      result.should be_an( Opium::Model::Criteria )
      result.should_not equal( subject )
      result.should_not == subject
      result.constraints.should_not have_key( :cache )
      result.variables.should have_key( :cache )
      result.variables[:cache].should == true
    end
  end
  
  describe ':==' do
    let( :first ) { Opium::Model::Criteria.new( 'Object' ).update_constraint( :order, ['title', 1] ) }
    let( :second ) { Opium::Model::Criteria.new( 'Object' ).update_constraint( :order, ['title', 1] ) }
    
    it 'should not affect :equal?' do
      first.should_not equal( second )
    end
    
    it 'should be based on the criteria constraints' do
      first.should == second
    end
    
    it 'should be based on the criteria variables' do
      third = first.update_variable( :cache, true )
      second.should_not == third
    end
  end
  
  describe ':criteria' do
    subject { Opium::Model::Criteria.new( 'Object' ).update_constraint( :order, ['title', 1] ) }
    
    it 'should be == to self' do
      subject.criteria.should == subject
    end
    
    it 'should not be a duplicate of self' do
      subject.criteria.should equal( subject )
    end
  end
  
  describe ':model' do
    subject { Opium::Model::Criteria.new( 'Game' ) }
    
    it 'should be the constantized version of :model_name' do
      subject.model_name.should == 'Game'
      subject.model.should == Game
    end
  end
  
  describe ':empty?' do
    it 'should be empty if there are no constraints' do
      subject.constraints.clear
      subject.should be_empty
    end
    
    it 'should not be empty if it has constraints' do
      subject.constraints[:limit] = 10
      subject.should_not be_empty
    end
  end
  
  describe ':each' do
    subject { Game.criteria }
    
    describe 'without a block' do
      it 'should return an Enumerator' do
        subject.each.should be_a( Enumerator )
      end
    end
    
    describe 'with a block' do
      it "should call its :model's :http_get" do
        subject.model.should receive(:http_get).with(query: subject.constraints)
        subject.each {|model| }
      end
      
      it 'should yield to its block any results it finds' do
        expect {|b| subject.each &b }.to yield_control.twice
      end
      
      it 'should yield to its block Opium::Model objects (Game in context)' do
        expect {|b| subject.each &b }.to yield_successive_args(Opium::Model, Opium::Model)
        expect {|b| subject.each &b }.to yield_successive_args(Game, Game)
      end
      
      it "should call its :model's :http_get when counting" do
        subject.model.should receive(:http_get).with(query: subject.constraints).twice
        subject.each {|model| }
        subject.each.count
      end
    end
    
    describe 'if :cache?' do
      subject { Game.criteria.cache }
      
      it 'each should call its :model\'s :http_get only once' do
        subject.model.should receive(:http_get).with(query: subject.constraints).once
        subject.each {|model| }
        subject.each {|model| }
      end
      
      it 'should yield to its block any results it finds' do
        expect {|b| subject.each &b }.to yield_control.twice
        expect {|b| subject.each &b }.to yield_control.twice
      end
      
      it 'should yield to its block Opium::Model objects (Game in context)' do
        expect {|b| subject.each &b }.to yield_successive_args(Opium::Model, Opium::Model)
        expect {|b| subject.each &b }.to yield_successive_args(Game, Game)
      end
      
      it "should not call its :model's :http_get when counting" do
        subject.model.should receive(:http_get).with(query: subject.constraints).once
        subject.each {|model| }
        subject.each.count
      end
    end
  end
  
  describe ':uncache' do
    subject { Game.criteria.cache }
    
    it 'each should call its :model\'s :http_get twice' do
      subject.model.should receive(:http_get).with(query: subject.constraints).twice
      subject.each {|model| }
      subject.uncache.each {|model| }
    end
    
    it 'should delete its @cache' do
      subject.each {|model| }
      subject.uncache.instance_variable_get(:@cache).should be_nil
    end
  end
    
  describe ':to_parse' do
    it 'should be a hash' do
      Game.criteria.to_parse.should be_a( Hash )
    end
    
    it 'should have a "query" key, if a "where" constraint exists, containing a "where" and a "className"' do
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