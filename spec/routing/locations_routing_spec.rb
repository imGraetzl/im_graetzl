require 'rails_helper'
require 'routing/shared/address_before_new'

RSpec.describe LocationsController, type: :routing do

  include_examples :address_before_new, 'location'
  
  describe 'routing' do

    it 'routes GET /graetzl-slug/locations/location-slug to #show' do
      expect(get: '/graetzl-slug/locations/location-slug').to route_to(
        controller: 'locations',
        action: 'show',
        graetzl_id: 'graetzl-slug',
        id: 'location-slug')
    end

    it 'routes GET /graetzl-slug/locations to #index' do
      expect(get: '/graetzl-slug/locations').to route_to(
        controller: 'locations',
        action: 'index',
        graetzl_id: 'graetzl-slug')
    end

    it 'routes GET /locations/new to #new' do
      expect(get: '/locations/new').to route_to(
        controller: 'locations',
        action: 'new')
    end

    it 'routes POST /locations to #create' do
      expect(post: '/locations').to route_to(
        controller: 'locations',
        action: 'create')
    end

    it 'routes GET /locations/location-slug/edit to #edit' do
      expect(get: '/locations/location-slug/edit').to route_to(
        controller: 'locations',
        action: 'edit',
        id: 'location-slug')
    end

    it 'routes PUT /locations/location-slug to #update' do
      expect(put: '/locations/location-slug').to route_to(
        controller: 'locations',
        action: 'update',
        id: 'location-slug')
    end
  end

  describe 'named routing' do

    it 'routes GET graetzl_location to #show' do
      expect(get: graetzl_location_path(graetzl_id: 'graetzl-slug', id: 'location-slug')).to route_to(
        controller: 'locations',
        action: 'show',
        graetzl_id: 'graetzl-slug',
        id: 'location-slug')
    end

    it 'routes GET graetzl_locations to #index' do
      expect(get: graetzl_locations_path(graetzl_id: 'graetzl-slug')).to route_to(
        controller: 'locations',
        action: 'index',
        graetzl_id: 'graetzl-slug')
    end

    it 'routes GET new_location to #new' do
      expect(get: new_location_path).to route_to(
        controller: 'locations',
        action: 'new')
    end

    it 'routes POST locations to #create' do
      expect(post: locations_path).to route_to(
        controller: 'locations',
        action: 'create')
    end

    it 'routes GET edit_location to #edit' do
      expect(get: edit_location_path(id: 'location-slug')).to route_to(
        controller: 'locations',
        action: 'edit',
        id: 'location-slug')
    end

    it 'routes PUT location to #update' do
      expect(put: location_path(id: 'location-slug')).to route_to(
        controller: 'locations',
        action: 'update',
        id: 'location-slug')
    end
  end
end