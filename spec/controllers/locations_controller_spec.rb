require 'rails_helper'
include GeojsonSupport

RSpec.describe LocationsController, type: :controller do
  let(:graetzl) { create(:graetzl) }
  before(:each) do
    request.env['HTTP_REFERER'] = 'where_i_came_from'
  end

  # Shared Examples:
  shared_examples :an_unauthenticated_request do
    it 'redirects to login' do
      expect(response).to render_template(session[:new])
    end
  end

  shared_examples :an_unauthorized_request do
    it 'redirects back to previous page' do
      expect(response).to redirect_to 'where_i_came_from'
    end

    it 'shows flash[:error]' do
      expect(flash[:error]).to be_present
    end
  end

  shared_examples :graetzl_context do
    it 'assigns @graetzl' do
      expect(assigns(:graetzl)).to eq graetzl
    end
  end

  shared_examples :a_successfull_location_request do

    it 'assigns @location' do
      expect(assigns(:location)).to eq location
    end
  end


  # Controller methods
  describe 'GET new' do
    context 'when logged out' do
      it 'redirects to login with flash' do
        get :new
        expect(response).to render_template(session[:new])
      end
    end

    context 'when logged in' do
      let(:user) { create(:user) }

      before do
        sign_in user
        get :new
      end

      it 'assigns no graetzl' do
        expect(assigns(:graetzl)).not_to be
      end

      it 'renders :graetzl_form' do
        expect(response).to render_template(:graetzl_form)
      end
    end
  end

  describe 'POST new' do
    context 'when logged out' do
      it 'redirects to login with flash' do
        post :new
        expect(response).to render_template(session[:new])
      end
    end

    context 'when logged in' do
      let(:graetzl) { create(:graetzl) }
      let(:user) { create(:user) }

      before do
        sign_in user
        post :new, graetzl_id: graetzl.id
      end

      it 'assigns @graetzl' do
        expect(assigns(:graetzl)).to eq graetzl
      end

      it 'assigns @location' do
        expect(assigns(:location)).to be_a_new(Location)
      end

      it 'renders :new' do
        expect(response).to render_template(:new)
      end
    end
  end

  #     context 'when non-business' do
  #       let(:user) { create(:user) }
  #       before do
  #         sign_in user
  #         post :new
  #       end
  #       include_examples :an_unauthenticated_request
  #     end

  #     context 'when business user' do
  #       let(:user) { create(:user_business) }
  #       let(:params) { {} }
  #       before { sign_in user }

  #       describe 'without :address parameter' do
  #         before { post :new, params }
  #         it 'renders :address_form' do
  #           expect(response).to render_template(:address_form)
  #         end
  #       end

  #       describe 'without :feature parameter' do
  #         before do
  #           params.merge!(address: 'something')
  #           post :new, params
  #         end

  #         it 'assigns @graetzl with user.graetzl' do
  #           expect(assigns(:graetzl)).to eq user.graetzl
  #         end

  #         it 'assigns @location with empty address' do
  #           expect(assigns(:location)).to be_an_instance_of(Location)
  #           expect(assigns(:location).address).to have_attributes(
  #             street_name: nil,
  #             street_number: nil,
  #             zip: nil,
  #             city: nil,
  #             coordinates: nil)
  #         end

  #         it 'renders :new' do
  #           expect(response).to render_template(:new)
  #         end
  #       end

  #       describe 'with :feature parameter' do
  #         let!(:new_graetzl) { create(:graetzl,
  #           area: 'POLYGON ((20.0 20.0, 20.0 30.0, 30.0 30.0, 30.0 20.0, 20.0 20.0))') }
  #         let(:feature) { feature_hash(25,25) }
  #         before do
  #           params.merge!({ address: 'something', feature: feature.to_json })
  #           post :new, params
  #         end

  #         it 'assigns new @graetzl' do
  #           expect(assigns(:graetzl)).to eq new_graetzl
  #         end

  #         it 'assigns @location with address from feature' do
  #           a = Address.attributes_from_feature(feature.to_json)
  #           expect(assigns(:location)).to be_an_instance_of(Location)
  #           expect(assigns(:location).address).to have_attributes(
  #             street_name: a[:street_name],
  #             street_number: a[:street_number],
  #             zip: a[:zip],
  #             city: a[:city],
  #             coordinates: a[:coordinates])
  #         end

  #         it 'assigns @location to new_graetzl' do
  #           expect(assigns(:location).graetzl).to eq new_graetzl
  #         end

  #         it 'renders :new' do
  #           expect(response).to render_template(:new)
  #         end

  #         it 'empties session' do
  #           expect(session[:address]).to be nil
  #           expect(session[:graetzl]).to be nil
  #         end
  #       end

  #       describe 'with locations nearby' do
  #         let!(:new_graetzl) { create(:graetzl,
  #           area: 'POLYGON ((20.0 20.0, 20.0 30.0, 30.0 30.0, 30.0 20.0, 20.0 20.0))') }
  #         let!(:l_managed) { create(:location_managed,
  #           address: build(:address, coordinates: 'POINT (25.00 25.00)')) }
  #         let!(:l_basic) { create(:location_basic,
  #           address: build(:address, coordinates: 'POINT (25.00 25.00)')) }
  #         let(:feature) { feature_hash(25.00,25.00) }
  #         before do
  #           params.merge!({ address: 'something', feature: feature.to_json })
  #           post :new, params
  #         end

  #         it 'assigns @address with address from feature' do
  #           a = Address.attributes_from_feature(feature.to_json)
  #           expect(assigns(:address)).to have_attributes(
  #             street_name: a[:street_name],
  #             street_number: a[:street_number],
  #             zip: a[:zip],
  #             city: a[:city],
  #             coordinates: a[:coordinates])
  #         end

  #         it 'assigns @locations' do
  #           expect(assigns(:locations)).to contain_exactly(l_managed, l_basic)
  #         end

  #         it 'stores address and graetzl in session' do
  #           expect(session[:address]).to eq assigns(:address).attributes
  #           expect(session[:graetzl]).to eq new_graetzl.id
  #         end

  #         it 'renders :adopt' do
  #           expect(response).to render_template(:adopt)
  #         end
  #       end
  #     end
  #   end
  # end

  describe 'GET index' do
    let!(:location_basic) { create(:location_basic, graetzl: graetzl) }
    let!(:location_managed) { create(:location_managed, graetzl: graetzl) }
    let!(:location_pending) { create(:location_pending, graetzl: graetzl) }
    let!(:other_location) { create(:location, graetzl: create(:graetzl)) }

    shared_examples :a_successfull_index_request do

      it 'renders :index' do
        expect(response).to render_template(:index)
      end

      it 'assigns @locations' do
        expect(assigns(:locations)).to be
      end

      describe '@locations' do

        # it 'contains basic and managed' do
        #   expect(assigns(:locations)).to include(location_basic, location_managed)
        # end

        it 'contains only managed' do
          expect(assigns(:locations)).to include(location_managed)
        end

        it 'does not contain pending' do
          expect(assigns(:locations)).not_to include(location_pending)
        end

        it 'does not contain other locations' do
          expect(assigns(:locations)).not_to include(other_location)
        end
      end
    end

    context 'when logged out' do    
      before { get :index, graetzl_id: graetzl }
      include_examples :a_successfull_index_request
    end

    context 'when business user' do
      let(:user) { create(:user_business) }
      before do
        sign_in user
        get :index, graetzl_id: graetzl
      end
      include_examples :a_successfull_index_request
    end

    context 'when non business user' do
      let(:user) { create(:user) }
      before do
        sign_in user
        get :index, graetzl_id: graetzl
      end
      include_examples :a_successfull_index_request
    end
  end

  describe 'GET show' do    
    let(:location) { create(:location, graetzl: graetzl) }
    let(:location_meeting) { create(:meeting, location: location) }
    let(:location_meeting_past) { build(:meeting, location: location, starts_at_date: Date.yesterday) }
    before { location_meeting_past.save(validate: false) }

    shared_examples :a_successfull_show_request do

      it 'renders :show' do
        expect(response).to render_template(:show)
      end

      it 'assigns @location' do
        expect(assigns(:location)).to eq location
      end

      it 'assigns @meetings' do
        expect(assigns(:meetings)).to be
      end

      describe '@meetings' do
        subject(:meetings) { assigns(:meetings) }

        it 'includes upcoming location meetings' do
          expect(meetings).to include(location_meeting)
        end

        it 'excludes past location meetings' do
          expect(assigns(:meetings)).not_to include(location_meeting_past)
        end
      end
    end

    context 'when logged out' do
      before { get :show, graetzl_id: graetzl, id: location }
      include_examples :a_successfull_show_request
    end

    context 'when business user' do
      let(:user) { create(:user) }
      before do
        sign_in user
        get :show, graetzl_id: graetzl, id: location
      end
      include_examples :a_successfull_show_request
    end

    context 'when non business user' do
      let(:user) { create(:user_business) }
      before do
        sign_in user
        get :show, graetzl_id: graetzl, id: location
      end
      include_examples :a_successfull_show_request
    end

    context 'when wrong graetzl' do
      before do
        get :show, graetzl_id: create(:graetzl).slug, id: location
      end

      it 'redirects to right graetzl' do
        expect(response).to redirect_to [graetzl, location]
      end
    end
  end

  describe 'POST create' do
    let(:user) { create(:user_business) }
    before { sign_in user }

    context 'with valid attributes' do
      let(:params) {
        {
          location: attributes_for(:location).
            merge(graetzl_id: graetzl.id).
            merge({ contact_attributes: attributes_for(:contact) }).
            merge({ address_attributes: attributes_for(:address) })
        }
      }

      it 'creates new location record' do
        expect{
          post :create, params
        }.to change(Location, :count).by(1)
      end

      describe 'location' do
        before { post :create, params }
        subject(:new_location) { Location.last }

        it 'has graetzl' do
          expect(new_location.graetzl).to eq graetzl
        end

        it 'is pending' do
          expect(new_location.pending?).to be_truthy
        end

        it 'has current_user associated' do
          expect(new_location.users).to include(user)
        end
      end

      it 'creates location_ownership' do
        expect{
          post :create, params
        }.to change(LocationOwnership, :count).by(1)        
      end

      it 'redirects to root with notice' do
        post :create, params
        expect(response).to redirect_to root_url
        expect(flash[:notice]).to be_present
      end
    end
  end

  describe 'GET edit' do
    context 'when basic location' do
      let(:location) { create(:location,
        graetzl: graetzl,
        state: Location.states[:basic]) }

      context 'when non-business user' do
        let(:user) { create(:user, role: nil) }
        before do
          sign_in user
          get :edit, id: location
        end

        include_examples :an_unauthorized_request
      end

      context 'when business user' do
        let(:user) { create(:user, role: User.roles[:business]) }

        before do
          sign_in user
          get :edit, id: location
        end

        include_examples :a_successfull_location_request

        it 'renders :edit' do
          expect(response).to render_template(:edit)
        end
      end
    end

    context 'when managed location' do
      let!(:location) { create(:location,
        graetzl: graetzl,
        state: Location.states[:managed]) }

      context 'when business user' do
        let(:user) { create(:user_business) }

        before { sign_in user }

        context 'without ownership' do

          it 'redirects to root with flash[:notice]' do
            get :edit, id: location
            expect(response).to redirect_to root_url
            expect(flash[:notice]).to be_present
          end

          it 'opens ownership_request' do
            expect{
              get :edit, id: location
            }.to change(LocationOwnership, :count).by(1)
          end
        end

        context 'with basic ownership' do
          before do
            create(:location_ownership, location: location, user: user)
            get :edit, graetzl_id: graetzl, id: location
          end

          include_examples :a_successfull_location_request

          it 'renders :edit' do
            expect(response).to render_template(:edit)
          end
        end

        context 'with pending ownership' do
          before do
            create(:location_ownership, location: location, user: user, state: LocationOwnership.states[:pending])
            get :edit, id: location
          end

          include_examples :a_successfull_location_request

          it 'redirect_to root' do
            expect(response).to redirect_to root_url
          end

          it 'shows flash[:notice]' do
            expect(flash[:notice]).to be_present
          end
        end
      end
    end
  end

  describe 'PUT update' do
    let(:location) { create(:location, graetzl: graetzl) }
    let(:params) {
        {
          id: location,
          location: attributes_for(:location)
        }
      }


    context 'when logged out' do
      before { put :update, params }
      include_examples :an_unauthenticated_request
    end

    context 'when non-business user' do
      let(:user) { create(:user, role: nil) }
      before do
        sign_in user
        put :update, params
      end

      include_examples :an_unauthorized_request
    end

    context 'when business user' do
      let(:user) { create(:user_business) }
      before { sign_in user }

      context 'with basic location' do
        before { location.basic! }

        it 'updates state to pending' do
          expect{
            put :update, params
          }.to change{location.reload.state}.to 'pending'
        end

        it 'adds current_user to users' do
          put :update, params
          expect(assigns(:location).users).to include(user)
        end

        it 'redirects to root with flash[:notice]' do
          put :update, params
          expect(response).to redirect_to root_url
          expect(flash[:notice]).to be_present
        end
      end

      context 'with managed location' do
        before { location.managed! }

        it 'does not change state' do
          expect{
            put :update, params
          }.not_to change{location.state}
        end

        it 'redirects to @location' do
          put :update, params
          expect(response).to redirect_to [graetzl, location]
        end
      end

      context 'with pending location' do
        before { location.pending! }

        it 'does not change state' do
          expect{
            put :update, params
          }.not_to change{location.state}
        end
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:location) { create(:location) }

    context 'when logged out' do
      before { delete :destroy, id: location }

      include_examples :an_unauthenticated_request
    end
    context 'when logged in' do
      let(:user) { create(:user) }
      before { sign_in user }

      context 'when non business user' do
        before { delete :destroy, id: location }

        include_examples :an_unauthenticated_request
      end
      context 'when business user' do
        before { user.business! }

        context 'when no location_ownership' do
          before { delete :destroy, id: location }

          include_examples :an_unauthenticated_request
        end
        context 'when location owner' do
          before { create(:location_ownership, user: user, location: location) }

          it 'deletes location record' do
            expect{
              delete :destroy, id: location
            }.to change{Location.count}.by(-1)
          end

          it 'redirects back to previous page' do
            delete :destroy, id: location
            expect(response).to redirect_to 'where_i_came_from'
          end
        end
      end
    end
  end
end
