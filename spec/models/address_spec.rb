require 'rails_helper'

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

    #it 'is invalid without a user'
  end

  # class methods
  it 'builds a new address from a geojson object' do
    geojson_hash = {"type"=>"Feature",
      "geometry"=>{
        "type"=>"Point",
        "coordinates"=>[16.35955137895887, 48.20137456512505]},
        "bbox"=>[48.20137456512505, 16.35955137895887, 16.35955137895887, 48.20137456512505],
        "properties"=>{
          "Bezirk"=>"7",
          "Adresse"=>"Mariahilfer Straße 10",
          "CountryCode"=>"AT",
          "StreetName"=>"Mariahilfer Straße",
          "StreetNumber"=>"10",
          "CountrySubdivision"=>"Wien",
          "Municipality"=>"Wien",
          "MunicipalitySubdivision"=>"Neubau",
          "Kategorie"=>"Adresse",
          "Zaehlbezirk"=>"0702",
          "Zaehlgebiet"=>"07023",
          "Ranking"=>0.0,
          "PostalCode"=>"1070"}}
    address = Address.new_from_geojson(geojson_hash)
    expect(address).to be_valid
  end


  # instance methods
  describe 'match respective graetzls' do

    context 'single result' do
      it 'returns 1 matching graetzl' do
        esterhazygasse = build(:esterhazygasse)
        graetzls = esterhazygasse.match_graetzls
        expect(graetzls.size).to eq(1)
        expect(graetzls.first.name).to eq('Naschmarkt, Wien')
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
