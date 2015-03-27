require 'spec_helper'

describe Opium do
  it { should respond_to(:configure, :config) }
  it { should respond_to(:load!).with(2).arguments }
  it { should respond_to(:reset) }
  
  describe ':configure' do
    it do
      expect {|b| Opium.configure(&b) }.to yield_with_args
    end
  end
  
  describe ':config' do
    subject { Opium.config }
    
    it { should_not be_nil }
    it { should be_an( Opium::Config ) }
  end
  
  describe ':reset' do
    after { described_class.config.log_network_responses = false }
    
    it 'should put all changed settings back to their defaults' do
      expect { described_class.config.log_network_responses = true }.to change( described_class.config, :log_network_responses ).from( false ).to( true )
      described_class.reset
      described_class.config.log_network_responses.should == false
    end
  end
  
  describe ':load!' do
    let(:file) { File.join( File.dirname( __FILE__ ), 'config', 'opium.yml' ) }
  
    before do
      described_class.load!( file, :test )
    end
    
    after do
      described_class.reset
    end
  
    it { subject.config.app_id.should == 'abcd1234' }
    it { subject.config.api_key.should == 'efgh5678' }
    it { subject.config.master_key.should == '9012ijkl' }
    it { subject.config.log_network_responses.should == true }
  end
    
  describe Opium::Config do
    it { should respond_to( :app_id, :api_key, :master_key, :log_network_responses ) }
    
    describe 'defaults' do
      its(:app_id) { should == 'PARSE_APP_ID' }
      its(:api_key) { should == 'PARSE_API_KEY' }
      its(:master_key) { should == 'PARSE_MASTER_KEY' }
      its(:log_network_responses) { should == false }
    end
  end
end