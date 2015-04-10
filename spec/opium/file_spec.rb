require 'spec_helper'

describe Opium::File do
  it { expect( described_class ).to be <= Opium::Model::Connectable }
  let!(:gif_file) do
    Tempfile.new(['test', '.gif']).tap do |f|
      f.binmode
      f.write Base64.decode64('R0lGODlhFQAEAIAAACMtMP///yH5BAEAAAEALAAAAAAVAAQAAAINjI8Bya2wnINUMopZAQA7')
    end
  end
  
  let(:location) { 'http://files.example.com/1234-file.gif' }
  
  describe '.upload' do
    subject { described_class }
    let(:upload_options) { {} }
    let(:result) { subject.upload( gif_file, upload_options ) }
    
    before do
      stub_request( :post, %r{https://api\.parse\.com/1/files/.+} ).
        with( 
          body: "9a\x15\x00\x04\x00\x80\x00\x00#-0\xFF\xFF\xFF!\xF9\x04\x01\x00\x00\x01\x00,\x00\x00\x00\x00\x15\x00\x04\x00\x00\x02\r\x8C\x8F\x01\xC9\xAD\xB0\x9C\x83T2\x8AY\x01\x00;".force_encoding('ASCII-8BIT'),
          headers: {content_type: 'image/gif', x_parse_application_id: 'PARSE_APP_ID', x_parse_rest_api_key: 'PARSE_API_KEY'}
        ).to_return(status: 201, body: ->(request) { { url: location, name: "1234-#{ ::File.basename(request.uri) }" }.to_json }, headers: { content_type: 'application/json', location: location })
    end
    
    it { is_expected.to respond_to(:upload).with(1).argument }
    
    context 'when the upload completes' do      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_a Opium::File }
      it { expect( result.url ).to_not be_nil }
      it { expect( result.name ).to_not be_nil }
    end
    
    context 'with a :original_filename option' do
      let(:upload_options) { { original_filename: 'chunky_bacon.jpg' } }
      
      it { expect { result }.to_not raise_exception }
      it 'preferentially uses the :original_filename' do
        expect( result.name ).to end_with 'chunky_bacon.jpg'
      end
    end
    
    context 'with a :content_type option' do
      let(:upload_options) { { content_type: 'image/png', sent_headers: true } }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to have_key( 'Content-Type') }
      it 'sends the given :content_type value' do
        expect( result['Content-Type'] ).to eq 'image/png'
      end
    end
    
    context 'without a :content_type option' do
      let(:upload_options) { { sent_headers: true } }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to have_key( 'Content-Type' ) }
      it 'sends the proper content_type' do
        expect( result['Content-Type'] ).to eq 'image/gif'
      end
    end
  end
  
  describe '.to_ruby' do
    subject { described_class }
    
    it { is_expected.to respond_to(:to_ruby).with(1).argument }
    
    let(:result) { subject.to_ruby( object ) }
    
    context 'when given a hash with __type: "File"' do
      let(:object) { { __type: 'File', url: location, name: 'chunky_bacon.jpg' } }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_a Opium::File }
    end
    
    context 'when given a hash with just a :url and :name' do
      let(:object) { { url: location, name: 'chunky_bacon.jpg' } }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_a Opium::File }
    end
    
    context 'when given a hash with __type != "File"' do
      let(:object) { { __type: 'Pointer' } }
      
      it { expect { result }.to raise_exception }
    end
    
    context 'when not given a hash' do
      let(:object) { 42 }
      
      it { expect { result }.to raise_exception }
    end
  end
  
  describe '.to_parse' do
    subject { described_class }
    
    it { is_expected.to respond_to(:to_parse).with(1).argument }
  end
  
  context '#initialize' do
    let(:filename) { 'file.png' }
    let(:location) { 'http://files.example.com/1234-file.png' }
    subject { described_class.new( __type: 'File', url: location, name: filename ) }
    
    it { is_expected.to respond_to( :name, :url, :mime_type ) }
    
    it 'sets the url' do 
      expect( subject.url ).to eq location
    end
    
    it 'sets the name' do
      expect( subject.name ).to eq filename
    end
    
    it 'infers the mime_type' do
      expect( subject.mime_type ).to eq 'image/png'
    end
  end
  
  describe '#delete' do
    subject { described_class.new }
    
    it { is_expected.to respond_to :delete }
  end
  
  describe '#to_parse' do
    subject { described_class.new }
    
    it { is_expected.to respond_to :to_parse }    
  end
  
  describe '#inspect' do
    context 'with data' do
      let(:filename) { 'file.gif' }
      let(:mime) { 'image/gif' }
      
      subject { described_class.new( url: location, name: filename ) }

      it 'has the values for all components' do
        expect( subject.inspect ).to eq %{#<Opium::File name="#{ filename }" url="#{ location }" mime_type="#{ mime }">}
      end
    end
    
    context 'without data' do
      subject { described_class.new }
      
      it 'has nil values for all components' do
        expect( subject.inspect ).to eq '#<Opium::File name=nil url=nil mime_type=nil>'
      end
    end
  end
end