require 'rails_helper'
require 'controllers/shared/meetings_controller'

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

      it_behaves_like :meetings_new
    end
  end
  describe 'POST create' do
    context 'when logged out' do
      it 'redirects to login' do
        post :create, location_id: 1
        expect(response).to render_template(session[:new])
      end
    end
    context 'when logged in' do
      let(:user) { create :user }
      let(:graetzl) { create :graetzl }
      before { sign_in user }

      context 'when owner of location' do
      end
      context 'when not owner of location' do
        let(:location) { create :location,  :approved, graetzl: graetzl }
        let(:params) {{ location_id: location, meeting: attributes_for(:meeting, graetzl_id: graetzl.id) }}

        it_behaves_like :meetings_create

        it 'assigns @parent to location' do
          post :create, params
          expect(assigns :parent).to eq location
        end

        it 'assigns new @meeting' do
          post :create, params
          expect(assigns :meeting).to be_a Meeting
        end
      end
    end
  end
end
