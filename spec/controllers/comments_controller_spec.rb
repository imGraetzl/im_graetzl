require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  describe 'POST create' do
    context 'when logged out' do
      it 'returns 401 unauthorized' do
        post :create, params: { comment: {} }, xhr: true
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
          post :create, params: params, xhr: true
        }.to change{Comment.count}.by 1
      end

      it 'logs activity' do
        expect{
          post :create, params: params, xhr: true
        }.to change{Activity.count}.by 1
      end

      it 'assigns @comment with attributes' do
        post :create, params: params, xhr: true
        expect(assigns :comment).to have_attributes(user: user, commentable: commentable)
      end

      it 'renders create.js' do
        post :create, params: params, xhr: true
        expect(response.content_type).to eq 'text/javascript'
        expect(response).to render_template :create
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:comment) { create :comment }

    context 'when logged out' do
      it 'returns 401 unauthorized' do
        delete :destroy, params: { id: comment }, xhr: true
        expect(response).to have_http_status 401
      end
    end
    context 'when logged in' do
      let(:user) { create :user }
      before { sign_in user }

      it 'removes comment' do
        expect{
          delete :destroy, params: { id: comment }, xhr: true
        }.to change{Comment.count}.by -1
      end

      it 'assigns @comment' do
        delete :destroy, params: { id: comment }, xhr: true
        expect(assigns(:comment)).to eq comment
      end

      it 'renders destroy.js' do
        delete :destroy, params: { id: comment }, xhr: true
        expect(response.content_type).to eq 'text/javascript'
        expect(response).to render_template(:destroy)
      end
    end
  end
end
