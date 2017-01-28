require 'spec_helper'

describe Opium::Push do
  it { expect( described_class ).to be <= Opium::Model::Connectable }

  it { expect( described_class ).to respond_to(:to_ruby, :to_parse).with(1).argument }

  it { is_expected.to respond_to( :create, :channels, :data, :alert ) }

  describe '#alert' do
    let(:result) do
      subject.data = data
      subject.alert
    end

    context 'with no data' do
      let(:data) { { } }

      it 'equals data[:alert]' do
        expect( result ).to be_nil
      end
    end

    context 'with alert data' do
      let(:data) { { alert: 'The sky is blue.' } }

      it 'equals data[:alert]' do
        expect( result ).to eq data[:alert]
      end
    end
  end

  describe '#alert=' do
    let(:result) do
      subject.alert = alert
      subject.data[:alert]
    end

    context 'with nothing' do
      let(:alert) { nil }

      it 'equals data[:alert]' do
        expect( result ).to be_nil
      end
    end

    context 'with text' do
      let(:alert) { 'The sky is blue.' }

      it 'equals data[:alert]' do
        expect( result ).to eq alert
      end
    end
  end

  describe '#create' do
    let(:result) do
      subject.tap do |push|
        push.channels = channels
        push.alert = alert
      end.create
    end

    let(:alert) { 'Zoo animals are fighting!' }

    before do
      stub_request(:post, "https://api.parse.com/1/push").
         with(body: "{\"channels\":[\"Penguins\",\"PolarBears\"],\"data\":{\"alert\":\"Zoo animals are fighting!\"}}",
              headers: {'Content-Type'=>'application/json', 'X-Parse-Application-Id'=>'PARSE_APP_ID', 'X-Parse-Master-Key' => 'PARSE_MASTER_KEY'}).
         to_return(:status => 200, :body => { result: true }.to_json, :headers => {content_type: 'application/json'})
    end

    context 'with no channels' do
      let(:channels) { [] }

      it { expect { result }.to raise_exception( ArgumentError ) }
    end

    context 'with channels' do
      let(:channels) { %w{ Penguins PolarBears } }

      it { expect { result }.to_not raise_exception }
      it { expect( result ).to eq true }
    end
  end
end
