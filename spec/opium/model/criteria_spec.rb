require 'spec_helper.rb'

describe Opium::Model::Criteria do
  after do
    Opium::Model::Criteria.models.clear
  end
  
  subject { Opium::Model::Criteria.new( 'Object' ) }
  
  it { should be_a( Opium::Model::Queryable::ClassMethods ) }
  it { should respond_to( :chain ) }
  it { should respond_to( :constraints ) }
  it { should respond_to( :update_constraint ).with(2).arguments }
  it { should respond_to( :model, :model_name ) }
  it { should respond_to( :empty? ) }
  
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
  
  describe ':==' do
    let( :first ) { Opium::Model::Criteria.new( 'Object' ).update_constraint( :order, ['title', 1] ) }
    let( :second ) { Opium::Model::Criteria.new( 'Object' ).update_constraint( :order, ['title', 1] ) }
    
    it 'should not affect :equal?' do
      first.should_not equal( second )
    end
    
    it 'should be based on the criteria constraints' do
      first.should == second
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
    before do
      stub_const( 'Game', Class.new do
        include Opium::Model
      end )
    end
    
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
end