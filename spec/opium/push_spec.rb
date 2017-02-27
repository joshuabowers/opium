require 'spec_helper'

describe Opium::Push do
  it { expect( described_class ).to be <= Opium::Model::Connectable }

  it { expect( described_class ).to respond_to(:to_ruby, :to_parse).with(1).argument }

  it { is_expected.to respond_to( :create, :channels, :data, :alert, :badge, :sound, :content_available, :category, :uri, :title ) }

  shared_examples_for 'a push option getter' do |option, value|
    let(:result) do
      subject.data = data
      subject.send(option)
    end

    context 'with no data' do
      let(:data) { { } }

      it "equals data[:#{ option }]" do
        expect( result ).to be_nil
      end
    end

    context "with a value" do
      let(:data) { { option => value } }

      it "equals data[:#{ option }]" do
        expect( result ).to eq data[option]
      end
    end
  end

  shared_examples_for 'a push option setter' do |option, value|
    let(:result) do
      subject.send( "#{ option }=".to_sym, option_value )
      subject.data[option]
    end

    context 'with nothing' do
      let(:option_value) { nil }

      it "equals data[:#{ option }]" do
        expect( result ).to be_nil
      end
    end

    context 'with a value' do
      let(:option_value) { value }

      it "equals data[:#{ option }]" do
        expect( result ).to eq option_value
      end
    end
  end

  {
    alert: 'The sky is blue.',
    badge: 'Increment',
    sound: 'cheering.caf',
    content_available: 1,
    category: 'A category',
    uri: 'https://example.com',
    title: 'Current Weather'
  }.each do |option, value|
    describe "##{ option }" do
      it_behaves_like 'a push option getter', option, value
    end

    describe "##{ option }=" do
      it_behaves_like 'a push option setter', option, value
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
