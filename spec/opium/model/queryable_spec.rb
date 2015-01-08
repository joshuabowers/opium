require 'spec_helper.rb'

describe Opium::Model::Queryable do
  let( :model ) { Class.new { include Opium::Model::Queryable } }

  describe 'the class' do
    subject { model }
    
    it { should respond_to( :all ) }
    it { should respond_to( :and ) }
    it { should respond_to( :between ) }
    it { should respond_to( :exists ) }
    it { should respond_to( :gt, :gte ) }
    it { should respond_to( :lt, :lte ) }
    it { should respond_to( :in, :nin ) }
    it { should respond_to( :ne ) }
    it { should respond_to( :or, :nor ) }
    it { should respond_to( :select, :dont_select ) }
    it { should respond_to( :where ).with(1).argument }
    it { should respond_to( :order ).with(1).argument }
    it { should respond_to( :limit, :skip ).with(1).argument }
  end
  
  describe 'within a model' do
    before do
      stub_const( 'Game', Class.new do
        include Opium::Model
        field :title, type: String
        field :price, type: Float
        
        stub(:model_name).and_return( 'Game' )
        
        default_scope order( title: :asc )
      end )
    end
    
    subject { Game }
        
    describe ':limit' do
      it 'should return a criteria' do
        subject.limit( 5 ).should be_a( Opium::Model::Criteria )
      end
      
      it 'should set the "limit" constraint to the provided value' do
        criteria = subject.limit( 100 )
        criteria.constraints.should have_key( 'limit' )
        criteria.constraints['limit'].should == 100
      end
    end
    
    describe ':skip' do
      it 'should return a criteria' do
        subject.skip( 5 ).should be_a( Opium::Model::Criteria )
      end
      
      it 'should set the "skip" constraint to the provided value' do
        criteria = subject.skip( 100 )
        criteria.constraints.should have_key( 'skip' )
        criteria.constraints['skip'].should == 100
      end
    end
    
    describe ':order' do
      it 'should return a criteria' do
        subject.order( title: :asc ).should be_a( Opium::Model::Criteria )
      end
      
      it 'should set the "order" constraint to string' do
        criteria = subject.unscoped.order( title: :asc )
        criteria.constraints.should have_key( 'order' )
        criteria.constraints['order'].should == 'title'
      end
      
      it 'should negate the field if given something which evaluates to "desc", "-1", or "-"' do
        [:desc, -1, '-'].each do |direction|
          criteria = subject.unscoped.order( title: direction )
          criteria.constraints['order'].should == '-title'
        end
      end
      
      it 'should combine multiple orderings via a comma' do
        criteria = subject.unscoped.order( title: 1, price: -1 )
        criteria.constraints['order'].should == 'title,-price'
      end
      
      it 'should concatenate successive orderings' do
        criteria = subject.unscoped.order( title: 1 ).order( price: -1 )
        criteria.constraints['order'].should == 'title,-price'
      end
    end
  end
end