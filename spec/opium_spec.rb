require 'spec_helper'

describe Opium do
  its(:constants) { should include( :Model ) }
  it { should respond_to( :configuration ) }
end