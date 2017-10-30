require 'rails_helper'

RSpec.describe ZuckerlsController, type: :routing do
  describe 'routes' do
    it 'does not route /graetzl-slug/zuckerl-slug to #show' do
      expect(get: '/graetzl-slug/zuckerl-slug').not_to be_routable
    end

    it 'routes GET /locations/location-slug/zuckerl/new to #new' do
      expect(get: '/locations/location-slug/zuckerl/new').to route_to('zuckerls#new', location_id: 'location-slug')
    end

    it 'routes GET /zuckerls/new to #new' do
      expect(get: '/zuckerl/new').to route_to('zuckerls#new')
    end

    it 'routes POST /locations/location-slug/zuckerl to #create' do
      expect(post: '/locations/location-slug/zuckerl').to route_to('zuckerls#create', location_id: 'location-slug')
    end

    it 'routes GET /locations/location-slug/zuckerl/zuckerl-slug/edit to #edit' do
      expect(get: '/locations/location-slug/zuckerl/zuckerl-slug/edit').to route_to('zuckerls#edit', location_id: 'location-slug', id: 'zuckerl-slug')
    end

    it 'routes PUT /locations/location-slug/zuckerl/zuckerl-slug to #update' do
      expect(put: '/locations/location-slug/zuckerl/zuckerl-slug').to route_to('zuckerls#update', location_id: 'location-slug', id: 'zuckerl-slug')
    end

    it 'routes DELETE /locations/location-slug/zuckerl/zuckerl-slug to #destroy' do
      expect(delete: '/locations/location-slug/zuckerl/zuckerl-slug').to route_to('zuckerls#destroy', location_id: 'location-slug', id: 'zuckerl-slug')
    end
  end
  describe 'named routes' do
    it 'routes GET new_location_zuckerl_path to #new' do
      expect(get: new_location_zuckerl_path('location-slug')).to route_to('zuckerls#new', location_id: 'location-slug')
    end

    it 'routes GET new_zuckerl_path to #new' do
      expect(get: new_zuckerl_path).to route_to('zuckerls#new')
    end

    it 'routes POST location_zuckerls_path to #create' do
      expect(post: location_zuckerls_path('location-slug')).to route_to('zuckerls#create', location_id: 'location-slug')
    end

    it 'routes GET edit_location_zuckerl_path to #edit' do
      expect(get: edit_location_zuckerl_path('location-slug', 'zuckerl-slug')).to route_to('zuckerls#edit', location_id: 'location-slug', id: 'zuckerl-slug')
    end

    it 'routes PUT location_zuckerl_path to #update' do
      expect(put: location_zuckerl_path('location-slug', 'zuckerl-slug')).to route_to('zuckerls#update', location_id: 'location-slug', id: 'zuckerl-slug')
    end

    it 'routes DELETE location_zuckerl_path to #destroy' do
      expect(delete: location_zuckerl_path('location-slug', 'zuckerl-slug')).to route_to('zuckerls#destroy', location_id: 'location-slug', id: 'zuckerl-slug')
    end
  end
end
