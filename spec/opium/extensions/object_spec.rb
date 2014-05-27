require 'spec_helper'

describe Object.new do
  it { should respond_to(:to_parse, :to_ruby) }
  its(:to_parse) { should == subject }
  its(:to_ruby) { should == subject }
end