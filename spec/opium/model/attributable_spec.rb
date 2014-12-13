require 'spec_helper'

describe Opium::Model::Attributable do
  let( :model ) { Class.new { include Opium::Model::Attributable } }
  
  it { model.should respond_to( :attr_accessible, :attr_protected ) }
  
  describe 'instance' do
    subject { model.new }
    
    it { should respond_to( :attributes, :attributes= ) }
    it { should respond_to( :attributes_to_parse ) }
  end
  
  describe 'when included in a model' do
    before do
      stub_const( 'Book', Class.new do
        include Opium::Model
        field :title, type: String
      end )
    end
    
    subject { Book.new( title: 'Little Brother', id: 'abc123', created_at: Time.now ) }
    
    describe 'attributes_to_parse' do
      it 'when called with no parameters, should have all fields present, with names and values converted to parse' do
        subject.attributes_to_parse.should =~ { 'objectId' => 'abc123', 'title' => 'Little Brother', 'createdAt' => subject.created_at.to_parse, 'updatedAt' => nil }
      end
      
      it 'when called with except, should exclude the excepted fields' do
        subject.attributes_to_parse( except: [:id, :updated_at] ).should =~ { 'title' => 'Little Brother', 'createdAt' => subject.created_at.to_parse }
      end
      
      it 'when called with readonly, should exclude all readonly fields' do
        subject.attributes_to_parse( readonly: true ).should =~ { 'title' => 'Little Brother' }
      end
    end
  end
end