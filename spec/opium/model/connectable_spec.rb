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
    it { should respond_to( :no_object_prefix! ) }
    it { should respond_to( :as_resource ).with(1).argument }
    it { should respond_to( :resource_name ).with(1).argument }
    it { should respond_to( :http_get, :http_post, :http_delete ).with(1).argument }
    it { should respond_to( :http_put ).with(2).arguments }
    it { should respond_to( :requires_heightened_privileges!, :requires_heightened_privileges? ) }
    
    its( :object_prefix ) { should == 'classes' }
    
    describe ':reset_connection!' do
      it 'should cause :connection to create a new connection object' do
        previous = subject.connection
        subject.reset_connection!
        subject.connection.should_not equal( previous )
      end
    end
    
    describe ':no_object_prefix!' do
      after do
        Model.instance_variable_set :@object_prefix, nil
      end
      
      it 'should have an empty object_prefix' do
        expect { subject.no_object_prefix! }.to change( subject, :object_prefix ).from( 'classes' ).to( '' )
      end
    end
    
    describe ':as_resource' do
      it { expect { subject.as_resource }.to raise_exception(ArgumentError) }
      it do
        expect {|b| subject.as_resource( :masked, &b ) }.to yield_control
      end
      
      it 'should cause :resource_name to return the supplied name' do
        subject.as_resource( :masked ) do
          subject.resource_name.should == 'masked'
        end
        subject.resource_name.should == 'classes/Model' 
      end
    end
    
    describe ':resource_name' do
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
    
    describe ':requires_heightened_privileges!' do
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
        
        it "should cause :http_#{method} to add a master-key header" do
          subject.requires_heightened_privileges!
          expect { subject.send( :"http_#{method}", *args ) }.to_not raise_exception
        end
      end
      
      after { subject.instance_variable_set :@requires_heightened_privileges, nil }
      
      it { subject.requires_heightened_privileges!.should == true }
      
      it_should_behave_like 'it has heightened privileges on', :post, {}
      it_should_behave_like 'it has heightened privileges on', :put, 'abcd1234', {}
      it_should_behave_like 'it has heightened privileges on', :delete, 'abcd1234'
    end
    
    describe ':requires_heightened_privileges?' do
      after { subject.instance_variable_set :@requires_heightened_privileges, nil }
      
      it { subject.requires_heightened_privileges?.should == false }
      
      it 'should be true if privileges have been raised' do
        subject.requires_heightened_privileges!
        subject.requires_heightened_privileges?.should == true
      end
    end
  end
end