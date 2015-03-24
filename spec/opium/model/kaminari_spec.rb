require 'spec_helper'

if defined?( Kaminari )
  describe 'when Kaminari is present' do
    before do
      stub_const( 'Game', Class.new do
        include Opium::Model
        field :title, type: String
        field :price, type: Float
      end )
      stub_request(:get, "https://api.parse.com/1/classes/Game?count=1&limit=10&skip=0").
        with(:headers => {'X-Parse-Application-Id'=>'PARSE_APP_ID', 'X-Parse-Rest-Api-Key'=>'PARSE_API_KEY'}).
        to_return(
          status: 200,
          body: {
            count: 100,
            results: []
          }.to_json, 
          headers: { content_type: 'application/json' }
        )
    end
    
    describe Opium::Model do    
      subject { Game }
    
      it { is_expected.to respond_to(:page, :per).with(1).argument }
    
      describe '.page' do
        let( :query ) { subject.page( 5 ) }
        it { expect { query }.to_not raise_exception }
        it { expect( query ).to be_an( Opium::Model::Criteria ) }
        it { expect( query.offset_value ).to eq 100 }
        it { expect( query ).to be_cached }
      end
    
      describe '.per' do
        let( :query ) { subject.per( 20 ) }
        it { expect { query }.to_not raise_exception }
        it { expect( query.limit_value ).to eq 20 }
        it { expect( query ).to be_cached }
      end
    
      describe '.limit_value' do
        let( :query ) { subject.limit_value }
        it { expect { query }.to_not raise_exception }
        it { expect( query ).to eq ::Kaminari.config.default_per_page }
      end
    
      describe '.offset_value' do
        let( :query ) { subject.offset_value }
        it { expect { query }.to_not raise_exception }
        it { expect( query ).to eq 0 }
      end
    end
  
    describe Opium::Model::Criteria do
      subject { Game.criteria }

      it { is_expected.to be_a( ::Kaminari::PageScopeMethods ) }      
      it { is_expected.to respond_to(:page, :per).with(1).argument }
      it { is_expected.to respond_to(:limit_value, :offset_value) }
    
      describe '#page' do
        let( :query ) { subject.page( 0 ) }
        it { expect { query }.to_not raise_exception }
        it { expect( query.offset_value ).to eq 0 }
      end
  
      describe '#per' do
        let( :query ) { subject.page( 2 ).per( 10 ) }
        it { expect { query }.to_not raise_exception }
        it { expect( query.max_per_page ).to be_nil }
        it { expect( query.constraints[:limit] ).to eq 10 }
        it { expect( query.constraints[:skip] ).to eq 10 }
        it { expect( query.limit_value ).to eq 10 }
        it { expect( query.offset_value ).to eq 10 }
      end
    
      describe '#total_pages' do
        let( :query ) { subject.page( 0 ).per( 10 ) }
        it { expect( query.offset_value ).to be_truthy }
        it { expect { query.total_pages }.to_not raise_exception }
        it { expect( query.total_pages ).to eq 10 }
      end
    
      describe '#entry_name' do
        it { expect( subject.entry_name ).to eq Game.model_name.human.downcase }
      end
    end
  end
end