require 'spec_helper'

describe Opium::Model::Dirty do
  let( :model ) { Class.new { def initialize(a = {}); end; def save(o = {}); end; include Opium::Model::Dirty; } }
  
  describe "instance" do
    subject { model.new }
    
    it { should respond_to( :changed?, :changed, :changed_attributes ) }
  end
  
  describe 'when included in a model' do
    before do
      stub_const( 'Game', Class.new do
        include Opium::Model
        field :title, type: String
      end )
      stub_request(:post, "https://api.parse.com/1/classes/Game").with(
        body: "{\"title\":\"Skyrim\"}",
        headers: {'Content-Type'=>'application/json'}
      ).to_return(
        body: { objectId: 'abcd1234', createdAt: Time.now.to_s }.to_json, 
        status: 200, 
        headers: { 'Content-Type' => 'application/json', Location: 'https://api.parse.com/1/classes/Game/abcd1234' } 
      )
    end
    
    subject { Game.new( title: 'Skyrim' ) }
    
    it 'when instantiated, should not be changed' do
      subject.should_not be_changed
    end
    
    it "when saved, should receive #changes_applied" do
      subject.should receive(:changes_applied)
      subject.save
    end    
  end
end