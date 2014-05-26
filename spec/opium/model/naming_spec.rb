require 'spec_helper'

describe Opium::Model::Naming do
  its(:singleton_class) { should be_a_kind_of( ActiveModel::Naming )}
  
  its(:singleton_class) { should respond_to(:model_name) }
end