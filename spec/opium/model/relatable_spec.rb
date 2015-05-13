require 'spec_helper'

# TODO:
# 1) define a Reference class, which represents the child-to-parent side of a relational query.
# 2) has_many should override the field's setter, such that the owning object is set on the Relation object.
# 3) Relation should subclass Criteria, and come with a baked in query.
# 4) Relation fields should have a default value, so that new objects can start binding things together.
# 5) Probably need to have some sort of after save callback to update any relations owners.
# 6) For a reverse lookup (e.g. for Reference, a belongs_to side of a relation), it should be possible to
#    do the following: ParentModel.where( relation_name: child_model_instance ). If reverse lookup implies
#    single point of ownership, this can be firsted.

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
      stub(:model_name).and_return( ActiveModel::Name.new( klass, nil, 'Article' ) )
      
      field :title, type: String
      has_many :comments
      belongs_to :author, class_name: 'User'
    end )
    
    stub_const( 'Comment', Class.new do |klass|
      include Opium::Model
      stub(:model_name).and_return( ActiveModel::Name.new( klass, nil, 'Comment' ) )
      
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
    it { expect( subject.fields[:article].default ).to be_nil }
    
    context 'within a new model' do
      subject { Comment.new }
    end
    
    context 'within an existing model' do
      subject { Comment.new id: 'c1234' }
      
      it { expect( subject.article ).to_not be_nil }
      it { expect( subject.article ).to be_a Opium::Model::Reference }
      it( 'loads the proper model id' ) { expect( subject.article.id ).to eq 'abcd1234' }
      it( 'loads the proper model class' ) { expect( subject.article.class_name ).to eq 'Article' }
      it( 'delegates to the underlying model' ) { expect( subject.article.class ).to be <= Article }
    end
  end
  
  describe '.has_and_belongs_to_many' do
  end
end