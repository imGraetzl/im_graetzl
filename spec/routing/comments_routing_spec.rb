require 'rails_helper'

RSpec.describe CommentsController, type: :routing do
  describe 'routes' do
    it 'routes POST /comments to #create' do
      expect(post: '/comments').to route_to('comments#create')
    end

    it 'routes DELETE /comments/comment-id to #destroy' do
      expect(delete: '/comments/comment-id').to route_to('comments#destroy', id: 'comment-id')
    end
  end
  describe 'named routes' do
    it 'routes POST comments_path to #create' do
      expect(post: comments_path).to route_to('comments#create')
    end

    it 'routes DELETE comment_path to #destroy' do
      expect(delete: comment_path('comment-id')).to route_to('comments#destroy', id: 'comment-id')
    end
  end
end
