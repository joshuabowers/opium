require 'spec_helper'

describe Opium::GeoPoint do
  subject { described_class }

  it { is_expected.to respond_to( :to_ruby, :to_parse ).with( 1 ).argument }
  it { is_expected.to be <= Comparable }
  it { expect( described_class.constants ).to include( :NULL_ISLAND ) }

  describe Opium::GeoPoint::NULL_ISLAND do
    it { is_expected.to be_frozen }
    it { is_expected.to be_a Opium::GeoPoint }

    it { expect( subject.latitude ).to eq 0 }
    it { expect( subject.longitude ).to eq 0 }
  end

  describe '.to_ruby' do
    let(:result) { subject.to_ruby( convert_from ) }

    context 'with valid object representations' do
      [ "33.33, -117.117", {latitude: 33.33, longitude: -117.117}, [33.33, -117.117], described_class.new( [33.33, -117.117] ) ].each do |value|
        let(:convert_from) { value }
        it { expect { result }.to_not raise_exception }
        it { expect( result ).to be_a described_class }
        it( 'sets the proper latitude' ) { expect( result.latitude ).to eq 33.33 }
        it( 'sets the proper longitude' ) { expect( result.longitude ).to eq -117.117 }
      end
    end

    context 'with invalid object representations' do
      [ "malformed", {latitude: 0, bad_key: :unknown}, [0], 1, 1.0, true, false ].each do |value|
        let(:convert_from) { value }
        it { expect { subject.to_ruby( value ) }.to raise_exception }
      end
    end
  end

  describe '.to_parse' do
    let(:result) { subject.to_parse( convert_from ) }
    let(:expected) { { "__type" => "GeoPoint", "latitude" => 33.33, "longitude" => -117.117 } }

    context 'with valid object representations' do
      [ "33.33, -117.117", {latitude: 33.33, longitude: -117.117}, [33.33, -117.117], described_class.new( [33.33, -117.117] ) ].each do |value|
        let(:convert_from) { value }

        it { expect { result }.to_not raise_exception }
        it { expect( result ).to eq expected }
      end
    end
  end

  describe '#initialize' do
    let(:result) { described_class.new( initialize_from ) }

    context 'with an array value' do
      let(:initialize_from) { [ 33.33, -117.117 ] }

      it { expect { result }.to_not raise_exception }
    end

    context 'with a hash value' do
      let(:initialize_from) { { latitude: 33.33, longitude: -117.117 } }

      it { expect { result }.to_not raise_exception }
    end

    context 'with a string value' do
      let(:initialize_from) { "33.33, -117.117" }

      it { expect { result }.to_not raise_exception }
    end

    context 'with anything else' do
      let(:initialize_from) { 42 }

      it { expect { result }.to raise_exception }
    end
  end

  describe '#<=>' do
    let(:a) { described_class.new( [0, 0] ) }
    let(:result) { a <=> b }

    context 'with a value less than a test value' do
      let(:b) { described_class.new( [1, 1] ) }

      it { expect( result ).to eq -1 }
    end

    context 'with a value equal to a test value' do
      let(:b) { described_class.new( [0, 0] ) }

      it { expect( result ).to eq 0 }
    end

    context 'with a value greater than a test value' do
      let(:b) { described_class.new( [-1, -1] ) }

      it { expect( result ).to eq 1 }
    end
  end

  describe "instance" do
    describe "with an array value" do
      subject { described_class.new [33.33, -117.117] }
      it { should respond_to(:latitude, :longitude, :to_geo_point, :to_parse).with(0).arguments }
      it { should respond_to(:latitude=, :longitude=).with(1).argument }

      its(:latitude) { should == 33.33 }
      its(:longitude) { should == -117.117 }
      its(:to_geo_point) { should == subject }
      its(:to_parse) { should == { "__type" => "GeoPoint", "latitude" => 33.33, "longitude" => -117.117 } }
      its(:to_s) { should == "33.33,-117.117" }
    end

    describe "with a hash value" do
      subject { described_class.new latitude: 33.33, longitude: -117.117 }
      it { should respond_to(:latitude, :longitude, :to_geo_point, :to_parse).with(0).arguments }
      it { should respond_to(:latitude=, :longitude=).with(1).argument }

      its(:latitude) { should == 33.33 }
      its(:longitude) { should == -117.117 }
      its(:to_geo_point) { should == subject }
      its(:to_parse) { should == { "__type" => "GeoPoint", "latitude" => 33.33, "longitude" => -117.117 } }
      its(:to_s) { should == "33.33,-117.117" }
    end
  end
end
