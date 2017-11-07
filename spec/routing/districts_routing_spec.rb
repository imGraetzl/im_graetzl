require 'rails_helper'

RSpec.describe DistrictsController, type: :routing do

  describe 'routes' do
    it 'routes GET /wien/district-slug to #show' do
      expect(get: '/wien/district-slug').to route_to('districts#show', id: 'district-slug')
    end

    it 'routes GET /wien/district-slug/graetzls to #graetzls' do
      expect(get: '/wien/district-slug/graetzls').to route_to('districts#graetzls', id: 'district-slug')
    end

    it 'routes GET /wien/district-slug/locations to #index' do
      expect(get: '/wien/district-slug/locations').to route_to('districts#locations', id: 'district-slug')
    end

    it 'routes GET /wien/district-slug/treffen to #index' do
      expect(get: '/wien/district-slug/treffen').to route_to('districts#meetings', id: 'district-slug')
    end

    it 'routes GET /wien/district-slug/zuckerl to #index' do
      expect(get: '/wien/district-slug/zuckerl').to route_to('districts#zuckerls', id: 'district-slug')
    end

  end
  describe 'named routes' do
    it 'routes GET district_path to #show' do
      expect(get: district_path('district-slug')).to route_to('districts#show', id: 'district-slug')
    end

    it 'routes GET locations_district_path to #index' do
      expect(get: locations_district_path('district-slug')).to route_to('districts#locations', id: 'district-slug')
    end

    it 'routes GET meetings_district_path to #index' do
      expect(get: meetings_district_path('district-slug')).to route_to('districts#meetings', id: 'district-slug')
    end

    it 'routes GET zuckerls_district_path to #index' do
      expect(get: zuckerls_district_path('district-slug')).to route_to('districts#zuckerls', id: 'district-slug')
    end
  end
end
