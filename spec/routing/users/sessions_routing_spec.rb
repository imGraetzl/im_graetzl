require 'rails_helper'

RSpec.describe Users::SessionsController, type: :routing do

  describe 'routes' do
    it 'routes GET /users/login to #new' do
      expect(get: '/users/login').to route_to('users/sessions#new')
    end

    it 'routes POST /users/login to #create' do
      expect(post: '/users/login').to route_to('users/sessions#create')
    end

    it 'routes DELETE /users/logout to #destroy' do
      expect(delete: '/users/logout').to route_to('users/sessions#destroy')
    end
  end

  describe 'named routes' do
    it 'routes GET new_user_session_path to #new' do
      expect(get: new_user_session_path).to route_to('users/sessions#new')
    end

    it 'routes POST user_session_path to #create' do
      expect(post: user_session_path).to route_to('users/sessions#create')
    end

    it 'routes DELETE destroy_user_session_path to #destroy' do
      expect(delete: destroy_user_session_path).to route_to('users/sessions#destroy')
    end
  end
end
