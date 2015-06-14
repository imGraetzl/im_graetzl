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
    context 'with single result' do
      let(:esterhazygasse) { build(:esterhazygasse) }
      let!(:naschmarkt) { create(:naschmarkt) }

      it 'returns 1 graetzl' do
        graetzls = esterhazygasse.graetzls
        expect(graetzls.size).to eq(1)
      end

      it 'returns matching graetzl (naschmarkt)' do
        graetzl = esterhazygasse.graetzls.first
        expect(graetzl).to eq(naschmarkt)
      end
    end

    context 'with multiple results' do
      let(:seestadt) { build(:seestadt) }
      let!(:seestadt_aspern) { create(:seestadt_aspern) }
      let!(:aspern) { create(:aspern) }

      it 'returns array of results' do
        graetzls = seestadt.graetzls
        expect(graetzls.size).to eq(2)
      end

      it 'returns 2 matching graetzls' do
        graetzls = seestadt.graetzls
        expect(graetzls).to include(seestadt_aspern)
        expect(graetzls).to include(aspern)
      end
    end

    context 'with no result' do
      let(:non_matching_address) { build(:address, coordinates: nil) }

      before do
        3.times { create(:graetzl) }
      end

      it 'returns empty array graetzl' do
        expect(non_matching_address.graetzls).to be_empty
      end
    end
  end
end
