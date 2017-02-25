require 'rails_helper'

RSpec.describe Admin::AdminPostsController, type: :controller do
  let(:admin) { create :user, :admin }
  before { sign_in admin }

  describe 'GET index' do
    let!(:admin_posts) { create_list :admin_post, 30 }

    before { get :index }

    it 'assigns @admin_posts with 30 first records' do
      expect(assigns :admin_posts).to match_array admin_posts
    end

    it 'renders index' do
      expect(response).to render_template 'admin/admin_posts/_index'
    end
  end
  describe 'GET show' do
    let(:admin_post) { create :admin_post }

    before { get :show, params: { id: admin_post } }

    it 'assigns @admin_post' do
      expect(assigns :admin_post).to eq admin_post
    end

    it 'renders show' do
      expect(response).to render_template 'admin/admin_posts/_show'
    end
  end
  describe 'GET new' do
    before { get :new }

    it 'assigns @admin_post' do
      expect(assigns :admin_post).to be_a_new AdminPost
    end

    it 'renders form' do
      expect(response).to render_template 'admin/admin_posts/_form'
    end
  end
  describe 'POST create' do
    let(:graetzls) { create_list :graetzl, 3 }
    let(:params) {{ admin_post: { title: 'hello', content: 'world', graetzl_ids: graetzls.map(&:id) }}}

    it 'creates admin_post record' do
      expect{
        post :create, params: params
      }.to change{AdminPost.count}.by 1
    end

    it 'creates activity record' do
      expect{
        post :create, params: params
      }.to change{Activity.count}.by 1
    end

    it 'redirects to new admin_post' do
      post :create, params: params
      admin_post = AdminPost.last
      expect(response).to redirect_to [:admin, admin_post]
    end
  end
  describe 'GET edit' do
    let(:admin_post) { create :admin_post }
    before { get :edit, params: { id: admin_post } }

    it 'assigns @admin_post' do
      expect(assigns :admin_post).to eq admin_post
    end

    it 'renders form' do
      expect(response).to render_template 'admin/admin_posts/_form'
    end
  end
  describe 'PUT update' do
    let(:graetzls) { create_list :graetzl, 3 }
    let(:admin_post) { create :admin_post }
    let(:params) {{ id: admin_post, admin_post: { title: 'hello', content: 'world', graetzl_ids: graetzls.map(&:id) }}}

    before do
      put :update, params: params
      admin_post.reload
    end

    it 'changes attributes' do
      expect(admin_post).to have_attributes(title: 'hello', content: 'world')
    end

    it 'updates graetzls' do
      expect(admin_post.graetzl_ids).to match_array graetzls.map(&:id)
    end

    it 'redirect_to admin_post' do
      expect(response).to redirect_to [:admin, admin_post]
    end
  end
  describe 'DELETE destroy' do
    let!(:admin_post) { create :admin_post }

    it 'deletes record' do
      expect{
        delete :destroy, params: { id: admin_post }
      }.to change{AdminPost.count}.by -1
    end

    it 'redirect_to admin_post index' do
      delete :destroy, params: { id: admin_post }
      expect(response).to redirect_to [:admin, AdminPost]
    end
  end
end
