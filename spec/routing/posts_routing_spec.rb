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

    it 'routes GET graetzl-slug/user_posts/post-slug to user_posts#show' do
      expect(get: 'graetzl-slug/user_posts/post-slug').to route_to('user_posts#show', graetzl_id: 'graetzl-slug', id: 'post-slug')
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

    it 'routes POST /location_posts to location_posts#create' do
      expect(post: '/location_posts').to route_to('location_posts#create')
    end
  end

  describe 'named routes' do
    it 'routes GET graetzl_posts to posts#index' do
      expect(get: graetzl_posts_path('graetzl-slug')).to route_to('posts#index', graetzl_id: 'graetzl-slug')
    end

    it 'routes GET graetzl_user_post to user_posts#show' do
      expect(get: graetzl_user_post_path(graetzl_id: 'graetzl-slug', id: 'post-slug')).
        to route_to('user_posts#show', graetzl_id: 'graetzl-slug', id: 'post-slug')
    end

    it 'routes GET new_graetzl_user_post to user_posts#new' do
      expect(get: new_graetzl_user_post_path('graetzl-slug')).to route_to('user_posts#new', graetzl_id: 'graetzl-slug')
    end

    it 'routes POST graetzl_user_posts to user_posts#create' do
      expect(post: graetzl_user_posts_path('graetzl-slug')).to route_to('user_posts#create', graetzl_id: 'graetzl-slug')
    end

    it 'routes DELETE post_path(post-slug) to post#destroy' do
      expect(delete: post_path('post-slug')).to route_to('posts#destroy', id: 'post-slug')
    end

    it 'routes POST location_posts_path to location_posts#create' do
      expect(post: location_posts_path).to route_to('location_posts#create')
    end
  end
end
