require 'spec_helper'

describe Opium::Pointer do
  subject { Opium::Pointer }
  
  describe 'an instance' do
    subject { Opium::Pointer.new( model_name: 'Game', id: 'abcd1234' ) }
    
    it { should respond_to( :model_name, :class_name, :id, :to_parse ) }
    
    describe ':model_name' do
      it 'should be an alias of :class_name' do
        subject.method(:model_name).should == subject.method(:class_name)
      end
    end
    
    describe ':to_parse' do
      it 'should be a hash' do
        subject.to_parse.should be_a( Hash )
      end
      
      it 'should have keys for "__type", "objectId", and "className"' do
        subject.to_parse.keys.should =~ [ '__type', 'objectId', 'className' ]
        subject.to_parse.should =~ { '__type' => 'Pointer', 'objectId' => 'abcd1234', 'className' => 'Game' }
      end
    end
  end
end