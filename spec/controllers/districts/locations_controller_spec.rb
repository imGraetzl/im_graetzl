require 'rails_helper'
require 'controllers/shared/district_context'

RSpec.describe Districts::LocationsController, type: :controller do

  it_behaves_like :a_district_controller
  
  describe 'GET index' do
    let(:district) { create(:district) }

    context 'when html request' do
      before { get :index, district_id: district }

      it 'assigns @district' do
        expect(assigns :district).to eq district
      end

      it 'assigns @map_data' do
        expect(assigns :map_data).to be
      end

      it 'assigns @locations' do
        expect(assigns :locations).to be
      end

      it 'renders /districts/locations/index.html' do
        expect(response.content_type).to eq 'text/html'
        expect(response).to render_template('districts/locations/index')
      end
    end

    context 'when js request' do
      before { xhr :get, :index, district_id: district, page: 2 }

      it 'assigns @district' do
        expect(assigns :district).to eq district
      end

      it 'does not assign @map_data' do
        expect(assigns :map_data).not_to be
      end

      it 'assigns @locations' do
        expect(assigns :locations).to be
      end

      it 'renders /districts/locations/index' do
        expect(response.header['Content-Type']).to include('text/javascript')
        expect(response).to render_template('districts/locations/index')
      end
    end
  end
end
