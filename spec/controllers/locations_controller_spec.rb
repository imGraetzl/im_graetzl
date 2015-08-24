require 'rails_helper'
include GeojsonSupport

RSpec.describe LocationsController, type: :controller do
  let(:graetzl) { create(:graetzl) }

  # Shared Examples:
  shared_examples :an_unauthenticated_request do
    it 'redirects to login' do
      expect(response).to render_template(session[:new])
    end
  end

  shared_examples :an_unauthorized_request do
    it 'redirects to @graetzl' do
      expect(response).to redirect_to graetzl
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


  describe 'GET new' do
    context 'when logged out' do
      before { get :new, graetzl_id: graetzl }
      include_examples :graetzl_context
      it_behaves_like :an_unauthenticated_request
    end

    context 'when non-business' do
      let(:user) { create(:user) }
      before do
        sign_in user
        get :new, graetzl_id: graetzl
      end
      include_examples :graetzl_context
      it_behaves_like :an_unauthenticated_request
    end

    context 'when business user' do
      let(:user) { create(:user_business) }
      before { sign_in user }

      context 'without address in session' do
        before { get :new, graetzl_id: graetzl }
        include_examples :graetzl_context

        it 'renders :address_form' do
          expect(response).to render_template(:address_form)
        end
      end

      context 'with address attributes in session' do
        let(:address) { build(:address, addressable_type: 'Location') }
        before do
          session[:address] = address.attributes
          get :new, graetzl_id: graetzl
        end
        include_examples :graetzl_context

        it 'assigns @location with address' do
          expect(assigns(:location)).to be_an_instance_of(Location)
          expect(assigns(:location).address.attributes).to eq address.attributes
        end

        it 'renders :new' do
          expect(response).to render_template(:new)
        end
      end
    end

    describe 'POST new' do
      context 'when logged out' do
        before { post :new, graetzl_id: graetzl }
        include_examples :graetzl_context
        it_behaves_like :an_unauthenticated_request
      end

      context 'when non-business' do
        let(:user) { create(:user) }
        before do
          sign_in user
          post :new, graetzl_id: graetzl
        end
        include_examples :graetzl_context
        it_behaves_like :an_unauthenticated_request
      end

      context 'when business user' do
        let(:user) { create(:user_business) }
        let(:params) { { graetzl_id: graetzl } }
        before { sign_in user }

        describe 'without :address parameter' do
          before { post :new, params }
          include_examples :graetzl_context

          it 'renders :address_form' do
            expect(response).to render_template(:address_form)
          end
        end

        describe 'without :feature parameter' do
          before do
            params.merge!(address: 'something')
            post :new, params
          end
          include_examples :graetzl_context

          it 'assigns @location with empty address' do
            expect(assigns(:location)).to be_an_instance_of(Location)
            expect(assigns(:location).address).to have_attributes(
              street_name: nil,
              street_number: nil,
              zip: nil,
              city: nil,
              coordinates: nil)
          end

          it 'renders :new' do
            expect(response).to render_template(:new)
          end
        end

        describe 'with :feature parameter' do
          let!(:new_graetzl) { create(:graetzl,
            area: 'POLYGON ((0.0 0.0, 0.0 2.0, 2.0 2.0, 2.0 0.0, 0.0 0.0))') }
          let(:feature) { feature_hash(1,1) }
          before do
            params.merge!({ address: 'something', feature: feature.to_json })
            post :new, params
          end

          it 'assigns new @graetzl' do
            #expect(assigns(:graetzl)).to eq new_graetzl
            expect(assigns(:location).address.graetzl).to eq new_graetzl
          end

          it 'assigns @location with address from feature' do
            a = Address.attributes_from_feature(feature.to_json)
            puts a
            expect(assigns(:location)).to be_an_instance_of(Location)
            expect(assigns(:location).address).to have_attributes(
              street_name: a[:street_name],
              street_number: a[:street_number],
              zip: a[:zip],
              city: a[:city],
              coordinates: a[:coordinates])
          end

          it 'assigns @location to new_graetzl' do
            expect(assigns(:location).graetzl).to eq new_graetzl
          end

          it 'renders :new' do
            expect(response).to render_template(:new)
          end
        end
      end
    end
  end

  # describe 'GET index' do

  #   shared_examples :a_successfull_index_request do
  #     let!(:location_basic) { create(:location_basic, graetzl: graetzl) }
  #     let!(:location_managed) { create(:location_managed, graetzl: graetzl) }
  #     let!(:location_pending) { create(:location_pending, graetzl: graetzl) }
  #     let!(:other_location) { create(:location, graetzl: create(:graetzl)) }

  #     before do
  #       sign_in user
  #       get :index, graetzl_id: graetzl
  #     end

  #     it 'renders :index' do
  #       expect(response).to render_template(:index)
  #     end

  #     it 'assigns @locations' do
  #       expect(assigns(:locations)).to be
  #     end

  #     describe '@locations' do

  #       it 'contains basic and managed' do
  #         expect(assigns(:locations)).to include(location_basic, location_managed)
  #       end

  #       it 'does not contain pending' do
  #         expect(assigns(:locations)).not_to include(location_pending)
  #       end

  #       it 'does not contain other locations' do
  #         expect(assigns(:locations)).not_to include(other_location)
  #       end
  #     end
  #   end

  #   context 'when business user' do
  #     let(:user) { create(:user_business) }
  #     it_behaves_like :a_successfull_index_request
  #   end

  #   context 'when non business user' do
  #     let(:user) { create(:user) }
  #     it_behaves_like :a_successfull_index_request
  #   end
  # end

  # describe 'GET show' do
  #   shared_examples :a_successfull_show_request do
  #     let(:location) { create(:location, graetzl: graetzl) }
  #     let(:location_meeting) { create(:meeting, location: location) }
  #     let(:location_meeting_past) { build(:meeting, location: location, starts_at_date: Date.yesterday) }

  #     before do
  #       sign_in user
  #       location_meeting_past.save(validate: false)
  #       get :show, graetzl_id: graetzl, id: location
  #     end

  #     it 'renders :show' do
  #       expect(response).to render_template(:show)
  #     end

  #     it 'assigns @location' do
  #       expect(assigns(:location)).to eq location
  #     end

  #     it 'assigns @meetings' do
  #       expect(assigns(:meetings)).to be
  #     end

  #     describe '@meetings' do
  #       subject(:meetings) { assigns(:meetings) }

  #       it 'includes upcoming location meetings' do
  #         expect(meetings).to include(location_meeting)
  #       end

  #       it 'excludes past location meetings' do
  #         expect(assigns(:meetings)).not_to include(location_meeting_past)
  #       end
  #     end
  #   end

  #   context 'when business user' do
  #     let(:user) { create(:user) }
  #     it_behaves_like :a_successfull_show_request
  #   end

  #   context 'when non business user' do
  #     let(:user) { create(:user_business) }
  #     it_behaves_like :a_successfull_show_request
  #   end
  # end

  # describe 'POST create' do
  #   let(:user) { create(:user_business) }

  #   before { sign_in user }

  #   it 'empties session' do
  #     session[:address] = Address.new.attributes
  #     expect{
  #       post :create, graetzl_id: graetzl, location: attributes_for(:location)
  #     }.to change{ session[:address] }.to nil
  #   end

  #   context 'with valid attributes' do
  #     let(:params) {
  #       {
  #         graetzl_id: graetzl,
  #         location: attributes_for(:location).
  #           merge({ contact_attributes: attributes_for(:contact) }).
  #           merge({ address_attributes: attributes_for(:address) })
  #       }
  #     }

  #     it 'creates new location record' do
  #       expect{
  #         post :create, params
  #       }.to change(Location, :count).by(1)
  #     end

  #     describe 'location' do
  #       before { post :create, params }
  #       subject(:new_location) { Location.last }

  #       it 'has @graetzl' do
  #         expect(new_location.graetzl).to eq graetzl
  #       end

  #       it 'is pending' do
  #         expect(new_location.pending?).to be_truthy
  #       end

  #       it 'has current_user associated' do
  #         expect(new_location.users).to include(user)
  #       end
  #     end

  #     it 'creates location_ownership' do
  #       expect{
  #         post :create, params
  #       }.to change(LocationOwnership, :count).by(1)        
  #     end

  #     it 'redirects to graetzl with notice' do
  #       post :create, params
  #       expect(response).to redirect_to graetzl
  #       expect(flash[:notice]).to be_present
  #     end
  #   end
  # end

  # describe 'GET edit' do
  #   context 'when basic location' do
  #     let(:location) { create(:location,
  #       graetzl: graetzl,
  #       state: Location.states[:basic]) }

  #     context 'when non-business user' do
  #       let(:user) { create(:user, role: nil) }

  #       before do
  #         sign_in user
  #         get :edit, graetzl_id: graetzl, id: location
  #       end

  #       it 'redirects to @graetzl with flash[:error] message' do
  #         expect(response).to redirect_to graetzl
  #         expect(flash[:error]).to be_present
  #       end
  #     end

  #     context 'when business user' do
  #       let(:user) { create(:user, role: User.roles[:business]) }

  #       before do
  #         sign_in user
  #         get :edit, graetzl_id: graetzl, id: location
  #       end

  #       it_behaves_like :a_successfull_location_request

  #       it 'renders :edit' do
  #         expect(response).to render_template(:edit)
  #       end
  #     end
  #   end

  #   context 'when managed location' do
  #     let!(:location) { create(:location,
  #       graetzl: graetzl,
  #       state: Location.states[:managed]) }

  #     context 'when business user' do
  #       let(:user) { create(:user_business) }

  #       before { sign_in user }

  #       context 'without ownership' do

  #         it 'redirects to @graetzl with flash[:notice]' do
  #           get :edit, graetzl_id: graetzl, id: location
  #           expect(response).to redirect_to graetzl
  #           expect(flash[:notice]).to be_present
  #         end

  #         it 'opens ownership_request' do
  #           expect{
  #             get :edit, graetzl_id: graetzl, id: location
  #           }.to change(LocationOwnership, :count).by(1)
  #         end
  #       end

  #       context 'with basic ownership' do
  #         before do
  #           create(:location_ownership, location: location, user: user)
  #           get :edit, graetzl_id: graetzl, id: location
  #         end

  #         it_behaves_like :a_successfull_location_request

  #         it 'renders :edit' do
  #           expect(response).to render_template(:edit)
  #         end
  #       end

  #       context 'with pending ownership' do
  #         before do
  #           create(:location_ownership, location: location, user: user, state: LocationOwnership.states[:pending])
  #           get :edit, graetzl_id: graetzl, id: location
  #         end

  #         it_behaves_like :a_successfull_location_request

  #         it 'redirect_to @graetzl' do
  #           expect(response).to redirect_to(graetzl)
  #         end

  #         it 'shows flash[:notice]' do
  #           expect(flash[:notice]).to be_present
  #         end
  #       end
  #     end
  #   end
  # end

  # describe 'PUT update' do
  #   let(:location) { create(:location, graetzl: graetzl) }
  #   let(:user) { create(:user_business) }
  #   let(:params) {
  #       {
  #         graetzl_id: graetzl,
  #         id: location,
  #         location: attributes_for(:location)
  #       }
  #     }
  #   before { sign_in user }

  #   context 'with basic location' do
  #     before { location.basic! }

  #     it 'updates state to pending' do
  #       expect{
  #         put :update, params
  #       }.to change{location.reload.state}.to 'pending'
  #     end

  #     it 'adds current_user to users' do
  #       put :update, params
  #       expect(assigns(:location).users).to include(user)
  #     end

  #     it 'redirects to @graetzl with flash[:notice]' do
  #       put :update, params
  #       expect(response).to redirect_to graetzl
  #       expect(flash[:notice]).to be_present
  #     end
  #   end

  #   context 'with managed location' do
  #     before { location.managed! }

  #     it 'does not change state' do
  #       expect{
  #         put :update, params
  #       }.not_to change{location.state}
  #     end

  #     it 'redirects to @location' do
  #       put :update, params
  #       expect(response).to redirect_to [graetzl, location]
  #     end
  #   end

  #   context 'with pending location' do
  #     before { location.pending! }

  #     it 'does not change state' do
  #       expect{
  #         put :update, params
  #       }.not_to change{location.state}
  #     end
  #   end
  # end
end
