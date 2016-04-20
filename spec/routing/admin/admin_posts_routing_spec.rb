require 'rails_helper'

RSpec.describe Admin::AdminPostsController, type: :routing do
  describe 'routes' do
    it 'routes GET admin/admin_posts to #index' do
      expect(get: 'admin/admin_posts').to route_to 'admin/admin_posts#index'
    end

    it 'routes GET admin/admin_posts/post-slug to #show' do
      expect(get: 'admin/admin_posts/post-slug').to route_to 'admin/admin_posts#show', id: 'post-slug'
    end

    it 'routes GET admin/admin_posts/new to #new' do
      expect(get: 'admin/admin_posts/new').to route_to 'admin/admin_posts#new'
    end

    it 'routes POST admin/admin_posts to #create' do
      expect(post: 'admin/admin_posts').to route_to 'admin/admin_posts#create'
    end

    it 'routes GET admin/admin_posts/post-slug/edit to #edit' do
      expect(get: 'admin/admin_posts/post-slug/edit').to route_to 'admin/admin_posts#edit', id: 'post-slug'
    end

    it 'routes PUT admin/admin_posts/post-slug to #update' do
      expect(put: 'admin/admin_posts/post-slug').to route_to 'admin/admin_posts#update', id: 'post-slug'
    end
  end
  describe 'named routes' do
    it 'routes GET admin_admin_posts_path to #index' do
      expect(get: admin_admin_posts_path).to route_to 'admin/admin_posts#index'
    end

    it 'routes GET admin_admin_post_path to #show' do
      expect(get: admin_admin_post_path('post-slug')).to route_to 'admin/admin_posts#show', id: 'post-slug'
    end

    it 'routes GET new_admin_admin_post_path to #new' do
      expect(get: new_admin_admin_post_path).to route_to 'admin/admin_posts#new'
    end

    it 'routes POST admin_admin_posts_path to #create' do
      expect(post: admin_admin_posts_path).to route_to 'admin/admin_posts#create'
    end

    it 'routes GET edit_admin_admin_post_path to #edit' do
      expect(get: edit_admin_admin_post_path('post-slug')).to route_to 'admin/admin_posts#edit', id: 'post-slug'
    end

    it 'routes PUT admin_admin_post_path to #update' do
      expect(put: admin_admin_post_path('post-slug')).to route_to 'admin/admin_posts#update', id: 'post-slug'
    end
  end
end
