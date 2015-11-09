require 'rails_helper'

RSpec.describe Districts::LocationsController, type: :controller do

  describe 'GET index' do
    let(:district) { create(:district) }
    let(:graetzl) { create(:graetzl) }
    let!(:pending_location) { create(:location, graetzl: graetzl, state: Location.states[:pending]) }

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

      it 'returns only approved locations' do
        expect(district.graetzls).to include graetzl
        expect(assigns(:locations)).not_to include pending_location
      end

      it 'renders /districts/locations/index.html' do
        expect(response['Content-Type']).to eq 'text/html; charset=utf-8'
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

      it 'returns only approved locations' do
        expect(district.graetzls).to include graetzl
        expect(assigns(:locations)).not_to include pending_location
      end

      it 'renders /districts/locations/index' do
        expect(response.header['Content-Type']).to include('text/javascript')
        expect(response).to render_template('districts/locations/index')
      end

    end
  end
end
