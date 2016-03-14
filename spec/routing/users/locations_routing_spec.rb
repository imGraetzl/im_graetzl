require 'rails_helper'

RSpec.describe Users::LocationsController, type: :routing do

  describe 'routes' do
    it 'routes GET /user/locations to users/locations#index' do
      expect(get: '/user/locations').to route_to('users/locations#index')
    end
  end

  describe 'named routes' do
    it 'routes GET user_locations_path to users/locations#index' do
      expect(get: user_locations_path).to route_to('users/locations#index')
    end
  end
end
