require 'spec_helper.rb'

describe Opium::Model::Queryable do
  let( :model ) { Class.new { include Opium::Model::Queryable } }

  context 'when included in a class' do
    subject { model }

    it { is_expected.to respond_to( :all, :all_in ).with(1).argument }
    it { is_expected.to respond_to( :and ).with(1).argument }
    it { is_expected.to respond_to( :between ).with(1).argument }
    it { is_expected.to respond_to( :exists ).with(1).argument }
    it { is_expected.to respond_to( :gt, :gte ).with(1).argument }
    it { is_expected.to respond_to( :lt, :lte ).with(1).argument }
    it { is_expected.to respond_to( :in, :any_in, :nin ).with(1).argument }
    it { is_expected.to respond_to( :ne ).with(1).argument }
    it { is_expected.to respond_to( :or ).with(1).argument }
    it { is_expected.to respond_to( :select, :dont_select ).with(1).argument }
    it { is_expected.to respond_to( :keys, :pluck ).with(1).argument }
    it { is_expected.to respond_to( :where ).with(1).argument }
    it { is_expected.to respond_to( :order ).with(1).argument }
    it { is_expected.to respond_to( :limit, :skip ).with(1).argument }
    it { is_expected.to respond_to( :cache, :uncache, :cached? ) }
    it { is_expected.to respond_to( :count, :total_count ) }
  end

  context 'within a model' do
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

    describe '.where' do
      it 'returns a criteria' do
        subject.where( price: { '$lte' => 5 } ).should be_a( Opium::Model::Criteria )
      end

      it 'sets the "where" constraint to the provided value' do
        subject.where( price: { '$lte' => 5 } ).tap do |criteria|
          criteria.constraints.should have_key( 'where' )
          criteria.constraints['where'].should =~ { 'price' => { '$lte' => 5 } }
        end
      end

      it 'deep merges the "where" constraint on successive calls' do
        subject.where( price: { '$lte' => 5 } ).where( price: { '$gte' => 1 } ).tap do |criteria|
          criteria.constraints['where'].should =~ { 'price' => { '$lte' => 5, '$gte' => 1 } }
        end
      end

      it 'ensures that specified fields exist on the model' do
        expect { subject.where( does_not_exist: true ) }.to raise_exception
      end

      it 'maps ruby names to parse names and ruby values to parse values' do
        time = Time.now - 1000
        subject.where( created_at: { '$gte' => time } ).tap do |criteria|
          criteria.constraints['where'].should =~ { 'createdAt' => { '$gte' => time.to_parse } }
        end
      end

      it 'converts constraint values to the field type' do
        subject.where( price: '14.99' ).tap do |criteria|
          expect( criteria.constraints['where']['price'] ).to eq 14.99
        end
      end
    end

    shared_examples_for 'a chainable criteria clause' do |method|
      describe ".#{method}" do
        it 'should return a criteria' do
          subject.send( method, price: 5, title: 'Skyrim' ).should be_a( Opium::Model::Criteria )
        end

        it "should add a \"$#{method}\" clause to the where constraint for each member of the hash" do
          subject.send( method, price: 5, title: 'Skyrim' ).tap do |criteria|
            criteria.constraints.should have_key( 'where' )
            criteria.constraints['where'].should =~ { 'price' => { "$#{method}" => 5 }, 'title' => { "$#{method}" => 'Skyrim' } }
          end
        end
      end
    end

    it_should_behave_like 'a chainable criteria clause', :gte
    it_should_behave_like 'a chainable criteria clause', :lte
    it_should_behave_like 'a chainable criteria clause', :gt
    it_should_behave_like 'a chainable criteria clause', :lt
    it_should_behave_like 'a chainable criteria clause', :ne

    shared_examples_for 'a chainable array-valued criteria clause' do |method|
      describe ":#{method}" do
        it 'should return a criteria' do
          subject.send( method, price: [1, 2, 3, 4] ).should be_a( Opium::Model::Criteria )
        end

        it "should add a \"$#{method}\" clause to the where constraint for each member of the hash, converting pair values to arrays" do
          subject.send( method, price: 1..4, title: ['Skyrim', 'Oblivion'] ).tap do |criteria|
            criteria.constraints.should have_key( 'where' )
            criteria.constraints['where'].should =~ { 'price' => { "$#{method}" => [1, 2, 3, 4] }, 'title' => { "$#{method}" => ['Skyrim', 'Oblivion'] } }
          end
        end
      end
    end

    it_should_behave_like 'a chainable array-valued criteria clause', :all
    it_should_behave_like 'a chainable array-valued criteria clause', :in
    it_should_behave_like 'a chainable array-valued criteria clause', :nin

    shared_examples_for 'an aliased method' do |aliased, method|
      describe ":#{aliased}" do
        it "should be an alias for :#{method}" do
          subject.method( aliased ).should == subject.method( method )
        end
      end
    end

    it_should_behave_like 'an aliased method', :and, :where
    it_should_behave_like 'an aliased method', :all_in, :all
    it_should_behave_like 'an aliased method', :any_in, :in

    describe '.all' do
      context 'when no parameter is given' do
        let(:result) { subject.all }

        it { expect { result }.to_not raise_exception }
        it { expect( result ).to be_a Opium::Model::Criteria }
        it { expect( result ).to eq subject.criteria }
      end
    end

    describe ':exists' do
      it 'should return a criteria' do
        subject.exists( price: true ).should be_a( Opium::Model::Criteria )
      end

      it 'should add a "$exist" clause for each hash pair, set to the truthiness of the pair value' do
        subject.exists( price: true, title: 'no' ).tap do |criteria|
          criteria.constraints.should have_key( 'where' )
          criteria.constraints['where'].should =~ { 'price' => { '$exists' => true }, 'title' => { '$exists' => false } }
        end
      end
    end

    describe '#between' do
      context 'with a inclusive range' do
        subject { Game.between( price: 5..10 ) }

        it { is_expected.to be_an( Opium::Model::Criteria ) }

        it { expect( subject.criteria.constraints ).to include(:where) }

        it 'adds a clause on the key' do
          expect( subject.criteria.constraints[:where] ).to include(:price)
        end

        it 'adds a "$gte" clause to the key' do
          expect( subject.criteria.constraints[:where][:price] ).to include( '$gte' => 5 )
        end

        it 'adds an "$lte" clause to the key' do
          expect( subject.criteria.constraints[:where][:price] ).to include( '$lte' => 10 )
        end

        it 'does not add an "$lt" clause to the key' do
          expect( subject.criteria.constraints[:where][:price].keys ).to_not include( '$lt' )
        end
      end

      context 'with an exclusive range' do
        subject { Game.between( price: 5...10 ) }

        it 'adds a "$gte" clause to the key' do
          expect( subject.criteria.constraints[:where][:price] ).to include( '$gte' => 5 )
        end

        it 'adds an "$lt" clause to the key' do
          expect( subject.criteria.constraints[:where][:price] ).to include( '$lt' => 10 )
        end

        it 'does not add an "$lte" clause to the key' do
          expect( subject.criteria.constraints[:where][:price].keys ).to_not include( '$lte' )
        end
      end
    end

    describe ':select' do
      it 'should return a criteria' do
        subject.select( title: subject.between( price: 5..10 ).keys( :title ) ).should be_a( Opium::Model::Criteria )
      end

      it 'should add a "$select" clause for each hash key, setting the value to a query expression based off the pair-value criteria' do
        subject.select( title: subject.between( price: 5..10 ).keys( :title ) ).tap do |criteria|
          criteria.constraints.should have_key( 'where' )
          criteria.constraints['where'].should =~ {
            'title' => { '$select' => {
              'query' => { 'className' => 'Game', 'where' => { 'price' => { '$gte' => 5, '$lte' => 10 } } },
              'key' => 'title'
              } }
          }
        end
      end
    end

    describe ':dont_select' do
      it 'should return a criteria' do
        subject.dont_select( title: subject.between( price: 5..10 ).keys( :title ) ).should be_a( Opium::Model::Criteria )
      end

      it 'should add a "$donSelect" clause for each hash key, setting the value to a query expression based off the pair-value criteria' do
        subject.dont_select( title: subject.between( price: 5..10 ).keys( :title ) ).tap do |criteria|
          criteria.constraints.should have_key( 'where' )
          criteria.constraints['where'].should =~ {
            'title' => { '$dontSelect' => {
              'query' => { 'className' => 'Game', 'where' => { 'price' => { '$gte' => 5, '$lte' => 10 } } },
              'key' => 'title'
              } }
          }
        end
      end
    end

    describe ':or' do
      it 'should return a criteria' do
        subject.or( { title: 'Skyrim' }, { title: 'Oblivion' } ).should be_a( Opium::Model::Criteria )
      end

      it 'should add an "$or" clause to the "where" constraint, whose contents are an array of all specified subqueries' do
        subject.or( { title: 'Skyrim' }, { title: 'Oblivion' } ).tap do |criteria|
          criteria.constraints.should have_key( 'where' )
          criteria.constraints['where'].should =~ {
            '$or' => [ { 'title' => 'Skyrim' }, { 'title' => 'Oblivion' } ]
          }
        end
      end
    end

    describe ':keys' do
      it 'should return a criteria' do
        subject.keys( :price ).should be_a( Opium::Model::Criteria )
      end

      it 'should set the "keys" constraint to the provided set of fields, whose names should be parsized' do
        subject.keys( :price, :updated_at ).tap do |criteria|
          criteria.constraints.should have_key( 'keys' )
          criteria.constraints['keys'].should == 'price,updatedAt'
        end
      end

      it 'should raise if a specified field does not exist' do
        expect { subject.keys( :does_not_exist ) }.to raise_exception
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

    describe ':cached?' do
      it 'should be false on a non-cached criteria' do
        Game.criteria.cached?.should be_falsey
      end
    end

    describe ':cache' do
      after { subject.uncache }

      it 'should return a criteria' do
        subject.cache.should be_an( Opium::Model::Criteria )
      end

      it 'should cause :cached? to return true' do
        subject.cache.cached?.should == true
      end
    end

    describe ':uncache' do
      it 'should return a criteria' do
        subject.uncache.should be_an( Opium::Model::Criteria )
      end

      it 'should cause :cached? to return false' do
        subject.uncache.cached?.should == false
      end
    end
  end
end
