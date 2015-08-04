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

      it 'redirects to admin_locations with flash[:success]' do
        put :approve, id: location
        expect(response).to redirect_to admin_locations_path
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

  describe 'PUT reject' do
    context 'when pending location' do
      context 'with previous versions' do
        let(:location) { create(:location_basic, name: 'basic_name') }

        before do
          location.name = 'pending_name'
          location.pending!
        end

        it 'changes state to previous' do
          expect{
            put :reject, id: location
          }.to change{ location.reload.state }.to 'basic'
        end

        it 'changes attributes to previous' do
          expect{
            put :reject, id: location
          }.to change{ location.reload.name }.to 'basic_name'
        end

        it 'redirects to admin_locations with flash[:notice]' do
          put :reject, id: location
          expect(response).to redirect_to admin_locations_path
          expect(flash[:notice]).to be_present
        end
      end

      context 'without previous versions' do
        let!(:location) { create(:location_pending) }

        it 'destroys record' do
          expect{
            put :reject, id: location
          }.to change(Location, :count).by(-1)
        end

        it 'redirects to admin_locations with flash[:notice]' do
          put :reject, id: location
          expect(response).to redirect_to admin_locations_path
          expect(flash[:notice]).to be_present
        end
      end
    end

    context 'when non pending location' do
      let!(:location) { create(:location_basic) }

      it 'does not change state' do
        expect{
          put :reject, id: location
        }.not_to change(location.reload, :state)
      end

      it 'redirects to admin_location with flash[:error]' do
        put :reject, id: location
        expect(response).to redirect_to admin_location_path(location)
        expect(flash[:error]).to be_present
      end
    end
  end
end