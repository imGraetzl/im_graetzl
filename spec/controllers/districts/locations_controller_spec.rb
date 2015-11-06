require 'rails_helper'

RSpec.describe Districts::LocationsController, type: :controller do

  describe 'GET index' do
    let(:district) { create(:district) }
    let(:graetzl) { create(:graetzl) }
    let!(:pending_location) { create(:location, graetzl: graetzl, state: Location.states[:pending]) }
    before { get :index, district_id: district }

    it 'returns a 200 OK status' do
      expect(response).to be_success
    end

    it 'assigns @district' do
      expect(assigns(:district)).to eq district
    end

    it 'assigns @locations' do
      expect(assigns(:locations)).to be
    end

    it 'returns only approved locations' do
      expect(district.graetzls).to include graetzl
      expect(assigns(:locations)).not_to include pending_location
    end

    it 'renders /districts/locations/index' do
      expect(response).to render_template('districts/locations/index')
    end
  end
end
