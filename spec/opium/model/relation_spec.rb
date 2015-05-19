require 'spec_helper'

describe Opium::Model::Relation do
  before do
    stub_const( 'Model', Class.new do |klass|
      include Opium::Model
      stub(:model_name).and_return( ActiveModel::Name.new( klass, nil, 'Model' ) )
    end )
    
    stub_const( 'RelatedClass', Class.new do |klass|
      include Opium::Model
      field :title, type: String
      
      def klass.model_name
        ActiveModel::Name.new( self, nil, 'RelatedClass' )
      end
    end )
    
    stub_request(:get, "https://api.parse.com/1/classes/RelatedClass?count=1").
      with(headers: {'X-Parse-Application-Id'=>'PARSE_APP_ID', 'X-Parse-Rest-Api-Key'=>'PARSE_API_KEY'}).
      to_return(status: 200, body: {
        count: 0,
        results: []
      }.to_json, headers: { content_type: 'application/json' })
      
    stub_request(:get, "https://api.parse.com/1/classes/RelatedClass?count=1&where=%7B%22$relatedTo%22:%7B%22object%22:%7B%22__type%22:%22Pointer%22,%22className%22:%22Model%22,%22objectId%22:%22abcd1234%22%7D,%22key%22:%22related%22%7D%7D").
      with(headers: {'X-Parse-Application-Id'=>'PARSE_APP_ID', 'X-Parse-Rest-Api-Key'=>'PARSE_API_KEY'}).
      to_return(status: 200, body: { count: 0, results: [] }.to_json, headers: { content_type: 'application/json' })
          
    stub_request(:post, "https://api.parse.com/1/classes/RelatedClass").
      with(body: "{\"title\":null}",
        headers: {'Content-Type'=>'application/json', 'X-Parse-Application-Id'=>'PARSE_APP_ID', 'X-Parse-Rest-Api-Key'=>'PARSE_API_KEY'}).
      to_return(status: 200, body: {
        objectId: 'rc1234',
        createdAt: Time.now.utc
      }.to_json, headers: { content_type: 'application/json' })
      
    stub_request(:put, "https://api.parse.com/1/classes/Model/abcd1234").
      with(body: "{\"related\":{\"__op\":\"AddRelation\",\"objects\":[{\"__type\":\"Pointer\",\"className\":\"RelatedClass\",\"objectId\":\"rc1234\"}]}}",
          headers: {'Content-Type'=>'application/json', 'X-Parse-Application-Id'=>'PARSE_APP_ID', 'X-Parse-Rest-Api-Key'=>'PARSE_API_KEY'}).
      to_return(status: 200, body: { updatedAt: Time.now.utc }.to_json, headers: { content_type: 'application/json' })    
  end
  
  it { expect( described_class ).to be <= Opium::Model::Criteria }
  it { expect( described_class ).to be <= ActiveModel::Dirty }
  
  describe '.to_ruby' do
    let(:result) { described_class.to_ruby( convert_from ) }
    
    context 'with a parse Relation object hash' do
      let(:convert_from) { { '__type' => 'Relation', 'className' => 'RelatedClass' } }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_a described_class }
      it { expect( result.class_name ).to eq 'RelatedClass' }
    end
    
    context 'with a string value' do
      let(:convert_from) { 'RelatedClass' }
      
      it { expect( result ).to be_a described_class }
      it { expect( result.class_name ).to eq 'RelatedClass' }
    end
    
    context 'with an Opium::Model' do
      let(:convert_from) { Model.new }
      
      it { expect( result ).to be_a described_class }
      it { expect( result.class_name ).to eq 'Model' }
    end
    
    context 'with an Opium::Model::Relation' do
      let(:convert_from) { described_class.new( 'RelatedClass' ) }
      
      it { expect( result ).to be_a described_class }
      it { expect( result.class_name ).to eq 'RelatedClass' }
    end
    
    context 'with nil' do
      let(:convert_from) { nil }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_nil }
    end
    
    context 'with any unconvertable value' do
      let(:convert_from) { 42 }
      
      it { expect { result }.to raise_exception }
    end
  end
  
  describe '.to_parse' do
    let(:result) { described_class.to_parse( convert_from ) }
    
    context 'with an Opium::Model::Relation' do
      let(:convert_from) { described_class.new( 'RelatedClass' ) }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_a Hash }
      it { expect( result.keys ).to include( '__type', 'className' ) }
      it { expect( result ).to eq( { '__type' => 'Relation', 'className' => 'RelatedClass' } ) }
    end
    
    context 'with a hash' do
      let(:convert_from) { { '__type' => 'Relation', 'className' => 'RelatedClass' } }
      
      it { expect( result ).to eq( { '__type' => 'Relation', 'className' => 'RelatedClass' } ) }
    end
    
    context 'with a string value' do
      let(:convert_from) { 'RelatedClass' }
      
      it { expect( result ).to eq( { '__type' => 'Relation', 'className' => 'RelatedClass' } ) }
    end
    
    context 'with an Opium::Model' do
      let(:convert_from) { Model.new }
      
      it { expect( result ).to eq( { '__type' => 'Relation', 'className' => 'Model' } ) }
    end
    
    context 'when the class_name cannot be determined' do
      let(:convert_from) { { '__type' => 'Relation' } }
      
      it { expect { result }.to raise_exception }
    end
    
    context 'with any unconvertable value' do
      let(:convert_from) { 42 }
      
      it { expect { result }.to raise_exception }
    end
  end
  
  describe '#to_parse' do
    let(:result) { subject.to_parse }
    subject { described_class.new 'RelatedClass' }
    
    it { expect( result ).to be_a Hash }
    it { expect( result.keys ).to include( '__type', 'className' ) }
    it { expect( result ).to eq( { '__type' => 'Relation', 'className' => 'RelatedClass' } ) }    
  end
  
  describe '#initialize' do
    let(:result) { described_class.new 'RelatedClass' }
    
    it { expect( result ).to be_cached }
  end
  
  describe '#empty?' do
    let(:result) { subject.empty? }
    
    context 'within an new model' do
      subject { described_class.new( 'RelatedClass' ).tap {|r| r.owner = Model.new } }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_truthy }
    end
  end
  
  describe '#owner' do
    let(:result) { subject.owner }
    subject { described_class.new 'RelatedClass' }
    
    it { expect { result }.to_not raise_exception }
  end
  
  describe '#owner=' do
    let(:result) { subject.owner = Model.new }
    subject { described_class.new 'RelatedClass' }
    
    it { expect { result }.to_not raise_exception }
  end
  
  describe '.push' do
    let(:result) { subject.push a_related_object }
    let(:a_related_object) { RelatedClass.new }
    subject { described_class.new 'RelatedClass' }
    
    it { expect { result }.to_not raise_exception }
    it { expect( result ).to eq subject }
    it { expect( result ).to include( a_related_object ) }
  end
  
  describe '.delete' do
    let(:result) { subject.delete a_related_object }
    let(:a_related_object) { RelatedClass.new }
    subject { described_class.new 'RelatedClass' }
    before(:each) { subject.push a_related_object }
    
    it { expect { result }.to_not raise_exception }
    it { expect( result ).to_not include( a_related_object ) }
  end
  
  describe '.build' do
    let(:result) { subject.build object_params }
    subject { described_class.new 'RelatedClass' }
    
    context 'with no params' do
      let(:object_params) { }
      
      it { expect( result.model_name ).to eq 'RelatedClass' }
      it { expect( result.persisted? ).to eq false }
      it { is_expected.to include( result ) }
    end
    
    context 'with params' do
      let(:object_params) { { title: 'Related' } }

      it { expect( result.model_name ).to eq 'RelatedClass' }
      it { expect( result.persisted? ).to eq false }
      it { expect( result.title ).to eq object_params[:title] }
      it { is_expected.to include( result ) }      
    end
  end
  
  describe '.create' do
  end
  
  describe '.create!' do
  end
  
  describe '.save' do
    # Note: this is mostly a utility method which should be only ever invoked by the owner upon it being saved.
    # This should trigger a save on all relations within changes which are not persisted?, and then perform a series
    # of AddRelation and RemoveRelation API calls.
    let(:result) { subject.save }
    let(:a_related_object) { subject.first }
    subject do 
      described_class.new( 'RelatedClass' ).tap do |r|
        r.owner = Model.new id: 'abcd1234'
        r.metadata = Opium::Model::Relatable::Metadata.new( Model, :has_many, :related, class_name: 'RelatedClass' )
        r.build 
      end
    end
    
    it { expect { result }.to_not raise_exception }
    it { result && is_expected.to( all( be_persisted ) ) }
    it { result && expect( subject.map(&:errors) ).to( all( be_empty ) ) }
    it { expect( result && subject.send(:__additions__) ).to be_empty }
    it { expect( result && subject.send(:__deletions__) ).to be_empty }
    it { is_expected.to include( a_related_object ) }
  end
end