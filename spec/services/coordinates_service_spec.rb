require 'rails_helper'
require 'coordinates_service'
include GeojsonSupport

RSpec.describe CoordinatesService do

  # describe 'attributes' do
  #   let(:address) { build(:address) }
  #   subject(:service) { CoordinatesService.new(address) }

  #   it 'assigns @street with address.street_name' do
  #     expect(service.instance_variable_get(:@street)).to eq address.street_name
  #   end

  #   it 'assigns @house with address.street_number' do
  #     expect(service.instance_variable_get(:@house)).to eq address.street_number
  #   end

  #   it 'assigns @district' do
  #     expect(service.instance_variable_get(:@district)).not_to be_nil
  #   end

  #   it 'assigns empty @best_feature' do
  #     expect(service.instance_variable_get(:@best_feature)).to eq nil
  #   end
  # end

  # describe '_#zip_to_numeric' do
  #   context 'when zip 4 digit single number district' do
  #     let(:service) { CoordinatesService.new(build(:address, zip: '1070')) }

  #     it 'returns single digit' do
  #       expect(service.send(:zip_to_numeric, '1070')).to eq '7'
  #     end

  #     it 'assigns @district with single digit' do
  #       expect(service.instance_variable_get(:@district)).to eq '7'
  #     end
  #   end

  #   context 'when zip 4 digit double number district' do
  #     let(:service) { CoordinatesService.new(build(:address, zip: '1160')) }

  #     it 'returns double digit' do
  #       expect(service.send(:zip_to_numeric, '1160')).to eq '16'
  #     end

  #     it 'assigns @district with double digit' do
  #       expect(service.instance_variable_get(:@district)).to eq '16'
  #     end
  #   end

  #   context 'when zip nil' do
  #     let(:service) { CoordinatesService.new(build(:address, zip: nil)) }

  #     it 'returns nil' do
  #       expect(service.send(:zip_to_numeric, nil)).to eq nil
  #     end

  #     it 'assigns @district with nil' do
  #       expect(service.instance_variable_get(:@district)).to eq nil
  #     end
  #   end
  # end

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
end