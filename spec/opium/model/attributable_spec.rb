require 'spec_helper'

describe Opium::Model::Attributable do
  let( :model ) { Class.new { include Opium::Model::Attributable } }
  
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
      
      it 'when called with not_readonly, should exclude all readonly fields' do
        subject.attributes_to_parse( not_readonly: true ).should =~ { 'title' => 'Little Brother' }
      end
    end
    
    describe ':attributes=' do
      it 'should still store unrecognized fields in the attributes hash' do
        expect { subject.attributes = { unknownField: 42 } }.to_not raise_exception
        subject.attributes.should have_key('unknownField')
        subject.attributes['unknownField'].should == 42
      end
    end
  end
end