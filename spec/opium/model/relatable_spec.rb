require 'spec_helper'

describe Opium::Model::Relatable do
  before do
    stub_const( 'Game', Class.new do
      include Opium::Model
      field :title, type: String
      has_and_belongs_to_many :players
    end )
    
    stub_const( 'Player', Class.new do
      include Opium::Model
      field :tag, type: String
      has_and_belongs_to_many :games 
    end )
    
    stub_const( 'Article', Class.new do
      include Opium::Model
      field :title, type: String
      has_many :comments
      belongs_to :author, class_name: 'User'
    end )
    
    stub_const( 'Comment', Class.new do
      include Opium::Model
      field :body
      belongs_to :article
    end )
    
    stub_const( 'User', Class.new(Opium::User) do
      has_many :articles
      has_one :profile
    end ) 
    
    stub_const( 'Profile', Class.new do
      include Opium::Model
      field :first_name, type: String
      belongs_to :user
    end )
    
    stub_const( 'Event', Class.new do
      include Opium::Model
      field :title, type: String
    end )
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
    
    it { is_expected.to have_field :comments }
    it { expect( subject.fields[:comments].type ).to eq Opium::Model::Relation }
  end
  
  describe '.has_one' do
  end
  
  describe '.belongs_to' do
  end
  
  describe '.has_and_belongs_to_many' do
  end
end