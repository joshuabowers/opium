require 'spec_helper'

describe Opium::Model::Relation do
  before do
    stub_const( 'Model', Class.new do
      include Opium::Model
    end )
  end
  
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
end