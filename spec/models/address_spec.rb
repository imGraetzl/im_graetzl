require 'rails_helper'
include GeojsonSupport

RSpec.describe Address, type: :model do

  it 'has a valid factory' do
    expect(build_stubbed(:address)).to be_valid
    expect(build_stubbed(:esterhazygasse)).to be_valid
  end

  describe 'associations' do
    let(:address) { create(:address) }

    it 'has addressable' do
      expect(address).to respond_to(:addressable)
    end
  end

  describe '.attributes_from_feature' do
    let(:feature) { feature_hash }

    subject(:address) { Address.new(Address.attributes_from_feature(feature.to_json)) }

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
      subject(:address) { Address.attributes_from_feature('invalid') }

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

  describe '.attributes_to_reset_location' do
    let(:geo_attributes) { [:coordinates, :street_name, :street_number, :city, :zip] }
    subject { Address.attributes_to_reset_location }

    it 'returns nil for geo attributes' do
      expect(subject.values).to all(be_nil)
    end

    it 'includes geo attributes' do
      expect(subject.keys).to match_array(geo_attributes)
    end

    it 'does not include :id' do
      expect(subject.has_key?(:id)).to eq(false)
    end

    it 'does not include :description' do
      expect(subject.has_key?(:description)).to eq(false)
    end

    it 'does not include :addressable' do
      expect(subject.keys).not_to include(:addressable_id, :addressable_type)
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
        expect(address.graetzls).to include matching_graetzl
      end

      it 'excludes matching graetzl' do
        expect(address.graetzls).not_to include wrong_graetzl
      end
    end

    context 'with multiple results' do
      let!(:matching_graetzl) { create(:graetzl) }
      let!(:other_graetzl) { create(:graetzl,
        area: 'POLYGON ((0.0 0.0, 0.0 5.0, 5.0 5.0, 5.0 0.0, 0.0 0.0))') }

      it 'returns array of results' do
        expect(address.graetzls.size).to eq(2)
      end

      it 'includes 2 matching graetzls' do
        expect(address.graetzls).to include(matching_graetzl, other_graetzl)
      end
    end

    context 'with no result' do
      let!(:wrong_graetzl) { create(:graetzl,
        area: 'POLYGON ((0.0 0.0, 0.0 0.9, 0.9 0.9, 0.9 0.0, 0.0 0.0))') }

      it 'returns empty array graetzl' do
        expect(address.graetzls).to be_empty
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

  describe '#locations' do
    let(:address) { build(:address, coordinates: 'POINT (0.0 0.0)') }

    context 'when location within 200 units' do
      let!(:location_within_range) { create(:location,
        address: build(:address, coordinates: 'POINT (42.0 42.0)')) }
      let!(:location_outside_range) { create(:location,
        address: build(:address, coordinates: 'POINT (200.0 200.0)')) }

      it 'contains location_within_range' do
        expect(address.locations).to include(location_within_range)
      end

      it 'does not contain location_outside_range' do
        expect(address.locations).not_to include(location_outside_range)
      end
    end

    context 'when no locations yet' do
      it 'returns empty' do
        expect(address.locations).to be_empty
      end
    end

    context 'when nil coordinates' do
      let!(:location_within_range) { create(:location,
        address: build(:address, coordinates: 'POINT (42.0 42.0)')) }

      before { address.coordinates = nil }

      it 'has empty coordintes' do
        expect(address.coordinates).to eq nil
      end

      it 'returns empty' do
        expect(address.locations).to be_empty
      end
    end
  end
end
