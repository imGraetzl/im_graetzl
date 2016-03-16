require 'rails_helper'

RSpec.describe GraetzlsController, type: :controller do
  let(:graetzl) { create :graetzl }
  let!(:district) { create :district }

  describe 'GET show' do
    context 'when html request' do
      before { get :show, id: graetzl, page: 2 }

      it 'assigns @graetzl' do
        expect(assigns :graetzl).to eq graetzl
      end

      it 'assigns @activity' do
        expect(assigns :activity).to eq graetzl.activity.page(2).per(12)
      end

      it 'assigns @activity_decorated' do
        expect(assigns :activity_decorated).to be
      end

      it 'assigns @map_data' do
        expect(assigns :map_data).to be
      end

      it 'renders show.html' do
        expect(response.content_type).to eq 'text/html'
        expect(response).to render_template(:show)
      end
    end
    context 'when js request' do
      before { xhr :get, :show, id: graetzl, page: 2 }

      it 'assigns @graetzl' do
        expect(assigns :graetzl).to eq graetzl
      end

      it 'assigns @activity' do
        expect(assigns :activity).to eq graetzl.activity.page(2).per(12)
      end

      it 'does not assign @map_data' do
        expect(assigns :map_data).not_to be
      end

      it 'does not assign @activity_decorated' do
        expect(assigns :activity_decorated).not_to be
      end

      it 'renders show.js' do
        expect(response.content_type).to eq 'text/javascript'
        expect(response).to render_template(:show)
      end
    end
  end
end
