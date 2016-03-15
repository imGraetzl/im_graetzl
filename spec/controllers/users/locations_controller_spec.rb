require 'rails_helper'

RSpec.describe Users::LocationsController, type: :controller do
  describe 'GET index' do
    context 'when logged out' do
      it 'redirects to login with flash' do
        get :index
        expect(response).to redirect_to new_user_session_path
        expect(flash[:alert]).to be_present
      end
    end
    context 'when logged in' do
      let(:user) { create(:user) }
      let!(:locations) { create_list :location, 3, users: [user] }

      before do
        sign_in user
        get :index
      end

      it 'assigns @locations' do
        expect(assigns :locations).to match_array locations
      end

      it 'renders :index' do
        expect(response).to render_template(:index)
      end
    end
  end
end
