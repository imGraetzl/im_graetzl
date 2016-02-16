require 'rails_helper'

RSpec.describe ZuckerlsController, type: :controller do
  describe 'GET new' do
    context 'when logged out' do
      it 'redirects to login' do
        get :new
        expect(response).to render_template(session[:new])
      end
    end
    context 'when logged in' do
      let(:user) { create :user }
      before { sign_in user }

      context 'with location_id' do
        let(:location) { create :location, state: Location::states[:approved] }
        before do
          create(:location_ownership, user: user, location: location)
          get :new, location_id: location
        end

        it 'assigns @location' do
          expect(assigns(:location)).to eq location
        end

        it 'renders :new' do
          expect(response).to render_template :new
        end
      end
      context 'when user owns single location' do
        let(:location) { create :location, state: Location::states[:approved] }
        before do
          create(:location_ownership, user: user, location: location)
          get :new
        end

        it 'assigns @location' do
          expect(assigns(:location)).to eq location
        end

        it 'renders :new' do
          expect(response).to render_template :new
        end
      end
      context 'when user owns multiple locations' do
        before do
          create_list(:location_ownership, 3,
            user: user,
            location: create(:location, state: Location::states[:approved]))
          get :new
        end

        it 'assigns @locations' do
          expect(assigns :locations).to eq user.locations
        end

        it 'renders :new_location' do
          expect(response).to render_template :new_location
        end
      end
    end
  end
end
