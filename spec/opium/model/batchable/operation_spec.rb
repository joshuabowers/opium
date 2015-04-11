require 'spec_helper'

describe Opium::Model::Batchable::Operation do
  let(:update_path) { '/1/classes/Game/abcd1234' }
  let(:body) { { title: 'Skyrim' } }
  
  describe '#initialize' do
    let(:result) { described_class.new( properties ) }
    
    context 'with all properties' do
      let(:properties) { { method: :put, path: update_path, body: body } }
    
      it { expect { result }.to_not raise_exception }
      it 'sets the method' do
        expect( result.method ).to eq :put
      end
      
      it 'sets the path' do
        expect( result.path ).to eq update_path
      end
      
      it 'sets the body' do
        expect( result.body ).to eq body
      end
    end
    
    context 'when :method is missing' do
      let(:properties) { { path: update_path, body: body } }
      
      it { expect { result }.to raise_exception }
    end
    
    context 'when :path is missing' do
      let(:properties) { { method: :put, body: body } }
      
      it { expect { result }.to raise_exception }
    end
    
    context 'when :body is missing' do
      let(:properties) { { method: :put, path: update_path } }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result.body ).to be_nil }
    end
  end
  
  describe '#to_parse' do
    let(:result) { subject.to_parse }
    
    context 'when a body is present' do
      subject { described_class.new( method: :put, path: update_path, body: body ) }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_a Hash }
      it { expect( result.keys ).to include( :method, :path, :body ) }
      it 'stringifies and upcases the method' do
        expect( result[:method] ).to eq 'PUT' 
      end
    end
    
    context 'without a body' do
      subject { described_class.new( method: :put, path: update_path ) }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_a Hash }
      it { expect( result.keys ).to include( :method, :path ) }
      it { expect( result ).to_not have_key( :body ) }
      it 'stringifies and upcases the method' do
        expect( result[:method] ).to eq 'PUT' 
      end
    end
  end
end