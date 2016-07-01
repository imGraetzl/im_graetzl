require 'rails_helper'
include GeojsonSupport

RSpec.describe CoordinatesService do
  before { WebMock.disable_net_connect!(allow_localhost: true) }

  describe 'attributes' do
    let(:address) { build(:address) }
    subject(:service) { CoordinatesService.new(address) }

    it 'assigns @street with address.street_name' do
      expect(service.instance_variable_get(:@street)).to eq address.street_name
    end

    it 'assigns @house with address.street_number' do
      expect(service.instance_variable_get(:@house)).to eq address.street_number
    end

    it 'assigns @district' do
      expect(service.instance_variable_get(:@district)).not_to be_nil
    end
  end

  describe '#coordinates' do
    let(:service) { CoordinatesService.new(build(:address)) }
    subject(:coords) { service.coordinates }

    context 'when api data available' do
      let(:api_response_body) { File.read(File.join('spec', 'support', 'assets', 'address_service_resp.json')) }

      before do
        stub_request(:get, /.*data.wien.gv.at.*/).to_return(
          status: 200,
          headers: { 'content-type' => 'application/json; charset=utf-8' },
          body: api_response_body)
      end

      it 'does not return nil' do
        expect(coords).not_to be_nil
      end

      it 'returns valid coordinates' do
        expect(coords).to respond_to(:x)
        expect(coords).to respond_to(:y)
      end
    end

    context 'when no data available' do
      before { stub_request(:get, /.*data.wien.gv.at.*/) }

      it 'returns nil' do
        expect(coords).to eq nil
      end
    end
  end

  describe '_#zip_to_numeric' do
    context 'when zip 4 digit single number district' do
      let(:service) { CoordinatesService.new(build(:address, zip: '1070')) }

      it 'returns single digit' do
        expect(service.send(:zip_to_numeric, '1070')).to eq '7'
      end

      it 'assigns @district with single digit' do
        expect(service.instance_variable_get(:@district)).to eq '7'
      end
    end

    context 'when zip 4 digit double number district' do
      let(:service) { CoordinatesService.new(build(:address, zip: '1160')) }

      it 'returns double digit' do
        expect(service.send(:zip_to_numeric, '1160')).to eq '16'
      end

      it 'assigns @district with double digit' do
        expect(service.instance_variable_get(:@district)).to eq '16'
      end
    end

    context 'when zip nil' do
      let(:service) { CoordinatesService.new(build(:address, zip: nil)) }

      it 'returns nil' do
        expect(service.send(:zip_to_numeric, nil)).to eq nil
      end

      it 'assigns @district with nil' do
        expect(service.instance_variable_get(:@district)).to eq nil
      end
    end
  end

  describe '_#find_best_feature' do
    let(:matching) { feature_hash(1,1,'7') }

    context 'when first matches' do
      let(:features) {
        [matching, feature_hash(1,1,'7'), feature_hash(1,1,'6'), feature_hash(1,1,'8')]
      }

      it 'returns first' do
        service = CoordinatesService.new(build(:address, zip: '1070'))
        expect(service.send(:find_best_feature, features)).to eq matching
      end
    end

    context 'when first does not match' do
      let(:features) {
        [feature_hash(1,1,'6'), matching, feature_hash(1,1,'7'), feature_hash(1,1,'6'), feature_hash(1,1,'8')]
      }
      it 'returns first matching' do
        service = CoordinatesService.new(build(:address, zip: '1070'))
        expect(service.send(:find_best_feature, features)).to eq matching
      end
    end

    context 'when first and last do not match' do
      let(:features) {
        [feature_hash(1,1,'6'), matching, feature_hash(1,1,'6'), feature_hash(1,1,'8')]
      }
      it 'returns first matching' do
        service = CoordinatesService.new(build(:address, zip: '1070'))
        expect(service.send(:find_best_feature, features)).to eq matching
      end
    end

    context 'when none matches' do
      let(:features) {
        [matching, feature_hash(1,1,'6'), feature_hash(1,1,'8')]
      }
      it 'returns first' do
        service = CoordinatesService.new(build(:address, zip: '1160'))
        expect(service.send(:find_best_feature, features)).to eq matching
      end
    end
  end

  describe '_#query_api' do
    let(:service) { CoordinatesService.new(build(:address)) }

    context 'when successful request' do
      let(:api_response_body) { File.read(File.join('spec', 'support', 'assets', 'address_service_resp.json')) }

      before do
        stub_request(:get, CoordinatesService::BASE_URI).to_return(
          status: 200,
          headers: { 'content-type' => 'application/json; charset=utf-8' },
          body: api_response_body)
      end

      it 'does not return nil' do
        expect(service.send(:query_api, nil)).not_to be_nil
      end

      it 'returns features only' do
        features = JSON.parse(api_response_body)['features']
        expect(service.send(:query_api, nil)).to eq features
      end
    end

    context 'when problem' do

      it 'returns nil when no features' do
        stub_request(:get, CoordinatesService::BASE_URI)
        expect(service.send(:query_api, nil)).to eq nil
      end

      it 'returns nil when no api response' do
        stub_request(:any, CoordinatesService::BASE_URI).to_raise(StandardError)
        expect(service.send(:query_api, nil)).to eq nil
      end

      it 'returns nil when api timeout' do
        stub_request(:get, CoordinatesService::BASE_URI).to_timeout
        expect(service.send(:query_api, nil)).to eq nil
      end
    end
  end
end
