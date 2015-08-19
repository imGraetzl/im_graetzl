require 'rails_helper'

RSpec.describe Admin::LocationsController, type: :controller do
  let(:graetzl) { create(:graetzl) }
  let(:admin) { create(:user_admin, graetzl: graetzl) }

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

  describe 'PUT update' do
    let!(:location) { create(:location_managed) }
    let(:params) {
      {
        id: location,
        location: location.attributes.merge(state: location.state)
      }
    }

    describe 'basic attributes' do
      describe 'graetzl' do
        let!(:new_graetzl) { create(:graetzl) }

        before do
          params[:location].merge!({ graetzl_id: new_graetzl.id })
          put :update, params
        end

        it 'changes graetzl' do
          expect(location.reload.graetzl).to eq new_graetzl
        end
      end

      describe 'state' do
        before do
          params[:location].merge!({ state: 'basic' })
        end

        it 'changes state' do
          expect{
            put :update, params
          }.to change{location.reload.state}.to 'basic'
        end
      end

      describe 'slug' do
        before do
          params[:location].merge!({ slug: 'new-slug' })
        end

        it 'changes slug' do
          expect{
            put :update, params
          }.to change{location.reload.slug}.to 'new-slug'
        end
      end
    end

    describe 'location_ownerships' do
      let!(:new_user) { create(:user_business) }

      context 'add user' do
        before do
          params[:location].merge!({ location_ownerships_attributes: {'0' => { user_id: new_user.id }}})
        end

        it 'creates new location_ownership record' do
          expect{
            put :update, params
          }.to change(LocationOwnership, :count).by(1)
        end

        it 'adds user to location' do
          put :update, params
          expect(location.reload.users).to include(new_user)
        end
      end

      context 'remove user' do
        let!(:location_ownership) { create(:location_ownership, user: new_user, location: location) }

        before do
          params[:location].merge!({ location_ownerships_attributes:
            { '0' => { id: location_ownership.id, user_id: new_user.id, _destroy: 1 } } })
        end

        it 'deletes location_ownership record' do
          expect{
            put :update, params
          }.to change(LocationOwnership, :count).by(-1)
        end

        it 'removes user from location' do
          expect(location.users). to include(new_user)
          put :update, params
          expect(location.reload.users).not_to include(new_user)
        end
      end
    end
  end

  describe 'POST :new_from_address' do
    let!(:address) { create(:address, description: 'name', coordinates: 'POINT (1.00 1.00)') }

    before { post :new_from_address, address: address }

    it 'renders :new_from_address' do
      expect(response).to render_template(:new_from_address)
    end

    describe '@location' do
      subject(:location) { assigns(:location) }

      it 'has address.description as name' do
        expect(location.name).to eq address.description
      end

      it 'has address.graetzl as graetzl' do
        expect(location.graetzl).to eq graetzl
      end

      it 'is basic' do
        expect(location.basic?).to eq true
      end

      it 'has contact' do
        expect(location.contact).not_to eq nil
      end

      describe 'address' do
        subject(:location_address) { location.address }

        it 'has address attributes' do
          expect(location_address).to have_attributes(
            street_name: address.street_name,
            street_number: address.street_number,
            zip: address.zip,
            city: address.city,
            coordinates: address.coordinates)
        end

        it 'has no description' do
          expect(location_address.description).to be_nil
        end
      end
    end
  end
end