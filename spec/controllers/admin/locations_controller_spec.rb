require 'rails_helper'

RSpec.describe Admin::LocationsController, type: :controller do
  let(:admin) { create(:user, role: User.roles[:admin]) }

  before { sign_in admin }

  describe 'GET index' do
    before { get :index }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @locations' do
      expect(assigns(:locations)).not_to be_nil
    end

    it 'renders :index' do
      expect(response).to render_template(:index)
    end
  end

  describe 'GET show' do
    let(:location) { create(:location) }
    before { get :show, id: location }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @location' do
      expect(assigns(:location)).to eq location
    end

    it 'renders :show' do
      expect(response).to render_template(:show)
    end
  end

  describe 'GET new' do
    before { get :new }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @location' do
      expect(assigns(:location)).to be_a_new(Location)
    end

    it 'renders :new' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST create' do
    let(:location) { build(:location, graetzl: create(:graetzl)) }
    let(:params) {
      {
        location: {
          graetzl_id: location.graetzl.id,
          name: location.name,
          slogan: location.slogan,
          description: location.description,
          state: location.state
        }
      }
    }

    context 'with basic attributes' do

      it 'creates new location record' do
        expect{
          post :create, params
        }.to change{Location.count}.by(1)
      end

      it 'assigns attributes to location' do
        post :create, params
        l = Location.last
        expect(l).to have_attributes(
          graetzl_id: location.graetzl.id,
          name: location.name,
          slogan: location.slogan,
          description: location.description,
          state: location.state)
      end

      it 'redirects_to new location page' do
        post :create, params
        new_location = Location.last
        expect(response).to redirect_to(admin_location_path(new_location))
      end
    end

    context 'with address, contact and ownerships' do
      let(:address) { build(:address) }
      let(:contact) { build(:contact) }
      let(:ownership_1) { build(:location_ownership, user: create(:user)) }
      let(:ownership_2) { build(:location_ownership, user: create(:user)) }
      before do
        params[:location].merge!(address_attributes: {
          street_name: address.street_name,
          street_number: address.street_number,
          zip: address.zip,
          city: address.city,
          coordinates: address.coordinates
          })
        params[:location].merge!(contact_attributes: {
          website: contact.website,
          email: contact.email,
          phone: contact.phone
          })
        params[:location].merge!(location_ownerships_attributes: {
          '0' => {
              user_id: ownership_1.user_id,
              state: ownership_1.state
            },
          '1' => {
              user_id: ownership_2.user_id,
              state: ownership_2.state
            },
          })
      end

      it 'creates new location record' do
        expect{
          post :create, params
        }.to change{Location.count}.by(1)
      end

      it 'creates new address record' do
        expect{
          post :create, params
        }.to change{Address.count}.by(1)
      end

      it 'creates new contact record' do
        expect{
          post :create, params
        }.to change{Contact.count}.by(1)
      end

      it 'creates new ownership record' do
        expect{
          post :create, params
        }.to change{LocationOwnership.count}.by(2)
      end

      describe 'new location' do
        before { post :create, params }
        subject(:new_location) { Location.last }

        it 'is has address' do
          expect(new_location.address).not_to be_nil
        end

        it 'is has contact' do
          expect(new_location.contact).not_to be_nil
        end

        it 'assigns address_attributes to location' do
          expect(Address.last).to have_attributes(
            street_name: address.street_name,
            street_number: address.street_number,
            zip: address.zip,
            city: address.city,
            coordinates: address.coordinates)
        end

        it 'assigns contact_attributes to location' do
          expect(Contact.last).to have_attributes(
            website: contact.website,
            phone: contact.phone,
            email: contact.email)
        end
      end
    end
  end

  describe 'GET edit' do
    let(:location) { create(:location) }
    before { get :edit, id: location }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @location' do
      expect(assigns(:location)).to eq location
    end

    it 'renders :edit' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'PUT update' do
    let!(:location) { create(:location) }
    let(:new_location) { build(:location,
                        graetzl: create(:graetzl),
                        allow_meetings: false) }
    let(:params) {
      {
        id: location,
        location: {
          graetzl_id: new_location.graetzl.id,
          name: new_location.name,
          state: new_location.state,
          slogan: new_location.slogan,
          allow_meetings: new_location.allow_meetings,
          description: new_location.description}
      }
    }

    context 'with basic attributes' do
      before do
        put :update, params
        location.reload
      end

      it 'redirects to location page' do
        expect(response).to redirect_to(admin_location_path(location))
      end

      it 'updates location attributes' do
        expect(location).to have_attributes(
          graetzl_id: new_location.graetzl.id,
          name: new_location.name,
          state: new_location.state,
          slogan: new_location.slogan,
          allow_meetings: new_location.allow_meetings,
          description: new_location.description)
      end
    end

    context 'destroy address' do
      before do
        params[:location].merge!(address_attributes: {
          id: location.address.id,
          _destroy: 1})
      end

      it 'removes address from location' do
        expect(location.address).to be_present
        put :update, params
        location.reload
        expect(location.address).not_to be_present
      end

      it 'deletes address record' do
        expect{
          put :update, params
        }.to change{Address.count}.by(-1)
      end
    end

    context 'with ownerships' do
      describe 'add ownership' do
        let!(:user) { create(:user) }
        before do
          params[:location].merge!(location_ownerships_attributes: {
            '0' => { user_id: user.id }
            })
        end

        it 'creates new ownership record' do
          expect{
            put :update, params
          }.to change(LocationOwnership, :count).by(1)
        end

        it 'adds user to location' do
          put :update, params
          expect(location.reload.users).to include(user)
        end
      end
    end

    describe 'remove user' do
      let!(:ownership) { create(:location_ownership, location: location) }
      before do
        params[:location].merge!(location_ownerships_attributes: {
          '0' => { id: ownership.id, _destroy: 1 }
          })

        it 'destroys ownership record' do
          expect(LocationOwnership.count).to eq 1
          expect{
            put :update, params
          }.to change(LocationOwnership, :count).by(-1)
        end

        it 'removes user from location' do
          expect(location.users). to include(new_user)
          put :update, params
          location.reload
          expect(location.users).not_to include(new_user)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:location) { create(:location) }

    it 'deletes location record' do
      expect{
        delete :destroy, id: location
      }.to change{Location.count}.by(-1)
    end

    it 'redirects_to index page' do
      delete :destroy, id: location
      expect(response).to redirect_to(admin_locations_path)
    end
  end

  describe 'PUT approve' do
    context 'when pending location' do
      let!(:location) { create(:location, state: Location.states[:pending]) }

      it 'changes state to approved' do
        expect{
          put :approve, id: location
          location.reload
        }.to change{location.state}.from('pending').to('approved')
      end

      it 'redirects to index with flash[:success]' do
        put :approve, id: location
        expect(response).to redirect_to admin_locations_path
        expect(flash[:success]).to be_present
      end
    end

    context 'when approved location' do
      let!(:location) { create(:location, state: Location.states[:approved]) }

      it 'does not change state' do
        expect{
          put :approve, id: location
          location.reload
        }.not_to change(location, :state)
      end

      it 'redirects to location page with flash[:error]' do
        put :approve, id: location
        expect(response).to redirect_to admin_location_path(location)
        expect(flash[:error]).to be_present
      end
    end
  end

  describe 'PUT reject' do
    context 'when pending location' do
      let!(:location) { create(:location) }

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

    context 'when approved location' do
      let!(:location) { create(:location, state: Location.states[:approved]) }

      it 'does not change state' do
        expect{
          put :reject, id: location
          location.reload
        }.not_to change(location, :state)
      end

      it 'redirects to admin_location with flash[:error]' do
        put :reject, id: location
        expect(response).to redirect_to admin_location_path(location)
        expect(flash[:error]).to be_present
      end
    end
  end

  describe 'POST :new_from_address' do
    let!(:graetzl) { create(:graetzl,
      area: 'POLYGON ((20.0 20.0, 20.0 25.0, 25.0 25.0, 25.0 20.0, 20.0 20.0))') }
    let!(:address) { create(:address, description: 'name', coordinates: 'POINT (21.00 21.00)') }

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

      it 'is approved' do
        expect(location.approved?).to eq true
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
