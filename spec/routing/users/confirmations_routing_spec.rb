require 'rails_helper'

RSpec.describe Users::ConfirmationsController, type: :routing do

  describe 'routes' do

    it 'routes GET /users/bestaetigung/neu to users/confirmations#new' do
      expect(get: '/users/bestaetigung/neu').to route_to(
        controller: 'users/confirmations',
        action: 'new')
    end

    it 'routes POST /users/bestaetigung to users/confirmations#create' do
      expect(post: '/users/bestaetigung').to route_to(
        controller: 'users/confirmations',
        action: 'create')
    end

    it 'routes GET /users/bestaetigung to users/confirmations#show' do
      expect(get: '/users/bestaetigung').to route_to(
        controller: 'users/confirmations',
        action: 'show')
    end
  end

  describe 'named routes' do

    it 'routes GET new_confirmation_path to users/confirmations#new' do
      expect(get: new_confirmation_path).to route_to(
        controller: 'users/confirmations',
        action: 'new')
    end

    it 'routes POST confirmation_path to users/confirmations#create' do
      expect(post: confirmation_path).to route_to(
        controller: 'users/confirmations',
        action: 'create')
    end

    it 'routes GET confirmation_path to users/confirmations#show' do
      expect(get: confirmation_path).to route_to(
        controller: 'users/confirmations',
        action: 'show')
    end
  end
end