require 'rails_helper'

RSpec.describe CommentsController, type: :routing do
  
  describe 'routing' do

    it 'routes POST /graetzl-slug/treffen/meeting-slug/comments to meetings/comments#create' do
      expect(post: '/graetzl-slug/treffen/meeting-slug/comments').to route_to(
        controller: 'meetings/comments',
        action: 'create',
        graetzl_id: 'graetzl-slug',
        meeting_id: 'meeting-slug')
    end

    it 'routes POST /graetzl-slug/posts/post_id/comments to posts/comments#create' do
      expect(post: '/graetzl-slug/posts/post_id/comments').to route_to(
        controller: 'posts/comments',
        action: 'create',
        graetzl_id: 'graetzl-slug',
        post_id: 'post_id')
    end

    it 'routes PUT /comments/:id to comments#update' do
      expect(put: '/comments/id').to route_to(
        controller: 'comments',
        action: 'update',
        id: 'id')
    end

    it 'routes DELETE /comments/:id to comments#destroy' do
      expect(delete: '/comments/id').to route_to(
        controller: 'comments',
        action: 'destroy',
        id: 'id')
    end
  end

  describe 'named routing' do

    it 'routes POST graetzl_meeting_comments to meetings/comments#create' do
      expect(post: graetzl_meeting_comments_path(graetzl_id: 'graetzl-slug',
        meeting_id: 'meeting-slug')).to route_to(
          controller: 'meetings/comments',
          action: 'create',
          graetzl_id: 'graetzl-slug',
          meeting_id: 'meeting-slug')
    end

    it 'routes POST graetzl_post_comments to post/comments#create' do
      expect(post: graetzl_post_comments_path(graetzl_id: 'graetzl-slug',
        post_id: 'post_id')).to route_to(
          controller: 'posts/comments',
          action: 'create',
          graetzl_id: 'graetzl-slug',
          post_id: 'post_id')
    end

    it 'routes PUT comment to comments#update' do
      expect(put: comment_path(id: 'id')).to route_to(
        controller: 'comments',
        action: 'update',
        id: 'id')
    end

    it 'routes DELETE /comments/:id to comments#destroy' do
      expect(delete: comment_path(id: 'id')).to route_to(
        controller: 'comments',
        action: 'destroy',
        id: 'id')
    end
  end
end