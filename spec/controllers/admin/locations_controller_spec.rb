require 'rails_helper'

RSpec.describe Admin::LocationsController, type: :controller do
  let(:admin) { create(:user_admin) }

  before { sign_in admin }

  describe 'PUT approve' do
    context 'when pending location' do
      let!(:location) { create(:location_pending) }

      it 'changes state to managed' do
        expect{
          put :approve, id: location
        }.to change{ location.reload.state }.to 'managed'
      end

      it 'redirects to admin_location with flash[:success]' do
        put :approve, id: location
        expect(response).to redirect_to admin_location_path(location)
        expect(flash[:success]).to be_present
      end
    end

    context 'when basic location' do
      let!(:location) { create(:location_basic) }

      it 'does not change state' do
        expect{
          put :approve, id: location
        }.not_to change(location.reload, :state)
      end

      it 'redirects to admin_location with flash[:error]' do
        put :approve, id: location
        expect(response).to redirect_to admin_location_path(location)
        expect(flash[:error]).to be_present
      end
    end

    context 'when managed location' do
      let!(:location) { create(:location_managed) }

      it 'does not change state' do
        expect{
          put :approve, id: location
        }.not_to change(location.reload, :state)
      end

      it 'redirects to admin_location with flash[:error]' do
        put :approve, id: location
        expect(response).to redirect_to admin_location_path(location)
        expect(flash[:error]).to be_present
      end
    end
  end
end