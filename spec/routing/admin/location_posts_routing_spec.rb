require 'rails_helper'

RSpec.describe Admin::LocationPostsController, type: :routing do
  describe 'routes' do
    it 'routes GET admin/location_posts to #index' do
      expect(get: 'admin/location_posts').to route_to 'admin/location_posts#index'
    end

    it 'routes GET admin/location_posts/post-slug to #show' do
      expect(get: 'admin/location_posts/post-slug').to route_to 'admin/location_posts#show', id: 'post-slug'
    end

    it 'does not route GET admin/location_posts/new' do
      expect(get: 'admin/location_posts/new').not_to route_to 'admin/location_posts#new'
    end

    it 'does not route POST admin/location_posts' do
      expect(post: 'admin/location_posts').not_to be_routable
    end

    it 'routes GET admin/location_posts/post-slug/edit to #edit' do
      expect(get: 'admin/location_posts/post-slug/edit').to route_to 'admin/location_posts#edit', id: 'post-slug'
    end

    it 'routes PUT admin/location_posts/post-slug to #update' do
      expect(put: 'admin/location_posts/post-slug').to route_to 'admin/location_posts#update', id: 'post-slug'
    end
  end
  describe 'named routes' do
    it 'routes GET admin_location_posts_path to #index' do
      expect(get: admin_location_posts_path).to route_to 'admin/location_posts#index'
    end

    it 'routes GET admin_location_post_path to #show' do
      expect(get: admin_location_post_path('post-slug')).to route_to 'admin/location_posts#show', id: 'post-slug'
    end

    it 'routes GET edit_admin_location_post_path to #edit' do
      expect(get: edit_admin_location_post_path('post-slug')).to route_to 'admin/location_posts#edit', id: 'post-slug'
    end

    it 'routes PUT admin_location_post_path to #update' do
      expect(put: admin_location_post_path('post-slug')).to route_to 'admin/location_posts#update', id: 'post-slug'
    end
  end
end
