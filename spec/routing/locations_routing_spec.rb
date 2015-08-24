require 'rails_helper'

RSpec.describe LocationsController, type: :routing do

  include_examples :address_before_new_routing, 'location'
  
  describe 'routing ' do

    it 'routes GET /locations/new to #new' do
      expect(get: '/locations/new').to route_to(
        controller: 'locations',
        action: 'new')
    end

    it 'routes POST /locations/new to #new' do
      expect(post: '/locations/new').to route_to(
        controller: 'locations',
        action: 'new')
    end

    # it 'routes POST /locations to #create' do
    #   expect(post: '/graetzl_slug/locations').to route_to(
    #     controller: 'locations',
    #     action: 'create',
    #     graetzl_id: 'graetzl_slug')
    # end

    # it 'routes GET /locations/location_slug to #show' do
    #   expect(get: '/graetzl_slug/locations/location_slug').to route_to(
    #     controller: 'locations',
    #     action: 'show',
    #     graetzl_id: 'graetzl_slug',
    #     id: 'location_slug')
    # end
  end

  describe 'named routing' do

    it 'routes GET new_location to #new' do
      expect(get: new_location_path).to route_to(
        controller: 'locations',
        action: 'new')
    end

    # it 'routes POST graetzl_locations to #create' do
    #   expect(post: graetzl_locations_path(graetzl_id: 'graetzl_slug')).to route_to(
    #     controller: 'locations',
    #     action: 'create',
    #     graetzl_id: 'graetzl_slug')
    # end

    # it 'routes GET graetzl_location to #show' do
    #   expect(get: graetzl_location_path(graetzl_id: 'graetzl_slug', id: 'location_slug')).to route_to(
    #     controller: 'locations',
    #     action: 'show',
    #     graetzl_id: 'graetzl_slug',
    #     id: 'location_slug')
    # end
  end
end