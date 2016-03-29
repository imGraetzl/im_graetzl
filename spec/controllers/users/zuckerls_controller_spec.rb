require 'rails_helper'

RSpec.describe Users::ZuckerlsController, type: :controller do
  before { allow_any_instance_of(Zuckerl).to receive(:send_booking_confirmation) }

  describe 'GET index' do
    context 'when logged out' do
      it 'redirects to login' do
        get :index
        expect(response).to redirect_to new_user_session_path
        expect(flash[:alert]).to be_present
      end
    end
    context 'when logged in' do
      let(:user) { create :user }
      let(:location) { create :location, :approved }
      let!(:ownership) { create :location_ownership, user: user, location: location }
      let!(:zuckerls) { create_list :zuckerl, 3, location: location }
      let!(:cancelled_zuckerl) { create :zuckerl, :cancelled, location: location }

      before do
        sign_in user
        get :index
      end

      it 'assigns @zuckerls' do
        expect(assigns :zuckerls).to match_array zuckerls
      end

      it 'ignores cancelled zuckerls' do
        expect(assigns :zuckerls).not_to include cancelled_zuckerl
      end

      it 'renders :index' do
        expect(response).to render_template('users/zuckerls/index')
      end
    end
  end
end
