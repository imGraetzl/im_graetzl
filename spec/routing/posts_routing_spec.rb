require 'rails_helper'

RSpec.describe PostsController, type: :routing do
  
  describe 'routing ' do

    it 'routes POST /posts to posts#create' do
      expect(post: '/posts').to route_to(
        controller: 'posts',
        action: 'create')
    end
  end

  describe 'named routing' do

    it 'routes POST posts to post#create' do
      expect(post: posts_path).to route_to(
        controller: 'posts',
        action: 'create')
    end
  end
end