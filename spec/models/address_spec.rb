require 'rails_helper'
include GeojsonSupport

RSpec.describe Address, type: :model do

  it 'has a valid factory' do
    expect(build :address).to be_valid
    expect(build :address, :esterhazygasse).to be_valid
  end

  describe 'associations' do
    it 'has addressable' do
      expect(build :address).to respond_to :addressable
    end
  end

  describe '#district_nr' do
    subject { address.district_nr }

    context 'when zip present' do
      let(:address) { build :address, zip: 1070 }

      it 'returns district number as string' do
        expect(subject).to eq '7'
      end
    end
    context 'when no zip' do
      let(:address) { build :address, zip: nil }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '.from_feature' do
    let(:feature) { feature_hash }

    subject(:address) { Address.from_feature(feature.to_json) }

    it 'returns new address' do
      expect(address).to be_a_new(Address)
    end

    context 'with valid json' do
      it 'has attributes from feature' do
        expect(address).to have_attributes(
          street_name: feature['properties']['StreetName'],
          street_number: feature['properties']['StreetNumber'],
          zip: feature['properties']['PostalCode'],
          city: feature['properties']['Municipality'],
          )
      end

      it 'sets coordinates' do
        expect(address.coordinates).not_to be_nil
        expect(address.coordinates.as_text).to include('POINT')
      end
    end

    context 'with invalid json' do
      subject(:address) { Address.from_feature('invalid') }

      it 'returns nil' do
        expect(address).to be_nil
      end
    end

    context 'with missing key' do
      before { feature.except!('geometry') }

      it 'returns address without attribute' do
        expect(address.coordinates).to be_nil
      end
    end
  end

  describe '#graetzls' do
    let(:address) { build(:address, coordinates: 'POINT (1.00 1.00)') }

    context 'with single result' do
      let!(:matching_graetzl) { create(:graetzl) }
      let!(:wrong_graetzl) { create(:graetzl,
        area: 'POLYGON ((0.0 0.0, 0.0 0.9, 0.9 0.9, 0.9 0.0, 0.0 0.0))') }

      it 'returns 1 graetzl' do
        expect(address.graetzls.size).to eq(1)
      end

      it 'includes matching graetzl' do
        expect(address.graetzl).to eq(matching_graetzl)
      end

      it 'excludes matching graetzl' do
        expect(address.graetzl).not_to eq(wrong_graetzl)
      end
    end

    context 'with no result' do
      let!(:wrong_graetzl) { create(:graetzl,
        area: 'POLYGON ((0.0 0.0, 0.0 0.9, 0.9 0.9, 0.9 0.0, 0.0 0.0))') }

      it 'returns empty array graetzl' do
        expect(address.graetzl).to be_nil
      end
    end

    context 'when no coordinates' do
      let!(:matching_graetzl) { create(:graetzl) }
      before do
        address.coordinates = nil
        address.save
      end

      it 'returns empty array graetzl' do
        expect(address.graetzls).to be_empty
      end
    end
  end
end
