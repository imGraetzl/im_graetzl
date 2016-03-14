require 'rails_helper'
require 'routing/shared/address_before_new'

RSpec.describe LocationsController, type: :routing do
  describe 'routes' do
    it 'routes GET /graetzl-slug/locations to #index' do
      expect(get: '/graetzl-slug/locations').to route_to('locations#index', graetzl_id: 'graetzl-slug')
    end

    it 'routes GET /graetzl-slug/locations/location-slug to #show' do
      expect(get: '/graetzl-slug/locations/location-slug').to route_to('locations#show', graetzl_id: 'graetzl-slug', id: 'location-slug')
    end

    it 'routes GET /locations/new to #new' do
      expect(get: '/locations/new').to route_to('locations#new')
    end

    it 'routes POST /locations/new to #new' do
      expect(post: '/locations/new').to route_to('locations#new')
    end

    it 'routes POST /locations to #create' do
      expect(post: '/locations').to route_to('locations#create')
    end

    it 'routes GET /locations/location-slug/edit to #edit' do
      expect(get: '/locations/location-slug/edit').to route_to('locations#edit', id: 'location-slug')
    end

    it 'routes PUT /locations/location-slug to #update' do
      expect(put: '/locations/location-slug').to route_to('locations#update', id: 'location-slug')
    end

    it 'routes DELETE /locations/location-slug to #destroy' do
      expect(delete: '/locations/location-slug').to route_to('locations#destroy', id: 'location-slug')
    end
  end

  describe 'named routing' do
    it 'routes GET graetzl_locations_path to #index' do
      expect(get: graetzl_locations_path('graetzl-slug')).to route_to('locations#index', graetzl_id: 'graetzl-slug')
    end

    it 'routes GET graetzl_location_path to #show' do
      expect(get: graetzl_location_path('graetzl-slug', 'location-slug')).to route_to('locations#show', graetzl_id: 'graetzl-slug', id: 'location-slug')
    end

    it 'routes GET new_location_path to #new' do
      expect(get: new_location_path).to route_to('locations#new')
    end

    it 'routes POST before_new_locations_path to #new' do
      expect(post: before_new_locations_path).to route_to('locations#new')
    end

    it 'routes POST locations_path to #create' do
      expect(post: locations_path).to route_to('locations#create')
    end

    it 'routes GET edit_location_path to #edit' do
      expect(get: edit_location_path('location-slug')).to route_to('locations#edit', id: 'location-slug')
    end

    it 'routes PUT location_path to #update' do
      expect(put: location_path('location-slug')).to route_to('locations#update', id: 'location-slug')
    end

    it 'routes DELETE location_path to #destroy' do
      expect(delete: location_path('location-slug')).to route_to('locations#destroy', id: 'location-slug')
    end
  end
end
