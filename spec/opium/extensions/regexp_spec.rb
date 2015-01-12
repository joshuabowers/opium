require 'spec_helper.rb'

describe /foo/ do
  
  it { should respond_to( :to_parse ) }
  
  describe ':to_parse' do
    it 'should create a hash containing a $regex key containing the regexp source' do
      /foo.?bar/.to_parse.tap do |result|
        result.should be_a( Hash )
        result.should have_key( '$regex' )
        result['$regex'].should == 'foo.?bar'
      end
    end
    
    it 'should also contain an $options key for any options defined on the regexp' do
      /foo.?bar/ix.to_parse.tap do |result|
        result.should have_key( '$options' )
        result['$options'].should == 'ix'
      end
    end
  end
end