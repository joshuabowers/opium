require 'spec_helper'

describe Opium::Installation do

  it { described_class.should respond_to( :object_prefix ) }

  it { should be_an( Opium::Model ) }

  it { expect( described_class ).to have_heightened_privileges }

  describe '#object_prefix' do
    it { expect( described_class.object_prefix ).to be_empty }
  end

  describe '#resource_name' do
    it { expect( described_class.resource_name ).to eq 'installations' }
  end

  %w{ badge channels time_zone device_type push_type gcm_sender_id
    installation_id device_token channel_uris app_name app_version
    parse_version app_identifier }.each do |field_name|
    it { described_class.fields.should have_key( field_name ) }
  end

  %w{ device_type push_type installation_id }.each do |field_name|
    describe "##{ field_name }" do
      it { expect( described_class.fields[field_name] ).to be_readonly }
    end
  end

  context 'within a subclass' do
    before do
      stub_const( 'SpecialInstallation', Class.new(Opium::Installation) do
        field :has_web_access, type: Opium::Boolean
      end )
    end

    subject { SpecialInstallation }

    it { is_expected.to be <= Opium::Installation }
    it { is_expected.to respond_to( :field, :fields ) }
    it { expect( subject.fields.keys ).to include( 'badge', 'device_token', 'has_web_access' ) }

    it { expect( subject ).to have_heightened_privileges }

    describe '#object_prefix' do
      it { expect( subject.object_prefix ).to be_empty }
    end

    describe '#resource_name' do
      it { expect( subject.resource_name ).to eq 'installations' }
    end
  end
end
