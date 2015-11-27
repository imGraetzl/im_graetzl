require 'rails_helper'

RSpec.describe Districts::LocationsController, type: :controller do

  # stub GeoJSONService calls
  before { allow_any_instance_of(GeoJSONService).to receive(:map_data).and_return({}.to_json) }

  describe 'GET index' do
    let(:district) { create(:district) }
    let(:graetzl) { create(:graetzl) }
    before { allow_any_instance_of(District).to receive(:graetzls).and_return([graetzl]) }

    context 'when html request' do
      before { get :index, district_id: district }

      it 'returns a 200 OK status' do
        expect(response).to be_success
      end

      it 'assigns @district' do
        expect(assigns(:district)).to eq district
      end

      it 'assigns @map_data' do
        expect(assigns(:map_data)).to be
      end

      it 'assigns @locations' do
        expect(assigns(:locations)).to be
      end

      it 'renders /districts/locations/index.html' do
        expect(response.content_type).to eq 'text/html'
        expect(response).to render_template('districts/locations/index')
      end
    end

    context 'when js request' do
      before { xhr :get, :index, district_id: district }

      it 'assigns @district' do
        expect(assigns(:district)).to eq district
      end

      it 'does not assign @map_data' do
        expect(assigns(:map_data)).not_to be
      end

      it 'assigns @locations' do
        expect(assigns(:locations)).to be
      end

      it 'renders /districts/locations/index' do
        expect(response.header['Content-Type']).to include('text/javascript')
        expect(response).to render_template('districts/locations/index')
      end
    end
  end
end
