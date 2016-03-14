require 'rails_helper'

RSpec.describe Districts::ZuckerlsController, type: :routing do

  describe 'routes' do
    it 'routes GET /wien/district-slug/graetzlzuckerl to districts/zuckerls#index' do
      expect(get: '/wien/district-slug/graetzlzuckerl').to route_to('districts/zuckerls#index', district_id: 'district-slug')
    end
  end
  describe 'named routes' do
    it 'routes GET district_zuckerls_path to districts/zuckerls#index' do
      expect(get: district_zuckerls_path('district-slug')).to route_to('districts/zuckerls#index', district_id: 'district-slug')
    end
  end
end
