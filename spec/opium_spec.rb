require 'spec_helper'

describe Opium do
  its(:constants) { should include( :Model ) }
end