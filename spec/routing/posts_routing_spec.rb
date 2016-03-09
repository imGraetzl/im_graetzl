require 'rails_helper'

RSpec.describe PostsController, type: :routing do
  describe 'routes ' do
    it 'does not route POST graetzl-slug/posts' do
      expect(post: 'graetzl-slug/posts').not_to route_to('posts#create')
    end

    it 'does not route GET graetzl-slug/posts/new' do
      expect(get: 'graetzl-slug/posts/new').not_to route_to('posts#new')
    end

    it 'routes GET graetzl-slug/posts to posts#index' do
      expect(get: 'graetzl-slug/posts').to route_to('posts#index', graetzl_id: 'graetzl-slug')
    end

    it 'routes GET graetzl-slug/posts/post-slug to posts#show' do
      expect(get: 'graetzl-slug/posts/post-slug').to route_to('posts#show', graetzl_id: 'graetzl-slug', id: 'post-slug')
    end

    it 'routes GET graetzl-slug/user_posts/new to user_posts#new' do
      expect(get: 'graetzl-slug/user_posts/new').to route_to('user_posts#new', graetzl_id: 'graetzl-slug')
    end

    it 'routes POST graetzl-slug/user_posts to user_posts#create' do
      expect(post: 'graetzl-slug/user_posts').to route_to('user_posts#create', graetzl_id: 'graetzl-slug')
    end

    it 'routes DELETE /posts/post-slug to posts#destroy' do
      expect(delete: '/posts/post-slug').to route_to('posts#destroy', id: 'post-slug')
    end
  end

  describe 'named routes' do

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
