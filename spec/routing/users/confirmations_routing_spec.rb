require 'rails_helper'

RSpec.describe Users::ConfirmationsController, type: :routing do

  describe 'routes' do
    it 'routes GET /users/bestaetigung/neu to #new' do
      expect(get: '/users/bestaetigung/neu').to route_to('users/confirmations#new')
    end

    it 'routes GET /users/bestaetigung to #show' do
      expect(GET: '/users/bestaetigung').to route_to('users/confirmations#show')
    end

    it 'routes POST /users/bestaetigung to #create' do
      expect(post: '/users/bestaetigung').to route_to('users/confirmations#create')
    end
  end

  describe 'named routes' do
    it 'routes GET new_confirmation_path to #new' do
      expect(get: new_confirmation_path).to route_to('users/confirmations#new')
    end

    it 'routes GET confirmation_path to #show' do
      expect(GET: confirmation_path).to route_to('users/confirmations#show')
    end

    it 'routes POST confirmation_path to #create' do
      expect(post: confirmation_path).to route_to('users/confirmations#create')
    end
  end
end
