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
      before do
        sign_in create(:user)
        get :new, location_id: location
      end

      it_behaves_like :meetings_new

      it 'assigns @parent with location' do
        expect(assigns :parent).to eq location
      end

      it 'assigns @meeting without address' do
        expect(assigns :meeting).to have_attributes(
          graetzl_id: graetzl.id,
          location_id: location.id,
          address: nil)
      end
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
      let(:location) { create :location, :approved, graetzl: graetzl }

      before { sign_in user }

      context 'with address' do
        let(:params) {
          { location_id: location,
            meeting: attributes_for(:meeting,
              graetzl_id: graetzl.id,
              address_attributes: attributes_for(:address)) }}

        it_behaves_like :meetings_create

        it 'assigns @parent to location' do
          post :create, params
          expect(assigns :parent).to eq location
        end

        it 'creates new address' do
          expect{
            post :create, params
          }.to change{Address.count}.by 1
        end
      end
      context 'without address' do
        let(:params) {
          { location_id: location,
            meeting: attributes_for(:meeting, graetzl_id: graetzl.id) }}

        it_behaves_like :meetings_create

        it 'assigns @parent to location' do
          post :create, params
          expect(assigns :parent).to eq location
        end

        it 'does not create address' do
          expect{
            post :create, params
          }.not_to change{Address.count}
        end
      end
    end
  end
end
