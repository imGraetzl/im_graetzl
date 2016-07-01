require 'rails_helper'

RSpec.describe Coordinates do
  let(:address_url) { /.*data.wien.gv.at.*/ }
  before { WebMock.disable_net_connect! allow_localhost: true }

  describe 'attributes' do
    subject { described_class.new address }

    context 'when address with zip' do
      let(:address) { build :address, zip: '1020' }

      it 'has private attribute street' do
        expect(subject.send :street).to eq address.street_name
      end
      it 'has private attribute street_nr' do
        expect(subject.send :street_nr).to eq address.street_number
      end
      it 'has private attribute district_nr' do
        expect(subject.send :district_nr).to eq '2'
      end
    end
    context 'when address without zip' do
      let(:address) { build :address, zip: nil }

      it 'has private attribute street' do
        expect(subject.send :street).to eq address.street_name
      end
      it 'has private attribute street_nr' do
        expect(subject.send :street_nr).to eq address.street_number
      end
      it 'has private attribute district_nr nil' do
        expect(subject.send :district_nr).to be_nil
      end
    end
  end

  describe '#call' do
    let(:address) { build :address }
    let(:service) { described_class.new address }

    subject{ service.call }

    context 'when correct api response' do
      before do
        file = File.join 'spec/support/assets', 'address_service_resp.json'
        json_body = File.read file
        stub_request(:get, address_url).to_return(
          status: 200,
          headers: { 'content-type' => 'application/json; charset=utf-8' },
          body: json_body)
      end

      it 'returns a coordinate' do
        expect(subject).to be_a RGeo::Geos::CAPIPointImpl
      end
      it 'has x and y coordinates' do
        expect(subject).to respond_to(:x)
        expect(subject).to respond_to(:y)
      end
    end
    context 'when empty api response' do
      before do
        stub_request(:get, address_url).to_return(
          status: 200,
          headers: { 'content-type' => 'application/json; charset=utf-8' },
          body: {}.to_json)
      end

      it 'returns nil' do
        expect(subject).to eq nil
      end
    end
    context 'when error occurs' do
      it 'returns nil when timeout' do
        stub_request(:get, address_url).to_timeout
        expect(subject).to be_nil
      end
      it 'returns nil when server error' do
        stub_request(:get, address_url).to_return(status: 500)
        expect(subject).to be_nil
      end
      it 'returns nil when bad request' do
        stub_request(:get, address_url).to_return(status: 422)
        expect(subject).to be_nil
      end
    end
  end
  describe '.call (real network request)' do
    let(:address) { build :address, :esterhazygasse }
    subject { described_class.call address }

    before { WebMock.allow_net_connect! }

    it 'returns a coordinate' do
      expect(subject).to be_a RGeo::Geos::CAPIPointImpl
    end
    it 'has x and y coordinates' do
      expect(subject.x).to eq 16.353120642788344
      expect(subject.y).to eq 48.194150529178096
    end
  end
end
