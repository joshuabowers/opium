require 'spec_helper.rb'

describe Opium::Model::Queryable do
  let( :model ) { Class.new { include Opium::Model::Queryable } }

  describe 'in a model' do
    subject { model }
    
    it { should respond_to( :find ).with(1).argument }
    it { should respond_to( :where ).with(1).argument }
  end
end