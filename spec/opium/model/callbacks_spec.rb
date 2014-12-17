require 'spec_helper'

describe Opium::Model::Callbacks do
  let( :model ) { Class.new { include Opium::Model::Callbacks } }
  
  its( :constants ) { should include(:CALLBACKS) }
  
  it "should provide a list of its defined CALLBACKS" do
    subject::CALLBACKS.should_not be_nil
    subject::CALLBACKS.should_not be_empty
  end
  
  it "should respond to each of its CALLBACKS" do
    subject::CALLBACKS.each do |callback|
      model.should respond_to(callback)
    end
  end
  
  shared_examples_for 'its callbacks should be invoked for' do |method, options = {}|
    describe method do
      subject { model.new }
      
      it 'should run callbacks' do
        subject.should receive(:run_callbacks).with(method)
        subject.send(method)
      end
      
      it 'should not make a private method public' do
        if options[:private]
          subject.should_not respond_to(method)
        else
          subject.should respond_to(method)
        end
      end
    end
  end
  
  it_should_behave_like 'its callbacks should be invoked for', :save
  it_should_behave_like 'its callbacks should be invoked for', :create, private: true
  it_should_behave_like 'its callbacks should be invoked for', :update, private: true
  it_should_behave_like 'its callbacks should be invoked for', :destroy
end