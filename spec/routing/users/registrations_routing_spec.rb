require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :routing do

  describe 'routes' do
    it 'routes GET /users/registrierung to #new' do
      expect(get: '/users/registrierung').to route_to('users/registrations#new')
    end

    it 'routes POST /users/set_address to #set_address' do
      expect(post: '/users/set_address').to route_to('users/registrations#set_address')
    end

    it 'routes POST /users to #create' do
      expect(post: '/users').to route_to('users/registrations#create')
    end

    it 'routes GET /users/graetzls to #graetzls' do
      expect(get: '/users/graetzls').to route_to('users/registrations#graetzls')
    end

    it 'routes DELETE /users to #destroy' do
      expect(delete: '/users').to route_to('users/registrations#destroy')
    end
  end

  describe 'named routes' do
    it 'routes GET new_registration_path to #new' do
      expect(get: new_registration_path).to route_to('users/registrations#new')
    end

    it 'routes POST set_address_registration_path to #new' do
      expect(post: set_address_registration_path).to route_to('users/registrations#set_address')
    end

    it 'routes POST registration_path to #create' do
      expect(post: registration_path).to route_to('users/registrations#create')
    end

    it 'routes GET graetzls_registration_path to #graetzl' do
      expect(get: graetzls_registration_path).to route_to('users/registrations#graetzls')
    end

    it 'routes DELETE registration_path to #destroy' do
      expect(delete: registration_path).to route_to('users/registrations#destroy')
    end
  end
end
