require 'spec_helper'

describe Opium do
  it { expect( described_class.constants ).to include( :Model, :User, :File, :Config ) }
end