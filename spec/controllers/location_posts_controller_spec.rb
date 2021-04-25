require 'rails_helper'

RSpec.describe LocationPostsController, type: :controller do
  describe 'POST create' do
    let(:graetzl) { create :graetzl }
    let(:location) { create :location, :approved, graetzl: graetzl }

    context 'when logged out' do
      it 'returns 401 unauthorized' do
        post :create, params: { location_post: {} }, xhr: true
        expect(response).to have_http_status 401
      end
    end
    context 'when logged in' do
      let(:user) { create :user }
      let(:params) {{ location_post: {
          title: 'something',
          content: 'something else',
          graetzl_id: graetzl.id,
          location_id: location.id} }}

      before { sign_in user }

      it 'creates new location_post record' do
        expect{
          post :create, params: params, xhr: true
        }.to change{LocationPost.count}.by 1
      end

      it 'logs activity' do
        expect{
          post :create, params: params, xhr: true
        }.to change{Activity.count}.by 1
      end

      it 'assigns @location_post with attributes' do
        post :create, params: params, xhr: true
        expect(assigns :location_post).to have_attributes(location: location, graetzl: graetzl)
      end

      it 'renders create.js' do
        post :create, params: params, xhr: true
        expect(response).to render_template :create
      end
    end
  end

  describe 'POST comment' do
    let(:location_post) { create :location_post }

    context 'when logged out' do
      it 'returns 401 unauthorized' do
        post :comment, params: { location_post_id: location_post.id }, xhr: true
        expect(response).to have_http_status 401
      end
    end
    context 'when logged in' do
      let(:user) { create :user }
      before { sign_in user }

      it 'creates new comment record' do
        expect{
          post :comment, params: { location_post_id: location_post.id, comment: { content: 'hello' } }, xhr: true
        }.to change{Comment.count}.by 1
      end

      it 'logs activity' do
        expect{
          post :comment, params: { location_post_id: location_post.id, comment: { content: 'hello' } }, xhr: true
        }.to change{Activity.count}.by 1
      end

      it 'assigns @location_post' do
        post :comment, params: { location_post_id: location_post.id, comment: { content: 'hello' } }, xhr: true
        expect(assigns :location_post).to eq location_post
      end

      it 'assigns @comment' do
        post :comment, params: { location_post_id: location_post.id, comment: { content: 'hello' } }, xhr: true
        expect(assigns :comment).to have_attributes(
          user: user,
          commentable: location_post,
          content: 'hello')
      end

      it 'renders comment.js' do
        post :comment, params: { location_post_id: location_post.id, comment: { content: 'hello' } }, xhr: true
        expect(response.content_type).to eq 'text/javascript'
        expect(response).to render_template :comment
      end
    end
  end

end
