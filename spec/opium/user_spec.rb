require 'spec_helper'

describe Opium::User do
  it { described_class.should respond_to( :authenticate, :authenticate! ).with(2).arguments }
  it { described_class.should respond_to( :object_prefix ) }
  
  it { should be_an( Opium::Model ) }
  
  [:username, :password, :email, :email_verified, :session_token].each do |field_name|
    it { described_class.fields.should have_key( field_name ) }
  end
  
  it { described_class.fields[:session_token].should be_readonly }
  it { described_class.object_prefix.should be_empty }
  
  describe 'instance' do
    it { should respond_to( :reset_password ) }
  end
end