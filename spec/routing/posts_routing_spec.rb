require 'rails_helper'

RSpec.describe PostsController, type: :routing do
  describe 'routes ' do
    it 'does not route POST graetzl-slug/posts' do
      expect(post: '/graetzl-slug/posts').not_to route_to('posts#create')
    end

    it 'does not route GET graetzl-slug/posts/new' do
      expect(get: '/graetzl-slug/posts/new').not_to route_to('posts#new')
    end

    it 'routes GET graetzl-slug/posts to #index' do
      expect(get: 'graetzl-slug/posts').to route_to('posts#index', graetzl_id: 'graetzl-slug')
    end

    it 'routes DELETE /posts/post-slug to posts#destroy' do
      expect(delete: '/posts/post-slug').to route_to('posts#destroy', id: 'post-slug')
    end
  end

  describe 'named routes' do
    it 'routes GET graetzl_posts_path to #index' do
      expect(get: graetzl_posts_path('graetzl-slug')).to route_to('posts#index', graetzl_id: 'graetzl-slug')
    end

    it 'routes DELETE post_path to posts#destroy' do
      expect(delete: post_path('post-slug')).to route_to('posts#destroy', id: 'post-slug')
    end
  end
end
