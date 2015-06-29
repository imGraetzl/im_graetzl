require 'rails_helper'

RSpec.describe CommentsController, type: :routing do
  
  describe 'routing' do

    it 'routes /treffen/meeting_slug/comments to meetings/comments#create' do
      expect(post: '/graetzl_slug/treffen/meeting_slug/comments').to route_to(
        controller: 'meetings/comments',
        action: 'create',
        graetzl_id: 'graetzl_slug',
        meeting_id: 'meeting_slug')
    end

    it 'routes /posts/post_id/comments to posts/comments#create' do
      expect(post: '/graetzl_slug/posts/post_id/comments').to route_to(
        controller: 'posts/comments',
        action: 'create',
        graetzl_id: 'graetzl_slug',
        post_id: 'post_id')
    end
  end
end