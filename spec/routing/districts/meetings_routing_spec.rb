require 'rails_helper'

RSpec.describe Districts::MeetingsController, type: :routing do

  describe 'routes' do
    it 'routes GET /wien/district-slug/treffen to districts/meetings#index' do
      expect(get: '/wien/district-slug/treffen').to route_to('districts/meetings#index', district_id: 'district-slug')
    end
  end
  describe 'named routes' do
    it 'routes GET district_meetings_path to districts/meetings#index' do
      expect(get: district_meetings_path('district-slug')).to route_to('districts/meetings#index', district_id: 'district-slug')
    end
  end
end
