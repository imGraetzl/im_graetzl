require 'rails_helper'

RSpec.describe Districts::LocationsController, type: :controller do

  describe 'GET index' do
    let(:district) { create(:district) }
    before { get :index, district_id: district }

    it 'returns a 200 OK status' do
      expect(response).to be_success
    end

    it 'assigns @district' do
      expect(assigns(:district)).to eq district
    end

    it 'assigns @locations' do
      expect(assigns(:locations)).to eq district.locations
    end

    it 'renders /districts/locations/index' do
      expect(response).to render_template('districts/locations/index')
    end
  end
end
