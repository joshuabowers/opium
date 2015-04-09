require 'spec_helper'

describe Symbol do
  describe '.to_ruby' do
    let(:converted) { described_class.to_ruby( param ) }
    
    context 'with a string parameter' do
      let(:param) { 'value' }

      it { expect { converted }.to_not raise_exception }
      it { expect( converted ).to be_a Symbol }
    end
    
    context 'with a symbol parameter' do
      let(:param) { :value }
      
      it { expect { converted }.to_not raise_exception }
      it { expect( converted ).to be_a Symbol }
    end
    
    context 'with anything else' do
      let(:param) { 42 }
      
      it { expect { converted }.to raise_exception }
    end
  end
  
  describe '.to_parse' do
  end
  
  describe '#to_parse' do
  end
end