require 'spec_helper'

describe Opium::Model::Serialization do
  let( :model ) do
    Class.new do
      include Opium::Model
      field :name
      field :price
    end
  end

  it { model.should respond_to( :include_root_in_json ) }
  it "include_root_in_json should default to false" do
    model.include_root_in_json.should == false
  end

  describe "instance" do
    describe "with no data" do
      let( :params ) { { "id" => nil, "created_at" => nil, "updated_at" => nil, "name" => nil, "price" => nil } }
      subject { model.new }
      its(:as_json) { should == params }
      describe "to_json" do
        it "should have no values in the JSON data" do
          JSON.parse(subject.to_json).should include( params )
        end
      end
    end

    describe "with partial data" do
      let( :params ) { { "name" => "test", "price" => nil } }
      subject { model.new( name: "test" ) }
      its(:as_json) { should include( params ) }
      describe "to_json" do
        it "should have the set values in the JSON data" do
          JSON.parse(subject.to_json).should include( params )
        end
      end
    end

    describe "with full data" do
      let( :params ) { { "name" => "test", "price" => 75.0 } }
      subject { model.new( params ) }
      its(:as_json) { should include( params ) }
      describe "to_json" do
        it "should have all values in the JSON data" do
          JSON.parse(subject.to_json).should include( params )
        end
      end
    end

    describe 'with non field data' do
      let( :params ) { {'name' => 'test', 'price' => 75.0, 'extra' => true} }
      subject { model.new( params ) }
      it { expect { subject.as_json }.to_not raise_exception }

      describe '#to_json' do
        let(:result) { JSON.parse(subject.to_json) }

        it 'only has field values' do
          expect( result ).to include( 'name', 'price' )
          expect( result ).to_not include( 'extra' )
        end
      end
    end
  end
end
