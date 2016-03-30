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
  
  it { expect( described_class ).to respond_to(:upload, :to_ruby, :to_parse).with(1).argument }
  it { is_expected.to respond_to( :delete, :name, :url, :mime_type, :to_parse ) }
  
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
    
    context 'with non-standard characters in filename' do
      let(:upload_options) { { original_filename: 'chunky&bacon$with cheddar@cheese.jpg' } }
      
      it { expect { result }.to_not raise_exception }
      it 'paramterizes the name' do
        expect( result.name ).to end_with 'chunky-bacon-with-cheddar-cheese.jpg'
      end
    end
    
    context 'when executed' do
      let(:upload_options) { { sent_headers: true } }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result.keys ).to include( 'Content-Length' ) }
      it { expect( result['Content-Length'] ).to eq gif_file.size.to_s }
    end
    
    context 'with a :content_type option' do
      let(:upload_options) { { content_type: 'image/png', sent_headers: true } }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to have_key( 'Content-Type') }
      it 'sends the given :content_type value' do
        expect( result['Content-Type'] ).to eq 'image/png'
      end
      it { expect( result.keys ).to include( 'X-Parse-Rest-Api-Key' )}
      it { expect( result.keys ).to_not include( 'X-Parse-Master-Key' )}
    end
    
    context 'without a :content_type option' do
      let(:upload_options) { { sent_headers: true } }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to have_key( 'Content-Type' ) }
      it 'sends the proper content_type' do
        expect( result['Content-Type'] ).to eq 'image/gif'
      end
      it { expect( result.keys ).to include( 'X-Parse-Rest-Api-Key' )}
      it { expect( result.keys ).to_not include( 'X-Parse-Master-Key' )}
    end
  end
  
  describe '.to_ruby' do
    subject { described_class }
    
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
    
    context 'when given an Opium::File' do
      let(:object) { Opium::File.new( url: location, name: 'chunky_bacon.jpg' ) }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_a Opium::File }
      it { expect( result ).to eq object }
    end
    
    context 'when given nil' do
      let(:object) { nil }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_nil }
    end
    
    context 'when given a JSON string' do
      let(:object) { { url: location, name: 'chunky_bacon.jpg' }.to_json }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_a Opium::File }
    end
    
    context 'when given an empty string' do
      let(:object) { '' }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_nil }
    end
    
    context 'when not given a hash' do
      let(:object) { 42 }
      
      it { expect { result }.to raise_exception }
    end
  end
  
  describe '.to_parse' do
    subject { described_class }
    
    let(:result) { described_class.to_parse( object ) }
    
    context 'when given an Opium::File' do
      let(:object) { subject.new( url: location, name: 'chunky_bacon.jpg' ) }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_a Hash }
      it { expect( result ).to have_key '__type' }
      it { expect( result ).to have_key 'name' }
      it 'has the proper values for :__type and :name' do
        expect( result ).to eq( '__type' => 'File', 'name' => 'chunky_bacon.jpg' )
      end
    end
    
    context 'when given nil' do
      let(:object) { nil }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_nil }
    end
    
    context 'when given anything else' do
      let(:object) { 42 }
      
      it { expect { result }.to raise_exception }
    end
  end
  
  context '#initialize' do
    let(:filename) { 'file.png' }
    let(:location) { 'http://files.example.com/1234-file.png' }
    subject { described_class.new( __type: 'File', url: location, name: filename ) }
    
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
    subject { described_class.new( url: location, name: 'chunky_bacon.jpg' ) }
    
    before do
      stub_request(:delete, "https://api.parse.com/1/files/chunky_bacon.jpg").
        with(:headers => {'X-Parse-Application-Id'=>'PARSE_APP_ID', 'X-Parse-Master-Key'=>'PARSE_MASTER_KEY'}).
        to_return(:status => 200, :body => "{}", :headers => { content_type: 'application/json' })
    end
    
    let(:delete_options) { {} }
    let(:result) { subject.delete( delete_options ) }
    
    context 'with a name' do
      it { expect { result }.to_not raise_exception }
      it 'freezes the Opium::File' do
        result
        expect( subject ).to be_frozen
      end
    end
    
    context 'without a name' do
      subject { described_class.new }
      
      it { expect { result }.to raise_exception }
    end
    
    context 'when executed' do
      let(:delete_options) { { sent_headers: true } }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result.keys ).to include( 'X-Parse-Master-Key' ) }
      it { expect( result.keys ).to_not include( 'X-Parse-Rest-Api-Key' ) }
    end
  end
  
  describe '#to_parse' do
    let(:result) { subject.to_parse }
    
    context 'when #name has a value' do
      subject { described_class.new( url: location, name: 'chunky_bacon.jpg' ) }
      
      it { expect { result }.to_not raise_exception }
      it { expect( result ).to be_a Hash }
      it { expect( result ).to have_key '__type' }
      it { expect( result ).to have_key 'name' }
      it 'has the proper values for :__type and :name' do
        expect( result ).to eq( '__type' => 'File', 'name' => 'chunky_bacon.jpg' )
      end
    end
    
    context 'when #name is empty' do
      subject { described_class.new }
      
      it { expect { result }.to raise_exception }
    end
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
  
  context 'when used as a field type' do
    before do
      stub_const( 'Game', Class.new do
        include Opium::Model
        field :cover_image, type: Opium::File
      end )
      
      stub_request(:get, "https://api.parse.com/1/classes/Game/abcd1234").
        with(:headers => {'X-Parse-Application-Id'=>'PARSE_APP_ID', 'X-Parse-Rest-Api-Key'=>'PARSE_API_KEY'}).
        to_return(:status => 200, :body => { objectId: 'abcd1234', coverImage: { __type: 'File', name: 'chunky_bacon.jpg', url: location }, createdAt: '2015-01-01T12:00:00Z' }.to_json, :headers => { content_type: 'application/json' })
        
      stub_request(:post, "https://api.parse.com/1/classes/Game").
        with(
          :body => "{\"coverImage\":{\"__type\":\"File\",\"name\":\"chunky_bacon.jpg\"}}",
          :headers => {'Content-Type'=>'application/json', 'X-Parse-Application-Id'=>'PARSE_APP_ID', 'X-Parse-Rest-Api-Key'=>'PARSE_API_KEY'}).
        to_return(:status => 200, :body => { objectId: 'abcd1234', createdAt: '2015-01-01T12:00:00Z' }.to_json, :headers => { content_type: 'application/json' })
      
    end
    
    it 'is retrievable as an Opium::File' do
      game = Game.find('abcd1234')
      expect( game.cover_image ).to be_a Opium::File
    end
    
    it 'is persistable as a Parse File object hash' do
      game = Game.new cover_image: Opium::File.new( url: location, name: 'chunky_bacon.jpg' )
      expect { game.save! }.to_not raise_exception
    end
  end
end