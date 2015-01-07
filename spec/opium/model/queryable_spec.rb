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
    it { should respond_to( :criteria ) }
    it { should respond_to( :order ).with(1).argument }
    it { should respond_to( :limit, :skip ) }
  end
  
  describe 'within a model' do
    before do
      stub_const( 'Game', Class.new do
        include Opium::Model
        field :title, type: String
        field :price, type: Float
        
        default_scope order( title: :asc )
      end )
    end
    
    describe ':criteria' do
      subject { Game }
      it 'should be the :default_scope' do
        subject.criteria.should == subject.default_scope 
        subject.criteria.should == subject.criteria
      end
      it 'should be duplicated between calls' do
        subject.criteria.should_not equal( subject.default_scope ) 
        subject.criteria.should_not equal( subject.criteria )
      end
    end
  end
end