require 'spec_helper.rb'

describe Opium::Schema do
  before do

  end

  it { expect( described_class ).to respond_to( :connection, :http_get ) }
  it { expect( described_class ).to have_heightened_privileges }

  it { expect( described_class ).to respond_to( :find ).with( 1 ).argument }
  it { expect( described_class ).to respond_to( :all ) }
  it { is_expected.to respond_to( :save, :delete, :fields ) }
end
