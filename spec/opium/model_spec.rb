require 'spec_helper'

describe Opium::Model do
  before do
    stub_const( 'Event', Class.new do
      include Opium::Model
      field :name, type: String
      field :occurred_at, type: DateTime
      field :severe, type: Boolean
    end )
  end
  
  subject { Event }
  
  it { should respond_to( :model_name, :validates, :define_model_callbacks ) }
  it { should respond_to( :field ).with(2).arguments }
  it { should respond_to( :delete_all, :find ).with(1).argument }
  it { should respond_to( :connection ) }
  it { should respond_to( :human_attribute_name, :lookup_ancestors ) }
  
  describe 'instance' do
    subject { Event.new }
    
    it { should respond_to( :attributes ) }
    it { should respond_to( :serializable_hash, :as_json, :from_json ) }
    it { should respond_to( :changes, :changed? ) }
    it { should respond_to( :inspect ) }
    it { should respond_to( :to_key, :to_model ) }
    
    its(:attributes) do
      should_not be_nil
      should be_a_kind_of( Hash )
    end
  end
  
  describe 'inspect' do
    describe 'within a blank model' do
      subject { Event.new }
      
      it { subject.inspect.should == '#<Event id: nil, created_at: nil, updated_at: nil, name: nil, occurred_at: nil, severe: nil>' }
    end
    
    describe 'within a model with data' do
      let(:event_time) { Time.now }
      subject { Event.new id: 'abc123', name: 'ping', occurred_at: event_time, severe: false }
      it { subject.inspect.should == "#<Event id: \"abc123\", created_at: nil, updated_at: nil, name: \"ping\", occurred_at: #{event_time.to_datetime.inspect}, severe: false>" }
    end
  end
end