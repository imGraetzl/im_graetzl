require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  describe 'POST create' do
    context 'when logged out' do
      it 'returns 401 unauthorized' do
        xhr :post, :create, comment: {}
        expect(response).to have_http_status 401
      end
    end
    context 'when logged in' do
      let(:user) { create :user }
      let(:commentable) { create :user_post }
      let(:params) { {comment: {
        content: 'some random string',
        commentable_id: commentable.id,
        commentable_type: 'UserPost' }} }

      before { sign_in user }

      it 'creates new comment record' do
        expect{
          xhr :post, :create, params
        }.to change{Comment.count}.by 1
      end

      it 'logs activity' do
        expect{
          xhr :post, :create, params
        }.to change{Activity.count}.by 1
      end

      it 'assigns @comment with attributes' do
        xhr :post, :create, params
        expect(assigns :comment).to have_attributes(user: user, commentable: commentable)
      end

      it 'renders create.js' do
        xhr :post, :create, params
        expect(response['Content-Type']).to eq 'text/javascript; charset=utf-8'
        expect(response).to render_template :create
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:comment) { create :comment }

    context 'when logged out' do
      it 'returns 401 unauthorized' do
        xhr :delete, :destroy, id: comment
        expect(response).to have_http_status 401
      end
    end
    context 'when logged in' do
      let(:user) { create :user }
      before { sign_in user }

      it 'removes comment' do
        expect{
          xhr :delete, :destroy, id: comment
        }.to change{Comment.count}.by -1
      end

      it 'assigns @comment' do
        xhr :delete, :destroy, id: comment
        expect(assigns(:comment)).to eq comment
      end

      it 'renders destroy.js' do
        xhr :delete, :destroy, id: comment
        expect(response.content_type).to eq 'text/javascript'
        expect(response).to render_template(:destroy)
      end
    end
  end
end
