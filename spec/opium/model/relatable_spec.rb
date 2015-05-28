require 'spec_helper'

describe Opium::Model::Relatable do
  before do
    stub_const( 'Game', Class.new do |klass|
      include Opium::Model
      stub(:model_name).and_return( ActiveModel::Name.new( klass, nil, 'Game' ) )
      
      field :title, type: String
      has_and_belongs_to_many :players
    end )
    
    stub_const( 'Player', Class.new do |klass|
      include Opium::Model
      stub(:model_name).and_return( ActiveModel::Name.new( klass, nil, 'Player' ) )
      
      field :tag, type: String
      has_and_belongs_to_many :games 
    end )
    
    stub_const( 'Article', Class.new do |klass|
      include Opium::Model
      
      instance_eval do
        def model_name
          ActiveModel::Name.new( self, nil, 'Article' )
        end
      end
      
      field :title, type: String
      has_many :comments
      belongs_to :author, class_name: 'User'
    end )
    
    stub_const( 'Comment', Class.new do |klass|
      include Opium::Model
      
      instance_eval do
        def model_name
          ActiveModel::Name.new( self, nil, 'Comment' )
        end
      end
      
      field :body
      belongs_to :article
    end )
    
    stub_const( 'User', Class.new(Opium::User) do |klass|
      stub(:model_name).and_return( ActiveModel::Name.new( klass, nil, 'User' ) )
      
      has_many :articles
      has_one :profile
    end ) 
    
    stub_const( 'Profile', Class.new do |klass|
      include Opium::Model
      stub(:model_name).and_return( ActiveModel::Name.new( klass, nil, 'Profile' ) )
      
      field :first_name, type: String
      belongs_to :user
    end )
    
    stub_const( 'Event', Class.new do |klass|
      include Opium::Model
      stub(:model_name).and_return( ActiveModel::Name.new( klass, nil, 'Event' ) )
    
      field :title, type: String
    end )
    
    stub_request(:get, "https://api.parse.com/1/classes/Comment?count=1&where=%7B%22$relatedTo%22:%7B%22object%22:%7B%22__type%22:%22Pointer%22,%22className%22:%22Article%22,%22objectId%22:%22abcd1234%22%7D,%22key%22:%22comments%22%7D%7D").
      with(headers: {'X-Parse-Application-Id'=>'PARSE_APP_ID', 'X-Parse-Rest-Api-Key'=>'PARSE_API_KEY'}).
      to_return(status: 200, body: {
        count: 2,
        results: [
          { objectId: 'c1234', body: 'A Moose once bit my sister...' },
          { objectId: 'c5678', body: 'No realli! She was Karving her initials on the moose' }
        ]
      }.to_json, headers: { content_type: 'application/json' })
      
    stub_request(:get, "https://api.parse.com/1/classes/Comment?count=1&where=%7B%22$relatedTo%22:%7B%22object%22:%7B%22__type%22:%22Pointer%22,%22className%22:%22Article%22,%22objectId%22:%22a1234%22%7D,%22key%22:%22comments%22%7D%7D").
      with(headers: {'X-Parse-Application-Id'=>'PARSE_APP_ID', 'X-Parse-Rest-Api-Key'=>'PARSE_API_KEY'}).
      to_return(status: 200, body: {
        count: 1,
        results: [
          { objectId: 'c2345', body: 'Seems plausible.' }
        ]
      }.to_json, headers: { content_type: 'application/json' })
      
    stub_request(:get, "https://api.parse.com/1/classes/Article?count=1&where=%7B%22comments%22:%7B%22__type%22:%22Pointer%22,%22className%22:%22Comment%22,%22objectId%22:%22c1234%22%7D%7D").
      with(headers: {'X-Parse-Application-Id'=>'PARSE_APP_ID', 'X-Parse-Rest-Api-Key'=>'PARSE_API_KEY'}).
      to_return(status: 200, body: {
        count: 1,
        results: [
          { objectId: 'abcd1234', title: 'Funny Subtitles' }
        ]
      }.to_json, headers: { content_type: 'application/json' })
      
    stub_request(:post, "https://api.parse.com/1/classes/Article").
      with(body: "{\"title\":\"A new approach to Sandboxes\"}",
        headers: {'Content-Type'=>'application/json', 'X-Parse-Application-Id'=>'PARSE_APP_ID', 'X-Parse-Rest-Api-Key'=>'PARSE_API_KEY'}).
      to_return(status: 200, body: { objectId: 'a1234', createdAt: Time.now.utc }.to_json, headers: { content_type: 'appliction/json' })
      
    stub_request(:post, "https://api.parse.com/1/classes/Comment").
      with(body: "{\"body\":\"Do. Not. Want.\"}",
        headers: {'Content-Type'=>'application/json', 'X-Parse-Application-Id'=>'PARSE_APP_ID', 'X-Parse-Rest-Api-Key'=>'PARSE_API_KEY'}).
      to_return(status: 200, body: { objectId: 'c7896', createdAt: Time.now.utc }.to_json, headers: { content_type: 'application/json' })
      
    stub_request(:put, "https://api.parse.com/1/classes/Article/a1234").
      with(body: "{\"comments\":{\"__op\":\"AddRelation\",\"objects\":[{\"__type\":\"Pointer\",\"className\":\"Comment\",\"objectId\":\"c7896\"}]}}",
        headers: {'Content-Type'=>'application/json', 'X-Parse-Application-Id'=>'PARSE_APP_ID', 'X-Parse-Rest-Api-Key'=>'PARSE_API_KEY'}).
      to_return(status: 200, body: { updatedAt: Time.now.utc }.to_json, headers: { content_type: 'application/json' })
  end
  
  describe '.relations' do
    let(:result) { subject.relations }
    
    context 'within a model with multiple relations' do
      subject { User }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_a Hash }
      it { expect( result.keys ).to include( 'articles', 'profile' ) }
    end
    
    context 'within a model with no relations' do
      subject { Event }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_a Hash }
      it { expect( result ).to be_empty }
    end
  end
  
  describe '.has_many' do
    subject { Article }
    let(:result) { subject.relations[relation_name] }
    let(:relation_name) { :comments }
    
    it { expect( result ).to be_a Opium::Model::Relatable::Metadata }
    
    it { is_expected.to have_field :comments }
    it { expect( subject.fields[:comments].type ).to eq Opium::Model::Relation }
    it { expect( subject.fields[:comments].default ).to_not be_nil }
    
    context 'within a new model' do
      subject { Article.new }
      
      it { expect( subject.comments ).to_not be_nil }
      it { expect( subject.comments ).to be_a Opium::Model::Relation }
      it('adds a constraint for the owner of the relation') { expect( subject.comments.constraints['where'] ).to include( '$relatedTo' => { 'object' => subject.to_parse, 'key' => 'comments' } ) }
      it { expect( subject.comments ).to be_empty }
      it { expect( subject.comments.owner ).to eq subject }
    end
    
    context 'when a model has existing relations' do
      subject { Article.new id: 'abcd1234' }
      
      it { expect( subject.comments ).to_not be_nil }
      it { expect( subject.comments ).to be_a Opium::Model::Relation }
      it('adds a constraint for the owner of the relation') { expect( subject.comments.constraints['where'] ).to include( '$relatedTo' => { 'object' => subject.to_parse, 'key' => 'comments' } ) }
      it { expect( subject.comments ).to_not be_empty }
      it { expect( subject.comments.owner ).to eq subject }
    end
    
    context "when setting a model's relation" do
      subject { Article.new id: 'abcd1234' }
      let(:result) { subject.comments = new_value; subject.comments }
      
      context 'to nil' do
        let(:new_value) { nil }
        
        it { expect { result }.to_not raise_exception }
        it { expect( result ).to be_a Opium::Model::Relation }
      end
      
      context 'to []' do
        let(:new_value) { [] }
        
        it { expect { result }.to_not raise_exception }
        it { expect( result ).to be_a Opium::Model::Relation }
      end
      
      context 'to an array of models' do
        let(:comment) { Comment.new }
        let(:new_value) { [ comment ] }
        
        it { expect { result }.to_not raise_exception }
        it { expect( result ).to be_a Opium::Model::Relation }
        it { expect( result ).to include( comment ) }
      end
    end
  end
  
  describe '.has_one' do
  end
  
  describe '.belongs_to' do
    subject { Comment }
    let(:result) { subject.relations[relation_name] }
    let(:relation_name) { :article }
    
    it { expect( result ).to be_a Opium::Model::Relatable::Metadata }
    
    it { is_expected.to have_field :article }
    it { expect( subject.fields[:article].type ).to eq Opium::Model::Reference }
    it { expect( subject.fields[:article].default ).to be_a Hash }
    
    context 'within a new model' do
      subject { Comment.new }
      
      it { expect( subject.article ).to_not be_nil }
      it { expect( subject.article ).to be_a Opium::Model::Reference }
      it { expect( subject.article.context ).to eq subject }
      it { expect { subject.article.__getobj__ }.to_not raise_exception }
      it { expect( subject.article.__getobj__ ).to be_nil }
    end
    
    context 'within an existing model' do
      subject { Comment.new id: 'c1234' }
      
      it { expect( subject.article ).to_not be_nil }
      it { expect( subject.article ).to be_a Opium::Model::Reference }
      it { expect( subject.article.context ).to eq subject }
      it( 'loads the proper model id' ) { expect( subject.article.id ).to eq 'abcd1234' }
      it( 'loads a properly typed model') { expect( subject.article.model_name ).to eq 'Article' }
    end
  end
  
  describe '.has_and_belongs_to_many' do
  end
  
  describe '#save' do
    let(:result) { subject.save }
    
    context 'within a model with a has_many relation' do
      subject { Article.new title: 'A new approach to Sandboxes' }
      before { subject.comments.build body: 'Do. Not. Want.' }
      
      it { result; expect( subject.errors ).to be_empty }
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_truthy }
      it { result && is_expected.to( be_persisted ) }
      it { result && expect( subject.comments ).to( be_a Opium::Model::Relation ) }
      it { result && expect( subject.comments ).to( all( be_a( Opium::Model ) ) ) }
      it { result && expect( subject.comments ).to( all( be_persisted ) ) }
    end
  end
end