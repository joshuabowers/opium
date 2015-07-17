require 'spec_helper.rb'

describe Opium::Schema do
  before do
    stub_const( 'Game', Class.new do |klass|
      include Opium::Model
      field :name, type: String
      field :current_price, type: Float
    end )
    stub_const( 'Player', Class.new do |klass|
      include Opium::Model
      field :player_tag, type: String
      field :player_score, type: Integer
    end )
  end

  let(:game_schema) do
    {
      className: 'Game',
      fields: {
        objectId: { type: 'String' },
        name: { type: 'String' },
        current_price: { type: 'Number' },
        createdAt: { type: 'Date' },
        updatedAt: { type: 'Date' }
      }
    }
  end

  let(:player_schema) do
    {
      className: 'Player',
      fields: {
        objectId: { type: 'String' },
        player_tag: { type: 'String' },
        player_score: { type: 'Number' },
        createdAt: { type: 'Date' },
        updatedAt: { type: 'Date' }
      }
    }
  end

  it { expect( described_class ).to respond_to( :connection, :http_get ) }
  it { expect( described_class ).to have_heightened_privileges }
  it { expect( described_class.object_prefix ).to be_blank }

  it { expect( described_class ).to respond_to( :find ).with( 1 ).argument }
  it { expect( described_class ).to respond_to( :all ) }
  it { is_expected.to respond_to( :save, :delete, :model, :fields, :class_name ) }

  describe '.find' do
    let(:result) { described_class.find( model_name, options ) }
    let(:options) { {} }

    context 'with a sent_headers option' do
      let(:model_name) { 'NoOp' }
      let(:options) { { sent_headers: true } }

      it { expect { result }.to_not raise_exception }
      it { expect( result.keys ).to include('X-Parse-Master-Key') }
      it { expect( result.keys ).to_not include('X-Parse-Rest-Api-Key') }
    end

    context 'with a valid model name' do
      let(:model_name) { 'Game' }

      before do
        stub_request(:get, "https://api.parse.com/1/schemas/Game").
          with(headers: {'X-Parse-Application-Id'=>'PARSE_APP_ID', 'X-Parse-Master-Key'=>'PARSE_MASTER_KEY'}).
          to_return(status: 200, body: game_schema.to_json, headers: { content_type: 'application/json' })
      end

      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_a( Opium::Schema ) }
      it('sets the correct model name from the results') { expect( result.class_name ).to eq 'Game' }
      it { expect( result.fields ).to be_a Hash }
      it { expect( result.fields.values ).to all( be_a Opium::Model::Field ) }
    end

    context 'with an invalid model name' do
      let(:model_name) { 'DoesNotExist' }

      before do
        stub_request(:get, "https://api.parse.com/1/schemas/DoesNotExist").
          with(headers: {'X-Parse-Application-Id'=>'PARSE_APP_ID', 'X-Parse-Master-Key'=>'PARSE_MASTER_KEY'}).
          to_return(status: 400, body: {
            code: 103, error: 'class DoesNotExist does not exist'
          }.to_json, headers: { content_type: 'application/json' })
      end

      it { expect { result }.to raise_exception( Opium::Model::Connectable::ParseError ) }
    end
  end

  describe '.all' do
    let(:result) { described_class.all }

    context 'when there are no classes' do
      before do
        stub_request(:get, "https://api.parse.com/1/schemas").
          with(headers: {'X-Parse-Application-Id'=>'PARSE_APP_ID', 'X-Parse-Master-Key'=>'PARSE_MASTER_KEY'}).
          to_return(status: 200, body: {
            results: []
          }.to_json, headers: { content_type: 'application/json' })
      end

      it { expect( result ).to be_empty }
      it { expect( result ).to be_a( Array ) }
    end

    context 'when there are multiple classes' do
      before do
        stub_request(:get, "https://api.parse.com/1/schemas").
          with(headers: {'X-Parse-Application-Id'=>'PARSE_APP_ID', 'X-Parse-Master-Key'=>'PARSE_MASTER_KEY'}).
          to_return(status: 200, body: {
            results: [
              game_schema,
              player_schema
            ]
          }.to_json, headers: { content_type: 'application/json' })
      end

      it { expect( result ).to_not be_empty }
      it { expect( result ).to all( be_a( Opium::Schema ) ) }
    end
  end

  describe '#save' do

  end

  describe '#delete' do

  end

  describe '#fields' do

  end
end
