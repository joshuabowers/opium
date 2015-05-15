require 'spec_helper'

describe Opium::Model::Reference do
  before do
    stub_const( 'Tree', Class.new do |klass| 
      include Opium::Model
      field :trees
      
      class << klass
        stub(:model_name).and_return( ActiveModel::Name.new( self, nil, 'Tree' ) )
      end
    end )
  end
  
  let(:child) { Tree.new id: 'c1234' }
  let(:metadata) { Opium::Model::Relatable::Metadata.new( Tree, :belongs_to, :parent, class_name: 'Tree' ) }
  
  describe '.to_ruby' do
    let(:result) { described_class.to_ruby( subject ) }
    
    context 'when given a hash' do
      subject { { metadata: metadata, context: child } }
      
      it { expect( result ).to be_a described_class }
      it { expect( result.metadata ).to eq metadata }
      it { expect( result.context ).to eq child }
      it { expect( result ).to be_a Delegator }
    end
    
    context 'when given a Reference' do
      subject { described_class.new( metadata, child ) }

      it { expect( result ).to be_a described_class }
      it { expect( result.metadata ).to eq metadata }
      it { expect( result.context ).to eq child }
      it { expect( result ).to be_a Delegator }
    end
  end
  
  describe '.to_parse' do
  end
  
  describe '.__getobj__' do
    subject { described_class.new( metadata, child ) }
    let(:result) { subject.__getobj__ }
    
    context 'when parse returns no results' do
      before do
        stub_request(:get, "https://api.parse.com/1/classes/Tree?count=1&where=%7B%22trees%22:%7B%22__type%22:%22Pointer%22,%22className%22:%22Tree%22,%22objectId%22:%22c1234%22%7D%7D").
          with(headers: {'X-Parse-Application-Id'=>'PARSE_APP_ID', 'X-Parse-Rest-Api-Key'=>'PARSE_API_KEY'}).
          to_return(status: 200, body: { results: [], count: 0 }.to_json, headers: { content_type: 'application/json' })
      end
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_nil }
    end
    
    context 'when parse returns a result' do
      before do
        stub_request(:get, "https://api.parse.com/1/classes/Tree?count=1&where=%7B%22trees%22:%7B%22__type%22:%22Pointer%22,%22className%22:%22Tree%22,%22objectId%22:%22c1234%22%7D%7D").
          with(headers: {'X-Parse-Application-Id'=>'PARSE_APP_ID', 'X-Parse-Rest-Api-Key'=>'PARSE_API_KEY'}).
          to_return(status: 200, body: { results: [
            { objectId: 'abcd1234' }
          ], count: 1 }.to_json, headers: { content_type: 'application/json' })
        allow(Tree).to receive(:model_name).and_return( ActiveModel::Name.new( Tree, nil, 'Tree' ) )
      end
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to_not be_nil }
      it { expect( result ).to be_a Opium::Model }
    end
  end
end