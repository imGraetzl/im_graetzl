require 'rails_helper'

RSpec.describe PostsController, type: :routing do
  
describe 'routing ' do

    it 'does not route GET /posts' do
      expect(get: '/graetzl_slug/posts').not_to be_routable
    end

    it 'does not route GET /posts/post_id' do
      expect(get: '/graetzl_slug/posts/post_id').not_to be_routable
    end

    it 'does not route GET /posts/new' do
      expect(get: '/graetzl_slug/posts/new').not_to be_routable
    end

    it 'routes POST /posts/new to #create' do
      expect(post: '/graetzl_slug/posts').to route_to(
        controller: 'posts',
        action: 'create',
        graetzl_id: 'graetzl_slug')
    end

    it 'does not route GET /posts/post_id/edit' do
      expect(get: '/graetzl_slug/posts/post_id/edit').not_to be_routable
    end

    it 'does not route PUT /posts/post_id' do
      expect(put: '/graetzl_slug/posts/post_id').not_to be_routable
    end

    it 'does not route PATCH /posts/post_id' do
      expect(patch: '/graetzl_slug/posts/post_id').not_to be_routable
    end

    it 'does not route DELETE /posts/post_id to #destroy' do
      expect(delete: '/graetzl_slug/posts/post_id').not_to be_routable
    end
  end
end