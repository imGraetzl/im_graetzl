require 'rails_helper'
include GeojsonSupport

RSpec.describe Address, type: :model do

  # check factory
  it 'has a valid factory' do
    expect(build_stubbed(:address)).to be_valid
    expect(build_stubbed(:esterhazygasse)).to be_valid
  end

  # validations
  # describe 'validations' do
  #   it 'is invalid without coordinates' do
  #     expect(build(:address, coordinates: nil)).not_to be_valid
  #   end

  #   it 'is invalid without street_name' do
  #     expect(build(:address, street_name: nil)).not_to be_valid
  #   end

  #   it 'is invalid without city and zip' do
  #     expect(build(:address, city: nil, zip: nil)).not_to be_valid
  #   end
  # end

  # class methods
  describe '.new_from_geojson' do
    let(:feature) { feature_hash }

    context 'with valid hash' do

      it 'returns new address object' do
        address = Address.new_from_geojson(feature)
        expect(address.class).to eq(Address)
      end

      it 'builds address with properties' do
        address = Address.new_from_geojson(feature)
        expect(address).to have_attributes(
          street_name: feature['properties']['StreetName'],
          street_number: feature['properties']['StreetNumber'],
          zip: feature['properties']['PostalCode'],
          city: feature['properties']['Municipality'],
          )
      end

      it 'builds point-coordinates' do
        coordinates = Address.new_from_geojson(feature).coordinates
        expect(coordinates).not_to be_nil
        expect(coordinates.as_text).to include('POINT')
      end
    end

    context 'with missing key' do
      before { feature.except!('geometry') }

      it 'returns address object without property' do
        address = Address.new_from_geojson(feature)
        expect(address.coordinates).to be_nil
      end
    end
  end

  describe '.new_from_json_string' do
    let(:feature) { feature_hash }

    context 'with valid json' do
      it 'parses json and calls .new_from_geojson' do
        address = Address.new_from_json_string(feature.to_json)
        expect(address).to have_attributes(
          street_name: feature['properties']['StreetName'],
          street_number: feature['properties']['StreetNumber'],
          zip: feature['properties']['PostalCode'],
          city: feature['properties']['Municipality'],
          )
      end
    end

    context 'with invalid json' do
      it 'returns empty address object' do
        address = Address.new_from_json_string('invalid')
        expect(address.attributes.values).to all(be_nil)
      end
    end
  end


  # instance methods
  describe '#match_graetzls' do

    context 'with single result' do
      let(:esterhazygasse) { build(:esterhazygasse) }

      before { @naschmarkt = create(:naschmarkt) }

      it 'returns 1 graetzl' do
        graetzls = esterhazygasse.match_graetzls
        expect(graetzls.size).to eq(1)
      end

      it 'returns matching graetzl (naschmarkt)' do
        graetzl = esterhazygasse.match_graetzls.first
        expect(graetzl).to eq(@naschmarkt)
      end
    end

    context 'with multiple results' do
      let(:seestadt) { build(:seestadt) }

      before do
        @seestadt_aspern = create(:seestadt_aspern)
        @aspern = create(:aspern)
      end

      it 'returns array of results' do
        graetzls = seestadt.match_graetzls
        expect(graetzls.size).to eq(2)
      end

      it 'returns 2 matching graetzls' do
        graetzls = seestadt.match_graetzls
        expect(graetzls).to include(@seestadt_aspern)
        expect(graetzls).to include(@aspern)
      end
    end

    context 'with no result' do
      let(:non_matching_address) { build(:address, coordinates: nil) }

      before do
        3.times { create(:graetzl) }
      end

      it 'returns all graetzl' do
        graetzls = non_matching_address.match_graetzls
        expect(graetzls.size).to eq(3)
      end
    end
  end

  describe '#merge_feature' do
    let(:old_address) { build(:address, description: 'old description') }
    let(:new_address) { build(:address, description: 'new description') }
    before { old_address.merge_feature(new_address.attributes) }

    it 'updates all geo-specific attributes' do
      expect(old_address).to have_attributes(
        street_name: new_address.street_name,
        street_number: new_address.street_number,
        city: new_address.city,
        zip: new_address.zip,
        coordinates: new_address.coordinates)
    end

    it 'keeps non-geo-specific attributes' do
      expect(old_address.description).to eq('old description')
    end
  end
end
