require 'rails_helper'

RSpec.describe GraetzlsController, type: :controller do
  let(:graetzl) { create :graetzl }
  let!(:district) { create(:district, graetzls: [graetzl]) }

  describe 'GET show' do
    context 'when logged in' do
      before { sign_in create(:user) }

      context 'when html request' do
        before { get :show, params: { id: graetzl, page: 2 } }

        it 'assigns @graetzl' do
          expect(assigns :graetzl).to eq graetzl
        end

        it 'assigns @map_data' do
          expect(assigns :map_data).to be
        end

        it 'renders show.html' do
          expect(response.content_type).to eq 'text/html'
          expect(response).to render_template(:show)
        end
      end
    end
    context 'when logged out' do
      before { get :show, params: { id: graetzl } }

      it 'assigns @graetzl' do
        expect(assigns :graetzl).to eq graetzl
      end

      it 'assigns @activity_sample' do
        expect(assigns :activity_sample).to be
      end

      it 'assigns @map_data' do
        expect(assigns :map_data).to be
      end

      it 'renders show.html' do
        expect(response.content_type).to eq 'text/html'
        expect(response).to render_template(:show)
      end
    end
  end
end
