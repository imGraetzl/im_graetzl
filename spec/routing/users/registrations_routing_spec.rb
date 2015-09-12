require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :routing do

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

    # it 'routes GET /users/einstellungen to users/registrations#edit' do
    #   expect(get: '/users/einstellungen').to route_to(
    #     controller: 'users/registrations',
    #     action: 'edit')
    # end
  end

  describe 'named routes' do
    
    it 'routes GET new_registration_path to users/registrations#new' do
      expect(get: new_registration_path).to route_to(
        controller: 'users/registrations',
        action: 'new')
    end

    it 'routes POST address_registration_path to users/registrations#new' do
      expect(post: address_registration_path).to route_to(
        controller: 'users/registrations',
        action: 'new')
    end

    it 'routes GET graetzls_registration_path to users/registrations#graetzl' do
      expect(get: graetzls_registration_path).to route_to(
        controller: 'users/registrations',
        action: 'graetzl')
    end

    it 'routes POST graetzl_registration_path to users/registrations#graetzl' do
      expect(post: graetzl_registration_path).to route_to(
        controller: 'users/registrations',
        action: 'graetzl')
    end

    it 'routes POST registration_path to users/registrations#create' do
      expect(post: registration_path).to route_to(
        controller: 'users/registrations',
        action: 'create')
    end

    # it 'routes GET edit_registration_path to users/registrations#edit' do
    #   expect(get: edit_registration_path).to route_to(
    #     controller: 'users/registrations',
    #     action: 'edit')
    # end
  end
end