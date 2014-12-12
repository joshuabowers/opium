require 'spec_helper.rb'

describe Opium::Model::Connectable do
  let( :model ) { Class.new { include Opium::Model::Connectable } }
  
  describe 'in a model' do
    subject { model }
    
    it { should respond_to( :connection ) }
    it { should respond_to( :object_prefix ) }
    it { should respond_to( :resource_name ).with(1).arguments }
    
    its( :object_prefix ) { should == 'classes' }
    
    describe 'resource_name' do
      it 'should be based off the class name' do
        subject.stub('model_name').and_return('model')
        subject.resource_name.should == 'classes/Model'
      end
      
      it 'should be able to include a resource id' do
        subject.stub('model_name').and_return('model')
        subject.resource_name('abc123').should == 'classes/Model/abc123'
      end
    end
  end
end