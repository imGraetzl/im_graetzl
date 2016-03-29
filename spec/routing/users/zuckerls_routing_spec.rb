require 'rails_helper'

RSpec.describe Users::ZuckerlsController, type: :routing do

  describe 'routes' do
    it 'routes GET /user/zuckerl to #index' do
      expect(get: '/user/zuckerl').to route_to('users/zuckerls#index')
    end
  end

  describe 'named routes' do
    it 'routes GET user_zuckerls_path to #index' do
      expect(get: user_zuckerls_path).to route_to('users/zuckerls#index')
    end
  end
end
