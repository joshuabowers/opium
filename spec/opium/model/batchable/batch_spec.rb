require 'spec_helper'

describe Opium::Model::Batchable::Batch do
  let(:update_path) { '/1/classes/Game/abcd1234' }
  let(:body) { { title: 'Skyrim' } }
  
  describe '#owner' do
    it 'is a property' do
      is_expected.to respond_to(:owner)
    end
  end
  
  describe '#depth' do
    let(:depth) { subject.depth }
    
    context 'within a new batch' do
      subject { described_class.new }
      
      it { expect(depth).to eq 0 }
    end
  end
  
  describe '#dive' do
    after { subject.depth = 0 }
    
    it { expect { subject.dive }.to change( subject, :depth ).by(1) }
  end
  
  describe '#ascend' do
    after { subject.depth = 0 }
    
    it { expect { subject.ascend }.to change( subject, :depth ).by(-1) }
  end
    
  describe '#queue' do
    let(:queue) { subject.queue }
    
    context 'within a new batch' do
      subject { described_class.new }
      
      it { expect(queue).to eq [] }
    end
  end
  
  describe '#enqueue' do
    let(:perform) { subject.enqueue( operation ) }
    
    after { subject.queue.clear }
    
    context 'with a valid operation hash' do
      let(:operation) { { method: :put, path: update_path, body: body } }
      
      it { expect { perform }.to_not raise_exception }
      it { expect( perform ).to be_a Opium::Model::Batchable::Operation }
    end
    
    context 'with an Operation object' do
      let(:operation) { Opium::Model::Batchable::Operation.new( method: :put, path: update_path, body: body ) }
      
      it { expect { perform }.to_not raise_exception }
      it { expect( perform ).to be_a Opium::Model::Batchable::Operation }
    end
    
    context 'with an invalid operation hash' do
      let(:operation) { { path: update_path, body: body } }
      
      it { expect { perform }.to raise_exception }
    end
  end
  
  describe '#execute' do
    let(:execute) { subject.execute }
    let(:operation) { Opium::Model::Batchable::Operation.new( method: :put, path: update_path, body: body ) }
    
    before do
      subject.owner = double()
      allow( subject.owner ).to receive(:http_post).and_return( [ { success: { objectId: 'abcd1234', createdAt: Time.now } } ] )
      subject.enqueue( operation )
    end
    
    after do 
      subject.owner = nil 
      subject.queue.clear
    end
    
    context 'when #depth is 0' do      
      it { expect( subject.depth ).to eq 0 }
      it { expect { execute }.to_not change( subject, :depth ) }
      it 'performs a POST of the batch' do
        expect( subject.owner ).to receive(:http_post).with( subject.to_parse.first )
        execute
      end
    end
    
    context 'when #depth is greater than 0' do
      before { subject.dive }
      after { subject.ascend }
      
      it { expect( subject.depth ).to eq 1 }
      it { expect { execute }.to change( subject, :depth ).by(-1) }
      it 'does not POST the batch' do
        expect( subject.owner ).to_not receive(:http_post)
        execute
      end
    end
    
    context 'when #queue is empty' do
      before { subject.queue.clear }
      
      # it { expect { subject.execute }.to raise_exception }
      
      it { expect { subject.execute }.to_not raise_exception }
      it { expect( subject.owner ).to_not receive(:http_post) }
    end
    
    context 'when #queue has more than MAX_BATCH_SIZE operations' do
      before { subject.queue = [operation] * 51 }
      after { subject.queue.clear }
      
      it 'performs multiple POSTs' do
        expect( subject.owner ).to receive(:http_post).twice
        execute
      end
    end
  end
  
  describe '#to_parse' do
    let(:result) { subject.to_parse }
    
    context 'with Operations in the queue' do
      before { subject.enqueue( method: :put, path: update_path, body: body ) }
      after { subject.queue.clear }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_a Array }
      
      it { expect( result.first ).to be_a Hash }
      it { expect( result.first ).to have_key( :requests ) }
      it { expect( result.first[:requests] ).to be_a Array }
      it { expect( result.first[:requests] ).to_not be_empty }
    end
    
    context 'with an empty queue' do
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to eq [] }
    end
  end
end