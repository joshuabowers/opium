require 'spec_helper'

describe Opium::User do
  before do
    stub_request(:get, 'https://api.parse.com/1/login?password=swordfish&username=username').to_return(
      status: 200, 
      body: { 
        username: 'username', 
        createdAt: '2014-11-01T12:00:30Z', 
        updatedAt: '2015-02-10T16:37:23Z',
        objectId: 'abcd1234',
        sessionToken: 'super-secret-session-id'
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
    
    stub_request(:get, 'https://api.parse.com/1/login?password=deadbeef&username=username').to_return(
      status: 404,
      body: {
        error: 'invalid login parameters',
        code: 101
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
    
    stub_request(:post, "https://api.parse.com/1/requestPasswordReset").with(
      body: "{\"data\":\"user@email.com\"}",
      headers: { 'Content-Type'=>'application/json' }
    ).to_return(
      status: 200,
      body: "{}", 
      headers: {'Content-Type' => 'application/json'}
    )
    
    stub_request(:get, "https://api.parse.com/1/users/me").
      with( headers: {'X-Parse-Session-Token'=>'super-secret-session-id'} ).
      to_return(
        :status => 200, 
        :body => {
          username: 'username', 
          createdAt: '2014-11-01T12:00:30Z', 
          updatedAt: '2015-02-10T16:37:23Z',
          objectId: 'abcd1234'
        }.to_json, 
        headers: { 'Content-Type' => 'application/json' }
      )
      
    stub_request(:get, "https://api.parse.com/1/users/me").
      with( headers: {'X-Parse-Session-Token'=>'never-been-given-out'}).
      to_return(
        status: 404, 
        body: {
          code: 101,
          error: 'invalid session'
        }.to_json, 
        headers: { 'Content-Type' => 'application/json' }
      )
  end
  
  it { described_class.should respond_to( :authenticate, :authenticate! ).with(2).arguments }
  it { described_class.should respond_to( :find_by_session_token ).with(1).argument }
  it { described_class.should respond_to( :object_prefix ) }
  
  it { should be_an( Opium::Model ) }
  
  [:username, :password, :email, :email_verified, :session_token].each do |field_name|
    it { described_class.fields.should have_key( field_name ) }
  end
  
  it { described_class.fields[:session_token].should be_readonly }
  it { described_class.object_prefix.should be_empty }
  it { described_class.resource_name.should == 'users' }
  
  describe ':authenticate' do
    describe 'a good login' do
      it 'should return an Opium::User matching the credentials' do
        expect { described_class.authenticate( 'username', 'swordfish' ) }.to_not raise_exception
        
        login = described_class.authenticate( 'username', 'swordfish' )
        
        login.should_not be_nil 
        login.should be_a( described_class ) 
        login.username.should == 'username' 
        login.session_token.should_not be_nil
      end

    end
    
    describe 'a bad login' do
      let(:login) { described_class.authenticate( 'username', 'deadbeef' ) }
      
      it { expect { login }.to_not raise_exception }
      it { login.should be_nil }
    end
  end
  
  describe ':authenticate!' do
    describe 'a good login' do
      it { expect { described_class.authenticate!( 'username', 'swordfish' ) }.to_not raise_exception }
    end
    
    describe 'a bad login' do
      it { expect { described_class.authenticate!( 'username', 'deadbeef' ) }.to raise_exception }
    end
  end
  
  describe ':find_by_session_token' do
    describe 'without a token' do
      it { expect { described_class.find_by_session_token( nil ) }.to raise_exception }
    end
    
    describe 'with a valid token' do
      let(:current_user) { described_class.find_by_session_token( 'super-secret-session-id' ) }
      
      it { expect { current_user }.to_not raise_exception }
      it { current_user.should be_a( described_class ) }
    end
    
    describe 'with an invalid token' do
      it { expect { described_class.find_by_session_token( 'never-been-given-out' ) }.to raise_exception(Opium::Model::Connectable::ParseError) }
    end
  end
  
  describe 'instance' do
    subject { Opium::User.new( id: 'abcd1234', session_token: 'super-secret-session-id', usernmae: 'user', email: 'user@email.com' ) }
    
    it { should respond_to( :reset_password, :reset_password! ) }
    
    describe ':reset_password' do
      describe 'without an email' do
        before { subject.email = nil }
        after { subject.email = 'user@example.com' }
        
        it { expect { subject.reset_password }.to_not raise_exception }
        it do 
          subject.reset_password.should == false
          subject.errors.should_not be_empty
        end
      end
      
      describe 'with an email' do
        it { expect { subject.reset_password }.to_not raise_exception }
        it { subject.reset_password.should == true }
      end
    end
    
    describe ':reset_password!' do
      describe 'without an email' do
        before { subject.email = nil }
        after { subject.email = 'user@example.com' }
        
        it { expect { subject.reset_password! }.to raise_exception }
      end
      
      describe 'with an email' do
        it { expect { subject.reset_password! }.to_not raise_exception }
        it { subject.reset_password!.should == true }
      end
    end
  end
end