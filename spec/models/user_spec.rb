require 'rails_helper'

RSpec.describe User, type: :model do
  
  ## CHECK FACTORY
  it 'has a valid factory' do
    expect(create(:user)).to be_valid
  end

  ## VALIDATIONS
  describe 'validations' do
    it 'is invalid without username' do
      expect(build(:user, username: nil)).not_to be_valid
    end

    it 'is invalid with dublicate username' do
      first_user = create(:user)
      expect(build(:user, username: first_user.username)).not_to be_valid
    end

    it 'is invalid without first_name' do
      expect(build(:user, first_name: nil)).not_to be_valid
    end

    it 'is invalid without last_name' do
      expect(build(:user, last_name: nil)).not_to be_valid
    end
  end

  ## INSTANCE METHODS
  describe 'autosave graetzl association' do
    context 'when graetzl exists:' do
      it 'associates with existing record in db' do
        existing_graetzl = create(:graetzl)
        other_graetzl = create(:graetzl, name: existing_graetzl.name)
        user = create(:user, graetzl: build(:graetzl, name: existing_graetzl.name))
        expect(user.graetzl).to eq(existing_graetzl)
        expect(user.graetzl).not_to eq(other_graetzl)
      end
    end
    context 'when no graetzl:' do
      it 'associates with default graetzl record in db (first graetzl for now)' do
        default_graetzl = Graetzl.first
        user_graetzl = create(:user, graetzl: build(:graetzl)).graetzl
        expect(user_graetzl).to eq(default_graetzl)
      end

      it 'should not create new record' do
        expect { create(:user, graetzl: build(:graetzl)) }.not_to change { Graetzl.count }
      end
    end
  end


  # #it 'is invalid without a user'

  # ## CLASS METHODS
  # it 'builds a new address from a geojson object' do
  #   geojson_hash = {"type"=>"Feature",
  #     "geometry"=>{
  #       "type"=>"Point",
  #       "coordinates"=>[16.35955137895887, 48.20137456512505]},
  #       "bbox"=>[48.20137456512505, 16.35955137895887, 16.35955137895887, 48.20137456512505],
  #       "properties"=>{
  #         "Bezirk"=>"7",
  #         "Adresse"=>"Mariahilfer Straße 10",
  #         "CountryCode"=>"AT",
  #         "StreetName"=>"Mariahilfer Straße",
  #         "StreetNumber"=>"10",
  #         "CountrySubdivision"=>"Wien",
  #         "Municipality"=>"Wien",
  #         "MunicipalitySubdivision"=>"Neubau",
  #         "Kategorie"=>"Adresse",
  #         "Zaehlbezirk"=>"0702",
  #         "Zaehlgebiet"=>"07023",
  #         "Ranking"=>0.0,
  #         "PostalCode"=>"1070"}}
  #   address = Address.new_from_geojson(geojson_hash)
  #   expect(address).to be_valid
  # end


  # ## INSTANCE METHODS
  # describe 'match respective graetzls' do

  #   context 'single result' do
  #     it 'returns 1 matching graetzl' do
  #       esterhazygasse = build(:esterhazygasse)
  #       graetzls = esterhazygasse.match_graetzls
  #       expect(graetzls.size).to eq(1)
  #       expect(graetzls.first.name).to eq('Naschmarkt, Wien')
  #     end
  #   end

  #   context 'multiple results' do
  #     it 'returns 2 matching graetzls' do
  #       seestadt = build(:seestadt)
  #       graetzls = seestadt.match_graetzls
  #       expect(graetzls.size).to eq(2)
  #     end
  #   end    

  #   context 'no results' do
  #     it 'returns all graetzls' do
  #       address = build(:address, coordinates: nil)
  #       graetzls = address.match_graetzls
  #       expect(graetzls.size).to eq(Graetzl.all.size)
  #     end
  #   end
  # end
end
