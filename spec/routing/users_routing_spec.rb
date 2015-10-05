require 'rails_helper'

RSpec.describe UsersController, type: :routing do
  
  describe 'routes ' do

    it 'routes GET /users/user-slug to users#show' do
      expect(get: '/users/user-slug').to route_to(
        controller: 'users',
        action: 'show',
        id: 'user-slug')
    end

    it 'routes GET graetzl-slug/users/user-slug to users#show' do
      expect(get: 'graetzl-slug/users/user-slug').to route_to(
        controller: 'users',
        action: 'show',
        graetzl_id: 'graetzl-slug',
        id: 'user-slug')
    end

    # it 'routes GET /users/user-slug/einstellungen to users#edit' do
    #   expect(get: '/users/user-slug/einstellungen').to route_to(
    #     controller: 'users',
    #     action: 'edit',
    #     id: 'user-slug')
    # end
    
    it 'routes GET /user/einstellungen to users#edit' do
      expect(get: '/user/einstellungen').to route_to(
        controller: 'users',
        action: 'edit')
    end
    
    it 'routes GET /user/locations to users#locations' do
      expect(get: '/user/locations').to route_to(
        controller: 'users',
        action: 'locations')
    end

    it 'routes PUT /users/user-slug to users#update' do
      expect(put: '/users/user-slug').to route_to(
        controller: 'users',
        action: 'update',
        id: 'user-slug')
    end
  end

  describe 'named routes' do

    it 'routes GET user_path(user-slug) to users#show' do
      expect(get: user_path('user-slug')).to route_to(
        controller: 'users',
        action: 'show',
        id: 'user-slug')
    end

    it 'routes GET graetzl_user_path(graetzl-slug, user-slug) to users#show' do
      expect(get: graetzl_user_path('graetzl-slug', 'user-slug')).to route_to(
        controller: 'users',
        action: 'show',
        graetzl_id: 'graetzl-slug',
        id: 'user-slug')
    end

    it 'routes GET edit_user_path to users#edit' do
      expect(get: edit_user_path).to route_to(
        controller: 'users',
        action: 'edit')
    end

    it 'routes GET locations_user_path to users#locations' do
      expect(get: locations_user_path).to route_to(
        controller: 'users',
        action: 'locations')
    end
  end
end