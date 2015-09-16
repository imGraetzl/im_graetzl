require 'rails_helper'

RSpec.describe PostsController, type: :routing do
  
  describe 'routes ' do

    it 'routes POST /posts to posts#create' do
      expect(post: '/posts').to route_to(
        controller: 'posts',
        action: 'create')
    end

    it 'routes DELETE /posts/post-slug to posts#destroy' do
      expect(delete: '/posts/post-slug').to route_to(
        controller: 'posts',
        action: 'destroy',
        id: 'post-slug')
    end

    it 'routes GET /graetzl-slug/posts/post-slug to posts#show' do
      expect(get: '/graetzl-slug/posts/post-slug').to route_to(
        controller: 'posts',
        action: 'show',
        graetzl_id: 'graetzl-slug',
        id: 'post-slug')
    end
  end

  describe 'named routes' do

    it 'routes POST posts_path to post#create' do
      expect(post: posts_path).to route_to(
        controller: 'posts',
        action: 'create')
    end

    it 'routes DELETE post_path(post-slug) to post#destroy' do
      expect(delete: post_path(id: 'post-slug')).to route_to(
        controller: 'posts',
        action: 'destroy',
        id: 'post-slug')
    end

    it 'routes GET graetzl_post_path(graetzl-slug, post-slug) to post#slug' do
      expect(get: graetzl_post_path('graetzl-slug', 'post-slug')).to route_to(
        controller: 'posts',
        action: 'show',
        graetzl_id: 'graetzl-slug',
        id: 'post-slug')
    end
  end
end