require 'rails_helper'

RSpec.describe Districts::LocationsController, type: :routing do

  describe 'routes' do
    it 'routes GET /wien/district-slug/locations to districts/locations#index' do
      expect(get: '/wien/district-slug/locations').to route_to('districts/locations#index', district_id: 'district-slug')
    end
  end
  describe 'named routes' do
    it 'routes GET district_locations_path to districts/locations#index' do
      expect(get: district_locations_path('district-slug')).to route_to('districts/locations#index', district_id: 'district-slug')
    end
  end
end
