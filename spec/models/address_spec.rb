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
      subject(:address) { Address.new(Address.attributes_from_feature('invalid')) }

      it 'has no attributes' do
        expect(address.attributes.values).to all(be_nil)
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
