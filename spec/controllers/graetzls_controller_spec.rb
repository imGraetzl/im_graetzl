require 'rails_helper'

RSpec.describe GraetzlsController, type: :controller do
  let(:user) { create(:user) }
  let(:graetzl) { create(:graetzl) }

  describe 'GET index' do
    before { get :index }

    it 'returns a 200 OK status' do
      expect(response).to be_success
    end

    it 'assigns @graetzls' do
      expect(assigns(:graetzls)).to eq Graetzl.all
    end
  end

  describe 'GET show' do
    before { get :show, id: graetzl.id }

    it 'returns a 200 OK status' do
      expect(response).to be_success
      expect(response).to have_http_status(:ok)
    end

    it 'assigns @graetzls' do
      expect(assigns(:graetzl)).to eq graetzl
    end

    it 'assigns @activities' do
      expect(assigns(:activities)).to be_a_kind_of(Array)
      expect(assigns(:activities)).to eq graetzl.activity
    end

    it 'renders #show' do
      expect(response).to render_template(:show)
    end

    describe 'assigns @meetings' do

      it 'is collection' do
        expect(assigns(:meetings)).to be_a_kind_of(Array)
      end

      context 'with meetings' do
        let!(:upcoming) { create(:meeting, graetzl: graetzl, starts_at_date: Date.tomorrow) }
        let!(:past) { build(:meeting, graetzl: graetzl, starts_at_date: Date.yesterday) }

        before { past.save(validate: false) }

        it 'contains upcoming meetings' do
          get :show, id: graetzl.id
          expect(assigns(:meetings)).to include(upcoming)
        end

        it 'excludes past meetings' do
          get :show, id: graetzl.id
          expect(assigns(:meetings)).not_to include(past)
        end
      end
    end
  end
end
