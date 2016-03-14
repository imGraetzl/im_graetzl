require 'rails_helper'

RSpec.describe GoingTosController, type: :routing do
  describe 'routes' do
    it 'routes POST /going_tos to #create' do
      expect(post: '/going_tos').to route_to('going_tos#create')
    end

    it 'routes DELETE /going_tos/going-to-id to #destroy' do
      expect(delete: '/going_tos/going-to-id').to route_to('going_tos#destroy', id: 'going-to-id')
    end
  end
  describe 'named routes' do
    it 'routes POST going_tos_path to #create' do
      expect(post: going_tos_path).to route_to('going_tos#create')
    end

    it 'routes DELETE going_to_path to #destroy' do
      expect(delete: going_to_path('going-to-id')).to route_to('going_tos#destroy', id: 'going-to-id')
    end
  end
end
