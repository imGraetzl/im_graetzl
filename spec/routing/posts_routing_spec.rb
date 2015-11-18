require 'rails_helper'

RSpec.describe PostsController, type: :routing do

  describe 'routes ' do

    it 'does not route POST /posts to posts#create' do
      expect(post: '/posts').not_to route_to(
        controller: 'posts',
        action: 'create')
    end

    it 'routes POST locations/location-slug/posts to locations/posts#create' do
      expect(post: 'locations/location-slug/posts').to route_to(
        controller: 'locations/posts',
        action: 'create',
        location_id: 'location-slug')
    end

    it 'routes POST users/user-slug/posts to users/posts#create' do
      expect(post: 'users/user-slug/posts').to route_to(
        controller: 'users/posts',
        action: 'create',
        user_id: 'user-slug')
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

    it 'does not route POST posts_path to post#create' do
      expect(post: posts_path).not_to route_to(
        controller: 'posts',
        action: 'create')
    end

    it 'routes POST location_posts_path(location-slug) to locations/post#create' do
      expect(post: location_posts_path('location-slug')).to route_to(
        controller: 'locations/posts',
        action: 'create',
        location_id: 'location-slug')
    end

    it 'routes POST user_posts_path(user-slug) to users/post#create' do
      expect(post: user_posts_path('user-slug')).to route_to(
        controller: 'users/posts',
        action: 'create',
        user_id: 'user-slug')
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
