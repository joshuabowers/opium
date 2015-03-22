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
    
  describe 'in a model' do
    subject { Model }
    let( :response ) { double('Response').tap {|r| allow(r).to receive(:body) } }
    
    it { should respond_to( :connection ) }
    it { should respond_to( :reset_connection! ) }
    it { should respond_to( :object_prefix ) }
    it { should respond_to( :resource_name ).with(1).argument }
    it { should respond_to( :http_get, :http_post, :http_delete ).with(1).argument }
    it { should respond_to( :http_put ).with(2).arguments }
    
    its( :object_prefix ) { should == 'classes' }
    
    describe ':reset_connection!' do
      it 'should cause :connection to create a new connection object' do
        previous = subject.connection
        subject.reset_connection!
        subject.connection.should_not equal( previous )
      end
    end
    
    describe 'resource_name' do
      it 'should be based off the class name' do
        subject.resource_name.should == 'classes/Model'
      end
      
      it 'should be able to include a resource id' do
        subject.resource_name('abc123').should == 'classes/Model/abc123'
      end
      
      it 'should demodulize the model_name' do
        namespaced_model = subject
        namespaced_model.stub(:model_name).and_return(ActiveModel::Name.new(subject, nil, 'Namespace::Model'))
        namespaced_model.should_receive(:resource_name).and_call_original
        namespaced_model.model_name.name.should == 'Namespace::Model'
        namespaced_model.resource_name.should == 'classes/Model'
      end
    end
    
    describe ':http_get' do
      before do
        stub_request( :get, %r{https://api.parse.com/1/classes/Model(\?.+)?} ).
          to_return( status: 200, body: { objectId: 'abc123' }.to_json, headers: { 'Content-Type' => 'application/json' } )
      end
      
      it 'should execute a :get on :connection' do
        subject.connection.should_receive(:get) { response }.with( 'classes/Model' )
        subject.http_get
      end
      
      it 'should use a resource id if passed an :id option' do
        subject.connection.should_receive(:get) { response }.with( 'classes/Model/abcd1234' )
        subject.http_get id: 'abcd1234'
      end
      
      it 'should return a raw response if passed :raw_response' do
        subject.http_get( raw_response: true ).should be_a( Faraday::Response )
      end
      
      it 'should set params for everything within the :query hash' do
        response = subject.http_get query: { keys: 'title,price', order: '-title', limit: 5 }, raw_response: true
        request_params = response.env.url.query.split('&').map {|p| p.split('=')}
        request_params.should =~ { 'keys' => 'title%2Cprice', 'order' => '-title', 'limit' => '5' }
      end
      
      it 'should special case a :query key of "where", making it json encoded' do
        criteria = { price: { '$lte' => 5 } }
        response = subject.http_get query: { where: criteria }, raw_response: true
        query = URI.decode response.env.url.query
        query.should == "where=#{criteria.to_json}"
      end
    end
    
    describe ':http_post' do
      it 'should execute a :post on :connection' do
        subject.connection.should_receive(:post) { response }
        subject.http_post( {} )
      end
    end
    
    describe ':http_put' do
      it 'should execute a :put on :connection' do
        subject.connection.should_receive(:put) { response }
        subject.http_put( 'abcd1234', {} )
      end
    end
    
    describe ':http_delete' do
      it 'should execute a :delete on :connection' do
        subject.connection.should_receive(:delete) { response }
        subject.http_delete( 'abcd1234' )
      end
    end
  end
end