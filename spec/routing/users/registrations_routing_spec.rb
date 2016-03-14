require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :routing do

  describe 'routes' do
    it 'routes GET /users/registrierung to #new' do
      expect(get: '/users/registrierung').to route_to('users/registrations#new')
    end

    it 'routes POST /users/registrierung to #new' do
      expect(post: '/users/registrierung').to route_to('users/registrations#new')
    end

    it 'routes POST /users to #create' do
      expect(post: '/users').to route_to('users/registrations#create')
    end

    it 'routes GET /users/graetzl to #graetzl' do
      expect(get: '/users/graetzl').to route_to('users/registrations#graetzl')
    end

    it 'routes POST /users/graetzl to #graetzl' do
      expect(post: '/users/graetzl').to route_to('users/registrations#graetzl')
    end

    it 'routes DELETE /users to #destroy' do
      expect(delete: '/users').to route_to('users/registrations#destroy')
    end
  end

  describe 'named routes' do
    it 'routes GET new_registration_path to #new' do
      expect(get: new_registration_path).to route_to('users/registrations#new')
    end

    it 'routes POST address_registration_path to #new' do
      expect(post: address_registration_path).to route_to('users/registrations#new')
    end

    it 'routes POST registration_path to #create' do
      expect(post: registration_path).to route_to('users/registrations#create')
    end

    it 'routes GET graetzls_registration_path to #graetzl' do
      expect(get: graetzls_registration_path).to route_to('users/registrations#graetzl')
    end

    it 'routes POST graetzls_registration_path to #graetzl' do
      expect(post: graetzls_registration_path).to route_to('users/registrations#graetzl')
    end

    it 'routes DELETE registration_path to #destroy' do
      expect(delete: registration_path).to route_to('users/registrations#destroy')
    end
  end
end
