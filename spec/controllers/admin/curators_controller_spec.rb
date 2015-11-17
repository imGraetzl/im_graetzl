require 'rails_helper'

RSpec.describe Admin::CuratorsController, type: :controller do
  let(:admin) { create(:user, role: User.roles[:admin]) }

  before { sign_in admin }

  describe 'GET index' do
    before { get :index }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @curators' do
      expect(assigns(:curators)).not_to be_nil
    end

    it 'renders :index' do
      expect(response).to render_template(:index)
    end
  end

  describe 'GET show' do
    let(:curator) { create(:curator) }
    before { get :show, id: curator }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @curator' do
      expect(assigns(:curator)).to eq curator
    end

    it 'renders :show' do
      expect(response).to render_template(:show)
    end
  end

  describe 'GET new' do
    before { get :new }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @curator' do
      expect(assigns(:curator)).to be_a_new(Curator)
    end

    it 'renders :new' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST create' do
    let(:curator) { build(:curator,
      graetzl: create(:graetzl),
      user: create(:user),
      website: 'http://google.de',
      description: 'lorem') }
    let(:params) {
      {
        curator: {
          graetzl_id: curator.graetzl.id,
          user_id: curator.user.id,
          website: curator.website,
          description: curator.description
        }
      }
    }

    context 'with basic attributes' do

      it 'creates new curator record' do
        expect{
          post :create, params
        }.to change{Curator.count}.by(1)
      end

      it 'assigns attributes to curator' do
        post :create, params
        c = Curator.last
        expect(c).to have_attributes(
          graetzl: curator.graetzl,
          user: curator.user,
          website: curator.website,
          description: curator.description)
      end

      it 'redirects_to new curator page' do
        post :create, params
        new_curator = Curator.last
        expect(response).to redirect_to(admin_curator_path(new_curator))
      end
    end
  end

  describe 'GET edit' do
    let(:curator) { create(:curator) }
    before { get :edit, id: curator }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @curator' do
      expect(assigns(:curator)).to eq curator
    end

    it 'renders :edit' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH update' do
    let(:curator) { create(:curator) }
    let(:new_curator) { build(:curator,
      graetzl: create(:graetzl),
      user: create(:user),
      website: 'http://google.de',
      description: 'lorem') }
    let(:params) {
      {
        id: curator,
        curator: {
          graetzl_id: new_curator.graetzl.id,
          user_id: new_curator.user.id,
          website: new_curator.website,
          description: new_curator.description
        }
      }
    }

    context 'with basic attributes' do
      before do
        patch :update, params
        curator.reload
      end

      it 'redirects to curator page' do
        expect(response).to redirect_to(admin_curator_path(curator))
      end

      it 'updates curator attributes' do
        expect(curator).to have_attributes(
          graetzl_id: new_curator.graetzl.id,
          user_id: new_curator.user.id,
          website: new_curator.website,
          description: new_curator.description)
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:curator) { create(:curator) }

    it 'deletes curator record' do
      expect{
        delete :destroy, id: curator
      }.to change{Curator.count}.by(-1)
    end

    it 'redirects_to index page' do
      delete :destroy, id: curator
      expect(response).to redirect_to(admin_curators_path)
    end
  end
end
