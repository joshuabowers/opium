require 'spec_helper'

describe Opium::Model do
  before do
    stub_const( 'Event', Class.new do
      include Opium::Model
      field :name, type: String
      field :occurred_at, type: DateTime
      field :severe, type: Opium::Boolean
    end )
  end
  
  subject { Event }
  
  it { is_expected.to be <= Opium::Model::Connectable }
  it { is_expected.to be <= Opium::Model::Persistable }
  it { is_expected.to be <= Opium::Model::Dirty }
  it { is_expected.to be <= Opium::Model::Fieldable }
  it { is_expected.to be <= Opium::Model::Serialization }
  it { is_expected.to be <= Opium::Model::Attributable }
  it { is_expected.to be <= Opium::Model::Queryable }
  it { is_expected.to be <= Opium::Model::Callbacks }
  it { is_expected.to be <= Opium::Model::Scopable }
  it { is_expected.to be <= Opium::Model::Findable }
  it { is_expected.to be <= Opium::Model::Inheritable }
  it { is_expected.to be <= Opium::Model::Batchable }
  it { is_expected.to be <= Opium::Model::Relatable }
    
  describe '#inspect' do
    context 'within a blank model' do
      subject { Event.new }
      
      it { expect( subject.inspect ).to eq '#<Event id: nil, created_at: nil, updated_at: nil, name: nil, occurred_at: nil, severe: nil>' }
    end
    
    context 'within a model with data' do
      let(:event_time) { Time.now }
      subject { Event.new id: 'abc123', name: 'ping', occurred_at: event_time, severe: false }
      it { expect( subject.inspect ).to eq "#<Event id: \"abc123\", created_at: nil, updated_at: nil, name: \"ping\", occurred_at: #{event_time.to_datetime.inspect}, severe: false>" }
    end
  end
end