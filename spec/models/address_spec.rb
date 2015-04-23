require 'rails_helper'
include GeojsonSupport

RSpec.describe Address, type: :model do

  # check factory
  it 'has a valid factory' do
    expect(build_stubbed(:address)).to be_valid
    expect(build_stubbed(:esterhazygasse)).to be_valid
  end

  # validations
  describe 'validations' do
    it 'is invalid without coordinates' do
      expect(build(:address, coordinates: nil)).not_to be_valid
    end

    it 'is invalid without street_name' do
      expect(build(:address, street_name: nil)).not_to be_valid
    end

    it 'is invalid without city and zip' do
      expect(build(:address, city: nil, zip: nil)).not_to be_valid
    end
  end

  # class methods
  let(:feature) { feature_hash }

  describe 'build new address form geojson object' do
    context 'when valid hash param' do
      it 'returns valid address object' do        
        address = Address.new_from_geojson(feature)
        expect(address).to be_valid
      end
    end

    context 'when missing keys' do
      before { feature.except!('geometry') }
      it 'returns invalid address object' do
        address = Address.new_from_geojson(feature)
        expect(address).not_to be_valid
      end
    end
  end

  describe 'build new address from json string' do
    context 'for valid json' do
      it 'returns new address' do        
        address = Address.new_from_json_string(feature.to_json)
        expect(address).to be_valid
      end
    end

    context 'for invalid json' do
      it 'returns empty address' do
        address = Address.new_from_json_string('invalid')
        expect(address).not_to be_valid
        expect(address.coordinates).to be_nil
      end
    end
  end


  # instance methods
  describe 'matches respective graetzls' do
    before do
      @naschmarkt = create(:naschmarkt)
      seestadt_aspern = create(:seestadt_aspern)
      aspern = create(:aspern)
      matching_graetzls = []
    end

    it 'with 3 graetzls in db' do
      expect(Graetzl.all.size).to eq(3)
    end
    
    context 'single result' do      
      it 'returns 1 matching graetzl' do
        esterhazygasse = build(:esterhazygasse)
        graetzls = esterhazygasse.match_graetzls
        expect(graetzls.size).to eq(1)
        expect(graetzls.first.name).to eq(@naschmarkt.name)
      end
    end

    context 'multiple results' do
      it 'returns 2 matching graetzls' do
        seestadt = build(:seestadt)
        graetzls = seestadt.match_graetzls
        expect(graetzls.size).to eq(2)
      end
    end    

    context 'no results' do
      it 'returns all graetzls' do
        address = build(:address, coordinates: nil)
        graetzls = address.match_graetzls
        expect(graetzls.size).to eq(Graetzl.all.size)
      end
    end
  end
end
