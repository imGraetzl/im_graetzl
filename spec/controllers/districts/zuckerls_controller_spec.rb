require 'rails_helper'
require 'controllers/shared/district_context'

RSpec.describe Districts::ZuckerlsController, type: :controller do

  it_behaves_like :a_district_controller

  describe 'GET index' do
    let(:district) { create(:district, area: 'POLYGON ((0.0 0.0, 0.0 1.0, 1.0 1.0, 1.0 0.0, 0.0 0.0))') }
    let(:graetzl_1) { create(:graetzl, area: 'POLYGON ((0.5 0.5, 0.5 0.7, 0.7 0.7, 0.5 0.5))') }
    let(:graetzl_2) { create(:graetzl, area: 'POLYGON ((0.8 0.8, 0.8 1.1, 0.8 1.1, 0.8 0.8))') }

    before do
      allow_any_instance_of(Zuckerl).to receive(:send_booking_confirmation)
      create_list(:zuckerl, 20, :live,
        location: create(:location, graetzl: [graetzl_1, graetzl_2].sample))
    end

    context 'when html request' do
      before { get :index, params: { district_id: district } }

      it 'assigns @district' do
        expect(assigns :district).to eq district
      end

      it 'assigns @map_data' do
        expect(assigns :map_data).to be
      end

      it 'assigns 15 @zuckerls' do
        expect(assigns(:zuckerls).size).to eq 15
      end

      it 'renders /districts/zuckerls/index.html' do
        expect(response.content_type).to eq 'text/html'
        expect(response).to render_template('districts/zuckerls/index')
      end
    end
    context 'when js request with page param' do
      before { get :index, params: { district_id: district, page: 2 }, xhr: true }

      it 'assigns @district' do
        expect(assigns :district).to eq district
      end

      it 'assigns 5 @zuckerls' do
        expect(assigns(:zuckerls).size).to eq 5
      end

      it 'does not assign @map_data' do
        expect(assigns :map_data).not_to be
      end

      it 'renders /districts/zuckerls/index.js' do
        expect(response.content_type).to eq 'text/javascript'
        expect(response).to render_template('districts/zuckerls/index')
      end
    end
  end
end
