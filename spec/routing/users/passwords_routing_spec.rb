require 'rails_helper'

RSpec.describe Users::PasswordsController, type: :routing do

  describe 'routes' do

    it 'routes GET /users/passwort/neu to users/passwords#new' do
      expect(get: '/users/passwort/neu').to route_to(
        controller: 'users/passwords',
        action: 'new')
    end

    it 'routes POST /users/passwort to users/passwords#create' do
      expect(post: '/users/passwort').to route_to(
        controller: 'users/passwords',
        action: 'create')
    end
  end

  describe 'named routes' do

    it 'routes GET new_password_path to users/passwords#new' do
      expect(get: new_password_path).to route_to(
        controller: 'users/passwords',
        action: 'new')
    end

    it 'routes POST password_path to users/passwords#create' do
      expect(post: password_path).to route_to(
        controller: 'users/passwords',
        action: 'create')
    end
  end
end