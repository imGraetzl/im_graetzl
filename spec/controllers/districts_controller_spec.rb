require 'rails_helper'

RSpec.describe DistrictsController, type: :controller do
  render_views

  describe 'GET index' do
    context 'when html request' do
      before { get :index }

      it 'renders index.html' do
        expect(response['Content-Type']).to eq 'text/html; charset=utf-8'
        expect(response).to render_template(:index)
      end

      it 'assigns @districts' do
        expect(assigns :districts).to be_truthy
      end

      it 'assigns @map_data' do
        expect(assigns :map_data).to be_truthy
      end

      it 'assigns @meetings' do
        expect(assigns :meetings).to be_truthy
      end
    end
    context 'when js request' do
      before { xhr :get, :index, page: 2 }

      it 'does not assign @districts' do
        expect(assigns :districts).not_to be
      end

      it 'does not assign @map_data' do
        expect(assigns :map_data).not_to be
      end

      it 'assigns @meetings' do
        expect(assigns :meetings).to be
      end

      it 'renders index.js' do
        expect(response.header['Content-Type']).to include('text/javascript')
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET show' do
    let(:district) { create :district }

    before { get :show, id: district }

    it 'assigns @district' do
      expect(assigns :district).to eq district
    end

    it 'assigns @map_data' do
      expect(assigns :map_data).to be
    end

    it 'assigns @meetings' do
      expect(assigns :meetings).to be
    end

    it 'assigns @locations' do
      expect(assigns :locations).to be
    end

    it 'renders #show' do
      expect(response).to render_template(:show)
    end
  end

  describe 'GET graetzls' do
    let(:district) { create(:district,
      area: 'POLYGON ((0.0 0.0, 0.0 10.0, 10.0 10.0, 10.0 0.0, 0.0 0.0))')}
    let!(:graetzl_1) { create(:graetzl,
      area: 'POLYGON ((1.0 1.0, 1.0 5.0, 5.0 5.0, 5.0 1.0, 1.0 1.0))') }
    let!(:graetzl_2) { create(:graetzl,
      area: 'POLYGON ((5.0 5.0, 5.0 6.0, 6.0 6.0, 6.0 5.0, 5.0 5.0))') }

    before { get :graetzls, id: district, format: :json }

    it 'assigns @district' do
      expect(assigns(:district)).to eq district
    end

    it 'responds with json' do
      expect(response.content_type).to eq('application/json')
    end

    it 'returns id and name of each graetzl' do
      graetzls = JSON.parse(response.body)
      expect(graetzls).to include({'id' => graetzl_1.id, 'name' => graetzl_1.name},
                                  {'id' => graetzl_2.id, 'name' => graetzl_2.name})
    end
  end
end
