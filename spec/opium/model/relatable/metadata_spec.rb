require 'spec_helper'

describe Opium::Model::Relatable::Metadata do
  before do
    stub_const( 'Model', Class.new do |klass|
      stub('model_name').and_return( ActiveModel::Name.new( klass, nil, 'Model' ) )
    end )
  end
  
  describe 'inverse_relation_name' do
    let(:result) { subject.inverse_relation_name }
    
    context 'when created with an :inverse_of key' do
      subject { described_class.new( Model, :belongs_to, :parent, class_name: 'Model', inverse_of: :children ) }
      
      it( 'uses the :inverse_of value' ) { expect( result ).to eq 'children' }
    end
    
    context 'when inferred from a :has_many context' do
      subject { described_class.new( Model, :has_many, :articles ) }
      
      it( 'uses the singular of its model name' ) { expect( result ).to eq 'model' }
    end
    
    context 'when inferred from a :belongs_to context' do
      subject { described_class.new( Model, :belongs_to, :article ) }
      
      it( 'uses the plural of its model name' ) { expect( result ).to eq 'models' }
    end
  end
end