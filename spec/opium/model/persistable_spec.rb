require 'spec_helper.rb'

describe Opium::Model::Persistable do
  let( :model ) { Class.new { include Opium::Model::Persistable } }

  describe 'in a model' do
    subject { model }
  
    it { should respond_to( :destroy_all ).with(1).argument }
    it { should respond_to( :delete_all ).with(1).argument }
    it { should respond_to( :create, :create! ).with(1).argument }
    it { should respond_to( :add_header_to ).with(4).arguments }
  end
    
  describe 'instance' do
    subject { model.new }
    
    it { should respond_to( :save ).with(1).argument }
    it { should respond_to( :save! ).with(0).arguments }
    it { should respond_to( :update_attributes, :update_attributes! ).with(1).argument }
    it { should respond_to( :touch ) }
    it { should respond_to( :destroy ) }
    it { should respond_to( :delete ) }
    it { should respond_to( :new_record?, :persisted? ) }
    it { should respond_to( :pointer, :to_parse ) }
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
    
    after do
      Opium::Model::Criteria.models.clear
    end
    
    describe ':new_record?' do
      subject { Game.new }
      
      it 'should be true in a model without an id' do
        subject.should be_a_new_record
      end
      
      it 'should be false in a model with an id' do
        subject.attributes = { id: 'abcd1234' }
        subject.should_not be_a_new_record
      end
    end
    
    describe 'when changing the attributes of a model' do
      subject { Game.new( id: 'abcd1234' ) }
      
      it { expect { subject.attributes = { title: 'Skyrim' } }.to change( subject, :persisted? ).from(true).to(false) }
    end
    
    describe 'a new model can be created with' do
      before do
        stub_request( :post, 'https://api.parse.com/1/classes/Game' ).with(
          body: { title: 'Skyrim', releasedOn: { '__type' => 'Date', 'iso' => '2011-11-11' }, releasePrice: 59.99 },
          headers: { 'Content-Type' => 'application/json' }
        ).to_return( 
          body: { objectId: 'abcd1234', createdAt: Time.now.to_s }.to_json, 
          status: 200, 
          headers: { 'Content-Type' => 'application/json', Location: 'https://api.parse.com/1/classes/Game/abcd1234' } 
        )
      end
      
      describe ':create' do      
        it 'which should return a persisted? model' do
          result = Game.create( title: 'Skyrim', released_on: '2011-11-11', release_price: 59.99 )
          result.should_not be_a_new_record
          result.should be_persisted
        end
      end
      
      describe ':create!' do
        it 'which should return a persisted? model' do
          result = Game.create( title: 'Skyrim', released_on: '2011-11-11', release_price: 59.99 )
          result.should_not be_a_new_record
          result.should be_persisted
        end
      end
    end
    
    describe 'attepting to' do
      describe ':create an invalid model' do
        it 'should not raise an exception' do
          expect { Game.create( release_price: -10.00 ) }.to_not raise_exception
        end
        
        it 'should have errors' do
          result = Game.create( release_price: -10.00 )
          result.should_not be_persisted
          result.errors.should_not be_empty
        end
      end
      
      describe ':create! an invalid model' do
        it 'should raise an exception' do
          expect { Game.create!( release_price: -10.00 ) }.to raise_exception
        end
      end
    end
    
    describe 'when saving a new model' do
      subject { Game.new( title: 'Skyrim', released_on: '2011-11-11', release_price: '59.99' ) }
      
      before do
        stub_request( :post, 'https://api.parse.com/1/classes/Game' ).with(
          body: { title: 'Skyrim', releasedOn: { '__type' => 'Date', 'iso' => '2011-11-11' }, releasePrice: 59.99 },
          headers: { 'Content-Type' => 'application/json' }
        ).to_return( 
          body: { objectId: 'abcd1234', createdAt: Time.now.to_s }.to_json, 
          status: 200, 
          headers: { 'Content-Type' => 'application/json', Location: 'https://api.parse.com/1/classes/Game/abcd1234' } 
        )
      end
      
      it 'should have its object_id and created_at fields updated' do
        subject.id.should be_nil
        subject.created_at.should be_nil
        subject.should be_a_new_record
        subject.should_not be_persisted
        subject.save.should == true
        subject.should_not be_a_new_record
        subject.should be_persisted
      end
    end
    
    describe 'when saving an existing model' do
      subject { Game.new( id: 'abcd1234', created_at: Time.now - 3600, title: 'Skyrim' ) }
      
      before do
        stub_request( :put, 'https://api.parse.com/1/classes/Game/abcd1234' ).with(
          body: { releasedOn: { '__type' => 'Date', 'iso' => '2011-11-11' }, releasePrice: 59.99 },
          headers: { 'Content-Type' => 'application/json' }
        ).to_return(
          body: { updatedAt: Time.now.to_s }.to_json,
          status: 200,
          headers: { 'Content-Type' => 'application/json', Location: 'https://api.parse.com/1/classes/Game/abcd1234' }
        )
      end
      
      before :each do
        subject.attributes = { released_on: '2011-11-11', release_price: 59.99 }
      end
      
      it 'should have its updated_at fields updated' do        
        subject.save.should == true
        subject.should be_persisted
        subject.updated_at.should_not be_nil
      end
      
      it ':save! should not raise an exception' do
        subject.release_price.should_not be_nil
        expect { subject.save! }.to_not raise_exception
      end
    end
    
    describe 'when saving a model causes a ParseError' do
      subject { Game.new( id: 'deadbeef', created_at: Time.now - 3600, title: 'Skyrim' ) }
      
      before do
        stub_request( :put, 'https://api.parse.com/1/classes/Game/deadbeef' ).with(
          body: { releasePrice: 599.99 },
          headers: { 'Content-Type' => 'application/json' }
        ).to_return(
          body: { code: 404, error: 'Could not locate a "Game" with id of "deadbeef".' }.to_json,
          status: 404,
          headers: { 'Content-Type' => 'application/json' }
        )
      end
      
      before(:each) do
        subject.release_price = 599.99
      end
      
      it { expect { subject.save }.to_not raise_exception }
      
      it ':save should return false and have errors' do
        subject.save.should == false
        subject.errors.should_not be_empty
      end
      
      it { expect { subject.save! }.to raise_exception }
    end
    
    describe 'when saving a model with validates: false' do
      subject { Game.new( title: 'Skyrim' ) }
      
      it 'should not receive :valid?, but should receive :create' do
        subject.should_not receive(:valid?)
        subject.should receive(:create)
        subject.save( validates: false )
      end
    end
    
    describe 'when saving an invalid model' do
      subject { Game.new( title: 'Skyrim', release_price: -10.99 ) }
      
      it ':save should return false and have :errors' do
        subject.save.should == false
        subject.errors.should_not be_empty
      end
      
      it ':save! should raise an exception' do
        expect { subject.save! }.to raise_exception
      end
    end
    
    describe ':update_attributes' do
      subject { Game.new( id: 'abcd1234', title: 'Skyrim' ) }
      
      let(:new_attributes) { { released_on: '2011-11-11', release_price: 59.99 } }
      
      it 'should alter the attributes and save the model' do
        subject.should receive(:attributes=).with( new_attributes )
        subject.should receive(:save)
        subject.update_attributes( new_attributes )
      end
    end
    
    describe ':update_attributes!' do
      subject { Game.new( id: 'abcd1234', title: 'Skyrim' ) }
      
      let(:new_attributes) { { released_on: '2011-11-11', release_price: 59.99 } }
      
      it 'should alter the attributes and save! the model' do
        subject.should receive(:attributes=).with( new_attributes )
        subject.should receive(:save!)
        subject.update_attributes!( new_attributes )
      end
    end
    
    describe ':touch' do
      subject { Game.new( id: 'abcd1234', title: 'Skyrim' ) }
      
      before do
        stub_request( :put, 'https://api.parse.com/1/classes/Game/abcd1234' ).with(
          body: { },
          headers: { 'Content-Type' => 'application/json' }
        ).to_return(
          body: { updatedAt: '2014-12-18T15:00:00Z' }.to_json,
          status: 200,
          headers: { 'Content-Type' => 'application/json', Location: 'https://api.parse.com/1/classes/Game/abcd1234' }
        )
      end
      
      it do
        expect { subject.touch }.to change( subject, :updated_at ).from( nil ).to( '2014-12-18T15:00:00Z'.to_datetime )
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
    
    describe ':pointer' do
      subject { Game.new( id: 'abcd1234' ) }

      it 'should be an Opium::Pointer' do
        subject.pointer.should be_a( Opium::Pointer )
      end
      
      it 'should have the :id of the instance' do
        subject.pointer.id.should == subject.id
      end
      
      it 'should have the :model_name of the instance class' do
        subject.pointer.model_name.should == subject.class.model_name
      end
    end
    
    describe ':to_parse' do
      subject { Game.new( id: 'abcd1234' ) }
      
      it 'should be a pointer hash' do
        subject.to_parse.should == subject.pointer.to_parse
      end
    end
  end
end