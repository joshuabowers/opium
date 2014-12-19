require 'spec_helper.rb'

describe Opium::Model::Criteria do
  it { should be_a( Opium::Model::Queryable::ClassMethods ) }
  it { should respond_to( :constraints ) }
end