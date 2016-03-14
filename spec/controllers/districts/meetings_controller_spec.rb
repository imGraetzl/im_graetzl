require 'rails_helper'
require 'controllers/shared/district_context'

RSpec.describe Districts::MeetingsController, type: :controller do

  it_behaves_like :a_district_controller

  describe 'GET index' do
    let(:district) { create(:district, area: 'POLYGON ((0.0 0.0, 0.0 1.0, 1.0 1.0, 1.0 0.0, 0.0 0.0))') }
    let(:graetzl) { create(:graetzl, area: 'POLYGON ((0.5 0.5, 0.5 0.7, 0.7 0.7, 0.5 0.5))') }

    before { create_list :meeting, 30, graetzl: graetzl }

    context 'when html request' do
      before { get :index, district_id: district }

      it 'assigns @district' do
        expect(assigns :district).to eq district
      end

      it 'assigns @map_data' do
        expect(assigns :map_data).to be
      end

      it 'assigns 14 @meetings' do
        expect(assigns(:meetings).size).to eq 14
      end

      it 'renders /districts/meetings/index.html' do
        expect(response['Content-Type']).to eq 'text/html; charset=utf-8'
        expect(response).to render_template('districts/meetings/index')
      end
    end

    context 'when js request with page param' do
      before { xhr :get, :index, district_id: district, page: 2 }

      it 'assigns @district' do
        expect(assigns :district).to eq district
      end

      it 'assigns 15 @meetings' do
        expect(assigns(:meetings).size).to eq 15
      end

      it 'does not assign @map_data' do
        expect(assigns(:map_data)).not_to be
      end

      it 'renders /districts/meetings/index.js' do
        expect(response.header['Content-Type']).to include('text/javascript')
        expect(response).to render_template('districts/meetings/index')
      end
    end
  end
end
