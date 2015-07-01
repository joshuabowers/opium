require 'spec_helper.rb'

describe Opium::Schema do
  before do

  end

  it { expect( described_class ).to respond_to( :connection, :http_get ) }
  it { expect( described_class ).to have_heightened_privileges }

  it { expect( described_class ).to respond_to( :find ).with( 1 ).argument }
  it { expect( described_class ).to respond_to( :all ) }
  it { is_expected.to respond_to( :save, :delete, :model, :fields ) }

  describe '.find' do
    let(:result) { described_class.find( model_name ) }

    context 'with a valid model name' do
      let(:model_name) { 'Game' }
    end

    context 'with an invalid model name' do
      let(:model_name) { 'DoesNotExist' }
    end
  end

  describe '.all' do
    let(:result) { described_class.all }
  end

  describe '#save' do

  end

  describe '#delete' do

  end

  describe '#fields' do

  end
end
