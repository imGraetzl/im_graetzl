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

    it 'routes GET /users/user-slug/edit to users#edit' do
      expect(get: '/users/user-slug/edit').to route_to(
        controller: 'users',
        action: 'edit',
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

    it 'routes GET edit_user_path(user-slug) to users#edit' do
      expect(get: edit_user_path('user-slug')).to route_to(
        controller: 'users',
        action: 'edit',
        id: 'user-slug')
    end
  end
end