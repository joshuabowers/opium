require 'spec_helper'

describe Opium::Model::Batchable do
  it { expect( described_class.constants ).to include( :Batch, :Operation ) }
  
  before do
    stub_const( 'Game', Class.new do
      include Opium::Model
      field :title, type: String
    end )
    
    stub_request(:get, "https://api.parse.com/1/classes/Game/abcd1234").
      with(headers: {'X-Parse-Application-Id'=>'PARSE_APP_ID', 'X-Parse-Rest-Api-Key'=>'PARSE_API_KEY'}).
      to_return(:status => 200, :body => { objectId: 'abcd1234', title: 'Never Alone' }.to_json, :headers => {})
      
    stub_request(:get, "https://api.parse.com/1/classes/Game/efgh5678").
      with(headers: {'X-Parse-Application-Id'=>'PARSE_APP_ID', 'X-Parse-Rest-Api-Key'=>'PARSE_API_KEY'}).
      to_return(:status => 200, :body => { objectId: 'efgh5678', title: 'Guacamelee' }.to_json, :headers => {})      
  end
  
  describe '.batched?' do
    let(:result) { Game.batched? }
    
    context 'when there is no batch job' do
      it { expect( result ).to be_falsey }
    end
    
    context 'when there is a batch job' do
      before(:each) { Game.create_batch }
      after(:each) { Game.delete_batch }
      
      it { expect( result ).to be_truthy }
    end
  end
  
  describe '.create_batch' do
    after { Game.delete_batch }
    let(:result) { Game.create_batch }
    
    context 'when there is no existing batch job' do
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_a Opium::Model::Batchable::Batch }
      it { expect( result.depth ).to be 0 }
    end
    
    context 'when there is a current batch job' do
      before { Game.create_batch }
      after { Game.delete_batch }
      
      it { expect { result }.to_not raise_exception }
      it( 'increments the depth' ) { expect( result.depth ).to eq 1 }
    end
  end
  
  describe '.delete_batch' do
    let(:result) { Game.delete_batch }
    
    context 'when there is no existing batch job' do
      it { expect { result }.to raise_exception }
    end
    
    context 'when there is a current batch job' do
      before { Game.create_batch }
    
      context 'with depth greater than 0' do
        before { Game.create_batch }
        after { Game.delete_batch }
        
        it { expect { result }.to_not raise_exception }
        it { expect( result ).to be_a Opium::Model::Batchable::Batch }
        it( 'decrements the depth' ) { expect( result.depth ).to eq 0 }
      end
      
      context 'with depth of 0' do
        it { expect { result }.to_not raise_exception }
        it { expect( result ).to be_nil }
      end
    end
  end
  
  describe '.current_batch_job' do
    let(:result) { Game.current_batch_job }
    
    context 'when there is no batch job' do
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_nil }
    end
    
    context 'when a batch job has been created' do
      before { Game.create_batch }
      after { Game.delete_batch }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_a Opium::Model::Batchable::Batch }
    end
  end
  
  describe '.batch' do
    let(:batch) { Game.batch( batch_options, &batch_block ) }
    let(:batch_options) { { } }
    let(:batch_block) { -> { } }
    
    context 'when given a block' do
      it { expect { batch }.to_not raise_exception }
      it { expect {|b| Game.batch( batch_options, &b ) }.to yield_control.at_least(1).times }
      it 'is batched within the block' do
        Game.batch( batch_options ) do
          expect( Game ).to be_batched
          
          Game.batch( batch_options ) do
            expect( Game ).to be_batched
            expect( Game.current_batch_job.depth ).to eq 1
          end
          
          expect( Game ).to be_batched
          expect( Game.current_batch_job.depth ).to eq 0
        end
        expect( Game ).to_not be_batched
      end
    end
    
    context 'without a block' do
      let(:batch_block) { }
      
      it { expect { batch }.to raise_exception }
    end
    
    context 'with mode: :mixed' do
      let(:batch_options) { { mode: :mixed } }
      let(:batch_block) do
        -> do
          Game.find('abcd1234').save
          Game.new( title: 'Skyrim' ).save
          Game.find('efgh5678').destroy
        end
      end
      
      it { expect { batch }.to_not raise_exception }
      
    end
    
    context 'with mode: :ordered' do
      let(:batch_options) { { mode: :ordered } }
      let(:batch_block) do
        -> do
          Game.find('abcd1234').save
          Game.new( title: 'Skyrim' ).save
          Game.find('efgh5678').destroy
        end
      end
    end
  end
end