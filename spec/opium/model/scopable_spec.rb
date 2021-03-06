require 'spec_helper.rb'

describe Opium::Model::Scopable do
  let( :model ) { Class.new { include Opium::Model::Scopable } }
  
  describe 'the class' do
    subject { model }
    
    it { should respond_to( :criteria ) }
    it { should respond_to( :scope ).with(2).arguments }
    it { should respond_to( :default_scope ).with(1).argument }
    it { should respond_to( :scoped ) }
    it { should respond_to( :unscoped ) }
    it { should respond_to( :with_scope ).with(1).argument }
  end
  
  describe 'within a model' do
    before do
      stub_const( 'Game', Class.new do |klass|
        include Opium::Model
        field :title, type: String
        field :release_price, type: Float
        
        stub('model_name').and_return(ActiveModel::Name.new(klass, nil, 'Game'))
        
        default_scope order( title: :asc )
        
        scope :under_10, where( release_price: { '$lte' => 10.0 } )
        scope :recent, -> { where( created_at: { '$gte' => Time.now - 3600 } ) }
        scope :under do |limit|
          where( release_price: { '$lte' => limit } )
        end
      end )
    end
    
    describe ':criteria' do
      it 'should be the :default_scope' do
        Game.criteria.should == Game.default_scope 
        Game.criteria.should == Game.criteria
      end
      
      it 'should not be duplicated between calls' do
        Game.criteria.should equal( Game.criteria )
      end
    end
    
    describe ':unscoped' do
      it 'should return an empty Criteria' do
        criteria = Game.unscoped
        criteria.should be_a( Opium::Model::Criteria )
        criteria.should_not be_constraints
      end
      
      it 'if passed a block, should make scope calls within the block be unscoped, and return the result of the block' do
        Game.default_scope.constraints.keys.should include('order')
        criteria = Game.unscoped do
          Game.limit( 10 ).tap do |inner|
            inner.constraints.should =~ { 'limit' => 10, 'count' => 1 }
          end
        end
        criteria.should be_a( Opium::Model::Criteria )
        criteria.constraints.should =~ { 'limit' => 10, 'count' => 1 }
        criteria.constraints.keys.should_not include('order')
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
      
      it 'should have a :model equal to its creating model' do
        Game.default_scope.model_name.should == 'Game'
      end
      
      it 'should set a criteria if passed one' do
        expected = Game.unscoped
        Game.default_scope( expected )
        Game.default_scope.should == expected
      end
      
      it 'should accept procs, which yield a criteria' do
        expected = Game.unscoped.limit( 5 )
        Game.default_scope( -> { Game.limit( 5 ) } ).should be_a( Opium::Model::Criteria )
        Game.default_scope.should == expected
      end
      
      it 'should accept a block, which yields a criteria' do
        expected = Game.unscoped.limit( 5 )
        Game.default_scope { Game.limit( 5 ) }.should be_a( Opium::Model::Criteria )
        Game.default_scope.should == expected
      end
    end
    
    describe ':with_scope' do
    end
  end
end