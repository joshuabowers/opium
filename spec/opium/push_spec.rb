require 'spec_helper'

describe Opium::Push do
  it { expect( described_class ).to be <= Opium::Model::Connectable }

  it { expect( described_class ).to respond_to(:to_ruby, :to_parse).with(1).argument }

  it { is_expected.to respond_to( :create, :channels, :data, :alert, :badge, :sound, :content_available, :category, :uri, :title, :expires_at, :push_at, :expiration_interval ) }

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
      push.create
    end

    let(:push) do
      subject.tap do |p|
        p.channels = channels
        p.alert = alert
        p.push_at = push_at if push_at
        p.expires_at = expires_at if expires_at
        p.expiration_interval = expiration_interval if expiration_interval
      end
    end

    let(:push_post_data) { push.send(:post_data) }

    let(:alert) { 'Zoo animals are fighting!' }
    let(:channels) { %w{ General } }
    let(:push_at) { nil }
    let(:expires_at) { nil }
    let(:expiration_interval) { nil }

    let(:one_day_ago) { Time.now - 86400 }
    let(:one_day_from_now) { Time.now + 86400 }
    let(:one_week) { 604800 }
    let(:one_week_from_now) { Time.now + one_week }
    let(:three_weeks_from_now) { Time.now + ( 3 * one_week ) }

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

    context 'with a scheduled push' do
      let(:push_at) { one_day_from_now }

      it { expect { push_post_data }.not_to raise_exception }
      it 'sets the proper push_time' do
         expect( push_post_data ).to include( push_time: push_at.iso8601 )
      end
    end

    context 'with a scheduled push before now' do
      let(:push_at) { one_day_ago }

      it { expect { result }.to raise_exception( ArgumentError ) }
    end

    context 'with a scheduled push too long from now' do
      let(:push_at) { three_weeks_from_now }

      it { expect { result }.to raise_exception( ArgumentError ) }
    end

    context 'with a scheduled push and an expiration inverval' do
      let(:push_at) { one_day_from_now }
      let(:expiration_interval) { one_week }

      it { expect { push_post_data }.not_to raise_exception }
      it 'sets the proper push_time' do
        expect( push_post_data ).to include( push_time: push_at.iso8601 )
      end
      it 'sets the proper expiration_interval' do
        expect( push_post_data ).to include( expiration_interval: expiration_interval )
      end
    end

    context 'without a scheduled push and with an expiration inverval' do
      let(:expiration_interval) { one_week }

      it { expect { result }.to raise_exception( ArgumentError ) }
    end

    context 'with an expiry' do
      let(:expires_at) { one_week_from_now }

      it { expect { push_post_data }.not_to raise_exception }
      it 'sets the proper expiration_time' do
        expect( push_post_data ).to include( expiration_time: expires_at.iso8601 )
      end
    end
  end
end
