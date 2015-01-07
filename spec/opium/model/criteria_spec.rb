require 'spec_helper.rb'

describe Opium::Model::Criteria do
  it { should be_a( Opium::Model::Queryable::ClassMethods ) }
  it { should respond_to( :constraints ) }
  it { should respond_to( :update_constraint ).with(2).arguments }
  
  describe ':update_constraint' do
    subject { Opium::Model::Criteria.new }
    
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
    let( :first ) { Opium::Model::Criteria.new.update_constraint( :order, ['title', 1] ) }
    let( :second ) { Opium::Model::Criteria.new.update_constraint( :order, ['title', 1] ) }
    
    it 'should not affect :equal?' do
      first.should_not equal( second )
    end
    
    it 'should be based on the criteria constraints' do
      first.should == second
    end
  end
  
  describe ':criteria' do
    subject { Opium::Model::Criteria.new.update_constraint( :order, ['title', 1] ) }
    
    it 'should be == to self' do
      subject.criteria.should == subject
    end
    
    it 'should be a duplicate of self' do
      subject.criteria.should_not equal( subject )
    end
  end
end