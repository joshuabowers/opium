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
    it { should respond_to( :save!).with(0).arguments }
    it { should respond_to( :destroy ) }
    it { should respond_to( :delete ) }
    it { should respond_to( :new_record? ) }
    it { should respond_to( :persisted? ) }
  end
  
  describe 'within a model' do
    before do
      stub_const( 'Game', Class.new do
        include Opium::Model
        field :title, type: String
        field :released_on, type: Date
        field :release_price, type: Float
        
        validates :release_price, numericality: { greater_than: 0 }
      end )
    end
    
    describe 'when saving a new model' do
      subject { Game.new( title: 'Skyrim', released_on: '2011-11-11', release_price: '59.99' ) }
      
      its(:id) { should be_nil }
      its(:created_at) { should be_nil }
      
      it { should be_a_new_record }
      it { should_not be_persisted }
      
      it 'should have its object_id and created_at fields updated' do
        stub_request( :post, 'https://api.parse.com/1/classes/Game' ).with(
          body: { title: 'Skyrim', releasedOn: { '__type' => 'Date', 'iso' => '2011-11-11' }, releasePrice: 59.99 },
          headers: { 'Content-Type' => 'application/json' }
        ).to_return( 
          body: { objectId: 'abcd1234', createdAt: Time.now.to_s }.to_json, 
          status: 200, 
          headers: { 'Content-Type' => 'application/json', Location: 'https://api.parse.com/1/classes/Game/abcd1234' } 
        )
        
        subject.save.should == true
        subject.should_not be_a_new_record
        subject.should be_persisted
      end
    end
    
    describe 'when saving an existing model' do
      subject { Game.new( id: 'abcd1234', created_at: Time.now - 3600, title: 'Skyrim' ) }
      
      its(:id) { should_not be_nil }
      its(:created_at) { should_not be_nil }
      
      it 'should have its updated_at fields updated' do
        stub_request( :put, 'https://api.parse.com/1/classes/Game/abcd1234' ).with(
          body: { releasedOn: { '__type' => 'Date', 'iso' => '2011-11-11' }, releasePrice: 59.99 },
          headers: { 'Content-Type' => 'application/json' }
        ).to_return(
          body: { updatedAt: Time.now.to_s }.to_json,
          status: 200,
          headers: { 'Content-Type' => 'application/json', Location: 'https://api.parse.com/1/classes/Game/abcd1234' }
        )
        
        subject.should_not be_a_new_record
        subject.should be_persisted
        subject.attributes = { released_on: '2011-11-11', release_price: 59.99 }
        subject.should_not be_persisted
        subject.save.should == true
        subject.should_not be_a_new_record
        subject.should be_persisted
        subject.updated_at.should_not be_nil
      end
    end
    
    describe 'when saving an invalid model' do
      subject { Game.new( title: 'Skyrim', release_price: -10.99 ) }
      
      it ':save should return false and have :errors' do
        subject.save.should ==  false
        subject.errors.should_not be_empty
      end
    end
    
    describe 'when deleting a new model' do
      subject { Game.new( title: 'Skyrim' ) }
      
      it 'should not receive :http_delete' do
        subject.class.should_not receive( :http_delete )
        subject.delete
      end
      
      it 'should be frozen after delete' do
        subject.delete
        subject.should be_frozen
      end
    end
    
    describe 'when deleting an existing model' do
      subject { Game.new( id: 'abcd1234', title: 'Skyrim' ) }
      
      it 'should receive :http_delete' do
        subject.class.should receive( :http_delete ).with('abcd1234')
        subject.delete
      end
      
      it 'should be frozen after delete' do
        stub_request( :delete, 'https://api.parse.com/1/classes/Game/abcd1234' ).to_return( status: 200 )
        
        subject.delete
        subject.should be_frozen
      end
    end
  end
end