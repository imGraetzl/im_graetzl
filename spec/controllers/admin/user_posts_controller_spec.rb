require 'rails_helper'

RSpec.describe Admin::UserPostsController, type: :controller do
  let(:admin) { create :user, :admin }
  before { sign_in admin }

  describe 'GET index' do
    let!(:user_posts) { create_list :user_post, 30 }

    before { get :index }

    it 'assigns @user_posts with 30 first records' do
      expect(assigns :user_posts).to match_array user_posts
    end

    it 'renders index' do
      expect(response).to render_template 'admin/user_posts/_index'
    end
  end
  describe 'GET show' do
    let(:user_post) { create :user_post }

    before { get :show, params: { id: user_post } }

    it 'assigns @user_post' do
      expect(assigns :user_post).to eq user_post
    end

    it 'renders show' do
      expect(response).to render_template 'admin/user_posts/_show'
    end
  end
  describe 'GET edit' do
    let(:user_post) { create :user_post }
    before { get :edit, params: { id: user_post } }

    it 'assigns @user_post' do
      expect(assigns :user_post).to eq user_post
    end

    it 'renders form' do
      expect(response).to render_template 'admin/user_posts/_form'
    end
  end
  describe 'PUT update' do
    let!(:graetzl) { create :graetzl }
    let!(:new_user) { create :user }
    let(:user_post) { create :user_post }
    let(:params) {{ id: user_post, user_post: { title: 'hello', content: 'world',
      graetzl_id: graetzl.id, author_id: new_user.id, author_type: 'User' }}}

    before do
      put :update, params: params
      user_post.reload
    end

    it 'changes attributes' do
      expect(user_post).to have_attributes(title: 'hello', content: 'world', graetzl: graetzl, author: new_user)
    end

    it 'redirect_to user_post' do
      expect(response).to redirect_to [:admin, user_post]
    end
  end
  describe 'DELETE destroy' do
    let!(:user_post) { create :user_post }

    it 'deletes record' do
      expect{
        delete :destroy, params: { id: user_post }
      }.to change{UserPost.count}.by -1
    end

    it 'redirect_to user_post index' do
      delete :destroy, params: { id: user_post }
      expect(response).to redirect_to [:admin, UserPost]
    end
  end
end
