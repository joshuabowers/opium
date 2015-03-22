require 'spec_helper'

describe Opium::User do
  it { described_class.should respond_to( :authenticate ).with(2).arguments }
  
  it { should be_an( Opium::Model ) }
  
  [:username, :password, :email, :email_verified].each do |field_name|
    it { described_class.fields.should have_key( field_name ) }
  end
  
  describe 'instance' do
    it { should respond_to( :reset_password ) }
  end
end