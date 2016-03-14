require 'rails_helper'

RSpec.describe LocationPostsController, type: :routing do
  describe 'routes ' do
    it 'routes POST /location_posts to #create' do
      expect(post: '/location_posts').to route_to('location_posts#create')
    end
  end
  describe 'named routes' do
    it 'routes POST location_posts_path to #create' do
      expect(post: location_posts_path).to route_to('location_posts#create')
    end
  end
end
