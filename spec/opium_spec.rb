require 'spec_helper'

describe Opium do
  it { expect( described_class.constants ).to include( :Model, :User, :Installation, :File, :Config, :Schema, :Push ) }
end
