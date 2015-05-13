require 'spec_helper'

describe Opium::Model::Reference do
  before do
    stub_const( 'Model', Class.new do |klass| 
      include Opium::Model
      stub(:model_name).and_return( ActiveModel::Name.new( klass, nil, 'Model' ) )
    end )
  end
  
  # it { expect( described_class ).to be <= Delegator }
end