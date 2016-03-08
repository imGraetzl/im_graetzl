require 'rails_helper'
require 'routing/shared/address_before_new'

RSpec.describe ZuckerlsController, type: :routing do

  describe 'routing' do

    it 'routes GET /graetzl-slug/zuckerls to #index' do
      expect(get: '/graetzl-slug/zuckerls').to route_to(
        controller: 'zuckerls',
        action: 'index',
        graetzl_id: 'graetzl-slug')
    end

    it 'routes GET /locations/location-slug/zuckerls/new to #new' do
      expect(get: '/locations/location-slug/zuckerls/new').to route_to(
        controller: 'zuckerls',
        action: 'new',
        location_id: 'location-slug')
    end

    it 'routes GET /zuckerls/new to #new' do
      expect(get: '/zuckerls/new').to route_to(
        controller: 'zuckerls',
        action: 'new')
    end

    it 'routes GET new_location_zuckerl to #new' do
      expect(get: new_location_zuckerl_path(location_id: 'location-slug')).to route_to(
        controller: 'zuckerls',
        action: 'new',
        location_id: 'location-slug')
    end

    it 'routes GET new_zuckerl to #new' do
      expect(get: new_zuckerl_path).to route_to(
        controller: 'zuckerls',
        action: 'new')
    end
  end
end
