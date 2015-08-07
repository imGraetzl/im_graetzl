require 'rails_helper'

RSpec.describe LocationsController, type: :routing do
  
  describe 'routing ' do

    it 'routes GET /locations/new/address to #new_address' do
      expect(get: '/graetzl_slug/locations/new/address').to route_to(
        controller: 'locations',
        action: 'new_address',
        graetzl_id: 'graetzl_slug')
    end

    it 'routes POST /locations/new/address to #set_address' do
      expect(post: '/graetzl_slug/locations/new/address').to route_to(
        controller: 'locations',
        action: 'set_new_address',
        graetzl_id: 'graetzl_slug')
    end

    it 'routes GET /locations/new to #new' do
      expect(get: '/graetzl_slug/locations/new').to route_to(
        controller: 'locations',
        action: 'new',
        graetzl_id: 'graetzl_slug')
    end

    it 'routes POST /locations to #create' do
      expect(post: '/graetzl_slug/locations').to route_to(
        controller: 'locations',
        action: 'create',
        graetzl_id: 'graetzl_slug')
    end

    it 'routes GET /locations/location_slug to #show' do
      expect(get: '/graetzl_slug/locations/location_slug').to route_to(
        controller: 'locations',
        action: 'show',
        graetzl_id: 'graetzl_slug',
        id: 'location_slug')
    end
  end

  describe 'named routing' do

    it 'routes GET address_new_graetzl_location to #new_address' do
      expect(get: address_new_graetzl_location_path(graetzl_id: 'graetzl_slug')).to route_to(
        controller: 'locations',
        action: 'new_address',
        graetzl_id: 'graetzl_slug')
    end

    it 'routes POST address_new_graetzl_location to #set_address' do
      expect(post: address_new_graetzl_location_path(graetzl_id: 'graetzl_slug')).to route_to(
        controller: 'locations',
        action: 'set_new_address',
        graetzl_id: 'graetzl_slug')
    end

    it 'routes GET new_graetzl_location to #new' do
      expect(get: new_graetzl_location_path(graetzl_id: 'graetzl_slug')).to route_to(
        controller: 'locations',
        action: 'new',
        graetzl_id: 'graetzl_slug')
    end

    it 'routes POST graetzl_locations to #create' do
      expect(post: graetzl_locations_path(graetzl_id: 'graetzl_slug')).to route_to(
        controller: 'locations',
        action: 'create',
        graetzl_id: 'graetzl_slug')
    end

    it 'routes GET graetzl_location to #show' do
      expect(get: graetzl_location_path(graetzl_id: 'graetzl_slug', id: 'location_slug')).to route_to(
        controller: 'locations',
        action: 'show',
        graetzl_id: 'graetzl_slug',
        id: 'location_slug')
    end
  end
end