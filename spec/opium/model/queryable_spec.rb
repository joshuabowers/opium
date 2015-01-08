require 'spec_helper.rb'

describe Opium::Model::Queryable do
  let( :model ) { Class.new { include Opium::Model::Queryable } }

  describe 'the class' do
    subject { model }
    
    it { should respond_to( :all ) }
    it { should respond_to( :and ) }
    it { should respond_to( :between ) }
    it { should respond_to( :exists ) }
    it { should respond_to( :gt, :gte ).with(1).argument }
    it { should respond_to( :lt, :lte ).with(1).argument }
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
    
    after do
      Opium::Model::Criteria.models.clear
    end
    
    subject { Game }
    
    describe ':where' do
      it 'should return a criteria' do
        subject.where( price: { '$lte' => 5 } ).should be_a( Opium::Model::Criteria )
      end
      
      it 'should set the "where" constraint to the provided value' do
        subject.where( price: { '$lte' => 5 } ).tap do |criteria|
          criteria.constraints.should have_key( 'where' )
          criteria.constraints['where'].should =~ { 'price' => { '$lte' => 5 } }
        end
      end
      
      it 'should deep merge the "where" constraint on successive calls' do
        subject.where( price: { '$lte' => 5 } ).where( price: { '$gte' => 1 } ).tap do |criteria|
          criteria.constraints['where'].should =~ { 'price' => { '$lte' => 5, '$gte' => 1 } }
        end
      end
      
      it 'should ensure that specified fields exist on the model' do
        expect { subject.where( does_not_exist: true ) }.to raise_exception
      end
      
      it 'should map ruby names to parse names and ruby values to parse values' do
        time = Time.now - 1000
        subject.where( created_at: { '$gte' => time } ).tap do |criteria|
          criteria.constraints['where'].should =~ { 'createdAt' => { '$gte' => time.to_parse } }
        end
      end
    end
    
    describe ':gte' do
      it 'should return a criteria' do
        subject.gte( price: 5 ).should be_a( Opium::Model::Criteria )
      end
      
      it 'should add a "$gte" clause to the where constraint for each member of the hash' do
        subject.gte( price: 5, title: 'Skyrim' ).tap do |criteria|
          criteria.constraints.should have_key( 'where' )
          criteria.constraints['where'].should =~ { 'price' => { '$gte' => 5 }, 'title' => { '$gte' => 'Skyrim' } }
        end
      end
    end
    
    describe ':lte' do
      it 'should return a criteria' do
        subject.lte( price: 5 ).should be_a( Opium::Model::Criteria )
      end
      
      it 'should add a "$lte" clause to the where constraint for each member of the hash' do
        subject.lte( price: 5, title: 'Skyrim' ).tap do |criteria|
          criteria.constraints.should have_key( 'where' )
          criteria.constraints['where'].should =~ { 'price' => { '$lte' => 5 }, 'title' => { '$lte' => 'Skyrim' } }
        end
      end
    end

    describe ':gt' do
      it 'should return a criteria' do
        subject.gt( price: 5 ).should be_a( Opium::Model::Criteria )
      end
      
      it 'should add a "$gt" clause to the where constraint for each member of the hash' do
        subject.gt( price: 5, title: 'Skyrim' ).tap do |criteria|
          criteria.constraints.should have_key( 'where' )
          criteria.constraints['where'].should =~ { 'price' => { '$gt' => 5 }, 'title' => { '$gt' => 'Skyrim' } }
        end
      end
    end
    
    describe ':lt' do
      it 'should return a criteria' do
        subject.lt( price: 5 ).should be_a( Opium::Model::Criteria )
      end
      
      it 'should add a "$lt" clause to the where constraint for each member of the hash' do
        subject.lt( price: 5, title: 'Skyrim' ).tap do |criteria|
          criteria.constraints.should have_key( 'where' )
          criteria.constraints['where'].should =~ { 'price' => { '$lt' => 5 }, 'title' => { '$lt' => 'Skyrim' } }
        end
      end
    end
        
    describe ':limit' do
      it 'should return a criteria' do
        subject.limit( 5 ).should be_a( Opium::Model::Criteria )
      end
      
      it 'should set the "limit" constraint to the provided value' do
        subject.limit( 100 ).tap do |criteria|
          criteria.constraints.should have_key( 'limit' )
          criteria.constraints['limit'].should == 100
        end
      end
    end
    
    describe ':skip' do
      it 'should return a criteria' do
        subject.skip( 5 ).should be_a( Opium::Model::Criteria )
      end
      
      it 'should set the "skip" constraint to the provided value' do
        subject.skip( 100 ).tap do |criteria|
          criteria.constraints.should have_key( 'skip' )
          criteria.constraints['skip'].should == 100
        end
      end
    end
    
    describe ':order' do
      it 'should return a criteria' do
        subject.order( title: :asc ).should be_a( Opium::Model::Criteria )
      end
      
      it 'should set the "order" constraint to a string' do
        subject.unscoped.order( title: :asc ).tap do |criteria|
          criteria.constraints.should have_key( 'order' )
          criteria.constraints['order'].should == 'title'
        end
      end
      
      it 'should negate the field if given something which evaluates to "desc", "-1", or "-"' do
        [:desc, -1, '-'].each do |direction|
          subject.unscoped.order( title: direction ).tap do |criteria|
            criteria.constraints['order'].should == '-title'
          end
        end
      end
      
      it 'should combine multiple orderings via a comma' do
        subject.unscoped.order( title: 1, price: -1 ).tap do |criteria|
          criteria.constraints['order'].should == 'title,-price'
        end
      end
      
      it 'should concatenate successive orderings' do
        subject.unscoped.order( title: 1 ).order( price: -1 ).tap do |criteria|
          criteria.constraints['order'].should == 'title,-price'
        end
      end
    end
  end
end