require 'spec_helper.rb'

describe Opium::Model::Connectable do
  before do
    stub_const( 'Model', Class.new do |klass|
      include Opium::Model::Connectable
      stub('model_name').and_return(ActiveModel::Name.new(klass, nil, 'Model'))
    end )
  end

  after do
    Opium::Model::Criteria.models.clear
  end

  subject { Model }
  let( :response ) { double('Response').tap {|r| allow(r).to receive(:body) } }

  it { is_expected.to respond_to( :parse_server_url ) }
  it { is_expected.to respond_to( :connection, :reset_connection! ) }
  it { is_expected.to respond_to( :object_prefix, :no_object_prefix! ) }
  it { is_expected.to respond_to( :as_resource, :resource_name ).with(1).argument }
  it { is_expected.to respond_to( :http_get, :http_post, :http_delete ).with(1).argument }
  it { is_expected.to respond_to( :http_put ).with(2).arguments }
  it { is_expected.to respond_to( :requires_heightened_privileges!, :requires_heightened_privileges?, :has_heightened_privileges? ) }

  describe '.parse_server_url' do
    after do
      Opium.reset
    end

    context 'with a default config' do
      it { expect( subject.parse_server_url ).to eq 'https://api.parse.com/1' }
    end

    context 'with altered server settings' do
      before do
        Opium.configure do |config|
          config.server_url = 'https://example.com'
          config.mount_point = '/parse'
        end
      end

      it { expect( subject.parse_server_url ).to eq 'https://example.com/parse' }
    end
  end

  describe '.object_prefix' do
    it { expect( subject.object_prefix ).to eq 'classes' }
  end

  describe '.connection' do
    after do
      Opium.reset
      subject.reset_connection!
    end

    context 'with a default config' do
      it { expect( subject.connection.url_prefix ).to eq ::URI.join( 'https://api.parse.com/1' ) }
    end

    context 'with altered server settings' do
      before do
        Opium.configure do |config|
          config.server_url = 'https://example.com'
          config.mount_point = '/parse'
        end
      end

      it { expect( subject.connection.url_prefix ).to eq ::URI.join( 'https://example.com/parse' ) }
    end
  end

  describe '.reset_connection!' do
    it { expect { subject.reset_connection! }.to change( subject, :connection ) }
  end

  describe '.no_object_prefix!' do
    after do
      Model.instance_variable_set :@object_prefix, nil
    end

    it 'has an empty object_prefix' do
      expect { subject.no_object_prefix! }.to change( subject, :object_prefix ).from( 'classes' ).to( '' )
    end
  end

  describe '.as_resource' do
    it { expect { subject.as_resource }.to raise_exception(ArgumentError) }
    it do
      expect {|b| subject.as_resource( :masked, &b ) }.to yield_control
    end

    it { expect { subject.as_resource( :masked ) {} }.to_not change( subject, :resource_name ) }

    it 'changes the .resource_name within a block' do
      subject.as_resource( :masked ) do
        expect( subject.resource_name ).to eq 'masked'
      end
    end
  end

  describe '.resource_name' do
    it 'is based off the class name' do
      subject.resource_name.should == 'classes/Model'
    end

    it 'is able to include a resource id' do
      subject.resource_name('abc123').should == 'classes/Model/abc123'
    end

    it 'demodulizes the model_name' do
      namespaced_model = subject
      namespaced_model.stub(:model_name).and_return(ActiveModel::Name.new(subject, nil, 'Namespace::Model'))
      namespaced_model.should_receive(:resource_name).and_call_original
      namespaced_model.model_name.name.should == 'Namespace::Model'
      namespaced_model.resource_name.should == 'classes/Model'
    end
  end

  shared_examples_for 'a sent-headers response' do |method, *args|
    let(:options) { args.last.is_a?(Hash) ? args.pop : {} }
    let(:params) { args.push options.merge( sent_headers: true ) }
    let(:request) { subject.send( :"http_#{method}", *params ) }

    it { expect { request }.to_not raise_exception }

    it { expect( request ).to be_a(Hash) }

    if [:put, :post].include? method
      context 'when including a JSON encoded body' do
        it { expect( request ).to have_key 'Content-Type' }
        it { expect( request['Content-Type'] ).to eq 'application/json' }
      end
    end

    context 'when not .requires_heightened_prvileges?' do
      before { subject.instance_variable_set :@requires_heightened_privileges, nil }

      it { expect( subject.requires_heightened_privileges? ).to eq false }

      it { expect( request.keys ).to include( 'X-Parse-Application-Id', 'X-Parse-Rest-Api-Key' ) }
      it { expect( request.keys ).to_not include( 'X-Parse-Master-Key', 'X-Parse-Session-Token' ) }
    end

    unless method == :get
      context 'when .requires_heightened_privileges?' do
        subject do
          Model.requires_heightened_privileges!
          Model.send( :"http_#{method}", *params )
        end

        after { Model.instance_variable_set :@requires_heightened_privileges, nil }

        it { expect( subject.keys ).to include( 'X-Parse-Application-Id', 'X-Parse-Master-Key' ) }
        it { expect( subject.keys ).to_not include( 'X-Parse-Rest-Api-Key', 'X-Parse-Session-Token' ) }
      end
    end
  end

  describe '.http_get' do
    before do
      stub_request( :get, %r{https://api.parse.com/1/classes/Model(\?.+)?} ).
        to_return( status: 200, body: { objectId: 'abc123' }.to_json, headers: { 'Content-Type' => 'application/json' } )
    end

    it 'executes a :get on :connection' do
      subject.connection.should_receive(:get) { response }.with( 'classes/Model' )
      subject.http_get
    end

    it 'uses a resource id if passed an :id option' do
      subject.connection.should_receive(:get) { response }.with( 'classes/Model/abcd1234' )
      subject.http_get id: 'abcd1234'
    end

    it 'returns a raw response if passed :raw_response' do
      subject.http_get( raw_response: true ).should be_a( Faraday::Response )
    end

    it 'sets params for everything within the :query hash' do
      response = subject.http_get query: { keys: 'title,price', order: '-title', limit: 5 }, raw_response: true
      request_params = response.env.url.query.split('&').map {|p| p.split('=')}
      request_params.should =~ { 'keys' => 'title%2Cprice', 'order' => '-title', 'limit' => '5' }
    end

    it 'special cases a :query key of "where", making it json encoded' do
      criteria = { price: { '$lte' => 5 } }
      response = subject.http_get query: { where: criteria }, raw_response: true
      query = URI.decode response.env.url.query
      query.should == "where=#{criteria.to_json}"
    end

    it_behaves_like 'a sent-headers response', :get
  end

  describe '.http_post' do
    it 'executes a :post on :connection' do
      subject.connection.should_receive(:post) { response }
      subject.http_post( {} )
    end

    it_behaves_like 'a sent-headers response', :post, {}, {}
  end

  describe '.http_put' do
    it 'executes a :put on :connection' do
      subject.connection.should_receive(:put) { response }
      subject.http_put( 'abcd1234', {} )
    end

    it_behaves_like 'a sent-headers response', :put, 'abcd1234', {}, {}
  end

  describe '.http_delete' do
    it 'executes a :delete on :connection' do
      subject.connection.should_receive(:delete) { response }
      subject.http_delete( 'abcd1234' )
    end

    it_behaves_like 'a sent-headers response', :delete, 'abcd1234'
  end

  describe '.requires_heightened_privileges!' do
    shared_examples_for 'it has heightened privileges on' do |method, *args|
      before do
        resource = args.first.is_a?(Hash) ? '' : "/#{args.first}"
        to_send = method == :delete ? {} : {body: "{}"}
        headers = method == :delete ? {} : {content_type: 'application/json'}
        stub_request(method, "https://api.parse.com/1/classes/Model#{resource}").
          with(
            to_send.merge(
              headers: headers.merge( x_parse_application_id: 'PARSE_APP_ID', x_parse_master_key: 'PARSE_MASTER_KEY' )
            )
          ).to_return(:status => 200, :body => "{}", :headers => {content_type: 'application/json'})
      end

      it "causes :http_#{method} to add a master-key header" do
        subject.requires_heightened_privileges!
        expect { subject.send( :"http_#{method}", *args ) }.to_not raise_exception
      end
    end

    after { subject.instance_variable_set :@requires_heightened_privileges, nil }

    it { subject.requires_heightened_privileges!.should == true }

    it_behaves_like 'it has heightened privileges on', :post, {}
    it_behaves_like 'it has heightened privileges on', :put, 'abcd1234', {}
    it_behaves_like 'it has heightened privileges on', :delete, 'abcd1234'
  end

  describe '.requires_heightened_privileges?' do
    after { subject.instance_variable_set :@requires_heightened_privileges, nil }

    it { subject.requires_heightened_privileges?.should == false }

    it 'is true if privileges have been raised' do
      subject.requires_heightened_privileges!
      subject.requires_heightened_privileges?.should == true
    end
  end

  describe '.with_heightened_privileges' do
    it { expect {|b| subject.with_heightened_privileges &b}.to yield_control }

    it 'has heightened privileges within the block' do
      subject.with_heightened_privileges do
        expect( subject ).to have_heightened_privileges
      end
    end

    it 'does not have heightened privileges outside the block' do
      subject.with_heightened_privileges {}
      expect( subject ).to_not have_heightened_privileges
    end

    it 'turns off heightened privileges on exceptions' do
      expect { subject.with_heightened_privileges { raise 'expected' } }.to raise_exception
      expect( subject ).to_not have_heightened_privileges
    end

    it 'keeps the previous value of requires_heightened_privileges? after the block' do
      subject.requires_heightened_privileges!
      subject.with_heightened_privileges {}
      expect( subject ).to have_heightened_privileges
      subject.instance_variable_set :@requires_heightened_privileges, nil
    end
  end
end
