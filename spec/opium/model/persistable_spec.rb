require 'spec_helper.rb'

describe Opium::Model::Persistable do
  let( :model ) { Class.new { include Opium::Model::Persistable } }

  describe 'in a model' do
    subject { model }
  
    it { should respond_to( :destroy_all ).with(1).argument }
    it { should respond_to( :delete_all ).with(1).argument }
  end
    
  describe 'instance' do
    subject { model.new }
    
    it { should respond_to( :save ).with(1).argument }
    it { should respond_to( :destroy ) }
    it { should respond_to( :delete ) }
    it { should respond_to( :new_record? ) }
    it { should respond_to( :persisted? ) }
  end
  
  describe 'within a model' do
    before do
      stub_const( 'Book', Class.new do
        include Opium::Model
        field :title, type: String
        field :author, type: String
        field :pages, type: Integer
        field :price, type: Float        
      end )
    end
    
    describe 'when saving a new model' do
      subject { Book.new( title: 'Little Brother', author: 'Cory Doctorow', pages: 382, price: 17.95 ) }
      
      its(:id) { should be_nil }
      its(:created_at) { should be_nil }
      
      it { should be_a_new_record }
      it { should_not be_persisted }
      
      it 'should have its object_id and created_at fields updated' do
        stub_request( :post, 'https://api.parse.com/1/classes/Book' ).with(
          body: { title: 'Little Brother', author: 'Cory Doctorow', pages: 382, price: 17.95 },
          headers: { 'Content-Type' => 'application/json' }
        ).to_return( 
          body: { objectId: 'abcd1234', createdAt: Time.now.to_s }.to_json, 
          status: 200, 
          headers: { 'Content-Type' => 'application/json', Location: 'https://api.parse.com/1/classes/Book/abcd1234' } 
        )
        
        subject.save.should == true
        subject.should_not be_a_new_record
        subject.should be_persisted
      end
    end
  end
end