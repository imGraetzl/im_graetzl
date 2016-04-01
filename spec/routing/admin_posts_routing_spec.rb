require 'rails_helper'

RSpec.describe AdminPostsController, type: :routing do
  describe 'routes ' do
    it 'routes GET /ideen/post-slug to #show' do
      expect(get: '/ideen/post-slug').to route_to('admin_posts#show', id: 'post-slug')
    end
  end
  describe 'named routes' do
    it 'routes GET admin_post_path to #show' do
      expect(get: admin_post_path('post-slug')).to route_to('admin_posts#show', id: 'post-slug')
    end
  end
end
