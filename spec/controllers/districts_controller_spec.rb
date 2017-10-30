require 'rails_helper'

RSpec.describe DistrictsController, type: :controller do
  render_views

  describe 'GET show' do
    let(:district) { create :district }

    before { get :show, params: { id: district } }

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

    before { get :graetzls, params: { id: district, format: :json } }

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
