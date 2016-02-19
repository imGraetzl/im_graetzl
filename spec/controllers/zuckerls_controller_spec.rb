require 'rails_helper'

RSpec.describe ZuckerlsController, type: :controller do
  before do
    allow_any_instance_of(Zuckerl).to receive(:send_booking_confirmation)
  end

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

  describe 'POST create' do
    let(:user) { create :user }
    let(:location) { create(:location, state: Location::states[:approved]) }

    before do
      create(:location_ownership, user: user, location: location)
      sign_in user
    end

    context 'with valid params' do
      let(:params) {
        { location_id: location.id, zuckerl: attributes_for(:zuckerl) }
      }

      it 'creates new zuckerl record' do
        expect{
          post :create, params
        }.to change{Zuckerl.count}.by 1
      end

      it 'renders booking_address form' do
      end
    end
    context 'with invalid params' do
      let(:params) {
        { location_id: location.id, zuckerl: attributes_for(:zuckerl, title: '') }
      }

      it 'does not create new zuckerl record' do
        expect{
          post :create, params
        }.not_to change{Zuckerl.count}
      end

      it 'renders :new' do
        post :create, params
        expect(response).to render_template :new
      end
    end
  end
end
