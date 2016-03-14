require 'rails_helper'

RSpec.describe ZuckerlsController, type: :routing do
  describe 'routes' do
    it 'routes GET /graetzl-slug/zuckerls to #index' do
      expect(get: '/graetzl-slug/zuckerls').to route_to('zuckerls#index', graetzl_id: 'graetzl-slug')
    end

    it 'does not route /graetzl-slug/zuckerl-slug to #show' do
      expect(get: '/graetzl-slug/zuckerl-slug').not_to be_routable
    end

    it 'routes GET /locations/location-slug/zuckerls/new to #new' do
      expect(get: '/locations/location-slug/zuckerls/new').to route_to('zuckerls#new', location_id: 'location-slug')
    end

    it 'routes GET /zuckerls/new to #new' do
      expect(get: '/zuckerls/new').to route_to('zuckerls#new')
    end

    it 'routes POST /locations/location-slug/zuckerls to #create' do
      expect(post: '/locations/location-slug/zuckerls').to route_to('zuckerls#create', location_id: 'location-slug')
    end
  end
  describe 'named routes' do
    it 'routes GET graetzl_zuckerls_path to #index' do
      expect(get: graetzl_zuckerls_path('graetzl-slug')).to route_to('zuckerls#index', graetzl_id: 'graetzl-slug')
    end

    it 'routes GET new_location_zuckerl_path to #new' do
      expect(get: new_location_zuckerl_path('location-slug')).to route_to('zuckerls#new', location_id: 'location-slug')
    end

    it 'routes GET new_zuckerl_path to #new' do
      expect(get: new_zuckerl_path).to route_to('zuckerls#new')
    end

    it 'routes POST location_zuckerls_path to #create' do
      expect(post: location_zuckerls_path('location-slug')).to route_to('zuckerls#create', location_id: 'location-slug')
    end
  end
end
