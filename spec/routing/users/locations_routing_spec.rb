require 'rails_helper'

RSpec.describe Users::LocationsController, type: :routing do

  describe 'routes' do
    it 'routes GET /user/locations to #index' do
      expect(get: '/user/locations').to route_to('users/locations#index')
    end
  end

  describe 'named routes' do
    it 'routes GET user_locations_path to #index' do
      expect(get: user_locations_path).to route_to('users/locations#index')
    end
  end
end
