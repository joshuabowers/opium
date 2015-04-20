require 'spec_helper'

describe Opium::Model::Callbacks do
  let( :model ) { 
    Class.new do
      def initialize( a = {} ) end
      def save( o = {} ) end
      def destroy; end
      def touch; end
      def _create; end
      def _update; end
      def update; end
      def find( id ) end
      
      private :_create, :_update
      
      include Opium::Model::Callbacks
    end
  }
  
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
        subject.should receive(:run_callbacks).with(options[:callback_name] || method)
        subject.send(method, *options[:args])
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
  
  it_should_behave_like 'its callbacks should be invoked for', :initialize, private: true
  it_should_behave_like 'its callbacks should be invoked for', :save
  it_should_behave_like 'its callbacks should be invoked for', :_create, private: true, callback_name: :create
  it_should_behave_like 'its callbacks should be invoked for', :_update, private: true, callback_name: :update
  it_should_behave_like 'its callbacks should be invoked for', :destroy
  it_should_behave_like 'its callbacks should be invoked for', :touch
  it_should_behave_like 'its callbacks should be invoked for', :find, args: ['abcd1234']
  
  it { expect( model.new ).to respond_to(:update) }
end