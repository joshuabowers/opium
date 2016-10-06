require 'spec_helper'

describe Opium do
  it { is_expected.to respond_to( :configure, :config ) }
  it { is_expected.to respond_to( :load! ).with(2).arguments }
  it { is_expected.to respond_to( :reset ) }

  describe '.configure' do
    it do
      expect {|b| Opium.configure(&b) }.to yield_with_args
    end
  end

  describe '.config' do
    subject { Opium.config }

    it { is_expected.to_not be_nil }
    it { is_expected.to be_an( Opium::Config ) }
  end

  describe '.reset' do
    after { described_class.config.log_network_responses = false }

    it 'should put all changed settings back to their defaults' do
      expect { described_class.config.log_network_responses = true }.to change( described_class.config, :log_network_responses ).from( false ).to( true )
      described_class.reset
      described_class.config.log_network_responses.should == false
    end
  end

  describe '.load!' do
    let(:file) { File.join( File.dirname( __FILE__ ), 'config', 'opium.yml' ) }

    before do
      described_class.load!( file, :test )
    end

    after do
      described_class.reset
    end

    subject(:config) { described_class.config }

    context 'a valid config file' do
      it { expect( config.app_id ).to eq 'abcd1234' }
      it { expect( config.api_key ).to eq 'efgh5678' }
      it { expect( config.master_key ).to eq '9012ijkl' }
      it { expect( config.webhook_key ).to eq 'mnop7654' }
      it { expect( config.log_network_responses ).to eq true }
      it { expect( config.server_url ).to eq 'https://example.com' }
      it { expect( config.mount_point ).to eq '/parse' }
    end
  end

  describe Opium::Config do
    it { is_expected.to respond_to( :app_id, :api_key, :master_key, :webhook_key, :log_network_responses, :server_url, :mount_point ) }

    context 'a default config' do
      it { expect( subject.app_id ).to eq 'PARSE_APP_ID' }
      it { expect( subject.api_key ).to eq 'PARSE_API_KEY' }
      it { expect( subject.master_key ).to eq 'PARSE_MASTER_KEY' }
      it { expect( subject.webhook_key ).to eq 'PARSE_WEBHOOK_KEY' }
      it { expect( subject.log_network_responses ).to eq false }
      it { expect( subject.server_url ).to eq 'https://api.parse.com' }
      it { expect( subject.mount_point ).to eq '/1' }
    end
  end
end
