require 'rails_helper'

RSpec.describe Admin::UserPostsController, type: :routing do
  describe 'routes' do
    it 'routes GET admin/user_posts to #index' do
      expect(get: 'admin/user_posts').to route_to 'admin/user_posts#index'
    end

    it 'routes GET admin/user_posts/post-slug to #show' do
      expect(get: 'admin/user_posts/post-slug').to route_to 'admin/user_posts#show', id: 'post-slug'
    end

    it 'does not route GET admin/user_posts/new' do
      expect(get: 'admin/user_posts/new').not_to route_to 'admin/user_posts#new'
    end

    it 'does not route POST admin/user_posts' do
      expect(post: 'admin/user_posts').not_to be_routable
    end

    it 'routes GET admin/user_posts/post-slug/edit to #edit' do
      expect(get: 'admin/user_posts/post-slug/edit').to route_to 'admin/user_posts#edit', id: 'post-slug'
    end

    it 'routes PUT admin/user_posts/post-slug to #update' do
      expect(put: 'admin/user_posts/post-slug').to route_to 'admin/user_posts#update', id: 'post-slug'
    end
  end
  describe 'named routes' do
    it 'routes GET admin_user_posts_path to #index' do
      expect(get: admin_user_posts_path).to route_to 'admin/user_posts#index'
    end

    it 'routes GET admin_user_post_path to #show' do
      expect(get: admin_user_post_path('post-slug')).to route_to 'admin/user_posts#show', id: 'post-slug'
    end

    it 'routes GET edit_admin_user_post_path to #edit' do
      expect(get: edit_admin_user_post_path('post-slug')).to route_to 'admin/user_posts#edit', id: 'post-slug'
    end

    it 'routes PUT admin_user_post_path to #update' do
      expect(put: admin_user_post_path('post-slug')).to route_to 'admin/user_posts#update', id: 'post-slug'
    end
  end
end
