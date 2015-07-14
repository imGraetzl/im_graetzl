require 'rails_helper'
include GeojsonSupport

RSpec.describe LocationsController, type: :controller do
  let(:graetzl) { create(:graetzl) }

  describe 'GET address' do
    context 'when authorized user' do
      let(:user) { create(:user, role: :business) }

      before do
        sign_in user
        get :new_address, graetzl_id: graetzl
      end

      it 'returns a 200 OK status' do
        expect(response).to be_success
      end

      it 'assigns @graetzl' do
        expect(assigns(:graetzl)).to eq graetzl
      end

      it 'renders address form' do
        expect(response).to render_template(:new_address)
      end
    end

    context 'when unauthorized user (logged in)' do
      let(:user) { create(:user) }

      before do
        sign_in user
        get :new_address, graetzl_id: graetzl
      end

      it 'redirects to @graetzl' do
        expect(response).to redirect_to graetzl
      end
    end    

    context 'when unauthorized user (logged out)' do
      it 'redirects to login' do
        get :new_address, graetzl_id: graetzl
        expect(response).to render_template(session[:new])
      end
    end
  end

  describe 'POST address' do
    let(:user) { create(:user, role: :business) }

    context 'without :address and :feature param' do
      let(:params) { { graetzl_id: graetzl, address: '' } }

      before do
        sign_in user
        post :set_new_address, params
      end

      it 'stores address in session' do
        expect(session[:address]).not_to be_nil
      end

      it 'stores empty address' do
        attrs = Address.new.attributes
        expect(session[:address].values).to all be_nil
        expect(session[:address]).to eq attrs
      end

      it 'does not assign new @graetzl' do
        expect(assigns(:graetzl)).to eq graetzl
      end

      it 'assigns empty @locations' do
        expect(assigns(:locations)).to be_empty
      end

      it 'redirects to new_location in graetzl' do
        expect(response).to redirect_to new_graetzl_location_path(graetzl)
      end
    end

    context 'with empty :feature param' do
      let(:params) { { graetzl_id: graetzl, address: '', feature: '' } }

      before do
        sign_in user
        post :set_new_address, params
      end

      it 'stores address in session' do
        expect(session[:address]).not_to be_nil
      end

      it 'stores empty address' do
        attrs = Address.new.attributes
        expect(session[:address].values).to all be_nil
        expect(session[:address]).to eq attrs
      end

      it 'does not assign new @graetzl' do
        expect(assigns(:graetzl)).to eq graetzl
      end

      it 'assigns empty @locations' do
        expect(assigns(:locations)).to be_empty
      end

      it 'redirects to new_location in graetzl' do
        expect(response).to redirect_to new_graetzl_location_path(graetzl)
      end
    end

    context 'with valid :feature param' do
      let!(:new_graetzl) { create(:graetzl,
        area: 'POLYGON ((0.0 0.0, 0.0 2.0, 2.0 2.0, 2.0 0.0, 0.0 0.0))') }
      let(:params) { { graetzl_id: graetzl, address: '', feature: feature_hash(1,1).to_json } }

      before do
        sign_in user
        post :set_new_address, params
      end

      it 'stores address in session' do
        expect(session[:address]).not_to be_nil
      end

      it 'stores address from feature' do
        attrs = feature_hash(1,1)['properties']
        expect(session[:address]['coordinates'].as_text).to eq 'POINT (1.0 1.0)'
        expect(session[:address]['street_name']).to eq attrs['StreetName']
      end

      it 'assigns new @graetzl' do
        expect(assigns(:graetzl)).to eq new_graetzl
      end

      context 'when no locations nearby' do

        it 'assigns empty @locations' do
          expect(assigns(:locations)).to be_empty
        end

        it 'redirects to new_location in new_graetzl' do
          expect(response).to redirect_to new_graetzl_location_path(new_graetzl)
        end
      end

      context 'when locations nearby' do
        let!(:location_1) { create(:location,
          address: build(:address, coordinates: 'POINT (1.5 1.5)'),
          graetzl: new_graetzl) }   
        let!(:location_2) { create(:location,
          address: build(:address, coordinates: 'POINT (1.7 1.7)'),
          graetzl: new_graetzl) }   
        let!(:other_location) { create(:location,
          address: build(:address, coordinates: 'POINT (201 201)'),
          graetzl: graetzl) }

        before { post :set_new_address, params }

        it 'assigns @locations' do
          expect(assigns(:locations)).not_to be_empty
        end

        it 'assigns @locations to contain nearby locations' do
          expect(assigns(:locations)).to include(location_1, location_2)
        end

        it 'assigns @locations to not contain other locations' do
          expect(assigns(:locations)).not_to include(other_location)
        end

        it 'renders :new_adopt' do
          expect(response).to render_template(:new_adopt)
        end
      end      

      context 'when no locations nearby' do
        let!(:other_location) { create(:location,
          address: build(:address, coordinates: 'POINT (201 201)'),
          graetzl: graetzl) }

        before { post :set_new_address, params }

        it 'assigns empty @locations' do
          expect(assigns(:locations)).to be_empty
        end

        it 'redirects to new_location in new_graetzl' do
          expect(response).to redirect_to new_graetzl_location_path(new_graetzl)
        end
      end
    end
  end

  describe 'GET new' do
    let(:user) { create(:user, role: :business) }

    context 'when no address in session' do
      before do
        sign_in user
        get :new, graetzl_id: graetzl
      end

      it 'returns a 200 OK status' do
        expect(response).to be_success
      end

      it 'assigns @location' do
        expect(assigns(:location)).not_to be_nil
      end

      it 'assigns @location with empty address' do
        attrs = Address.new(addressable_type: 'Location').attributes
        expect(assigns(:location).address.attributes).to eq attrs
      end

      it 'assigns @location with empty contact' do
        attrs = Contact.new.attributes
        expect(assigns(:location).contact.attributes).to eq attrs
      end

      it 'renders :new' do
        expect(response).to render_template(:new)
      end
    end

    context 'when address in session' do
      let(:address) { build(:address, addressable_type: 'Location') }

      before do
        sign_in user
        session[:address] = address.attributes
        get :new, graetzl_id: graetzl
      end

      it 'returns a 200 OK status' do
        expect(response).to be_success
      end

      it 'assigns @location with address' do
        expect(assigns(:location).address.attributes).to eq address.attributes
      end
    end
  end
end
