require 'rails_helper'

RSpec.describe Admin::GraetzlsController, type: :controller do
  let(:admin) { create :user, :admin }

  before { sign_in admin }

  describe 'GET index' do
    before { get :index }

    it 'assigns @graetzls' do
      expect(assigns :graetzls).not_to be_nil
    end

    it 'renders :index' do
      expect(response).to render_template :index
    end
  end

  describe 'GET show' do
    let!(:graetzl) { create :graetzl }
    before { get :show, params: { id: graetzl } }
    it 'assigns @graetzl' do
      expect(assigns :graetzl).to eq graetzl
    end

    it 'renders :show' do
      expect(response).to render_template :show
    end
  end

  describe 'GET new' do
    before { get :new }

    it 'assigns @graetzl' do
      expect(assigns :graetzl).to be_a_new Graetzl
    end

    it 'renders :new' do
      expect(response).to render_template :new
    end
  end

  describe 'POST create' do
    let(:graetzl) { build(:graetzl) }
    let(:params) {
      {
        graetzl: {
          name: graetzl.name,
          area: graetzl.area
        }
      }
    }

    it 'creates new graetzl record' do
      expect{
        post :create, params: params
      }.to change{Graetzl.count}.by 1
    end

    it 'assigns attributes to graetzl' do
      post :create, params: params
      g = Graetzl.last
      expect(g).to have_attributes(
        name: graetzl.name,
        area: graetzl.area)
    end

    it 'redirects_to new graetzl page' do
      post :create, params: params
      new_graetzl = Graetzl.last
      expect(response).to redirect_to(admin_graetzl_path(new_graetzl))
    end
  end

  describe 'GET edit' do
    let(:graetzl) { create :graetzl }
    before { get :edit, params: { id: graetzl } }

    it 'assigns @graetzl' do
      expect(assigns :graetzl).to eq graetzl
    end

    it 'renders :edit' do
      expect(response).to render_template :edit
    end
  end

  describe 'PATCH update' do
    let(:graetzl) { create :graetzl }
    let(:new_graetzl) { build :graetzl }
    let(:params) {
      {
        id: graetzl,
        graetzl: {
          name: new_graetzl.name,
          area: new_graetzl.area
        }
      }
    }

    before do
      patch :update, params: params
      graetzl.reload
    end

    it 'redirects to graetzl page' do
      expect(response).to redirect_to(admin_graetzl_path(graetzl))
    end

    it 'updates graetzl attributes' do
      expect(graetzl).to have_attributes(
        name: new_graetzl.name,
        area: new_graetzl.area)
    end
  end

  describe 'DELETE destroy' do
    let!(:graetzl) { create :graetzl }

    it 'deletes graetzl record' do
      expect{
        delete :destroy, params: { id: graetzl }
      }.to change{Graetzl.count}.by -1
    end

    it 'redirects_to index page' do
      delete :destroy, params: { id: graetzl }
      expect(response).to redirect_to(admin_graetzls_path)
    end
  end
end
