require 'rails_helper'

RSpec.describe Users::PasswordsController, type: :routing do

  describe 'routes' do
    it 'routes GET /users/passwort/neu to users/passwords#new' do
      expect(get: '/users/passwort/neu').to route_to('users/passwords#new')
    end

    it 'routes GET /users/passwort/edit to users/passwords#edit' do
      expect(get: '/users/passwort/edit').to route_to('users/passwords#edit')
    end

    it 'routes GET /users/passwort to users/passwords#show' do
      expect(GET: '/users/passwort').to route_to('users/passwords#show')
    end

    it 'routes PUT /users/passwort to users/passwords#update' do
      expect(put: '/users/passwort').to route_to('users/passwords#update')
    end

    it 'routes POST /users/passwort to users/passwords#create' do
      expect(post: '/users/passwort').to route_to('users/passwords#create')
    end

    it 'routes DELETE /users/passwort to users/passwords#destroy' do
      expect(delete: '/users/passwort').to route_to('users/passwords#destroy')
    end
  end

  describe 'named routes' do
    it 'routes GET new_password_path to users/passwords#new' do
      expect(get: new_password_path).to route_to('users/passwords#new')
    end

    it 'routes GET edit_password_path to users/passwords#edit' do
      expect(get: edit_password_path).to route_to('users/passwords#edit')
    end

    it 'routes GET password_path to users/passwords#show' do
      expect(GET: password_path).to route_to('users/passwords#show')
    end

    it 'routes PUT password_path to users/passwords#update' do
      expect(put: password_path).to route_to('users/passwords#update')
    end

    it 'routes POST password_path to users/passwords#create' do
      expect(post: password_path).to route_to('users/passwords#create')
    end

    it 'routes DELETE password_path to users/passwords#destroy' do
      expect(delete: password_path).to route_to('users/passwords#destroy')
    end
  end
end
