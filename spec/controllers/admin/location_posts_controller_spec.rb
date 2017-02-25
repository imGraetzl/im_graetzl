require 'rails_helper'

RSpec.describe Admin::LocationPostsController, type: :controller do
  let(:admin) { create :user, :admin }
  before { sign_in admin }

  describe 'GET index' do
    let!(:location_posts) { create_list :location_post, 30 }

    before { get :index }

    it 'assigns @location_posts with 30 first records' do
      expect(assigns :location_posts).to match_array location_posts
    end

    it 'renders index' do
      expect(response).to render_template 'admin/location_posts/_index'
    end
  end
  describe 'GET show' do
    let(:location_post) { create :location_post }

    before { get :show, params: { id: location_post } }

    it 'assigns @location_post' do
      expect(assigns :location_post).to eq location_post
    end

    it 'renders show' do
      expect(response).to render_template 'admin/location_posts/_show'
    end
  end
  describe 'GET edit' do
    let(:location_post) { create :location_post }
    before { get :edit, params: { id: location_post } }

    it 'assigns @location_post' do
      expect(assigns :location_post).to eq location_post
    end

    it 'renders form' do
      expect(response).to render_template 'admin/location_posts/_form'
    end
  end
  describe 'PUT update' do
    let(:location_post) { create :location_post }
    let(:params) {{ id: location_post, location_post: { title: 'hello', content: 'world' }}}

    before do
      put :update, params: params
      location_post.reload
    end

    it 'changes attributes' do
      expect(location_post).to have_attributes(title: 'hello', content: 'world')
    end

    it 'redirect_to location_post' do
      expect(response).to redirect_to [:admin, location_post]
    end
  end
  describe 'DELETE destroy' do
    let!(:location_post) { create :location_post }

    it 'deletes record' do
      expect{
        delete :destroy, params: { id: location_post }
      }.to change{LocationPost.count}.by -1
    end

    it 'redirect_to location_post index' do
      delete :destroy, params: { id: location_post }
      expect(response).to redirect_to [:admin, LocationPost]
    end
  end
end
