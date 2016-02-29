require 'rails_helper'
include GeojsonSupport

RSpec.describe Users::LocationsController, type: :controller do
  before(:each) do
    request.env['HTTP_REFERER'] = 'where_i_came_from'
  end

  describe 'GET index' do
    context 'when logged out' do
      it 'redirects to login with flash' do
        get :index
        expect(response).to render_template(session[:new])
        expect(flash[:alert]).to be_present
      end
    end
    context 'when logged in' do
      let!(:user) { create(:user) }
      before do
        sign_in user
        3.times { location = create(:location, users: [user]) }
        get :index
      end

      it 'assigns @locations' do
        expect(assigns(:locations)).to be_present
        expect(assigns(:locations).size).to eq 3
      end

      it 'renders :index' do
        expect(response).to render_template(:index)
      end
    end
  end
end
