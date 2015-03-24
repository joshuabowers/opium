require 'spec_helper'

if defined?( Kaminari )
  describe Opium::Model do
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
    
    subject { Game }
    
    it { expect( subject.criteria ).to be_a( ::Kaminari::PageScopeMethods ) }
    
    it { expect( subject ).to respond_to(:page).with(1).argument }
    it { expect( subject.criteria ).to respond_to(:page, :per).with(1).argument }
    it { expect( subject.criteria ).to respond_to(:limit_value, :offset_value) }
    
    describe ':page' do
      let( :query ) { subject.page( 1 ) }
      it { expect { query }.to_not raise_exception }
      it { expect( query ).to be_an( Opium::Model::Criteria ) }
    end
    
    describe '::Criteria' do
      describe ':page' do
        let( :query ) { subject.criteria.page( 0 ) }
        it { expect { query }.to_not raise_exception }
        it { expect( query.offset_value ) == 0 }
      end
    
      describe ':per' do
        let( :query ) { subject.page( 1 ).per( 10 ) }
        it { expect { query }.to_not raise_exception }
        it { expect( query.limit_value ) == 10 }
        it { expect( query.offset_value ) == 10 }
      end
      
      describe ':total_pages' do
        let( :query ) { subject.page( 0 ).per( 10 ) }
        it { expect( query.offset_value ).to be_truthy }
        it { expect { query.total_pages }.to_not raise_exception }
        it { expect( query.total_pages ) == 10 }
      end
    end
  end
end