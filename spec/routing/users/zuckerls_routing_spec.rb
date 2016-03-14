require 'rails_helper'

RSpec.describe Users::ZuckerlsController, type: :routing do

  describe 'routes' do
    it 'routes GET /user/zuckerls to users/zuckerls#index' do
      expect(get: '/user/zuckerls').to route_to('users/zuckerls#index')
    end
  end

  describe 'named routes' do
    it 'routes GET user_zuckerls_path to users/zuckerls#index' do
      expect(get: user_zuckerls_path).to route_to('users/zuckerls#index')
    end
  end
end
