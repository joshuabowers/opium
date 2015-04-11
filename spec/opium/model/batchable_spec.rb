require 'spec_helper'

describe Opium::Model::Batchable do
  it { expect( described_class.constants ).to include( :Batch, :Operation ) }
end