require 'spec_helper'

describe Opium::Boolean do
  subject { Opium::Boolean }
  
  it { is_expected.to respond_to( :to_ruby, :to_parse ).with( 1 ).argument }
  
  describe '.to_ruby' do
    let(:result) { subject.to_ruby( convert_from ) }
    
    context 'with valid boolean objects' do
      ["true", "false", true, false, 1.0, 1, 0.0, 0].each do |value|
        let(:convert_from) { value }
        
        it { expect { result }.to_not raise_exception }
        it { expect( result ).to be_a described_class }
        it { expect( result ).to eq convert_from.to_bool }
      end
    end
  end
  
  describe '.to_parse' do
    let(:result) { subject.to_parse( convert_from ) }
    
    context 'with valid boolean objects' do
      ["true", "false", true, false, 1.0, 1, 0.0, 0].each do |value|
        let(:convert_from) { value }
        
        it { expect { result }.to_not raise_exception }
        it { expect( result ).to be_a described_class }
        it { expect( result ).to eq convert_from.to_bool }
      end
    end
  end
  
  describe "instance" do
    subject { Class.new { include Opium::Boolean }.new }
    it { should respond_to(:to_ruby, :to_parse).with(0).arguments }
    its(:to_ruby) { should == subject }
    its(:to_parse) { should == subject }
  end
end