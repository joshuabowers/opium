require 'spec_helper.rb'

describe Opium::Model::Criteria do
  subject { Opium::Model::Criteria.new( 'Object' ) }
  
  it { should be_a( Opium::Model::Queryable::ClassMethods ) }
  it { should respond_to( :constraints ) }
  it { should respond_to( :update_constraint ).with(2).arguments }
  it { should respond_to( :model, :model_name ) }
  it { should respond_to( :empty? ) }
  
  describe ':update_constraint' do    
    it 'should alter the specified constraint, and return the Criteria' do
      result = subject.update_constraint( :order, ['title', 1] )
      result.should be_a( Opium::Model::Criteria )
      result.should equal( subject )
      subject.constraints.should have_key( :order )
      subject.constraints[:order].should == ['title', 1]
    end
    
    it 'should merge hash-valued constraints' do
      subject.constraints['where'] = { score: { '$lte' => 321 } }
      subject.update_constraint( 'where', price: { '$gte' => 123 } )
      subject.constraints['where'].should =~ { 'score' => { '$lte' => 321 }, 'price' => { '$gte' => 123 } }
    end
    
    it 'should deep merge hash-valued constraints' do
      subject.constraints['where'] = { score: { '$lte' => 321 } }
      subject.update_constraint( 'where', score: { '$gte' => 123 } )
      subject.constraints['where'].should =~ { 'score' => { '$lte' => 321, '$gte' => 123 } }
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
    
    it 'should be a duplicate of self' do
      subject.criteria.should_not equal( subject )
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
      subject.update_constraint( :limit, 10 )
      subject.should_not be_empty
    end
  end
end