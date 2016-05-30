require 'rails_helper'
include GeojsonSupport

RSpec.describe Locations::MeetingsController, type: :controller do
  describe 'GET new' do
    let(:graetzl) { create :graetzl }
    let(:location) { create :location, :approved, graetzl: graetzl }

    context 'when logged out' do
      it 'redirects to login' do
        get :new, location_id: location
        expect(response).to render_template(session[:new])
      end
    end
    context 'when logged in' do
      let(:user) { create :user }
      before do
        sign_in user
        get :new, location_id: location
      end

      it 'assigns @parent with location' do
        expect(assigns :parent).to eq location
      end

      it 'assigns @meeting without adddress' do
        expect(assigns :meeting).to have_attributes(
          graetzl_id: graetzl.id,
          location_id: location.id,
          address: nil)
      end

      it 'renders meetings/new' do
        expect(response).to render_template 'meetings/new'
      end
    end
  end
end
