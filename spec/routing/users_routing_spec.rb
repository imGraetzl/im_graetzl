require 'rails_helper'

RSpec.describe UsersController, type: :routing do
  describe 'routes ' do
    it 'routes GET /users/user-slug to #show' do
      expect(get: '/users/user-slug').to route_to('users#show', id: 'user-slug')
    end

    it 'routes GET graetzl-slug/users/user-slug to #show' do
      expect(get: 'graetzl-slug/users/user-slug').to route_to('users#show', graetzl_id: 'graetzl-slug', id: 'user-slug')
    end

    it 'routes GET /user/einstellungen to #edit' do
      expect(get: '/user/einstellungen').to route_to('users#edit')
    end

    it 'routes GET /user/locations to #locations' do
      expect(get: '/user/locations').to route_to('users#locations')
    end

    it 'routes GET /user/zuckerl to #zuckerls' do
      expect(get: '/user/zuckerl').to route_to('users#zuckerls')
    end

    it 'routes PUT /users/user-slug to #update' do
      expect(put: '/users/user-slug').to route_to('users#update', id: 'user-slug')
    end
  end
  describe 'named routes' do
    it 'routes GET user_path to #show' do
      expect(get: user_path('user-slug')).to route_to('users#show', id: 'user-slug')
    end

    it 'routes GET graetzl_user_path to #show' do
      expect(get: graetzl_user_path(graetzl_id: 'graetzl-slug', id: 'user-slug')).to route_to('users#show', graetzl_id: 'graetzl-slug', id: 'user-slug')
    end

    it 'routes GET locations_user_path to #locations' do
      expect(get: locations_user_path).to route_to('users#locations')
    end

    it 'routes GET zuckerls_user_path to #zuckerls' do
      expect(get: zuckerls_user_path).to route_to('users#zuckerls')
    end

    it 'routes GET edit_user_path to #edit' do
      expect(get: edit_user_path).to route_to('users#edit')
    end

    it 'routes PUT user_path to #update' do
      expect(put: user_path('user-slug')).to route_to('users#update', id: 'user-slug')
    end
  end
end
