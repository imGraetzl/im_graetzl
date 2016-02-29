require 'rails_helper'

RSpec.describe Users::ZuckerlsController, type: :controller do
  before { allow_any_instance_of(Zuckerl).to receive(:send_booking_confirmation) }

  describe 'GET index' do
    context 'when logged out' do
      before { get :index }

      it 'returns a 302 found status' do
        expect(response).to have_http_status 302
      end

      it 'redirects to login' do
        expect(response).to render_template(session[:new])
        expect(flash[:alert]).to be_present
      end
    end
    context 'when logged in' do
      let(:user) { create :user }
      let(:location) { create :location, state: Location.states[:approved] }
      let!(:ownership) { create :location_ownership, user: user, location: location }
      let!(:zuckerls) { create_list(:zuckerl, 3, location: location) }

      before do
        sign_in user
        get :index
      end

      it 'returns a 200 ok status' do
        expect(response).to have_http_status 200
      end

      it 'assigns @zuckerls' do
        expect(assigns(:zuckerls).pluck(:id)).to match_array zuckerls.map(&:id)
      end

      it 'renders :index' do
        expect(response).to render_template('users/zuckerls/index')
      end
    end
  end
end
