require 'spec_helper.rb'

describe Opium::Model::Persistable do
  let( :model ) { Class.new { include Opium::Model::Persistable } }
    
  describe 'in a model' do
    subject { model }
  
    it { should respond_to( :destroy_all ).with(1).argument }
    it { should respond_to( :delete_all ).with(1).argument }
  end
    
  describe 'instance' do
    subject { model.new }
    
    it { should respond_to( :save ).with(1).argument }
    it { should respond_to( :destroy ) }
    it { should respond_to( :delete ) }
  end
end