require 'spec_helper'

describe Opium::Model::Attributable do
  context 'when included in a model' do
    before do
      stub_const( 'Book', Class.new do
        include Opium::Model
        field :title, type: String
        field :genre, type: Symbol
        attr_accessor :not_a_field
      end )
    end
    
    subject { Book.new( title: 'Little Brother', id: 'abc123', created_at: Time.now, genre: :sci_fi ) }
    
    describe '#attributes_to_parse' do
      context 'when called with no parameters' do
        it 'has all fields present, with names and values converted to parse' do
          expect( subject.attributes_to_parse ).to eq( 'objectId' => 'abc123', 'title' => 'Little Brother', 'genre' => 'sci_fi', 'createdAt' => subject.created_at.to_parse, 'updatedAt' => nil )
        end
      end
      
      context 'when called with except' do
        it 'excludes the excepted fields' do
          expect( subject.attributes_to_parse( except: [:id, :updated_at] ) ).to eq( 'title' => 'Little Brother', 'genre' => 'sci_fi', 'createdAt' => subject.created_at.to_parse )
        end
      end
      
      context 'when called with not_readonly' do
        it 'excludes all readonly fields' do
          expect( subject.attributes_to_parse( not_readonly: true ) ).to eq( 'title' => 'Little Brother', 'genre' => 'sci_fi' )
        end
      end
    end
    
    describe '#attributes=' do
      it 'stores unrecognized fields in the attributes hash' do
        expect { subject.attributes = { unknownField: 42 } }.to_not raise_exception
        expect( subject.attributes ).to have_key('unknownField')
        expect( subject.attributes['unknownField'] ).to eq 42
      end
      
      it 'calls relevant setters rather for non fields if they exist' do
        expect { subject.attributes = { not_a_field: 42 } }.to_not raise_exception
        expect( subject.not_a_field ).to eq 42
        expect( subject.attributes ).to_not have_key('not_a_field')
      end
    end
  end
end