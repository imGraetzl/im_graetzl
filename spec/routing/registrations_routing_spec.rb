require 'rails_helper'

RSpec.describe RegistrationsController, type: :routing do

  describe 'routes' do

    it 'routes GET /users/registrierung to users/registrations#new' do
      expect(get: '/users/registrierung').to route_to(
        controller: 'users/registrations',
        action: 'new')
    end

    it 'routes POST /users/registrierung to users/registrations#new' do
      expect(post: '/users/registrierung').to route_to(
        controller: 'users/registrations',
        action: 'new')
    end

    it 'routes POST /users to users/registrations#create' do
      expect(post: '/users').to route_to(
        controller: 'users/registrations',
        action: 'create')
    end

    it 'routes GET /users/graetzl to users/registrations#graetzl' do
      expect(get: '/users/graetzl').to route_to(
        controller: 'users/registrations',
        action: 'graetzl')
    end

    it 'routes POST /users/graetzl to users/registrations#graetzl' do
      expect(post: '/users/graetzl').to route_to(
        controller: 'users/registrations',
        action: 'graetzl')
    end
  end

  describe 'named routes' do
    
    it 'routes GET new_user_registration_path to users/registrations#new' do
      expect(get: new_user_registration_path).to route_to(
        controller: 'users/registrations',
        action: 'new')
    end

    it 'routes POST address_users_path to users/registrations#new' do
      expect(post: address_users_path).to route_to(
        controller: 'users/registrations',
        action: 'new')
    end

    it 'routes GET registration_graetzls_path to users/registrations#graetzl' do
      expect(get: registration_graetzls_path).to route_to(
        controller: 'users/registrations',
        action: 'graetzl')
    end

    it 'routes POST registration_graetzl_path to users/registrations#graetzl' do
      expect(post: registration_graetzl_path).to route_to(
        controller: 'users/registrations',
        action: 'graetzl')
    end

    it 'routes POST user_registration_path to users/registrations#create' do
      expect(post: user_registration_path).to route_to(
        controller: 'users/registrations',
        action: 'create')
    end
  end
end